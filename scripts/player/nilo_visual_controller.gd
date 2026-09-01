class_name NiloVisualController
extends Sprite2D

const COHESION_TINT := Color("fff8ee")

const LOCOMOTION_PROFILES := [
	{"region": Rect2(0, 0, 246, 249), "height": 179.0, "bottom": 182.0, "center_x": 104.5},
	{"region": Rect2(246, 0, 246, 249), "height": 179.0, "bottom": 182.0, "center_x": 114.5},
	{"region": Rect2(492, 0, 246, 249), "height": 179.0, "bottom": 182.0, "center_x": 124.5},
	{"region": Rect2(738, 0, 247, 249), "height": 179.0, "bottom": 182.0, "center_x": 134.5},
	{"region": Rect2(0, 249, 246, 249), "height": 179.0, "bottom": 200.0},
	{"region": Rect2(246, 249, 246, 249), "height": 179.0, "bottom": 201.0},
	{"region": Rect2(492, 249, 246, 249), "height": 179.0, "bottom": 199.0},
	{"region": Rect2(738, 249, 247, 249), "height": 179.0, "bottom": 199.0},
	{"region": Rect2(0, 498, 246, 249), "height": 171.0, "bottom": 204.0},
	{"region": Rect2(246, 498, 246, 249), "height": 174.0, "bottom": 204.0},
	{"region": Rect2(492, 498, 246, 249), "height": 172.0, "bottom": 205.0},
	{"region": Rect2(738, 498, 247, 249), "height": 171.0, "bottom": 206.0},
	{"region": Rect2(0, 747, 246, 250), "height": 179.0, "bottom": 204.0},
	{"region": Rect2(246, 747, 246, 250), "height": 179.0, "bottom": 208.0},
	{"region": Rect2(492, 747, 246, 250), "height": 179.0, "bottom": 211.0},
	{"region": Rect2(738, 747, 247, 250), "height": 179.0, "bottom": 212.0},
]

const COMBAT_PROFILES := [
	{"region": Rect2(0, 0, 239, 248), "height": 179.0, "bottom": 184.0},
	{"region": Rect2(239, 0, 239, 248), "height": 179.0, "bottom": 183.0},
	{"region": Rect2(478, 0, 239, 248), "height": 178.0, "bottom": 184.0},
	{"region": Rect2(717, 0, 239, 248), "height": 180.0, "bottom": 184.0},
	{"region": Rect2(0, 248, 239, 248), "height": 177.0, "bottom": 194.0},
	{"region": Rect2(239, 248, 239, 248), "height": 177.0, "bottom": 194.0},
	{"region": Rect2(478, 248, 239, 248), "height": 177.0, "bottom": 194.0},
	{"region": Rect2(717, 248, 239, 248), "height": 177.0, "bottom": 194.0},
	{"region": Rect2(0, 496, 239, 248), "height": 176.0, "bottom": 206.0},
	{"region": Rect2(239, 496, 239, 248), "height": 159.0, "bottom": 202.0},
	{"region": Rect2(478, 496, 239, 248), "height": 157.0, "bottom": 207.0},
	{"region": Rect2(717, 496, 239, 248), "height": 172.0, "bottom": 203.0},
	{"region": Rect2(0, 744, 239, 248), "height": 165.0, "bottom": 232.0},
	{"region": Rect2(239, 744, 239, 248), "height": 189.0, "bottom": 238.0},
	{"region": Rect2(478, 744, 239, 248), "height": 216.0, "bottom": 242.0},
	{"region": Rect2(717, 744, 239, 248), "height": 181.0, "bottom": 235.0},
]

enum VisualTransition { NONE, RUN_START, RUN_STOP, TURN, TAKEOFF, LAND }

signal foot_contact(side: int)
signal transition_started(transition: VisualTransition)

@export var combat_texture: Texture2D
@export var target_visual_height := 40.0
@export var visual_baseline_offset := 12.0
@export var minimum_run_cycles_per_second := 1.65
@export var maximum_run_cycles_per_second := 3.05
@export var moving_speed_threshold := 5.0

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
var locomotion_frame := -1
var combat_frame := -1
var shooting_frame := -1
var normalized_visual_height := 0.0
var normalized_baseline_offset := 0.0

