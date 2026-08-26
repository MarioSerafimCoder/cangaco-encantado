class_name WorldConnector
extends Area2D

@export var connector_id: StringName
@export var destination := Vector2.ZERO
@export var required_ability: StringName
@export var display_name := "PASSAGEM"
@export var destination_room: StringName
@export var persistent_shortcut := true
@export var locked_until_opened := false

var _player_inside: NiloPlayer


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 36.0)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	set_process(true)
	queue_redraw()


func _process(_delta: float) -> void:
	if _player_inside == null or not Input.is_action_just_pressed("interact"):
		return
	if not _can_use():
		return
	if persistent_shortcut and not GameState.opened_shortcuts.has(String(connector_id)):
		GameState.opened_shortcuts[String(connector_id)] = true
		EventBus.shortcut_opened.emit(connector_id)
	_player_inside.global_position = destination
	_player_inside.velocity = Vector2.ZERO
	if not destination_room.is_empty():
		EventBus.room_entered.emit(destination_room, "")


func _can_use() -> bool:
	if locked_until_opened and not bool(GameState.opened_shortcuts.get(String(connector_id), false)):
		return false
	if required_ability.is_empty():
		return true
	return bool(GameState.abilities.get(String(required_ability), false)) or bool(GameState.opened_shortcuts.get(String(connector_id), false))


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		_player_inside = body
		queue_redraw()


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null
		queue_redraw()


func _draw() -> void:
	var unlocked := _can_use()
	var color := Color("62cbb5") if unlocked else Color("9a3f38")
	draw_rect(Rect2(-10, -16, 20, 32), Color(0.08, 0.06, 0.05, 0.82), true)
	draw_rect(Rect2(-10, -16, 20, 32), color, false, 2.0)
	draw_circle(Vector2(0, -2), 4, color, false, 1.0)
	if _player_inside != null:
		var prompt := "[E] %s" % display_name if unlocked else ("ATALHO FECHADO" if locked_until_opened else "REQUER %s" % _ability_name())
		draw_string(ThemeDB.fallback_font, Vector2(-34, -22), prompt, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color.WHITE)


func _ability_name() -> String:
	match required_ability:
		&"wall_jump": return "PASSO DA PEDRA"
		&"dash": return "PASSO DA POEIRA"
		_: return String(required_ability).to_upper()
