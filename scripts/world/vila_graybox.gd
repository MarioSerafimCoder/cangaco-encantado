class_name VilaGraybox
extends Node2D

const SAQUEADOR_SCENE := preload("res://scenes/enemies/saqueador.tscn")
const PISTOLEIRO_SCENE := preload("res://scenes/enemies/pistoleiro.tscn")
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
const CASA_INTERIOR_ATLAS := preload("res://assets/area_01/environment/casa_nilo_interior_atlas.png")
const CASA_ARCHITECTURE_ATLAS := preload("res://assets/area_01/environment/casa_nilo_arquitetura_atlas.png")
const TRAVERSAL_ATLAS := preload("res://assets/area_01/environment/traversal_props_atlas.png")
const ARCHITECTURE_ATLAS := preload("res://assets/area_01/environment/arquitetura_vila_atlas.png")
const UNDERGROUND_ATLAS := preload("res://assets/area_01/environment/cripta_subterraneo_atlas.png")
const CAVERN_ATLAS := preload("res://assets/area_01/environment/grutas_cavernas_atlas.png")
const CAVERN_STRUCTURE_ATLAS := preload("res://assets/area_01/environment/cavernas_estrutura_atlas.png")
const CAVE_FLOOR_REGION := Rect2(60, 150, 650, 270)
const HOME_WALL_REGION := Rect2(302, 108, 910, 340)
const HOME_LEFT_WALL_REGION := Rect2(28, 54, 196, 420)
const HOME_RIGHT_WALL_REGION := Rect2(1283, 55, 205, 420)
const HOME_CEILING_REGION := Rect2(207, 500, 1090, 108)
const HOME_FLOOR_REGION := Rect2(90, 697, 500, 158)
const HOME_DOOR_CLOSED_REGION := Rect2(693, 648, 235, 298)
const HOME_DOOR_OPEN_REGION := Rect2(965, 647, 273, 300)
const HOME_WINDOW_REGION := Rect2(1294, 672, 216, 238)
const CAVE_WALL_REGION := Rect2(40, 34, 720, 320)
const CAVE_CEILING_REGION := Rect2(804, 32, 695, 200)
const UNDERGROUND_WALL_REGION := Rect2(720, 425, 510, 280)
const CAVE_TUNNEL_REGION := Rect2(309, 387, 355, 325)
const CAVE_WATER_REGION := Rect2(95, 750, 665, 225)
const CAVE_BRIDGE_REGION := Rect2(812, 744, 630, 230)

const ROOMS := [
	{"id": &"casa_nilo", "name": "01 CASA DE NILO", "width": 960.0, "function": "Origem, retorno e segredo"},
	{"id": &"rua_cinzas", "name": "02 RUA DAS CINZAS", "width": 1280.0, "function": "Primeiro combate"},
	{"id": &"barracos", "name": "03 VILA BAIXA", "width": 1280.0, "function": "Traversal e conflito"},
	{"id": &"praca_umbu", "name": "04 PRAÇA DO UMBU", "width": 1280.0, "function": "Hub, comércio e moradores"},
	{"id": &"igreja_velha", "name": "05 IGREJA E CEMITÉRIO", "width": 960.0, "function": "Checkpoint, lore e cripta"},
	{"id": &"telhados", "name": "06 TELHADOS DA VILA", "width": 1280.0, "function": "Rota arquitetônica elevada"},
	{"id": &"armazem", "name": "07 CRIPTA DA IGREJA", "width": 1280.0, "function": "Entrada subterrânea"},
	{"id": &"patio", "name": "08 SUBTERRÂNEO DA VILA", "width": 1280.0, "function": "Alvenaria e túneis"},
	{"id": &"beco", "name": "09 GRUTAS", "width": 960.0, "function": "Pedra exposta e raízes"},
	{"id": &"poco", "name": "10 POÇO DAS RAÍZES", "width": 960.0, "function": "Rota opcional e segredo"},
	{"id": &"barricada", "name": "11 CAVERNA RASA", "width": 1280.0, "function": "Exploração natural"},
	{"id": &"posto", "name": "12 CAVERNA PROFUNDA", "width": 960.0, "function": "Descida e atalho"},
	{"id": &"arena", "name": "13 SANTUÁRIO ENCANTADO", "width": 1280.0, "function": "Descoberta sobrenatural"},
]

