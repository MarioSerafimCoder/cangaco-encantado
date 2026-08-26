class_name MvpSpriteAnimator
extends Sprite2D

const COHESION_TINT := Color("fff8ee")

enum ActorKind { NILO, SAQUEADOR, PISTOLEIRO, ZE_TRANCA }

const ENEMY_FRAME_PROFILES := {
	ActorKind.SAQUEADOR: {
		0: {"region": Rect2(111, 58, 257, 367), "content_bottom": 412.0},
		1: {"region": Rect2(455, 83, 240, 342), "content_bottom": 412.0},
		2: {"region": Rect2(729, 130, 348, 294), "content_bottom": 411.0},
		4: {"region": Rect2(136, 480, 345, 294), "content_bottom": 761.0},
		6: {"region": Rect2(813, 463, 265, 311), "content_bottom": 761.0},
		11: {"region": Rect2(343, 824, 529, 232), "content_bottom": 1043.0},
	},
	ActorKind.PISTOLEIRO: {
		0: {"region": Rect2(80, 102, 186, 231), "content_bottom": 320.0},
		1: {"region": Rect2(297, 115, 170, 217), "content_bottom": 319.0},
		2: {"region": Rect2(501, 115, 166, 215), "content_bottom": 317.0},
		3: {"region": Rect2(108, 823, 162, 202), "content_bottom": 1012.0},
		4: {"region": Rect2(915, 130, 210, 205), "content_bottom": 322.0},
		6: {"region": Rect2(888, 903, 307, 129), "content_bottom": 1019.0},
	},
	ActorKind.ZE_TRANCA: {
		0: {"region": Rect2(76, 145, 291, 340), "content_bottom": 472.0},
		1: {"region": Rect2(391, 163, 310, 322), "content_bottom": 472.0},
		2: {"region": Rect2(738, 176, 430, 309), "content_bottom": 472.0},
		3: {"region": Rect2(1003, 562, 245, 278), "content_bottom": 827.0},
		4: {"region": Rect2(1232, 705, 303, 161), "content_bottom": 853.0},
	},
}

@export var actor_kind := ActorKind.NILO
@export_range(1, 12) var columns := 4
@export_range(1, 8) var rows := 3
@export var frame_interval := 0.13
@export var visual_baseline_offset := 0.0

var _state_elapsed := 0.0
var _life_elapsed := 0.0
var _last_state := -1
var _last_frame := -1
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE
var _frame_position_adjustment_y := 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	region_enabled = true
	region_filter_clip_enabled = true
	_base_position = position
	_base_scale = scale
	_apply_frame(0)


func _process(delta: float) -> void:
	if texture == null:
		return
	_life_elapsed += delta
	var state_key := _actor_state_key()
	if state_key != _last_state:
		_last_state = state_key
		_state_elapsed = 0.0
		_last_frame = -1
	else:
		_state_elapsed += delta
	_apply_frame(_select_frame())
	_update_facing_feedback_and_motion()


func _actor_state_key() -> int:
	if actor_kind == ActorKind.NILO:
		var nilo := get_parent() as NiloPlayer
		return int(nilo.state_machine.current_state) if nilo != null else -1
	var enemy := get_parent() as EnemyBase
	return int(enemy.state_machine.current) if enemy != null else -1


func _select_frame() -> int:
	if actor_kind == ActorKind.NILO:
		return _select_nilo_frame()
	return _select_enemy_frame()


func _select_nilo_frame() -> int:
	var nilo := get_parent() as NiloPlayer
	if nilo == null:
		return 0
	match nilo.state_machine.current_state:
		PlayerStateMachine.State.RUN:
			var speed_ratio := clampf(absf(nilo.velocity.x) / maxf(nilo.config.move_speed, 1.0), 0.0, 1.0)
			var run_interval := lerpf(0.16, 0.085, speed_ratio)
			return _cycle(4, 4, run_interval)
		PlayerStateMachine.State.CROUCH:
			return 0
		PlayerStateMachine.State.JUMP:
			return 8
		PlayerStateMachine.State.FALL:
			return 9
		PlayerStateMachine.State.PISTOL, PlayerStateMachine.State.RIFLE:
			return 10
		PlayerStateMachine.State.MELEE:
			return 11
		PlayerStateMachine.State.SPECIAL:
			return 12
		PlayerStateMachine.State.HEAL:
			return 13
		PlayerStateMachine.State.HURT:
			return 12
		PlayerStateMachine.State.DEAD:
			return 15
		_:
			return _cycle(0, 2, 0.62)


