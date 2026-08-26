class_name VilaGraybox
extends Node2D

const SAQUEADOR_SCENE := preload("res://scenes/enemies/saqueador.tscn")
const PISTOLEIRO_SCENE := preload("res://scenes/enemies/pistoleiro.tscn")
const ZE_TRANCA_SCENE := preload("res://scenes/bosses/ze_tranca.tscn")
const RUA_DAS_CINZAS_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/rua_das_cinzas.tscn")
const TELHADOS_DA_VILA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/telhados_da_vila.tscn")
const PRACA_DO_UMBU_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/praca_do_umbu.tscn")
const BARRACOS_QUEIMADOS_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/barracos_queimados.tscn")
const POSTO_DE_COMANDO_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/posto_de_comando.tscn")
const ARENA_ZE_TRANCA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/arena_ze_tranca.tscn")
const CASA_DE_NILO_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/casa_de_nilo.tscn")
const IGREJA_VELHA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/igreja_velha.tscn")
const ARMAZEM_TOMADO_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/armazem_tomado.tscn")
const PATIO_DO_ARMAZEM_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/patio_do_armazem.tscn")
const BECO_DOS_SAQUEADORES_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/beco_dos_saqueadores.tscn")
const POCO_DO_ROMAOZINHO_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/poco_do_romaozinho.tscn")
const BARRICADA_DA_COMPANHIA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/barricada_da_companhia.tscn")

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
	_build_metroidvania_routes()
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
		var production_scene := _production_scene_for(room.id)
		_add_production_room(bounds, production_scene)
		cursor_x += room.width
	world_width = cursor_x
	_add_solid(Rect2(-24.0, -40.0, 24.0, 240.0))
	_add_solid(Rect2(world_width, -40.0, 24.0, 240.0))


func _add_production_room(bounds: Rect2, scene: PackedScene) -> void:
	var room := scene.instantiate() as RoomController
	room.position = bounds.position
	add_child(room)


func _production_scene_for(room_id: StringName) -> PackedScene:
	match room_id:
		&"casa_nilo":
			return CASA_DE_NILO_SCENE
		&"rua_cinzas":
			return RUA_DAS_CINZAS_SCENE
		&"igreja_velha":
			return IGREJA_VELHA_SCENE
		&"telhados":
			return TELHADOS_DA_VILA_SCENE
		&"praca_umbu":
			return PRACA_DO_UMBU_SCENE
		&"barracos":
			return BARRACOS_QUEIMADOS_SCENE
		&"armazem":
			return ARMAZEM_TOMADO_SCENE
		&"patio":
			return PATIO_DO_ARMAZEM_SCENE
		&"beco":
			return BECO_DOS_SAQUEADORES_SCENE
		&"poco":
			return POCO_DO_ROMAOZINHO_SCENE
		&"barricada":
			return BARRICADA_DA_COMPANHIA_SCENE
		&"posto":
			return POSTO_DE_COMANDO_SCENE
		&"arena":
			return ARENA_ZE_TRANCA_SCENE
		_:
			return null


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
	barricade_gate.show_indicator = false
	add_child(barricade_gate)
	barricade_gate.position = Vector2(barricade.position.x + 286.0, 133.0)

	if not WorldState.is_vila_liberated():
		_spawn_occupied_encounters()


