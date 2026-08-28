class_name WorldMapUI
extends CanvasLayer

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const ROOM_LAYOUT := {
	&"casa_nilo": Vector2i(0, 1),
	&"rua_cinzas": Vector2i(1, 1),
	&"barracos": Vector2i(2, 1),
	&"praca_umbu": Vector2i(3, 1),
	&"igreja_velha": Vector2i(4, 1),
	&"telhados": Vector2i(4, 0),
	&"armazem": Vector2i(4, 2),
	&"patio": Vector2i(5, 2),
	&"beco": Vector2i(6, 2),
	&"poco": Vector2i(6, 3),
	&"barricada": Vector2i(7, 2),
	&"posto": Vector2i(7, 3),
	&"arena": Vector2i(8, 3),
}
const ROOM_NAMES := {
	&"casa_nilo": "CASA",
	&"rua_cinzas": "RUA",
	&"igreja_velha": "IGREJA",
	&"telhados": "TELHADOS",
	&"praca_umbu": "PRAÇA",
	&"barracos": "VILA BAIXA",
	&"armazem": "CRIPTA",
	&"patio": "SUBSOLO",
	&"beco": "GRUTAS",
	&"poco": "POÇO",
	&"barricada": "CAV. RASA",
	&"posto": "CAV. FUNDA",
	&"arena": "SANTUÁRIO",
}
const CONNECTIONS := [
	[&"casa_nilo", &"rua_cinzas", &""], [&"rua_cinzas", &"barracos", &""],
	[&"barracos", &"praca_umbu", &""], [&"praca_umbu", &"igreja_velha", &""],
	[&"igreja_velha", &"telhados", &"wall_jump"], [&"igreja_velha", &"armazem", &""],
	[&"armazem", &"patio", &""], [&"patio", &"beco", &""],
	[&"beco", &"poco", &"wall_jump"], [&"beco", &"barricada", &""],
	[&"barricada", &"posto", &""], [&"posto", &"arena", &""],
	[&"praca_umbu", &"armazem", &"dash"], [&"igreja_velha", &"poco", &"wall_jump"],
]

var _root: Control
var _canvas: MapCanvas
var _open := false
var _toast: Label
var _toast_tween: Tween


class MapCanvas extends Control:
	var map_ui: WorldMapUI

	func _draw() -> void:
		map_ui._draw_map(self)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	_canvas = MapCanvas.new()
	_canvas.map_ui = self
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_canvas)
	_root.visible = false
	_build_toast()
	EventBus.room_entered.connect(_on_progress_changed)
	EventBus.shortcut_opened.connect(_on_progress_changed_one)
	EventBus.ability_unlocked.connect(_on_progress_changed_two)
	EventBus.secret_discovered.connect(_on_progress_changed_one)
	EventBus.permanent_upgrade_collected.connect(_on_upgrade_collected)
	EventBus.lore_collectible_found.connect(_on_lore_collectible_found)


func _build_toast() -> void:
	_toast = Label.new()
	_toast.position = Vector2(230, 104)
	_toast.size = Vector2(180, 30)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_theme_font_override("font", PIXEL_FONT)
	_toast.add_theme_font_size_override("font_size", 8)
	_toast.add_theme_color_override("font_color", Color("ffe09a"))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.045, 0.035, 0.94)
	style.border_color = Color("b87936")
	style.set_border_width_all(1)
	_toast.add_theme_stylebox_override("normal", style)
	_toast.visible = false
	add_child(_toast)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map") and (_open or _front_end_hidden()):
		get_viewport().set_input_as_handled()
		_toggle()
	elif _open and event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_close()


func _toggle() -> void:
	if _open:
		_close()
	else:
		_open = true
		_root.visible = true
		get_tree().paused = true
		_canvas.queue_redraw()


func open_map() -> void:
	if _open:
		return
	_open = true
	_root.visible = true
	get_tree().paused = true
	_canvas.queue_redraw()


func _close() -> void:
	_open = false
	_root.visible = false
	get_tree().paused = false


func _front_end_hidden() -> bool:
	var menu := get_tree().get_first_node_in_group("front_end_menu") as FrontEndMenu
	return menu == null or menu.mode == FrontEndMenu.Mode.HIDDEN


