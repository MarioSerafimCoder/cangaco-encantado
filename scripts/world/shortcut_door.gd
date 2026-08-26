class_name ShortcutDoor
extends Area2D

const INTERACTIVE_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/08_objetos_interativos_e_estados.png")
const CLOSED_REGION := Rect2(805, 45, 366, 402)
const OPEN_REGION := Rect2(1254, 45, 359, 402)

@export var shortcut_id: StringName = &"vila_praca_armazem"
@export var destination := Vector2.ZERO
var player_inside: NiloPlayer
var opened := false
var visual: Sprite2D


func _ready() -> void:
	opened = bool(GameState.opened_shortcuts.get(String(shortcut_id), false))
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(26.0, 42.0)
	collision.shape = shape
	add_child(collision)
	visual = Sprite2D.new()
	visual.name = "DoorSprite"
	visual.texture = INTERACTIVE_ATLAS
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.region_enabled = true
	visual.region_filter_clip_enabled = true
	visual.z_index = 7
	add_child(visual)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()


func _process(_delta: float) -> void:
	if player_inside == null or not Input.is_action_just_pressed("interact"):
		return
	if not opened:
		opened = true
		GameState.opened_shortcuts[String(shortcut_id)] = true
		EventBus.shortcut_opened.emit(shortcut_id)
		_refresh_visual()
	else:
		player_inside.global_position = destination


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		player_inside = body


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null


func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(-22.0, -24.0), "ATALHO" if opened else "ABRIR [E]", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color.WHITE)


func _refresh_visual() -> void:
	var frame_region := OPEN_REGION if opened else CLOSED_REGION
	var target_width := 72.0
	var art_scale := target_width / frame_region.size.x
	visual.region_rect = frame_region
	visual.scale = Vector2.ONE * art_scale
	var content_bottom := 435.0
	var bottom_from_center := content_bottom - frame_region.position.y - frame_region.size.y * 0.5
	visual.position = Vector2(0.0, 22.0 - bottom_from_center * art_scale)
	queue_redraw()
