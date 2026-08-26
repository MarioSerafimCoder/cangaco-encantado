class_name TraversalPlatform
extends StaticBody2D

@export var platform_size := Vector2(64.0, 8.0)
@export var stone_style := false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = platform_size
	collision.shape = shape
	add_child(collision)
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(-platform_size * 0.5, platform_size)
	var base := Color("72513a") if not stone_style else Color("756652")
	var edge := Color("c18a4d") if not stone_style else Color("bca477")
	var shadow := Color("3d2b24") if not stone_style else Color("3d3932")
	draw_rect(rect, base, true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(3.0, rect.size.y))), edge, true)
	draw_line(Vector2(rect.position.x, rect.end.y - 1), rect.end - Vector2(0, 1), shadow, 1.0)
	if platform_size.x > platform_size.y:
		for x in range(int(rect.position.x) + 8, int(rect.end.x), 14):
			draw_line(Vector2(x, rect.position.y + 2), Vector2(x + 4, rect.end.y - 2), shadow, 1.0)
	else:
		for y in range(int(rect.position.y) + 8, int(rect.end.y), 13):
			draw_line(Vector2(rect.position.x + 2, y), Vector2(rect.end.x - 2, y + 3), shadow, 1.0)

