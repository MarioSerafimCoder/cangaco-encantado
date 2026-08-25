class_name GameHUD
extends CanvasLayer

var health_label: Label
var revolver_label: Label
var shotgun_label: Label
var heal_label: Label
var room_panel: Panel
var room_label: Label
var world_panel: Panel
var world_label: Label
var debug_panel: Panel
var debug_label: Label
var boss_panel: Panel
var boss_label: Label
var boss_fill: ColorRect
var help_panel: Panel
var player: NiloPlayer
var room_fade := 0.0
var debug_visible := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build_hud()
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_ammo_changed.connect(_on_ammo_changed)
	EventBus.player_heal_charges_changed.connect(_on_heals_changed)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.world_state_changed.connect(_on_world_changed)
	_on_health_changed(GameState.player_health, 5)
	_on_ammo_changed(&"revolver", 6, 6)
	_on_ammo_changed(&"shotgun", 2, 2)
	_on_heals_changed(GameState.heal_charges, 2)
	_on_world_changed(&"vila_umbuzeiro", WorldState.get_region_state(&"vila_umbuzeiro"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		debug_visible = not debug_visible
		GameState.debug_overlay_enabled = debug_visible
		debug_panel.visible = debug_visible
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as NiloPlayer
	if player != null:
		if debug_visible:
			debug_label.text = "%s\nPOS %d,%d  VEL %d,%d" % [
				player.state_machine.state_name(),
				int(player.global_position.x), int(player.global_position.y),
				int(player.velocity.x), int(player.velocity.y),
			]
		_update_boss_bar()
	room_fade = maxf(0.0, room_fade - delta)
	room_panel.modulate.a = clampf(minf(room_fade, 1.0), 0.0, 1.0)


func _build_hud() -> void:
	var status_panel := _make_panel(Rect2(5.0, 5.0, 116.0, 48.0), Color("241d1acc"), Color("b88042"))
	health_label = _make_label(status_panel, Vector2(7.0, 4.0), Vector2(104.0, 11.0), 9, Color("ffe2a8"))
	revolver_label = _make_label(status_panel, Vector2(7.0, 17.0), Vector2(104.0, 9.0), 7, Color("e9d5aa"))
	shotgun_label = _make_label(status_panel, Vector2(7.0, 27.0), Vector2(104.0, 9.0), 7, Color("e9d5aa"))
	heal_label = _make_label(status_panel, Vector2(7.0, 37.0), Vector2(104.0, 9.0), 7, Color("8fe3b4"))

	world_panel = _make_panel(Rect2(219.0, 5.0, 96.0, 20.0), Color("241d1acc"), Color("b88042"))
	world_label = _make_label(world_panel, Vector2(3.0, 4.0), Vector2(90.0, 11.0), 7, Color("f2d49a"))
	world_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	debug_panel = _make_panel(Rect2(203.0, 29.0, 112.0, 31.0), Color("101417df"), Color("5a8290"))
	debug_label = _make_label(debug_panel, Vector2(5.0, 3.0), Vector2(103.0, 25.0), 6, Color("bce8ee"))
	debug_panel.visible = false

	room_panel = _make_panel(Rect2(67.0, 52.0, 186.0, 22.0), Color("241d1ae6"), Color("d59a4a"))
	room_label = _make_label(room_panel, Vector2(4.0, 5.0), Vector2(178.0, 13.0), 9, Color("fff0ca"))
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_panel.modulate.a = 0.0

	boss_panel = _make_panel(Rect2(124.0, 29.0, 191.0, 20.0), Color("1b1115e8"), Color("9f3c38"))
	boss_label = _make_label(boss_panel, Vector2(5.0, 2.0), Vector2(181.0, 8.0), 7, Color("f4d8bd"))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var boss_track := ColorRect.new()
	boss_track.position = Vector2(8.0, 12.0)
	boss_track.size = Vector2(175.0, 4.0)
	boss_track.color = Color("3a2528")
	boss_panel.add_child(boss_track)
	boss_fill = ColorRect.new()
	boss_fill.size = boss_track.size
	boss_fill.color = Color("c94b3f")
	boss_track.add_child(boss_fill)
	boss_panel.visible = false

	help_panel = _make_panel(Rect2(4.0, 162.0, 312.0, 14.0), Color("171311c9"), Color("6e5337"))
	var help_label := _make_label(help_panel, Vector2(4.0, 2.0), Vector2(304.0, 9.0), 6, Color("d8c39e"))
	help_label.text = "A/D MOVER   ESPAÇO PULAR   J FACÃO   K TIRO   L ESPINGARDA   F3 DEBUG"
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _update_boss_bar() -> void:
	var boss := get_tree().get_first_node_in_group("bosses") as EnemyBase
	if boss == null or not is_instance_valid(boss) or player.global_position.distance_to(boss.global_position) > 300.0:
		boss_panel.visible = false
		return
	boss_panel.visible = true
	boss_label.text = "ZÉ TRANCA"
	var ratio := float(boss.health.current_health) / maxf(float(boss.health.max_health), 1.0)
	boss_fill.size.x = 175.0 * clampf(ratio, 0.0, 1.0)


func _make_panel(rect: Rect2, background: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 2
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	return panel


func _make_label(parent: Control, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label


func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "VIDA  %s%s" % ["◆".repeat(current), "◇".repeat(maximum - current)]


func _on_ammo_changed(weapon_id: StringName, current: int, maximum: int) -> void:
	if weapon_id == &"revolver":
		revolver_label.text = "REVÓLVER   %s%s  %d/%d" % ["●".repeat(current), "·".repeat(maximum - current), current, maximum]
	elif weapon_id == &"shotgun":
		shotgun_label.text = "ESPINGARDA %s%s  %d/%d" % ["▮".repeat(current), "·".repeat(maximum - current), current, maximum]


func _on_heals_changed(current: int, maximum: int) -> void:
	heal_label.text = "CABAÇA     %s%s  %d/%d" % ["✦".repeat(current), "·".repeat(maximum - current), current, maximum]


func _on_room_entered(_room_id: StringName, display_name: String) -> void:
	room_label.text = display_name
	room_fade = 2.4


func _on_world_changed(region_id: StringName, state: StringName) -> void:
	if region_id != &"vila_umbuzeiro":
		return
	var liberated := state == WorldState.LIBERATED
	world_label.text = "VILA LIBERTADA" if liberated else "VILA OCUPADA"
	world_label.add_theme_color_override("font_color", Color("9ee39b") if liberated else Color("f2b36f"))
