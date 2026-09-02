class_name DialogueDirector
extends CanvasLayer

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const UI_ATLAS := preload("res://assets/sprites/usados/interface/dialogo_loja/dialogo_loja_atlas.png")
const TOP_ORNAMENT := Rect2(178, 30, 900, 260)
const BOTTOM_ORNAMENT := Rect2(395, 304, 575, 145)
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/components/dialogue_box.tscn")

@export_range(20.0, 70.0) var characters_per_second := 38.0

var active := false
var dialogue_id: StringName
var speaker_npc: NPCActor
var lines: Array = []
var line_index := 0
var _elapsed := 0.0
var _root: Control
var _overlay: ColorRect
var _panel: Panel
var _name_label: Label
var _text_label: Label
var _continue_label: Label
var _choice_box: VBoxContainer
var _shop_ui: ShopUI


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	_build_ui()
	_root.visible = false
	_shop_ui = ShopUI.new()
	add_child(_shop_ui)


func start(dialogue_key: StringName, npc: NPCActor = null) -> bool:
	if active or _shop_ui.is_open:
		return false
	var selected := DialogueDatabase.get_conversation(dialogue_key)
	if selected.is_empty():
		return false
	active = true
	characters_per_second = SettingsManager.text_characters_per_second()
	dialogue_id = dialogue_key
	speaker_npc = npc
	lines = selected
	line_index = 0
	_root.visible = true
	NotificationManager.set_suppressed(true)
	_lock_world(true)
	_show_line()
	EventBus.dialogue_started.emit(dialogue_id, speaker_npc)
	return true


func _process(delta: float) -> void:
	if not active:
		return
	_continue_label.text = InputGlyphResolver.prompt(&"interact", "CONTINUAR")
	_continue_label.position.y = 91.0 + round(sin(Time.get_ticks_msec() * 0.006) * 1.0)
	if _text_label.visible_characters >= _text_label.text.length():
		_continue_label.visible = _choice_box.get_child_count() == 0
		return
	_elapsed += delta * characters_per_second
	_text_label.visible_characters = mini(_text_label.text.length(), int(_elapsed))


func _unhandled_input(event: InputEvent) -> void:
	if not active or _shop_ui.is_open:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		return
	if not (event.is_action_pressed("interact") or event.is_action_pressed("jump")):
		return
	get_viewport().set_input_as_handled()
	if _text_label.visible_characters < _text_label.text.length():
		_text_label.visible_characters = _text_label.text.length()
		return
	if _choice_box.get_child_count() == 0:
		_advance()


func _show_line() -> void:
	_clear_choices()
	var line: Dictionary = lines[line_index]
	_name_label.text = String(line.get("speaker", speaker_npc.display_name if speaker_npc != null else ""))
	_text_label.text = String(line.get("text", ""))
	_text_label.visible_characters = 0
	_elapsed = 0.0
	_continue_label.visible = false
	var choices: Array = line.get("choices", [])
	if not choices.is_empty():
		_text_label.visible_characters = _text_label.text.length()
		_text_label.size.y = 31.0
		_choice_box.visible = true
		_build_choices(choices)
	else:
		_text_label.size.y = 60.0
		_choice_box.visible = false


func _advance() -> void:
	var line: Dictionary = lines[line_index]
	_apply_events(line.get("events", []))
	line_index += 1
	if line_index >= lines.size():
		_finish()
	else:
		_show_line()


func _finish() -> void:
	var finished_id := dialogue_id
	var finished_npc := speaker_npc
	active = false
	_root.visible = false
	NotificationManager.set_suppressed(false)
	_lock_world(false)
	if finished_npc != null:
		finished_npc.on_dialogue_finished()
	EventBus.dialogue_finished.emit(finished_id, finished_npc)


