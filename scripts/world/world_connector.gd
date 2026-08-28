class_name WorldConnector
extends Area2D

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

@export var connector_id: StringName
@export var destination := Vector2.ZERO
@export var required_ability: StringName
@export var required_flag: StringName
@export var display_name := "PASSAGEM"
@export var destination_room: StringName
@export var persistent_shortcut := true
@export var locked_until_opened := false

var _player_inside: NiloPlayer
var _prompt: Label


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
	_prompt = Label.new()
	_prompt.position = Vector2(-52, -28)
	_prompt.size = Vector2(104, 18)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_override("font", PIXEL_FONT)
	_prompt.add_theme_font_size_override("font_size", 7)
	_prompt.add_theme_color_override("font_color", Color("f4dfb6"))
	_prompt.visible = false
	add_child(_prompt)
	set_process(true)


func _process(_delta: float) -> void:
	if _player_inside == null:
		return
	_refresh_prompt()
	if not Input.is_action_just_pressed("interact"):
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
	if not required_flag.is_empty() and not bool(WorldState.flags.get(String(required_flag), false)):
		return false
	if locked_until_opened and not bool(GameState.opened_shortcuts.get(String(connector_id), false)):
		return false
	if required_ability.is_empty():
		return true
	return bool(GameState.abilities.get(String(required_ability), false)) or bool(GameState.opened_shortcuts.get(String(connector_id), false))


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		_player_inside = body
		_refresh_prompt()


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null
		_prompt.visible = false


func _refresh_prompt() -> void:
	var unlocked := _can_use()
	_prompt.text = "[%s] %s" % [InputBootstrap.interact_prompt(), display_name] if unlocked else ("ATALHO FECHADO" if locked_until_opened or not required_flag.is_empty() else "REQUER %s" % _ability_name())
	_prompt.visible = true


func _ability_name() -> String:
	match required_ability:
		&"wall_jump": return "PASSO DA PEDRA"
		&"dash": return "PASSO DA POEIRA"
		_: return String(required_ability).to_upper()
