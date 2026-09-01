class_name PlayerMovement
extends Node

@export var config: PlayerConfig

var coyote_remaining := 0.0
var jump_buffer_remaining := 0.0
var crouching := false
var movement_hold_time := 0.0
var running_active := false
var speed_ramp := 0.0
var _held_direction := 0.0
var dash_remaining := 0.0
var dash_cooldown_remaining := 0.0
var dash_direction := 1.0


func physics_step(body: CharacterBody2D, delta: float, movement_locked: bool) -> void:
	if config == null:
		return
	dash_cooldown_remaining = maxf(0.0, dash_cooldown_remaining - delta)
	if dash_remaining > 0.0:
		dash_remaining = maxf(0.0, dash_remaining - delta)
		body.velocity = Vector2(dash_direction * config.dash_speed, 0.0)
		body.move_and_slide()
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
	_update_speed_ramp(input_axis, delta, movement_locked or crouching)
	var speed_scale := config.crouch_speed_multiplier if crouching else lerpf(config.walk_speed_multiplier, 1.0, smoothstep(0.0, 1.0, speed_ramp))
	var target_speed := input_axis * config.move_speed * speed_scale
	var acceleration := config.ground_acceleration if grounded_before_move else config.ground_acceleration * config.air_control
	if is_zero_approx(input_axis):
		acceleration = config.ground_deceleration if grounded_before_move else config.ground_deceleration * config.air_control
	elif not is_zero_approx(body.velocity.x) and signf(body.velocity.x) != signf(input_axis):
		acceleration = config.ground_deceleration * config.direction_change_multiplier
	body.velocity.x = move_toward(body.velocity.x, target_speed, acceleration * delta)
	running_active = absf(body.velocity.x) >= config.move_speed * config.run_animation_threshold

	if not movement_locked and GameState.abilities.get("dash", false) and Input.is_action_just_pressed("dash") and dash_cooldown_remaining <= 0.0:
		dash_direction = signf(input_axis) if not is_zero_approx(input_axis) else (body as NiloPlayer).facing
		dash_remaining = config.dash_duration
		dash_cooldown_remaining = config.dash_cooldown
		body.velocity = Vector2(dash_direction * config.dash_speed, 0.0)
		body.move_and_slide()
		return

	if not grounded_before_move:
		var gravity_scale := config.fast_fall_multiplier if body.velocity.y > 0.0 and Input.is_action_pressed("move_down") else 1.0
		body.velocity.y += config.gravity * gravity_scale * delta

	var can_wall_jump: bool = not grounded_before_move and body.is_on_wall_only() and bool(GameState.abilities.get("wall_jump", false))
	if not movement_locked and jump_buffer_remaining > 0.0 and can_wall_jump:
		var wall_normal := body.get_wall_normal()
		body.velocity = Vector2(wall_normal.x * config.wall_jump_velocity.x, config.wall_jump_velocity.y)
		jump_buffer_remaining = 0.0
		coyote_remaining = 0.0
	elif not movement_locked and jump_buffer_remaining > 0.0 and coyote_remaining > 0.0:
		body.velocity.y = config.jump_velocity
		if running_active and not is_zero_approx(input_axis):
			body.velocity.x = signf(input_axis) * maxf(absf(body.velocity.x), config.run_jump_speed)
		jump_buffer_remaining = 0.0
		coyote_remaining = 0.0
	if Input.is_action_just_released("jump") and body.velocity.y < -70.0:
		body.velocity.y *= 0.48

	body.move_and_slide()


func _update_speed_ramp(input_axis: float, delta: float, force_reset: bool) -> void:
	if force_reset or is_zero_approx(input_axis):
		movement_hold_time = 0.0
		running_active = false
		_held_direction = 0.0
		speed_ramp = move_toward(speed_ramp, 0.0, delta / 0.12)
		return
	var input_direction := signf(input_axis)
	if not is_equal_approx(input_direction, _held_direction):
		movement_hold_time = 0.0
		running_active = false
		_held_direction = input_direction
		speed_ramp = minf(speed_ramp, 0.18)
	else:
		movement_hold_time += delta
	speed_ramp = move_toward(speed_ramp, 1.0, delta / maxf(config.time_to_max_speed, 0.01))


func debug_snapshot() -> Dictionary:
	return {
		"coyote": coyote_remaining,
		"jump_buffer": jump_buffer_remaining,
		"crouching": crouching,
		"movement_hold_time": movement_hold_time,
		"speed_ramp": speed_ramp,
		"running": running_active,
		"dash_remaining": dash_remaining,
		"dash_cooldown": dash_cooldown_remaining,
	}
