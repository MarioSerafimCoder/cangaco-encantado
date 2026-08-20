class_name PlayerCombat
extends Node

@export var revolver_data: WeaponData
@export var shotgun_data: WeaponData
@export var machete_data: WeaponData

var player: CharacterBody2D
var revolver_ammo := 6
var shotgun_ammo := 2
var heal_charges := 2
var cooldown := 0.0
var reload_timer := 0.0
var reloading_weapon: StringName = &""
var healing := false
var heal_timer := 0.0
var combo_step := 0
var combo_reset_timer := 0.0


func initialize(owner_player: CharacterBody2D) -> void:
	player = owner_player
	revolver_ammo = revolver_data.magazine_size
	shotgun_ammo = shotgun_data.magazine_size
	heal_charges = clampi(GameState.heal_charges, 0, player.config.heal_charges)
	_emit_all()


func update(delta: float) -> void:
	if player == null or player.is_dead:
		return
	cooldown = maxf(0.0, cooldown - delta)
	combo_reset_timer = maxf(0.0, combo_reset_timer - delta)
	if combo_reset_timer <= 0.0:
		combo_step = 0
	_update_reload(delta)
	_update_heal(delta)
	if healing:
		return
	if player.state_machine.current_state in [PlayerStateMachine.State.HURT, PlayerStateMachine.State.DEAD]:
		return
	if Input.is_action_just_pressed("heal"):
		_start_heal()
	elif Input.is_action_just_pressed("melee"):
		_use_machete()
	elif Input.is_action_just_pressed("shoot_shotgun"):
		_fire_shotgun()
	elif Input.is_action_pressed("shoot_revolver"):
		_fire_revolver()


func interrupt_heal() -> void:
	if not healing:
		return
	healing = false
	heal_timer = 0.0


func refill_at_checkpoint() -> void:
	heal_charges = player.config.heal_charges
	revolver_ammo = revolver_data.magazine_size
	shotgun_ammo = shotgun_data.magazine_size
	GameState.heal_charges = heal_charges
	_emit_all()


func _fire_revolver() -> void:
	if cooldown > 0.0 or reload_timer > 0.0:
		return
	if revolver_ammo <= 0:
		_start_reload(revolver_data)
		return
	revolver_ammo -= 1
	cooldown = revolver_data.fire_interval
	player.state_machine.request(PlayerStateMachine.State.SHOOT, 0.08)
	player.spawn_projectile(revolver_data, player.get_aim_direction(), &"revolver")
	EventBus.player_ammo_changed.emit(&"revolver", revolver_ammo, revolver_data.magazine_size)
	if revolver_ammo == 0:
		_start_reload(revolver_data)


func _fire_shotgun() -> void:
	if cooldown > 0.0 or reload_timer > 0.0:
		return
	if shotgun_ammo <= 0:
		_start_reload(shotgun_data)
		return
	shotgun_ammo -= 1
	cooldown = shotgun_data.fire_interval
	player.state_machine.request(PlayerStateMachine.State.SHOTGUN, 0.18)
	var direction: Vector2 = player.get_aim_direction()
	for angle in [-0.10, 0.0, 0.10]:
		player.spawn_projectile(shotgun_data, direction.rotated(angle), &"shotgun")
	player.velocity.x -= direction.x * shotgun_data.recoil
	EventBus.player_ammo_changed.emit(&"shotgun", shotgun_ammo, shotgun_data.magazine_size)
	if shotgun_ammo == 0:
		_start_reload(shotgun_data)


func _use_machete() -> void:
	if cooldown > 0.0:
		return
	combo_step = (combo_step % 3) + 1
	combo_reset_timer = 0.8
	cooldown = machete_data.fire_interval + (0.06 if combo_step == 3 else 0.0)
	player.state_machine.request(PlayerStateMachine.State.MELEE, 0.16)
	var variant := &"machete"
	if Input.is_action_pressed("move_up"):
		variant = &"machete_up"
	elif not player.is_on_floor() and Input.is_action_pressed("move_down"):
		variant = &"machete_down"
	player.spawn_melee(machete_data, combo_step, variant)
	if combo_step == 2:
		player.velocity.x = player.facing * 75.0


func _start_heal() -> void:
	if heal_charges <= 0 or player.health.current_health >= player.health.max_health:
		return
	healing = true
	heal_timer = player.config.heal_duration
	player.velocity.x = 0.0
	player.state_machine.request(PlayerStateMachine.State.HEAL, player.config.heal_duration, true)


func _update_heal(delta: float) -> void:
	if not healing:
		return
	heal_timer -= delta
	if heal_timer > 0.0:
		return
	healing = false
	heal_charges -= 1
	GameState.heal_charges = heal_charges
	player.health.heal(player.config.heal_amount)
	EventBus.player_heal_charges_changed.emit(heal_charges, player.config.heal_charges)


func _start_reload(data: WeaponData) -> void:
	if reload_timer > 0.0:
		return
	reloading_weapon = data.id
	reload_timer = data.reload_time


func _update_reload(delta: float) -> void:
	if reload_timer <= 0.0:
		return
	reload_timer -= delta
	if reload_timer > 0.0:
		return
	if reloading_weapon == &"revolver":
		revolver_ammo = revolver_data.magazine_size
		EventBus.player_ammo_changed.emit(&"revolver", revolver_ammo, revolver_data.magazine_size)
	elif reloading_weapon == &"shotgun":
		shotgun_ammo = shotgun_data.magazine_size
		EventBus.player_ammo_changed.emit(&"shotgun", shotgun_ammo, shotgun_data.magazine_size)
	reloading_weapon = &""


func _emit_all() -> void:
	EventBus.player_ammo_changed.emit(&"revolver", revolver_ammo, revolver_data.magazine_size)
	EventBus.player_ammo_changed.emit(&"shotgun", shotgun_ammo, shotgun_data.magazine_size)
	EventBus.player_heal_charges_changed.emit(heal_charges, player.config.heal_charges)


func debug_snapshot() -> Dictionary:
	return {
		"revolver": revolver_ammo,
		"shotgun": shotgun_ammo,
		"heals": heal_charges,
		"reload": reloading_weapon,
	}
