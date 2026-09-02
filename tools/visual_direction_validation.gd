extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	var world := main.get_node("VilaDoUmbuzeiro") as VilaGraybox
	var hud := main.get_node("HUD") as GameHUD
	_validate_materialized_rooms(world)
	_validate_authored_traversal(world)
	_validate_scene_triggers(hud)
	_validate_hud_layers(hud)
	_validate_asset_pack()
	if failures.is_empty():
		print("VISUAL_DIRECTION_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_materialized_rooms(world: VilaGraybox) -> void:
	for room_id in [&"barracos", &"praca_umbu", &"igreja_velha", &"telhados"]:
		var room := world.room_nodes.get(room_id) as RoomController
		if room == null:
			failures.append("Sala materializada ausente: %s." % room_id)
			continue
		if room.authored_composition_width < room.local_bounds.size.x:
			failures.append("A composição autoral não cobre toda a sala %s." % room_id)
		if room.get_node_or_null("Environment/RuntimeComposition") != null:
			failures.append("A sala %s voltou a receber composição visual runtime." % room_id)
	if (world.room_nodes[&"praca_umbu"] as RoomController).get_node_or_null("Environment/ExperiencePolish/UmbuzeiroLandmark") == null:
		failures.append("O umbu-landmark da Praça não está materializado.")
	if (world.room_nodes[&"igreja_velha"] as RoomController).get_node_or_null("Environment/Cemetery/PortaoPrincipal") == null:
		failures.append("O portão do cemitério não está materializado.")


func _validate_authored_traversal(world: VilaGraybox) -> void:
	var roofs := world.room_nodes[&"telhados"] as RoomController
	var obstacles := roofs.get_node_or_null("Geometry/EditableObstacles")
	if obstacles == null or obstacles.get_child_count() < 8:
		failures.append("Telhados não possui oito superfícies caminháveis editáveis.")
	var broken_roof := roofs.get_node_or_null("Environment/ExperiencePolish/TelhadoQuebrado") as Sprite2D
	var balcony := roofs.get_node_or_null("Environment/ExperiencePolish/VarandaElevada") as Sprite2D
	if broken_roof == null or balcony == null or not broken_roof.visible or not balcony.visible:
		failures.append("A rota alta perdeu o telhado quebrado ou a varanda.")


func _validate_scene_triggers(hud: GameHUD) -> void:
	if get_tree().get_nodes_in_group("tutorial_triggers").size() < 2:
		failures.append("Tutoriais de arma não foram transferidos para TutorialTrigger.")
	if hud.has_method("_update_spatial_tutorials"):
		failures.append("O HUD ainda contém checks mágicos de posição para tutoriais.")
	if get_tree().get_nodes_in_group("camera_composition_zones").size() < 2:
		failures.append("Zonas locais de composição de câmera estão ausentes.")


func _validate_hud_layers(hud: GameHUD) -> void:
	EventBus.objective_changed.emit("TESTE DE OBJETIVO")
	hud.call("_set_objective_compact")
	var room_rect := Rect2(hud.room_panel.position, hud.room_panel.size)
	var objective_rect := Rect2(hud.objective_panel.position, hud.objective_panel.size)
	if room_rect.intersects(objective_rect):
		failures.append("Objetivo compacto ainda sobrepõe o nome da sala.")
	EventBus.ability_unlocked.emit(&"wall_jump", "PASSO DA PEDRA")
	if not hud.ability_presentation.visible:
		failures.append("Aquisição de habilidade não abriu a apresentação especial.")


func _validate_asset_pack() -> void:
	var base := "res://assets/sprites/usados/cenarios/polimento_experiencia_0_4_4/"
	for file_name in [
		"01_telhados_atlas_transparente.png",
		"02_igreja_cemiterio_atlas_transparente.png",
		"03_praca_atlas_transparente.png",
		"04_vila_baixa_rua_atlas_transparente.png",
		"07_vila_baixa_casas_pequenas_suplemento_transparente.png",
	]:
		if not FileAccess.file_exists(base + file_name):
			failures.append("Atlas tratado ausente: %s." % file_name)
	var generated_pose := "res://assets/sprites/nao_utilizados/aguardando_tratamento/gerados/pending_bg_removal/experience_polish_sprite_pack_2026-09-01/10_nilo_aquisicao_reacao_fundo_branco.png"
	if not FileAccess.file_exists(generated_pose):
		failures.append("Folha gerada de aquisição/reação do Nilo está ausente.")
