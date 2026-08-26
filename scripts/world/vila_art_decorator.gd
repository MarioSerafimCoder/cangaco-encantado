class_name VilaArtDecorator
extends Node2D

const CASA_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/01_casa_nilo_e_rua_props.png")
const IGREJA_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/02_igreja_velha_e_checkpoint.png")
const PRACA_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/03_telhados_e_praca_umbu.png")
const BARRACOS_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/04_barracos_queimados.png")
const ARMAZEM_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/05_armazem_e_patio.png")
const POCO_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/06_beco_e_poco_romaozinho.png")
const POSTO_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/07_barricada_e_posto_comando.png")
const ARENA_ATLAS := preload("res://assets/environments/vila_umbuzeiro/atlases/08_arena_ze_tranca.png")
const CIVIL_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/01_arquitetura_civil_casas_igreja_beco.png")
const MILITARY_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/02_arquitetura_armazem_patio_barricada.png")
const GROUND_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/03_sistema_de_chao_e_transicoes.png")
const FILLER_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/05_conjuntos_de_transicao_e_preenchimento.png")
const ATMOSPHERE_ATLAS := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_5/06_elementos_atmosfericos.png")
const STREET_GROUND := preload("res://assets/environments/vila_umbuzeiro/generated_0_2_7/rua_chao_continuo.png")
const PARALLAX_320_SCENE := preload("res://scenes/world/vila_umbuzeiro/shared/vila_parallax_320.tscn")
const PARALLAX_640_SCENE := preload("res://scenes/world/vila_umbuzeiro/shared/vila_parallax_640.tscn")

const REMAINING_ROOM_IDS := [&"casa_nilo", &"igreja_velha", &"armazem", &"patio", &"beco", &"poco", &"barricada"]

var room_bounds: Dictionary = {}
var art_sprites: Array[Sprite2D] = []
var occupied_only_sprites: Array[Sprite2D] = []


func configure(bounds_by_room: Dictionary) -> void:
	room_bounds = bounds_by_room
	_build_remaining_room_layers()
	_build_casa_e_rua()
	_build_igreja()
	_build_telhados_e_praca()
	_build_barracos()
	_build_armazem_e_patio()
	_build_beco_e_poco()
	_build_barricada_e_posto()
	_build_arena()
	EventBus.world_state_changed.connect(_on_world_state_changed)
	_refresh_world_state()


func _build_casa_e_rua() -> void:
	_add(CASA_ATLAS, Rect2(65, 50, 590, 465), _x(&"casa_nilo", 0.5), 150.0, 250.0)


func _build_igreja() -> void:
	_add(IGREJA_ATLAS, Rect2(195, 35, 610, 380), _x(&"igreja_velha", 0.52), 150.0, 250.0)
	_add(IGREJA_ATLAS, Rect2(70, 690, 390, 220), _x(&"igreja_velha", 0.83), 150.0, 66.0)


func _build_telhados_e_praca() -> void:
	pass


func _build_barracos() -> void:
	pass


func _build_armazem_e_patio() -> void:
	_add(ARMAZEM_ATLAS, Rect2(25, 15, 850, 405), _x(&"armazem", 0.5), 150.0, 300.0)
	_add(ARMAZEM_ATLAS, Rect2(800, 425, 460, 185), _x(&"armazem", 0.3), 114.0, 105.0)
	_add(ARMAZEM_ATLAS, Rect2(885, 195, 620, 180), _x(&"armazem", 0.68), 100.0, 145.0)
	_add(ARMAZEM_ATLAS, Rect2(50, 545, 295, 215), _x(&"patio", 0.18), 150.0, 88.0)
	_add(ARMAZEM_ATLAS, Rect2(365, 545, 300, 235), _x(&"patio", 0.42), 150.0, 92.0)
	_add(ARMAZEM_ATLAS, Rect2(690, 600, 245, 195), _x(&"patio", 0.64), 150.0, 76.0)
	_add(ARMAZEM_ATLAS, Rect2(965, 615, 330, 180), _x(&"patio", 0.82), 150.0, 96.0)
	_add(FILLER_ATLAS, Rect2(840, 100, 400, 340), _x(&"armazem", 0.82), 150.0, 118.0, false, 4)
	_add(MILITARY_ATLAS, Rect2(625, 84, 384, 379), _x(&"patio", 0.5), 150.0, 150.0, false, 3)


func _build_beco_e_poco() -> void:
	_add(POCO_ATLAS, Rect2(55, 30, 500, 390), _x(&"beco", 0.22), 150.0, 135.0)
	_add(POCO_ATLAS, Rect2(570, 95, 510, 340), _x(&"beco", 0.58), 112.0, 135.0)
	_add(POCO_ATLAS, Rect2(1100, 170, 350, 255), _x(&"beco", 0.84), 124.0, 95.0)
	_add(POCO_ATLAS, Rect2(120, 425, 370, 315), _x(&"poco", 0.5), 150.0, 155.0)
	_add(POCO_ATLAS, Rect2(910, 500, 560, 225), _x(&"poco", 0.82), 150.0, 115.0)
	_add(POCO_ATLAS, Rect2(80, 770, 390, 215), _x(&"poco", 0.15), 150.0, 88.0)
	_add(CIVIL_ATLAS, Rect2(553, 536, 402, 351), _x(&"beco", 0.5), 150.0, 112.0, false, -1)
	_add(CIVIL_ATLAS, Rect2(77, 29, 438, 460), _x(&"beco", 0.08), 150.0, 88.0, false, -2)
	_add(FILLER_ATLAS, Rect2(420, 500, 420, 320), _x(&"poco", 0.78), 150.0, 112.0, false, 3)


