class_name EnemyDetection
extends Node

@export var detection_range := 150.0
var target: Node2D


func acquire(origin: Node2D) -> Node2D:
	if not is_instance_valid(target):
		target = origin.get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(target):
		return null
	if origin.global_position.distance_to(target.global_position) > detection_range:
		return null
	return target

