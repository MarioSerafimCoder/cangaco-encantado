class_name EnemyBase
extends CharacterBody2D

const COMBAT_FEEDBACK := preload("res://resources/combat/feedback.tres")

enum AttackPhase { NONE, ANTICIPATION, ACTIVE, RECOVERY }

@export var data: EnemyData
@export var hostile_in_liberated_state := false

@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var detection: EnemyDetection = $Detection
@onready var movement: EnemyMovement = $Movement
@onready var state_machine: EnemyStateMachine = $StateMachine

var attack_cooldown := 0.0
var attack_phase := AttackPhase.NONE
var attack_phase_remaining := 0.0
var attack_facing := -1.0
var combat_bar_visible_remaining := 0.0
var facing := -1.0
var target: Node2D
var home_position := Vector2.ZERO
var last_known_target_position := Vector2.ZERO
var target_memory_remaining := 0.0
var target_visible := false
var patrol_direction := -1.0
var patrol_wait_remaining := 0.0
var patrol_radius_override := -1.0
var death_elapsed := 0.0


func _ready() -> void:
	add_to_group("enemies")
	home_position = global_position
	patrol_direction = facing
	patrol_wait_remaining = data.patrol_wait * 0.5
	health.configure(data.max_health)
	posture.configure(data.max_posture, data.stagger_duration)
	detection.detection_range = data.detection_range
	movement.move_speed = data.move_speed
	health.died.connect(_on_died)
	posture.posture_broken.connect(_on_posture_broken)
	EventBus.world_state_changed.connect(_on_world_state_changed)
	if WorldState.is_vila_liberated() and not hostile_in_liberated_state:
		queue_free()
	queue_redraw()


func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	combat_bar_visible_remaining = maxf(0.0, combat_bar_visible_remaining - delta)
	state_machine.tick(delta)
	if state_machine.current in [EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER] and state_machine.lock_remaining <= 0.0:
		state_machine.transition(EnemyStateMachine.State.IDLE, 0.0, true)
	_update_perception(delta)
	if attack_phase != AttackPhase.NONE:
		_update_attack_sequence(delta)
		movement.physics_step(self, 0.0, delta, false)
		queue_redraw()
		return
	if not state_machine.can_act():
		movement.physics_step(self, 0.0, delta, false)
		queue_redraw()
		return
	var direction := 0.0
	if target != null:
		direction = _combat_direction()
	elif target_memory_remaining > 0.0:
		direction = _search_direction()
	else:
		direction = _patrol_or_return_direction(delta)
	var safe_direction := movement.safe_direction(self, direction)
	if not is_zero_approx(direction) and is_zero_approx(safe_direction):
		_on_movement_blocked(direction)
	direction = safe_direction
	movement.physics_step(self, direction, delta, state_machine.can_act())
	queue_redraw()


func configure_post(position_value: Vector2, initial_facing: float, patrol_radius_value := -1.0) -> void:
	home_position = position_value
	facing = signf(initial_facing) if not is_zero_approx(initial_facing) else -1.0
	patrol_direction = facing
	patrol_radius_override = patrol_radius_value
	patrol_wait_remaining = data.patrol_wait * 0.5


func _update_perception(delta: float) -> void:
	if global_position.distance_to(home_position) > data.leash_range:
		target = null
		target_visible = false
		target_memory_remaining = 0.0
		return
	var candidate := detection.acquire(self)
	target_visible = candidate != null and detection.has_line_of_sight(self, candidate)
	if target_visible:
		target = candidate
		last_known_target_position = target.global_position
		target_memory_remaining = data.target_memory
		return
	if target != null and is_instance_valid(target) and target_memory_remaining > 0.0:
		target_memory_remaining = maxf(0.0, target_memory_remaining - delta)
		if target_memory_remaining <= 0.0:
			target = null
		return
	target = null
	target_memory_remaining = 0.0


