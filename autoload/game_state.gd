extends Node

const DEFAULT_CHECKPOINT := &"vila_casa"
const DEFAULT_SPAWN := Vector2(120.0, 138.0)

var checkpoint_id: StringName = DEFAULT_CHECKPOINT
var checkpoint_position := DEFAULT_SPAWN
var player_health := 5
var heal_charges := 2
var debug_overlay_enabled := false
var abilities := {
	"wall_jump": false,
	"dash": false,
	"water_movement": false,
	"double_jump": false,
	"air_dash": false,
	"spectral_dash": false,
	"magic_gifts": false,
}
var defeated_bosses: Dictionary = {}
var opened_shortcuts: Dictionary = {}
var discovered_secrets: Dictionary = {}
var visited_rooms: Dictionary = {}
var current_room_id: StringName = &"casa_nilo"
var permanent_upgrades: Dictionary = {}
var max_health_bonus := 0
var currency := 35
var inventory := {
	"consumables": {},
	"important_items": {},
	"collectibles": {},
}
var purchased_items: Dictionary = {}
var npc_states: Dictionary = {}
var dialogue_flags: Dictionary = {}
var area_states := {"area_01_vila_umbuzeiro": "INTRO"}


func _ready() -> void:
	EventBus.checkpoint_activated.connect(_on_checkpoint_activated)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.shortcut_opened.connect(_on_shortcut_opened)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.ability_unlocked.connect(_on_ability_unlocked)
	EventBus.permanent_upgrade_collected.connect(_on_permanent_upgrade_collected)
	EventBus.secret_discovered.connect(_on_secret_discovered)


func reset_new_game() -> void:
	checkpoint_id = DEFAULT_CHECKPOINT
	checkpoint_position = DEFAULT_SPAWN
	player_health = 5
	heal_charges = 2
	debug_overlay_enabled = false
	defeated_bosses.clear()
	opened_shortcuts.clear()
	discovered_secrets.clear()
	visited_rooms = {"casa_nilo": true}
	current_room_id = &"casa_nilo"
	permanent_upgrades.clear()
	max_health_bonus = 0
	currency = 35
	inventory = {"consumables": {}, "important_items": {}, "collectibles": {}}
	purchased_items.clear()
	npc_states.clear()
	dialogue_flags.clear()
	area_states = {"area_01_vila_umbuzeiro": "INTRO"}
	for ability in abilities:
		abilities[ability] = false


func to_dictionary() -> Dictionary:
	return {
		"version": 3,
		"checkpoint_id": String(checkpoint_id),
		"checkpoint_position": [checkpoint_position.x, checkpoint_position.y],
		"player_health": player_health,
		"heal_charges": heal_charges,
		"abilities": abilities.duplicate(true),
		"defeated_bosses": defeated_bosses.duplicate(true),
		"opened_shortcuts": opened_shortcuts.duplicate(true),
		"discovered_secrets": discovered_secrets.duplicate(true),
		"visited_rooms": visited_rooms.duplicate(true),
		"current_room_id": String(current_room_id),
		"permanent_upgrades": permanent_upgrades.duplicate(true),
		"max_health_bonus": max_health_bonus,
		"currency": currency,
		"inventory": inventory.duplicate(true),
		"purchased_items": purchased_items.duplicate(true),
		"npc_states": npc_states.duplicate(true),
		"dialogue_flags": dialogue_flags.duplicate(true),
		"area_states": area_states.duplicate(true),
	}