const UNDERGROUND_ROOMS := [&"armazem", &"patio"]
const CAVERN_ROOMS := [&"beco", &"poco", &"barricada", &"posto", &"arena"]

var room_bounds: Dictionary = {}
var solid_rects: Array[Rect2] = []
var world_width := 0.0
var player: NiloPlayer


func _ready() -> void:
	_build_rooms()
	_build_area01_composition()
	_build_npcs()
	_build_gameplay()
	_build_metroidvania_routes()
	EventBus.world_state_changed.connect(_on_world_state_changed)
	queue_redraw()


func _process(_delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as NiloPlayer
	if player != null and player.global_position.y > 420.0 and not player.is_dead:
		player.respawn_at_checkpoint()


func get_room_center(room_id: StringName) -> Vector2:
	var bounds: Rect2 = room_bounds.get(room_id, Rect2())
	return Vector2(bounds.get_center().x, 136.0)


func _build_rooms() -> void:
	var cursor_x := 0.0
	for room in ROOMS:
		var bounds := Rect2(cursor_x, 0.0, room.width, 360.0)
		room_bounds[room.id] = bounds
		var production_scene := _production_scene_for(room.id)
		_add_production_room(bounds, production_scene)
		cursor_x += room.width
	world_width = cursor_x
	_add_solid(Rect2(-24.0, -120.0, 24.0, 480.0))
	_add_solid(Rect2(world_width, -120.0, 24.0, 480.0))


func _add_production_room(bounds: Rect2, scene: PackedScene) -> void:
	var room := scene.instantiate() as RoomController
	room.position = bounds.position
	if room.room_id in UNDERGROUND_ROOMS:
		room.occupied_tint = Color("7f8080")
		room.liberated_tint = Color("8b8c88")
		room.camera_profile = "underground"
		room.suppress_authored_environment = true
	elif room.room_id in CAVERN_ROOMS:
		room.occupied_tint = Color("68666b")
		room.liberated_tint = Color("77747a")
		room.camera_profile = "cavern"
		room.suppress_authored_environment = true
	elif room.room_id == &"telhados":
		room.camera_profile = "rooftops"
	elif room.room_id == &"casa_nilo":
		room.suppress_authored_environment = true
	add_child(room)
	if room.suppress_authored_environment:
		_hide_authored_ground(room)
	if room.room_id == &"casa_nilo":
		_add_home_backdrop(bounds)
	elif room.room_id in UNDERGROUND_ROOMS:
		_add_cave_backdrop(bounds, false)
	elif room.room_id in CAVERN_ROOMS:
		_add_cave_backdrop(bounds, true)


func _build_area01_composition() -> void:
	var home: Rect2 = room_bounds[&"casa_nilo"]
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(28, 105, 455, 330), home.position.x + 150, 150, 175, 116, 10, -3)
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(500, 120, 240, 300), home.position.x + 350, 150, 92, 70, 8, -3)
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(805, 145, 395, 275), home.position.x + 535, 150, 145, 105, 8, -3)
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(90, 560, 280, 170), home.position.x + 310, 150, 88, 0, 0, 2)
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(245, 780, 460, 180), home.position.x + 560, 112, 175, 0, 0, -2)
	_add_prop(CASA_INTERIOR_ATLAS, Rect2(55, 750, 120, 205), home.position.x + 730, 150, 45, 0, 0, 2)
	_add_narrative(CASA_INTERIOR_ATLAS, Rect2(1210, 20, 300, 380), home.position.x + 255, 108, 66, &"lembranca_nilo")
	_add_home_doors(home)

	var street: Rect2 = room_bounds[&"rua_cinzas"]
	_add_prop(TRAVERSAL_ATLAS, Rect2(55, 145, 590, 265), street.position.x + 300, 150, 230, 180, 10, -1)
	_add_prop(TRAVERSAL_ATLAS, Rect2(35, 665, 310, 300), street.position.x + 570, 150, 165, 145, 8, -1)
	_add_prop(TRAVERSAL_ATLAS, Rect2(365, 650, 350, 315), street.position.x + 790, 150, 175, 140, 8, -2)
	_add_prop(TRAVERSAL_ATLAS, Rect2(830, 425, 205, 185), street.position.x + 1040, 150, 105, 82, 8, -1)

	var lower: Rect2 = room_bounds[&"barracos"]
	_add_prop(ARCHITECTURE_ATLAS, Rect2(50, 75, 270, 325), lower.position.x + 180, 150, 210, 150, 8, -6)
	_add_prop(ARCHITECTURE_ATLAS, Rect2(335, 65, 575, 340), lower.position.x + 540, 150, 330, 245, 8, -7)
	_add_prop(TRAVERSAL_ATLAS, Rect2(695, 135, 565, 295), lower.position.x + 840, 150, 220, 175, 10, -1)
	_add_prop(ARCHITECTURE_ATLAS, Rect2(965, 45, 505, 355), lower.position.x + 1090, 150, 280, 220, 8, -7)

	var square: Rect2 = room_bounds[&"praca_umbu"]
	_add_prop(ARCHITECTURE_ATLAS, Rect2(35, 425, 530, 280), square.position.x + 960, 150, 280, 0, 0, -8)
	_add_prop(TRAVERSAL_ATLAS, Rect2(1110, 405, 340, 215), square.position.x + 1140, 150, 150, 120, 8, -2)
	_add_narrative(ARCHITECTURE_ATLAS, Rect2(1070, 400, 250, 310), square.position.x + 1165, 150, 125, &"saida_beta")

	var church: Rect2 = room_bounds[&"igreja_velha"]
	_add_prop(ARCHITECTURE_ATLAS, Rect2(590, 420, 440, 290), church.position.x + 520, 150, 220, 0, 0, -7)
	_add_prop(ARCHITECTURE_ATLAS, Rect2(1070, 400, 250, 310), church.position.x + 810, 150, 145, 0, 0, -7)
	_add_prop(UNDERGROUND_ATLAS, Rect2(30, 55, 340, 345), church.position.x + 700, 150, 170, 0, 0, -4)

	var roofs: Rect2 = room_bounds[&"telhados"]
	_add_prop(ARCHITECTURE_ATLAS, Rect2(50, 75, 270, 325), roofs.position.x + 720, 150, 190, 145, 8, -6)
	_add_prop(TRAVERSAL_ATLAS, Rect2(35, 665, 310, 300), roofs.position.x + 550, 150, 150, 125, 8, -1)
	_add_prop(ARCHITECTURE_ATLAS, Rect2(335, 65, 575, 340), roofs.position.x + 940, 150, 310, 235, 8, -7)
	_add_prop(TRAVERSAL_ATLAS, Rect2(365, 650, 350, 315), roofs.position.x + 1125, 150, 160, 135, 8, -1)

	_build_underground_composition()


