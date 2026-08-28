class_name NPCActor
extends Area2D

const NPC_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/07_moradores_chibi_da_vila.png")
const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const ATLAS_COLUMNS := 4
const ATLAS_ROWS := 2
const BASE_SCALE := 0.075

@export var npc_id: StringName
@export var display_name := "MORADOR"
@export var dialogue_id: StringName
@export var room_id: StringName
@export_range(0, 7) var atlas_index := 0
@export var idle_walk_radius := 0.0

var player_inside: NiloPlayer
var sprite: Sprite2D
var prompt: Label
var origin_x := 0.0
var facing := 1.0
var _idle_time := 0.0


func _ready() -> void:
	add_to_group("npcs")
	collision_layer = 16
	collision_mask = 2
	origin_x = position.x
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28, 40)
	collision.shape = shape
	collision.position.y = -10
	add_child(collision)
	sprite = Sprite2D.new()
	sprite.texture = NPC_ATLAS
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	# O atlas original mede 1313x1198; usar células fixas de 384x512
	# invadia o personagem vizinho e cortava a linha inferior.
	var cell_size := Vector2(
		float(NPC_ATLAS.get_width()) / ATLAS_COLUMNS,
		float(NPC_ATLAS.get_height()) / ATLAS_ROWS
	)
	sprite.region_rect = Rect2(
		Vector2(atlas_index % ATLAS_COLUMNS, atlas_index / ATLAS_COLUMNS) * cell_size,
		cell_size
	)
	sprite.scale = Vector2(BASE_SCALE, BASE_SCALE)
	sprite.position.y = -19
	sprite.z_index = 6
	add_child(sprite)
	prompt = Label.new()
	prompt.position = Vector2(-25, -49)
	prompt.size = Vector2(50, 14)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_override("font", PIXEL_FONT)
	prompt.add_theme_font_size_override("font_size", 8)
	prompt.add_theme_color_override("font_color", Color("ffe6ad"))
	prompt.text = "[%s]" % InputBootstrap.interact_prompt()
	prompt.visible = false
	add_child(prompt)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	EventBus.room_entered.connect(_on_room_entered)
	_refresh_room_visibility(GameState.current_room_id)


func _process(delta: float) -> void:
	_idle_time += delta
	var breathe := sin(_idle_time * 2.1) * 0.004
	sprite.scale.y = BASE_SCALE + breathe
	if player_inside != null:
		facing = signf(player_inside.global_position.x - global_position.x)
		sprite.flip_h = facing < 0
		prompt.text = "[%s]" % InputBootstrap.interact_prompt()
		if Input.is_action_just_pressed("interact"):
			_interact()
	elif idle_walk_radius > 0.0:
		position.x = origin_x + sin(_idle_time * 0.45) * idle_walk_radius
		sprite.flip_h = cos(_idle_time * 0.45) < 0


func _interact() -> void:
	var director := get_tree().get_first_node_in_group("dialogue_director") as DialogueDirector
	if director != null and director.start(dialogue_id, self):
		prompt.visible = false
		if player_inside != null:
			sprite.flip_h = player_inside.global_position.x < global_position.x


func on_dialogue_finished() -> void:
	if player_inside != null:
		prompt.visible = true


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		player_inside = body
		prompt.visible = true


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		prompt.visible = false


func _on_room_entered(active_room_id: StringName, _display_name: String) -> void:
	_refresh_room_visibility(active_room_id)


func _refresh_room_visibility(active_room_id: StringName) -> void:
	var active := room_id.is_empty() or room_id == active_room_id
	visible = active
	set_process(active)
	set_deferred("monitoring", active)
	if not active:
		player_inside = null
		if prompt != null:
			prompt.visible = false
