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


func has_line_of_sight(origin: Node2D, candidate: Node2D) -> bool:
	if origin == null or candidate == null or not is_instance_valid(candidate):
		return false
	var space_state := origin.get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		origin.global_position + Vector2(0.0, -6.0),
		candidate.global_position + Vector2(0.0, -6.0),
		1
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return space_state.intersect_ray(query).is_empty()
