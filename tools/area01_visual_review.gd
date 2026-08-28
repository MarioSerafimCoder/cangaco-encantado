extends Node

const OUTPUT_DIRECTORY := "res://prints_do_jogo/area_01_vertical_slice"


func _ready() -> void:
	await get_tree().process_frame
	SaveManager.autosave_enabled = false
	GameState.reset_new_game()
	WorldState.reset_new_game()
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", WorldState.OCCUPIED)
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
	await _capture_room(world, nilo, camera, hud, &"casa_nilo", "01_casa_de_nilo.png")
	await _capture_home_exit(world, nilo, camera, hud)
	await _capture_room(world, nilo, camera, hud, &"barracos", "02_vila_baixa.png")
	await _capture_room(world, nilo, camera, hud, &"praca_umbu", "03_praca_do_umbu.png")
	await _capture_shop(main, world, nilo, camera, hud)
	await _capture_dialogue(main, world, nilo, camera, hud)
	await _capture_room(world, nilo, camera, hud, &"igreja_velha", "06_igreja_e_cemiterio.png")
	await _capture_room(world, nilo, camera, hud, &"telhados", "07_telhados.png")
	await _capture_room(world, nilo, camera, hud, &"patio", "08_subterraneo.png")
	await _capture_room(world, nilo, camera, hud, &"beco", "09_grutas.png")
	await _capture_room(world, nilo, camera, hud, &"arena", "10_caverna_santuario.png")
	SaveManager.autosave_enabled = true
	print("AREA01_VISUAL_REVIEW_OK: %s" % ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	get_tree().quit()


func _capture_room(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD, room_id: StringName, file_name: String) -> void:
	nilo.invulnerability_remaining = 999.0
	nilo.narrative_locked = false
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = world.get_room_center(room_id)
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
	hud.world_fade = 0.0
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
	hud.world_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(16)
	await _capture(OUTPUT_DIRECTORY.path_join("01b_porta_de_saida_da_casa.png"))


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
		director.call("_finish")


func _position_in_square(world: VilaGraybox, nilo: NiloPlayer, camera: Camera2D, hud: GameHUD) -> void:
	var bounds: Rect2 = world.room_bounds[&"praca_umbu"]
	nilo.global_position = Vector2(bounds.position.x + 610, 138)
	nilo.velocity = Vector2.ZERO
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_top = -120
	camera.limit_bottom = 360
	camera.position = Vector2.ZERO
	camera.position_smoothing_enabled = false
	camera.reset_smoothing()
	hud.room_fade = 0.0
	hud.world_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(16)


func _capture(path: String) -> void:
	for attempt in 3:
		var image := get_viewport().get_texture().get_image()
		if image.save_png(ProjectSettings.globalize_path(path)) == OK:
			return
		if attempt < 2:
			await get_tree().create_timer(0.12).timeout
	push_error("Falha ao gerar screenshot: %s" % path)


func _freeze_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame
