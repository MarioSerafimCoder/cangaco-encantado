class_name PlayerCombat
extends Node

enum AttackPhase { NONE, ANTICIPATION, ACTIVE, FOLLOW_THROUGH, RECOVERY }

@export var revolver_data: WeaponData
@export var shotgun_data: WeaponData
@export var machete_data: WeaponData
@export var feedback_config: CombatFeedbackConfig

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
var attack_phase := AttackPhase.NONE
var attack_phase_remaining := 0.0
var buffered_melee_remaining := 0.0
var current_melee_variant: StringName = &"machete"


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
	buffered_melee_remaining = maxf(0.0, buffered_melee_remaining - delta)
	if combo_reset_timer <= 0.0 and attack_phase == AttackPhase.NONE:
		combo_step = 0
	_update_reload(delta)
	_update_heal(delta)
	if healing:
		return
	if player.state_machine.current_state in [PlayerStateMachine.State.HURT, PlayerStateMachine.State.DEAD]:
		_cancel_melee_sequence()
		return
	if attack_phase != AttackPhase.NONE:
		if Input.is_action_just_pressed("melee"):
			request_melee_input()
		_update_machete_sequence(delta)
		return
	if Input.is_action_just_pressed("heal"):
		_start_heal()
	elif Input.is_action_just_pressed("melee"):
		request_melee_input()
	elif Input.is_action_just_pressed("shoot_shotgun"):
		_fire_shotgun()
	elif Input.is_action_just_pressed("shoot_revolver"):
		_fire_revolver()


func request_melee_input() -> void:
	if attack_phase in [AttackPhase.ACTIVE, AttackPhase.FOLLOW_THROUGH, AttackPhase.RECOVERY]:
		buffered_melee_remaining = feedback_config.combo_input_buffer
	elif attack_phase == AttackPhase.NONE:
		_begin_machete_sequence()


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
	player.spawn_projectile(revolver_data, player.get_aim_direction(), &"revolver", feedback_config.revolver_hitstop)
	player.play_weapon_feedback(&"revolver")
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
	player.state_machine.request(PlayerStateMachine.State.SHOTGUN, 0.22)
	var direction: Vector2 = player.get_aim_direction()
	for angle in [-0.10, 0.0, 0.10]:
		player.spawn_projectile(shotgun_data, direction.rotated(angle), &"shotgun", feedback_config.shotgun_hitstop)
	player.velocity.x -= direction.x * shotgun_data.recoil
	player.play_weapon_feedback(&"shotgun")
	EventBus.player_ammo_changed.emit(&"shotgun", shotgun_ammo, shotgun_data.magazine_size)
	if shotgun_ammo == 0:
		_start_reload(shotgun_data)


func _begin_machete_sequence() -> void:
	if cooldown > 0.0:
		return
	combo_step = (combo_step % 3) + 1
	combo_reset_timer = feedback_config.combo_reset_time
	current_melee_variant = &"machete"
	if Input.is_action_pressed("move_up"):
		current_melee_variant = &"machete_up"
	elif not player.is_on_floor() and Input.is_action_pressed("move_down"):
		current_melee_variant = &"machete_down"
	attack_phase = AttackPhase.ANTICIPATION
	attack_phase_remaining = _phase_duration(attack_phase, combo_step)
	var total_duration := 0.0
	for phase in [AttackPhase.ANTICIPATION, AttackPhase.ACTIVE, AttackPhase.FOLLOW_THROUGH, AttackPhase.RECOVERY]:
		total_duration += _phase_duration(phase, combo_step)
	cooldown = total_duration
	player.state_machine.request(PlayerStateMachine.State.MELEE, total_duration, true)


func _update_machete_sequence(delta: float) -> void:
	attack_phase_remaining -= delta
	if attack_phase_remaining > 0.0:
		return
	match attack_phase:
		AttackPhase.ANTICIPATION:
			attack_phase = AttackPhase.ACTIVE
			attack_phase_remaining = _phase_duration(attack_phase, combo_step)
			_activate_machete_hit()
		AttackPhase.ACTIVE:
			attack_phase = AttackPhase.FOLLOW_THROUGH
			attack_phase_remaining = _phase_duration(attack_phase, combo_step)
		AttackPhase.FOLLOW_THROUGH:
			attack_phase = AttackPhase.RECOVERY
			attack_phase_remaining = _phase_duration(attack_phase, combo_step)
		AttackPhase.RECOVERY:
			attack_phase = AttackPhase.NONE
			attack_phase_remaining = 0.0
			if buffered_melee_remaining > 0.0:
				buffered_melee_remaining = 0.0
				cooldown = 0.0
				_begin_machete_sequence()


func _activate_machete_hit() -> void:
	var hitstop := feedback_config.machete_hitstop(combo_step)
	player.spawn_melee(machete_data, combo_step, current_melee_variant, hitstop)
	player.play_machete_feedback(current_melee_variant, combo_step)
	if combo_step == 2:
		player.velocity.x = player.facing * 75.0
	elif combo_step == 3:
		player.velocity.x += player.facing * 28.0


func _phase_duration(phase: AttackPhase, step: int) -> float:
	match phase:
		AttackPhase.ANTICIPATION:
			return [0.035, 0.055, 0.09][step - 1]
		AttackPhase.ACTIVE:
			return [0.07, 0.075, 0.09][step - 1]
		AttackPhase.FOLLOW_THROUGH:
			return [0.055, 0.075, 0.11][step - 1]
		AttackPhase.RECOVERY:
			return [0.075, 0.09, 0.14][step - 1]
	return 0.0


func _cancel_melee_sequence() -> void:
	attack_phase = AttackPhase.NONE
	attack_phase_remaining = 0.0
	buffered_melee_remaining = 0.0


func _start_heal() -> void:
	if heal_charges <= 0 or player.health.current_health >= player.health.max_health:
		return
	healing = true
	heal_timer = player.config.heal_duration
	player.velocity.x = 0.0
	player.state_machine.request(PlayerStateMachine.State.HEAL, player.config.heal_duration, true)
	player.play_heal_channel_feedback()


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
		"attack_phase": AttackPhase.keys()[attack_phase],
		"combo_step": combo_step,
		"buffer": buffered_melee_remaining,
	}
