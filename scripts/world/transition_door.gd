class_name TransitionDoor
extends Area2D

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

@export var door_id: StringName
@export var destination := Vector2.ZERO
@export var destination_room: StringName
@export var display_name := "ABRIR PORTA"
@export var closed_region := Rect2()
@export var open_region := Rect2()
@export var target_width := 96.0

var _sprite: Sprite2D
var _prompt: Label
var _player: NiloPlayer
var _transitioning := false
var _fade: ColorRect


func configure_visual(texture: Texture2D, closed_region: Rect2, open_region: Rect2, target_width: float) -> TransitionDoor:
	self.closed_region = closed_region
	self.open_region = open_region
	self.target_width = target_width
	_sprite = Sprite2D.new()
	_sprite.name = "DoorSprite"
	_sprite.texture = texture
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.region_enabled = true
	_sprite.region_filter_clip_enabled = true
	_sprite.region_rect = closed_region
	_sprite.scale = Vector2.ONE * (target_width / maxf(closed_region.size.x, 1.0))
	_sprite.position.y = -closed_region.size.y * _sprite.scale.y * 0.5
	_sprite.z_index = -1
	add_child(_sprite)
	return self


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	if _sprite == null:
		_sprite = get_node_or_null("DoorSprite") as Sprite2D
	var collision := get_node_or_null("InteractionCollision") as CollisionShape2D
	if collision == null:
		collision = CollisionShape2D.new()
		collision.name = "InteractionCollision"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(maxf(34.0, target_width * 0.55), 58.0)
		collision.shape = shape
		collision.position.y = -28.0
		add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_prompt = get_node_or_null("Prompt") as Label
	if _prompt == null:
		_build_prompt()
	_fade = get_node_or_null("FadeLayer/Fade") as ColorRect
	if _fade == null:
		_build_fade()
	_set_open(false)


func _process(_delta: float) -> void:
	if _player == null or _transitioning:
		return
	_prompt.text = InputGlyphResolver.prompt(&"interact", display_name)
	if Input.is_action_just_pressed("interact"):
		_transition()


func _build_prompt() -> void:
	_prompt = Label.new()
	_prompt.name = "Prompt"
	_prompt.position = Vector2(-58.0, -92.0)
	_prompt.size = Vector2(116.0, 16.0)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_override("font", PIXEL_FONT)
	_prompt.add_theme_font_size_override("font_size", 7)
	_prompt.add_theme_color_override("font_color", Color("ffe0a3"))
	_prompt.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.text = InputGlyphResolver.prompt(&"interact", display_name)
	_prompt.visible = false
	add_child(_prompt)


func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.name = "FadeLayer"
	layer.layer = 118
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.color = Color(0.01, 0.007, 0.005, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		_player = body
		_prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body == _player and not _transitioning:
		_player = null
		_prompt.visible = false


func _transition() -> void:
	if _player == null:
		return
	_transitioning = true
	_prompt.visible = false
	_player.narrative_locked = true
	_player.velocity = Vector2.ZERO
	_set_open(true)
	var fade_in := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in.tween_property(_fade, "color:a", 1.0, 0.20).set_trans(Tween.TRANS_SINE)
	await fade_in.finished
	_player.global_position = destination
	_player.velocity = Vector2.ZERO
	EventBus.room_entered.emit(destination_room, "")
	var director := get_tree().get_first_node_in_group("camera_director") as CameraDirector
	if director != null:
		director.snap_to_room(destination_room)
	await get_tree().process_frame
	var fade_out := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out.tween_property(_fade, "color:a", 0.0, 0.28).set_trans(Tween.TRANS_SINE)
	await fade_out.finished
	_set_open(false)
	if is_instance_valid(_player):
		_player.narrative_locked = false
	_player = null
	_transitioning = false


func _set_open(value: bool) -> void:
	if _sprite == null:
		return
	var region := open_region if value else closed_region
	_sprite.region_rect = region
	_sprite.scale = Vector2.ONE * (target_width / maxf(region.size.x, 1.0))
	_sprite.position.y = -region.size.y * _sprite.scale.y * 0.5
