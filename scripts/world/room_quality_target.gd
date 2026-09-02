class_name RoomQualityTarget
extends Node2D

const SKY_TEXTURE := preload("res://assets/sprites/usados/cenarios/rua_das_cinzas/fundos/rua_sky_far.png")
const VILLAGE_TEXTURE := preload("res://assets/sprites/usados/cenarios/rua_das_cinzas/fundos/rua_village_mid.png")
const FOREGROUND_TEXTURE := preload("res://assets/sprites/usados/cenarios/rua_das_cinzas/fundos/rua_foreground.png")

var room_bounds := Rect2()
var player: NiloPlayer
var layers: Array[Dictionary] = []


func configure(target_bounds: Rect2) -> void:
	room_bounds = target_bounds
	_build_layer(SKY_TEXTURE, Vector2(room_bounds.get_center().x, 0.0), -30, 0.04)
	_build_layer(VILLAGE_TEXTURE, Vector2(room_bounds.get_center().x, 69.0), -12, 0.52)
	_build_layer(FOREGROUND_TEXTURE, Vector2(room_bounds.get_center().x, 8.0), 12, 1.10)
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as NiloPlayer
	if player == null:
		return
	var active_bounds := room_bounds.grow(190.0)
	visible = active_bounds.has_point(player.global_position)
	if not visible:
		return
	var camera_delta := player.global_position.x - room_bounds.get_center().x
	for entry in layers:
		var sprite: Sprite2D = entry.sprite
		var base_position: Vector2 = entry.base_position
		var scroll_scale: float = entry.scroll_scale
		sprite.position.x = round(base_position.x + camera_delta * (1.0 - scroll_scale))


func _build_layer(texture: Texture2D, base_position: Vector2, layer_z: int, scroll_scale: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = base_position
	sprite.z_index = layer_z
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	layers.append({"sprite": sprite, "base_position": base_position, "scroll_scale": scroll_scale})
