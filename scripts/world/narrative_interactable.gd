class_name NarrativeInteractable
extends Area2D

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

@export var dialogue_id: StringName
@export var persistent_flag: StringName
@export var interaction_verb := "EXAMINAR"
@export var enchanted_presence := false

var player_inside: NiloPlayer
var prompt: Label
var _visual: Sprite2D
var _visual_base_scale := Vector2.ONE
var _aura_center := Vector2.ZERO
var _aura_radius := 20.0
var _elapsed := 0.0


func configure_visual(texture: Texture2D, region: Rect2, target_width: float, z := 4) -> void:
	_visual = Sprite2D.new()
	_visual.name = "NarrativeSprite"
	_visual.texture = texture
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.region_enabled = true
	_visual.region_filter_clip_enabled = true
	_visual.region_rect = region
	var art_scale := target_width / maxf(region.size.x, 1.0)
	_visual.scale = Vector2.ONE * art_scale
	_visual_base_scale = _visual.scale
	_visual.position.y = -region.size.y * art_scale * 0.5
	_visual.z_index = z
	_aura_center = _visual.position
	_aura_radius = maxf(18.0, target_width * 0.42)
	add_child(_visual)


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := get_node_or_null("InteractionCollision") as CollisionShape2D
	if collision == null:
		collision = CollisionShape2D.new()
		collision.name = "InteractionCollision"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(34, 44)
		collision.shape = shape
		collision.position.y = -14
		add_child(collision)
	prompt = get_node_or_null("Prompt") as Label
	if prompt == null:
		prompt = Label.new()
		prompt.name = "Prompt"
		prompt.position = Vector2(-40, -58)
		prompt.size = Vector2(80, 14)
		prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt.add_theme_font_override("font", PIXEL_FONT)
		prompt.add_theme_font_size_override("font_size", 8)
		prompt.add_theme_color_override("font_color", Color("ffe4a8"))
		prompt.visible = false
		add_child(prompt)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_elapsed += delta
	if enchanted_presence and _visual != null:
		var pulse := sin(_elapsed * 2.1)
		_visual.scale = _visual_base_scale * (1.0 + pulse * 0.012)
		_visual.modulate = Color(1.0, 0.86 + pulse * 0.035, 0.82 + pulse * 0.04, 1.0)
		queue_redraw()
	if player_inside == null:
		return
	prompt.text = InputGlyphResolver.prompt(&"interact", interaction_verb)
	if Input.is_action_just_pressed("interact"):
		var director := get_tree().get_first_node_in_group("dialogue_director") as DialogueDirector
		if director != null:
			director.start(dialogue_id)


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		player_inside = body
		prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		prompt.visible = false


func _draw() -> void:
	if not enchanted_presence:
		return
	var pulse := (sin(_elapsed * 1.7) + 1.0) * 0.5
	for index in 3:
		var radius := _aura_radius + float(index) * 10.0 + pulse * 4.0
		var alpha := (0.18 - float(index) * 0.045) * (0.72 + pulse * 0.28)
		draw_arc(_aura_center, radius, 0.0, TAU, 32, Color(0.82, 0.18, 0.16, alpha), 1.0)
