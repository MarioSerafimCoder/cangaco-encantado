class_name BossStatusHUD
extends Control

const PANEL_TEXTURE := preload("res://assets/ui/hud/boss_bar_panel.tres")
const HUD_ATLAS := preload("res://assets/sprites/usados/interface/hud/hud_personalizado_atlas.png")
const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const PHASE_REGION := Rect2(828.0, 925.0, 74.0, 78.0)

var boss: EnemyBase
var _display_health := 1.0
var _display_posture := 1.0
var _previous_health := 1.0
var _damage_flash := 0.0
var _time := 0.0


func _ready() -> void:
	position = Vector2(200.0, 328.0)
	size = Vector2(240.0, 27.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_frame()
	visible = false


func _process(delta: float) -> void:
	_time += delta
	_damage_flash = maxf(0.0, _damage_flash - delta)
	if boss != null and is_instance_valid(boss):
		var target_health := float(boss.health.current_health) / maxf(float(boss.health.max_health), 1.0)
		var target_posture := boss.posture.current_posture / maxf(boss.posture.max_posture, 0.1)
		if target_health < _previous_health:
			_damage_flash = 0.32
		_previous_health = target_health
		_display_health = move_toward(_display_health, target_health, delta * 1.8)
		_display_posture = move_toward(_display_posture, target_posture, delta * 3.5)
	queue_redraw()


func show_boss(value: EnemyBase) -> void:
	if boss == value:
		visible = true
		return
	boss = value
	visible = boss != null
	if boss != null:
		_display_health = float(boss.health.current_health) / maxf(float(boss.health.max_health), 1.0)
		_display_posture = boss.posture.current_posture / maxf(boss.posture.max_posture, 0.1)
		_previous_health = _display_health


func hide_boss() -> void:
	boss = null
	visible = false


func _build_frame() -> void:
	var frame := NinePatchRect.new()
	frame.name = "AtlasFrame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.texture = PANEL_TEXTURE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.patch_margin_left = 24
	frame.patch_margin_top = 8
	frame.patch_margin_right = 24
	frame.patch_margin_bottom = 8
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.show_behind_parent = true
	add_child(frame)


func _draw() -> void:
	if boss == null or not is_instance_valid(boss):
		return
	var second_phase := boss.health.current_health <= boss.health.max_health / 2
	var title := "ZÉ TRANCA"
	_draw_centered_text(Vector2(0.0, 3.0), size.x, title, Color("ffe0ae"), 8)
	_draw_centered_text(Vector2(165.0, 4.0), 48.0, "FASE %d" % [2 if second_phase else 1], Color("e9b461"), 6)

	var health_track := Rect2(20.0, 13.0, 200.0, 6.0)
	draw_rect(health_track, Color("160f11"), true)
	var health_color := Color("dc4b3e") if not second_phase else Color("ed743f")
	if _damage_flash > 0.0:
		health_color = health_color.lerp(Color.WHITE, sin((_damage_flash / 0.32) * PI) * 0.7)
	draw_rect(Rect2(health_track.position + Vector2.ONE, Vector2((health_track.size.x - 2.0) * clampf(_display_health, 0.0, 1.0), 4.0)), health_color, true)
	draw_line(Vector2(health_track.position.x + health_track.size.x * 0.5, health_track.position.y), Vector2(health_track.position.x + health_track.size.x * 0.5, health_track.end.y), Color(0.12, 0.07, 0.07, 0.9), 1.0)

	var posture_track := Rect2(27.0, 21.0, 186.0, 3.0)
	draw_rect(posture_track, Color("181411"), true)
	var posture_color := Color("efb94e") if not boss.posture.broken else Color("fff0a0")
	draw_rect(Rect2(posture_track.position, Vector2(posture_track.size.x * clampf(_display_posture, 0.0, 1.0), posture_track.size.y)), posture_color, true)
	if boss.posture.broken:
		var pulse := 0.55 + sin(_time * 18.0) * 0.35
		draw_rect(posture_track.grow(1.0), Color(1.0, 0.9, 0.4, pulse), false, 1.0)

	for index in 2:
		var active := index == (1 if second_phase else 0)
		var rect := Rect2(223.0 + index * 7.0, 4.0, 6.0, 6.0)
		draw_texture_rect_region(HUD_ATLAS, rect, PHASE_REGION, Color.WHITE if active else Color(0.25, 0.23, 0.2, 0.75))


func _draw_centered_text(position_value: Vector2, width: float, value: String, color: Color, font_size: int) -> void:
	draw_string(PIXEL_FONT, position_value + Vector2(1.0, 1.0), value, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, Color(0.03, 0.02, 0.02, 0.95))
	draw_string(PIXEL_FONT, position_value, value, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)
