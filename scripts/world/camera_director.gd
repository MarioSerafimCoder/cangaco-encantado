class_name CameraDirector
extends Node

@export var world_path: NodePath = NodePath("../VilaDoUmbuzeiro")
@export var player_path: NodePath = NodePath("../Nilo")
@export_range(0.1, 1.0) var transition_duration := 0.34
@export var teleport_snap_distance := 960.0

var world: VilaGraybox
var player: NiloPlayer
var camera: Camera2D
var active_room: RoomController
var _transition_elapsed := 0.0
var _start_bounds := Rect2()
var _target_bounds := Rect2()
var _current_bounds := Rect2()


func _ready() -> void:
	process_physics_priority = -100
	world = get_node(world_path) as VilaGraybox
	player = get_node(player_path) as NiloPlayer
	camera = player.camera
	_select_room(true)


func _physics_process(delta: float) -> void:
	_select_room(false)
	if active_room == null or _current_bounds == _target_bounds:
		return
	_transition_elapsed = minf(transition_duration, _transition_elapsed + delta)
	var ratio := smoothstep(0.0, 1.0, _transition_elapsed / maxf(transition_duration, 0.01))
	_current_bounds = Rect2(
		_start_bounds.position.lerp(_target_bounds.position, ratio),
		_start_bounds.size.lerp(_target_bounds.size, ratio)
	)
	_apply_bounds(_current_bounds)


func _select_room(immediate: bool) -> void:
	var candidate := _room_at_player_x()
	if candidate == null or candidate == active_room:
		return
	active_room = candidate
	_start_bounds = _camera_rect()
	_target_bounds = active_room.get_global_camera_bounds()
	_transition_elapsed = 0.0
	var long_distance_transition := _start_bounds.get_center().distance_to(_target_bounds.get_center()) > teleport_snap_distance
	if immediate or long_distance_transition:
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
