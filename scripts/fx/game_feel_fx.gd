class_name GameFeelFX
extends Node2D

enum Kind { RUN_DUST, LAND_DUST, MUZZLE, SLASH_HORIZONTAL, SLASH_UP, SLASH_DOWN, HIT, HEAL_CHANNEL, HEAL_COMPLETE, PROJECTILE_IMPACT }

var kind := Kind.HIT
var facing := 1.0
var duration := 0.18
var elapsed := 0.0
var strength := 1.0


static func spawn(parent: Node, world_position: Vector2, effect_kind: Kind, effect_facing := 1.0, effect_strength := 1.0) -> GameFeelFX:
	var effect := GameFeelFX.new()
	effect.kind = effect_kind
	effect.facing = effect_facing
	effect.strength = effect_strength
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
		Kind.SLASH_HORIZONTAL:
			_draw_slash_horizontal(progress, fade)
		Kind.SLASH_UP:
			_draw_slash_vertical(progress, fade, true)
		Kind.SLASH_DOWN:
			_draw_slash_vertical(progress, fade, false)
		Kind.HIT:
			_draw_hit(progress, fade)
		Kind.HEAL_CHANNEL:
			_draw_heal_channel(progress, fade)
		Kind.HEAL_COMPLETE:
			_draw_heal_complete(progress, fade)
		Kind.PROJECTILE_IMPACT:
			_draw_projectile_impact(progress, fade)


func _draw_dust(progress: float, fade: float, wide: bool) -> void:
	var spread := (14.0 if wide else 8.0) * progress * strength
	var dust_color := Color(0.73, 0.55, 0.34, fade * 0.72)
	for index in 4:
		var side := -1.0 if index % 2 == 0 else 1.0
		var distance := spread * (0.45 + index * 0.17)
		var rise := progress * (3.0 + index)
		var radius := maxf(0.6, (2.2 if wide else 1.5) * fade * strength)
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


func _draw_slash_horizontal(progress: float, fade: float) -> void:
	var start_angle := -1.3 if facing > 0.0 else PI - 1.3
	var end_angle := 0.9 if facing > 0.0 else PI + 0.9
	draw_arc(Vector2(facing * 4.0, -3.0), (17.0 + progress * 3.0) * strength, start_angle, end_angle, 12, Color(1.0, 0.86, 0.43, fade), 3.0)
	draw_arc(Vector2(facing * 4.0, -3.0), 13.0 + progress * 2.0, start_angle, end_angle, 10, Color(0.88, 0.24, 0.13, fade * 0.8), 1.0)


func _draw_slash_vertical(progress: float, fade: float, upward: bool) -> void:
	var start_angle := PI + 0.15 if upward else 0.15
	var end_angle := TAU - 0.15 if upward else PI - 0.15
	var center := Vector2(facing * 2.0, 2.0 if upward else -2.0)
	var radius := (16.0 + progress * 3.0) * strength
	draw_arc(center, radius, start_angle, end_angle, 12, Color(1.0, 0.86, 0.43, fade), 3.0)
	draw_arc(center, radius - 4.0, start_angle, end_angle, 10, Color(0.88, 0.24, 0.13, fade * 0.78), 1.0)


func _draw_hit(progress: float, fade: float) -> void:
	var radius := 4.0 + progress * 10.0
	for index in 8:
		var angle := TAU * float(index) / 8.0
		var inner := Vector2.from_angle(angle) * radius * 0.35
		var outer := Vector2.from_angle(angle) * radius
		draw_line(inner, outer, Color(1.0, 0.9 if index % 2 == 0 else 0.35, 0.2, fade), 2.0)


func _draw_heal_channel(progress: float, fade: float) -> void:
	for index in 5:
		var angle := TAU * float(index) / 5.0 + progress * 2.0
		var orbit := 7.0 + progress * 7.0
		var point := Vector2(cos(angle) * orbit, sin(angle) * orbit - progress * 10.0)
		draw_circle(point, 1.5, Color(0.45, 0.95, 0.72, fade))
	draw_arc(Vector2.ZERO, 9.0 + progress * 4.0, 0.0, TAU, 16, Color(0.55, 0.95, 0.78, fade * 0.65), 1.0)


func _draw_heal_complete(progress: float, fade: float) -> void:
	var radius := 5.0 + progress * 16.0
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, Color(0.72, 1.0, 0.82, fade), 2.0)
	for index in 4:
		var direction := Vector2.from_angle(TAU * float(index) / 4.0)
		draw_line(direction * radius * 0.35, direction * radius, Color(0.92, 1.0, 0.7, fade), 2.0)


func _draw_projectile_impact(progress: float, fade: float) -> void:
	var travel := 3.0 + progress * 5.0
	for index in 4:
		var vertical := -2.5 + float(index) * 1.7
		var endpoint := Vector2(facing * travel * (0.7 + index * 0.12), vertical * (1.0 + progress))
		draw_line(Vector2.ZERO, endpoint, Color(1.0, 0.72 if index % 2 == 0 else 0.38, 0.16, fade), 1.0)
	draw_circle(Vector2.ZERO, maxf(0.5, 2.2 * fade), Color(1.0, 0.9, 0.48, fade))


func _duration_for_kind(effect_kind: Kind) -> float:
	match effect_kind:
		Kind.RUN_DUST:
			return 0.24
		Kind.LAND_DUST:
			return 0.32
		Kind.MUZZLE:
			return 0.09
		Kind.SLASH_HORIZONTAL, Kind.SLASH_UP, Kind.SLASH_DOWN:
			return 0.16
		Kind.HIT:
			return 0.15
		Kind.HEAL_CHANNEL:
			return 1.05
		Kind.HEAL_COMPLETE:
			return 0.55
		Kind.PROJECTILE_IMPACT:
			return 0.14
	return 0.18
