class_name WorldMapUI
extends CanvasLayer

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
enum Tab { MAP, ITEMS, ABILITIES, AMULETS }
const TAB_NAMES := ["MAPA", "ITENS", "HABILIDADES", "AMULETOS"]
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
var _tab := Tab.MAP


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
	elif _open and event.is_action_pressed("move_left"):
		get_viewport().set_input_as_handled()
		_change_tab(-1)
	elif _open and event.is_action_pressed("move_right"):
		get_viewport().set_input_as_handled()
		_change_tab(1)


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
	_tab = Tab.MAP
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


func _change_tab(direction: int) -> void:
	_tab = posmod(_tab + direction, TAB_NAMES.size())
	_canvas.queue_redraw()


func _draw_map(canvas: Control) -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO, canvas.size), Color(0.025, 0.018, 0.015, 0.92), true)
	canvas.draw_rect(Rect2(82, 34, 476, 292), Color("211713"), true)
	canvas.draw_rect(Rect2(82, 34, 476, 292), Color("b87936"), false, 2.0)
	canvas.draw_rect(Rect2(89, 41, 462, 278), Color(0.07, 0.045, 0.035, 0.82), false, 1.0)
	canvas.draw_string(PIXEL_FONT, Vector2(100, 53), "DIÁRIO DE NILO", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ffd681"))
	canvas.draw_string(PIXEL_FONT, Vector2(443, 51), "M / ESC  FECHAR", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("bda47b"))
	_draw_tabs(canvas)
	if _tab == Tab.ITEMS:
		_draw_items(canvas)
		return
	if _tab == Tab.ABILITIES:
		_draw_abilities(canvas)
		return
	if _tab == Tab.AMULETS:
		_draw_amulets(canvas)
		return
	canvas.draw_string(PIXEL_FONT, Vector2(182, 118), "VILA DO UMBUZEIRO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("ffd681"))
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


func _draw_tabs(canvas: Control) -> void:
	for index in TAB_NAMES.size():
		var rect := Rect2(101 + index * 109, 63, 102, 18)
		var active := index == _tab
		canvas.draw_rect(rect, Color("6a3f22") if active else Color("2b1d17"), true)
		canvas.draw_rect(rect, Color("e3b45f") if active else Color("6f5038"), false, 1.0)
		canvas.draw_string(PIXEL_FONT, rect.position + Vector2(0, 12), TAB_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8, Color("ffe09a") if active else Color("a99170"))
	canvas.draw_string(PIXEL_FONT, Vector2(230, 311), "A / D  TROCAR ABA", HORIZONTAL_ALIGNMENT_CENTER, 180, 7, Color("9d8769"))


func _draw_items(canvas: Control) -> void:
	_draw_section_title(canvas, "BOLSA E ITENS IMPORTANTES")
	canvas.draw_string(PIXEL_FONT, Vector2(112, 115), "MOEDAS DO SERTÃO", HORIZONTAL_ALIGNMENT_LEFT, 160, 9, Color("d9b35e"))
	canvas.draw_string(PIXEL_FONT, Vector2(282, 115), "◆ %d" % GameState.currency, HORIZONTAL_ALIGNMENT_LEFT, 90, 9, Color("ffe09a"))
	canvas.draw_string(PIXEL_FONT, Vector2(112, 137), "CARGAS DA CABAÇA", HORIZONTAL_ALIGNMENT_LEFT, 160, 9, Color("9dd8c7"))
	canvas.draw_string(PIXEL_FONT, Vector2(282, 137), "%d / 2" % GameState.heal_charges, HORIZONTAL_ALIGNMENT_LEFT, 90, 9, Color("c4efe0"))
	var line_y := 169.0
	for category in ["consumables", "important_items", "collectibles"]:
		var items: Dictionary = GameState.inventory.get(category, {})
		var keys := items.keys()
		keys.sort()
		for key in keys:
			if int(items[key]) <= 0:
				continue
			canvas.draw_string(PIXEL_FONT, Vector2(112, line_y), "• %s" % _display_item_name(String(key)), HORIZONTAL_ALIGNMENT_LEFT, 260, 8, Color("e1cfaa"))
			canvas.draw_string(PIXEL_FONT, Vector2(390, line_y), "x%d" % int(items[key]), HORIZONTAL_ALIGNMENT_LEFT, 50, 8, Color("d9b35e"))
			line_y += 16.0
	if line_y <= 169.0:
		canvas.draw_string(PIXEL_FONT, Vector2(112, 177), "A bolsa ainda está vazia.", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("806e5c"))


func _draw_abilities(canvas: Control) -> void:
	_draw_section_title(canvas, "HABILIDADES DE TRAVESSIA")
	_draw_ability_row(canvas, 119, "PASSO DA PEDRA", "QUIQUE NAS PAREDES", bool(GameState.abilities.get("wall_jump", false)))
	_draw_ability_row(canvas, 158, "PASSO DA POEIRA", "INVESTIDA COM C", bool(GameState.abilities.get("dash", false)))
	_draw_ability_row(canvas, 197, "SALTO DUPLO", "SEGREDO NÃO DESCOBERTO", bool(GameState.abilities.get("double_jump", false)))
	_draw_ability_row(canvas, 236, "PASSO ESPECTRAL", "SEGREDO NÃO DESCOBERTO", bool(GameState.abilities.get("spectral_dash", false)))
	canvas.draw_string(PIXEL_FONT, Vector2(112, 284), "MELHORIAS PERMANENTES: %d" % GameState.permanent_upgrades.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d9b35e"))


func _draw_ability_row(canvas: Control, y: float, title: String, description: String, unlocked: bool) -> void:
	var rect := Rect2(108, y - 17, 420, 33)
	canvas.draw_rect(rect, Color("34241b") if unlocked else Color("1c1714"), true)
	canvas.draw_rect(rect, Color("b87936") if unlocked else Color("4c4037"), false, 1.0)
	canvas.draw_string(PIXEL_FONT, Vector2(119, y - 2), ("◆ " if unlocked else "◇ ") + title, HORIZONTAL_ALIGNMENT_LEFT, 190, 9, Color("ffe09a") if unlocked else Color("72685f"))
	canvas.draw_string(PIXEL_FONT, Vector2(315, y - 2), description if unlocked else "BLOQUEADA", HORIZONTAL_ALIGNMENT_LEFT, 200, 7, Color("9dd8c7") if unlocked else Color("635b54"))


func _draw_amulets(canvas: Control) -> void:
	_draw_section_title(canvas, "AMULETOS E RELÍQUIAS")
	var medal_owned := GameState.inventory_amount(&"important_items", &"medalha_antiga") > 0 or bool(GameState.purchased_items.get("medalha_antiga", false))
	_draw_amulet_slot(canvas, Rect2(110, 112, 130, 116), "MEDALHA\nANTIGA", medal_owned)
	_draw_amulet_slot(canvas, Rect2(255, 112, 130, 116), "ESPAÇO\nVAZIO", false)
	_draw_amulet_slot(canvas, Rect2(400, 112, 130, 116), "ESPAÇO\nVAZIO", false)
	canvas.draw_string(PIXEL_FONT, Vector2(114, 254), "Relíquias alteram atributos e abrem novas combinações.", HORIZONTAL_ALIGNMENT_LEFT, 410, 8, Color("a99170"))
	canvas.draw_string(PIXEL_FONT, Vector2(114, 274), "Relatos encontrados: %d" % GameState.inventory.get("collectibles", {}).size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d9b35e"))


func _draw_amulet_slot(canvas: Control, rect: Rect2, label: String, owned: bool) -> void:
	canvas.draw_rect(rect, Color("39271c") if owned else Color("181411"), true)
	canvas.draw_rect(rect, Color("d29a49") if owned else Color("4b4138"), false, 2.0)
	canvas.draw_circle(rect.position + Vector2(rect.size.x * 0.5, 38), 18.0, Color("ad6f2d") if owned else Color("302923"), true)
	canvas.draw_circle(rect.position + Vector2(rect.size.x * 0.5, 38), 18.0, Color("ffe09a") if owned else Color("5b5047"), false, 2.0)
	canvas.draw_string(PIXEL_FONT, rect.position + Vector2(0, 78), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8, Color("ffe09a") if owned else Color("6c6259"))


func _draw_section_title(canvas: Control, text: String) -> void:
	canvas.draw_string(PIXEL_FONT, Vector2(108, 97), text, HORIZONTAL_ALIGNMENT_LEFT, 420, 11, Color("dfbd82"))
	canvas.draw_line(Vector2(108, 101), Vector2(530, 101), Color("6f5038"), 1.0)


func _display_item_name(item_id: String) -> String:
	return item_id.replace("_", " ").to_upper()


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
