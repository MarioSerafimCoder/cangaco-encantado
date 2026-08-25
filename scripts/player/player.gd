class_name NiloPlayer
extends CharacterBody2D

@export var config: PlayerConfig

@onready var health: HealthComponent = $HealthComponent
@onready var movement: PlayerMovement = $PlayerMovement
@onready var combat: PlayerCombat = $PlayerCombat
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var hurt_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var camera: Camera2D = $Camera2D

var facing := 1.0
var invulnerability_remaining := 0.0
var is_dead := false
var _crouch_applied := false
var _run_dust_remaining := 0.0
var _camera_shake_remaining := 0.0
var _camera_shake_strength := 0.0


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	health.configure(config.max_health)
	health.current_health = clampi(GameState.player_health, 1, config.max_health)
	health.health_changed.connect(_on_health_changed)
	health.healed.connect(_on_healed)
	health.died.connect(_on_died)
	movement.config = config
	combat.initialize(self)
	_on_health_changed(health.current_health, health.max_health)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_update_camera_shake(delta)
	if is_dead:
		return
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	_run_dust_remaining = maxf(0.0, _run_dust_remaining - delta)
	var grounded_before_move := is_on_floor()
	state_machine.tick(delta)
	combat.update(delta)
	movement.physics_step(self, delta, state_machine.is_movement_locked())
	var landed := not grounded_before_move and is_on_floor()
	if absf(velocity.x) > 1.0:
		facing = signf(velocity.x)
	_set_crouched(movement.crouching)
	state_machine.update_locomotion(self, movement.crouching)
	_update_locomotion_fx(landed)
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
	add_camera_shake(2.0, 0.12)
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
	var hurt_shape := hurt_collision.shape as RectangleShape2D
	hurt_shape.size = Vector2(12.0, 14.0 if value else 24.0)
	hurt_collision.position.y = 5.0 if value else 0.0


func play_weapon_feedback(weapon_id: StringName) -> void:
	match weapon_id:
		&"revolver":
			GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(facing * 18.0, -8.0), GameFeelFX.Kind.MUZZLE, facing)
			add_camera_shake(0.7, 0.05)
		&"shotgun":
			GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(facing * 20.0, -7.0), GameFeelFX.Kind.MUZZLE, facing)
			add_camera_shake(2.2, 0.13)
		&"machete":
			GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(facing * 7.0, -7.0), GameFeelFX.Kind.SLASH, facing)


func play_heal_feedback() -> void:
	GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(0.0, -10.0), GameFeelFX.Kind.HEAL, facing)


func add_camera_shake(strength: float, duration: float) -> void:
	_camera_shake_strength = maxf(_camera_shake_strength, strength)
	_camera_shake_remaining = maxf(_camera_shake_remaining, duration)


func _update_camera_shake(delta: float) -> void:
	_camera_shake_remaining = maxf(0.0, _camera_shake_remaining - delta)
	if _camera_shake_remaining <= 0.0:
		camera.offset = Vector2.ZERO
		_camera_shake_strength = 0.0
		return
	var phase := Time.get_ticks_msec() * 0.045
	var fade := clampf(_camera_shake_remaining / 0.14, 0.0, 1.0)
	camera.offset = Vector2(sin(phase * 1.7), cos(phase * 2.3)) * _camera_shake_strength * fade


func _update_locomotion_fx(landed: bool) -> void:
	if landed:
		GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(0.0, 11.0), GameFeelFX.Kind.LAND_DUST, facing)
		add_camera_shake(0.75, 0.07)
	if is_on_floor() and absf(velocity.x) > config.move_speed * 0.58 and _run_dust_remaining <= 0.0:
		_run_dust_remaining = 0.16
		GameFeelFX.spawn(get_tree().current_scene, global_position + Vector2(-facing * 5.0, 11.0), GameFeelFX.Kind.RUN_DUST, -facing)


func _on_health_changed(current: int, maximum: int) -> void:
	GameState.player_health = current
	EventBus.player_health_changed.emit(current, maximum)


func _on_healed(_amount: int) -> void:
	play_heal_feedback()


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
