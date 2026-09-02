class_name AbilityPickup
extends Area2D

const UI_ATLAS := preload("res://assets/sprites/usados/interface/dialogo_loja/dialogo_loja_atlas.png")
const ABILITY_REGION := Rect2(1245, 112, 120, 150)
const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

@export var ability_id: StringName = &"wall_jump"
@export var display_name := "PASSO DA PEDRA"
@export var description := "SALTE NOVAMENTE JUNTO A UMA PAREDE"

var _player_inside: NiloPlayer
var _collected := false
var _visual: Sprite2D
var _prompt: Label
var _elapsed := 0.0


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13.0
	collision.shape = shape
	add_child(collision)
	_visual = Sprite2D.new()
	_visual.texture = UI_ATLAS
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.region_enabled = true
	_visual.region_filter_clip_enabled = true
	_visual.region_rect = ABILITY_REGION
	_visual.scale = Vector2.ONE * 0.2
	_visual.z_index = 8
	add_child(_visual)
	_prompt = Label.new()
	_prompt.position = Vector2(-55, -28)
	_prompt.size = Vector2(110, 14)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_override("font", PIXEL_FONT)
	_prompt.add_theme_font_size_override("font_size", 7)
	_prompt.add_theme_color_override("font_color", Color("f4dfb6"))
	_prompt.visible = false
	add_child(_prompt)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_collected = bool(GameState.abilities.get(String(ability_id), false))
	visible = not _collected
	set_process(not _collected)
	queue_redraw()


func _process(_delta: float) -> void:
	_elapsed += _delta
	_visual.position.y = round(sin(_elapsed * 2.8) * 2.0)
	if _player_inside != null and Input.is_action_just_pressed("interact"):
		_collect()


func _collect() -> void:
	if _collected:
		return
	_collected = true
	GameState.abilities[String(ability_id)] = true
	EventBus.ability_unlocked.emit(ability_id, display_name)
	visible = false
	set_process(false)


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		_player_inside = body
		_prompt.text = InputGlyphResolver.prompt(&"interact", "ADQUIRIR %s" % display_name)
		_prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null
		_prompt.visible = false
