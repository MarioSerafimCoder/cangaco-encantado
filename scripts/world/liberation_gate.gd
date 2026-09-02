class_name LiberationGate
extends StaticBody2D

const INTERACTIVE_ATLAS := preload("res://assets/sprites/usados/cenarios/vila_umbuzeiro/atlases_expansao/08_objetos_interativos_e_estados.png")
const CLOSED_REGION := Rect2(848, 474, 377, 365)
const OPEN_REGION := Rect2(1255, 474, 402, 365)

@export var region_id: StringName = &"vila_umbuzeiro"
@export var blocked_label := "BLOQUEADA"
@export var open_label := "PEDRA SECA >"
@export var gate_size := Vector2(12.0, 34.0)
@export var show_indicator := true
var opened := false
var collision: CollisionShape2D
var visual: Sprite2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	collision.shape = shape
	add_child(collision)
	if show_indicator:
		visual = Sprite2D.new()
		visual.name = "GateSprite"
		visual.texture = INTERACTIVE_ATLAS
		visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		visual.region_enabled = true
		visual.region_filter_clip_enabled = true
		visual.z_index = 9
		add_child(visual)
	EventBus.world_state_changed.connect(_on_world_state_changed)
	_set_open(WorldState.get_region_state(region_id) == WorldState.LIBERATED)


func _set_open(value: bool) -> void:
	opened = value
	if collision:
		collision.disabled = opened
	_refresh_visual()
	queue_redraw()


func _on_world_state_changed(changed_region: StringName, state: StringName) -> void:
	if changed_region == region_id:
		_set_open(state == WorldState.LIBERATED)


func _draw() -> void:
	if not show_indicator:
		return
	if opened:
		draw_string(ThemeDB.fallback_font, Vector2(-24.0, -18.0), open_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color("9ad1a3"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(-29.0, -gate_size.y * 0.5 - 5.0), blocked_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color.WHITE)


func _refresh_visual() -> void:
	if visual == null:
		return
	var frame_region := OPEN_REGION if opened else CLOSED_REGION
	var target_width := 62.0 if opened else 58.0
	var art_scale := target_width / frame_region.size.x
	visual.region_rect = frame_region
	visual.scale = Vector2.ONE * art_scale
	var content_bottom := 826.0
	var bottom_from_center := content_bottom - frame_region.position.y - frame_region.size.y * 0.5
	# Este portao e criado em y=60; o piso global da arena esta em y=150.
	visual.position = Vector2(0.0, 90.0 - bottom_from_center * art_scale)
