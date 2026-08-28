class_name FrontEndMenu
extends CanvasLayer

signal game_entered

enum Mode { HIDDEN, TITLE, PAUSE, SETTINGS, CONTROLS, CONFIRM_NEW_GAME }

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const PANEL_TEXTURE := preload("res://assets/ui/hud/status_panel.tres")
const MENU_BACKGROUND := preload("res://assets/ui/generated_0_4_2/fundo_menu_principal.png")
const GAME_LOGO := preload("res://assets/ui/generated_0_4_2/logo_cangaco_encantado.png")
const COMMAND_ATLAS := preload("res://assets/ui/generated_0_4_2/atlas_comandos.png")
const UI_THEME := preload("res://assets/ui/themes/cangaco_ui_theme.tres")
const MENU_BUTTON_SCENE := preload("res://scenes/ui/components/menu_button.tscn")

var mode := Mode.HIDDEN
var action_buttons: Dictionary = {}
var session_started := false

var _root: Control
var _background_fill: ColorRect
var _backdrop: TextureRect
var _dimmer: ColorRect
var _logo: TextureRect
var _frame: NinePatchRect
var _content: VBoxContainer
var _title: Label
var _subtitle: Label
var _submenu_origin := Mode.TITLE
var _controls_from_settings := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("front_end_menu")
	layer = 100
	_build_shell()
	_root.visible = false


func show_title(_initial := true) -> void:
	mode = Mode.TITLE
	_root.visible = true
	get_tree().paused = true
	_set_game_hud_visible(false)
	NotificationManager.set_suppressed(true)
	_set_title_art_visible(true)
	_set_standard_layout()
	_set_heading("", "UMA LENDA DO SERTÃO")
	_clear_content()
	_add_button(&"continue", "CONTINUAR", _continue_game, not session_started and not SaveManager.has_save())
	_add_button(&"new_game", "NOVO JOGO", _request_new_game)
	_add_button(&"settings", "OPÇÕES", _open_settings)
	_add_button(&"quit", "SAIR", _quit_game)
	_focus_first_available()
	_animate_open()


func show_pause() -> void:
	if mode != Mode.HIDDEN:
		return
	mode = Mode.PAUSE
	_root.visible = true
	get_tree().paused = true
	_set_game_hud_visible(true)
	NotificationManager.set_suppressed(true)
	_set_title_art_visible(false)
	_set_pause_layout()
	_set_heading("JOGO PAUSADO", "A LENDA ESPERA")
	_clear_content()
	_add_button(&"continue", "RETOMAR", enter_game)
	_add_button(&"map", "DIÁRIO / MAPA", _open_map)
	_add_button(&"settings", "OPÇÕES", _open_settings)
	_add_button(&"title", "MENU PRINCIPAL", _return_to_title)
	_add_button(&"quit", "SAIR", _quit_game)
	_focus_first_available()
	_animate_open()


func enter_game() -> void:
	mode = Mode.HIDDEN
	session_started = true
	_root.visible = false
	_set_game_hud_visible(true)
	NotificationManager.set_suppressed(false)
	get_tree().paused = false
	var viewport := get_viewport()
	if viewport.gui_get_focus_owner() != null:
		viewport.gui_get_focus_owner().release_focus()
	game_entered.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	get_viewport().set_input_as_handled()
	match mode:
		Mode.HIDDEN:
			show_pause()
		Mode.PAUSE:
			enter_game()
		Mode.SETTINGS, Mode.CONTROLS, Mode.CONFIRM_NEW_GAME:
			_return_from_submenu()
		Mode.TITLE:
			pass


