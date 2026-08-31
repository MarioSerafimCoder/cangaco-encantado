extends Node

var failures: Array[String] = []
var world: VilaGraybox
var player: NiloPlayer
var director: CameraDirector
var house: RoomController
var street: RoomController


func _ready() -> void:
	await get_tree().process_frame
	get_tree().paused = false
	world = $Main/VilaDoUmbuzeiro as VilaGraybox
	player = $Main/Nilo as NiloPlayer
	director = $Main/CameraDirector as CameraDirector
	house = _find_room(&"casa_nilo")
	street = _find_room(&"rua_cinzas")
	_disable_combat_actors()
	_validate_room_triggers()
	await _validate_house_corridor()
	await _validate_door_roundtrip()
	await _validate_street_corridor()
	_finish()


func _find_room(room_id: StringName) -> RoomController:
	for candidate in get_tree().get_nodes_in_group("production_rooms"):
		var room := candidate as RoomController
		if room != null and room.room_id == room_id:
			return room
	return null


func _disable_combat_actors() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		if enemy is CollisionObject2D:
			(enemy as CollisionObject2D).collision_layer = 0
			(enemy as CollisionObject2D).collision_mask = 0


func _validate_room_triggers() -> void:
	for room in [house, street]:
		if room == null:
			failures.append("Uma das duas primeiras salas não foi carregada.")
			continue
		var trigger := room.get_node_or_null("Gameplay/Triggers/RoomArea/CollisionShape2D") as CollisionShape2D
		if trigger == null or trigger.shape == null:
			failures.append("RoomArea sem shape em %s." % room.room_id)


func _validate_house_corridor() -> void:
	director.snap_to_room(&"casa_nilo")
	await _place_player(Vector2(30, 138))
	await _walk_right_until(500.0, 420, "interior da Casa de Nilo")
	_validate_camera_bounds(house, "Casa de Nilo")


func _validate_door_roundtrip() -> void:
	var exit_door := house.get_node("Gameplay/Doors/InteriorDoor") as TransitionDoor
	var entrance_door := house.get_node("Gameplay/Doors/ExteriorDoor") as TransitionDoor
	await _use_door(exit_door)
	if player.global_position.distance_to(exit_door.destination) > 1.0:
		failures.append("A porta de saída não posicionou Nilo na Rua das Cinzas.")
	_validate_camera_bounds(street, "Rua das Cinzas após sair da casa")
	_validate_fade(exit_door, "porta de saída")
	await _use_door(entrance_door)
	if player.global_position.distance_to(entrance_door.destination) > 1.0:
		failures.append("A porta de entrada não devolveu Nilo à Casa de Nilo.")
	_validate_camera_bounds(house, "Casa de Nilo após retornar")
	_validate_fade(entrance_door, "porta de entrada")
	await _use_door(exit_door)


func _validate_street_corridor() -> void:
	await _place_player(Vector2(722, 138))
	director.snap_to_room(&"rua_cinzas")
	await _walk_right_until(1870.0, 720, "Rua das Cinzas")
	_validate_camera_bounds(street, "Rua das Cinzas")


func _place_player(at: Vector2) -> void:
	player.is_dead = false
	player.narrative_locked = false
	player.velocity = Vector2.ZERO
	player.global_position = at
	for _frame in 6:
		await get_tree().physics_frame


func _walk_right_until(target_x: float, maximum_frames: int, label: String) -> void:
	var start_x := player.global_position.x
	Input.action_press("move_right")
	for _frame in maximum_frames:
		await get_tree().physics_frame
		if player.global_position.x >= target_x:
			break
	Input.action_release("move_right")
	await get_tree().physics_frame
	if player.global_position.x < target_x:
		failures.append("Nilo ficou preso em %s: avançou de %.1f até %.1f; esperado %.1f." % [label, start_x, player.global_position.x, target_x])
	if not player.is_on_floor():
		failures.append("Nilo não terminou a travessia de %s apoiado no piso." % label)


func _use_door(door: TransitionDoor) -> void:
	await _place_player(door.global_position + Vector2(0, -12))
	door.call("_on_body_entered", player)
	door.call("_transition")
	await get_tree().create_timer(0.62).timeout


func _validate_camera_bounds(room: RoomController, label: String) -> void:
	if director.active_room != room:
		failures.append("Câmera não selecionou %s." % label)
		return
	var bounds := room.get_global_camera_bounds()
	var camera := player.camera
	if camera.limit_left != roundi(bounds.position.x) or camera.limit_right != roundi(bounds.end.x) or camera.limit_top != roundi(bounds.position.y) or camera.limit_bottom != roundi(bounds.end.y):
		failures.append("Limites da câmera incorretos em %s." % label)


func _validate_fade(door: TransitionDoor, label: String) -> void:
	var fade := door.get_node_or_null("FadeLayer/Fade") as ColorRect
	if fade == null:
		failures.append("Fade ausente na %s." % label)
		return
	if absf(fade.color.a) > 0.01 or fade.offset_left != 0.0 or fade.offset_top != 0.0 or fade.offset_right != 0.0 or fade.offset_bottom != 0.0:
		failures.append("Fade deslocado ou ainda visível na %s." % label)


func _finish() -> void:
	Input.action_release("move_right")
	if failures.is_empty():
		print("FIRST_ROOMS_TRAVERSAL_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
