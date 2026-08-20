class_name LiberationGate
extends StaticBody2D

@export var region_id: StringName = &"vila_umbuzeiro"
@export var blocked_label := "BLOQUEADA"
@export var open_label := "PEDRA SECA >"
@export var gate_size := Vector2(12.0, 34.0)
var opened := false
var collision: CollisionShape2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	collision.shape = shape
	add_child(collision)
	EventBus.world_state_changed.connect(_on_world_state_changed)
	_set_open(WorldState.get_region_state(region_id) == WorldState.LIBERATED)


func _set_open(value: bool) -> void:
	opened = value
	if collision:
		collision.disabled = opened
	queue_redraw()


func _on_world_state_changed(changed_region: StringName, state: StringName) -> void:
	if changed_region == region_id:
		_set_open(state == WorldState.LIBERATED)


func _draw() -> void:
	if opened:
		draw_string(ThemeDB.fallback_font, Vector2(-24.0, -18.0), open_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color("9ad1a3"))
	else:
		draw_rect(Rect2(-gate_size * 0.5, gate_size), Color("8c5e3c"), true)
		draw_string(ThemeDB.fallback_font, Vector2(-29.0, -gate_size.y * 0.5 - 5.0), blocked_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color.WHITE)
