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

var room_bounds: Dictionary = {}
var art_sprites: Array[Sprite2D] = []
var occupied_only_sprites: Array[Sprite2D] = []


func configure(bounds_by_room: Dictionary) -> void:
	room_bounds = bounds_by_room
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
	_add(CASA_ATLAS, Rect2(420, 565, 330, 320), _x(&"rua_cinzas", 0.22), 150.0, 74.0)
	_add(CASA_ATLAS, Rect2(770, 600, 360, 285), _x(&"rua_cinzas", 0.76), 150.0, 92.0)
	_add(CASA_ATLAS, Rect2(1150, 600, 500, 285), _x(&"rua_cinzas", 0.94), 150.0, 105.0, true)


func _build_igreja() -> void:
	_add(IGREJA_ATLAS, Rect2(195, 35, 610, 380), _x(&"igreja_velha", 0.52), 150.0, 250.0)
	_add(IGREJA_ATLAS, Rect2(1060, 55, 280, 370), _x(&"igreja_velha", 0.19), 150.0, 55.0)
	_add(IGREJA_ATLAS, Rect2(70, 690, 390, 220), _x(&"igreja_velha", 0.83), 150.0, 66.0)


func _build_telhados_e_praca() -> void:
	_add(PRACA_ATLAS, Rect2(40, 45, 985, 150), _x(&"telhados", 0.28), 122.0, 245.0)
	_add(PRACA_ATLAS, Rect2(40, 245, 825, 150), _x(&"telhados", 0.72), 98.0, 225.0)
	_add(PRACA_ATLAS, Rect2(45, 455, 510, 155), _x(&"telhados", 0.52), 148.0, 128.0)
	_add(PRACA_ATLAS, Rect2(650, 425, 165, 225), _x(&"telhados", 0.47), 92.0, 36.0)
	_add(PRACA_ATLAS, Rect2(880, 260, 610, 570), _x(&"praca_umbu", 0.5), 150.0, 180.0)
	_add(PRACA_ATLAS, Rect2(35, 665, 415, 310), _x(&"praca_umbu", 0.18), 150.0, 125.0)
	_add(PRACA_ATLAS, Rect2(485, 680, 230, 300), _x(&"praca_umbu", 0.86), 150.0, 45.0)


func _build_barracos() -> void:
	_add(BARRACOS_ATLAS, Rect2(70, 75, 860, 390), _x(&"barracos", 0.35), 150.0, 285.0)
	_add(BARRACOS_ATLAS, Rect2(985, 120, 475, 350), _x(&"barracos", 0.79), 150.0, 150.0)
	_add(BARRACOS_ATLAS, Rect2(475, 525, 480, 225), _x(&"barracos", 0.57), 150.0, 110.0)
	_add(BARRACOS_ATLAS, Rect2(935, 770, 525, 205), _x(&"barracos", 0.91), 150.0, 115.0)


func _build_armazem_e_patio() -> void:
	_add(ARMAZEM_ATLAS, Rect2(25, 15, 850, 405), _x(&"armazem", 0.5), 150.0, 300.0)
	_add(ARMAZEM_ATLAS, Rect2(800, 425, 460, 185), _x(&"armazem", 0.3), 114.0, 105.0)
	_add(ARMAZEM_ATLAS, Rect2(885, 195, 620, 180), _x(&"armazem", 0.68), 100.0, 145.0)
	_add(ARMAZEM_ATLAS, Rect2(50, 545, 295, 215), _x(&"patio", 0.18), 150.0, 88.0)
	_add(ARMAZEM_ATLAS, Rect2(365, 545, 300, 235), _x(&"patio", 0.42), 150.0, 92.0)
	_add(ARMAZEM_ATLAS, Rect2(690, 600, 245, 195), _x(&"patio", 0.64), 150.0, 76.0)
	_add(ARMAZEM_ATLAS, Rect2(965, 615, 330, 180), _x(&"patio", 0.82), 150.0, 96.0)


func _build_beco_e_poco() -> void:
	_add(POCO_ATLAS, Rect2(55, 30, 500, 390), _x(&"beco", 0.22), 150.0, 135.0)
	_add(POCO_ATLAS, Rect2(570, 95, 510, 340), _x(&"beco", 0.58), 112.0, 135.0)
	_add(POCO_ATLAS, Rect2(1100, 170, 350, 255), _x(&"beco", 0.84), 124.0, 95.0)
	_add(POCO_ATLAS, Rect2(120, 425, 370, 315), _x(&"poco", 0.5), 150.0, 155.0)
	_add(POCO_ATLAS, Rect2(910, 500, 560, 225), _x(&"poco", 0.82), 150.0, 115.0)
	_add(POCO_ATLAS, Rect2(80, 770, 390, 215), _x(&"poco", 0.15), 150.0, 88.0)


func _build_barricada_e_posto() -> void:
	_add(POSTO_ATLAS, Rect2(20, 45, 690, 410), _x(&"barricada", 0.5), 150.0, 280.0, true)
	_add(POSTO_ATLAS, Rect2(735, 55, 285, 410), _x(&"barricada", 0.13), 150.0, 82.0, true)
	_add(POSTO_ATLAS, Rect2(1060, 55, 290, 410), _x(&"barricada", 0.87), 150.0, 82.0, true)
	_add(POSTO_ATLAS, Rect2(1340, 120, 360, 350), _x(&"posto", 0.57), 150.0, 180.0)
	_add(POSTO_ATLAS, Rect2(55, 480, 285, 380), _x(&"posto", 0.2), 150.0, 92.0)
	_add(POSTO_ATLAS, Rect2(1200, 600, 310, 240), _x(&"posto", 0.84), 150.0, 86.0, true)


func _build_arena() -> void:
	_add(ARENA_ATLAS, Rect2(430, 35, 690, 420), _x(&"arena", 0.5), 150.0, 260.0)
	_add(ARENA_ATLAS, Rect2(45, 25, 300, 430), _x(&"arena", 0.1), 150.0, 88.0)
	_add(ARENA_ATLAS, Rect2(1180, 25, 310, 430), _x(&"arena", 0.9), 150.0, 88.0)
	_add(ARENA_ATLAS, Rect2(20, 480, 600, 235), _x(&"arena", 0.25), 150.0, 145.0)
	_add(ARENA_ATLAS, Rect2(635, 470, 245, 235), _x(&"arena", 0.55), 150.0, 58.0)
	_add(ARENA_ATLAS, Rect2(890, 470, 200, 225), _x(&"arena", 0.68), 150.0, 48.0)
	_add(ARENA_ATLAS, Rect2(1090, 455, 410, 255), _x(&"arena", 0.8), 150.0, 100.0)


func _add(texture: Texture2D, region: Rect2, world_x: float, baseline: float, target_width: float, occupied_only := false) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = region
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var art_scale := target_width / region.size.x
	sprite.scale = Vector2.ONE * art_scale
	sprite.position = Vector2(round(world_x), round(baseline - region.size.y * art_scale * 0.5))
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
