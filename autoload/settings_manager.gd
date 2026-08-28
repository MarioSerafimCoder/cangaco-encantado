extends Node

const SETTINGS_PATH := "user://cangaco_encantado_settings.json"

var master_volume := 1.0
var fullscreen := false
var screen_shake_enabled := true
var vsync_enabled := true
var resolution_index := 2
var vibration_enabled := true
var screen_shake_scale := 1.0
var reduce_flashes := false
var text_speed_index := 1
const WINDOW_RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]


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
	vsync_enabled = bool(parsed.get("vsync_enabled", true))
	resolution_index = clampi(int(parsed.get("resolution_index", 2)), 0, WINDOW_RESOLUTIONS.size() - 1)
	vibration_enabled = bool(parsed.get("vibration_enabled", true))
	screen_shake_scale = clampf(float(parsed.get("screen_shake_scale", 1.0)), 0.0, 1.0)
	reduce_flashes = bool(parsed.get("reduce_flashes", false))
	text_speed_index = clampi(int(parsed.get("text_speed_index", 1)), 0, 3)


func save_settings() -> bool:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Não foi possível salvar as configurações.")
		return false
	file.store_string(JSON.stringify({
		"master_volume": master_volume,
		"fullscreen": fullscreen,
		"screen_shake_enabled": screen_shake_enabled,
		"vsync_enabled": vsync_enabled,
		"resolution_index": resolution_index,
		"vibration_enabled": vibration_enabled,
		"screen_shake_scale": screen_shake_scale,
		"reduce_flashes": reduce_flashes,
		"text_speed_index": text_speed_index,
	}, "  "))
	file.close()
	return true


func apply_settings() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(master_volume, 0.0001)))
		AudioServer.set_bus_mute(master_bus, master_volume <= 0.001)
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		if not fullscreen:
			DisplayServer.window_set_size(WINDOW_RESOLUTIONS[resolution_index])


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


func set_vibration_enabled(value: bool) -> void:
	vibration_enabled = value
	save_settings()


func cycle_screen_shake_scale() -> void:
	var values := [1.0, 0.5, 0.25, 0.0]
	var index := values.find(screen_shake_scale)
	screen_shake_scale = values[(index + 1) % values.size()] if index >= 0 else 0.5
	screen_shake_enabled = screen_shake_scale > 0.0
	save_settings()


func set_reduce_flashes(value: bool) -> void:
	reduce_flashes = value
	save_settings()


func cycle_text_speed() -> void:
	text_speed_index = (text_speed_index + 1) % 4
	save_settings()


func text_speed_label() -> String:
	return ["LENTA", "NORMAL", "RÁPIDA", "INSTANTÂNEA"][text_speed_index]


func text_characters_per_second() -> float:
	return [22.0, 38.0, 64.0, 10000.0][text_speed_index]


func screen_shake_label() -> String:
	return ["DESLIGADO", "REDUZIDO", "MÉDIO", "COMPLETO"][clampi(int(round(screen_shake_scale * 3.0)), 0, 3)]


func set_vsync_enabled(value: bool) -> void:
	vsync_enabled = value
	apply_settings()
	save_settings()


func cycle_resolution() -> void:
	resolution_index = (resolution_index + 1) % WINDOW_RESOLUTIONS.size()
	apply_settings()
	save_settings()


func resolution_label() -> String:
	var size: Vector2i = WINDOW_RESOLUTIONS[resolution_index]
	return "%d×%d" % [size.x, size.y]
