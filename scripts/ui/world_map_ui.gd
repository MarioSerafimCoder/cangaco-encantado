class_name WorldMapUI
extends CanvasLayer

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const SHOP_ICON_ATLAS := preload("res://assets/sprites/usados/interface/menu_diario/atlas_itens_loja.png")
const PROGRESSION_ATLAS := preload("res://assets/sprites/usados/interface/menu_diario/atlas_progressao.png")
const MAP_ICON_ATLAS := preload("res://assets/sprites/usados/interface/menu_diario/atlas_mapa_13_areas.png")
const SHOP_ICON_CELL := Vector2(418.0, 627.0)
const PROGRESSION_CELL := Vector2(313.5, 418.0)
const MAP_ICON_CELL := Vector2(313.5, 313.5)
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
const ROOM_ICON_INDEX := {
	&"casa_nilo": 0, &"rua_cinzas": 1, &"barracos": 2,
	&"praca_umbu": 3, &"igreja_velha": 4, &"telhados": 5,
	&"armazem": 6, &"patio": 7, &"beco": 8, &"poco": 9,
	&"barricada": 10, &"posto": 11, &"arena": 12,
}
const ITEM_ICON_INDEX := {
	"carga_cabaca": 0, "municao_pistola": 1, "municao_rifle": 2,
	"mapa_vila": 3, "medalha_antiga": 4,
}
const ITEM_DISPLAY := {
	"carga_cabaca": {"name": "CARGA DE CABAÇA", "description": "Recupera uma carga de cura.", "category": "CONSUMÍVEL"},
	"municao_pistola": {"name": "MUNIÇÃO DE PISTOLA", "description": "Reabastece a pistola.", "category": "CONSUMÍVEL"},
	"municao_rifle": {"name": "CARTUCHOS DE RIFLE", "description": "Reabastece o rifle.", "category": "CONSUMÍVEL"},
	"mapa_vila": {"name": "FOLHETO DA VILA", "description": "Registra os setores conhecidos.", "category": "ITEM IMPORTANTE"},
	"medalha_antiga": {"name": "MEDALHA ANTIGA", "description": "Relíquia ligada à história da Vila.", "category": "RELÍQUIA"},
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
var _tab := Tab.MAP
var _opened_from_pause := false
var _selected_room: StringName = &"casa_nilo"


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
	EventBus.room_entered.connect(_on_progress_changed)
	EventBus.shortcut_opened.connect(_on_progress_changed_one)
	EventBus.ability_unlocked.connect(_on_progress_changed_two)
	EventBus.secret_discovered.connect(_on_progress_changed_one)
	EventBus.permanent_upgrade_collected.connect(_on_upgrade_collected)
	EventBus.lore_collectible_found.connect(_on_lore_collectible_found)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map") and (_open or _front_end_hidden()):
		get_viewport().set_input_as_handled()
		_toggle()
	elif _open and (event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		_close()
	elif _open and ((InputBootstrap.last_input_was_gamepad and event.is_action_pressed("special_attack")) or (not InputBootstrap.last_input_was_gamepad and event.is_action_pressed("heal"))):
		get_viewport().set_input_as_handled()
		_change_tab(-1)
	elif _open and ((InputBootstrap.last_input_was_gamepad and event.is_action_pressed("shoot_rifle")) or (not InputBootstrap.last_input_was_gamepad and event.is_action_pressed("interact"))):
		get_viewport().set_input_as_handled()
		_change_tab(1)
	elif _open and _tab == Tab.MAP and event.is_action_pressed("move_left"):
		get_viewport().set_input_as_handled()
		_move_room_selection(Vector2i.LEFT)
	elif _open and _tab == Tab.MAP and event.is_action_pressed("move_right"):
		get_viewport().set_input_as_handled()
		_move_room_selection(Vector2i.RIGHT)
	elif _open and _tab == Tab.MAP and event.is_action_pressed("move_up"):
		get_viewport().set_input_as_handled()
		_move_room_selection(Vector2i.UP)
	elif _open and _tab == Tab.MAP and event.is_action_pressed("move_down"):
		get_viewport().set_input_as_handled()
		_move_room_selection(Vector2i.DOWN)


func _toggle() -> void:
	if _open:
		_close()
	else:
		_open = true
		_opened_from_pause = false
		_selected_room = GameState.current_room_id
		_root.visible = true
		NotificationManager.set_suppressed(true)
		get_tree().paused = true
		_canvas.queue_redraw()


func open_map(opened_from_pause := false) -> void:
	if _open:
		return
	_tab = Tab.MAP
	_opened_from_pause = opened_from_pause
	_selected_room = GameState.current_room_id
	_open = true
	_root.visible = true
	NotificationManager.set_suppressed(true)
	get_tree().paused = true
	_canvas.queue_redraw()


func _close() -> void:
	_open = false
	_root.visible = false
	NotificationManager.set_suppressed(false)
	if _opened_from_pause:
		_opened_from_pause = false
		var menu := get_tree().get_first_node_in_group("front_end_menu") as FrontEndMenu
		if menu != null:
			menu.show_pause()
			return
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
	canvas.draw_string(PIXEL_FONT, Vector2(430, 51), "%s FECHAR" % InputGlyphResolver.label_for_action(&"pause"), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("bda47b"))
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
	var origin := Vector2(116, 133)
	var step := Vector2(27, 27)
	for connection in CONNECTIONS:
		var a: StringName = connection[0]
		var b: StringName = connection[1]
		if not _is_connection_known(a, b):
			continue
		var a_pos := origin + Vector2(ROOM_LAYOUT[a]) * step + Vector2(11, 11)
		var b_pos := origin + Vector2(ROOM_LAYOUT[b]) * step + Vector2(11, 11)
		var required: StringName = connection[2]
		var unlocked := required.is_empty() or bool(GameState.abilities.get(String(required), false))
		canvas.draw_line(a_pos, b_pos, Color("a8753c") if unlocked else Color("713b36"), 2.0 if unlocked else 1.0)
		if not unlocked:
			canvas.draw_circle((a_pos + b_pos) * 0.5, 2.5, Color("d65345"), true)
	for room_id in ROOM_LAYOUT:
		_draw_room(canvas, room_id, origin + Vector2(ROOM_LAYOUT[room_id]) * step)
	_draw_room_details(canvas)
	_draw_legend(canvas)


func _draw_tabs(canvas: Control) -> void:
	for index in TAB_NAMES.size():
		var rect := Rect2(101 + index * 109, 63, 102, 18)
		var active := index == _tab
		canvas.draw_rect(rect, Color("6a3f22") if active else Color("2b1d17"), true)
		canvas.draw_rect(rect, Color("e3b45f") if active else Color("6f5038"), false, 1.0)
		canvas.draw_string(PIXEL_FONT, rect.position + Vector2(0, 12), TAB_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8, Color("ffe09a") if active else Color("a99170"))
	canvas.draw_string(PIXEL_FONT, Vector2(192, 311), "Q / E  ou  LB / RB  TROCAR ABA", HORIZONTAL_ALIGNMENT_CENTER, 256, 7, Color("9d8769"))


func _draw_items(canvas: Control) -> void:
	_draw_section_title(canvas, "BOLSA E ITENS IMPORTANTES")
	_draw_atlas_icon(canvas, SHOP_ICON_ATLAS, Rect2(110, 106, 27, 27), _atlas_region(0, 3, SHOP_ICON_CELL))
	canvas.draw_string(PIXEL_FONT, Vector2(143, 119), "CARGAS DA CABAÇA", HORIZONTAL_ALIGNMENT_LEFT, 145, 9, Color("9dd8c7"))
	canvas.draw_string(PIXEL_FONT, Vector2(292, 119), "%d / 2" % GameState.heal_charges, HORIZONTAL_ALIGNMENT_LEFT, 60, 9, Color("c4efe0"))
	canvas.draw_string(PIXEL_FONT, Vector2(373, 119), "MOEDAS  ◆ %d" % GameState.currency, HORIZONTAL_ALIGNMENT_LEFT, 145, 9, Color("ffe09a"))
	var line_y := 169.0
	for category in ["consumables", "important_items", "collectibles"]:
		var items: Dictionary = GameState.inventory.get(category, {})
		var keys := items.keys()
		keys.sort()
		for key in keys:
			if int(items[key]) <= 0:
				continue
			var item_index := int(ITEM_ICON_INDEX.get(String(key), 0))
			_draw_atlas_icon(canvas, SHOP_ICON_ATLAS, Rect2(112, line_y - 14, 18, 18), _atlas_region(item_index, 3, SHOP_ICON_CELL))
			var display: Dictionary = ITEM_DISPLAY.get(String(key), {})
			canvas.draw_string(PIXEL_FONT, Vector2(136, line_y), _display_item_name(String(key)), HORIZONTAL_ALIGNMENT_LEFT, 250, 8, Color("e1cfaa"))
			canvas.draw_string(PIXEL_FONT, Vector2(390, line_y), "x%d" % int(items[key]), HORIZONTAL_ALIGNMENT_LEFT, 50, 8, Color("d9b35e"))
			canvas.draw_string(PIXEL_FONT, Vector2(136, line_y + 10), "%s — %s" % [display.get("category", "ITEM"), display.get("description", "")], HORIZONTAL_ALIGNMENT_LEFT, 360, 6, Color("8f7d65"))
			line_y += 28.0
	if line_y <= 169.0:
		canvas.draw_string(PIXEL_FONT, Vector2(112, 177), "A bolsa ainda está vazia.", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("806e5c"))


func _draw_abilities(canvas: Control) -> void:
	_draw_section_title(canvas, "HABILIDADES DE TRAVESSIA")
	_draw_ability_row(canvas, 119, 0, "PASSO DA PEDRA", "QUIQUE NAS PAREDES", bool(GameState.abilities.get("wall_jump", false)))
	_draw_ability_row(canvas, 158, 1, "PASSO DA POEIRA", "INVESTIDA COM C", bool(GameState.abilities.get("dash", false)))
	_draw_ability_row(canvas, 197, 2, "SALTO DUPLO", "SEGREDO NÃO DESCOBERTO", bool(GameState.abilities.get("double_jump", false)))
	_draw_ability_row(canvas, 236, 3, "PASSO ESPECTRAL", "SEGREDO NÃO DESCOBERTO", bool(GameState.abilities.get("spectral_dash", false)))
	canvas.draw_string(PIXEL_FONT, Vector2(112, 284), "MELHORIAS PERMANENTES: %d" % GameState.permanent_upgrades.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d9b35e"))
	for index in 4:
		var owned := index == 0 and GameState.permanent_upgrades.size() > 0
		var slot := Rect2(408 + index * 28, 264, 23, 23)
		canvas.draw_rect(slot, Color("271e19"), true)
		canvas.draw_rect(slot, Color("8b663e") if owned else Color("4b4138"), false, 1.0)
		if owned:
			_draw_atlas_icon(canvas, PROGRESSION_ATLAS, slot, _atlas_region(8 + index, 4, PROGRESSION_CELL))
		else:
			canvas.draw_string(PIXEL_FONT, slot.position + Vector2(0, 16), "?", HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, 10, Color("6c6259"))


func _draw_ability_row(canvas: Control, y: float, icon_index: int, title: String, description: String, unlocked: bool) -> void:
	var rect := Rect2(108, y - 17, 420, 33)
	canvas.draw_rect(rect, Color("34241b") if unlocked else Color("1c1714"), true)
	canvas.draw_rect(rect, Color("b87936") if unlocked else Color("4c4037"), false, 1.0)
	var icon_rect := Rect2(112, y - 14, 27, 27)
	if unlocked:
		_draw_atlas_icon(canvas, PROGRESSION_ATLAS, icon_rect, _atlas_region(icon_index, 4, PROGRESSION_CELL))
	else:
		canvas.draw_rect(icon_rect, Color("302923"), true)
		canvas.draw_string(PIXEL_FONT, icon_rect.position + Vector2(0, 19), "?", HORIZONTAL_ALIGNMENT_CENTER, icon_rect.size.x, 12, Color("6c6259"))
	canvas.draw_string(PIXEL_FONT, Vector2(146, y - 2), title if unlocked else "???", HORIZONTAL_ALIGNMENT_LEFT, 170, 9, Color("ffe09a") if unlocked else Color("72685f"))
	canvas.draw_string(PIXEL_FONT, Vector2(322, y - 2), description if unlocked else "HABILIDADE NÃO DESCOBERTA", HORIZONTAL_ALIGNMENT_LEFT, 195, 7, Color("9dd8c7") if unlocked else Color("635b54"))


func _draw_amulets(canvas: Control) -> void:
	_draw_section_title(canvas, "AMULETOS E RELÍQUIAS")
	var medal_owned := GameState.inventory_amount(&"important_items", &"medalha_antiga") > 0 or bool(GameState.purchased_items.get("medalha_antiga", false))
	_draw_amulet_slot(canvas, Rect2(110, 112, 130, 116), 4, "MEDALHA\nANTIGA", medal_owned)
	_draw_amulet_slot(canvas, Rect2(255, 112, 130, 116), 5, "VAZIO", false)
	_draw_amulet_slot(canvas, Rect2(400, 112, 130, 116), 6, "VAZIO", false)
	canvas.draw_string(PIXEL_FONT, Vector2(114, 254), "Relíquias alteram atributos e abrem novas combinações.", HORIZONTAL_ALIGNMENT_LEFT, 410, 8, Color("a99170"))
	canvas.draw_string(PIXEL_FONT, Vector2(114, 274), "Relatos encontrados: %d" % GameState.inventory.get("collectibles", {}).size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d9b35e"))


func _draw_amulet_slot(canvas: Control, rect: Rect2, icon_index: int, label: String, owned: bool) -> void:
	canvas.draw_rect(rect, Color("39271c") if owned else Color("181411"), true)
	canvas.draw_rect(rect, Color("d29a49") if owned else Color("4b4138"), false, 2.0)
	if owned:
		_draw_atlas_icon(canvas, PROGRESSION_ATLAS, Rect2(rect.position + Vector2(44, 9), Vector2(42, 50)), _atlas_region(icon_index, 4, PROGRESSION_CELL))
	else:
		canvas.draw_rect(Rect2(rect.position + Vector2(50, 17), Vector2(30, 30)), Color("302923"), true)
		canvas.draw_string(PIXEL_FONT, rect.position + Vector2(0, 39), "◇", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color("5b5047"))
	canvas.draw_string(PIXEL_FONT, rect.position + Vector2(0, 78), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8, Color("ffe09a") if owned else Color("6c6259"))


func _draw_section_title(canvas: Control, text: String) -> void:
	canvas.draw_string(PIXEL_FONT, Vector2(108, 97), text, HORIZONTAL_ALIGNMENT_LEFT, 420, 11, Color("dfbd82"))
	canvas.draw_line(Vector2(108, 101), Vector2(530, 101), Color("6f5038"), 1.0)


func _display_item_name(item_id: String) -> String:
	return String(ITEM_DISPLAY.get(item_id, {}).get("name", item_id.replace("_", " ").to_upper()))


func _draw_room(canvas: Control, room_id: StringName, position: Vector2) -> void:
	var visited := bool(GameState.visited_rooms.get(String(room_id), false))
	var current := GameState.current_room_id == room_id
	var selected := _selected_room == room_id and _tab == Tab.MAP
	var rect := Rect2(position, Vector2(22, 22))
	var fill := Color("77502d") if visited else Color("342822")
	if current:
		fill = Color("d4983f")
	canvas.draw_rect(rect, fill, true)
	canvas.draw_rect(rect, Color("fff3b0") if selected else (Color("ffe09a") if current else Color("8a6846")), false, 2.0 if selected else 1.0)
	var icon_color := Color.WHITE if visited else Color(0.24, 0.22, 0.21, 0.8)
	if current:
		icon_color = Color("fff2c1")
	_draw_atlas_icon(canvas, MAP_ICON_ATLAS, Rect2(position + Vector2(2, 2), Vector2(18, 18)), _atlas_region(int(ROOM_ICON_INDEX[room_id]), 4, MAP_ICON_CELL), icon_color)
	if current:
		canvas.draw_colored_polygon(PackedVector2Array([position + Vector2(7,-5), position + Vector2(11,-5), position + Vector2(9,-1)]), Color("fff1a6"))


func _draw_legend(canvas: Control) -> void:
	var abilities_text := "HABILIDADES: "
	abilities_text += "PEDRA ✓  " if GameState.abilities.get("wall_jump", false) else "PEDRA ?  "
	abilities_text += "POEIRA ✓" if GameState.abilities.get("dash", false) else "POEIRA ?"
	canvas.draw_string(PIXEL_FONT, Vector2(112, 271), abilities_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("8bd6bf"))
	canvas.draw_string(PIXEL_FONT, Vector2(390, 271), "◆ SEGREDOS %d" % GameState.discovered_secrets.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d9b35e"))
	canvas.draw_string(PIXEL_FONT, Vector2(112, 291), "RASTRO ATUAL: %s" % GameState.current_objective, HORIZONTAL_ALIGNMENT_LEFT, 416, 7, Color("d9b35e"))


func _draw_room_details(canvas: Control) -> void:
	var visited := bool(GameState.visited_rooms.get(String(_selected_room), false))
	var panel := Rect2(382, 108, 148, 142)
	canvas.draw_rect(panel, Color("18120f"), true)
	canvas.draw_rect(panel, Color("725238"), false, 1.0)
	canvas.draw_string(PIXEL_FONT, Vector2(390, 125), ROOM_NAMES.get(_selected_room, "???") if visited else "???", HORIZONTAL_ALIGNMENT_LEFT, 132, 9, Color("ffe09a") if visited else Color("71685f"))
	canvas.draw_string(PIXEL_FONT, Vector2(390, 142), "VISITADA" if visited else "NÃO DESCOBERTA", HORIZONTAL_ALIGNMENT_LEFT, 132, 7, Color("92d4b8") if visited else Color("71685f"))
	if not visited:
		return
	canvas.draw_string(PIXEL_FONT, Vector2(390, 161), "SAÍDAS CONHECIDAS", HORIZONTAL_ALIGNMENT_LEFT, 132, 7, Color("c9a66f"))
	var y := 176.0
	for connection in CONNECTIONS:
		if connection[0] != _selected_room and connection[1] != _selected_room:
			continue
		var other: StringName = connection[1] if connection[0] == _selected_room else connection[0]
		if not _is_connection_known(_selected_room, other):
			continue
		var required: StringName = connection[2]
		var suffix := ""
		if not required.is_empty() and not bool(GameState.abilities.get(String(required), false)):
			suffix = " — BLOQUEADA"
		canvas.draw_string(PIXEL_FONT, Vector2(390, y), "• %s%s" % [ROOM_NAMES.get(other, "???"), suffix], HORIZONTAL_ALIGNMENT_LEFT, 132, 6, Color("d9c39d") if suffix.is_empty() else Color("d26d55"))
		y += 13.0
		if y > 228.0:
			break


func _move_room_selection(direction: Vector2i) -> void:
	var current_position: Vector2i = ROOM_LAYOUT.get(_selected_room, ROOM_LAYOUT[GameState.current_room_id])
	var best_room := _selected_room
	var best_score := INF
	for candidate in ROOM_LAYOUT:
		if not bool(GameState.visited_rooms.get(String(candidate), false)):
			continue
		var delta: Vector2i = ROOM_LAYOUT[candidate] - current_position
		if direction.x != 0 and (signi(delta.x) != direction.x or delta.x == 0):
			continue
		if direction.y != 0 and (signi(delta.y) != direction.y or delta.y == 0):
			continue
		var score: float = float(abs(delta.x)) + float(abs(delta.y)) * 1.5 if direction.x != 0 else float(abs(delta.y)) + float(abs(delta.x)) * 1.5
		if score < best_score:
			best_score = score
			best_room = candidate
	_selected_room = best_room
	_canvas.queue_redraw()


func _atlas_region(index: int, columns: int, cell_size: Vector2) -> Rect2:
	return Rect2(Vector2(index % columns, floori(float(index) / float(columns))) * cell_size, cell_size)


func _draw_atlas_icon(canvas: Control, atlas: Texture2D, destination: Rect2, source: Rect2, color := Color.WHITE) -> void:
	canvas.draw_texture_rect_region(atlas, destination, source, color, false, true)


func _is_connection_known(a: StringName, b: StringName) -> bool:
	return GameState.visited_rooms.has(String(a)) or GameState.visited_rooms.has(String(b))


func _on_progress_changed(_room_id: StringName, _display_name: String) -> void:
	_canvas.queue_redraw()


func _on_progress_changed_one(_id: StringName) -> void:
	_canvas.queue_redraw()


func _on_progress_changed_two(_id: StringName, _display_name: String) -> void:
	_canvas.queue_redraw()


func _on_upgrade_collected(_id: StringName, display_name: String) -> void:
	_canvas.queue_redraw()
	_show_toast("MELHORIA PERMANENTE\n%s: VIDA MÁXIMA +1" % display_name)


func _on_lore_collectible_found(_id: StringName, display_name: String) -> void:
	_canvas.queue_redraw()
	_show_toast("RELATO ENCONTRADO\n%s" % display_name)


func _show_toast(message: String) -> void:
	NotificationManager.enqueue(message, 60, &"journal")