func _build_underground_composition() -> void:
	var crypt: Rect2 = room_bounds[&"armazem"]
	_add_prop(UNDERGROUND_ATLAS, Rect2(25, 45, 350, 360), crypt.position.x + 180, 150, 220, 0, 0, -5)
	_add_prop(UNDERGROUND_ATLAS, Rect2(390, 55, 330, 345), crypt.position.x + 470, 150, 240, 0, 0, -6)
	_add_prop(UNDERGROUND_ATLAS, Rect2(755, 70, 350, 340), crypt.position.x + 760, 150, 220, 165, 8, -2)
	_add_prop(UNDERGROUND_ATLAS, Rect2(1120, 90, 390, 310), crypt.position.x + 1080, 150, 230, 175, 8, -3)
	var tunnels: Rect2 = room_bounds[&"patio"]
	_add_prop(UNDERGROUND_ATLAS, Rect2(20, 450, 365, 220), tunnels.position.x + 180, 150, 220, 0, 0, -4)
	_add_prop(UNDERGROUND_ATLAS, Rect2(410, 455, 330, 230), tunnels.position.x + 460, 150, 210, 0, 0, -4)
	_add_prop(UNDERGROUND_ATLAS, Rect2(760, 505, 390, 180), tunnels.position.x + 760, 150, 260, 215, 8, -2)
	_add_prop(UNDERGROUND_ATLAS, Rect2(1160, 470, 350, 220), tunnels.position.x + 1080, 150, 230, 180, 8, -2)
	var grotto: Rect2 = room_bounds[&"beco"]
	_add_prop(CAVERN_ATLAS, Rect2(60, 150, 650, 270), grotto.position.x + 280, 150, 430, 315, 10, -4)
	_add_prop(CAVERN_ATLAS, Rect2(790, 70, 300, 360), grotto.position.x + 720, 150, 190, 0, 0, -5)
	var roots: Rect2 = room_bounds[&"poco"]
	_add_prop(CAVERN_ATLAS, Rect2(390, 470, 310, 210), roots.position.x + 210, 150, 210, 0, 0, -4)
	_add_prop(CAVERN_STRUCTURE_ATLAS, CAVE_WATER_REGION, roots.position.x + 520, 150, 420, 300, 8, -3)
	_add_prop(CAVERN_ATLAS, Rect2(1050, 485, 240, 190), roots.position.x + 780, 150, 150, 0, 0, -3)
	var cave: Rect2 = room_bounds[&"barricada"]
	_add_prop(CAVERN_STRUCTURE_ATLAS, CAVE_BRIDGE_REGION, cave.position.x + 300, 150, 360, 300, 10, -4)
	_add_prop(CAVERN_ATLAS, Rect2(540, 710, 220, 280), cave.position.x + 600, 150, 155, 0, 0, -4)
	_add_prop(CAVERN_ATLAS, Rect2(790, 700, 255, 290), cave.position.x + 920, 150, 180, 0, 0, -4)
	var deep: Rect2 = room_bounds[&"posto"]
	_add_prop(CAVERN_ATLAS, Rect2(60, 150, 650, 270), deep.position.x + 300, 150, 420, 310, 10, -4)
	_add_prop(CAVERN_ATLAS, Rect2(805, 70, 285, 355), deep.position.x + 740, 150, 180, 0, 0, -4)
	var sanctuary: Rect2 = room_bounds[&"arena"]
	_add_prop(CAVERN_ATLAS, Rect2(45, 755, 420, 230), sanctuary.position.x + 260, 150, 300, 220, 10, -5)
	_add_narrative(CAVERN_ATLAS, Rect2(1130, 715, 300, 280), sanctuary.position.x + 700, 150, 200, &"manifestacao")


