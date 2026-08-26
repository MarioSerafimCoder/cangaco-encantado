extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	WorldState.region_states["vila_umbuzeiro"] = WorldState.OCCUPIED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)
	await get_tree().process_frame
	var rooms := get_tree().get_nodes_in_group("production_rooms")
	var expected_rooms := {
		&"casa_nilo": 320.0,
		&"rua_cinzas": 640.0,
		&"igreja_velha": 320.0,
		&"telhados": 640.0,
		&"praca_umbu": 640.0,
		&"barracos": 640.0,
		&"armazem": 640.0,
		&"patio": 640.0,
		&"beco": 320.0,
		&"poco": 320.0,
		&"barricada": 640.0,
		&"posto": 320.0,
		&"arena": 640.0,
	}
	if rooms.size() != expected_rooms.size():
		failures.append("Todas as treze áreas devem usar RoomController; encontradas: %d." % rooms.size())
		_finish()
		return
	var by_id: Dictionary = {}
	for candidate in rooms:
		var room := candidate as RoomController
		by_id[room.room_id] = room
		_validate_identity_and_bounds(room, expected_rooms)
		_validate_entrances(room)
		_validate_geometry(room)
		_validate_parallax(room)
		_validate_world_state(room)
	for room_id in expected_rooms:
		if not by_id.has(room_id):
			failures.append("Sala de produção ausente: %s." % room_id)
	if by_id.has(&"rua_cinzas"):
		_validate_spawns(by_id[&"rua_cinzas"], 2)
		await _validate_player_baseline(by_id[&"rua_cinzas"])
	if by_id.has(&"telhados"):
		_validate_roof_collisions(by_id[&"telhados"])
	if by_id.has(&"barracos"):
		_validate_spawns(by_id[&"barracos"], 1)
	if by_id.has(&"armazem"):
		_validate_spawns(by_id[&"armazem"], 2)
	if by_id.has(&"patio"):
		_validate_spawns(by_id[&"patio"], 2)
	if by_id.has(&"beco"):
		_validate_spawns(by_id[&"beco"], 1)
	if by_id.has(&"arena"):
		_validate_spawns(by_id[&"arena"], 1)
	_validate_no_hybrid_decorator()
	await _validate_camera_director(by_id)
	_validate_visual_cohesion(rooms)
	_validate_character_shadows()
	_validate_player_sprite_regions()
	_validate_enemy_sprite_regions()
	_validate_save_payload_roundtrip()
	_finish()


func _validate_identity_and_bounds(room: RoomController, expected_rooms: Dictionary) -> void:
	if not expected_rooms.has(room.room_id):
		failures.append("RoomController registrou ID inesperado: %s." % room.room_id)
	elif not is_equal_approx(room.local_bounds.size.x, float(expected_rooms[room.room_id])):
		failures.append("Largura inesperada na sala %s." % room.room_id)
	if room.local_bounds.size.x <= 0.0 or room.local_bounds.size.y <= 0.0:
		failures.append("Bounds da sala são inválidos.")
	if room.camera_bounds.size.x < 320.0 or room.camera_bounds.size.y < 180.0:
		failures.append("Camera bounds são menores que o viewport interno.")
	if not room.camera_bounds.encloses(room.local_bounds):
		failures.append("Camera bounds não abrangem a área jogável completa.")
	if not is_equal_approx(room.camera_bounds.position.y, -60.0) or not is_equal_approx(room.camera_bounds.size.y, 300.0):
		failures.append("Sala %s não usa o enquadramento vertical padronizado." % room.room_id)


func _validate_entrances(room: RoomController) -> void:
	for entrance_id in [&"LEFT_ENTRANCE", &"RIGHT_ENTRANCE"]:
		var marker := room.get_entrance(entrance_id)
		if marker == null:
			failures.append("Entrada ausente: %s." % entrance_id)
		elif not room.local_bounds.has_point(marker.position):
			failures.append("Entrada %s está fora dos bounds." % entrance_id)


func _validate_spawns(room: RoomController, minimum_count: int) -> void:
	var spawn_root := room.get_node_or_null("Gameplay/EnemySpawns")
	if spawn_root == null or spawn_root.get_child_count() < minimum_count:
		failures.append("Sala %s precisa de ao menos %d EnemySpawn(s)." % [room.room_id, minimum_count])
		return
	var ids: Dictionary = {}
	for child in spawn_root.get_children():
		if child is not EnemySpawn:
			failures.append("Spawn de inimigo não usa EnemySpawn: %s." % child.name)
			continue
		var spawn := child as EnemySpawn
		if spawn.spawn_id == &"" or ids.has(spawn.spawn_id):
			failures.append("spawn_id vazio ou duplicado: %s." % spawn.spawn_id)
		ids[spawn.spawn_id] = true
		if not room.local_bounds.has_point(spawn.position):
			failures.append("Spawn %s está fora da sala." % spawn.spawn_id)
		if spawn.position.y >= 150.0:
			failures.append("Spawn %s começa dentro do chão." % spawn.spawn_id)


