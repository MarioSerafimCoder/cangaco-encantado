extends Node

const SAVE_PATH := "user://cangaco_encantado_save.json"


func _ready() -> void:
	EventBus.request_autosave.connect(_on_autosave_requested)


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível abrir o arquivo de save: %s" % FileAccess.get_open_error())
		return false
	var payload := {
		"game_state": GameState.to_dictionary(),
		"world_state": WorldState.to_dictionary(),
	}
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	EventBus.save_completed.emit(SAVE_PATH)
	return true


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_warning("Save inválido; iniciando um novo jogo.")
		return false
	GameState.apply_dictionary(parsed.get("game_state", {}))
	WorldState.apply_dictionary(parsed.get("world_state", {}))
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _on_autosave_requested(_reason: StringName) -> void:
	save_game()

