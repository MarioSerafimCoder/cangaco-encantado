class_name CombatProjectile
extends AttackHitbox

var velocity := Vector2.ZERO
var max_distance := 220.0
var travelled := 0.0
var projectile_color := Color(1.0, 0.78, 0.28)


func _physics_process(delta: float) -> void:
	if not velocity.is_zero_approx():
		rotation = velocity.angle()
	var motion := velocity * delta
	position += motion
	travelled += motion.length()
	if travelled >= max_distance:
		queue_free()


func _draw() -> void:
	super()
	draw_circle(Vector2.ZERO, 2.2, Color(projectile_color, 0.22))
	draw_rect(Rect2(-7.0, -1.0, 10.0, 2.0), Color(projectile_color, 0.42), true)
	draw_rect(Rect2(-2.0, -1.0, 5.0, 2.0), projectile_color, true)
