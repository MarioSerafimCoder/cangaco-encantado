extends Node

const OCCUPIED := &"OCCUPIED"
const LIBERATED := &"LIBERATED"

var region_states := {"vila_umbuzeiro": OCCUPIED}
var flags := {
	"water_restored": false,
	"wind_restored": false,
	"smoke_cleared": false,
}


func reset_new_game() -> void:
	region_states = {"vila_umbuzeiro": OCCUPIED}
	flags = {
		"water_restored": false,
		"wind_restored": false,
		"smoke_cleared": false,
	}


func _ready() -> void:
	pass


func get_region_state(region_id: StringName) -> StringName:
	return StringName(region_states.get(String(region_id), OCCUPIED))


func set_region_state(region_id: StringName, state: StringName) -> void:
	if get_region_state(region_id) == state:
		return
	region_states[String(region_id)] = state
	EventBus.world_state_changed.emit(region_id, state)
	EventBus.request_autosave.emit(&"world_state")


func is_vila_liberated() -> bool:
	return get_region_state(&"vila_umbuzeiro") == LIBERATED


func liberate_vila() -> void:
	set_region_state(&"vila_umbuzeiro", LIBERATED)


func set_flag(flag_id: StringName, value: bool) -> void:
	flags[String(flag_id)] = value
	EventBus.world_flag_changed.emit(flag_id, value)
	EventBus.request_autosave.emit(&"world_flag")


func complete_area01_discovery() -> void:
	if bool(flags.get("area01_encantado_discovered", false)):
		return
	set_flag(&"area01_encantado_discovered", true)
	GameState.area_states["area_01_vila_umbuzeiro"] = "DISCOVERY_COMPLETE"
	set_region_state(&"vila_umbuzeiro", LIBERATED)
	EventBus.area_discovery_completed.emit(&"area_01_vila_umbuzeiro")


func to_dictionary() -> Dictionary:
	return {"region_states": region_states.duplicate(true), "flags": flags.duplicate(true)}


func apply_dictionary(data: Dictionary) -> void:
	region_states.merge(data.get("region_states", {}), true)
	flags.merge(data.get("flags", {}), true)
