class_name NarrativeInteractable
extends Area2D

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

@export var dialogue_id: StringName
@export var persistent_flag: StringName

var player_inside: NiloPlayer
var prompt: Label


func configure_visual(texture: Texture2D, region: Rect2, target_width: float, z := 4) -> void:
	var sprite := Sprite2D.new()
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


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 44)
	collision.shape = shape
	collision.position.y = -14
	add_child(collision)
	prompt = Label.new()
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


func _process(_delta: float) -> void:
	if player_inside == null:
		return
	prompt.text = "[%s]" % InputBootstrap.interact_prompt()
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
