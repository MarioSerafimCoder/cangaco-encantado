class_name MvpSpriteAnimator
extends Sprite2D

enum ActorKind { NILO, SAQUEADOR, PISTOLEIRO, ZE_TRANCA }

@export var actor_kind := ActorKind.NILO
@export_range(1, 12) var columns := 4
@export_range(1, 8) var rows := 3
@export var frame_interval := 0.13

var _elapsed := 0.0
var _alternate_frame := false
var _last_frame := -1


func _ready() -> void:
	region_enabled = true
	region_filter_clip_enabled = true
	_apply_frame(0)


func _process(delta: float) -> void:
	if texture == null:
		return
	_elapsed += delta
	if _elapsed >= frame_interval:
		_elapsed = 0.0
		_alternate_frame = not _alternate_frame
	_apply_frame(_select_frame())
	_update_facing_and_feedback()


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
			return 4 + int(_alternate_frame)
		PlayerStateMachine.State.JUMP:
			return 5
		PlayerStateMachine.State.FALL:
			return 4
		PlayerStateMachine.State.SHOOT:
			return 6
		PlayerStateMachine.State.SHOTGUN:
			return 7
		PlayerStateMachine.State.MELEE:
			return 8 + int(_alternate_frame)
		PlayerStateMachine.State.HURT:
			return 3
		PlayerStateMachine.State.DEAD:
			return 11
		_:
			return int(_alternate_frame)


func _select_enemy_frame() -> int:
	var enemy := get_parent() as EnemyBase
	if enemy == null:
		return 0
	match actor_kind:
		ActorKind.SAQUEADOR:
			match enemy.state_machine.current:
				EnemyStateMachine.State.CHASE:
					return 1 + int(_alternate_frame)
				EnemyStateMachine.State.ATTACK:
					return 4 + int(_alternate_frame)
				EnemyStateMachine.State.HURT, EnemyStateMachine.State.STAGGER:
					return 6
				EnemyStateMachine.State.DEAD:
					return 11
				_:
					return 0
		ActorKind.PISTOLEIRO:
			match enemy.state_machine.current:
				EnemyStateMachine.State.CHASE:
					return 1 + int(_alternate_frame)
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


func _update_facing_and_feedback() -> void:
	var actor := get_parent()
	var actor_facing = actor.get("facing")
	if actor_facing != null:
		flip_h = float(actor_facing) < 0.0
	self_modulate = Color.WHITE
	if actor is NiloPlayer:
		var nilo := actor as NiloPlayer
		if nilo.invulnerability_remaining > 0.0:
			self_modulate.a = 0.35 if int(nilo.invulnerability_remaining * 20.0) % 2 == 0 else 1.0
		if nilo.state_machine.current_state == PlayerStateMachine.State.HEAL:
			self_modulate = Color(0.65, 0.88, 1.0, self_modulate.a)
	elif actor is EnemyBase:
		var enemy := actor as EnemyBase
		if enemy.state_machine.current == EnemyStateMachine.State.STAGGER:
			self_modulate = Color("f4d35e")
		elif enemy.state_machine.current == EnemyStateMachine.State.HURT:
			self_modulate = Color("ff8080")