func _build_npcs() -> void:
	_add_npc(&"dona_tereza", "DONA TEREZA", &"dona_tereza", 0, &"rua_cinzas", 120, 0)
	_add_npc(&"raimundo", "RAIMUNDO", &"ferido", 1, &"rua_cinzas", 185, 0)
	_add_npc(&"bento", "BENTO", &"artesao", 3, &"barracos", 610, 14)
	_add_npc(&"anselmo", "SEU ANSELMO", &"mercador", 6, &"praca_umbu", 650, 0)
	_add_npc(&"lia", "LIA", &"crianca", 4, &"praca_umbu", 440, 20)
	_add_npc(&"tome", "IRMÃO TOMÉ", &"sacristao", 7, &"igreja_velha", 430, 0)
	_add_npc(&"ze_lino", "ZÉ LINO", &"vigia", 1, &"telhados", 110, 0)
	_add_npc(&"mariano", "MARIANO", &"viajante", 6, &"praca_umbu", 850, 18)


func _add_npc(id: StringName, name_value: String, dialogue: StringName, atlas_index: int, room_id: StringName, local_x: float, walk_radius: float) -> void:
	var npc := NPCActor.new()
	npc.npc_id = id
	npc.display_name = name_value
	npc.dialogue_id = dialogue
	npc.atlas_index = atlas_index
	npc.idle_walk_radius = walk_radius
	add_child(npc)
	var bounds: Rect2 = room_bounds[room_id]
	npc.position = Vector2(bounds.position.x + local_x, 138)


