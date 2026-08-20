class_name NiloPlayer
extends CharacterBody2D

@export var config: PlayerConfig

@onready var health: HealthComponent = $HealthComponent
@onready var movement: PlayerMovement = $PlayerMovement
@onready var combat: PlayerCombat = $PlayerCombat
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var body_collision: CollisionShape2D = $BodyCollision

var facing := 1.0
var invulnerability_remaining := 0.0
var is_dead := false
var _crouch_applied := false


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	health.configure(config.max_health)
	health.current_health = clampi(GameState.player_health, 1, config.max_health)
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	movement.config = config
	combat.initialize(self)
	_on_health_changed(health.current_health, health.max_health)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	state_machine.tick(delta)
	combat.update(delta)
	movement.physics_step(self, delta, state_machine.is_movement_locked())
	if absf(velocity.x) > 1.0:
		facing = signf(velocity.x)
	_set_crouched(movement.crouching)
	state_machine.update_locomotion(self, movement.crouching)
	queue_redraw()


func get_aim_direction() -> Vector2:
	if Input.is_action_pressed("aim"):
		var vertical := Input.get_axis("move_up", "move_down")
		if vertical < -0.25:
			return Vector2.UP
		if vertical > 0.25 and not is_on_floor():
			return Vector2.DOWN
	return Vector2(facing, 0.0)


func spawn_projectile(data: WeaponData, direction: Vector2, attack_id: StringName) -> void:
	var projectile := CombatProjectile.new()
	projectile.team = "player"
	projectile.damage = data.damage
	projectile.posture_damage = data.posture_damage
	projectile.knockback = direction * data.knockback
	projectile.attack_id = attack_id
	projectile.owner_actor = self
	projectile.velocity = direction.normalized() * data.projectile_speed
	projectile.max_distance = data.range
	projectile.lifetime = data.range / maxf(1.0, data.projectile_speed) + 0.1
	projectile.setup_shape(Vector2(4.0, 2.0 if attack_id == &"revolver" else 4.0))
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + direction * 12.0 + Vector2(0.0, -5.0)


func spawn_melee(data: WeaponData, combo_step: int, variant: StringName) -> void:
	var hitbox := AttackHitbox.new()
	hitbox.team = "player"
	hitbox.damage = data.damage + (1 if combo_step == 3 else 0)
	hitbox.posture_damage = data.posture_damage + (1.0 if combo_step == 3 else 0.0)
	hitbox.knockback = Vector2(facing * data.knockback * (1.35 if combo_step == 3 else 1.0), -24.0)
	hitbox.attack_id = variant
	hitbox.owner_actor = self
	hitbox.lifetime = 0.13
	var extents := Vector2(15.0 + combo_step * 2.0, 11.0)
	var offset := Vector2(facing * 18.0, -4.0)
	if variant == &"machete_up":
		extents = Vector2(10.0, 19.0)
		offset = Vector2(0.0, -22.0)
	elif variant == &"machete_down":
		extents = Vector2(11.0, 17.0)
		offset = Vector2(0.0, 19.0)
	hitbox.setup_shape(extents)
	hitbox.connected.connect(_on_melee_connected.bind(variant))
	get_tree().current_scene.add_child(hitbox)
	hitbox.global_position = global_position + offset


func receive_hit(hit: Dictionary) -> bool:
	if is_dead or invulnerability_remaining > 0.0:
		return false
	combat.interrupt_heal()
	var accepted := health.take_damage(int(hit.get("damage", 1)), hit.get("source"))
	if not accepted:
		return false
	invulnerability_remaining = config.invulnerability_time
	velocity = hit.get("knockback", Vector2.ZERO)
	state_machine.request(PlayerStateMachine.State.HURT, config.hurt_lock_time, true)
	return true


func respawn_at_checkpoint() -> void:
	global_position = GameState.checkpoint_position
	velocity = Vector2.ZERO
	is_dead = false
	health.restore_full()
	combat.refill_at_checkpoint()
	state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	invulnerability_remaining = 1.0
	visible = true


func _set_crouched(value: bool) -> void:
	if _crouch_applied == value:
		return
	_crouch_applied = value
	var shape := body_collision.shape as RectangleShape2D
	shape.size = Vector2(12.0, 14.0 if value else 24.0)
	body_collision.position.y = 5.0 if value else 0.0


func _on_health_changed(current: int, maximum: int) -> void:
	GameState.player_health = current
	EventBus.player_health_changed.emit(current, maximum)


func _on_melee_connected(_target: Node, variant: StringName) -> void:
	if variant == &"machete_down":
		velocity.y = -190.0


func _on_died() -> void:
	is_dead = true
	state_machine.request(PlayerStateMachine.State.DEAD, 0.0, true)
	EventBus.player_died.emit()
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.7).timeout
	respawn_at_checkpoint()


func _draw() -> void:
	var visual := get_node_or_null("Visual") as Sprite2D
	if visual != null and visual.texture != null:
		return
	var flash := invulnerability_remaining > 0.0 and int(invulnerability_remaining * 18.0) % 2 == 0
	if flash:
		return
	var body_height := 14.0 if _crouch_applied else 24.0
	var top := -body_height * 0.5
	draw_rect(Rect2(-6.0, top, 12.0, body_height), Color("c58b45"), true)
	draw_rect(Rect2(-7.0, top - 3.0, 14.0, 4.0), Color("7d3328"), true)
	draw_line(Vector2(0.0, top + 5.0), Vector2(facing * 8.0, top + 5.0), Color("f4d35e"), 2.0)
