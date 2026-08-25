class_name NiloVisualController
extends Sprite2D

enum VisualTransition { NONE, RUN_START, RUN_STOP, TURN, TAKEOFF, LAND }

signal foot_contact(side: int)
signal transition_started(transition: VisualTransition)

@export_range(1, 12) var columns := 4
@export_range(1, 8) var rows := 4
@export var shooting_texture: Texture2D
@export_range(2, 12) var shooting_columns := 6
@export var shooting_row_height := 380.0
@export var revolver_row_y := 30.0
@export var shotgun_row_y := 440.0
@export_range(0.05, 1.0) var shooting_scale_multiplier := 0.105
@export var shooting_vertical_offset := 11.0
@export var minimum_run_cycles_per_second := 1.65
@export var maximum_run_cycles_per_second := 3.05
@export var moving_speed_threshold := 5.0
@export_range(0.1, 0.5) var running_enter_ratio := 0.22
@export_range(0.05, 0.4) var running_exit_ratio := 0.16

var run_phase := 0.0
var smoothed_speed_ratio := 0.0
var visual_transition := VisualTransition.NONE
var foot_contact_count := 0
var air_phase: StringName = &"grounded"
var landing_intensity := 0.0
var bob_offset := 0.0
var run_contact_amount := 1.0
var moving_active := false
var running_active := false
var shooting_frame := -1

var _player: NiloPlayer
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE
var _base_rotation := 0.0
var _life_elapsed := 0.0
var _state_elapsed := 0.0
var _last_state := -1
var _last_frame := -1
var _previous_grounded := false
var _previous_running := false
var _previous_facing := 1.0
var _last_running_facing := 1.0
var _transition_elapsed := 0.0
var _transition_duration := 0.0
var _recoil_strength := 0.0
var _recoil_remaining := 0.0
var _recoil_duration := 0.0
var _hurt_flash_remaining := 0.0
var _base_texture: Texture2D
var _using_shooting_sheet := false


func _ready() -> void:
	_player = get_parent() as NiloPlayer
	_base_position = position
	_base_scale = scale
	_base_rotation = rotation
	_base_texture = texture
	region_enabled = true
	region_filter_clip_enabled = true
	_previous_grounded = _player.is_on_floor()
	_previous_facing = _player.facing
	_last_running_facing = _player.facing
	_apply_frame(0)


func _process(delta: float) -> void:
	if _player == null or texture == null:
		return
	_life_elapsed += delta
	_hurt_flash_remaining = maxf(0.0, _hurt_flash_remaining - delta)
	_update_state_clock(delta)
	_update_motion_flags()
	_update_transitions(delta)
	_update_run_phase(delta)
	_update_air_phase()
	_apply_current_frame()
	_apply_visual_transform()
	_previous_grounded = _player.is_on_floor()
	_previous_running = _is_running()
	_previous_facing = _player.facing


func notify_landed(vertical_speed: float) -> void:
	landing_intensity = smoothstep(105.0, 470.0, absf(vertical_speed))
	if landing_intensity < 0.08:
		return
	_start_transition(VisualTransition.LAND, lerpf(0.065, 0.12, landing_intensity))


func notify_weapon_recoil(amount: float, duration: float) -> void:
	_recoil_strength = maxf(_recoil_strength, amount)
	_recoil_duration = maxf(duration, 0.01)
	_recoil_remaining = _recoil_duration


func notify_hurt() -> void:
	_hurt_flash_remaining = 0.095


func _update_state_clock(delta: float) -> void:
	var current := int(_player.state_machine.current_state)
	if current != _last_state:
		_last_state = current
		_state_elapsed = 0.0
		_last_frame = -1
	else:
		_state_elapsed += delta


func _update_transitions(delta: float) -> void:
	var grounded := _player.is_on_floor()
	var running := _is_running()
	if grounded and running and not _previous_running:
		run_phase = 0.0
		if signf(_player.facing) != signf(_last_running_facing):
			_start_transition(VisualTransition.TURN, 0.105)
			_spawn_foot_dust(0, 0.9)
		else:
			_start_transition(VisualTransition.RUN_START, 0.085)
			_spawn_foot_dust(0, 0.55)
	elif grounded and not running and _previous_running:
		_start_transition(VisualTransition.RUN_STOP, 0.105)
		_spawn_foot_dust(0, 0.72)
	if grounded and running and signf(_player.facing) != signf(_previous_facing):
		_start_transition(VisualTransition.TURN, 0.105)
		_spawn_foot_dust(0, 0.9)
	if running:
		_last_running_facing = _player.facing
	if _previous_grounded and not grounded and _player.velocity.y < 0.0:
		_start_transition(VisualTransition.TAKEOFF, 0.08)
	if visual_transition != VisualTransition.NONE:
		_transition_elapsed += delta
		if _transition_elapsed >= _transition_duration:
			visual_transition = VisualTransition.NONE
			_transition_elapsed = 0.0