func _combat_direction() -> float:
	var aim_position := target.global_position if target_visible else last_known_target_position
	var horizontal_delta := aim_position.x - global_position.x
	var distance := global_position.distance_to(aim_position)
	if not is_zero_approx(horizontal_delta):
		facing = signf(horizontal_delta)
	if not target_visible:
		state_machine.transition(EnemyStateMachine.State.CHASE)
		return facing if absf(horizontal_delta) > 5.0 else 0.0
	if data.behavior == EnemyData.Behavior.RANGED:
		return _ranged_combat_direction(distance)
	if distance <= data.attack_range and attack_cooldown <= 0.0:
		_begin_attack()
		return 0.0
	state_machine.transition(EnemyStateMachine.State.CHASE)
	return facing


func _ranged_combat_direction(distance: float) -> float:
	if distance < data.ranged_min_distance:
		var retreat_direction := -facing
		if not is_zero_approx(movement.safe_direction(self, retreat_direction)):
			state_machine.transition(EnemyStateMachine.State.RETREAT)
			return retreat_direction
		if attack_cooldown <= 0.0:
			_begin_attack()
		return 0.0
	if distance > data.ranged_preferred_distance:
		state_machine.transition(EnemyStateMachine.State.CHASE)
		return facing
	if attack_cooldown <= 0.0:
		_begin_attack()
	else:
		state_machine.transition(EnemyStateMachine.State.IDLE)
	return 0.0


func _search_direction() -> float:
	var delta_x := last_known_target_position.x - global_position.x
	if absf(delta_x) <= 5.0:
		target_memory_remaining = 0.0
		target = null
		return 0.0
	facing = signf(delta_x)
	state_machine.transition(EnemyStateMachine.State.CHASE)
	return facing


func _patrol_or_return_direction(delta: float) -> float:
	var distance_home := global_position.x - home_position.x
	var radius := data.patrol_radius if patrol_radius_override < 0.0 else patrol_radius_override
	if absf(distance_home) > radius + 5.0:
		facing = -signf(distance_home)
		state_machine.transition(EnemyStateMachine.State.RETURN)
		return facing
	patrol_wait_remaining = maxf(0.0, patrol_wait_remaining - delta)
	if patrol_wait_remaining > 0.0:
		state_machine.transition(EnemyStateMachine.State.IDLE)
		return 0.0
	if radius <= 1.0:
		state_machine.transition(EnemyStateMachine.State.IDLE)
		return 0.0
	if distance_home >= radius:
		patrol_direction = -1.0
		patrol_wait_remaining = data.patrol_wait
	elif distance_home <= -radius:
		patrol_direction = 1.0
		patrol_wait_remaining = data.patrol_wait
	facing = patrol_direction
	state_machine.transition(EnemyStateMachine.State.PATROL)
	return patrol_direction


func _on_movement_blocked(attempted_direction: float) -> void:
	if state_machine.current in [EnemyStateMachine.State.PATROL, EnemyStateMachine.State.RETURN]:
		patrol_direction = -signf(attempted_direction)
		facing = patrol_direction
		patrol_wait_remaining = maxf(0.25, data.patrol_wait)
		state_machine.transition(EnemyStateMachine.State.IDLE, 0.0, true)
	elif state_machine.current == EnemyStateMachine.State.RETREAT:
		state_machine.transition(EnemyStateMachine.State.IDLE, 0.0, true)


func _begin_attack() -> void:
	if attack_phase != AttackPhase.NONE or attack_cooldown > 0.0:
		return
	attack_phase = AttackPhase.ANTICIPATION
	attack_phase_remaining = maxf(0.05, data.attack_windup)
	attack_facing = facing
	attack_cooldown = data.attack_cooldown
	var sequence_duration := data.attack_windup + data.attack_active_time + data.attack_recovery
	state_machine.transition(EnemyStateMachine.State.ATTACK, sequence_duration, true)
	velocity.x = 0.0
	queue_redraw()


func _update_attack_sequence(delta: float) -> void:
	attack_phase_remaining -= delta
	if attack_phase_remaining > 0.0:
		return
	match attack_phase:
		AttackPhase.ANTICIPATION:
			attack_phase = AttackPhase.ACTIVE
			attack_phase_remaining = maxf(0.03, data.attack_active_time)
			facing = attack_facing
			_perform_attack()
		AttackPhase.ACTIVE:
			attack_phase = AttackPhase.RECOVERY
			attack_phase_remaining = maxf(0.05, data.attack_recovery)
		AttackPhase.RECOVERY:
			attack_phase = AttackPhase.NONE
			attack_phase_remaining = 0.0
			state_machine.transition(EnemyStateMachine.State.IDLE, 0.0, true)
	queue_redraw()


