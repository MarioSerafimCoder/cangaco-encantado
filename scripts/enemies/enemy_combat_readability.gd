class_name EnemyCombatReadability
extends Node2D

var enemy: EnemyBase


func _ready() -> void:
	enemy = get_parent() as EnemyBase
	z_index = 20
	queue_redraw()


func _process(_delta: float) -> void:
	if enemy == null or not is_instance_valid(enemy):
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if enemy == null or enemy.data == null:
		return
	_draw_attack_telegraph()
	_draw_combat_bars()


func _draw_attack_telegraph() -> void:
	if enemy.attack_phase != EnemyBase.AttackPhase.ANTICIPATION:
		return
	var duration := maxf(enemy.data.attack_windup, 0.05)
	var progress := clampf(1.0 - enemy.attack_phase_remaining / duration, 0.0, 1.0)
	var pulse := 0.65 + 0.35 * absf(sin(progress * PI * 4.0))
	var marker_y := -39.0 if enemy.data.behavior == EnemyData.Behavior.BOSS else -26.0
	var marker_size := lerpf(2.5, 4.0, progress)
	var warning_color := Color(1.0, lerpf(0.72, 0.24, progress), 0.08, pulse)
	var marker := PackedVector2Array([
		Vector2(0.0, marker_y - marker_size),
		Vector2(marker_size, marker_y),
		Vector2(0.0, marker_y + marker_size),
		Vector2(-marker_size, marker_y),
	])
	draw_colored_polygon(marker, warning_color)
	draw_arc(Vector2(0.0, marker_y), marker_size + 2.0, -PI * 0.5, -PI * 0.5 + TAU * progress, 12, Color(1.0, 0.78, 0.22, pulse), 1.0)
	if enemy.data.behavior in [EnemyData.Behavior.RANGED, EnemyData.Behavior.BOSS] and progress > 0.35:
		var aim_alpha := smoothstep(0.45, 1.0, progress) * 0.75
		var aim_length := minf(72.0, enemy.data.attack_range * 0.58)
		var aim_start := Vector2(enemy.attack_facing * 8.0, -6.0)
		var aim_end := Vector2(enemy.attack_facing * aim_length, -6.0)
		draw_line(aim_start, aim_end, Color(1.0, 0.28, 0.12, aim_alpha), 1.0)
		draw_line(aim_end + Vector2(0.0, -3.0), aim_end + Vector2(0.0, 3.0), Color(1.0, 0.68, 0.25, aim_alpha), 1.0)
	elif progress > 0.28:
		var danger_alpha := smoothstep(0.28, 1.0, progress) * 0.62
		var attack_center := Vector2(enemy.attack_facing * 14.0, 8.0)
		draw_arc(attack_center, 11.0, PI if enemy.attack_facing > 0.0 else 0.0, TAU if enemy.attack_facing > 0.0 else PI, 10, Color(1.0, 0.38, 0.12, danger_alpha), 1.0)
		draw_line(Vector2(enemy.attack_facing * 5.0, 9.0), Vector2(enemy.attack_facing * 25.0, 9.0), Color(1.0, 0.52, 0.16, danger_alpha), 1.0)


func _draw_combat_bars() -> void:
	if enemy.data.behavior == EnemyData.Behavior.BOSS or (enemy.combat_bar_visible_remaining <= 0.0 and not enemy.posture.broken):
		return
	var bar_width := 20.0
	var top := -20.0
	var health_ratio := float(enemy.health.current_health) / maxf(float(enemy.health.max_health), 1.0)
	var posture_ratio := enemy.posture.current_posture / maxf(enemy.posture.max_posture, 0.1)
	draw_rect(Rect2(-bar_width * 0.5 - 1.0, top - 1.0, bar_width + 2.0, 5.0), Color(0.05, 0.04, 0.035, 0.86), true)
	draw_rect(Rect2(-bar_width * 0.5, top, bar_width * health_ratio, 2.0), Color("d6533f"), true)
	draw_rect(Rect2(-bar_width * 0.5, top + 2.0, bar_width * posture_ratio, 1.0), Color("efbd4e") if not enemy.posture.broken else Color("fff1a1"), true)