func _update_run_phase(delta: float) -> void:
	var raw_ratio := clampf(absf(_player.velocity.x) / maxf(_player.config.move_speed, 1.0), 0.0, 1.0)
	var eased_ratio := smoothstep(0.0, 1.0, raw_ratio)
	smoothed_speed_ratio = move_toward(smoothed_speed_ratio, eased_ratio, delta * 4.5)
	if not _player.is_on_floor() or not moving_active:
		bob_offset = 0.0
		run_contact_amount = 1.0
		return
	var previous_phase := run_phase
	var cycles_per_second := lerpf(minimum_run_cycles_per_second, maximum_run_cycles_per_second, smoothed_speed_ratio)
	run_phase = fmod(run_phase + delta * cycles_per_second, 1.0)
	# Contatos em 0 e 0,5; passagens em 0,25 e 0,75. O corpo sobe
	# discretamente na passagem e volta à baseline quando o pé planta.
	run_contact_amount = absf(cos(run_phase * TAU))
	var pass_amount := 1.0 - run_contact_amount
	bob_offset = -pass_amount * lerpf(0.08, 0.46, smoothed_speed_ratio)
	if _is_running():
		if _phase_crossed(previous_phase, run_phase, 0.0):
			_on_foot_contact(-1)
		if _phase_crossed(previous_phase, run_phase, 0.5):
			_on_foot_contact(1)


func _update_air_phase() -> void:
	if _player.is_on_floor():
		air_phase = &"land" if visual_transition == VisualTransition.LAND else &"grounded"
	elif _player.velocity.y < -45.0:
		air_phase = &"takeoff" if visual_transition == VisualTransition.TAKEOFF else &"ascent"
	elif absf(_player.velocity.y) <= 45.0:
		air_phase = &"apex"
	elif Input.is_action_pressed("move_down") and _player.velocity.y > 150.0:
		air_phase = &"fast_fall"
	else:
		air_phase = &"fall"


func _select_frame() -> int:
	match _player.state_machine.current_state:
		PlayerStateMachine.State.RUN:
			return 4 + int(floor(run_phase * 4.0)) % 4 if running_active else int(floor(_life_elapsed / 0.72)) % 2
		PlayerStateMachine.State.CROUCH:
			return 0
		PlayerStateMachine.State.JUMP:
			return 8
		PlayerStateMachine.State.FALL:
			return 8 if air_phase == &"apex" else 9
		PlayerStateMachine.State.SHOOT, PlayerStateMachine.State.SHOTGUN:
			return 2
		PlayerStateMachine.State.MELEE:
			return 11
		PlayerStateMachine.State.HEAL:
			return 13
		PlayerStateMachine.State.HURT:
			return 12
		PlayerStateMachine.State.DEAD:
			return 15
		_:
			return int(floor(_life_elapsed / 0.72)) % 2