func _select_enemy_frame() -> int:
	var enemy := get_parent() as EnemyBase
	if enemy == null:
		return 0
	match actor_kind:
		ActorKind.SAQUEADOR:
			match enemy.state_machine.current:
				EnemyStateMachine.State.PATROL, EnemyStateMachine.State.CHASE, EnemyStateMachine.State.RETURN, EnemyStateMachine.State.RETREAT:
					return _cycle(1, 2, _enemy_move_interval(enemy))
				EnemyStateMachine.State.ATTACK:
					match enemy.attack_phase:
						EnemyBase.AttackPhase.ANTICIPATION:
							return 2
						EnemyBase.AttackPhase.ACTIVE:
							return 4
						_:
							return 0
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 6
				EnemyStateMachine.State.DEAD:
					return 11
				_:
					return 0
		ActorKind.PISTOLEIRO:
			match enemy.state_machine.current:
				EnemyStateMachine.State.PATROL, EnemyStateMachine.State.CHASE, EnemyStateMachine.State.RETURN, EnemyStateMachine.State.RETREAT:
					return _cycle(1, 2, _enemy_move_interval(enemy))
				EnemyStateMachine.State.ATTACK:
					return 4 if enemy.attack_phase != EnemyBase.AttackPhase.RECOVERY else 0
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 3
				EnemyStateMachine.State.DEAD:
					return 6
				_:
					return 0
		ActorKind.ZE_TRANCA:
			match enemy.state_machine.current:
				EnemyStateMachine.State.PATROL, EnemyStateMachine.State.CHASE, EnemyStateMachine.State.RETURN, EnemyStateMachine.State.RETREAT:
					return 1
				EnemyStateMachine.State.ATTACK:
					return 2 if enemy.attack_phase == EnemyBase.AttackPhase.ACTIVE else 1
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 3
				EnemyStateMachine.State.DEAD:
					return 4
				_:
					return 0
	return 0


func _enemy_move_interval(enemy: EnemyBase) -> float:
	match enemy.state_machine.current:
		EnemyStateMachine.State.PATROL:
			return frame_interval * 1.35
		EnemyStateMachine.State.RETREAT:
			return frame_interval * 0.72
		EnemyStateMachine.State.RETURN:
			return frame_interval * 1.1
	return frame_interval


func _cycle(first_frame: int, frame_count: int, interval: float) -> int:
	return first_frame + int(floor(_state_elapsed / maxf(interval, 0.01))) % maxi(frame_count, 1)


func _apply_frame(frame_index: int) -> void:
	if texture == null or frame_index == _last_frame:
		return
	_last_frame = frame_index
	var profile := _frame_profile(frame_index)
	if not profile.is_empty():
		var frame_region: Rect2 = profile["region"]
		region_rect = frame_region
		var content_bottom := float(profile["content_bottom"])
		var bottom_from_center := content_bottom - frame_region.position.y - frame_region.size.y * 0.5
		var final_position_y := visual_baseline_offset - bottom_from_center * absf(_base_scale.y)
		_frame_position_adjustment_y = final_position_y - _base_position.y
		return
	_frame_position_adjustment_y = 0.0
	var safe_columns := maxi(1, columns)
	var safe_rows := maxi(1, rows)
	var cell_size := Vector2(
		float(texture.get_width()) / float(safe_columns),
		float(texture.get_height()) / float(safe_rows)
	)
	var column := frame_index % safe_columns
	var row := frame_index / safe_columns
	region_rect = Rect2(Vector2(column, row) * cell_size, cell_size)


func _frame_profile(frame_index: int) -> Dictionary:
	var actor_profiles: Dictionary = ENEMY_FRAME_PROFILES.get(actor_kind, {})
	return actor_profiles.get(frame_index, {})


func get_profile_regions_for_validation() -> Array[Rect2]:
	var result: Array[Rect2] = []
	var actor_profiles: Dictionary = ENEMY_FRAME_PROFILES.get(actor_kind, {})
	for frame_index in actor_profiles:
		result.append(actor_profiles[frame_index]["region"])
	return result