func _build_metroidvania_routes() -> void:
	var home: Rect2 = room_bounds[&"casa_nilo"]
	var church: Rect2 = room_bounds[&"igreja_velha"]
	var roofs: Rect2 = room_bounds[&"telhados"]
	var square: Rect2 = room_bounds[&"praca_umbu"]
	var warehouse: Rect2 = room_bounds[&"armazem"]
	var well: Rect2 = room_bounds[&"poco"]

	# Primeiro poder: muda imediatamente a forma de ler a igreja e os telhados.
	var wall_jump_pickup := AbilityPickup.new()
	wall_jump_pickup.ability_id = &"wall_jump"
	wall_jump_pickup.display_name = "PASSO DA PEDRA"
	add_child(wall_jump_pickup)
	wall_jump_pickup.position = Vector2(church.position.x + 104.0, 130.0)

	# Campanário: uma chaminé curta que exige alternar saltos nas paredes.
	_add_traversal_platform(Vector2(church.position.x + 214.0, 91.0), Vector2(9.0, 66.0), true)
	_add_traversal_platform(Vector2(church.position.x + 250.0, 91.0), Vector2(9.0, 66.0), true)
	_add_traversal_platform(Vector2(church.position.x + 278.0, 54.0), Vector2(64.0, 8.0), true)
	_add_traversal_platform(Vector2(roofs.position.x + 18.0, 75.0), Vector2(54.0, 8.0), false)

	# A habilidade de investida fica na rota alta, visível antes de ser alcançada.
	var dash_pickup := AbilityPickup.new()
	dash_pickup.ability_id = &"dash"
	dash_pickup.display_name = "PASSO DA POEIRA"
	dash_pickup.description = "C PARA ATRAVESSAR SELOS E VÃOS"
	add_child(dash_pickup)
	dash_pickup.position = Vector2(roofs.position.x + 250.0, 72.0)

	# Segredo na casa inicial: só abre no retorno com Pedra + Poeira.
	_add_traversal_platform(Vector2(home.position.x + 176.0, 112.0), Vector2(42.0, 7.0), false)
	_add_traversal_platform(Vector2(home.position.x + 224.0, 82.0), Vector2(46.0, 7.0), false)
	_add_traversal_platform(Vector2(home.position.x + 281.0, 72.0), Vector2(66.0, 7.0), false)
	var home_gate := AbilityGate.new()
	home_gate.required_ability = &"dash"
	home_gate.label = "SELO DA POEIRA"
	home_gate.gate_size = Vector2(8.0, 52.0)
	add_child(home_gate)
	home_gate.position = Vector2(home.position.x + 252.0, 49.0)
	var heart_upgrade := PermanentUpgradePickup.new()
	heart_upgrade.upgrade_id = &"coracao_casa_nilo"
	heart_upgrade.display_name = "CORAÇÃO DO SERTÃO"
	add_child(heart_upgrade)
	heart_upgrade.position = Vector2(home.position.x + 292.0, 57.0)

	# Rota alternativa: Praça -> fundos do Armazém. Abre nos dois sentidos.
	_add_connector(&"praca_armazem_alto", Vector2(square.position.x + 525.0, 125.0), Vector2(warehouse.position.x + 500.0, 125.0), &"dash", "TRILHA ALTA", &"armazem")
	_add_connector(&"praca_armazem_alto", Vector2(warehouse.position.x + 500.0, 125.0), Vector2(square.position.x + 525.0, 125.0), &"", "VOLTAR À PRAÇA", &"praca_umbu", true)

	# Atalho tardio: aberto pelo lado do Poço, devolve rapidamente à Igreja.
	_add_connector(&"poco_igreja_cripta", Vector2(well.position.x + 160.0, 112.0), Vector2(church.position.x + 40.0, 130.0), &"wall_jump", "DESCER À CRIPTA", &"igreja_velha")
	_add_connector(&"poco_igreja_cripta", Vector2(church.position.x + 40.0, 130.0), Vector2(well.position.x + 160.0, 112.0), &"", "TÚNEL DO POÇO", &"poco", true)


func _add_traversal_platform(at: Vector2, size: Vector2, stone_style: bool) -> void:
	var platform := TraversalPlatform.new()
	platform.platform_size = size
	platform.stone_style = stone_style
	add_child(platform)
	platform.position = at


func _add_connector(id: StringName, at: Vector2, target: Vector2, ability: StringName, label: String, target_room: StringName, wait_for_unlock := false) -> void:
	var connector := WorldConnector.new()
	connector.connector_id = id
	connector.destination = target
	connector.required_ability = ability
	connector.display_name = label
	connector.destination_room = target_room
	connector.locked_until_opened = wait_for_unlock
	add_child(connector)
	connector.position = at


func _spawn_occupied_encounters() -> void:
	pass


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
	pass


