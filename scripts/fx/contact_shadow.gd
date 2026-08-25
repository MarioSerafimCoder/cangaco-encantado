class_name ContactShadow2D
extends Node2D

@export var ground_offset := 12.0
@export var half_width := 8.0
@export var half_height := 2.0
@export var ground_color := Color(0.08, 0.055, 0.045, 0.48)
@export var maximum_air_height := 84.0

var _actor: CharacterBody2D
var _ground_y := 0.0
var _last_air_ratio := -1.0


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	top_level = true
	z_as_relative = false
	z_index = 9
	if _actor != null:
		_ground_y = _actor.global_position.y + ground_offset
	_update_shadow(true)


func _process(_delta: float) -> void:
	_update_shadow(false)


func _update_shadow(force_redraw: bool) -> void:
	if _actor == null or not is_instance_valid(_actor):
		queue_free()
		return
	if _actor.is_on_floor():
		_ground_y = _actor.global_position.y + ground_offset
	var feet_y := _actor.global_position.y + ground_offset
	var air_height := maxf(0.0, _ground_y - feet_y)
	var air_ratio := clampf(air_height / maxf(maximum_air_height, 1.0), 0.0, 1.0)
	global_position = Vector2(round(_actor.global_position.x), round(_ground_y))
	if force_redraw or absf(air_ratio - _last_air_ratio) >= 0.025:
		_last_air_ratio = air_ratio
		queue_redraw()


func _draw() -> void:
	var air_ratio := maxf(_last_air_ratio, 0.0)
	var width := half_width * lerpf(1.0, 0.55, air_ratio)
	var height := half_height * lerpf(1.0, 0.65, air_ratio)
	var color := ground_color
	color.a *= lerpf(1.0, 0.3, air_ratio)
	var points := PackedVector2Array([
		Vector2(-width + 2.0, -height),
		Vector2(width - 2.0, -height),
		Vector2(width, 0.0),
		Vector2(width - 2.0, height),
		Vector2(-width + 2.0, height),
		Vector2(-width, 0.0),
	])
	draw_colored_polygon(points, color)