var _player: NiloPlayer
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE
var _base_rotation := 0.0
var _life_elapsed := 0.0
var _state_elapsed := 0.0
var _last_state := -1
var _last_frame := -1
var _previous_grounded := false
var _previous_moving := false
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
var _current_sheet := -1
var _current_useful_height := 285.0
var _current_useful_bottom := 297.0
var _current_useful_center_x := 0.0
var _current_region_height := 309.0
var _current_region_width := 309.0
var _canonical_baseline_offset := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_player = get_parent() as NiloPlayer
	_base_position = position
	_base_scale = scale
	_base_rotation = rotation
	_base_texture = texture
	_canonical_baseline_offset = visual_baseline_offset
	region_enabled = true
	region_filter_clip_enabled = true
	_previous_grounded = _player.is_on_floor()
	_previous_facing = _player.facing
	_last_running_facing = _player.facing
	_apply_locomotion_frame(0)


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
	_previous_moving = moving_active
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
	if grounded and moving_active and not _previous_moving:
		run_phase = 0.0
		_start_transition(VisualTransition.RUN_START, 0.085)
		_spawn_foot_dust(0, 0.55)
	elif grounded and running and not _previous_running:
		if signf(_player.facing) != signf(_last_running_facing):
			_start_transition(VisualTransition.TURN, 0.105)
			_spawn_foot_dust(0, 0.9)
	elif grounded and not moving_active and _previous_moving:
		_start_transition(VisualTransition.RUN_STOP, 0.105)
		_spawn_foot_dust(0, 0.72)
	if grounded and moving_active and signf(_player.facing) != signf(_previous_facing):
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
		PlayerStateMachine.State.IDLE:
			return _idle_frame()
		PlayerStateMachine.State.RUN:
			var row_start := 8 if running_active else 4
			return row_start + int(floor(run_phase * 4.0)) % 4
		PlayerStateMachine.State.CROUCH:
			return 0
		PlayerStateMachine.State.JUMP:
			return 5
		PlayerStateMachine.State.FALL:
			return 6 if air_phase == &"apex" else 7
		PlayerStateMachine.State.PISTOL, PlayerStateMachine.State.RIFLE, PlayerStateMachine.State.MELEE, PlayerStateMachine.State.SPECIAL:
			return 0
		PlayerStateMachine.State.HEAL:
			return 2
		PlayerStateMachine.State.HURT:
			return 3
		PlayerStateMachine.State.DEAD:
			return 12 + mini(3, int(floor(_state_elapsed / 0.16)))
		_:
			return _idle_frame()


func _idle_frame() -> int:
	# A piscada aparece brevemente a cada 4,8 s. Nos demais instantes,
	# as três poses abertas formam uma respiração lenta e ancorada.
	var idle_cycle := fmod(_life_elapsed, 4.8)
	if idle_cycle >= 4.12 and idle_cycle < 4.27:
		return 1
	var breathing_sequence := [0, 2, 3, 2]
	return breathing_sequence[int(floor(fmod(_life_elapsed, 2.4) / 0.6)) % breathing_sequence.size()]


func _apply_visual_transform() -> void:
	position = _base_position
	var normalized_scale := target_visual_height / maxf(_current_useful_height, 1.0)
	scale = Vector2(normalized_scale, normalized_scale)
	# As poses paradas vieram deslocadas 10 px para a direita a cada célula.
	# Compensar o centro útil mantém o corpo sobre o mesmo ponto do mundo.
	var center_delta := _current_useful_center_x - _current_region_width * 0.5
	position.x -= center_delta * normalized_scale * _player.facing
	position.y = _canonical_baseline_offset - (_current_useful_bottom - _current_region_height * 0.5) * normalized_scale
	rotation = _base_rotation
	self_modulate = COHESION_TINT
	flip_h = _player.facing < 0.0
	normalized_visual_height = _current_useful_height * absf(scale.y)
	normalized_baseline_offset = position.y + (_current_useful_bottom - _current_region_height * 0.5) * absf(scale.y)

	match _player.state_machine.current_state:
		PlayerStateMachine.State.IDLE:
			# Respiração perceptível, mas com os pés presos à baseline.
			var breath := (sin(_life_elapsed * TAU / 2.8) + 1.0) * 0.5
			var scale_before_breath := scale
			scale.x *= 1.0 + breath * 0.008
			scale.y *= 1.0 + breath * 0.012
			var bottom_from_center := _current_useful_bottom - _current_region_height * 0.5
			position.y -= bottom_from_center * (scale.y - scale_before_breath.y)
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
		PlayerStateMachine.State.PISTOL:
			_apply_shoot_transform(false)
		PlayerStateMachine.State.RIFLE:
			_apply_shoot_transform(true)
		PlayerStateMachine.State.MELEE:
			position.x += _player.facing * 1.5
		PlayerStateMachine.State.SPECIAL:
			var special_pulse := sin(clampf(_state_elapsed / 0.64, 0.0, 1.0) * PI)
			scale *= Vector2(1.0 + special_pulse * 0.045, 1.0 - special_pulse * 0.025)
			position.x += _player.facing * special_pulse * 2.0
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
		self_modulate = Color(1.0, 0.72, 0.62, 1.0) if SettingsManager.reduce_flashes else Color(1.0, 0.52, 0.42, 1.0)
	elif _player.invulnerability_remaining > 0.0:
		self_modulate.a = 0.82 if SettingsManager.reduce_flashes else (0.72 if int(_player.invulnerability_remaining * 16.0) % 2 == 0 else 1.0)


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


