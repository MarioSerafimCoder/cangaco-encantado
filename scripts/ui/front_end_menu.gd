class_name FrontEndMenu
extends CanvasLayer

enum Mode { HIDDEN, TITLE, PAUSE, SETTINGS, CONTROLS, CONFIRM_NEW_GAME }

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const PANEL_TEXTURE := preload("res://assets/ui/hud/status_panel.tres")

var mode := Mode.HIDDEN
var action_buttons: Dictionary = {}
var session_started := false

var _root: Control
var _frame: NinePatchRect
var _content: VBoxContainer
var _title: Label
var _subtitle: Label
var _submenu_origin := Mode.TITLE


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
	_set_standard_layout()
	_set_heading("CANGAÇO ENCANTADO", "UMA LENDA DO SERTÃO")
	_clear_content()
	_add_button(&"continue", "CONTINUAR", _continue_game, not session_started and not SaveManager.has_save())
	_add_button(&"new_game", "NOVO JOGO", _request_new_game)
	_add_button(&"settings", "CONFIGURAÇÕES", _open_settings)
	_add_button(&"controls", "CONTROLES", _open_controls)
	_add_button(&"quit", "SAIR", _quit_game)
	_focus_first_available()


func show_pause() -> void:
	if mode != Mode.HIDDEN:
		return
	mode = Mode.PAUSE
	_root.visible = true
	get_tree().paused = true
	_set_game_hud_visible(true)
	_set_standard_layout()
	_set_heading("JOGO PAUSADO", "A LENDA ESPERA")
	_clear_content()
	_add_button(&"continue", "CONTINUAR", enter_game)
	_add_button(&"new_game", "NOVO JOGO", _request_new_game)
	_add_button(&"settings", "CONFIGURAÇÕES", _open_settings)
	_add_button(&"controls", "CONTROLES", _open_controls)
	_add_button(&"title", "MENU INICIAL", _return_to_title)
	_add_button(&"quit", "SAIR", _quit_game)
	_focus_first_available()


func enter_game() -> void:
	mode = Mode.HIDDEN
	session_started = true
	_root.visible = false
	_set_game_hud_visible(true)
	get_tree().paused = false
	var viewport := get_viewport()
	if viewport.gui_get_focus_owner() != null:
		viewport.gui_get_focus_owner().release_focus()


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
	add_child(_root)

	var dim := ColorRect.new()
	dim.name = "Dimmer"
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.035, 0.022, 0.018, 0.82)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var top_glow := ColorRect.new()
	top_glow.position = Vector2(0.0, 0.0)
	top_glow.size = Vector2(320.0, 2.0)
	top_glow.color = Color("b97535")
	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(top_glow)

	_title = _make_label(_root, Vector2(28.0, 11.0), Vector2(264.0, 20.0), 18, Color("ffd47d"))
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle = _make_label(_root, Vector2(35.0, 33.0), Vector2(250.0, 10.0), 7, Color("d0a56a"))
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
	_content.add_theme_constant_override("separation", 2)
	_frame.position = Vector2(76.0, 46.0)
	_frame.size = Vector2(168.0, 126.0)
	_content.position = Vector2(92.0, 56.0)
	_content.size = Vector2(136.0, 106.0)


func _set_wide_layout() -> void:
	_content.add_theme_constant_override("separation", 3)
	_frame.position = Vector2(28.0, 42.0)
	_frame.size = Vector2(264.0, 132.0)
	_content.position = Vector2(43.0, 63.0)
	_content.size = Vector2(234.0, 98.0)


func _set_heading(title_text: String, subtitle_text: String) -> void:
	_title.text = title_text
	_subtitle.text = subtitle_text


func _clear_content() -> void:
	action_buttons.clear()
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()


func _add_button(id: StringName, text_value: String, callback: Callable, disabled := false) -> Button:
	var button := Button.new()
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
	_submenu_origin = Mode.PAUSE if session_started else Mode.TITLE
	mode = Mode.SETTINGS
	_set_standard_layout()
	_set_heading("CONFIGURAÇÕES", "AJUSTES DA EXPERIÊNCIA")
	_build_settings_content()


func _build_settings_content() -> void:
	_clear_content()
	_add_button(&"volume", "VOLUME: %d%%" % int(round(SettingsManager.master_volume * 100.0)), _cycle_volume)
	_add_button(&"fullscreen", "TELA CHEIA: %s" % _yes_no(SettingsManager.fullscreen), _toggle_fullscreen)
	_add_button(&"screen_shake", "TREMOR DE CÂMERA: %s" % _yes_no(SettingsManager.screen_shake_enabled), _toggle_screen_shake)
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


func _toggle_screen_shake() -> void:
	SettingsManager.set_screen_shake_enabled(not SettingsManager.screen_shake_enabled)
	_build_settings_content()


func _open_controls() -> void:
	if mode not in [Mode.SETTINGS, Mode.CONTROLS]:
		_submenu_origin = Mode.PAUSE if session_started else Mode.TITLE
	mode = Mode.CONTROLS
	_set_wide_layout()
	_set_heading("CONTROLES", "TECLADO E CONTROLE")
	_clear_content()
	for line in [
		"A / D  MOVER E CORRER     J  FACÃO",
		"ESPAÇO  PULAR             K  PISTOLA",
		"CTRL  AGACHAR             L  RIFLE",
		"SHIFT + W / S  MIRAR      I  ATAQUE ESPECIAL",
		"Q  USAR CABAÇA            E  INTERAGIR",
		"C  INVESTIDA              M  MAPA",
		"ESC / START  PAUSAR E VOLTAR",
	]:
		_add_info_line(line, Color("efd7aa"), 6)
	_add_button(&"back", "VOLTAR", _return_from_submenu)
	_focus_first_available()


func _return_from_submenu() -> void:
	if _submenu_origin == Mode.PAUSE:
		mode = Mode.HIDDEN
		show_pause()
	else:
		show_title(false)


func _return_to_title() -> void:
	show_title(false)


func _quit_game() -> void:
	get_tree().quit()


func _yes_no(value: bool) -> String:
	return "SIM" if value else "NÃO"


func _set_game_hud_visible(value: bool) -> void:
	var hud := get_parent().get_node_or_null("HUD") as CanvasLayer
	if hud != null:
		hud.visible = value
