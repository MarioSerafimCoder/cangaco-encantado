class_name TraversalPlatform
extends StaticBody2D

const TRAVERSAL_ATLAS := preload("res://assets/area_01/environment/traversal_props_atlas.png")
const CAVERN_ATLAS := preload("res://assets/area_01/environment/cavernas_estrutura_atlas.png")
const WOOD_HORIZONTAL_REGION := Rect2(38, 820, 292, 44)
const WOOD_VERTICAL_REGION := Rect2(40, 670, 60, 210)
const STONE_HORIZONTAL_REGION := Rect2(812, 744, 630, 82)
const STONE_VERTICAL_REGION := Rect2(40, 388, 88, 323)

@export var platform_size := Vector2(64.0, 8.0)
@export var stone_style := false
@export var reveal_ability: StringName

var _collision: CollisionShape2D
var _sprite: Sprite2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_collision = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if _collision == null:
		_collision = CollisionShape2D.new()
		_collision.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = platform_size
		_collision.shape = shape
		add_child(_collision)
	_sprite = get_node_or_null("PlatformSprite") as Sprite2D
	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.name = "PlatformSprite"
		_configure_runtime_sprite()
		add_child(_sprite)
	if not reveal_ability.is_empty():
		EventBus.ability_unlocked.connect(_on_ability_unlocked)
	_refresh_visibility()


func _configure_runtime_sprite() -> void:
	var vertical := platform_size.y > platform_size.x
	var region: Rect2
	if stone_style:
		region = STONE_VERTICAL_REGION if vertical else STONE_HORIZONTAL_REGION
	else:
		region = WOOD_VERTICAL_REGION if vertical else WOOD_HORIZONTAL_REGION
	_sprite.texture = CAVERN_ATLAS if stone_style else TRAVERSAL_ATLAS
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.region_enabled = true
	_sprite.region_filter_clip_enabled = true
	_sprite.region_rect = region
	var art_scale := (platform_size.y / region.size.y) if vertical else (maxf(platform_size.x, 28.0) / region.size.x)
	_sprite.scale = Vector2.ONE * art_scale
	if not vertical:
		_sprite.position.y = -region.size.y * art_scale * 0.5 + platform_size.y * 0.5
	_sprite.z_index = 2


func _on_ability_unlocked(ability_id: StringName, _display_name: String) -> void:
	if ability_id == reveal_ability:
		_refresh_visibility()


func _refresh_visibility() -> void:
	var revealed := reveal_ability.is_empty() or bool(GameState.abilities.get(String(reveal_ability), false))
	_sprite.visible = revealed
	_collision.set_deferred("disabled", not revealed)