func _apply_visual_transform() -> void:
	position = _base_position
	scale = _base_scale
	rotation = _base_rotation
	self_modulate = Color.WHITE
	flip_h = _player.facing < 0.0
	if _using_shooting_sheet:
		scale *= shooting_scale_multiplier
		position.y += shooting_vertical_offset

	match _player.state_machine.current_state:
		PlayerStateMachine.State.IDLE:
			# Respiração só altera volume; os pés permanecem ancorados.
			var breath := (sin(_life_elapsed * 2.0) + 1.0) * 0.5
			scale.x *= 1.0 + breath * 0.008
			scale.y *= 1.0 - breath * 0.006
			position.y += _base_scale.y * 64.0 * breath * 0.003
		PlayerStateMachine.State.RUN:
			if running_active:
				var compression := run_contact_amount * lerpf(0.002, 0.012, smoothed_speed_ratio)
				scale.x *= 1.0 + compression * 0.55
				scale.y *= 1.0 - compression
				position.y += bob_offset + _base_scale.y * 32.0 * compression
				rotation += _player.facing * lerpf(0.008, 0.026, smoothed_speed_ratio)
		PlayerStateMachine.State.CROUCH:
			scale *= Vector2(1.04, 0.92)
			position.y += 2.0
		PlayerStateMachine.State.JUMP, PlayerStateMachine.State.FALL:
			_apply_air_transform()
		PlayerStateMachine.State.SHOOT:
			_apply_shoot_transform(false)
		PlayerStateMachine.State.SHOTGUN:
			_apply_shoot_transform(true)
		PlayerStateMachine.State.MELEE:
			position.x += _player.facing * 1.5
		PlayerStateMachine.State.HEAL:
			var pulse := (sin(_life_elapsed * 9.0) + 1.0) * 0.5
			scale *= Vector2.ONE * (1.0 + pulse * 0.025)
			self_modulate = Color(0.72, 1.0, 0.84, 1.0)
		PlayerStateMachine.State.HURT:
			position.x += sin(_state_elapsed * 75.0) * 1.0
			scale *= Vector2(1.06, 0.94)
		_:
			pass

	_apply_transition_transform()
	_apply_recoil()
	if _hurt_flash_remaining > 0.0:
		self_modulate = Color(1.0, 0.52, 0.42, 1.0)
	elif _player.invulnerability_remaining > 0.0:
		self_modulate.a = 0.72 if int(_player.invulnerability_remaining * 16.0) % 2 == 0 else 1.0


func _apply_air_transform() -> void:
	match air_phase:
		&"takeoff", &"ascent":
			scale *= Vector2(0.95, 1.055)
			rotation += _player.facing * 0.025
		&"apex":
			scale *= Vector2(1.01, 0.99)
		&"fall":
			var fall_ratio := clampf(_player.velocity.y / 420.0, 0.0, 1.0)
			scale *= Vector2(1.0 + fall_ratio * 0.055, 1.0 - fall_ratio * 0.045)
		&"fast_fall":
			scale *= Vector2(0.94, 1.075)
			rotation += _player.facing * 0.045


func _apply_shoot_transform(is_shotgun: bool) -> void:
	var anticipation := 0.08 if is_shotgun else 0.06
	var active_end := 0.18 if is_shotgun else 0.14
	var total := 0.36 if is_shotgun else 0.24
	var strength := 1.0 if is_shotgun else 0.45
	if _state_elapsed < anticipation:
		var brace := smoothstep(0.0, anticipation, _state_elapsed)
		position.x += _player.facing * brace * (1.1 if is_shotgun else 0.55)
		scale *= Vector2(1.0 + brace * 0.012 * strength, 1.0 - brace * 0.018 * strength)
		rotation += _player.facing * brace * 0.012
	elif _state_elapsed < active_end:
		var fire_progress := (_state_elapsed - anticipation) / maxf(active_end - anticipation, 0.001)
		var recoil_pulse := sin(fire_progress * PI)
		position.x -= _player.facing * recoil_pulse * (1.7 if is_shotgun else 0.7)
		rotation -= _player.facing * recoil_pulse * (0.045 if is_shotgun else 0.018)
	else:
		var recovery := clampf((_state_elapsed - active_end) / maxf(total - active_end, 0.001), 0.0, 1.0)
		var settle := 1.0 - recovery
		position.x -= _player.facing * settle * (0.65 if is_shotgun else 0.25)
		rotation -= _player.facing * settle * (0.018 if is_shotgun else 0.008)


func _apply_transition_transform() -> void:
	if visual_transition == VisualTransition.NONE:
		return
	var progress := clampf(_transition_elapsed / maxf(_transition_duration, 0.001), 0.0, 1.0)
	var pulse := sin(progress * PI)
	match visual_transition:
		VisualTransition.RUN_START:
			scale *= Vector2(1.0 + pulse * 0.045, 1.0 - pulse * 0.055)
			rotation += _player.facing * pulse * 0.075
		VisualTransition.RUN_STOP:
			scale *= Vector2(1.0 + pulse * 0.035, 1.0 - pulse * 0.025)
			position.x -= _player.facing * pulse * 2.0
			rotation -= _player.facing * pulse * 0.075
		VisualTransition.TURN:
			scale.x *= 1.0 - pulse * 0.08
			position.x -= _player.facing * pulse * 1.5
			rotation -= _player.facing * pulse * 0.1
		VisualTransition.TAKEOFF:
			scale *= Vector2(1.0 - pulse * 0.07, 1.0 + pulse * 0.08)
		VisualTransition.LAND:
			scale *= Vector2(1.0 + pulse * 0.12 * landing_intensity, 1.0 - pulse * 0.13 * landing_intensity)
			position.y += pulse * 2.2 * landing_intensity