func _update_facing_feedback_and_motion() -> void:
	var actor := get_parent()
	var actor_facing = actor.get("facing")
	if actor_facing != null:
		flip_h = float(actor_facing) < 0.0
	position = _base_position
	position.y += _frame_position_adjustment_y
	scale = _base_scale
	rotation = 0.0
	self_modulate = COHESION_TINT
	if actor is NiloPlayer:
		_update_nilo_feedback(actor as NiloPlayer)
	elif actor is EnemyBase:
		var enemy := actor as EnemyBase
		if enemy.state_machine.current == EnemyStateMachine.State.DEAD:
			var death_progress := clampf(_state_elapsed / maxf(enemy.data.death_duration, 0.1), 0.0, 1.0)
			position.x -= enemy.facing * death_progress * 4.0
			position.y += smoothstep(0.0, 1.0, death_progress) * 4.0
			rotation = enemy.facing * death_progress * 0.16
			scale *= Vector2(1.0 + death_progress * 0.08, 1.0 - death_progress * 0.18)
			self_modulate = Color(0.72, 0.56, 0.5, 1.0 - smoothstep(0.62, 1.0, death_progress))
		elif enemy.attack_phase == EnemyBase.AttackPhase.ANTICIPATION:
			var warning_progress := clampf(1.0 - enemy.attack_phase_remaining / maxf(enemy.data.attack_windup, 0.05), 0.0, 1.0)
			var warning_pulse := 0.75 + absf(sin(warning_progress * PI * 4.0)) * 0.25
			self_modulate = Color(1.0, warning_pulse, 0.62, 1.0)
			scale *= Vector2(1.0 + warning_progress * 0.025, 1.0 - warning_progress * 0.025)
		elif enemy.attack_phase == EnemyBase.AttackPhase.ACTIVE:
			self_modulate = Color(1.0, 0.92, 0.68, 1.0)
		elif enemy.state_machine.current == EnemyStateMachine.State.STAGGER:
			position.x += sin(_state_elapsed * 24.0) * 0.65
			rotation = sin(_state_elapsed * 13.0) * 0.035
			self_modulate = Color("f4d35e")
		elif enemy.state_machine.current == EnemyStateMachine.State.HURT:
			var hurt_progress := clampf(_state_elapsed / maxf(enemy.data.hurt_duration, 0.05), 0.0, 1.0)
			var recoil := (1.0 - hurt_progress) * 2.4
			position.x += enemy.facing * recoil + sin(_state_elapsed * 78.0) * (1.0 - hurt_progress) * 0.8
			rotation = enemy.facing * (1.0 - hurt_progress) * 0.075
			self_modulate = COHESION_TINT if int(_state_elapsed * 36.0) % 2 == 0 else Color("ff6961")
		elif enemy.state_machine.current == EnemyStateMachine.State.RETREAT:
			position.x -= enemy.facing * 0.8
			rotation = enemy.facing * 0.025


func _update_nilo_feedback(nilo: NiloPlayer) -> void:
	match nilo.state_machine.current_state:
		PlayerStateMachine.State.IDLE:
			position.y += sin(_life_elapsed * 2.4) * 0.35
		PlayerStateMachine.State.RUN:
			var run_step := int(floor(_state_elapsed / 0.09))
			position.y += -0.7 if run_step % 2 == 0 else 0.35
		PlayerStateMachine.State.CROUCH:
			scale.y *= 0.92
			position.y += 2.0
		PlayerStateMachine.State.JUMP:
			scale *= Vector2(0.94, 1.06)
		PlayerStateMachine.State.FALL:
			scale *= Vector2(1.06, 0.94)
		PlayerStateMachine.State.RIFLE:
			position.x -= nilo.facing * 1.5
			rotation = -nilo.facing * 0.025
		PlayerStateMachine.State.MELEE:
			position.x += nilo.facing * 1.0
		PlayerStateMachine.State.HEAL:
			var pulse := 0.92 + sin(_life_elapsed * 9.0) * 0.08
			self_modulate = Color(0.62 + pulse * 0.2, 1.0, 0.78, 1.0)
		PlayerStateMachine.State.HURT:
			position.x += sin(_state_elapsed * 70.0) * 1.2
		_:
			pass
	if nilo.invulnerability_remaining > 0.0:
		var flash_phase := int(nilo.invulnerability_remaining * 24.0) % 3
		self_modulate.a = 0.45 if flash_phase == 0 else 1.0