func apply_dictionary(data: Dictionary) -> void:
	checkpoint_id = StringName(data.get("checkpoint_id", String(DEFAULT_CHECKPOINT)))
	var saved_position: Array = data.get("checkpoint_position", [DEFAULT_SPAWN.x, DEFAULT_SPAWN.y])
	if saved_position.size() >= 2:
		checkpoint_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	max_health_bonus = maxi(0, int(data.get("max_health_bonus", 0)))
	player_health = clampi(int(data.get("player_health", 5)), 1, 5 + max_health_bonus)
	heal_charges = clampi(int(data.get("heal_charges", 2)), 0, 2)
	abilities.merge(data.get("abilities", {}), true)
	defeated_bosses = data.get("defeated_bosses", {}).duplicate(true)
	opened_shortcuts = data.get("opened_shortcuts", {}).duplicate(true)
	discovered_secrets = data.get("discovered_secrets", {}).duplicate(true)
	visited_rooms = data.get("visited_rooms", {"casa_nilo": true}).duplicate(true)
	current_room_id = StringName(data.get("current_room_id", "casa_nilo"))
	permanent_upgrades = data.get("permanent_upgrades", {}).duplicate(true)
	currency = maxi(0, int(data.get("currency", 35)))
	inventory = data.get("inventory", {"consumables": {}, "important_items": {}, "collectibles": {}}).duplicate(true)
	for category in ["consumables", "important_items", "collectibles"]:
		if not inventory.has(category):
			inventory[category] = {}
	purchased_items = data.get("purchased_items", {}).duplicate(true)
	npc_states = data.get("npc_states", {}).duplicate(true)
	dialogue_flags = data.get("dialogue_flags", {}).duplicate(true)
	area_states = data.get("area_states", {"area_01_vila_umbuzeiro": "INTRO"}).duplicate(true)


func add_currency(amount: int) -> void:
	currency = maxi(0, currency + amount)
	EventBus.currency_changed.emit(currency)


func spend_currency(amount: int) -> bool:
	if amount < 0 or currency < amount:
		return false
	currency -= amount
	EventBus.currency_changed.emit(currency)
	return true


func add_inventory_item(category: StringName, item_id: StringName, amount := 1) -> void:
	var category_key := String(category)
	if not inventory.has(category_key):
		inventory[category_key] = {}
	var items: Dictionary = inventory[category_key]
	items[String(item_id)] = maxi(0, int(items.get(String(item_id), 0)) + amount)
	EventBus.inventory_changed.emit(category, item_id, int(items[String(item_id)]))
	EventBus.request_autosave.emit(&"inventory")


func inventory_amount(category: StringName, item_id: StringName) -> int:
	return int(inventory.get(String(category), {}).get(String(item_id), 0))


func set_dialogue_flag(flag_id: StringName, value := true) -> void:
	dialogue_flags[String(flag_id)] = value
	EventBus.request_autosave.emit(&"dialogue")


func _on_checkpoint_activated(new_id: StringName, new_position: Vector2) -> void:
	checkpoint_id = new_id
	checkpoint_position = new_position
	player_health = 5 + max_health_bonus
	heal_charges = 2
	EventBus.request_autosave.emit(&"checkpoint")


func _on_boss_defeated(boss_id: StringName) -> void:
	defeated_bosses[String(boss_id)] = true
	EventBus.request_autosave.emit(&"boss_defeated")


func _on_shortcut_opened(shortcut_id: StringName) -> void:
	opened_shortcuts[String(shortcut_id)] = true
	EventBus.request_autosave.emit(&"shortcut")


func _on_room_entered(room_id: StringName, _display_name: String) -> void:
	current_room_id = room_id
	if not visited_rooms.has(String(room_id)):
		visited_rooms[String(room_id)] = true
		EventBus.request_autosave.emit(&"room_discovered")


func _on_ability_unlocked(ability_id: StringName, _display_name: String) -> void:
	abilities[String(ability_id)] = true
	EventBus.request_autosave.emit(&"ability")


func _on_permanent_upgrade_collected(upgrade_id: StringName, _display_name: String) -> void:
	permanent_upgrades[String(upgrade_id)] = true
	EventBus.request_autosave.emit(&"permanent_upgrade")


func _on_secret_discovered(secret_id: StringName) -> void:
	discovered_secrets[String(secret_id)] = true
	EventBus.request_autosave.emit(&"secret")
