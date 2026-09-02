class_name CameraCompositionZone
extends Area2D

@export var horizontal_offset := 0.0
@export var vertical_offset := 0.0
@export var profile_override := ""
@export var composition_priority := 0

var _player_inside := false


func _ready() -> void:
	add_to_group("camera_composition_zones")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func is_active_for(player: Node) -> bool:
	return _player_inside and player != null


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
