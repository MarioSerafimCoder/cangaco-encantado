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
@export var stagger_duration := 1.2