func _draw_room_background(bounds: Rect2, index: int, liberated: bool) -> void:
	var sky_top := Color("6e7d82") if liberated else Color("55464a")
	var sky_bottom := Color("d7a25f") if liberated else Color("9a6047")
	for band in 6:
		var ratio := float(band) / 5.0
		var band_rect := Rect2(bounds.position.x, ratio * 25.0, bounds.size.x, 26.0)
		draw_rect(band_rect, sky_top.lerp(sky_bottom, ratio), true)
	if index == 0:
		var sun_position := Vector2(bounds.position.x + bounds.size.x * 0.78, 38.0)
		draw_circle(sun_position, 11.0, Color("f3c56d") if liberated else Color("c87850"))
		draw_circle(sun_position, 7.0, Color("ffe09a") if liberated else Color("e0a060"))

	var far_color := Color("59635d") if liberated else Color("695755")
	var mountain_points := PackedVector2Array([Vector2(bounds.position.x, 126.0)])
	var segment := bounds.size.x / 6.0
	for ridge in 7:
		var ridge_height := 72.0 + float((ridge * 17 + index * 11) % 33)
		mountain_points.append(Vector2(bounds.position.x + ridge * segment, ridge_height))
	mountain_points.append(Vector2(bounds.end.x, 150.0))
	mountain_points.append(Vector2(bounds.position.x, 150.0))
	draw_colored_polygon(mountain_points, far_color)

	var near_color := Color("3f5147") if liberated else Color("584441")
	var near_points := PackedVector2Array([Vector2(bounds.position.x, 150.0)])
	for ridge in 7:
		var near_height := 108.0 + float((ridge * 13 + index * 9) % 24)
		near_points.append(Vector2(bounds.position.x + ridge * segment, near_height))
	near_points.append(Vector2(bounds.end.x, 150.0))
	draw_colored_polygon(near_points, near_color)



func _draw_background_structures(bounds: Rect2, index: int, liberated: bool) -> void:
	var wall_color := Color("80634a") if liberated else Color("65483e")
	var roof_color := Color("4b332b") if liberated else Color("38262a")
	var window_color := Color("e7b85f") if liberated else Color("51292b")
	var building_count := 2 if bounds.size.x <= 320.0 else 4
	for building in building_count:
		var x := bounds.position.x + 28.0 + building * (bounds.size.x - 56.0) / float(building_count)
		var width := 48.0 + float((building + index) % 3) * 8.0
		var height := 22.0 + float((building * 7 + index) % 16)
		draw_rect(Rect2(x, 150.0 - height, width, height), wall_color, true)
		var roof := PackedVector2Array([
			Vector2(x - 5.0, 150.0 - height),
			Vector2(x + width * 0.5, 142.0 - height),
			Vector2(x + width + 5.0, 150.0 - height),
		])
		draw_colored_polygon(roof, roof_color)
		draw_rect(Rect2(x + width * 0.18, 138.0 - height * 0.45, 6.0, 7.0), window_color, true)
		draw_rect(Rect2(x + width * 0.68, 138.0 - height * 0.45, 6.0, 7.0), window_color, true)
	for post in range(18, int(bounds.size.x), 42):
		var post_x := bounds.position.x + float(post)
		draw_line(Vector2(post_x, 134.0), Vector2(post_x, 150.0), Color("493629"), 2.0)
		draw_line(Vector2(post_x, 138.0), Vector2(post_x + 42.0, 142.0), Color("6b4a31"), 1.0)


func _draw_styled_solid(solid: Rect2, liberated: bool) -> void:
	var dirt := Color("745239") if liberated else Color("684535")
	var dark_dirt := Color("493527") if liberated else Color("3e2a29")
	var cap := Color("b18a53") if liberated else Color("9c7046")
	draw_rect(solid, dirt, true)
	draw_rect(Rect2(solid.position, Vector2(solid.size.x, minf(4.0, solid.size.y))), cap, true)
	draw_line(solid.position + Vector2(0.0, 4.0), Vector2(solid.end.x, solid.position.y + 4.0), dark_dirt, 1.0)
	if solid.size.x >= 24.0:
		for mark_x in range(10, int(solid.size.x), 24):
			var y_offset := 8.0 + float((mark_x * 7) % maxi(8, int(maxf(solid.size.y - 10.0, 8.0))))
			draw_line(solid.position + Vector2(mark_x, y_offset), solid.position + Vector2(mark_x + 5.0, y_offset + 1.0), dark_dirt, 1.0)


