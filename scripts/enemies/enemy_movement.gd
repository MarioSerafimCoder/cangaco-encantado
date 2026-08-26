class_name EnemyMovement
extends Node

@export var move_speed := 45.0
@export var acceleration := 420.0
@export var gravity := 900.0
@export var obstacle_probe_distance := 15.0
@export var ledge_probe_depth := 24.0


func safe_direction(body: CharacterBody2D, desired_direction: float) -> float:
	var direction := signf(desired_direction)
	if is_zero_approx(direction) or not body.is_on_floor():
		return direction
	var space_state := body.get_world_2d().direct_space_state
	var wall_query := PhysicsRayQueryParameters2D.create(
		body.global_position + Vector2(0.0, -5.0),
		body.global_position + Vector2(direction * obstacle_probe_distance, -5.0),
		1
	)
	wall_query.collide_with_areas = false
	wall_query.collide_with_bodies = true
	if not space_state.intersect_ray(wall_query).is_empty():
		return 0.0
	var ledge_x := direction * (obstacle_probe_distance - 2.0)
	var ground_query := PhysicsRayQueryParameters2D.create(
		body.global_position + Vector2(ledge_x, 7.0),
		body.global_position + Vector2(ledge_x, ledge_probe_depth),
		1
	)
	ground_query.collide_with_areas = false
	ground_query.collide_with_bodies = true
	if space_state.intersect_ray(ground_query).is_empty():
		return 0.0
	return direction


func physics_step(body: CharacterBody2D, direction: float, delta: float, enabled: bool) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	var safe_input := safe_direction(body, direction) if enabled else 0.0
	var target_speed := safe_input * move_speed
	body.velocity.x = move_toward(body.velocity.x, target_speed, acceleration * delta)
	body.move_and_slide()
