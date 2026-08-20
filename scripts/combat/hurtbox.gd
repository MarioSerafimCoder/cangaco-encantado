class_name Hurtbox
extends Area2D

@export_enum("player", "enemy", "neutral") var team := "neutral"


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0
	monitorable = true


func receive_hit(hit: Dictionary) -> bool:
	if String(hit.get("team", "neutral")) == team:
		return false
	var receiver := get_parent()
	if receiver.has_method("receive_hit"):
		return bool(receiver.receive_hit(hit))
	return false

