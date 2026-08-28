class_name PlayerConfig
extends Resource

@export_category("Locomoção")
@export var move_speed := 120.0
@export_range(0.2, 1.0) var walk_speed_multiplier := 0.58
@export_range(0.1, 5.0) var run_hold_duration := 2.0
@export var ground_acceleration := 1400.0
@export var ground_deceleration := 1800.0
@export_range(0.0, 1.0) var air_control := 0.75
@export var gravity := 900.0
@export var jump_velocity := -290.0
@export var fast_fall_multiplier := 1.35
@export var coyote_time := 0.10
@export var jump_buffer := 0.12
@export var crouch_speed_multiplier := 0.35
@export var wall_jump_velocity := Vector2(185.0, -275.0)
@export var dash_speed := 285.0
@export var dash_duration := 0.16
@export var dash_cooldown := 0.42
@export var run_jump_speed := 150.0

@export_category("Combate e sobrevivência")
@export var max_health := 5
@export var hurt_lock_time := 0.15
@export var invulnerability_time := 0.65
@export var heal_charges := 2
@export var heal_amount := 2
@export var heal_duration := 1.10