func _draw_map(canvas: Control) -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO, canvas.size), Color(0.025, 0.018, 0.015, 0.92), true)
	canvas.draw_rect(Rect2(173, 103, 294, 154), Color("211713"), true)
	canvas.draw_rect(Rect2(173, 103, 294, 154), Color("b87936"), false, 2.0)
	canvas.draw_string(PIXEL_FONT, Vector2(182, 118), "MAPA DA VILA DO UMBUZEIRO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffd681"))
	canvas.draw_string(PIXEL_FONT, Vector2(182, 130), "M / ESC  FECHAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("bda47b"))
	var origin := Vector2(183, 133)
	var step := Vector2(27, 27)
	for connection in CONNECTIONS:
		var a: StringName = connection[0]
		var b: StringName = connection[1]
		if not _is_connection_known(a, b):
			continue
		var a_pos := origin + Vector2(ROOM_LAYOUT[a]) * step + Vector2(9, 7)
		var b_pos := origin + Vector2(ROOM_LAYOUT[b]) * step + Vector2(9, 7)
		var required: StringName = connection[2]
		var unlocked := required.is_empty() or bool(GameState.abilities.get(String(required), false))
		canvas.draw_line(a_pos, b_pos, Color("a8753c") if unlocked else Color("713b36"), 2.0 if unlocked else 1.0)
		if not unlocked:
			canvas.draw_circle((a_pos + b_pos) * 0.5, 2.5, Color("d65345"), true)
	for room_id in ROOM_LAYOUT:
		_draw_room(canvas, room_id, origin + Vector2(ROOM_LAYOUT[room_id]) * step)
	_draw_legend(canvas)


func _draw_room(canvas: Control, room_id: StringName, position: Vector2) -> void:
	var visited := bool(GameState.visited_rooms.get(String(room_id), false))
	var current := GameState.current_room_id == room_id
	var rect := Rect2(position, Vector2(18, 14))
	var fill := Color("77502d") if visited else Color("342822")
	if current:
		fill = Color("d4983f")
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, Color("ffe09a") if current else Color("8a6846"), false, 1.0)
	if visited:
		canvas.draw_string(PIXEL_FONT, position + Vector2(1, -2), ROOM_NAMES[room_id], HORIZONTAL_ALIGNMENT_CENTER, 18, 5, Color("ead5a7"))
	if current:
		canvas.draw_colored_polygon(PackedVector2Array([position + Vector2(7,-5), position + Vector2(11,-5), position + Vector2(9,-1)]), Color("fff1a6"))


func _draw_legend(canvas: Control) -> void:
	var abilities_text := "HABILIDADES: "
	abilities_text += "PEDRA ✓  " if GameState.abilities.get("wall_jump", false) else "PEDRA ?  "
	abilities_text += "POEIRA ✓" if GameState.abilities.get("dash", false) else "POEIRA ?"
	canvas.draw_string(PIXEL_FONT, Vector2(182, 245), abilities_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("8bd6bf"))
	canvas.draw_string(PIXEL_FONT, Vector2(350, 245), "◆ SEGREDOS %d" % GameState.discovered_secrets.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d9b35e"))


func _is_connection_known(a: StringName, b: StringName) -> bool:
	return GameState.visited_rooms.has(String(a)) or GameState.visited_rooms.has(String(b))


func _on_progress_changed(_room_id: StringName, _display_name: String) -> void:
	_canvas.queue_redraw()


func _on_progress_changed_one(_id: StringName) -> void:
	_canvas.queue_redraw()


func _on_progress_changed_two(_id: StringName, _display_name: String) -> void:
	_canvas.queue_redraw()
	var command := "C: INVESTIDA" if _id == &"dash" else "ESPAÇO JUNTO À PAREDE"
	_show_toast("NOVA HABILIDADE: %s\n%s" % [_display_name, command])


func _on_upgrade_collected(_id: StringName, display_name: String) -> void:
	_canvas.queue_redraw()
	_show_toast("MELHORIA PERMANENTE\n%s: VIDA MÁXIMA +1" % display_name)


func _on_lore_collectible_found(_id: StringName, display_name: String) -> void:
	_canvas.queue_redraw()
	_show_toast("RELATO ENCONTRADO\n%s" % display_name)


func _show_toast(message: String) -> void:
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast.text = message
	_toast.modulate = Color(1, 1, 1, 0)
	_toast.visible = true
	_toast_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.15)
	_toast_tween.tween_interval(2.2)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.3)
	_toast_tween.tween_callback(func(): _toast.visible = false)
