class_name VilaGraybox
extends Node2D

const SAQUEADOR_SCENE := preload("res://scenes/enemies/saqueador.tscn")
const PISTOLEIRO_SCENE := preload("res://scenes/enemies/pistoleiro.tscn")
const ZE_TRANCA_SCENE := preload("res://scenes/bosses/ze_tranca.tscn")

const ROOMS := [
	{"id": &"casa_nilo", "name": "01 CASA DE NILO", "width": 320.0, "function": "Origem e controles"},
	{"id": &"rua_cinzas", "name": "02 RUA DAS CINZAS", "width": 640.0, "function": "Primeiro combate"},
	{"id": &"igreja_velha", "name": "03 IGREJA VELHA", "width": 320.0, "function": "Trauma e checkpoint"},
	{"id": &"telhados", "name": "04 TELHADOS DA VILA", "width": 640.0, "function": "Plataforma"},
	{"id": &"praca_umbu", "name": "05 PRAÇA DO UMBU", "width": 640.0, "function": "Landmark e hub"},
	{"id": &"barracos", "name": "06 BARRACOS QUEIMADOS", "width": 640.0, "function": "Controle de área"},
	{"id": &"armazem", "name": "07 ARMAZÉM TOMADO", "width": 640.0, "function": "Combate interno"},
	{"id": &"patio", "name": "08 PÁTIO DO ARMAZÉM", "width": 640.0, "function": "Arena de domínio"},
	{"id": &"beco", "name": "09 BECO DOS SAQUEADORES", "width": 320.0, "function": "Emboscada"},
	{"id": &"poco", "name": "10 POÇO DO ROMÃOZINHO", "width": 320.0, "function": "Opcional e bloqueado"},
	{"id": &"barricada", "name": "11 BARRICADA DA COMPANHIA", "width": 640.0, "function": "Gate e elite"},
	{"id": &"posto", "name": "12 POSTO DE COMANDO", "width": 320.0, "function": "Pré-boss e lore"},
	{"id": &"arena", "name": "13 ARENA DE ZÉ TRANCA", "width": 640.0, "function": "Boss tutorial"},
]

var room_bounds: Dictionary = {}
var solid_rects: Array[Rect2] = []
var world_width := 0.0
var player: NiloPlayer


func _ready() -> void:
	_build_rooms()
	_build_gameplay()
	EventBus.world_state_changed.connect(_on_world_state_changed)
	queue_redraw()


func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as NiloPlayer
	if player != null and player.global_position.y > 280.0 and not player.is_dead:
		player.respawn_at_checkpoint()


func get_room_center(room_id: StringName) -> Vector2:
	var bounds: Rect2 = room_bounds.get(room_id, Rect2())
	return Vector2(bounds.get_center().x, 136.0)


func _build_rooms() -> void:
	var cursor_x := 0.0
	for room in ROOMS:
		var bounds := Rect2(cursor_x, 0.0, room.width, 180.0)
		room_bounds[room.id] = bounds
		_add_solid(Rect2(cursor_x, 150.0, room.width, 30.0))
		var trigger := RoomTrigger.new()
		add_child(trigger)
		trigger.configure(room.id, room.name, bounds)
		cursor_x += room.width
	world_width = cursor_x
	_add_solid(Rect2(-24.0, -40.0, 24.0, 240.0))
	_add_solid(Rect2(world_width, -40.0, 24.0, 240.0))
	_add_room_platforms()


func _add_room_platforms() -> void:
	var roofs: Rect2 = room_bounds[&"telhados"]
	_add_solid(Rect2(roofs.position.x + 70.0, 112.0, 86.0, 10.0))
	_add_solid(Rect2(roofs.position.x + 198.0, 88.0, 104.0, 10.0))
	_add_solid(Rect2(roofs.position.x + 350.0, 116.0, 92.0, 10.0))
	_add_solid(Rect2(roofs.position.x + 492.0, 82.0, 110.0, 10.0))
	var square: Rect2 = room_bounds[&"praca_umbu"]
	_add_solid(Rect2(square.position.x + 248.0, 126.0, 144.0, 24.0))
	var warehouse: Rect2 = room_bounds[&"armazem"]
	_add_solid(Rect2(warehouse.position.x + 130.0, 106.0, 86.0, 8.0))
	_add_solid(Rect2(warehouse.position.x + 344.0, 92.0, 96.0, 8.0))
	var well: Rect2 = room_bounds[&"poco"]
	_add_solid(Rect2(well.position.x + 116.0, 126.0, 88.0, 24.0))


