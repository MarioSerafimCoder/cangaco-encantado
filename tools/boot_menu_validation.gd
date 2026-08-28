extends Node

var failures: Array[String] = []


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	await get_tree().process_frame
	var main := $Main
	var menu := main.get_node("FrontEndMenu") as FrontEndMenu
	var hud := main.get_node("HUD") as CanvasLayer
	if menu.mode != FrontEndMenu.Mode.TITLE:
		failures.append("Uma inicialização normal não abriu o menu inicial.")
	if not get_tree().paused:
		failures.append("O mundo não foi pausado atrás do menu inicial.")
	if hud.visible:
		failures.append("O HUD de combate apareceu no menu inicial.")
	if not menu.action_buttons.has(&"new_game") or not menu.action_buttons.has(&"continue"):
		failures.append("O menu inicial não apresentou Novo jogo e Continuar.")
	if failures.is_empty():
		print("BOOT_MENU_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)
