class_name EnemyStateMachine
extends Node

enum State { IDLE, CHASE, ATTACK, HURT, STAGGER, DEAD }

signal state_changed(previous: State, current: State)

var current := State.IDLE
var lock_remaining := 0.0


func transition(next: State, lock_duration := 0.0, force := false) -> bool:
	if current == State.DEAD and not force:
		return false
	if lock_remaining > 0.0 and not force and next not in [State.HURT, State.STAGGER, State.DEAD]:
		return false
	var previous := current
	current = next
	lock_remaining = maxf(0.0, lock_duration)
	if previous != current:
		state_changed.emit(previous, current)
	return true


func tick(delta: float) -> void:
	lock_remaining = maxf(0.0, lock_remaining - delta)


func can_act() -> bool:
	return current != State.DEAD and lock_remaining <= 0.0
