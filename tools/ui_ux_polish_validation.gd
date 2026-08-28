extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	_validate_resolution()
	_validate_input_glyph_switch()
	_validate_tutorial_persistence(main.get_node("HUD") as GameHUD)
	await _validate_journal_origin(main)
	_validate_dialogue_layout(main.get_node("DialogueDirector") as DialogueDirector)
	await _validate_shop_focus(main.get_node("DialogueDirector") as DialogueDirector)
	_validate_notification_separation(main.get_node("HUD") as GameHUD)
	_validate_old_save_compatibility()
	_validate_ui_components()
	if failures.is_empty():
		print("UI_UX_POLISH_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_resolution() -> void:
	if get_viewport().get_visible_rect().size != Vector2(640, 360):
		failures.append("A UI deixou de operar no viewport interno 640×360.")


func _validate_input_glyph_switch() -> void:
	var previous := InputBootstrap.last_input_was_gamepad
	InputBootstrap.last_input_was_gamepad = false
	var keyboard := InputGlyphResolver.prompt(&"interact", "CONVERSAR")
	InputBootstrap.last_input_was_gamepad = true
	var gamepad := InputGlyphResolver.prompt(&"interact", "CONVERSAR")
	InputBootstrap.last_input_was_gamepad = previous
	if "[E]" not in keyboard or "[Y]" not in gamepad or keyboard == gamepad:
		failures.append("Glyph de interação não alternou entre teclado e gamepad.")
	if not InputMap.has_action("ui_accept") or not InputMap.has_action("ui_cancel"):
		failures.append("Navegação padrão de teclado/gamepad não está disponível.")


func _validate_tutorial_persistence(hud: GameHUD) -> void:
	var previous_flags := GameState.tutorial_flags.duplicate(true)
	GameState.tutorial_flags.clear()
	GameState.current_room_id = &"casa_nilo"
	GameState.dialogue_flags["opening_house_exited"] = false
	hud.begin_opening_guide()
	if not hud.opening_guide_active:
		failures.append("Onboarding contextual não apareceu para um novo jogador.")
	Input.action_press("move_right")
	hud.call("_update_context_tutorial")
	Input.action_release("move_right")
	if not GameState.tutorial_learned(&"move"):
		failures.append("Onboarding não avançou depois da ação executada.")
	hud.begin_opening_guide()
	if hud.opening_guide_active:
		failures.append("Tutorial concluído reapareceu indevidamente.")
	GameState.tutorial_flags = previous_flags


func _validate_journal_origin(main: Node) -> void:
	var menu := main.get_node("FrontEndMenu") as FrontEndMenu
	var journal := main.get_node("WorldMap") as WorldMapUI
	menu.show_pause()
	menu.call("_open_map")
	if not bool(journal.get("_opened_from_pause")) or not get_tree().paused:
		failures.append("Diário não preservou a origem no menu de pausa.")
	journal.call("_close")
	if menu.mode != FrontEndMenu.Mode.PAUSE or not get_tree().paused:
		failures.append("Pause → Diário → Voltar não retornou ao Pause.")
	menu.enter_game()
	journal.open_map(false)
	journal.call("_close")
	if get_tree().paused or journal.get("_open"):
		failures.append("Gameplay → Diário → Voltar não retornou ao gameplay.")
	await get_tree().process_frame


func _validate_dialogue_layout(director: DialogueDirector) -> void:
	var text := director.get("_text_label") as Label
	var choices := director.get("_choice_box") as VBoxContainer
	text.size.y = 31.0
	if text.position.y + text.size.y > choices.position.y:
		failures.append("Diálogo ainda permite sobreposição entre texto e escolhas.")


func _validate_shop_focus(director: DialogueDirector) -> void:
	var shop := director.get("_shop_ui") as ShopUI
	var previous_currency := GameState.currency
	GameState.currency = 999
	shop.open(&"mercador_vila")
	await get_tree().process_frame
	var items := shop.get("_items") as VBoxContainer
	if items.get_child_count() < 2:
		failures.append("Loja não carregou itens suficientes para testar o foco.")
	else:
		var second := items.get_child(1) as Button
		second.grab_focus()
		var definition: Dictionary = shop.get("_catalog").get("mercador_vila", {})
		shop.call("_buy", definition.get("items", [])[1])
		await get_tree().process_frame
		await get_tree().process_frame
		var focused := get_viewport().gui_get_focus_owner()
		if focused == null or StringName(focused.get_meta("item_id", "")) != &"municao_pistola":
			failures.append("Loja perdeu a seleção atual depois da compra.")
	shop.close()
	GameState.currency = previous_currency


func _validate_notification_separation(hud: GameHUD) -> void:
	if hud.currency_panel == null or hud.currency_label == null or hud.currency_panel.get_parent() != hud:
		failures.append("Moeda e estado da região não possuem apresentações separadas.")
	if NotificationManager == hud or NotificationManager.layer <= hud.layer:
		failures.append("Notificações importantes não possuem uma camada independente do HUD.")
	var before := NotificationManager.pending_count()
	NotificationManager.enqueue("PRIMEIRA", 10)
	NotificationManager.enqueue("SEGUNDA", 20)
	if NotificationManager.pending_count() < before + 2:
		failures.append("Fila de notificações sobrescreveu mensagens pendentes.")


func _validate_old_save_compatibility() -> void:
	var current := GameState.to_dictionary()
	var old_save := {"version": 3, "player_health": 4, "checkpoint_position": [120.0, 138.0]}
	GameState.apply_dictionary(old_save)
	if GameState.player_health != 4 or GameState.tutorial_flags == null:
		failures.append("Save antigo não recebeu defaults compatíveis.")
	GameState.apply_dictionary(current)


func _validate_ui_components() -> void:
	for path in [
		"res://assets/ui/themes/cangaco_ui_theme.tres",
		"res://scenes/ui/components/pixel_panel.tscn",
		"res://scenes/ui/components/menu_button.tscn",
		"res://scenes/ui/components/input_glyph.tscn",
		"res://scenes/ui/components/notification_toast.tscn",
		"res://scenes/ui/components/currency_counter.tscn",
		"res://scenes/ui/components/dialogue_box.tscn",
	]:
		if load(path) == null:
			failures.append("Componente de UI não carregou: %s" % path)
