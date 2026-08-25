extends Node


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var hud := $Main/HUD as GameHUD
	var camera := nilo.get_node("Camera2D") as Camera2D
	var output_directory := ProjectSettings.globalize_path("res://prints_do_jogo")
	DirAccess.make_dir_recursive_absolute(output_directory)

	nilo.global_position = Vector2(600.0, 126.0)
	camera.reset_smoothing()
	await _wait_frames(20)
	hud.room_fade = 0.0
	hud.world_fade = 0.0
	hud.help_fade = 0.0
	Input.action_press("move_right")
	await _wait_frames(18)
	_capture(output_directory.path_join("andando_no_mapa_01.png"))
	Input.action_release("move_right")

	nilo.global_position = Vector2(720.0, 126.0)
	nilo.velocity = Vector2.ZERO
	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	camera.reset_smoothing()
	await _wait_frames(15)
	nilo.receive_hit({"damage": 1, "knockback": Vector2(55.0, -28.0), "source": world})
	GameFeelFX.spawn(get_tree().current_scene, nilo.global_position + Vector2(0.0, -8.0), GameFeelFX.Kind.HIT, -1.0)
	await _wait_frames(2)
	_capture(output_directory.path_join("dano_de_personagem.png"))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
	var visual_tour := [
		[&"casa_nilo", "ambiente_01_casa_de_nilo.png"],
		[&"igreja_velha", "ambiente_03_igreja_velha.png"],
		[&"telhados", "ambiente_04_telhados_da_vila.png"],
		[&"praca_umbu", "ambiente_05_praca_do_umbu.png"],
		[&"barracos", "ambiente_06_barracos_queimados.png"],
		[&"armazem", "ambiente_07_armazem_tomado.png"],
		[&"patio", "ambiente_08_patio_do_armazem.png"],
		[&"beco", "ambiente_09_beco_dos_saqueadores.png"],
		[&"poco", "ambiente_10_poco_do_romaozinho.png"],
		[&"barricada", "ambiente_11_barricada_da_companhia.png"],
		[&"posto", "ambiente_12_posto_de_comando.png"],
		[&"arena", "ambiente_13_arena_de_ze_tranca.png"],
	]
	for entry in visual_tour:
		await _capture_room(world, nilo, camera, hud, entry[0], output_directory.path_join(entry[1]))

	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = Vector2(6400.0, 126.0)
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(30)
	_capture(output_directory.path_join("combate_com_ze_tranca.png"))

	WorldState.region_states["vila_umbuzeiro"] = WorldState.LIBERATED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.LIBERATED)
	world.queue_redraw()
	nilo.global_position = world.get_room_center(&"praca_umbu")
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(30)
	_capture(output_directory.path_join("vila_libertada_praca_do_umbu.png"))
	get_tree().quit()


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame


func _capture_room(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD, room_id: StringName, path: String) -> void:
	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = world.get_room_center(room_id)
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(16)
	hud.room_fade = 0.0
	hud.world_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(2)
	_capture(path)


func _capture(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(path)