func _validate_geometry(room: RoomController) -> void:
	var collision := room.get_node_or_null("Geometry/Ground/GroundCollision/CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		failures.append("Chão principal não possui CollisionShape2D.")
		return
	var shape := collision.shape as RectangleShape2D
	if shape == null or not is_equal_approx(shape.size.x, room.local_bounds.size.x):
		failures.append("Colisão do chão não acompanha a largura visual da sala.")
	var ground := room.get_node("Geometry/Ground/GroundCollision") as StaticBody2D
	var top := ground.position.y - shape.size.y * 0.5
	if not is_equal_approx(top, 150.0):
		failures.append("Baseline física deve coincidir com y=150; encontrada: %.2f." % top)


func _validate_parallax(room: RoomController) -> void:
	if room.room_id == &"rua_cinzas":
		_validate_parallax_paths(room, {
			"Environment/Sky": Vector2(0.03, 1.0),
			"Environment/FarBackground": Vector2(0.14, 1.0),
			"Environment/MidBackground": Vector2(0.5, 1.0),
			"Environment/Foreground": Vector2(1.1, 1.0),
		})
		return
	_validate_parallax_paths(room, {
		"Environment/Parallax/Sky": Vector2(0.03, 1.0),
		"Environment/Parallax/FarMountains": Vector2(0.16, 1.0),
		"Environment/Parallax/Village": Vector2(0.48, 1.0),
	})


func _validate_parallax_paths(room: RoomController, expected: Dictionary) -> void:
	for path in expected:
		var layer := room.get_node_or_null(path) as CameraParallaxLayer
		if layer == null:
			failures.append("Camada não usa paralaxe baseado em Camera2D: %s." % path)
		elif not layer.scroll_scale.is_equal_approx(expected[path]):
			failures.append("Ratio inesperado na camada %s." % path)


func _validate_world_state(room: RoomController) -> void:
	var occupied := room.get_node("Environment/OccupiedOnly") as CanvasItem
	var liberated := room.get_node("Environment/LiberatedOnly") as CanvasItem
	if not occupied.visible or liberated.visible:
		failures.append("Estado OCCUPIED não ativou os grupos visuais corretos.")
	WorldState.region_states["vila_umbuzeiro"] = WorldState.LIBERATED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.LIBERATED)
	if occupied.visible or not liberated.visible:
		failures.append("Estado LIBERATED não alternou os grupos visuais corretos.")
	WorldState.region_states["vila_umbuzeiro"] = WorldState.OCCUPIED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)


func _validate_roof_collisions(room: RoomController) -> void:
	var expected_tops := {
		"Geometry/Roof1": 112.0,
		"Geometry/Roof2": 88.0,
		"Geometry/Roof3": 116.0,
		"Geometry/Roof4": 82.0,
	}
	for path in expected_tops:
		var body := room.get_node_or_null(path) as StaticBody2D
		if body == null:
			failures.append("Telhado sem corpo físico: %s." % path)
			continue
		var collision := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		var shape := collision.shape as RectangleShape2D if collision != null else null
		if shape == null:
			failures.append("Telhado sem RectangleShape2D: %s." % path)
			continue
		var top := body.position.y - shape.size.y * 0.5
		if absf(top - float(expected_tops[path])) > 0.1:
			failures.append("Colisão desalinhada no telhado %s: %.2f." % [path, top])


func _validate_no_hybrid_decorator() -> void:
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var decorator := world.get_node_or_null("VilaArtDecorator") as VilaArtDecorator
	if decorator != null:
		failures.append("O compositor híbrido global ainda está ativo depois da migração.")


func _validate_camera_director(by_id: Dictionary) -> void:
	var main := $Main
	var director := main.get_node_or_null("CameraDirector") as CameraDirector
	var player := main.get_node("Nilo") as NiloPlayer
	if director == null:
		failures.append("Gerenciador central de câmera não foi encontrado.")
		return
	player.set_physics_process(false)
	player.global_position = Vector2(300, 138)
	await get_tree().physics_frame
	player.global_position = Vector2(340, 138)
	await get_tree().physics_frame
	var target := (by_id[&"rua_cinzas"] as RoomController).get_global_camera_bounds()
	if not director.is_transitioning():
		failures.append("Troca Casa–Rua aplicou limites instantaneamente, sem transição.")
	if player.camera.limit_left == roundi(target.position.x) and player.camera.limit_right == roundi(target.end.x):
		failures.append("Câmera saltou diretamente para os limites da sala seguinte.")
	for _frame in 30:
		await get_tree().physics_frame
	if player.camera.limit_left != roundi(target.position.x) or player.camera.limit_right != roundi(target.end.x):
		failures.append("Câmera não concluiu a transição nos limites da Rua.")
	player.set_physics_process(true)


