class_name CameraParallaxLayer
extends Node2D

@export var scroll_scale := Vector2.ONE
@export var camera_anchor := Vector2(320.0, 90.0)
@export var activation_bounds := Rect2(-200.0, -120.0, 1040.0, 420.0)
@export var pixel_snap := true

var _base_position := Vector2.ZERO


func _ready() -> void:
	_base_position = position


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d() as Camera2D
	if camera == null:
		return
	var parent_2d := get_parent() as Node2D
	if parent_2d == null:
		return
	var camera_position: Vector2 = parent_2d.to_local(camera.get_screen_center_position())
	visible = activation_bounds.has_point(camera_position)
	if not visible:
		return
	var offset: Vector2 = (camera_position - camera_anchor) * (Vector2.ONE - scroll_scale)
	var target: Vector2 = _base_position + offset
	position = target.round() if pixel_snap else target
