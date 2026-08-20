class_name RoomTrigger
extends Area2D

var room_id: StringName
var display_name := ""
var triggered := false


func configure(new_id: StringName, new_name: String, bounds: Rect2) -> void:
	room_id = new_id
	display_name = new_name
	position = bounds.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = bounds.size
	collision.shape = shape
	add_child(collision)
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		EventBus.room_entered.emit(room_id, display_name)
		triggered = true

