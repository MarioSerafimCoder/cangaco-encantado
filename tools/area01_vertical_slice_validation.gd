extends Node

var failures: Array[String] = []
var _game_snapshot: Dictionary
var _world_snapshot: Dictionary


func _ready() -> void:
	await get_tree().process_frame
	_game_snapshot = GameState.to_dictionary()
	_world_snapshot = WorldState.to_dictionary()
	SaveManager.autosave_enabled = false
	GameState.reset_new_game()
	WorldState.reset_new_game()
	var main := $Main
	var world := main.get_node("VilaDoUmbuzeiro") as VilaGraybox
	var player := main.get_node("Nilo") as NiloPlayer
	_validate_macroarea(world)
	_validate_art_pipeline(world)
	await _validate_home_opening(main, world, player)
	await _validate_first_combat_onboarding(main, world)
	_validate_npcs_and_dialogue(main, player)
	_validate_shop_and_economy(main)
	_validate_progression_and_save(main)
	_validate_generated_assets()
	_validate_diegetic_dialogue()
	GameState.apply_dictionary(_game_snapshot)
	WorldState.apply_dictionary(_world_snapshot)
	SaveManager.autosave_enabled = true
	if failures.is_empty():
		print("AREA01_VERTICAL_SLICE_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_macroarea(world: VilaGraybox) -> void:
	if world.room_bounds.size() != 13:
		failures.append("A macroárea deve registrar treze trechos navegáveis.")
	for room_id in [&"casa_nilo", &"barracos", &"praca_umbu", &"igreja_velha", &"telhados", &"armazem", &"patio", &"beco", &"barricada", &"posto", &"arena"]:
		if not world.room_bounds.has(room_id):
			failures.append("Setor obrigatório ausente: %s." % room_id)
	if not world.find_children("*", "ZeTranca", true, false).is_empty():
		failures.append("Zé Tranca ainda foi instanciado na Área 01.")
	if world.find_children("*", "Checkpoint", true, false).size() < 3:
		failures.append("Casa, Igreja e Subterrâneo precisam de checkpoints.")
	var home_doors := world.find_children("*", "TransitionDoor", true, false)
	if home_doors.size() != 2:
		failures.append("A Casa de Nilo precisa de portas funcionais nos dois sentidos.")
	var npcs := get_tree().get_nodes_in_group("npcs")
	if npcs.size() < 8 or npcs.size() > 9:
		failures.append("A Vila deve possuir de 8 a 9 NPCs relevantes; encontrou %d." % npcs.size())
	var first_spawn: EnemySpawn
	for candidate in world.find_children("*", "EnemySpawn", true, false):
		if (candidate as EnemySpawn).spawn_id == &"rua_saqueador_01":
			first_spawn = candidate
	if first_spawn == null or first_spawn.activation_flag != &"first_combat_unlocked":
		failures.append("O primeiro combate não está condicionado à conversa com o ferido.")
	elif first_spawn.required_tutorial != &"melee":
		failures.append("O primeiro inimigo deve aguardar a execução do tutorial do facão.")


func _validate_art_pipeline(world: VilaGraybox) -> void:
	for platform in world.find_children("*", "TraversalPlatform", true, false):
		if platform.find_children("*", "Sprite2D", true, false).is_empty():
			failures.append("Uma plataforma de traversal ainda não possui sprite real.")
	for room in get_tree().get_nodes_in_group("production_rooms"):
		if (room as RoomController).authored_composition_width > 0.0 and (room as RoomController).get_method_list().any(func(method): return method.name == "_extend_authored_composition"):
			failures.append("Duplicação automática de arquitetura voltou a ser usada.")
	if get_tree().get_nodes_in_group("atlas_world_props").size() < 25:
		failures.append("A composição manual não cobre os setores com props suficientes.")
	for npc in get_tree().get_nodes_in_group("npcs"):
		var actor := npc as NPCActor
		if actor.sprite.region_rect.end.x > actor.sprite.texture.get_width() + 0.01 or actor.sprite.region_rect.end.y > actor.sprite.texture.get_height() + 0.01:
			failures.append("O recorte do morador %s ultrapassa os limites do atlas." % actor.npc_id)


func _validate_home_opening(main: Node, world: VilaGraybox, player: NiloPlayer) -> void:
	var hud := main.get_node("HUD") as GameHUD
	# O runner restaura/resetta o estado depois que os filhos entram na árvore;
	# reinicia aqui o mesmo guia que o fluxo real de Novo jogo aciona no boot.
	hud.set("_tutorial_id", &"")
	hud.opening_guide_active = false
	hud.begin_opening_guide()
	if not hud.opening_guide_active or hud.get("_tutorial_id") != &"move":
		failures.append("A abertura não iniciou o tutorial contextual de movimento.")
	Input.action_press("move_right")
	hud.call("_update_context_tutorial")
	Input.action_release("move_right")
	if not GameState.tutorial_learned(&"move") or hud.opening_guide_active:
		failures.append("O tutorial de movimento não avançou após a ação real.")
	var exit_door: TransitionDoor
	for candidate in world.find_children("*", "TransitionDoor", true, false):
		if (candidate as TransitionDoor).destination_room == &"rua_cinzas":
			exit_door = candidate
			break
	if exit_door == null:
		failures.append("Porta de saída da Casa de Nilo não foi encontrada.")
		return
	player.global_position = exit_door.global_position
	exit_door.call("_on_body_entered", player)
	exit_door.call("_transition")
	await get_tree().create_timer(0.62).timeout
	if player.global_position.distance_to(exit_door.destination) > 1.0:
		failures.append("A porta da Casa de Nilo não levou o jogador até a rua.")
	if player.narrative_locked or bool(exit_door.get("_transitioning")):
		failures.append("A transição da porta não devolveu o controle ao jogador.")
	if hud.opening_guide_active or not bool(GameState.dialogue_flags.get("opening_house_exited", false)):
		failures.append("O tutorial inicial não foi concluído ao sair da casa.")


func _validate_npcs_and_dialogue(main: Node, player: NiloPlayer) -> void:
	var director := main.get_node("DialogueDirector") as DialogueDirector
	var npc := get_tree().get_nodes_in_group("npcs")[0] as NPCActor
	if not director.start(npc.dialogue_id, npc):
		failures.append("NPC não iniciou diálogo orientado a dados.")
		return
	director.call("_process", 0.25)
	var text_label := director.get("_text_label") as Label
	if text_label.visible_characters <= 0 or text_label.visible_characters >= text_label.text.length():
		failures.append("Typewriter não revelou o texto progressivamente.")
	if not player.narrative_locked:
		failures.append("Nilo continuou livre durante o diálogo.")
	while director.active:
		text_label.visible_characters = text_label.text.length()
		director.call("_advance")
	if player.narrative_locked:
		failures.append("Fim do diálogo não devolveu o controle a Nilo.")
	var before := GameState.inventory_amount(&"collectibles", &"fragmento_encantado")
	director.call("_apply_events", [{"type":"give_item", "category":"collectibles", "id":"fragmento_encantado", "amount":1}, {"type":"complete_area01"}])
	if not bool(WorldState.flags.get("area01_encantado_discovered", false)) or GameState.inventory_amount(&"collectibles", &"fragmento_encantado") != before + 1:
		failures.append("Manifestação não registrou descoberta e colecionável.")
	var repeat_lines := DialogueDatabase.get_conversation(&"manifestacao")
	if repeat_lines.size() != 1 or repeat_lines[0].has("events"):
		failures.append("Manifestação pode repetir a recompensa depois de concluída.")


func _validate_first_combat_onboarding(main: Node, world: VilaGraybox) -> void:
	var hud := main.get_node("HUD") as GameHUD
	var first_spawn: EnemySpawn
	for candidate in world.find_children("*", "EnemySpawn", true, false):
		if (candidate as EnemySpawn).spawn_id == &"rua_saqueador_01":
			first_spawn = candidate
			break
	if first_spawn == null:
		failures.append("Spawn do primeiro combate ausente para validar o onboarding.")
		return
	WorldState.set_flag(&"first_combat_unlocked", false)
	GameState.tutorial_flags.erase("melee")
	await get_tree().process_frame
	WorldState.set_flag(&"first_combat_unlocked", true)
	await get_tree().process_frame
	if first_spawn.has_live_enemy():
		failures.append("O saqueador apareceu antes de Nilo executar o comando do facão.")
	if hud.get("_tutorial_id") == &"jump":
		Input.action_press("jump")
		hud.call("_update_context_tutorial")
		Input.action_release("jump")
		await get_tree().process_frame
	if hud.get("_tutorial_id") != &"melee":
		failures.append("A conversa com Raimundo não encadeou o tutorial contextual do facão.")
		return
	Input.action_press("melee")
	hud.call("_update_context_tutorial")
	Input.action_release("melee")
	await get_tree().process_frame
	await get_tree().process_frame
	if not first_spawn.has_live_enemy():
		failures.append("O primeiro saqueador não apareceu depois que o facão foi aprendido.")


func _validate_shop_and_economy(main: Node) -> void:
	var director := main.get_node("DialogueDirector") as DialogueDirector
	var shop := director.get("_shop_ui") as ShopUI
	var definition: Dictionary = shop.get("_catalog").get("mercador_vila", {})
	var items: Array = definition.get("items", [])
	if items.size() < 4 or items.size() > 6:
		failures.append("A primeira loja precisa de 4 a 6 mercadorias.")
		return
	GameState.currency = 0
	shop.open(&"mercador_vila")
	shop.call("_buy", items[0])
	if GameState.currency != 0:
		failures.append("Compra sem dinheiro alterou a moeda.")
	GameState.currency = 100
	var price := int(items[0].get("price", 0))
	shop.call("_buy", items[0])
	if GameState.currency != 100 - price:
		failures.append("Loja cobrou um valor diferente do catálogo.")
	shop.close()


func _validate_progression_and_save(main: Node) -> void:
	var map_ui := main.get_node("WorldMap") as WorldMapUI
	if map_ui.ROOM_LAYOUT.size() != 13 or map_ui.CONNECTIONS.size() < 14:
		failures.append("Mapa local não representa setores e atalhos da Área 01.")
	var data := GameState.to_dictionary()
	for key in ["currency", "inventory", "purchased_items", "npc_states", "dialogue_flags", "area_states", "visited_rooms", "opened_shortcuts"]:
		if not data.has(key):
			failures.append("Save não persiste: %s." % key)
	var json = JSON.parse_string(JSON.stringify({"game_state":data, "world_state":WorldState.to_dictionary()}))
	if json is not Dictionary:
		failures.append("Estado completo não suporta roundtrip JSON.")


func _validate_generated_assets() -> void:
	for path in [
		"res://assets/sprites/usados/cenarios/area_01/casa_nilo_interior_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/casa_nilo_arquitetura_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/traversal_props_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/arquitetura_vila_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/cripta_subterraneo_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/grutas_cavernas_atlas.png",
		"res://assets/sprites/usados/cenarios/area_01/cavernas_estrutura_atlas.png",
		"res://assets/sprites/usados/interface/dialogo_loja/dialogo_loja_atlas.png",
	]:
		var texture := load(path) as Texture2D
		if texture == null:
			failures.append("Atlas final ausente: %s." % path)
			continue
		var image := texture.get_image()
		for point in [Vector2i(0,0), Vector2i(image.get_width()-1,0), Vector2i(0,image.get_height()-1), Vector2i(image.get_width()-1,image.get_height()-1)]:
			if image.get_pixelv(point).a > 0.02:
				failures.append("Atlas ainda possui fundo opaco: %s." % path)
				break


func _validate_diegetic_dialogue() -> void:
	var source := FileAccess.get_file_as_string("res://resources/dialogues/area_01_dialogues.json").to_lower()
	for forbidden in ["nesta versão", "beta", "versão de teste"]:
		if source.contains(forbidden):
			failures.append("Diálogo da vila ainda quebra a quarta parede com: %s." % forbidden)