func _build_barricada_e_posto() -> void:
	_add(POSTO_ATLAS, Rect2(20, 45, 690, 410), _x(&"barricada", 0.5), 150.0, 280.0, true)
	_add(POSTO_ATLAS, Rect2(735, 55, 285, 410), _x(&"barricada", 0.13), 150.0, 82.0, true)
	_add(POSTO_ATLAS, Rect2(1060, 55, 290, 410), _x(&"barricada", 0.87), 150.0, 82.0, true)
	_add(MILITARY_ATLAS, Rect2(432, 528, 463, 360), _x(&"barricada", 0.16), 150.0, 118.0, true, 3)


func _build_arena() -> void:
	pass


func _build_remaining_room_layers() -> void:
	for room_id in REMAINING_ROOM_IDS:
		var bounds: Rect2 = room_bounds[room_id]
		var parallax_scene: PackedScene = PARALLAX_320_SCENE if bounds.size.x <= 320.0 else PARALLAX_640_SCENE
		var parallax := parallax_scene.instantiate() as Node2D
		parallax.name = "SpriteParallax_%s" % room_id
		parallax.position = bounds.position
		add_child(parallax)
		for layer in parallax.get_children():
			if layer is CameraParallaxLayer:
				(layer as CameraParallaxLayer).camera_anchor = Vector2(bounds.size.x * 0.5, 90.0)
				(layer as CameraParallaxLayer).activation_bounds = Rect2(-200.0, -120.0, bounds.size.x + 400.0, 420.0)
		_add_ground_for_room(room_id)
		_add_atmosphere_for_room(room_id)


func _add_ground_for_room(room_id: StringName) -> void:
	var bounds: Rect2 = room_bounds[room_id]
	var region := Rect2(13, 216, 440, 180)
	if room_id == &"igreja_velha" or room_id == &"poco":
		region = Rect2(474, 216, 394, 180)
	elif room_id == &"armazem" or room_id == &"patio" or room_id == &"barricada":
		region = Rect2(19, 520, 475, 166)
	var segment_count := ceili(bounds.size.x / 320.0)
	for segment_index in segment_count:
		var target_width := minf(320.0, bounds.size.x - segment_index * 320.0)
		# A margem de 10 px para cada lado cobre tanto a emenda interna quanto
		# as bordas arredondadas entre salas, sem deixar o fundo cinza aparecer.
		target_width += 20.0
		var visual_scale := target_width / region.size.x
		# A faixa frontal sobe o suficiente para sobrepor a rua contínua. A arte
		# possui alguns pixels transparentes no topo e não pode apenas encostar.
		var visual_bottom := 140.0 + region.size.y * visual_scale
		var segment_center := bounds.position.x + segment_index * 320.0 + 160.0
		_add(GROUND_ATLAS, region, segment_center, visual_bottom, target_width, false, 0)
	_add_street_surface(room_id)


func _add_street_surface(room_id: StringName) -> void:
	var bounds: Rect2 = room_bounds[room_id]
	var sprite := Sprite2D.new()
	sprite.texture = STREET_GROUND
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = Rect2(0, 273, 2172, 100)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(bounds.size.x / 2172.0, 0.16)
	sprite.position = Vector2(bounds.get_center().x, 142.0)
	sprite.z_index = -1
	add_child(sprite)
	art_sprites.append(sprite)


func _add_atmosphere_for_room(room_id: StringName) -> void:
	var bounds: Rect2 = room_bounds[room_id]
	_add(ATMOSPHERE_ATLAS, Rect2(82, 79, 1385, 70), bounds.get_center().x, 54.0, minf(bounds.size.x * 0.86, 300.0), false, -90)
	if room_id == &"casa_nilo":
		_add(ATMOSPHERE_ATLAS, Rect2(950, 525, 100, 110), bounds.position.x + bounds.size.x * 0.78, 62.0, 20.0, false, -89)


func _add(texture: Texture2D, region: Rect2, world_x: float, baseline: float, target_width: float, occupied_only := false, z_index_value := 0) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = region
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var art_scale := target_width / region.size.x
	sprite.scale = Vector2.ONE * art_scale
	sprite.position = Vector2(round(world_x), round(baseline - region.size.y * art_scale * 0.5))
	sprite.z_index = z_index_value
	add_child(sprite)
	art_sprites.append(sprite)
	if occupied_only:
		occupied_only_sprites.append(sprite)


func _x(room_id: StringName, ratio: float) -> float:
	var bounds: Rect2 = room_bounds[room_id]
	return bounds.position.x + bounds.size.x * ratio


func _on_world_state_changed(region_id: StringName, _state: StringName) -> void:
	if region_id == &"vila_umbuzeiro":
		_refresh_world_state()


func _refresh_world_state() -> void:
	var liberated := WorldState.is_vila_liberated()
	for sprite in art_sprites:
		sprite.modulate = Color.WHITE if liberated else Color(0.88, 0.8, 0.76, 1.0)
	for sprite in occupied_only_sprites:
		sprite.visible = not liberated