func _draw_landmarks(liberated: bool) -> void:
	var home: Rect2 = room_bounds[&"casa_nilo"]
	_draw_doorway(Vector2(home.position.x + 64.0, 150.0), liberated)
	var church: Rect2 = room_bounds[&"igreja_velha"]
	_draw_church(Vector2(church.get_center().x, 150.0), liberated)
	var square: Rect2 = room_bounds[&"praca_umbu"]
	var tree_position := Vector2(square.get_center().x, 113.0)
	draw_line(tree_position, tree_position + Vector2(0.0, 37.0), Color("6b4028"), 6.0)
	draw_circle(tree_position + Vector2(-9.0, -8.0), 14.0, Color("5a874e") if liberated else Color("55513a"))
	draw_circle(tree_position + Vector2(8.0, -11.0), 16.0, Color("4f7c4c") if liberated else Color("494538"))
	draw_circle(tree_position + Vector2(0.0, -19.0), 13.0, Color("659755") if liberated else Color("5b563d"))
	draw_rect(Rect2(tree_position.x - 23.0, 145.0, 46.0, 5.0), Color("8e714a"), true)
	var well: Rect2 = room_bounds[&"poco"]
	var well_center := Vector2(well.get_center().x, 139.0)
	draw_circle(well_center, 25.0, Color("5a4939"), true)
	draw_circle(well_center, 19.0, Color("171c22"), true)
	draw_line(well_center + Vector2(-23.0, -9.0), well_center + Vector2(-23.0, -39.0), Color("5b402b"), 3.0)
	draw_line(well_center + Vector2(23.0, -9.0), well_center + Vector2(23.0, -39.0), Color("5b402b"), 3.0)
	draw_line(well_center + Vector2(-25.0, -38.0), well_center + Vector2(25.0, -38.0), Color("76553a"), 3.0)
	var command: Rect2 = room_bounds[&"posto"]
	_draw_watchtower(Vector2(command.get_center().x, 150.0), liberated)
	var arena: Rect2 = room_bounds[&"arena"]
	for stake_x in [42.0, 598.0]:
		var x: float = arena.position.x + float(stake_x)
		draw_line(Vector2(x, 116.0), Vector2(x, 150.0), Color("4a2c27"), 4.0)
		draw_line(Vector2(x - 7.0, 121.0), Vector2(x + 7.0, 121.0), Color("7f3b32"), 2.0)
		var flag_direction := 1.0 if stake_x < 300.0 else -1.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 118.0), Vector2(x + flag_direction * 22.0, 123.0),
			Vector2(x + flag_direction * 14.0, 132.0), Vector2(x, 128.0),
		]), Color("8f382f"))
		var fire_x := x + flag_direction * 28.0
		draw_rect(Rect2(fire_x - 6.0, 143.0, 12.0, 4.0), Color("402820"), true)
		draw_circle(Vector2(fire_x, 140.0), 5.0, Color("d9572d"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(fire_x - 3.0, 142.0), Vector2(fire_x + 1.0, 130.0), Vector2(fire_x + 4.0, 142.0),
		]), Color("f4a13c"))
	for barricade_x in [120.0, 488.0]:
		var bx: float = arena.position.x + barricade_x
		draw_line(Vector2(bx - 18.0, 147.0), Vector2(bx + 18.0, 134.0), Color("5a3828"), 4.0)
		draw_line(Vector2(bx - 18.0, 134.0), Vector2(bx + 18.0, 147.0), Color("70452f"), 4.0)


func _draw_doorway(base: Vector2, liberated: bool) -> void:
	var wall := Color("9b744e") if liberated else Color("694b3f")
	draw_rect(Rect2(base.x - 30.0, base.y - 42.0, 60.0, 42.0), wall, true)
	draw_colored_polygon(PackedVector2Array([Vector2(base.x - 36.0, base.y - 42.0), Vector2(base.x, base.y - 55.0), Vector2(base.x + 36.0, base.y - 42.0)]), Color("493229"))
	draw_rect(Rect2(base.x - 8.0, base.y - 26.0, 16.0, 26.0), Color("2b2422"), true)
	draw_circle(base + Vector2(4.0, -13.0), 1.0, Color("d8a74f"))