func _validate_visual_cohesion(rooms: Array[Node]) -> void:
	var expected_tint := Color("f0e6db")
	for candidate in rooms:
		var room := candidate as RoomController
		var environment := room.get_node_or_null("Environment") as CanvasItem
		if environment == null or not environment.self_modulate.is_equal_approx(expected_tint):
			failures.append("Sala %s não recebeu o perfil cromático comum." % room.room_id)
		for sprite_candidate in room.find_children("*", "Sprite2D", true, false):
			var sprite := sprite_candidate as Sprite2D
			if sprite.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
				failures.append("Sprite sem filtro nearest na sala %s: %s." % [room.room_id, sprite.name])


func _validate_character_shadows() -> void:
	for scene_path in [
		"res://scenes/player/player.tscn",
		"res://scenes/enemies/saqueador.tscn",
		"res://scenes/enemies/pistoleiro.tscn",
		"res://scenes/bosses/ze_tranca.tscn",
	]:
		var packed := load(scene_path) as PackedScene
		var actor := packed.instantiate()
		if actor.get_node_or_null("ContactShadow") == null:
			failures.append("Personagem sem sombra de contato: %s." % scene_path)
		actor.free()


func _validate_enemy_sprite_regions() -> void:
	for scene_path in [
		"res://scenes/enemies/saqueador.tscn",
		"res://scenes/enemies/pistoleiro.tscn",
		"res://scenes/bosses/ze_tranca.tscn",
	]:
		var packed := load(scene_path) as PackedScene
		var actor := packed.instantiate()
		var visual := actor.get_node("Visual") as MvpSpriteAnimator
		var image := visual.texture.get_image()
		for frame_region in visual.get_profile_regions_for_validation():
			if frame_region.position.x < 0.0 or frame_region.position.y < 0.0 or frame_region.end.x > image.get_width() or frame_region.end.y > image.get_height():
				failures.append("Região de sprite fora da folha em %s: %s." % [scene_path, frame_region])
				continue
			if _region_touches_opaque_vertical_border(image, frame_region):
				failures.append("Sprite ainda toca o limite vertical de corte em %s: %s." % [scene_path, frame_region])
		actor.free()


func _validate_player_sprite_regions() -> void:
	var player := get_tree().get_first_node_in_group("player") as NiloPlayer
	if player == null:
		failures.append("Nilo não foi encontrado para validar as novas folhas.")
		return
	for profile_set in player.visual.get_profile_sets_for_validation():
		var sprite_texture := profile_set["texture"] as Texture2D
		if sprite_texture == null:
			failures.append("Uma das novas folhas de Nilo não foi carregada.")
			continue
		var image := sprite_texture.get_image()
		for profile in profile_set["profiles"]:
			var frame_region: Rect2 = profile["region"]
			if frame_region.position.x < 0.0 or frame_region.position.y < 0.0 or frame_region.end.x > image.get_width() or frame_region.end.y > image.get_height():
				failures.append("Região de Nilo fora da folha: %s." % frame_region)
			elif _region_touches_opaque_vertical_border(image, frame_region):
				failures.append("Pose de Nilo ainda toca o corte vertical: %s." % frame_region)


func _region_touches_opaque_vertical_border(image: Image, region: Rect2) -> bool:
	var left := roundi(region.position.x)
	var top := roundi(region.position.y)
	var right := roundi(region.end.x) - 1
	var bottom := roundi(region.end.y) - 1
	for x in range(left, right + 1):
		# Ignora apenas o halo subvisual de 1-4% deixado pelo gerador,
		# mas rejeita qualquer pixel efetivamente visível na borda.
		if image.get_pixel(x, top).a > 0.07 or image.get_pixel(x, bottom).a > 0.07:
			return true
	return false


func _validate_save_payload_roundtrip() -> void:
	var payload := {
		"game_state": GameState.to_dictionary(),
		"world_state": WorldState.to_dictionary(),
	}
	var parsed = JSON.parse_string(JSON.stringify(payload))
	if parsed is not Dictionary:
		failures.append("Payload do save não completa roundtrip JSON.")
		return
	if not parsed.has("game_state") or not parsed.has("world_state"):
		failures.append("Payload do save perdeu os blocos de estado obrigatórios.")
	elif not parsed["world_state"].has("region_states"):
		failures.append("WorldState não preserva region_states no save.")


func _validate_player_baseline(room: RoomController) -> void:
	var player := get_tree().get_first_node_in_group("player") as NiloPlayer
	var entrance := room.get_entrance(&"LEFT_ENTRANCE")
	player.global_position = entrance.global_position
	player.velocity = Vector2.ZERO
	for _frame in 8:
		await get_tree().physics_frame
	if not player.is_on_floor():
		failures.append("Player spawn da entrada esquerda não repousa no chão.")
	if absf((player.global_position.y + 12.0) - 150.0) > 0.6:
		failures.append("Collider de Nilo não fecha na baseline y=150.")
	var visual_foot := player.global_position.y + player.visual.normalized_baseline_offset
	if absf(visual_foot - 150.0) > 0.8:
		failures.append("Pé visual de Nilo não coincide com a baseline: %.2f." % visual_foot)


func _finish() -> void:
	if failures.is_empty():
		print("ROOM_PRODUCTION_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
