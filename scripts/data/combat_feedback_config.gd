class_name CombatFeedbackConfig
extends Resource

@export_category("Hitstop")
@export var machete_hitstop_1 := 0.030
@export var machete_hitstop_2 := 0.035
@export var machete_hitstop_3 := 0.055
@export var pistol_hitstop := 0.020
@export var rifle_hitstop := 0.040
@export var special_hitstop := 0.075
@export var posture_break_hitstop := 0.070

@export_category("Combo")
@export var combo_input_buffer := 0.14
@export var combo_reset_time := 0.9


func machete_hitstop(combo_step: int) -> float:
	match combo_step:
		2:
			return machete_hitstop_2
		3:
			return machete_hitstop_3
	return machete_hitstop_1
