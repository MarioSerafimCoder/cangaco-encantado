class_name LoreCollectible
extends Area2D

const UI_ATLAS := preload("res://assets/sprites/usados/interface/dialogo_loja/dialogo_loja_atlas.png")
const CORDEL_REGION := Rect2(242, 778, 205, 180)

@export var collectible_id: StringName
@export var display_name := "FOLHETO DE CORDEL"
@export var currency_reward := 4

var _collected := false
var _sprite: Sprite2D
var _elapsed := 0.0


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 11.0
	collision.shape = shape
	add_child(collision)
	_sprite = Sprite2D.new()
	_sprite.texture = UI_ATLAS
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.region_enabled = true
	_sprite.region_filter_clip_enabled = true
	_sprite.region_rect = CORDEL_REGION
	_sprite.scale = Vector2.ONE * 0.115
	_sprite.z_index = 8
	add_child(_sprite)
	body_entered.connect(_on_body_entered)
	_collected = bool(GameState.discovered_secrets.get(String(collectible_id), false))
	visible = not _collected
	set_process(not _collected)


func _process(delta: float) -> void:
	_elapsed += delta
	_sprite.position.y = round(sin(_elapsed * 2.4) * 2.0)


func _on_body_entered(body: Node) -> void:
	if _collected or body is not NiloPlayer:
		return
	_collected = true
	GameState.discovered_secrets[String(collectible_id)] = true
	GameState.add_inventory_item(&"collectibles", collectible_id, 1)
	GameState.add_currency(currency_reward)
	EventBus.secret_discovered.emit(collectible_id)
	EventBus.lore_collectible_found.emit(collectible_id, display_name)
	visible = false
	set_process(false)
