class_name RoomController
extends Node2D

signal player_entered(room_id: StringName)
signal player_exited(room_id: StringName)

@export var room_id: StringName
@export var display_name := ""
@export var world_region_id: StringName = &"vila_umbuzeiro"
@export var local_bounds := Rect2(0.0, 0.0, 320.0, 180.0)
@export var camera_bounds := Rect2(0.0, -40.0, 320.0, 260.0)

var _active_player: NiloPlayer
var _debug_visible := false


func _ready() -> void:
	add_to_group("production_rooms")
	var room_area := get_node_or_null("Gameplay/Triggers/RoomArea") as Area2D
	if room_area != null:
		room_area.body_entered.connect(_on_body_entered)
		room_area.body_exited.connect(_on_body_exited)
	EventBus.world_state_changed.connect(_on_world_state_changed)
	_apply_rendering_profile()
	_refresh_world_state()
	set_process(true)


func _process(_delta: float) -> void:
	if _debug_visible == GameState.debug_overlay_enabled:
		return
	_debug_visible = GameState.debug_overlay_enabled
	queue_redraw()


func get_entrance(entrance_id: StringName) -> Marker2D:
	var entrances := get_node_or_null("Gameplay/Entrances")
	if entrances == null:
		return null
	return entrances.get_node_or_null(String(entrance_id)) as Marker2D


func get_global_bounds() -> Rect2:
	return Rect2(to_global(local_bounds.position), local_bounds.size)


func get_global_camera_bounds() -> Rect2:
	return Rect2(to_global(camera_bounds.position), camera_bounds.size)


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_active_player = body as NiloPlayer
	EventBus.room_entered.emit(room_id, display_name)
	player_entered.emit(room_id)


func _on_body_exited(body: Node) -> void:
	if body != _active_player:
		return
	_active_player = null
	player_exited.emit(room_id)


func _on_world_state_changed(region_id: StringName, _state: StringName) -> void:
	if region_id == world_region_id:
		_refresh_world_state()


func _refresh_world_state() -> void:
	var liberated := WorldState.get_region_state(world_region_id) == WorldState.LIBERATED
	var environment := get_node_or_null("Environment") as CanvasItem
	if environment != null:
		environment.self_modulate = Color("fff8e9") if liberated else Color("f0e6db")
	_set_group_visibility(&"room_occupied_only", not liberated)
	_set_group_visibility(&"room_liberated_only", liberated)


func _apply_rendering_profile() -> void:
	for candidate in find_children("*", "Sprite2D", true, false):
		var sprite := candidate as Sprite2D
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position = sprite.position.round()


func _set_group_visibility(group_id: StringName, value: bool) -> void:
	for candidate in get_tree().get_nodes_in_group(group_id):
		if candidate == self or not is_ancestor_of(candidate):
			continue
		if candidate is CanvasItem:
			(candidate as CanvasItem).visible = value
		elif candidate is Node:
			(candidate as Node).process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED


func _draw() -> void:
	if not _debug_visible:
		return
	draw_rect(local_bounds, Color(0.1, 0.85, 0.95, 0.9), false, 1.0)
	draw_rect(camera_bounds, Color(0.96, 0.76, 0.18, 0.9), false, 1.0)
	var geometry := get_node_or_null("Geometry")
	if geometry != null:
		for candidate in geometry.find_children("*", "CollisionShape2D", true, false):
			var collision := candidate as CollisionShape2D
			if collision == null or collision.shape is not RectangleShape2D:
				continue
			var rectangle := collision.shape as RectangleShape2D
			var center := to_local(collision.global_position)
			draw_rect(Rect2(center - rectangle.size * 0.5, rectangle.size), Color(0.95, 0.2, 0.28, 0.85), false, 1.0)
	var entrances := get_node_or_null("Gameplay/Entrances")
	if entrances != null:
		for marker in entrances.get_children():
			if marker is Marker2D:
				draw_circle((marker as Marker2D).position, 3.0, Color(0.2, 0.9, 0.45, 0.9), false, 1.0)
	var spawns := get_node_or_null("Gameplay/EnemySpawns")
	if spawns != null:
		for marker in spawns.get_children():
			if marker is Node2D:
				var point := (marker as Node2D).position
				draw_line(point + Vector2(-4.0, 0.0), point + Vector2(4.0, 0.0), Color(0.95, 0.25, 0.25), 1.0)
				draw_line(point + Vector2(0.0, -4.0), point + Vector2(0.0, 4.0), Color(0.95, 0.25, 0.25), 1.0)
