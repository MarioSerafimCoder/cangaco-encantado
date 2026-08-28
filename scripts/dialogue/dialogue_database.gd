extends Node

const DATA_PATH := "res://resources/dialogues/area_01_dialogues.json"

var conversations: Dictionary = {}


func _ready() -> void:
	_reload()


func _reload() -> void:
	conversations.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Base de diálogos ausente: %s" % DATA_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		conversations = parsed
	else:
		push_error("Base de diálogos inválida: %s" % DATA_PATH)


func get_conversation(dialogue_id: StringName) -> Array:
	var definition: Dictionary = conversations.get(String(dialogue_id), {})
	var variants: Array = definition.get("variants", [])
	for variant in variants:
		if _conditions_match(variant.get("conditions", {})):
			return variant.get("lines", []).duplicate(true)
	return definition.get("lines", []).duplicate(true)


func _conditions_match(conditions: Dictionary) -> bool:
	var world_flags: Dictionary = conditions.get("world_flags", {})
	for flag_id in world_flags:
		if bool(WorldState.flags.get(flag_id, false)) != bool(world_flags[flag_id]):
			return false
	var dialogue_flags: Dictionary = conditions.get("dialogue_flags", {})
	for flag_id in dialogue_flags:
		if bool(GameState.dialogue_flags.get(flag_id, false)) != bool(dialogue_flags[flag_id]):
			return false
	for room_id in conditions.get("visited_rooms", []):
		if not bool(GameState.visited_rooms.get(room_id, false)):
			return false
	return true