func _apply_recoil() -> void:
	_recoil_remaining = maxf(0.0, _recoil_remaining - get_process_delta_time())
	if _recoil_remaining <= 0.0:
		_recoil_strength = 0.0
		return
	var ratio := _recoil_remaining / maxf(_recoil_duration, 0.01)
	position.x -= _player.facing * _recoil_strength * ratio
	rotation -= _player.facing * _recoil_strength * 0.012 * ratio


func _start_transition(next: VisualTransition, duration: float) -> void:
	visual_transition = next
	_transition_elapsed = 0.0
	_transition_duration = duration
	transition_started.emit(next)


func _on_foot_contact(side: int) -> void:
	foot_contact_count += 1
	foot_contact.emit(side)
	_spawn_foot_dust(side, lerpf(0.45, 0.9, smoothed_speed_ratio))


func _spawn_foot_dust(side: int, strength: float) -> void:
	if not _player.is_on_floor():
		return
	var offset := Vector2(float(side) * 3.0 - _player.facing * 2.0, 11.0)
	GameFeelFX.spawn(get_tree().current_scene, _player.global_position + offset, GameFeelFX.Kind.RUN_DUST, -_player.facing, strength)


func _phase_crossed(previous: float, current: float, target: float) -> bool:
	if current >= previous:
		return target > previous and target <= current
	return target > previous or target <= current


func _is_running() -> bool:
	return running_active


func _update_motion_flags() -> void:
	var grounded := _player.is_on_floor()
	var speed := absf(_player.velocity.x)
	moving_active = grounded and speed > moving_speed_threshold
	var speed_ratio := speed / maxf(_player.config.move_speed, 1.0)
	if running_active:
		running_active = grounded and speed_ratio > running_exit_ratio
	else:
		running_active = grounded and speed_ratio > running_enter_ratio


func _apply_frame(frame_index: int) -> void:
	if texture != _base_texture:
		texture = _base_texture
		_last_frame = -1
	_using_shooting_sheet = false
	shooting_frame = -1
	if frame_index == _last_frame or texture == null:
		return
	_last_frame = frame_index
	var cell_size := Vector2(float(texture.get_width()) / float(maxi(columns, 1)), float(texture.get_height()) / float(maxi(rows, 1)))
	region_rect = Rect2(Vector2(frame_index % columns, frame_index / columns) * cell_size, cell_size)


func _apply_current_frame() -> void:
	var state := _player.state_machine.current_state
	if shooting_texture != null and (state == PlayerStateMachine.State.SHOOT or state == PlayerStateMachine.State.SHOTGUN):
		_apply_shooting_frame(state == PlayerStateMachine.State.SHOTGUN)
	else:
		_apply_frame(_select_frame())


func _apply_shooting_frame(is_shotgun: bool) -> void:
	var frame_index := _shooting_frame_at_time(is_shotgun)
	var sheet_changed := texture != shooting_texture
	if sheet_changed:
		texture = shooting_texture
		_last_frame = -1
	_using_shooting_sheet = true
	shooting_frame = frame_index
	if frame_index == _last_frame and not sheet_changed:
		return
	_last_frame = frame_index
	var cell_width := float(shooting_texture.get_width()) / float(maxi(shooting_columns, 1))
	var row_y := shotgun_row_y if is_shotgun else revolver_row_y
	region_rect = Rect2(frame_index * cell_width, row_y, cell_width, shooting_row_height)


func _shooting_frame_at_time(is_shotgun: bool) -> int:
	if is_shotgun:
		if _state_elapsed < 0.025:
			return 0
		if _state_elapsed < 0.05:
			return 1
		if _state_elapsed < 0.08:
			return 2
		if _state_elapsed < 0.16:
			return 3
		if _state_elapsed < 0.25:
			return 4
		return 5
	if _state_elapsed < 0.02:
		return 0
	if _state_elapsed < 0.04:
		return 1
	if _state_elapsed < 0.06:
		return 2
	if _state_elapsed < 0.12:
		return 3
	if _state_elapsed < 0.18:
		return 4
	return 5