func _apply_shoot_transform(is_rifle: bool) -> void:
	var anticipation := 0.08 if is_rifle else 0.06
	var active_end := 0.19 if is_rifle else 0.14
	var total := 0.38 if is_rifle else 0.24
	var strength := 0.8 if is_rifle else 0.45
	if _state_elapsed < anticipation:
		var brace := smoothstep(0.0, anticipation, _state_elapsed)
		position.x += _player.facing * brace * (0.9 if is_rifle else 0.55)
		scale *= Vector2(1.0 + brace * 0.012 * strength, 1.0 - brace * 0.018 * strength)
		rotation += _player.facing * brace * 0.012
	elif _state_elapsed < active_end:
		var fire_progress := (_state_elapsed - anticipation) / maxf(active_end - anticipation, 0.001)
		var recoil_pulse := sin(fire_progress * PI)
		position.x -= _player.facing * recoil_pulse * (1.15 if is_rifle else 0.7)
		rotation -= _player.facing * recoil_pulse * (0.032 if is_rifle else 0.018)
	else:
		var recovery := clampf((_state_elapsed - active_end) / maxf(total - active_end, 0.001), 0.0, 1.0)
		var settle := 1.0 - recovery
		position.x -= _player.facing * settle * (0.48 if is_rifle else 0.25)
		rotation -= _player.facing * settle * (0.014 if is_rifle else 0.008)


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
	running_active = moving_active and _player.movement.running_active


func _apply_locomotion_frame(frame_index: int) -> void:
	locomotion_frame = frame_index
	combat_frame = -1
	shooting_frame = -1
	_apply_profile(_base_texture, LOCOMOTION_PROFILES[clampi(frame_index, 0, LOCOMOTION_PROFILES.size() - 1)], frame_index, 0)


func _apply_current_frame() -> void:
	var state := _player.state_machine.current_state
	if combat_texture != null and (state == PlayerStateMachine.State.PISTOL or state == PlayerStateMachine.State.RIFLE):
		_apply_shooting_frame(state == PlayerStateMachine.State.RIFLE)
	elif combat_texture != null and state == PlayerStateMachine.State.MELEE:
		_apply_melee_frame()
	elif combat_texture != null and state == PlayerStateMachine.State.SPECIAL:
		_apply_special_frame()
	else:
		_apply_locomotion_frame(_select_frame())


func _apply_shooting_frame(is_rifle: bool) -> void:
	locomotion_frame = -1
	var frame_index := _shooting_frame_at_time(is_rifle)
	shooting_frame = frame_index
	var profile_index := frame_index + (4 if is_rifle else 0)
	combat_frame = profile_index
	_apply_profile(combat_texture, COMBAT_PROFILES[profile_index], profile_index, 1)


func _apply_melee_frame() -> void:
	locomotion_frame = -1
	shooting_frame = -1
	var profile_index := 8
	match _player.combat.attack_phase:
		PlayerCombat.AttackPhase.ANTICIPATION:
			profile_index = 8
		PlayerCombat.AttackPhase.ACTIVE:
			if _player.combat.current_melee_variant == &"machete_down" or _player.combat.combo_step == 2:
				profile_index = 10
			else:
				profile_index = 9
		PlayerCombat.AttackPhase.FOLLOW_THROUGH:
			profile_index = 10
		PlayerCombat.AttackPhase.RECOVERY:
			profile_index = 11
		_:
			profile_index = 11
	combat_frame = profile_index
	_apply_profile(combat_texture, COMBAT_PROFILES[profile_index], profile_index, 1)


func _apply_special_frame() -> void:
	locomotion_frame = -1
	shooting_frame = -1
	var frame_index := 0
	if _state_elapsed >= 0.46:
		frame_index = 3
	elif _state_elapsed >= 0.28:
		frame_index = 2
	elif _state_elapsed >= 0.12:
		frame_index = 1
	var profile_index := 12 + frame_index
	combat_frame = profile_index
	_apply_profile(combat_texture, COMBAT_PROFILES[profile_index], profile_index, 1)


func _apply_profile(next_texture: Texture2D, profile: Dictionary, frame_index: int, sheet_id: int) -> void:
	if next_texture == null:
		return
	var sheet_changed := texture != next_texture or _current_sheet != sheet_id
	if not sheet_changed and frame_index == _last_frame:
		return
	texture = next_texture
	_current_sheet = sheet_id
	_last_frame = frame_index
	region_rect = profile["region"]
	_current_useful_height = float(profile["height"])
	_current_useful_bottom = float(profile["bottom"])
	_current_useful_center_x = float(profile.get("center_x", region_rect.size.x * 0.5))
	_current_region_height = region_rect.size.y
	_current_region_width = region_rect.size.x


func _shooting_frame_at_time(is_rifle: bool) -> int:
	if is_rifle:
		if _state_elapsed < 0.06:
			return 0
		if _state_elapsed < 0.18:
			return 1
		if _state_elapsed < 0.28:
			return 2
		return 3
	if _state_elapsed < 0.045:
		return 0
	if _state_elapsed < 0.12:
		return 1
	if _state_elapsed < 0.18:
		return 2
	return 3


func get_profile_sets_for_validation() -> Array[Dictionary]:
	return [
		{"texture": _base_texture, "profiles": LOCOMOTION_PROFILES},
		{"texture": combat_texture, "profiles": COMBAT_PROFILES},
	]
