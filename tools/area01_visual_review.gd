extends Node

const OUTPUT_DIRECTORY := "res://prints_do_jogo/area_01_vertical_slice"

var _capture_failed := false


func _ready() -> void:
	await get_tree().process_frame
	SaveManager.autosave_enabled = false
	GameState.reset_new_game()
	WorldState.reset_new_game()
	EventBus.currency_changed.emit(GameState.currency)
	var main := $Main
	var world := main.get_node("VilaDoUmbuzeiro") as VilaGraybox
	var nilo := main.get_node("Nilo") as NiloPlayer
	var camera := nilo.camera
	var hud := main.get_node("HUD") as GameHUD
	main.get_node("CameraDirector").process_mode = Node.PROCESS_MODE_DISABLED
	var fade := main.get("_screen_fade") as ColorRect
	if fade != null:
		fade.modulate.a = 0.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	_freeze_enemies()
	await _capture_front_end(main)
	await _capture_room(world, nilo, camera, hud, &"casa_nilo", "01_casa_de_nilo.png")
	await _capture_context_tutorials(world, nilo, camera, hud)
	await _capture_home_exit(world, nilo, camera, hud)
	await _capture_street_clearance(world, nilo, camera, hud)
	await _capture_hud_states(world, nilo, camera, hud)
	await _capture_room(world, nilo, camera, hud, &"barracos", "02_vila_baixa.png")
	await _capture_room(world, nilo, camera, hud, &"praca_umbu", "03_praca_do_umbu.png")
	await _capture_shop(main, world, nilo, camera, hud)
	await _capture_dialogue(main, world, nilo, camera, hud)
	await _capture_room(world, nilo, camera, hud, &"igreja_velha", "06_igreja_e_cemiterio.png")
	await _capture_room(world, nilo, camera, hud, &"telhados", "07_telhados.png")
	await _capture_room(world, nilo, camera, hud, &"patio", "08_subterraneo.png")
	await _capture_room(world, nilo, camera, hud, &"beco", "09_grutas.png")
	await _capture_room(world, nilo, camera, hud, &"arena", "10_caverna_santuario.png")
	await _capture_character_menu(main)
	await _capture_notification()
	SaveManager.autosave_enabled = true
	if _capture_failed:
		get_tree().quit(1)
		return
	print("AREA01_VISUAL_REVIEW_OK: %s" % ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	get_tree().quit()


func _capture_front_end(main: Node) -> void:
	var menu := main.get_node("FrontEndMenu") as FrontEndMenu
	menu.show_title()
	# A cena de revisão precisa continuar processando enquanto o menu pausa o jogo.
	get_tree().paused = false
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("00_menu_inicial.png"))
	menu.enter_game()
	menu.show_pause()
	get_tree().paused = false
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("00b_menu_de_pausa.png"))
	menu.enter_game()


func _capture_room(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD, room_id: StringName, file_name: String) -> void:
	nilo.invulnerability_remaining = 999.0
	nilo.narrative_locked = false
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = world.get_room_center(room_id)
	EventBus.room_entered.emit(room_id, "")
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	var bounds: Rect2 = world.room_bounds[room_id]
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -120
	camera.limit_bottom = 360
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(18)
	await _capture(OUTPUT_DIRECTORY.path_join(file_name))


