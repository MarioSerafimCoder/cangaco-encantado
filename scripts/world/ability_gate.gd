class_name AbilityGate
extends StaticBody2D

@export var required_ability: StringName = &"dash"
@export var gate_size := Vector2(10.0, 54.0)
@export var label := "SELO DO VENTO"

var _collision: CollisionShape2D
var _opened := false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	_collision.shape = shape
	add_child(_collision)
	EventBus.ability_unlocked.connect(_on_ability_unlocked)
	_refresh()


func _on_ability_unlocked(ability_id: StringName, _display_name: String) -> void:
	if ability_id == required_ability:
		_refresh()


func _refresh() -> void:
	_opened = bool(GameState.abilities.get(String(required_ability), false))
	_collision.set_deferred("disabled", _opened)
	queue_redraw()


func _draw() -> void:
	if _opened:
		return
	var rect := Rect2(-gate_size * 0.5, gate_size)
	draw_rect(rect, Color(0.18, 0.07, 0.08, 0.72), true)
	for y in range(int(rect.position.y) + 4, int(rect.end.y), 8):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y + 3), Color("d74a3e"), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-28, rect.position.y - 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("f4bc70"))

