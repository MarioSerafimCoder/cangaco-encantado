class_name AtlasWorldProp
extends StaticBody2D

static var _opaque_bounds_cache: Dictionary = {}

var sprite: Sprite2D
var visual_height := 0.0
var walkable_surface_height := 0.0


func configure(texture: Texture2D, region: Rect2, target_width: float, walkable_width := 0.0, walkable_height := 8.0, z := -2, surface_height := -1.0) -> AtlasWorldProp:
	collision_layer = 1 if walkable_width > 0.0 else 0
	collision_mask = 0
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = region
	var art_scale := target_width / maxf(region.size.x, 1.0)
	var opaque_bounds := _alpha_bounds(texture, region)
	visual_height = opaque_bounds.size.y * art_scale
	walkable_surface_height = visual_height if surface_height <= 0.0 else minf(surface_height, visual_height)
	sprite.scale = Vector2.ONE * art_scale
	# A linha de base usa o último pixel opaco, não a borda da célula do atlas.
	# Assim margens transparentes não fazem o objeto ou a colisão flutuar.
	sprite.position.y = region.size.y * art_scale * 0.5 - opaque_bounds.end.y * art_scale
	sprite.z_index = z
	add_child(sprite)
	if walkable_width > 0.0:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(walkable_width, walkable_height)
		collision.shape = shape
		collision.position.y = -walkable_surface_height + walkable_height * 0.5
		add_child(collision)
	return self


static func _alpha_bounds(texture: Texture2D, region: Rect2) -> Rect2:
	var cache_key := "%s:%d:%d:%d:%d" % [texture.resource_path, int(region.position.x), int(region.position.y), int(region.size.x), int(region.size.y)]
	if _opaque_bounds_cache.has(cache_key):
		return _opaque_bounds_cache[cache_key]
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2(Vector2.ZERO, region.size)
	var start_x := clampi(int(region.position.x), 0, image.get_width())
	var start_y := clampi(int(region.position.y), 0, image.get_height())
	var end_x := clampi(int(region.end.x), 0, image.get_width())
	var end_y := clampi(int(region.end.y), 0, image.get_height())
	var min_x := end_x
	var min_y := end_y
	var max_x := start_x - 1
	var max_y := start_y - 1
	for y in range(start_y, end_y):
		for x in range(start_x, end_x):
			if image.get_pixel(x, y).a <= 0.05:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	var result := Rect2(Vector2.ZERO, region.size)
	if max_x >= min_x and max_y >= min_y:
		result = Rect2(min_x - start_x, min_y - start_y, max_x - min_x + 1, max_y - min_y + 1)
	_opaque_bounds_cache[cache_key] = result
	return result
