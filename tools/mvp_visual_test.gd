extends Node


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var camera := nilo.get_node("Camera2D") as Camera2D
	var output_directory := ProjectSettings.globalize_path("res://prints_do_jogo")
	DirAccess.make_dir_recursive_absolute(output_directory)

	nilo.global_position = Vector2(600.0, 126.0)
	camera.reset_smoothing()
	await _wait_frames(15)
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


func _capture(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(path)
