class_name Checkpoint
extends Area2D

const INTERACTIVE_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/08_objetos_interativos_e_estados.png")
const INACTIVE_REGION := Rect2(96, 45, 268, 402)
const ACTIVE_REGION := Rect2(449, 45, 270, 402)

@export var checkpoint_id: StringName = &"vila_igreja"
var active := false
var visual: Sprite2D


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20.0, 34.0)
	collision.shape = shape
	add_child(collision)
	visual = Sprite2D.new()
	visual.name = "CheckpointSprite"
	visual.texture = INTERACTIVE_ATLAS
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.region_enabled = true
	visual.region_filter_clip_enabled = true
	visual.z_index = 8
	add_child(visual)
	body_entered.connect(_on_body_entered)
	_refresh_visual()


func _on_body_entered(body: Node) -> void:
	if active or not body.is_in_group("player"):
		return
	active = true
	EventBus.checkpoint_activated.emit(checkpoint_id, global_position + Vector2(20.0, 4.0))
	if body is NiloPlayer:
		body.health.restore_full()
		body.combat.refill_at_checkpoint()
	_refresh_visual()


func _refresh_visual() -> void:
	var frame_region := ACTIVE_REGION if active else INACTIVE_REGION
	var target_width := 55.0
	var art_scale := target_width / frame_region.size.x
	visual.region_rect = frame_region
	visual.scale = Vector2.ONE * art_scale
	# O altar fica apoiado no mesmo piso da colisao, sem depender do tamanho da folha.
	var content_bottom := 435.0
	var bottom_from_center := content_bottom - frame_region.position.y - frame_region.size.y * 0.5
	visual.position = Vector2(0.0, 18.0 - bottom_from_center * art_scale)
