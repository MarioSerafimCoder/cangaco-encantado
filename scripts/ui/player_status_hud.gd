class_name PlayerStatusHUD
extends Control

const HUD_ATLAS := preload("res://assets/sprites/usados/interface/hud/hud_personalizado_atlas.png")
const PANEL_TEXTURE := preload("res://assets/ui/hud/world_plaque.tres")

const FULL_HEART_REGION := Rect2(620.0, 43.0, 88.0, 98.0)
const EMPTY_HEART_REGION := Rect2(1052.0, 43.0, 88.0, 98.0)
const PISTOL_REGION := Rect2(620.0, 165.0, 232.0, 202.0)
const RIFLE_ROUND_REGION := Rect2(895.0, 222.0, 82.0, 140.0)
const GOURD_FULL_REGION := Rect2(1100.0, 157.0, 221.0, 230.0)
const GOURD_EMPTY_REGION := Rect2(1308.0, 157.0, 188.0, 230.0)
const SPECIAL_REGION := Rect2(828.0, 925.0, 74.0, 78.0)
const PISTOL_ROUND_REGION := Rect2(39.0, 930.0, 53.0, 59.0)

var current_health := 5
var maximum_health := 5
var pistol_ammo := 8
var pistol_maximum := 8
var rifle_ammo := 4
var rifle_maximum := 4
var heal_charges := 2
var heal_maximum := 2
var player: NiloPlayer

var _health_pulse := 0.0
var _health_damage := false
var _pistol_pulse := 0.0
var _rifle_pulse := 0.0
var _heal_pulse := 0.0
var _time := 0.0
var _base_position := Vector2(4.0, 4.0)


