extends Node

const OUTPUT_DIRECTORY := "res://prints_do_jogo/iteracao_0_2_5"


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	var world := main.get_node("VilaDoUmbuzeiro") as VilaGraybox
	var nilo := main.get_node("Nilo") as NiloPlayer
	var camera := nilo.camera
	var hud := main.get_node("HUD") as GameHUD
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	WorldState.region_states["vila_umbuzeiro"] = WorldState.OCCUPIED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)
	await get_tree().process_frame
	await get_tree().process_frame
	_freeze_enemies()
	await _capture_room(world, nilo, camera, hud, &"telhados", "04_telhados.png")
	await _capture_room(world, nilo, camera, hud, &"praca_umbu", "05_praca_occupied.png")
	await _capture_room(world, nilo, camera, hud, &"barracos", "06_barracos.png")
	await _capture_room(world, nilo, camera, hud, &"posto", "12_posto.png")
	await _capture_room(world, nilo, camera, hud, &"arena", "13_arena.png")
	WorldState.region_states["vila_umbuzeiro"] = WorldState.LIBERATED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.LIBERATED)
	await get_tree().process_frame
	await _capture_room(world, nilo, camera, hud, &"praca_umbu", "05_praca_liberated.png")
	WorldState.region_states["vila_umbuzeiro"] = WorldState.OCCUPIED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)
	get_tree().quit()


func _capture_room(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD, room_id: StringName, file_name: String) -> void:
	nilo.invulnerability_remaining = 999.0
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = world.get_room_center(room_id)
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(14)
	_freeze_enemies()
	var bounds: Rect2 = world.room_bounds[room_id]
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -60
	camera.limit_bottom = 240
	camera.reset_smoothing()
	hud.room_fade = 0.0
	hud.world_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(3)
	await _capture(OUTPUT_DIRECTORY.path_join(file_name))


func _capture(path: String) -> void:
	for attempt in 3:
		var image := get_viewport().get_texture().get_image()
		if image.save_png(ProjectSettings.globalize_path(path)) == OK:
			return
		if attempt < 2:
			await get_tree().create_timer(0.12).timeout
	push_error("Falha ao salvar captura ambiental: %s" % path)


func _freeze_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Node:
			(enemy as Node).process_mode = Node.PROCESS_MODE_DISABLED


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame
