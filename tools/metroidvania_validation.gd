extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	var world := main.get_node("VilaDoUmbuzeiro") as VilaGraybox
	var player := main.get_node("Nilo") as NiloPlayer
	var map_ui := main.get_node("WorldMap") as WorldMapUI
	_validate_world_graph(world)
	_validate_progression(world, player)
	_validate_map(map_ui)
	_validate_persistence_schema()
	if failures.is_empty():
		print("METROIDVANIA_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_world_graph(world: VilaGraybox) -> void:
	var connectors := world.find_children("*", "WorldConnector", true, false)
	var pickups := world.find_children("*", "AbilityPickup", true, false)
	var upgrades := world.find_children("*", "PermanentUpgradePickup", true, false)
	var platforms := world.find_children("*", "TraversalPlatform", true, false)
	if connectors.size() < 4:
		failures.append("O mapa não possui os dois pares de atalhos planejados.")
	if pickups.size() < 2:
		failures.append("A progressão não contém as duas habilidades de travessia.")
	if upgrades.size() < 1:
		failures.append("Nenhuma melhoria permanente foi colocada no retorno à Casa de Nilo.")
	if platforms.size() < 6:
		failures.append("A rota vertical possui plataformas insuficientes.")
	var min_y := 150.0
	for platform in platforms:
		min_y = minf(min_y, (platform as TraversalPlatform).position.y)
	if min_y > 60.0:
		failures.append("As rotas continuam planas; nenhuma plataforma alcança a camada alta.")


func _validate_progression(world: VilaGraybox, player: NiloPlayer) -> void:
	if player.config.wall_jump_velocity.y >= 0.0 or player.config.dash_speed <= player.config.move_speed:
		failures.append("As habilidades não alteram a mobilidade de forma útil.")
	var dash_connector: WorldConnector
	for candidate in world.find_children("*", "WorldConnector", true, false):
		if (candidate as WorldConnector).required_ability == &"dash":
			dash_connector = candidate
			break
	if dash_connector == null:
		failures.append("Não há rota alternativa controlada pela investida.")
		return
	var previous := bool(GameState.abilities.get("dash", false))
	GameState.abilities["dash"] = false
	if dash_connector.call("_can_use"):
		failures.append("A rota da Praça ignora a habilidade necessária.")
	GameState.abilities["dash"] = true
	if not dash_connector.call("_can_use"):
		failures.append("A rota da Praça não abre depois de obter a investida.")
	GameState.abilities["dash"] = previous


func _validate_map(map_ui: WorldMapUI) -> void:
	if map_ui.ROOM_LAYOUT.size() != 13:
		failures.append("O mapa navegável não representa todas as treze áreas.")
	if map_ui.CONNECTIONS.size() < 14:
		failures.append("O mapa não representa rotas alternativas e verticais.")
	if not InputMap.has_action("map") or not InputMap.has_action("dash"):
		failures.append("Os comandos de mapa ou investida não foram registrados.")
	if map_ui.TAB_NAMES.size() != 4:
		failures.append("O diário do personagem não contém mapa, itens, habilidades e amuletos.")
	if not InputMap.has_action("sprint"):
		failures.append("A corrida acelerada com Espaço não foi registrada.")


func _validate_persistence_schema() -> void:
	var data := GameState.to_dictionary()
	for key in ["visited_rooms", "current_room_id", "permanent_upgrades", "max_health_bonus", "abilities", "opened_shortcuts"]:
		if not data.has(key):
			failures.append("O save não persiste o campo de exploração: %s." % key)