func _build_shell() -> void:
	_root = Control.new()
	_root.name = "MenuRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.theme = UI_THEME
	add_child(_root)

	_background_fill = ColorRect.new()
	_background_fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background_fill.color = Color("17100d")
	_background_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_background_fill)

	_backdrop = TextureRect.new()
	_backdrop.name = "MenuBackground"
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.texture = MENU_BACKGROUND
	_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_backdrop)

	_dimmer = ColorRect.new()
	_dimmer.name = "Dimmer"
	_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dimmer.color = Color(0.035, 0.022, 0.018, 0.38)
	_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_dimmer)

	_logo = TextureRect.new()
	_logo.name = "GameLogo"
	_logo.position = Vector2(200.0, 5.0)
	_logo.size = Vector2(240.0, 135.0)
	_logo.texture = GAME_LOGO
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_logo)

	var top_glow := ColorRect.new()
	top_glow.position = Vector2(0.0, 0.0)
	top_glow.size = Vector2(640.0, 2.0)
	top_glow.color = Color("b97535")
	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(top_glow)

	_title = _make_label(_root, Vector2(188.0, 101.0), Vector2(264.0, 20.0), 18, Color("ffd47d"))
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle = _make_label(_root, Vector2(195.0, 123.0), Vector2(250.0, 10.0), 7, Color("d0a56a"))
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_frame = NinePatchRect.new()
	_frame.name = "MenuFrame"
	_frame.texture = PANEL_TEXTURE
	_frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_frame.patch_margin_left = 18
	_frame.patch_margin_top = 16
	_frame.patch_margin_right = 18
	_frame.patch_margin_bottom = 16
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_frame)

	_content = VBoxContainer.new()
	_content.name = "MenuContent"
	_content.add_theme_constant_override("separation", 2)
	_root.add_child(_content)
	_set_standard_layout()


func _set_standard_layout() -> void:
	_title.position = Vector2(188.0, 101.0)
	_subtitle.position = Vector2(195.0, 123.0)
	_content.add_theme_constant_override("separation", 2)
	_frame.position = Vector2(236.0, 136.0)
	_frame.size = Vector2(168.0, 126.0)
	_content.position = Vector2(252.0, 146.0)
	_content.size = Vector2(136.0, 106.0)


func _set_pause_layout() -> void:
	_title.position = Vector2(188.0, 101.0)
	_subtitle.position = Vector2(195.0, 123.0)
	_content.add_theme_constant_override("separation", 1)
	_frame.position = Vector2(236.0, 132.0)
	_frame.size = Vector2(168.0, 142.0)
	_content.position = Vector2(252.0, 142.0)
	_content.size = Vector2(136.0, 123.0)


func _set_wide_layout() -> void:
	_title.position = Vector2(188.0, 101.0)
	_subtitle.position = Vector2(195.0, 123.0)
	_content.add_theme_constant_override("separation", 3)
	_frame.position = Vector2(188.0, 132.0)
	_frame.size = Vector2(264.0, 132.0)
	_content.position = Vector2(203.0, 153.0)
	_content.size = Vector2(234.0, 98.0)


func _set_controls_layout() -> void:
	_title.position = Vector2(188.0, 43.0)
	_subtitle.position = Vector2(195.0, 63.0)
	_content.add_theme_constant_override("separation", 2)
	_frame.position = Vector2(188.0, 76.0)
	_frame.size = Vector2(264.0, 252.0)
	_content.position = Vector2(203.0, 86.0)
	_content.size = Vector2(234.0, 232.0)


func _set_settings_layout() -> void:
	_title.position = Vector2(188.0, 43.0)
	_subtitle.position = Vector2(195.0, 63.0)
	_content.add_theme_constant_override("separation", 2)
	_frame.position = Vector2(210.0, 76.0)
	_frame.size = Vector2(220.0, 252.0)
	_content.position = Vector2(226.0, 87.0)
	_content.size = Vector2(188.0, 230.0)


func _set_heading(title_text: String, subtitle_text: String) -> void:
	_title.text = title_text
	_subtitle.text = subtitle_text


func _clear_content() -> void:
	action_buttons.clear()
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()


func _add_button(id: StringName, text_value: String, callback: Callable, disabled := false) -> Button:
	var button := MENU_BUTTON_SCENE.instantiate() as Button
	button.name = String(id)
	button.text = text_value
	button.custom_minimum_size = Vector2(136.0, 15.0)
	button.focus_mode = Control.FOCUS_ALL
	button.disabled = disabled
	button.add_theme_font_override("font", PIXEL_FONT)
	button.add_theme_font_size_override("font_size", 8)
	button.add_theme_color_override("font_color", Color("f3d6a2"))
	button.add_theme_color_override("font_hover_color", Color("fff1bd"))
	button.add_theme_color_override("font_focus_color", Color("fff1bd"))
	button.add_theme_color_override("font_disabled_color", Color("6e6253"))
	button.add_theme_stylebox_override("normal", _button_style(Color("211815d9"), Color("70502e"), 1))
	button.add_theme_stylebox_override("hover", _button_style(Color("3a251ae8"), Color("d79543"), 1))
	button.add_theme_stylebox_override("pressed", _button_style(Color("5a321ee8"), Color("ffd47d"), 1))
	button.add_theme_stylebox_override("focus", _button_style(Color.TRANSPARENT, Color("ffd47d"), 2))
	button.add_theme_stylebox_override("disabled", _button_style(Color("171311c0"), Color("40372d"), 1))
	button.pressed.connect(callback)
	_content.add_child(button)
	action_buttons[id] = button
	return button


