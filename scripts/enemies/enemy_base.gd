class_name EnemyBase
extends CharacterBody2D

const COMBAT_FEEDBACK := preload("res://resources/combat/feedback.tres")

@export var data: EnemyData
@export var hostile_in_liberated_state := false

@onready var health: HealthComponent = $HealthComponent
@onready var posture: PostureComponent = $PostureComponent
@onready var detection: EnemyDetection = $Detection
@onready var movement: EnemyMovement = $Movement
@onready var state_machine: EnemyStateMachine = $StateMachine

var attack_cooldown := 0.0
var facing := -1.0
var target: Node2D


func _ready() -> void:
	add_to_group("enemies")
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
	state_machine.tick(delta)
	if state_machine.current in [EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER] and state_machine.lock_remaining <= 0.0:
		state_machine.transition(EnemyStateMachine.State.IDLE, 0.0, true)
	target = detection.acquire(self)
	var direction := 0.0
	if target != null and state_machine.can_act():
		var distance := global_position.distance_to(target.global_position)
		facing = signf(target.global_position.x - global_position.x)
		if distance <= data.attack_range and attack_cooldown <= 0.0:
			state_machine.transition(EnemyStateMachine.State.ATTACK, 0.2)
			_perform_attack()
		elif _should_chase(distance):
			state_machine.transition(EnemyStateMachine.State.CHASE)
			direction = facing
		else:
			state_machine.transition(EnemyStateMachine.State.IDLE)
	movement.physics_step(self, direction, delta, state_machine.can_act())
	queue_redraw()


func _should_chase(distance: float) -> bool:
	if data.behavior == EnemyData.Behavior.RANGED:
		return distance > data.attack_range * 0.82
	return distance > data.attack_range * 0.65


func _perform_attack() -> void:
	attack_cooldown = data.attack_cooldown
	if data.behavior == EnemyData.Behavior.RANGED:
		_spawn_projectile(Vector2(facing, 0.0), 250.0, 180.0, &"enemy_bullet")
	else:
		_spawn_melee()


func _spawn_melee() -> void:
	var hitbox := AttackHitbox.new()
	hitbox.team = "enemy"
	hitbox.damage = data.attack_damage
	hitbox.posture_damage = 0.0
	hitbox.knockback = Vector2(facing * 110.0, -75.0)
	hitbox.attack_id = &"enemy_melee"
	hitbox.owner_actor = self
	hitbox.lifetime = 0.14
	hitbox.setup_shape(Vector2(13.0, 10.0))
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = global_position + Vector2(facing * 17.0, -3.0)


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
	var accepted := health.take_damage(int(hit.get("damage", 1)), source)
	if not accepted:
		return false
	var posture_was_broken := posture.broken
	posture.apply_posture_damage(float(hit.get("posture_damage", 0.0)))
	if not posture_was_broken and posture.broken:
		HitStop.apply([self, source as Node], COMBAT_FEEDBACK.posture_break_hitstop)
	velocity = hit.get("knockback", Vector2.ZERO)
	if state_machine.current != EnemyStateMachine.State.STAGGER:
		state_machine.transition(EnemyStateMachine.State.HURT, 0.12, true)
	facing = signf(global_position.x - source_position.x)
	return true


func _on_posture_broken(duration: float) -> void:
	state_machine.transition(EnemyStateMachine.State.STAGGER, duration, true)


func _on_died() -> void:
	state_machine.transition(EnemyStateMachine.State.DEAD, 0.0, true)
	set_physics_process(false)
	collision_layer = 0
	$Hurtbox.set_deferred("monitorable", false)
	await get_tree().create_timer(0.25).timeout
	queue_free()


func _on_world_state_changed(region_id: StringName, state: StringName) -> void:
	if region_id == &"vila_umbuzeiro" and state == WorldState.LIBERATED and not hostile_in_liberated_state:
		queue_free()


func _draw() -> void:
	var visual := get_node_or_null("Visual") as Sprite2D
	if visual != null and visual.texture != null:
		return
	var color := Color("a73d31")
	if data.behavior == EnemyData.Behavior.RANGED:
		color = Color("663f8c")
	elif data.behavior == EnemyData.Behavior.BOSS:
		color = Color("23191c")
	if state_machine.current == EnemyStateMachine.State.STAGGER:
		color = Color("f4d35e")
	draw_rect(Rect2(-7.0, -13.0, 14.0, 26.0), color, true)
	draw_line(Vector2(0.0, -7.0), Vector2(facing * 8.0, -7.0), Color.WHITE, 2.0)