func _cancel_attack() -> void:
	attack_phase = AttackPhase.NONE
	attack_phase_remaining = 0.0


func _perform_attack() -> void:
	if data.behavior == EnemyData.Behavior.RANGED:
		_spawn_projectile(Vector2(attack_facing, 0.0), 250.0, 180.0, &"enemy_bullet")
	else:
		_spawn_melee()


func _spawn_melee() -> void:
	var hitbox := AttackHitbox.new()
	hitbox.team = "enemy"
	hitbox.damage = data.attack_damage
	hitbox.posture_damage = 0.0
	hitbox.knockback = Vector2(attack_facing * 110.0, -75.0)
	hitbox.attack_id = &"enemy_melee"
	hitbox.owner_actor = self
	hitbox.lifetime = 0.14
	hitbox.setup_shape(Vector2(13.0, 10.0))
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = global_position + Vector2(attack_facing * 17.0, -3.0)


func _spawn_projectile(direction: Vector2, speed: float, distance: float, attack_id: StringName) -> void:
	var projectile := CombatProjectile.new()
	projectile.team = "enemy"
	projectile.damage = data.attack_damage
	projectile.knockback = direction * 85.0 + Vector2(0.0, -35.0)
	projectile.attack_id = attack_id
	projectile.owner_actor = self
	projectile.velocity = direction.normalized() * speed
	projectile.max_distance = distance
	projectile.lifetime = distance / speed + 0.2
	projectile.projectile_color = Color("ef476f")
	projectile.setup_shape(Vector2(4.0, 2.0))
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + Vector2(direction.x * 14.0, -6.0)


func receive_hit(hit: Dictionary) -> bool:
	if state_machine.current == EnemyStateMachine.State.DEAD:
		return false
	var source_position := global_position
	var source = hit.get("source")
	if source is Node2D:
		source_position = source.global_position
		target = source as Node2D
		last_known_target_position = source_position
		target_memory_remaining = data.target_memory
	var accepted := health.take_damage(int(hit.get("damage", 1)), source)
	if not accepted:
		return false
	if health.dead:
		return true
	_cancel_attack()
	combat_bar_visible_remaining = 2.2
	var posture_was_broken := posture.broken
	posture.apply_posture_damage(float(hit.get("posture_damage", 0.0)))
	if not posture_was_broken and posture.broken:
		HitStop.apply([self, source as Node], COMBAT_FEEDBACK.posture_break_hitstop)
	velocity = hit.get("knockback", Vector2.ZERO)
	if state_machine.current != EnemyStateMachine.State.STAGGER:
		state_machine.transition(EnemyStateMachine.State.HURT, data.hurt_duration, true)
	facing = signf(global_position.x - source_position.x)
	return true


func _on_posture_broken(duration: float) -> void:
	_cancel_attack()
	state_machine.transition(EnemyStateMachine.State.STAGGER, duration, true)


func _on_died() -> void:
	_cancel_attack()
	state_machine.transition(EnemyStateMachine.State.DEAD, 0.0, true)
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	$Hurtbox.set_deferred("monitorable", false)
	await get_tree().create_timer(data.death_duration).timeout
	queue_free()


func _on_world_state_changed(region_id: StringName, state: StringName) -> void:
	if region_id == &"vila_umbuzeiro" and state == WorldState.LIBERATED and not hostile_in_liberated_state:
		queue_free()


func _draw() -> void:
	var visual := get_node_or_null("Visual") as Sprite2D
	if visual == null or visual.texture == null:
		var color := Color("a73d31")
		if data.behavior == EnemyData.Behavior.RANGED:
			color = Color("663f8c")
		elif data.behavior == EnemyData.Behavior.BOSS:
			color = Color("23191c")
		if state_machine.current == EnemyStateMachine.State.STAGGER:
			color = Color("f4d35e")
		draw_rect(Rect2(-7.0, -13.0, 14.0, 26.0), color, true)
		draw_line(Vector2(0.0, -7.0), Vector2(facing * 8.0, -7.0), Color.WHITE, 2.0)
