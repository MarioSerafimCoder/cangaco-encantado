class_name ShortcutDoor
extends Area2D

@export var shortcut_id: StringName = &"vila_praca_armazem"
@export var destination := Vector2.ZERO
var player_inside: NiloPlayer
var opened := false


func _ready() -> void:
	opened = bool(GameState.opened_shortcuts.get(String(shortcut_id), false))
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(26.0, 42.0)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()


func _process(_delta: float) -> void:
	if player_inside == null or not Input.is_action_just_pressed("interact"):
		return
	if not opened:
		opened = true
		GameState.opened_shortcuts[String(shortcut_id)] = true
		EventBus.shortcut_opened.emit(shortcut_id)
		queue_redraw()
	else:
		player_inside.global_position = destination


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		player_inside = body


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null


func _draw() -> void:
	var color := Color("5b7f5d") if opened else Color("7d3328")
	draw_rect(Rect2(-10.0, -19.0, 20.0, 38.0), color, true)
	draw_circle(Vector2(5.0, 0.0), 1.5, Color("f4d35e"))
	draw_string(ThemeDB.fallback_font, Vector2(-22.0, -24.0), "ATALHO" if opened else "ABRIR [E]", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color.WHITE)