func _button_style(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 1
	style.corner_radius_top_right = 1
	style.corner_radius_bottom_left = 1
	style.corner_radius_bottom_right = 1
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	return style


func _make_label(parent: Control, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label


func _add_info_line(text_value: String, color := Color("e6c894"), font_size := 7) -> Label:
	var label := Label.new()
	label.text = text_value
	label.custom_minimum_size = Vector2(0.0, 8.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	_content.add_child(label)
	return label


func _focus_first_available() -> void:
	call_deferred("_grab_first_available")


func _grab_first_available() -> void:
	if not is_inside_tree() or not _root.visible:
		return
	for child in _content.get_children():
		if child is Button and not child.disabled and child.is_inside_tree():
			child.grab_focus()
			return


func _continue_game() -> void:
	enter_game()


func _request_new_game() -> void:
	if SaveManager.has_save() or session_started:
		_open_new_game_confirmation()
		return
	_start_new_game()


func _open_new_game_confirmation() -> void:
	_submenu_origin = Mode.PAUSE if session_started else Mode.TITLE
	mode = Mode.CONFIRM_NEW_GAME
	_set_standard_layout()
	_set_heading("APAGAR PROGRESSO?", "ESTA AÇÃO NÃO PODE SER DESFEITA")
	_clear_content()
	_add_info_line("O SAVE ATUAL SERÁ APAGADO.", Color("f0b27b"), 7)
	_add_info_line("DESEJA COMEÇAR UMA NOVA LENDA?", Color("dfc598"), 6)
	_add_button(&"confirm_new_game", "APAGAR E INICIAR", _start_new_game)
	_add_button(&"cancel", "CANCELAR", _return_from_submenu)
	_focus_first_available()


func _start_new_game() -> void:
	SaveManager.request_new_game()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _open_settings() -> void:
	if mode not in [Mode.SETTINGS, Mode.CONTROLS]:
		_submenu_origin = Mode.PAUSE if session_started else Mode.TITLE
	mode = Mode.SETTINGS
	_set_title_art_visible(_submenu_origin == Mode.TITLE)
	_set_settings_layout()
	_set_heading("OPÇÕES", "AJUSTES DA EXPERIÊNCIA")
	_build_settings_content()


func _build_settings_content() -> void:
	_clear_content()
	_add_button(&"volume", "VOLUME: %d%%" % int(round(SettingsManager.master_volume * 100.0)), _cycle_volume)
	_add_button(&"fullscreen", "TELA CHEIA: %s" % _yes_no(SettingsManager.fullscreen), _toggle_fullscreen)
	_add_button(&"resolution", "RESOLUÇÃO: %s" % SettingsManager.resolution_label(), _cycle_resolution)
	_add_button(&"vsync", "VSYNC: %s" % _yes_no(SettingsManager.vsync_enabled), _toggle_vsync)
	_add_button(&"screen_shake", "TREMOR: %s" % SettingsManager.screen_shake_label(), _cycle_screen_shake)
	_add_button(&"reduce_flashes", "REDUZIR FLASH: %s" % _yes_no(SettingsManager.reduce_flashes), _toggle_reduce_flashes)
	_add_button(&"vibration", "VIBRAÇÃO: %s" % _yes_no(SettingsManager.vibration_enabled), _toggle_vibration)
	_add_button(&"text_speed", "TEXTO: %s" % SettingsManager.text_speed_label(), _cycle_text_speed)
	_add_button(&"controls", "VER CONTROLES", _open_controls)
	_add_button(&"back", "VOLTAR", _return_from_submenu)
	_focus_first_available()


func _cycle_volume() -> void:
	var levels := [1.0, 0.75, 0.5, 0.25, 0.0]
	var closest_index := 0
	var closest_distance := INF
	for index in levels.size():
		var distance := absf(levels[index] - SettingsManager.master_volume)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = index
	SettingsManager.set_master_volume(levels[(closest_index + 1) % levels.size()])
	_build_settings_content()


func _toggle_fullscreen() -> void:
	SettingsManager.set_fullscreen(not SettingsManager.fullscreen)
	_build_settings_content()


func _cycle_screen_shake() -> void:
	SettingsManager.cycle_screen_shake_scale()
	_build_settings_content()


func _toggle_reduce_flashes() -> void:
	SettingsManager.set_reduce_flashes(not SettingsManager.reduce_flashes)
	_build_settings_content()


func _toggle_vibration() -> void:
	SettingsManager.set_vibration_enabled(not SettingsManager.vibration_enabled)
	_build_settings_content()


func _cycle_text_speed() -> void:
	SettingsManager.cycle_text_speed()
	_build_settings_content()


func _cycle_resolution() -> void:
	SettingsManager.cycle_resolution()
	_build_settings_content()


func _toggle_vsync() -> void:
	SettingsManager.set_vsync_enabled(not SettingsManager.vsync_enabled)
	_build_settings_content()


func _open_controls() -> void:
	_controls_from_settings = mode == Mode.SETTINGS
	if mode not in [Mode.SETTINGS, Mode.CONTROLS]:
		_submenu_origin = Mode.PAUSE if session_started else Mode.TITLE
	mode = Mode.CONTROLS
	_set_title_art_visible(false)
	_set_controls_layout()
	_set_heading("CONTROLES", "TECLADO E CONTROLE")
	_clear_content()
	var atlas_preview := TextureRect.new()
	atlas_preview.custom_minimum_size = Vector2(224.0, 168.0)
	atlas_preview.texture = COMMAND_ATLAS
	atlas_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	atlas_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	atlas_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	atlas_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(atlas_preview)
	_add_info_line("J FACÃO   K PISTOLA   L RIFLE   I ATAQUE ESPECIAL", Color("efd7aa"), 6)
	_add_info_line("Q CURA   E INTERAGIR   C INVESTIDA   M MAPA", Color("efd7aa"), 6)
	_add_info_line("ESC / START  PAUSAR E VOLTAR", Color("bda47b"), 6)
	_add_button(&"back", "VOLTAR", _return_from_submenu)
	_focus_first_available()


func _return_from_submenu() -> void:
	if mode == Mode.CONTROLS and _controls_from_settings:
		_controls_from_settings = false
		mode = Mode.SETTINGS
		_set_settings_layout()
		_set_heading("OPÇÕES", "AJUSTES DA EXPERIÊNCIA")
		_build_settings_content()
		return
	if _submenu_origin == Mode.PAUSE:
		mode = Mode.HIDDEN
		show_pause()
	else:
		show_title(false)


func _return_to_title() -> void:
	show_title(false)


func _open_map() -> void:
	enter_game()
	var map_ui := get_parent().get_node_or_null("WorldMap") as WorldMapUI
	if map_ui != null:
		map_ui.open_map(true)


func _quit_game() -> void:
	get_tree().quit()


func _yes_no(value: bool) -> String:
	return "SIM" if value else "NÃO"


func _set_game_hud_visible(value: bool) -> void:
	var hud := get_parent().get_node_or_null("HUD") as CanvasLayer
	if hud != null:
		hud.visible = value


func _set_title_art_visible(value: bool) -> void:
	_background_fill.visible = value
	_backdrop.visible = value
	_logo.visible = value
	_title.visible = not value
	_subtitle.visible = true
	_dimmer.color = Color(0.035, 0.022, 0.018, 0.38 if value else 0.82)


func _animate_open() -> void:
	_root.modulate.a = 0.0
	_frame.position.y = round(_frame.position.y + 3.0)
	_content.position.y = round(_content.position.y + 3.0)
	var target_y: float = roundf(_frame.position.y - 3.0)
	var target_content_y: float = roundf(_content.position.y - 3.0)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_root, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(_frame, "position:y", target_y, 0.12)
	tween.parallel().tween_property(_content, "position:y", target_content_y, 0.12)