func _capture_home_exit(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	var bounds: Rect2 = world.room_bounds[&"casa_nilo"]
	nilo.global_position = Vector2(bounds.end.x - 125.0, 138.0)
	nilo.velocity = Vector2.ZERO
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -120
	camera.limit_bottom = 360
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	camera.reset_smoothing()
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(16)
	await _capture(OUTPUT_DIRECTORY.path_join("01b_porta_de_saida_da_casa.png"))


func _capture_street_clearance(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	var bounds: Rect2 = world.room_bounds[&"rua_cinzas"]
	nilo.global_position = Vector2(bounds.position.x + 135.0, 138.0)
	nilo.velocity = Vector2.ZERO
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -120
	camera.limit_bottom = 360
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	camera.reset_smoothing()
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(16)
	await _capture(OUTPUT_DIRECTORY.path_join("01c_rua_das_cinzas_sem_oclusao.png"))


func _capture_shop(main: Node, world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	await _position_in_square(world, nilo, camera, hud)
	var director := main.get_node("DialogueDirector") as DialogueDirector
	var shop := director.get("_shop_ui") as ShopUI
	shop.open(&"mercador_vila")
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("04_mercador_loja.png"))
	shop.close()


func _capture_dialogue(main: Node, world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	await _position_in_square(world, nilo, camera, hud)
	var merchant: NPCActor
	for candidate in get_tree().get_nodes_in_group("npcs"):
		if (candidate as NPCActor).npc_id == &"anselmo":
			merchant = candidate
			break
	var director := main.get_node("DialogueDirector") as DialogueDirector
	if merchant != null:
		nilo.global_position = merchant.global_position + Vector2(-48, 0)
		director.start(&"mercador", merchant)
		await _wait_frames(3)
		var text_label := director.get("_text_label") as Label
		text_label.visible_characters = text_label.text.length()
		await _wait_frames(2)
		await _capture(OUTPUT_DIRECTORY.path_join("05_dialogo_na_praca.png"))
		director.call("_advance")
		await _wait_frames(3)
		text_label.visible_characters = text_label.text.length()
		await _capture(OUTPUT_DIRECTORY.path_join("05b_dialogo_com_escolhas.png"))
		director.call("_finish")


func _position_in_square(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	var bounds: Rect2 = world.room_bounds[&"praca_umbu"]
	nilo.global_position = Vector2(bounds.position.x + 610, 138)
	EventBus.room_entered.emit(&"praca_umbu", "")
	nilo.velocity = Vector2.ZERO
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -120
	camera.limit_bottom = 360
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	camera.reset_smoothing()
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(16)


func _capture_character_menu(main: Node) -> void:
	var menu := main.get_node("WorldMap") as WorldMapUI
	GameState.abilities["wall_jump"] = true
	GameState.add_inventory_item(&"important_items", &"medalha_antiga", 1)
	menu.open_map()
	# A revisão visual precisa continuar processando depois que a interface pausa o jogo.
	get_tree().paused = false
	var canvas := menu.get("_canvas") as Control
	menu.set("_tab", WorldMapUI.Tab.MAP)
	canvas.queue_redraw()
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("11a_diario_mapa.png"))
	menu.set("_tab", WorldMapUI.Tab.ITEMS)
	canvas.queue_redraw()
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("11b_diario_itens.png"))
	menu.set("_tab", WorldMapUI.Tab.ABILITIES)
	canvas.queue_redraw()
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("11c_diario_habilidades.png"))
	menu.set("_tab", WorldMapUI.Tab.AMULETS)
	canvas.queue_redraw()
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("11d_diario_amuletos.png"))
	menu.call("_close")


func _capture_context_tutorials(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	GameState.tutorial_flags.clear()
	GameState.dialogue_flags["opening_house_exited"] = false
	GameState.current_room_id = &"casa_nilo"
	hud.begin_opening_guide()
	await _wait_frames(3)
	await _capture(OUTPUT_DIRECTORY.path_join("01d_tutorial_movimento.png"))
	Input.action_press("move_right")
	hud.call("_update_context_tutorial")
	Input.action_release("move_right")
	var exit_door: TransitionDoor
	for candidate in world.find_children("*", "TransitionDoor", true, false):
		if (candidate as TransitionDoor).destination_room == &"rua_cinzas":
			exit_door = candidate
			break
	if exit_door != null:
		nilo.global_position = exit_door.global_position
		exit_door.call("_on_body_entered", nilo)
		camera.reset_smoothing()
		await _wait_frames(3)
		await _capture(OUTPUT_DIRECTORY.path_join("01e_tutorial_interacao.png"))
		exit_door.call("_on_body_exited", nilo)


func _capture_hud_states(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	await _capture_room(world, nilo, camera, hud, &"rua_cinzas", "02a_hud_normal.png")
	hud.player_status.set_health(3, 5)
	await _wait_frames(2)
	await _capture(OUTPUT_DIRECTORY.path_join("02b_hud_apos_dano.png"))
	hud.player_status.bind_player(nilo)
	nilo.combat.reloading_weapon = &"pistol"
	nilo.combat.reload_timer = nilo.combat.pistol_data.reload_time * 0.5
	await _wait_frames(2)
	await _capture(OUTPUT_DIRECTORY.path_join("02c_hud_durante_recarga.png"))
	nilo.combat.reload_timer = 0.0
	nilo.combat.reloading_weapon = &""


func _capture_notification() -> void:
	NotificationManager.enqueue("NOVA HABILIDADE\nPASSO DA PEDRA", 100, &"ability", 4.0)
	await _wait_frames(4)
	await _capture(OUTPUT_DIRECTORY.path_join("12_notificacao_nova_habilidade.png"))


func _capture(path: String) -> void:
	if _capture_failed:
		return
	for attempt in 3:
		var viewport_texture := get_viewport().get_texture()
		if viewport_texture == null:
			_capture_failed = true
			push_error("O renderizador ativo não disponibilizou textura para a revisão visual.")
			return
		var image := viewport_texture.get_image()
		if image == null:
			_capture_failed = true
			push_error("O renderizador ativo não disponibilizou imagem para a revisão visual.")
			return
		if image.save_png(ProjectSettings.globalize_path(path)) == OK:
			return
		if attempt < 2:
			await get_tree().create_timer(0.12).timeout
	_capture_failed = true
	push_error("Falha ao gerar screenshot: %s" % path)


func _freeze_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame
