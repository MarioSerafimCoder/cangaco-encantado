class_name EnemySpawn
extends Marker2D

enum RespawnBehavior { ON_ROOM_LOAD, ON_WORLD_RESET, NEVER }

@export var enemy_scene: PackedScene
@export var spawn_id: StringName
@export var active_if_occupied := true
@export var facing := -1.0
@export var patrol_radius := -1.0
@export var respawn_behavior := RespawnBehavior.ON_ROOM_LOAD
@export var activation_flag: StringName
@export var required_tutorial: StringName

var spawned_enemy: EnemyBase


func _ready() -> void:
	add_to_group("enemy_spawn_points")
	EventBus.world_state_changed.connect(_on_world_state_changed)
	EventBus.world_flag_changed.connect(_on_world_flag_changed)
	EventBus.tutorial_completed.connect(_on_tutorial_completed)
	_refresh_spawn.call_deferred()


func has_live_enemy() -> bool:
	return spawned_enemy != null and is_instance_valid(spawned_enemy) and not spawned_enemy.is_queued_for_deletion()


func _refresh_spawn() -> void:
	var flag_allows := activation_flag.is_empty() or bool(WorldState.flags.get(String(activation_flag), false))
	var tutorial_allows := required_tutorial.is_empty() or GameState.tutorial_learned(required_tutorial)
	var should_be_active := flag_allows and tutorial_allows and (not active_if_occupied or not WorldState.is_vila_liberated())
	if not should_be_active:
		if has_live_enemy():
			spawned_enemy.queue_free()
		spawned_enemy = null
		return
	if has_live_enemy() or enemy_scene == null:
		return
	spawned_enemy = enemy_scene.instantiate() as EnemyBase
	var actors := get_node_or_null("../../Actors")
	if actors == null:
		actors = get_parent()
	actors.add_child(spawned_enemy)
	spawned_enemy.global_position = global_position
	spawned_enemy.configure_post(global_position, facing, patrol_radius)


func _on_world_state_changed(region_id: StringName, _state: StringName) -> void:
	if region_id == &"vila_umbuzeiro":
		_refresh_spawn.call_deferred()


func _on_world_flag_changed(flag_id: StringName, _value: bool) -> void:
	if flag_id == activation_flag:
		_refresh_spawn.call_deferred()


func _on_tutorial_completed(tutorial_id: StringName) -> void:
	if tutorial_id == required_tutorial:
		_refresh_spawn.call_deferred()
