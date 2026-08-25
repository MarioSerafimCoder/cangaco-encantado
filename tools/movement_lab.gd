extends Node2D

var solid_rects: Array[Rect2] = [
	Rect2(0.0, 150.0, 304.0, 30.0),
	Rect2(376.0, 150.0, 584.0, 30.0),
	Rect2(202.0, 112.0, 92.0, 8.0),
	Rect2(396.0, 119.0, 108.0, 8.0),
	Rect2(546.0, 92.0, 84.0, 8.0),
	Rect2(580.0, 118.0, 12.0, 32.0),
	Rect2(796.0, 118.0, 100.0, 8.0),
]


func _ready() -> void:
	for rect in solid_rects:
		_add_solid(rect)
	_build_overlay()
	queue_redraw()


func _process(_delta: float) -> void:
	var nilo := $Nilo as NiloPlayer
	if nilo.global_position.y > 280.0:
		nilo.global_position = Vector2(112.0, 126.0)
		nilo.velocity = Vector2.ZERO


func _add_solid(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.position = rect.get_center()
	body.add_child(collision)
	add_child(body)


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var title := Label.new()
	title.position = Vector2(6.0, 4.0)
	title.size = Vector2(308.0, 20.0)
	title.text = "MOVEMENT LAB 0.2.1"
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color("ffe0a0"))
	layer.add_child(title)
	var hint := Label.new()
	hint.position = Vector2(6.0, 164.0)
	hint.size = Vector2(308.0, 12.0)
	hint.text = "CORRA · VIRE · SALTE O VÃO · TESTE COMBO NO BONECO"
	hint.add_theme_font_size_override("font_size", 5)
	hint.add_theme_color_override("font_color", Color("d9c8a5"))
	layer.add_child(hint)


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 960.0, 180.0), Color("26343a"), true)
	for band in 5:
		draw_rect(Rect2(0.0, 36.0 + band * 18.0, 960.0, 18.0), Color("4f6570").lerp(Color("b98455"), float(band) / 4.0), true)
	for rect in solid_rects:
		draw_rect(rect, Color("654632"), true)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(rect.size.y, 4.0))), Color("c09559"), true)
	for marker_x in range(32, 944, 32):
		draw_line(Vector2(marker_x, 146.0), Vector2(marker_x, 150.0), Color("e1ba6c"), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(310.0, 142.0), "VÃO", HORIZONTAL_ALIGNMENT_CENTER, 66.0, 7, Color("ffe0a0"))
	draw_string(ThemeDB.fallback_font, Vector2(560.0, 86.0), "VIRADA", HORIZONTAL_ALIGNMENT_CENTER, 58.0, 7, Color("ffe0a0"))
	draw_string(ThemeDB.fallback_font, Vector2(690.0, 113.0), "BONECO", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 7, Color("ffe0a0"))