func _draw_church(base: Vector2, liberated: bool) -> void:
	var wall := Color("a88360") if liberated else Color("73554d")
	draw_rect(Rect2(base.x - 42.0, base.y - 58.0, 84.0, 58.0), wall, true)
	draw_colored_polygon(PackedVector2Array([Vector2(base.x - 48.0, base.y - 58.0), Vector2(base.x, base.y - 83.0), Vector2(base.x + 48.0, base.y - 58.0)]), Color("49332f"))
	draw_rect(Rect2(base.x - 9.0, base.y - 31.0, 18.0, 31.0), Color("31272a"), true)
	draw_line(Vector2(base.x, base.y - 83.0), Vector2(base.x, base.y - 96.0), Color("d1b075"), 2.0)
	draw_line(Vector2(base.x - 5.0, base.y - 90.0), Vector2(base.x + 5.0, base.y - 90.0), Color("d1b075"), 2.0)


func _draw_watchtower(base: Vector2, liberated: bool) -> void:
	var wood := Color("74583b") if liberated else Color("523631")
	draw_line(base + Vector2(-19.0, 0.0), base + Vector2(-12.0, -48.0), wood, 4.0)
	draw_line(base + Vector2(19.0, 0.0), base + Vector2(12.0, -48.0), wood, 4.0)
	draw_rect(Rect2(base.x - 23.0, base.y - 53.0, 46.0, 9.0), wood, true)
	draw_line(base + Vector2(0.0, -53.0), base + Vector2(0.0, -72.0), wood, 2.0)
	draw_colored_polygon(PackedVector2Array([base + Vector2(0.0, -72.0), base + Vector2(18.0, -66.0), base + Vector2(0.0, -61.0)]), Color("c66b44") if liberated else Color("7e3030"))


func _draw_world_state_atmosphere(liberated: bool) -> void:
	if not liberated:
		for room_id in [&"armazem", &"patio"]:
			var bounds: Rect2 = room_bounds[room_id]
			var fire_position := Vector2(bounds.position.x + bounds.size.x * 0.72, 143.0)
			var flicker := sin(bounds.position.x) * 2.0
			draw_circle(fire_position, 8.0, Color("d84a2d"))
			draw_colored_polygon(PackedVector2Array([fire_position + Vector2(-5.0, 0.0), fire_position + Vector2(flicker, -17.0), fire_position + Vector2(5.0, 0.0)]), Color("f0a13b"))
			draw_circle(fire_position + Vector2(0.0, -5.0), 3.0, Color("ffe184"))
			for smoke in 3:
				var drift := fmod(smoke * 8.0, 24.0)
				draw_circle(fire_position + Vector2(smoke * 3.0 + drift * 0.35, -20.0 - drift), 5.0 + smoke, Color(0.18, 0.16, 0.17, 0.34 - smoke * 0.07))
		draw_rect(Rect2(0.0, 0.0, 320.0, 150.0), Color(0.18, 0.07, 0.08, 0.08), true)
		draw_rect(Rect2(960.0, 0.0, world_width - 960.0, 150.0), Color(0.18, 0.07, 0.08, 0.08), true)
	else:
		pass


func _draw_pixel_resident(position: Vector2, shirt: Color, alternate: bool) -> void:
	var outline := Color("302621")
	draw_rect(Rect2(position.x - 3.0, position.y - 4.0, 6.0, 6.0), outline, true)
	draw_rect(Rect2(position.x - 2.0, position.y - 3.0, 4.0, 4.0), Color("c9895b"), true)
	draw_rect(Rect2(position.x - 4.0, position.y + 2.0, 8.0, 9.0), outline, true)
	draw_rect(Rect2(position.x - 3.0, position.y + 3.0, 6.0, 7.0), shirt, true)
	var stance := 1.0 if alternate else 0.0
	draw_rect(Rect2(position.x - 3.0 - stance, position.y + 11.0, 3.0, 5.0), outline, true)
	draw_rect(Rect2(position.x + stance, position.y + 11.0, 3.0, 5.0), outline, true)
