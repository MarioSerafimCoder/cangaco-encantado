class_name PermanentUpgradePickup
extends Area2D

const UI_ATLAS := preload("res://assets/area_01/ui/dialogo_loja_atlas.png")
const MEDAL_REGION := Rect2(1000, 778, 155, 180)

@export var upgrade_id: StringName = &"coracao_casa_nilo"
@export var display_name := "CORAÇÃO DO SERTÃO"
@export var health_bonus := 1

var _collected := false
var _visual: Sprite2D


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := get_node_or_null("InteractionCollision") as CollisionShape2D
	if collision == null:
		collision = CollisionShape2D.new()
		collision.name = "InteractionCollision"
		var shape := CircleShape2D.new()
		shape.radius = 10.0
		collision.shape = shape
		add_child(collision)
	_visual = get_node_or_null("UpgradeSprite") as Sprite2D
	if _visual == null:
		_visual = Sprite2D.new()
		_visual.name = "UpgradeSprite"
		_visual.texture = UI_ATLAS
		_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_visual.region_enabled = true
		_visual.region_filter_clip_enabled = true
		_visual.region_rect = MEDAL_REGION
		_visual.scale = Vector2.ONE * 0.17
		_visual.z_index = 8
		add_child(_visual)
	body_entered.connect(_on_body_entered)
	_collected = bool(GameState.permanent_upgrades.get(String(upgrade_id), false))
	visible = not _collected


func _on_body_entered(body: Node) -> void:
	if _collected or not body is NiloPlayer:
		return
	_collected = true
	var player := body as NiloPlayer
	player.apply_permanent_health_upgrade(health_bonus)
	GameState.permanent_upgrades[String(upgrade_id)] = true
	GameState.discovered_secrets[String(upgrade_id)] = true
	EventBus.secret_discovered.emit(upgrade_id)
	EventBus.permanent_upgrade_collected.emit(upgrade_id, display_name)
	visible = false