func _add_prop(texture: Texture2D, region: Rect2, x: float, baseline: float, target_width: float, walkable_width: float, walkable_height: float, z: int) -> AtlasWorldProp:
	var prop := AtlasWorldProp.new().configure(texture, region, target_width, walkable_width, walkable_height, z)
	add_child(prop)
	prop.position = Vector2(x, baseline)
	return prop


func _add_narrative(texture: Texture2D, region: Rect2, x: float, baseline: float, target_width: float, dialogue: StringName) -> void:
	var interactable := NarrativeInteractable.new()
	interactable.dialogue_id = dialogue
	interactable.configure_visual(texture, region, target_width)
	add_child(interactable)
	interactable.position = Vector2(x, baseline)


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
	var home: Rect2 = room_bounds[&"casa_nilo"]
	var home_checkpoint := Checkpoint.new()
	home_checkpoint.checkpoint_id = &"vila_casa"
	home_checkpoint.show_visual = false
	add_child(home_checkpoint)
	home_checkpoint.position = Vector2(home.position.x + 92.0, 132.0)

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
	var underground: Rect2 = room_bounds[&"patio"]
	var underground_checkpoint := Checkpoint.new()
	underground_checkpoint.checkpoint_id = &"vila_subterraneo"
	add_child(underground_checkpoint)
	underground_checkpoint.position = Vector2(underground.position.x + 90.0, 132.0)

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
	_add_traversal_platform(Vector2(church.position.x + 214.0, 117.0), Vector2(9.0, 66.0), true)
	_add_traversal_platform(Vector2(church.position.x + 250.0, 117.0), Vector2(9.0, 66.0), true)
	_add_traversal_platform(Vector2(church.position.x + 278.0, 54.0), Vector2(64.0, 8.0), true)
	_add_traversal_platform(Vector2(roofs.position.x + 18.0, 75.0), Vector2(54.0, 8.0), false)

	# A habilidade de investida fica na rota alta, visível antes de ser alcançada.
	var dash_pickup := AbilityPickup.new()
	dash_pickup.ability_id = &"dash"
	dash_pickup.display_name = "PASSO DA POEIRA"
	dash_pickup.description = "C PARA ATRAVESSAR SELOS E VÃOS"
	add_child(dash_pickup)
	dash_pickup.position = Vector2(roofs.position.x + 890.0, 72.0)

	# Segredo na casa inicial: só abre no retorno com Pedra + Poeira.
	_add_traversal_platform(Vector2(home.position.x + 176.0, 112.0), Vector2(42.0, 7.0), false, &"dash")
	_add_traversal_platform(Vector2(home.position.x + 224.0, 82.0), Vector2(46.0, 7.0), false, &"dash")
	_add_traversal_platform(Vector2(home.position.x + 281.0, 72.0), Vector2(66.0, 7.0), false, &"dash")
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
	_add_connector(&"praca_armazem_alto", Vector2(square.position.x + 1165.0, 125.0), Vector2(warehouse.position.x + 1140.0, 125.0), &"dash", "TRILHA ALTA", &"armazem")
	_add_connector(&"praca_armazem_alto", Vector2(warehouse.position.x + 1140.0, 125.0), Vector2(square.position.x + 1165.0, 125.0), &"", "VOLTAR À PRAÇA", &"praca_umbu", true)

	# Atalho tardio: aberto pelo lado do Poço, devolve rapidamente à Igreja.
	_add_connector(&"poco_igreja_cripta", Vector2(well.position.x + 160.0, 112.0), Vector2(church.position.x + 40.0, 130.0), &"wall_jump", "DESCER À CRIPTA", &"igreja_velha")
	_add_connector(&"poco_igreja_cripta", Vector2(church.position.x + 40.0, 130.0), Vector2(well.position.x + 160.0, 112.0), &"", "TÚNEL DO POÇO", &"poco", true)

	# O clímax abre um retorno curto ao hub; o acesso inverso só existe depois disso.
	var sanctuary: Rect2 = room_bounds[&"arena"]
	var return_connector := WorldConnector.new()
	return_connector.connector_id = &"santuario_praca_retorno"
	return_connector.destination = Vector2(square.position.x + 1030.0, 130.0)
	return_connector.destination_room = &"praca_umbu"
	return_connector.display_name = "RETORNAR À PRAÇA"
	return_connector.required_flag = &"area01_encantado_discovered"
	add_child(return_connector)
	return_connector.position = Vector2(sanctuary.position.x + 1030.0, 128.0)
	_add_connector(&"santuario_praca_retorno", Vector2(square.position.x + 1030.0, 130.0), Vector2(sanctuary.position.x + 1030.0, 128.0), &"", "ATALHO DO SANTUÁRIO", &"arena", true)

	_add_lore_collectible(&"cordel_telhadista", "O HOMEM QUE ANDAVA NO VENTO", Vector2(roofs.position.x + 1115.0, 56.0))
	_add_lore_collectible(&"cordel_cripta", "VERSOS DA PEDRA ANTIGA", Vector2(warehouse.position.x + 1010.0, 118.0))
	_add_lore_collectible(&"cordel_raizes", "A CANTIGA DAS RAÍZES", Vector2(well.position.x + 700.0, 110.0))
	_add_lore_collectible(&"cordel_caverna", "A ESTRELA SOB A TERRA", Vector2(sanctuary.position.x + 450.0, 105.0))