func _apply_events(events: Array) -> void:
	for event_data in events:
		match String(event_data.get("type", "")):
			"world_flag":
				WorldState.set_flag(StringName(event_data.get("id", "")), bool(event_data.get("value", true)))
			"dialogue_flag":
				GameState.set_dialogue_flag(StringName(event_data.get("id", "")), bool(event_data.get("value", true)))
			"give_item":
				GameState.add_inventory_item(StringName(event_data.get("category", "important_items")), StringName(event_data.get("id", "")), int(event_data.get("amount", 1)))
			"open_shop":
				_root.visible = false
				_shop_ui.open(StringName(event_data.get("shop_id", "mercador_vila")), Callable(self, "_return_from_shop"))
			"complete_area01":
				WorldState.complete_area01_discovery()


func _build_choices(choices: Array) -> void:
	for choice in choices:
		var button := Button.new()
		button.text = String(choice.get("text", "CONTINUAR"))
		button.custom_minimum_size = Vector2(252, 17)
		button.add_theme_font_override("font", PIXEL_FONT)
		button.add_theme_font_size_override("font_size", 8)
		_apply_choice_button_theme(button)
		button.pressed.connect(_on_choice.bind(choice))
		_choice_box.add_child(button)
	if _choice_box.get_child_count() > 0:
		(_choice_box.get_child(0) as Button).grab_focus.call_deferred()


func _on_choice(choice: Dictionary) -> void:
	_apply_events(choice.get("events", []))
	var next_index := int(choice.get("next_index", line_index + 1))
	if next_index >= lines.size():
		_finish()
	else:
		line_index = next_index
		_show_line()


func _return_from_shop() -> void:
	_root.visible = true
	_finish()


func _lock_world(value: bool) -> void:
	var player := get_tree().get_first_node_in_group("player") as NiloPlayer
	if player != null:
		player.narrative_locked = value
		player.velocity = Vector2.ZERO
		if value and speaker_npc != null:
			player.facing = signf(speaker_npc.global_position.x - player.global_position.x)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
	var hud := get_tree().get_first_node_in_group("game_hud") as CanvasItem
	if hud != null:
		hud.modulate.a = 0.35 if value else 1.0


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.02, 0.015, 0.012, 0.16)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_overlay)
	_panel = DIALOGUE_BOX_SCENE.instantiate()
	_root.add_child(_panel)
	var top := Sprite2D.new()
	var top_texture := AtlasTexture.new()
	top_texture.atlas = UI_ATLAS
	top_texture.region = TOP_ORNAMENT
	top.texture = top_texture
	top.position = Vector2(240, 4)
	top.scale = Vector2(184.0 / TOP_ORNAMENT.size.x, 50.0 / TOP_ORNAMENT.size.y)
	top.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.add_child(top)
	_name_label = _panel.get_node("Speaker") as Label
	_text_label = _panel.get_node("Text") as Label
	_continue_label = _panel.get_node("Continue") as Label
	_choice_box = _panel.get_node("Choices") as VBoxContainer
	_continue_label.text = InputGlyphResolver.prompt(&"interact", "CONTINUAR")


func _apply_choice_button_theme(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("e9dcc5"))
	button.add_theme_color_override("font_hover_color", Color("fff0c7"))
	button.add_theme_color_override("font_focus_color", Color("fff0c7"))
	button.add_theme_color_override("font_pressed_color", Color("1d130d"))
	button.add_theme_stylebox_override("normal", _button_style(Color("241a13dc"), Color("6e5337"), 1))
	button.add_theme_stylebox_override("hover", _button_style(Color("3a291ce8"), Color("b6864c"), 1))
	button.add_theme_stylebox_override("focus", _button_style(Color("3a291cf2"), Color("e1aa59"), 2))
	button.add_theme_stylebox_override("pressed", _button_style(Color("d5a45d"), Color("f0ce8e"), 1))


func _button_style(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	return style


func _clear_choices() -> void:
	for child in _choice_box.get_children():
		_choice_box.remove_child(child)
		child.queue_free()
