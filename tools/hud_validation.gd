extends Node

const BOSS_SCENE := preload("res://scenes/bosses/ze_tranca.tscn")

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var hud := $Main/HUD as GameHUD
	var player := $Main/Nilo as NiloPlayer
	_validate_structure(hud)
	_validate_player_feedback(hud, player)
	await _validate_boss_bar(hud, player)
	if failures.is_empty():
		print("HUD_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_structure(hud: GameHUD) -> void:
	if hud.player_status == null or hud.boss_status == null:
		failures.append("HUD profissional não criou os painéis de jogador e chefe.")
		return
	if hud.player_status.size.y > 38.0:
		failures.append("Painel do jogador excedeu a altura compacta de 38 px.")
	if hud.player_status.get_node_or_null("AtlasFrame") == null:
		failures.append("Painel do jogador não reutiliza a moldura do atlas.")
	if hud.boss_status.get_node_or_null("AtlasFrame") == null:
		failures.append("Barra de chefe não reutiliza a moldura do atlas.")


func _validate_player_feedback(hud: GameHUD, player: NiloPlayer) -> void:
	var panel := hud.player_status
	panel.bind_player(player)
	panel.set_health(4, 5)
	if panel.current_health != 4 or panel.get("_health_pulse") <= 0.0:
		failures.append("Perda de vida não ativou a animação do HUD.")
	panel.set_ammo(&"pistol", 7, 8)
	panel.set_ammo(&"rifle", 3, 4)
	if panel.pistol_ammo != 7 or panel.rifle_ammo != 3:
		failures.append("Munições visuais não acompanham pistola e rifle.")
	panel.set_heals(1, 2)
	if panel.heal_charges != 1 or panel.get("_heal_pulse") <= 0.0:
		failures.append("Cabaça não ativou a animação de recuperação de recurso.")
	player.combat.reloading_weapon = &"pistol"
	player.combat.reload_timer = player.combat.pistol_data.reload_time * 0.5
	if not panel.call("_is_reloading", &"pistol"):
		failures.append("Indicador de recarga não reconheceu a pistola em recarga.")
	var progress := float(panel.call("_reload_progress"))
	if progress < 0.45 or progress > 0.55:
		failures.append("Progresso visual da recarga não representa o tempo restante.")
	player.combat.reload_timer = 0.0
	player.combat.reloading_weapon = &""


func _validate_boss_bar(hud: GameHUD, player: NiloPlayer) -> void:
	var boss := BOSS_SCENE.instantiate() as EnemyBase
	add_child(boss)
	boss.global_position = player.global_position + Vector2(40.0, 0.0)
	await get_tree().process_frame
	hud.boss_status.show_boss(boss)
	if not hud.boss_status.visible:
		failures.append("Barra de chefe não apareceu para um chefe válido.")
	boss.health.take_damage(7, player)
	await get_tree().process_frame
	if boss.health.current_health > boss.health.max_health / 2:
		failures.append("Cenário de validação não alcançou a segunda fase do chefe.")
	boss.posture.apply_posture_damage(2.0)
	await get_tree().process_frame
	if boss.posture.current_posture >= boss.posture.max_posture:
		failures.append("Medidor de postura do chefe não recebeu a alteração esperada.")
	hud.boss_status.hide_boss()
	boss.queue_free()
