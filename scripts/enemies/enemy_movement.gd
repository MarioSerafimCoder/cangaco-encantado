class_name EnemyMovement
extends Node

@export var move_speed := 45.0
@export var acceleration := 420.0
@export var gravity := 900.0


func physics_step(body: CharacterBody2D, direction: float, delta: float, enabled: bool) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	var target_speed := direction * move_speed if enabled else 0.0
	body.velocity.x = move_toward(body.velocity.x, target_speed, acceleration * delta)
	body.move_and_slide()

