class_name AttackHitbox
extends Area2D

signal connected(target: Node)

var team := "neutral"
var damage := 1
var posture_damage := 0.0
var knockback := Vector2.ZERO
var attack_id: StringName = &"attack"
var owner_actor: Node
var lifetime := 0.12
var hitstop_duration := 0.0
var hit_targets: Array[Node] = []


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	monitoring = true
	area_entered.connect(_on_area_entered)
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(queue_free)


func setup_shape(extents: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = extents * 2.0
	collision.shape = shape
	add_child(collision)
	queue_redraw()


func _draw() -> void:
	if not GameState.debug_overlay_enabled:
		return
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node and shape_node.shape is RectangleShape2D:
		var half_size := (shape_node.shape as RectangleShape2D).size * 0.5
		draw_rect(Rect2(-half_size, half_size * 2.0), Color(1.0, 0.25, 0.12, 0.18), true)


func _on_area_entered(area: Area2D) -> void:
	if not area is Hurtbox or area in hit_targets:
		return
	var hurtbox := area as Hurtbox
	var payload := {
		"team": team,
		"damage": damage,
		"posture_damage": posture_damage,
		"knockback": knockback,
		"attack_id": attack_id,
		"source": owner_actor,
	}
	if hurtbox.receive_hit(payload):
		hit_targets.append(area)
		GameFeelFX.spawn(get_tree().current_scene, hurtbox.global_position, GameFeelFX.Kind.HIT, signf(knockback.x))
		HitStop.apply([owner_actor, hurtbox.get_parent()], hitstop_duration)
		connected.emit(hurtbox.get_parent())