func _ready() -> void:
	position = _base_position
	size = Vector2(136.0, 36.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_frame()
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	_health_pulse = maxf(0.0, _health_pulse - delta)
	_pistol_pulse = maxf(0.0, _pistol_pulse - delta)
	_rifle_pulse = maxf(0.0, _rifle_pulse - delta)
	_heal_pulse = maxf(0.0, _heal_pulse - delta)
	if _health_pulse > 0.0 and _health_damage:
		var strength := _health_pulse / 0.42
		position = _base_position + Vector2(roundf(sin(_time * 72.0) * strength), 0.0)
	else:
		position = _base_position
	queue_redraw()


func bind_player(value: NiloPlayer) -> void:
	player = value


func set_health(current: int, maximum: int) -> void:
	if maximum_health > 0 and current != current_health:
		_health_damage = current < current_health
		_health_pulse = 0.42
	current_health = current
	maximum_health = maximum
	queue_redraw()


func set_ammo(weapon_id: StringName, current: int, maximum: int) -> void:
	if weapon_id == &"pistol":
		if current != pistol_ammo:
			_pistol_pulse = 0.32
		pistol_ammo = current
		pistol_maximum = maximum
	elif weapon_id == &"rifle":
		if current != rifle_ammo:
			_rifle_pulse = 0.32
		rifle_ammo = current
		rifle_maximum = maximum
	queue_redraw()


func set_heals(current: int, maximum: int) -> void:
	if current != heal_charges:
		_heal_pulse = 0.5
	heal_charges = current
	heal_maximum = maximum
	queue_redraw()


func _build_frame() -> void:
	var frame := NinePatchRect.new()
	frame.name = "AtlasFrame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.texture = PANEL_TEXTURE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.patch_margin_left = 12
	frame.patch_margin_top = 8
	frame.patch_margin_right = 12
	frame.patch_margin_bottom = 8
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.show_behind_parent = true
	add_child(frame)


func _draw() -> void:
	_draw_health()
	_draw_special()
	_draw_pistol()
	_draw_rifle()
	_draw_gourd()
	_draw_heal_progress()


func _draw_health() -> void:
	var scale_bump := 1.0
	if _health_pulse > 0.0:
		scale_bump += sin((_health_pulse / 0.42) * PI) * 0.18
	for index in maximum_health:
		var destination := Rect2(9.0 + index * 11.0, 5.0, 9.0, 9.0)
		if index == clampi(current_health - 1, 0, maximum_health - 1) and _health_pulse > 0.0:
			var center := destination.get_center()
			destination.size *= scale_bump
			destination.position = center - destination.size * 0.5
		var region := FULL_HEART_REGION if index < current_health else EMPTY_HEART_REGION
		draw_texture_rect_region(HUD_ATLAS, destination, region)
	if _health_pulse > 0.0:
		var color := Color(1.0, 0.23, 0.16, _health_pulse * 1.5) if _health_damage else Color(0.52, 1.0, 0.55, _health_pulse * 1.4)
		draw_line(Vector2(8.0, 15.0), Vector2(64.0, 15.0), color, 1.0)


func _draw_special() -> void:
	var cooldown_ratio := 0.0
	if player != null and player.combat != null:
		cooldown_ratio = clampf(player.combat.special_cooldown_remaining / maxf(player.combat.special_data.fire_interval, 0.01), 0.0, 1.0)
	var ready := cooldown_ratio <= 0.0
	draw_line(Vector2(67.0, 4.0), Vector2(67.0, 15.0), Color("8d6538"), 1.0)
	var icon_rect := Rect2(71.0, 4.0, 11.0, 11.0)
	draw_texture_rect_region(HUD_ATLAS, icon_rect, SPECIAL_REGION, Color.WHITE if ready else Color(0.38, 0.38, 0.38, 0.82))
	var track := Rect2(84.0, 7.0, 24.0, 4.0)
	draw_rect(track, Color("1b1513"), true)
	var ready_ratio := 1.0 - cooldown_ratio
	draw_rect(Rect2(track.position + Vector2.ONE, Vector2((track.size.x - 2.0) * ready_ratio, 2.0)), Color("e35d3d") if not ready else Color("7fe39b"), true)
	if ready:
		var pulse := 0.35 + 0.25 * sin(_time * 5.0)
		draw_arc(icon_rect.get_center(), 7.0, 0.0, TAU, 16, Color(1.0, 0.68, 0.18, pulse), 1.0)


func _draw_pistol() -> void:
	var reloading := _is_reloading(&"pistol")
	var pulse := _resource_pulse(_pistol_pulse, Color("ffd36a"))
	draw_texture_rect_region(HUD_ATLAS, Rect2(8.0, 20.0, 11.0, 10.0), PISTOL_REGION, Color(0.62, 0.62, 0.62) if reloading else Color.WHITE)
	for index in pistol_maximum:
		var rect := Rect2(21.0 + index * 4.5, 21.0, 3.5, 8.0)
		var color := Color.WHITE if index < pistol_ammo else Color(0.25, 0.22, 0.18, 0.72)
		draw_texture_rect_region(HUD_ATLAS, rect, PISTOL_ROUND_REGION, color)
	if _pistol_pulse > 0.0:
		draw_rect(Rect2(20.0, 19.0, 38.0, 12.0), pulse, false, 1.0)
	if reloading:
		_draw_reload_indicator(Vector2(13.5, 25.0), _reload_progress(), 6.5)


func _draw_rifle() -> void:
	var reloading := _is_reloading(&"rifle")
	var pulse := _resource_pulse(_rifle_pulse, Color("ff9f4d"))
	draw_texture_rect_region(HUD_ATLAS, Rect2(64.0, 19.0, 8.0, 12.0), RIFLE_ROUND_REGION, Color(0.62, 0.62, 0.62) if reloading else Color.WHITE)
	for index in rifle_maximum:
		var rect := Rect2(75.0 + index * 8.0, 20.0, 6.0, 11.0)
		var color := Color.WHITE if index < rifle_ammo else Color(0.25, 0.22, 0.18, 0.72)
		draw_texture_rect_region(HUD_ATLAS, rect, RIFLE_ROUND_REGION, color)
	if _rifle_pulse > 0.0:
		draw_rect(Rect2(74.0, 19.0, 32.0, 13.0), pulse, false, 1.0)
	if reloading:
		_draw_reload_indicator(Vector2(68.0, 25.0), _reload_progress(), 6.5)


func _draw_gourd() -> void:
	var healing := player != null and player.combat != null and player.combat.healing
	var pulse_scale := 1.0 + sin((_heal_pulse / 0.5) * PI) * 0.12 if _heal_pulse > 0.0 else 1.0
	var gourd_rect := Rect2(111.0, 3.0, 18.0, 18.0)
	var center := gourd_rect.get_center()
	gourd_rect.size *= pulse_scale
	gourd_rect.position = center - gourd_rect.size * 0.5
	var gourd_region := GOURD_FULL_REGION if heal_charges > 0 else GOURD_EMPTY_REGION
	draw_texture_rect_region(HUD_ATLAS, gourd_rect, gourd_region, Color(0.72, 1.0, 0.76) if healing else Color.WHITE)
	for index in heal_maximum:
		var color := Color("64d99a") if index < heal_charges else Color("39312a")
		draw_circle(Vector2(116.0 + index * 8.0, 24.0), 2.2, Color("17120f"))
		draw_circle(Vector2(116.0 + index * 8.0, 24.0), 1.4, color)
	if _heal_pulse > 0.0:
		draw_arc(center, 11.0, 0.0, TAU, 20, Color(0.45, 1.0, 0.68, _heal_pulse * 1.5), 1.0)


func _draw_heal_progress() -> void:
	if player == null or player.combat == null or not player.combat.healing:
		return
	var duration := maxf(player.config.heal_duration, 0.01)
	var progress := clampf(1.0 - player.combat.heal_timer / duration, 0.0, 1.0)
	var track := Rect2(109.0, 30.0, 21.0, 3.0)
	draw_rect(track, Color("171411"), true)
	draw_rect(Rect2(track.position, Vector2(track.size.x * progress, track.size.y)), Color("62d98f"), true)
	draw_line(Vector2(track.position.x + track.size.x * progress, 29.0), Vector2(track.position.x + track.size.x * progress, 34.0), Color("d9ffd8"), 1.0)


func _draw_reload_indicator(center: Vector2, progress: float, radius: float) -> void:
	draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * progress, 16, Color("ffd15a"), 1.4)
	var spinner_angle := _time * 12.0
	draw_circle(center + Vector2.from_angle(spinner_angle) * radius, 1.2, Color("fff1a3"))


func _is_reloading(weapon_id: StringName) -> bool:
	return player != null and player.combat != null and player.combat.reload_timer > 0.0 and player.combat.reloading_weapon == weapon_id


func _reload_progress() -> float:
	if player == null or player.combat == null or player.combat.reload_timer <= 0.0:
		return 1.0
	var duration := player.combat.pistol_data.reload_time if player.combat.reloading_weapon == &"pistol" else player.combat.rifle_data.reload_time
	return clampf(1.0 - player.combat.reload_timer / maxf(duration, 0.01), 0.0, 1.0)


func _resource_pulse(remaining: float, color: Color) -> Color:
	var result := color
	result.a = clampf(remaining * 2.8, 0.0, 0.85)
	return result
