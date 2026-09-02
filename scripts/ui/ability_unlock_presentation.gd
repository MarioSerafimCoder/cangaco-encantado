class_name AbilityUnlockPresentation
extends Control

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

var _panel: Panel
var _title: Label
var _name: Label
var _hint: Label
var _active_tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build()
	EventBus.ability_unlocked.connect(_on_ability_unlocked)


func _build() -> void:
	_panel = Panel.new()
	_panel.position = Vector2(152, 116)
	_panel.size = Vector2(336, 104)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17110df2")
	style.border_color = Color("d69a49")
	style.set_border_width_all(2)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.62)
	style.shadow_size = 5
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_title = _label(Vector2(16, 12), Vector2(304, 18), 9, Color("efb957"))
	_title.text = "NOVO PASSO APRENDIDO"
	_name = _label(Vector2(16, 36), Vector2(304, 28), 15, Color("fff0ca"))
	_hint = _label(Vector2(16, 72), Vector2(304, 17), 8, Color("d8c39e"))


func _label(at: Vector2, extent: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.size = extent
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	_panel.add_child(label)
	return label


func _on_ability_unlocked(ability_id: StringName, display_name: String) -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_name.text = display_name
	_hint.text = _ability_hint(ability_id)
	visible = true
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.94, 0.94)
	_panel.pivot_offset = _panel.size * 0.5
	_active_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_active_tween.tween_property(_panel, "modulate:a", 1.0, 0.12)
	_active_tween.parallel().tween_property(_panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.tween_interval(1.35)
	_active_tween.tween_property(_panel, "modulate:a", 0.0, 0.22)
	_active_tween.tween_callback(func(): visible = false)


func _ability_hint(ability_id: StringName) -> String:
	match ability_id:
		&"wall_jump":
			return "SALTE JUNTO À PAREDE PARA TOMAR IMPULSO"
		&"dash":
			return "USE C PARA ATRAVESSAR SELOS E VÃOS"
		_:
			return "UMA NOVA ROTA SE ABRIU"
