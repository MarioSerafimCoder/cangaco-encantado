class_name Checkpoint
extends Area2D

@export var checkpoint_id: StringName = &"vila_igreja"
var active := false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20.0, 34.0)
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if active or not body.is_in_group("player"):
		return
	active = true
	EventBus.checkpoint_activated.emit(checkpoint_id, global_position + Vector2(20.0, 4.0))
	if body is NiloPlayer:
		body.health.restore_full()
		body.combat.refill_at_checkpoint()
	queue_redraw()


func _draw() -> void:
	var color := Color("f4d35e") if active else Color("5b7f5d")
	draw_circle(Vector2.ZERO, 7.0, color)
	draw_line(Vector2(0.0, -12.0), Vector2(0.0, 12.0), Color.WHITE, 2.0)
	draw_line(Vector2(-5.0, -6.0), Vector2(5.0, -6.0), Color.WHITE, 2.0)

