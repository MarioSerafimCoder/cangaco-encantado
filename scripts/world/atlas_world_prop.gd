class_name AtlasWorldProp
extends StaticBody2D

var sprite: Sprite2D


func configure(texture: Texture2D, region: Rect2, target_width: float, walkable_width := 0.0, walkable_height := 8.0, z := -2) -> AtlasWorldProp:
	collision_layer = 1 if walkable_width > 0.0 else 0
	collision_mask = 0
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = region
	var art_scale := target_width / maxf(region.size.x, 1.0)
	sprite.scale = Vector2.ONE * art_scale
	sprite.position.y = -region.size.y * art_scale * 0.5
	sprite.z_index = z
	add_child(sprite)
	if walkable_width > 0.0:
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(walkable_width, walkable_height)
		collision.shape = shape
		collision.position.y = -region.size.y * art_scale + walkable_height * 0.5
		add_child(collision)
	return self
