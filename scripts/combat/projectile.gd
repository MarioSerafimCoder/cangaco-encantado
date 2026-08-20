class_name CombatProjectile
extends AttackHitbox

var velocity := Vector2.ZERO
var max_distance := 220.0
var travelled := 0.0
var projectile_color := Color(1.0, 0.78, 0.28)


func _physics_process(delta: float) -> void:
	var motion := velocity * delta
	position += motion
	travelled += motion.length()
	if travelled >= max_distance:
		queue_free()


func _draw() -> void:
	draw_rect(Rect2(-3.0, -1.0, 6.0, 2.0), projectile_color, true)

