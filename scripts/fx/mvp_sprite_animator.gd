class_name MvpSpriteAnimator
extends Sprite2D

enum ActorKind { NILO, SAQUEADOR, PISTOLEIRO, ZE_TRANCA }

@export var actor_kind := ActorKind.NILO
@export_range(1, 12) var columns := 4
@export_range(1, 8) var rows := 3
@export var frame_interval := 0.13

var _state_elapsed := 0.0
var _life_elapsed := 0.0
var _last_state := -1
var _last_frame := -1
var _base_position := Vector2.ZERO
var _base_scale := Vector2.ONE


func _ready() -> void:
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
		PlayerStateMachine.State.SHOOT, PlayerStateMachine.State.SHOTGUN:
			return 10
		PlayerStateMachine.State.MELEE:
			return 11
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
				EnemyStateMachine.State.CHASE:
					return _cycle(1, 2, frame_interval)
				EnemyStateMachine.State.ATTACK:
					return _cycle(4, 2, frame_interval)
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 6
				EnemyStateMachine.State.DEAD:
					return 11
				_:
					return 0
		ActorKind.PISTOLEIRO:
			match enemy.state_machine.current:
				EnemyStateMachine.State.CHASE:
					return _cycle(1, 2, frame_interval)
				EnemyStateMachine.State.ATTACK:
					return 4
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 3
				_:
					return 0
		ActorKind.ZE_TRANCA:
			match enemy.state_machine.current:
				EnemyStateMachine.State.CHASE:
					return 1
				EnemyStateMachine.State.ATTACK:
					return 2
				_:
					return 0
	return 0


func _cycle(first_frame: int, frame_count: int, interval: float) -> int:
	return first_frame + int(floor(_state_elapsed / maxf(interval, 0.01))) % maxi(frame_count, 1)


func _apply_frame(frame_index: int) -> void:
	if texture == null or frame_index == _last_frame:
		return
	_last_frame = frame_index
	var safe_columns := maxi(1, columns)
	var safe_rows := maxi(1, rows)
	var cell_size := Vector2(
		float(texture.get_width()) / float(safe_columns),
		float(texture.get_height()) / float(safe_rows)
	)
	var column := frame_index % safe_columns
	var row := frame_index / safe_columns
	region_rect = Rect2(Vector2(column, row) * cell_size, cell_size)


func _update_facing_feedback_and_motion() -> void:
	var actor := get_parent()
	var actor_facing = actor.get("facing")
	if actor_facing != null:
		flip_h = float(actor_facing) < 0.0
	position = _base_position
	scale = _base_scale
	rotation = 0.0
	self_modulate = Color.WHITE
	if actor is NiloPlayer:
		_update_nilo_feedback(actor as NiloPlayer)
	elif actor is EnemyBase:
		var enemy := actor as EnemyBase
		if enemy.state_machine.current == EnemyStateMachine.State.STAGGER:
			self_modulate = Color("f4d35e")
		elif enemy.state_machine.current == EnemyStateMachine.State.HURT:
			self_modulate = Color("ff8080")


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
		PlayerStateMachine.State.SHOTGUN:
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
