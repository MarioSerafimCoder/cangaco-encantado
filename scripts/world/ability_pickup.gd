class_name AbilityPickup
extends Area2D

@export var ability_id: StringName = &"wall_jump"
@export var display_name := "PASSO DA PEDRA"
@export var description := "SALTE NOVAMENTE JUNTO A UMA PAREDE"

var _player_inside: NiloPlayer
var _collected := false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 13.0
	collision.shape = shape
	add_child(collision)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_collected = bool(GameState.abilities.get(String(ability_id), false))
	visible = not _collected
	set_process(not _collected)
	queue_redraw()


func _process(_delta: float) -> void:
	if _player_inside != null and Input.is_action_just_pressed("interact"):
		_collect()
	queue_redraw()


func _collect() -> void:
	if _collected:
		return
	_collected = true
	GameState.abilities[String(ability_id)] = true
	EventBus.ability_unlocked.emit(ability_id, display_name)
	visible = false
	set_process(false)


func _on_body_entered(body: Node) -> void:
	if body is NiloPlayer:
		_player_inside = body


func _on_body_exited(body: Node) -> void:
	if body == _player_inside:
		_player_inside = null


func _draw() -> void:
	if _collected:
		return
	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.006) * 0.12
	draw_circle(Vector2.ZERO, 10.0 * pulse, Color(0.2, 0.82, 0.72, 0.2))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -9), Vector2(7, 0), Vector2(0, 9), Vector2(-7, 0)]), Color("6de0c3"))
	draw_polyline(PackedVector2Array([Vector2(-7, 0), Vector2(0, -9), Vector2(7, 0), Vector2(0, 9), Vector2(-7, 0)]), Color("f7df8b"), 1.0)
	if _player_inside != null:
		draw_string(ThemeDB.fallback_font, Vector2(-38, -18), "[E] %s" % display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color.WHITE)

