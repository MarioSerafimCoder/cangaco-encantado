class_name CameraDirector
extends Node

@export var world_path: NodePath = NodePath("../VilaDoUmbuzeiro")
@export var player_path: NodePath = NodePath("../Nilo")
@export_range(0.1, 1.0) var transition_duration := 0.34
@export var base_vertical_offset := -42.0
@export_range(60.0, 100.0) var maximum_horizontal_look_ahead := 84.0
@export var ascending_look_ahead := -34.0
@export var falling_look_ahead := 42.0
@export var teleport_snap_distance := 640.0

var world: VilaGraybox
var player: NiloPlayer
var camera: Camera2D
var active_room: RoomController
var _transition_elapsed := 0.0
var _start_bounds := Rect2()
var _target_bounds := Rect2()
var _current_bounds := Rect2()
var _horizontal_look := 0.0
var _vertical_look := 0.0
var _previous_player_position := Vector2.ZERO
var _vertical_intent_time := 0.0


func _ready() -> void:
	add_to_group("camera_director")
	process_physics_priority = -100
	world = get_node(world_path) as VilaGraybox
	player = get_node(player_path) as NiloPlayer
	camera = player.camera
	camera.zoom = Vector2.ONE
	camera.drag_horizontal_enabled = false
	camera.drag_vertical_enabled = false
	_previous_player_position = player.global_position
	_select_room(true, true)
	_update_composition(1.0, true)


func _physics_process(delta: float) -> void:
	var teleported := player.global_position.distance_to(_previous_player_position) > teleport_snap_distance
	_previous_player_position = player.global_position
	_select_room(false, teleported)
	_update_composition(delta, teleported)
	if active_room == null or _current_bounds == _target_bounds:
		return
	_transition_elapsed = minf(transition_duration, _transition_elapsed + delta)
	var ratio := smoothstep(0.0, 1.0, _transition_elapsed / maxf(transition_duration, 0.01))
	_current_bounds = Rect2(
		_start_bounds.position.lerp(_target_bounds.position, ratio),
		_start_bounds.size.lerp(_target_bounds.size, ratio)
	)
	_apply_bounds(_current_bounds)


func _update_composition(delta: float, immediate := false) -> void:
	var maximum_speed := maxf(player.config.move_speed, 1.0)
	var speed_ratio := clampf(absf(player.velocity.x) / maximum_speed, 0.0, 1.0)
	var profile := active_room.camera_profile if active_room != null else "surface"
	var profile_horizontal := maximum_horizontal_look_ahead
	var profile_up := ascending_look_ahead
	var profile_down := falling_look_ahead
	match profile:
		"rooftops":
			profile_horizontal = 76.0
			profile_up = -48.0
			profile_down = 52.0
		"underground":
			profile_horizontal = 60.0
			profile_up = -28.0
			profile_down = 32.0
		"cavern":
			profile_horizontal = 66.0
			profile_up = -44.0
			profile_down = 50.0
	var horizontal_target := 0.0
	if speed_ratio > 0.08:
		horizontal_target = player.facing * lerpf(minf(54.0, profile_horizontal), profile_horizontal, smoothstep(0.15, 1.0, speed_ratio))
	var vertical_target := 0.0
	var has_vertical_intent := false
	if not player.is_on_floor() and player.velocity.y < -145.0:
		vertical_target = profile_up
		has_vertical_intent = true
	elif not player.is_on_floor() and player.velocity.y > 155.0:
		vertical_target = profile_down
		has_vertical_intent = true
	if has_vertical_intent:
		_vertical_intent_time += delta
	else:
		_vertical_intent_time = maxf(0.0, _vertical_intent_time - delta * 2.0)
	if _vertical_intent_time < 0.08:
		vertical_target = 0.0
	var horizontal_response := 1.0 if immediate else 1.0 - exp(-delta * (5.5 if horizontal_target != 0.0 else 3.4))
	var vertical_response := 1.0 if immediate else 1.0 - exp(-delta * (3.2 if vertical_target != 0.0 else 2.6))
	_horizontal_look = lerpf(_horizontal_look, horizontal_target, horizontal_response)
	_vertical_look = lerpf(_vertical_look, vertical_target, vertical_response)
	camera.position = Vector2(round(_horizontal_look), round(base_vertical_offset + _vertical_look))


func _select_room(immediate: bool, teleported := false) -> void:
	var candidate := _room_at_player_x()
	if candidate == null or candidate == active_room:
		return
	active_room = candidate
	_start_bounds = _camera_rect()
	_target_bounds = active_room.get_global_camera_bounds()
	_transition_elapsed = 0.0
	if immediate or teleported:
		_current_bounds = _target_bounds
		_transition_elapsed = transition_duration
		_apply_bounds(_current_bounds)


func _room_at_player_x() -> RoomController:
	var player_x := player.global_position.x
	for candidate in get_tree().get_nodes_in_group("production_rooms"):
		var room := candidate as RoomController
		if room == null:
			continue
		var bounds := room.get_global_bounds()
		if player_x >= bounds.position.x and player_x < bounds.end.x:
			return room
	return active_room


func _camera_rect() -> Rect2:
	return Rect2(
		float(camera.limit_left), float(camera.limit_top),
		float(camera.limit_right - camera.limit_left),
		float(camera.limit_bottom - camera.limit_top)
	)


func _apply_bounds(bounds: Rect2) -> void:
	_current_bounds = bounds
	camera.limit_left = roundi(bounds.position.x)
	camera.limit_top = roundi(bounds.position.y)
	camera.limit_right = roundi(bounds.end.x)
	camera.limit_bottom = roundi(bounds.end.y)
	camera.limit_smoothed = true


func is_transitioning() -> bool:
	return _transition_elapsed < transition_duration and _current_bounds != _target_bounds


func snap_to_room(room_id: StringName) -> void:
	for candidate in get_tree().get_nodes_in_group("production_rooms"):
		var room := candidate as RoomController
		if room == null or room.room_id != room_id:
			continue
		active_room = room
		_target_bounds = room.get_global_camera_bounds()
		_start_bounds = _target_bounds
		_current_bounds = _target_bounds
		_transition_elapsed = transition_duration
		_previous_player_position = player.global_position
		_apply_bounds(_target_bounds)
		_update_composition(1.0, true)
		camera.reset_smoothing()
		return
