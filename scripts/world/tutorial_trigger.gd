class_name TutorialTrigger
extends Area2D

@export var tutorial_id: StringName
@export var action: StringName
@export var verb := ""
@export var one_shot := true

var _fired := false


func _ready() -> void:
	add_to_group("tutorial_triggers")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _fired or not body.is_in_group("player") or GameState.tutorial_learned(tutorial_id):
		return
	_fired = one_shot
	EventBus.tutorial_requested.emit(tutorial_id, action, verb)
