class_name PostureComponent
extends Node

signal posture_changed(current: float, maximum: float)
signal posture_broken(duration: float)

@export var max_posture := 4.0
@export var stagger_duration := 1.2
@export var recovery_per_second := 0.75
var current_posture := 4.0
var broken := false


func _ready() -> void:
	current_posture = max_posture


func _process(delta: float) -> void:
	if broken or current_posture >= max_posture:
		return
	current_posture = minf(max_posture, current_posture + recovery_per_second * delta)
	posture_changed.emit(current_posture, max_posture)


func configure(new_maximum: float, new_stagger_duration: float) -> void:
	max_posture = maxf(0.1, new_maximum)
	current_posture = max_posture
	stagger_duration = new_stagger_duration


func apply_posture_damage(amount: float) -> void:
	if broken or amount <= 0.0:
		return
	current_posture = maxf(0.0, current_posture - amount)
	posture_changed.emit(current_posture, max_posture)
	if is_zero_approx(current_posture):
		broken = true
		posture_broken.emit(stagger_duration)
		_reset_after_stagger()


func _reset_after_stagger() -> void:
	await get_tree().create_timer(stagger_duration).timeout
	current_posture = max_posture
	broken = false
	posture_changed.emit(current_posture, max_posture)

