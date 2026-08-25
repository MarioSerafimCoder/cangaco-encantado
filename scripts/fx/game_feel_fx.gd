class_name GameFeelFX
extends Node2D

enum Kind { RUN_DUST, LAND_DUST, MUZZLE, SLASH, HIT, HEAL }

var kind := Kind.HIT
var facing := 1.0
var duration := 0.18
var elapsed := 0.0


static func spawn(parent: Node, world_position: Vector2, effect_kind: Kind, effect_facing := 1.0) -> GameFeelFX:
	var effect := GameFeelFX.new()
	effect.kind = effect_kind
	effect.facing = effect_facing
	effect.duration = effect._duration_for_kind(effect_kind)
	parent.add_child(effect)
	effect.global_position = world_position
	return effect


func _ready() -> void:
	z_index = 40
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / maxf(duration, 0.01), 0.0, 1.0)
	var fade := 1.0 - progress
	match kind:
		Kind.RUN_DUST:
			_draw_dust(progress, fade, false)
		Kind.LAND_DUST:
			_draw_dust(progress, fade, true)
		Kind.MUZZLE:
			_draw_muzzle(progress, fade)
		Kind.SLASH:
			_draw_slash(progress, fade)
		Kind.HIT:
			_draw_hit(progress, fade)
		Kind.HEAL:
			_draw_heal(progress, fade)


func _draw_dust(progress: float, fade: float, wide: bool) -> void:
	var spread := (14.0 if wide else 8.0) * progress
	var dust_color := Color(0.73, 0.55, 0.34, fade * 0.72)
	for index in 4:
		var side := -1.0 if index % 2 == 0 else 1.0
		var distance := spread * (0.45 + index * 0.17)
		var rise := progress * (3.0 + index)
		var radius := maxf(0.6, (2.2 if wide else 1.5) * fade)
		draw_circle(Vector2(side * distance, -rise), radius, dust_color)


func _draw_muzzle(progress: float, fade: float) -> void:
	var length := 13.0 * (1.0 - progress * 0.35)
	var points := PackedVector2Array([
		Vector2.ZERO,
		Vector2(facing * length, -3.0 * fade),
		Vector2(facing * length * 0.72, 0.0),
		Vector2(facing * length, 3.0 * fade),
	])
	draw_colored_polygon(points, Color(1.0, 0.73, 0.17, fade))
	draw_circle(Vector2(facing * 3.0, 0.0), 2.5 * fade, Color(1.0, 0.95, 0.62, fade))


func _draw_slash(progress: float, fade: float) -> void:
	var start_angle := -1.3 if facing > 0.0 else PI - 1.3
	var end_angle := 0.9 if facing > 0.0 else PI + 0.9
	draw_arc(Vector2(facing * 4.0, -3.0), 17.0 + progress * 3.0, start_angle, end_angle, 12, Color(1.0, 0.86, 0.43, fade), 3.0)
	draw_arc(Vector2(facing * 4.0, -3.0), 13.0 + progress * 2.0, start_angle, end_angle, 10, Color(0.88, 0.24, 0.13, fade * 0.8), 1.0)


func _draw_hit(progress: float, fade: float) -> void:
	var radius := 4.0 + progress * 10.0
	for index in 8:
		var angle := TAU * float(index) / 8.0
		var inner := Vector2.from_angle(angle) * radius * 0.35
		var outer := Vector2.from_angle(angle) * radius
		draw_line(inner, outer, Color(1.0, 0.9 if index % 2 == 0 else 0.35, 0.2, fade), 2.0)


func _draw_heal(progress: float, fade: float) -> void:
	for index in 5:
		var angle := TAU * float(index) / 5.0 + progress * 2.0
		var orbit := 7.0 + progress * 7.0
		var point := Vector2(cos(angle) * orbit, sin(angle) * orbit - progress * 10.0)
		draw_circle(point, 1.5, Color(0.45, 0.95, 0.72, fade))
	draw_arc(Vector2.ZERO, 9.0 + progress * 4.0, 0.0, TAU, 16, Color(0.55, 0.95, 0.78, fade * 0.65), 1.0)


func _duration_for_kind(effect_kind: Kind) -> float:
	match effect_kind:
		Kind.RUN_DUST:
			return 0.24
		Kind.LAND_DUST:
			return 0.32
		Kind.MUZZLE:
			return 0.09
		Kind.SLASH:
			return 0.16
		Kind.HIT:
			return 0.15
		Kind.HEAL:
			return 0.55
	return 0.18
