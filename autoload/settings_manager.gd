extends Node

const SETTINGS_PATH := "user://cangaco_encantado_settings.json"

var master_volume := 1.0
var fullscreen := false
var screen_shake_enabled := true


func _ready() -> void:
	load_settings()
	apply_settings()


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	master_volume = clampf(float(parsed.get("master_volume", 1.0)), 0.0, 1.0)
	fullscreen = bool(parsed.get("fullscreen", false))
	screen_shake_enabled = bool(parsed.get("screen_shake_enabled", true))


func save_settings() -> bool:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar as configurações.")
		return false
	file.store_string(JSON.stringify({
		"master_volume": master_volume,
		"fullscreen": fullscreen,
		"screen_shake_enabled": screen_shake_enabled,
	}, "  "))
	file.close()
	return true


func apply_settings() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.0001)))
		AudioServer.set_bus_mute(master_bus, master_volume <= 0.001)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_settings()
	save_settings()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_settings()
	save_settings()


func set_screen_shake_enabled(value: bool) -> void:
	screen_shake_enabled = value
	save_settings()
