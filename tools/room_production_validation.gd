extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	WorldState.region_states["vila_umbuzeiro"] = WorldState.OCCUPIED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)
	await get_tree().process_frame
	var rooms := get_tree().get_nodes_in_group("production_rooms")
	if rooms.size() != 1:
		failures.append("A iteração deve possuir exatamente uma sala no pipeline de produção; encontradas: %d." % rooms.size())
		_finish()
		return
	var room := rooms[0] as RoomController
	_validate_identity_and_bounds(room)
	_validate_entrances(room)
	_validate_spawns(room)
	_validate_geometry(room)
	_validate_parallax(room)
	_validate_world_state(room)
	await _validate_player_baseline(room)
	_finish()


func _validate_identity_and_bounds(room: RoomController) -> void:
	if room.room_id != &"rua_cinzas":
		failures.append("RoomController não registrou room_id rua_cinzas.")
	if room.local_bounds.size.x <= 0.0 or room.local_bounds.size.y <= 0.0:
		failures.append("Bounds da sala são inválidos.")
	if room.camera_bounds.size.x < 320.0 or room.camera_bounds.size.y < 180.0:
		failures.append("Camera bounds são menores que o viewport interno.")
	if not room.camera_bounds.encloses(room.local_bounds):
		failures.append("Camera bounds não abrangem a área jogável completa.")


func _validate_entrances(room: RoomController) -> void:
	for entrance_id in [&"LEFT_ENTRANCE", &"RIGHT_ENTRANCE"]:
		var marker := room.get_entrance(entrance_id)
		if marker == null:
			failures.append("Entrada ausente: %s." % entrance_id)
		elif not room.local_bounds.has_point(marker.position):
			failures.append("Entrada %s está fora dos bounds." % entrance_id)


func _validate_spawns(room: RoomController) -> void:
	var spawn_root := room.get_node_or_null("Gameplay/EnemySpawns")
	if spawn_root == null or spawn_root.get_child_count() < 2:
		failures.append("Rua das Cinzas precisa de spawns visuais para Saqueador e Pistoleiro.")
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
	var expected := {
		"Environment/Sky": Vector2(0.03, 1.0),
		"Environment/FarBackground": Vector2(0.14, 1.0),
		"Environment/MidBackground": Vector2(0.5, 1.0),
		"Environment/Foreground": Vector2(1.1, 1.0),
	}
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
	var visual_foot := player.global_position.y + player.visual.position.y + 32.0 * player.visual.scale.y
	if absf(visual_foot - 150.0) > 0.8:
		failures.append("Pé visual de Nilo não coincide com a baseline: %.2f." % visual_foot)
	var expected_camera := room.get_global_camera_bounds()
	if player.camera.limit_left != roundi(expected_camera.position.x) or player.camera.limit_right != roundi(expected_camera.end.x):
		failures.append("Entrada na sala não aplicou camera bounds próprios.")
	player.global_position = room.to_global(Vector2(-20.0, 138.0))
	player.velocity = Vector2.ZERO
	for _frame in 4:
		await get_tree().physics_frame
	if player.camera.limit_left == roundi(expected_camera.position.x) and player.camera.limit_right == roundi(expected_camera.end.x):
		failures.append("Saída da sala não restaurou os camera bounds do mundo.")


func _finish() -> void:
	if failures.is_empty():
		print("ROOM_PRODUCTION_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