func _add_traversal_platform(at: Vector2, size: Vector2, stone_style: bool, reveal_ability: StringName = &"") -> void:
	var platform := TraversalPlatform.new()
	platform.platform_size = size
	platform.stone_style = stone_style
	platform.reveal_ability = reveal_ability
	add_child(platform)
	platform.position = at


func _add_lore_collectible(id: StringName, display_name: String, at: Vector2) -> void:
	var collectible := LoreCollectible.new()
	collectible.collectible_id = id
	collectible.display_name = display_name
	add_child(collectible)
	collectible.position = at


func _hide_authored_ground(room: RoomController) -> void:
	var ground := room.get_node_or_null("Geometry/Ground") as CanvasItem
	if ground != null:
		ground.visible = false


func _add_home_backdrop(bounds: Rect2) -> void:
	_add_gradient_backdrop(bounds, Color("5a4130"), Color("211711"))
	# A arquitetura precisa ficar acima dos parallax das salas vizinhas. Sem isso,
	# a rua atravessava visualmente a parede quando a câmera se aproximava da porta.
	_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_WALL_REGION, bounds.get_center().x, 150.0, 920.0, 0.0, 0.0, -9)
	_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_LEFT_WALL_REGION, bounds.position.x + 52.0, 150.0, 118.0, 0.0, 0.0, -8)
	_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_RIGHT_WALL_REGION, bounds.end.x - 52.0, 150.0, 118.0, 0.0, 0.0, -8)
	_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_CEILING_REGION, bounds.get_center().x, 0.0, 920.0, 0.0, 0.0, -7)
	# Usa apenas o centro retangular do piso e sobrepõe levemente os módulos.
	# As bordas em perspectiva do sprite completo deixavam uma fenda escura.
	for index in 3:
		_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_FLOOR_REGION, bounds.position.x + 160.0 + index * 320.0, 242.0, 324.0, 0.0, 0.0, -6)
	_add_prop(CASA_ARCHITECTURE_ATLAS, HOME_WINDOW_REGION, bounds.position.x + 680.0, 115.0, 105.0, 0.0, 0.0, -4)


