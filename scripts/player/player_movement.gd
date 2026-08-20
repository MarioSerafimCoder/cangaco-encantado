class_name PlayerMovement
extends Node

@export var config: PlayerConfig

var coyote_remaining := 0.0
var jump_buffer_remaining := 0.0
var crouching := false


func physics_step(body: CharacterBody2D, delta: float, movement_locked: bool) -> void:
	if config == null:
		return
	var grounded_before_move := body.is_on_floor()
	if grounded_before_move:
		coyote_remaining = config.coyote_time
	else:
		coyote_remaining = maxf(0.0, coyote_remaining - delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_remaining = config.jump_buffer
	else:
		jump_buffer_remaining = maxf(0.0, jump_buffer_remaining - delta)

	crouching = grounded_before_move and Input.is_action_pressed("crouch") and not movement_locked
	var input_axis := Input.get_axis("move_left", "move_right")
	if movement_locked:
		input_axis = 0.0
	var speed_scale := config.crouch_speed_multiplier if crouching else 1.0
	var target_speed := input_axis * config.move_speed * speed_scale
	var acceleration := config.ground_acceleration if grounded_before_move else config.ground_acceleration * config.air_control
	if is_zero_approx(input_axis):
		acceleration = config.ground_deceleration if grounded_before_move else config.ground_deceleration * config.air_control
	body.velocity.x = move_toward(body.velocity.x, target_speed, acceleration * delta)

	if not grounded_before_move:
		var gravity_scale := config.fast_fall_multiplier if body.velocity.y > 0.0 and Input.is_action_pressed("move_down") else 1.0
		body.velocity.y += config.gravity * gravity_scale * delta

	if not movement_locked and jump_buffer_remaining > 0.0 and coyote_remaining > 0.0:
		body.velocity.y = config.jump_velocity
		jump_buffer_remaining = 0.0
		coyote_remaining = 0.0
	if Input.is_action_just_released("jump") and body.velocity.y < -70.0:
		body.velocity.y *= 0.48

	body.move_and_slide()


func debug_snapshot() -> Dictionary:
	return {
		"coyote": coyote_remaining,
		"jump_buffer": jump_buffer_remaining,
		"crouching": crouching,
	}

