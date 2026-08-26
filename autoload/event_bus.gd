extends Node

signal checkpoint_activated(checkpoint_id: StringName, position: Vector2)
signal player_health_changed(current: int, maximum: int)
signal player_ammo_changed(weapon_id: StringName, current: int, maximum: int)
signal player_heal_charges_changed(current: int, maximum: int)
signal player_died
signal boss_defeated(boss_id: StringName)
signal room_entered(room_id: StringName, display_name: String)
signal encounter_completed(encounter_id: StringName)
signal shortcut_opened(shortcut_id: StringName)
signal ability_unlocked(ability_id: StringName, display_name: String)
signal permanent_upgrade_collected(upgrade_id: StringName, display_name: String)
signal secret_discovered(secret_id: StringName)
signal world_state_changed(region_id: StringName, state: StringName)
signal save_completed(path: String)
signal request_autosave(reason: StringName)
