extends Node


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	var world := $Main/VilaDoUmbuzeiro as VilaGraybox
	var hud := $Main/HUD as GameHUD
	var camera := nilo.get_node("Camera2D") as Camera2D
	var output_directory := ProjectSettings.globalize_path("res://prints_do_jogo")
	DirAccess.make_dir_recursive_absolute(output_directory)

	nilo.invulnerability_remaining = 999.0
	nilo.global_position = world.get_room_center(&"casa_nilo")
	nilo.velocity = Vector2.ZERO
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.visual.set("_life_elapsed", 1.25)
	camera.reset_smoothing()
	await _wait_frames(10)
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _capture(output_directory.path_join("heroi_parado_respirando.png"))
	nilo.visual.set("_life_elapsed", 4.16)
	await _wait_frames(1)
	await _capture(output_directory.path_join("heroi_piscando.png"))

	nilo.global_position = Vector2(600.0, 126.0)
	nilo.visual.set("_life_elapsed", 0.0)
	camera.reset_smoothing()
	await _wait_frames(20)
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	Input.action_press("move_right")
	await _wait_frames(18)
	await _capture(output_directory.path_join("andando_no_mapa_01.png"))
	await _wait_physics_frames(125)
	await _capture(output_directory.path_join("correndo_apos_2_segundos.png"))
	Input.action_release("move_right")
	await _wait_frames(2)
	await _capture(output_directory.path_join("inimigos_escala_e_recorte.png"))

	nilo.global_position = Vector2(720.0, 126.0)
	nilo.velocity = Vector2.ZERO
	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	camera.reset_smoothing()
	await _wait_frames(15)
	nilo.receive_hit({"damage": 1, "knockback": Vector2(55.0, -28.0), "source": world})
	GameFeelFX.spawn(get_tree().current_scene, nilo.global_position + Vector2(0.0, -8.0), GameFeelFX.Kind.HIT, -1.0)
	await _wait_frames(2)
	await _capture(output_directory.path_join("dano_de_personagem.png"))

	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		if enemy is CanvasItem:
			(enemy as CanvasItem).visible = false
	nilo.global_position = Vector2(640.0, 138.0)
	nilo.velocity = Vector2.ZERO
	nilo.invulnerability_remaining = 0.0
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	camera.reset_smoothing()
	await _wait_frames(12)
	Input.action_press("shoot_pistol")
	await get_tree().physics_frame
	Input.action_release("shoot_pistol")
	await _wait_for_shooting_frame(nilo.visual, 1, 20)
	await _capture(output_directory.path_join("tiro_de_pistola.png"))
	await _wait_physics_frames(20)
	Input.action_press("shoot_rifle")
	await get_tree().physics_frame
	Input.action_release("shoot_rifle")
	await _wait_for_shooting_frame(nilo.visual, 1, 24)
	await _capture(output_directory.path_join("tiro_de_rifle.png"))
	await _wait_frames(20)
	nilo.invulnerability_remaining = 0.0
	nilo.combat.combo_step = 1
	nilo.combat.attack_phase = PlayerCombat.AttackPhase.ACTIVE
	nilo.combat.attack_phase_remaining = 1.0
	nilo.state_machine.request(PlayerStateMachine.State.MELEE, 0.2, true)
	await _wait_frames(2)
	await _capture(output_directory.path_join("ataque_de_facao.png"))
	nilo.combat.combo_step = 3
	nilo.combat.attack_phase = PlayerCombat.AttackPhase.ACTIVE
	nilo.combat.attack_phase_remaining = 1.0
	nilo.state_machine.request(PlayerStateMachine.State.MELEE, 0.2, true)
	await _wait_frames(2)
	await _capture(output_directory.path_join("ataque_finalizador_de_facao.png"))
	nilo.combat.attack_phase = PlayerCombat.AttackPhase.NONE
	nilo.combat.attack_phase_remaining = 0.0
	nilo.combat.cooldown = 0.0
	Input.action_press("special_attack")
	await get_tree().physics_frame
	Input.action_release("special_attack")
	await _wait_for_combat_frame(nilo.visual, 13, 24)
	await _capture(output_directory.path_join("ataque_especial.png"))
	nilo.combat.special_remaining = 0.0
	nilo.combat.cooldown = 0.0
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	await _wait_frames(8)
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
	await _capture(output_directory.path_join("combate_com_ze_tranca.png"))

	WorldState.region_states["vila_umbuzeiro"] = WorldState.LIBERATED
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.LIBERATED)
	world.queue_redraw()
	nilo.global_position = world.get_room_center(&"praca_umbu")
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(30)
	await _capture(output_directory.path_join("vila_libertada_praca_do_umbu.png"))
	get_tree().quit()


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame


func _wait_physics_frames(count: int) -> void:
	for _frame in count:
		await get_tree().physics_frame


func _wait_for_shooting_frame(visual: NiloVisualController, frame_index: int, maximum_frames: int) -> void:
	for _frame in maximum_frames:
		await get_tree().process_frame
		if visual.shooting_frame == frame_index:
			return


func _wait_for_combat_frame(visual: NiloVisualController, frame_index: int, maximum_frames: int) -> void:
	for _frame in maximum_frames:
		await get_tree().process_frame
		if visual.combat_frame == frame_index:
			return


func _capture_room(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD, room_id: StringName, path: String) -> void:
	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = world.get_room_center(room_id)
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(16)
	var bounds: Rect2 = world.room_bounds[room_id]
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -60
	camera.limit_bottom = 240
	camera.reset_smoothing()
	await _wait_frames(2)
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(2)
	await _capture(path)


func _capture(path: String) -> void:
	for attempt in 3:
		var image := get_viewport().get_texture().get_image()
		var error := image.save_png(path)
		if error == OK:
			return
		if attempt < 2:
			await get_tree().create_timer(0.12).timeout
	push_error("Não foi possível atualizar a captura após 3 tentativas: %s" % path)
