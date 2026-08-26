class_name EnemyData
extends Resource

enum Behavior { MELEE, RANGED, AREA_CONTROL, MOBILE, ELITE, BOSS }

@export var id: StringName
@export var display_name := "Inimigo"
@export var behavior := Behavior.MELEE
@export var max_health := 3
@export var max_posture := 4.0
@export var move_speed := 45.0
@export var detection_range := 150.0
@export var attack_range := 28.0
@export var attack_damage := 1
@export var attack_cooldown := 1.0
@export var attack_windup := 0.24
@export var attack_active_time := 0.08
@export var attack_recovery := 0.24
@export var stagger_duration := 1.2
@export var hurt_duration := 0.18
@export var death_duration := 0.9
@export var patrol_radius := 42.0
@export var patrol_wait := 0.75
@export var target_memory := 1.25
@export var leash_range := 220.0
@export var ranged_min_distance := 58.0
@export var ranged_preferred_distance := 98.0
