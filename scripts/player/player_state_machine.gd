class_name PlayerStateMachine
extends Node

enum State {
	IDLE,
	RUN,
	CROUCH,
	JUMP,
	FALL,
	SHOOT,
	SHOTGUN,
	MELEE,
	HEAL,
	HURT,
	DEAD,
}

const STATE_NAMES := [
	"IDLE", "RUN", "CROUCH", "JUMP", "FALL", "SHOOT", "SHOTGUN", "MELEE", "HEAL", "HURT", "DEAD"
]

signal state_changed(previous: State, current: State)

var current_state := State.IDLE
var lock_remaining := 0.0


func request(next_state: State, lock_duration := 0.0, force := false) -> bool:
	if current_state == State.DEAD and not force:
		return false
	if lock_remaining > 0.0 and not force and next_state not in [State.HURT, State.DEAD]:
		return false
	var previous := current_state
	current_state = next_state
	lock_remaining = maxf(0.0, lock_duration)
	if previous != current_state:
		state_changed.emit(previous, current_state)
	return true


func tick(delta: float) -> void:
	lock_remaining = maxf(0.0, lock_remaining - delta)


func update_locomotion(body: CharacterBody2D, crouching: bool) -> void:
	if lock_remaining > 0.0 or current_state == State.DEAD:
		return
	if not body.is_on_floor():
		request(State.JUMP if body.velocity.y < 0.0 else State.FALL)
	elif crouching:
		request(State.CROUCH)
	elif absf(body.velocity.x) > 1.0:
		request(State.RUN)
	else:
		request(State.IDLE)


func is_movement_locked() -> bool:
	return current_state == State.DEAD or (current_state in [State.HEAL, State.HURT] and lock_remaining > 0.0)


func state_name() -> String:
	return STATE_NAMES[current_state]
