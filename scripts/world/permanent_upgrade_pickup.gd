class_name PermanentUpgradePickup
extends Area2D

@export var upgrade_id: StringName = &"coracao_casa_nilo"
@export var display_name := "CORAÇÃO DO SERTÃO"
@export var health_bonus := 1

var _collected := false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	_collected = bool(GameState.permanent_upgrades.get(String(upgrade_id), false))
	visible = not _collected
	queue_redraw()


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


func _draw() -> void:
	if _collected:
		return
	draw_circle(Vector2.ZERO, 9.0, Color(0.9, 0.2, 0.18, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-7,-3), Vector2(-4,-7), Vector2(0,-5), Vector2(4,-7), Vector2(7,-3), Vector2(0,8)]), Color("dc493d"))
	draw_polyline(PackedVector2Array([Vector2(-7,-3), Vector2(-4,-7), Vector2(0,-5), Vector2(4,-7), Vector2(7,-3), Vector2(0,8), Vector2(-7,-3)]), Color("ffd27a"), 1.0)