func _build_gameplay() -> void:
	var church: Rect2 = room_bounds[&"igreja_velha"]
	var checkpoint := Checkpoint.new()
	checkpoint.checkpoint_id = &"vila_igreja"
	add_child(checkpoint)
	checkpoint.position = Vector2(church.position.x + 72.0, 132.0)

	var warehouse: Rect2 = room_bounds[&"armazem"]
	var square: Rect2 = room_bounds[&"praca_umbu"]
	var shortcut := ShortcutDoor.new()
	shortcut.shortcut_id = &"vila_praca_armazem"
	shortcut.destination = Vector2(square.position.x + square.size.x - 58.0, 130.0)
	add_child(shortcut)
	shortcut.position = Vector2(warehouse.position.x + warehouse.size.x - 62.0, 128.0)

	var arena: Rect2 = room_bounds[&"arena"]
	var exit_gate := LiberationGate.new()
	exit_gate.gate_size = Vector2(12.0, 180.0)
	add_child(exit_gate)
	exit_gate.position = Vector2(arena.end.x - 28.0, 60.0)
	var barricade: Rect2 = room_bounds[&"barricada"]
	var barricade_gate := LiberationGate.new()
	barricade_gate.blocked_label = "BARRICADA"
	barricade_gate.open_label = "ABERTA"
	add_child(barricade_gate)
	barricade_gate.position = Vector2(barricade.position.x + 286.0, 133.0)

	if not WorldState.is_vila_liberated():
		_spawn_occupied_encounters()


func _spawn_occupied_encounters() -> void:
	_spawn_enemy(SAQUEADOR_SCENE, &"rua_cinzas", 210.0)
	_spawn_enemy(PISTOLEIRO_SCENE, &"rua_cinzas", 430.0)
	_spawn_enemy(SAQUEADOR_SCENE, &"barracos", 170.0)
	_spawn_enemy(SAQUEADOR_SCENE, &"armazem", 180.0)
	_spawn_enemy(PISTOLEIRO_SCENE, &"armazem", 430.0)
	_spawn_enemy(SAQUEADOR_SCENE, &"patio", 190.0)
	_spawn_enemy(SAQUEADOR_SCENE, &"patio", 390.0)
	_spawn_enemy(PISTOLEIRO_SCENE, &"beco", 180.0)
	if not GameState.defeated_bosses.get("ze_tranca", false):
		_spawn_enemy(ZE_TRANCA_SCENE, &"arena", 390.0)


func _spawn_enemy(scene: PackedScene, room_id: StringName, local_x: float) -> void:
	var bounds: Rect2 = room_bounds[room_id]
	var enemy := scene.instantiate() as CharacterBody2D
	add_child(enemy)
	enemy.position = Vector2(bounds.position.x + local_x, 132.0)


func _add_solid(rect: Rect2) -> void:
	solid_rects.append(rect)
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.position = rect.get_center()
	body.add_child(collision)
	add_child(body)


func _on_world_state_changed(region_id: StringName, _state: StringName) -> void:
	if region_id == &"vila_umbuzeiro":
		queue_redraw()


func _draw() -> void:
	var liberated := WorldState.is_vila_liberated()
	for index in ROOMS.size():
		var room: Dictionary = ROOMS[index]
		var bounds: Rect2 = room_bounds[room.id]
		var base_color := Color("3f332e") if index % 2 == 0 else Color("493a32")
		if liberated:
			base_color = Color("35483d") if index % 2 == 0 else Color("3d5145")
		draw_rect(bounds, base_color, true)
		draw_rect(bounds.grow(-2.0), Color(0.85, 0.7, 0.45, 0.22), false, 2.0)
		draw_string(ThemeDB.fallback_font, bounds.position + Vector2(10.0, 15.0), room.name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color("f6e7cb"))
		draw_string(ThemeDB.fallback_font, bounds.position + Vector2(10.0, 27.0), room.function, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 7, Color("d0b79b"))
	for solid in solid_rects:
		draw_rect(solid, Color("7a5c3e") if not liberated else Color("6f7750"), true)
	_draw_landmarks(liberated)


func _draw_landmarks(liberated: bool) -> void:
	var square: Rect2 = room_bounds[&"praca_umbu"]
	var tree_position := Vector2(square.get_center().x, 113.0)
	draw_line(tree_position, tree_position + Vector2(0.0, 32.0), Color("6b4028"), 5.0)
	draw_circle(tree_position + Vector2(0.0, -8.0), 18.0, Color("4f7c4c") if liberated else Color("55513a"))
	var well: Rect2 = room_bounds[&"poco"]
	draw_circle(Vector2(well.get_center().x, 139.0), 24.0, Color("1e2329"), true)
	draw_string(ThemeDB.fallback_font, Vector2(well.position.x + 78.0, 76.0), "DESCIDA PARCIAL", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color("8fc8d8"))
	draw_string(ThemeDB.fallback_font, Vector2(well.position.x + 84.0, 88.0), "ROTA BLOQUEADA", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 7, Color("e6a15c"))
	if not liberated:
		for room_id in [&"rua_cinzas", &"barracos", &"armazem"]:
			var bounds: Rect2 = room_bounds[room_id]
			var fire_position := Vector2(bounds.position.x + bounds.size.x * 0.72, 140.0)
			draw_circle(fire_position, 8.0, Color("e4572e"))
			draw_circle(fire_position + Vector2(0.0, -8.0), 5.0, Color("f4d35e"))
	else:
		for x_offset in [230.0, 310.0, 390.0]:
			draw_circle(Vector2(square.position.x + x_offset, 136.0), 5.0, Color("d7b58c"))
