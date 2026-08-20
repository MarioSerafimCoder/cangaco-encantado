class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal damaged(amount: int, source: Node)
signal healed(amount: int)
signal died

@export var max_health := 5
@export var current_health := 5
var dead := false


func _ready() -> void:
	current_health = clampi(current_health, 1, max_health)
	health_changed.emit(current_health, max_health)


func configure(new_maximum: int, start_full := true) -> void:
	max_health = maxi(1, new_maximum)
	if start_full:
		current_health = max_health
	else:
		current_health = clampi(current_health, 0, max_health)
	dead = current_health <= 0
	health_changed.emit(current_health, max_health)


func take_damage(amount: int, source: Node = null) -> bool:
	if dead or amount <= 0:
		return false
	current_health = maxi(0, current_health - amount)
	damaged.emit(amount, source)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		dead = true
		died.emit()
	return true


func heal(amount: int) -> int:
	if dead or amount <= 0:
		return 0
	var previous := current_health
	current_health = mini(max_health, current_health + amount)
	var restored := current_health - previous
	if restored > 0:
		healed.emit(restored)
		health_changed.emit(current_health, max_health)
	return restored


func restore_full() -> void:
	dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)