func _add_cave_backdrop(bounds: Rect2, deep: bool) -> void:
	_add_gradient_backdrop(bounds, Color("17171a") if deep else Color("231d19"), Color("070708"))
	var wall_region := CAVE_WALL_REGION if deep else UNDERGROUND_WALL_REGION
	var wall_width := 520.0
	for index in ceili(bounds.size.x / wall_width):
		var wall := _add_prop(CAVERN_STRUCTURE_ATLAS, wall_region, bounds.position.x + wall_width * (index + 0.5), 150.0, wall_width + 4.0, 0.0, 0.0, -34)
		wall.sprite.modulate = Color(0.56, 0.58, 0.61, 0.88) if deep else Color(0.50, 0.54, 0.58, 0.86)
		var lower_wall := _add_prop(CAVERN_STRUCTURE_ATLAS, wall_region, bounds.position.x + wall_width * (index + 0.5), 370.0, wall_width + 4.0, 0.0, 0.0, -35)
		lower_wall.sprite.modulate = Color(0.30, 0.32, 0.36, 0.92) if deep else Color(0.29, 0.30, 0.31, 0.92)
	if deep:
		for index in ceili(bounds.size.x / wall_width):
			var ceiling := _add_prop(CAVERN_STRUCTURE_ATLAS, CAVE_CEILING_REGION, bounds.position.x + wall_width * (index + 0.5), 8.0, wall_width + 4.0, 0.0, 0.0, -12)
			ceiling.sprite.modulate = Color(0.62, 0.64, 0.68, 0.92)
	var segment_width := 430.0
	for index in ceili(bounds.size.x / segment_width):
		var sprite := _atlas_sprite(CAVERN_ATLAS, CAVE_FLOOR_REGION)
		var scale_value := segment_width / CAVE_FLOOR_REGION.size.x
		sprite.scale = Vector2.ONE * scale_value
		sprite.position = Vector2(bounds.position.x + segment_width * (index + 0.5), 150.0 + CAVE_FLOOR_REGION.size.y * scale_value * 0.5)
		sprite.z_index = -2
		add_child(sprite)


func _add_home_doors(home: Rect2) -> void:
	var inside := TransitionDoor.new().configure_visual(CASA_ARCHITECTURE_ATLAS, HOME_DOOR_CLOSED_REGION, HOME_DOOR_OPEN_REGION, 90.0)
	inside.door_id = &"casa_nilo_saida"
	inside.destination = Vector2(home.end.x + 82.0, 138.0)
	inside.destination_room = &"rua_cinzas"
	inside.display_name = "SAIR PARA A RUA"
	add_child(inside)
	inside.position = Vector2(home.end.x - 105.0, 150.0)
	var outside := TransitionDoor.new().configure_visual(CASA_ARCHITECTURE_ATLAS, HOME_DOOR_CLOSED_REGION, HOME_DOOR_OPEN_REGION, 84.0)
	outside.door_id = &"casa_nilo_entrada"
	outside.destination = Vector2(home.end.x - 155.0, 138.0)
	outside.destination_room = &"casa_nilo"
	outside.display_name = "ENTRAR NA CASA"
	add_child(outside)
	outside.position = Vector2(home.end.x + 42.0, 150.0)
	_add_solid(Rect2(home.end.x - 16.0, -120.0, 16.0, 270.0))


func _add_gradient_backdrop(bounds: Rect2, top_color: Color, bottom_color: Color) -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([top_color, bottom_color])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = roundi(bounds.size.x)
	texture.height = 480
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(bounds.get_center().x, 120.0)
	sprite.z_index = -40
	add_child(sprite)


func _atlas_sprite(texture: Texture2D, region: Rect2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = region
	return sprite


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
