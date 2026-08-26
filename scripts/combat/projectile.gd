class_name CombatProjectile
extends AttackHitbox

var velocity := Vector2.ZERO
var max_distance := 220.0
var travelled := 0.0
var projectile_color := Color(1.0, 0.78, 0.28)
var _world_impact_triggered := false


func _ready() -> void:
	super()
	# Hurtboxes usam a camada 3 (valor 4) e o cenário usa a camada 1.
	# O raycast abaixo evita atravessar paredes mesmo em projéteis rápidos.
	collision_mask = 1 | 4
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if not velocity.is_zero_approx():
		rotation = velocity.angle()
	var motion := velocity * delta
	var impact := _find_world_impact(global_position, global_position + motion)
	if not impact.is_empty():
		_spawn_world_impact(impact.get("position", global_position + motion))
		queue_free()
		return
	position += motion
	travelled += motion.length()
	if travelled >= max_distance:
		queue_free()


func _find_world_impact(from: Vector2, to: Vector2) -> Dictionary:
	if from.is_equal_approx(to):
		return {}
	var query := PhysicsRayQueryParameters2D.create(from, to, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_2d().direct_space_state.intersect_ray(query)


func _on_body_entered(body: Node) -> void:
	var collision_body := body as CollisionObject2D
	if _world_impact_triggered or body == owner_actor or collision_body == null or collision_body.collision_layer & 1 == 0:
		return
	_spawn_world_impact(global_position)
	queue_free()


func _spawn_world_impact(point: Vector2) -> void:
	if _world_impact_triggered:
		return
	_world_impact_triggered = true
	var impact_facing := -signf(velocity.x) if not is_zero_approx(velocity.x) else 1.0
	GameFeelFX.spawn(get_tree().current_scene, point, GameFeelFX.Kind.PROJECTILE_IMPACT, impact_facing, 1.0)


func _draw() -> void:
	super()
	draw_circle(Vector2.ZERO, 2.2, Color(projectile_color, 0.22))
	draw_rect(Rect2(-7.0, -1.0, 10.0, 2.0), Color(projectile_color, 0.42), true)
	draw_rect(Rect2(-2.0, -1.0, 5.0, 2.0), projectile_color, true)
