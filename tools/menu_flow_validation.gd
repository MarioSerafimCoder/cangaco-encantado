extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	var menu := main.get_node("FrontEndMenu") as FrontEndMenu
	var hud := main.get_node("HUD") as CanvasLayer
	_validate_initial_test_state(menu)
	_validate_pause_menu(menu, hud)
	_validate_settings(menu)
	_validate_controls(menu)
	_validate_new_game_confirmation(menu)
	_validate_title(menu, hud)
	menu.enter_game()
	if get_tree().paused:
		failures.append("O jogo permaneceu pausado depois de continuar.")
	if failures.is_empty():
		print("MENU_FLOW_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_initial_test_state(menu: FrontEndMenu) -> void:
	if menu.mode != FrontEndMenu.Mode.HIDDEN:
		failures.append("Cena de teste deveria iniciar diretamente no jogo.")
	if get_tree().paused:
		failures.append("Menu inicial pausou cenas de validação incorporadas.")


func _validate_pause_menu(menu: FrontEndMenu, hud: CanvasLayer) -> void:
	menu.show_pause()
	if menu.mode != FrontEndMenu.Mode.PAUSE or not get_tree().paused:
		failures.append("Menu de pausa não abriu ou não congelou o jogo.")
	for action in [&"continue", &"new_game", &"settings", &"controls", &"title", &"quit"]:
		if not menu.action_buttons.has(action):
			failures.append("Ação ausente no menu de pausa: %s." % action)
	if not hud.visible:
		failures.append("HUD deveria permanecer atrás da interface de pausa.")


func _validate_settings(menu: FrontEndMenu) -> void:
	menu.call("_open_settings")
	if menu.mode != FrontEndMenu.Mode.SETTINGS:
		failures.append("Tela de configurações não abriu.")
	for action in [&"volume", &"fullscreen", &"screen_shake", &"controls", &"back"]:
		if not menu.action_buttons.has(action):
			failures.append("Configuração ausente: %s." % action)


func _validate_controls(menu: FrontEndMenu) -> void:
	menu.call("_open_controls")
	if menu.mode != FrontEndMenu.Mode.CONTROLS:
		failures.append("Tela de controles não abriu.")
	var combined_text := ""
	for child in menu.get_node("MenuRoot/MenuContent").get_children():
		if child is Label or child is Button:
			combined_text += child.text + "\n"
	for expected in ["FACÃO", "PISTOLA", "RIFLE", "ATAQUE ESPECIAL", "PAUSAR"]:
		if expected not in combined_text:
			failures.append("Tela de controles não informa: %s." % expected)
	menu.call("_return_from_submenu")
	if menu.mode != FrontEndMenu.Mode.PAUSE:
		failures.append("Voltar dos controles não retornou ao menu de pausa.")


func _validate_new_game_confirmation(menu: FrontEndMenu) -> void:
	menu.call("_open_new_game_confirmation")
	if menu.mode != FrontEndMenu.Mode.CONFIRM_NEW_GAME:
		failures.append("Confirmação de novo jogo não abriu.")
	if not menu.action_buttons.has(&"confirm_new_game") or not menu.action_buttons.has(&"cancel"):
		failures.append("Confirmação de novo jogo não oferece confirmar e cancelar.")
	var confirm_button := menu.action_buttons.get(&"confirm_new_game") as Button
	if confirm_button == null or "APAGAR" not in confirm_button.text:
		failures.append("A ação destrutiva não está identificada claramente.")
	menu.call("_return_from_submenu")


func _validate_title(menu: FrontEndMenu, hud: CanvasLayer) -> void:
	menu.show_title(true)
	if menu.mode != FrontEndMenu.Mode.TITLE or not get_tree().paused:
		failures.append("Menu inicial não abriu em estado pausado.")
	for action in [&"continue", &"new_game", &"settings", &"controls", &"quit"]:
		if not menu.action_buttons.has(action):
			failures.append("Ação ausente no menu inicial: %s." % action)
	if hud.visible:
		failures.append("HUD de combate deveria ficar oculto no menu inicial.")
