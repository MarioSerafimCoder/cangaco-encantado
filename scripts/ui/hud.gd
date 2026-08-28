class_name GameHUD
extends CanvasLayer

const ROOM_PANEL_TEXTURE := preload("res://assets/ui/hud/room_banner.tres")
const WORLD_PANEL_TEXTURE := preload("res://assets/ui/hud/world_plaque.tres")
const HELP_PANEL_TEXTURE := preload("res://assets/ui/hud/help_banner.tres")
const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")

var player_status: PlayerStatusHUD
var room_panel: Panel
var room_label: Label
var world_panel: Panel
var world_label: Label
var debug_panel: Panel
var debug_label: Label
var boss_status: BossStatusHUD
var help_panel: Panel
var help_label: Label
var player: NiloPlayer
var room_fade := 0.0
var world_fade := 0.0
var help_fade := 6.0
var debug_visible := false
var opening_guide_active := false
var opening_guide_stage := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_hud")
	layer = 20
	_build_hud()
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_ammo_changed.connect(_on_ammo_changed)
	EventBus.player_heal_charges_changed.connect(_on_heals_changed)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.world_state_changed.connect(_on_world_changed)
	_on_health_changed(GameState.player_health, 5)
	_on_ammo_changed(&"pistol", 8, 8)
	_on_ammo_changed(&"rifle", 4, 4)
	_on_heals_changed(GameState.heal_charges, 2)
	_on_world_changed(&"vila_umbuzeiro", WorldState.get_region_state(&"vila_umbuzeiro"))
	EventBus.currency_changed.connect(_on_currency_changed)


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
		player_status.bind_player(player)
		if debug_visible:
			debug_label.text = "%s\nPOS %d,%d  VEL %d,%d" % [
				player.state_machine.state_name(),
				int(player.global_position.x), int(player.global_position.y),
				int(player.velocity.x), int(player.velocity.y),
			]
		_update_boss_bar()
	room_fade = maxf(0.0, room_fade - delta)
	world_fade = maxf(0.0, world_fade - delta)
	if not opening_guide_active:
		help_fade = maxf(0.0, help_fade - delta)
	elif not get_tree().paused:
		_update_opening_guide()
	_apply_temporary_visibility(room_panel, room_fade)
	_apply_temporary_visibility(world_panel, world_fade)
	_apply_temporary_visibility(help_panel, help_fade)


func _apply_temporary_visibility(control: Control, remaining: float) -> void:
	control.visible = remaining > 0.0
	control.modulate.a = clampf(minf(remaining * 2.0, 1.0), 0.0, 1.0)


func _build_hud() -> void:
	player_status = PlayerStatusHUD.new()
	add_child(player_status)

	world_panel = _make_panel(Rect2(542.0, 4.0, 94.0, 16.0), Color("241d1acc"), Color("b88042"), WORLD_PANEL_TEXTURE)
	world_label = _make_label(world_panel, Vector2(3.0, 3.0), Vector2(88.0, 10.0), 6, Color("f2d49a"))
	world_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	debug_panel = _make_panel(Rect2(524.0, 23.0, 112.0, 31.0), Color("101417df"), Color("5a8290"))
	debug_label = _make_label(debug_panel, Vector2(5.0, 3.0), Vector2(103.0, 25.0), 6, Color("bce8ee"))
	debug_panel.visible = false

	room_panel = _make_panel(Rect2(228.0, 56.0, 184.0, 21.0), Color("241d1ae6"), Color("d59a4a"), ROOM_PANEL_TEXTURE)
	var room_text_backing := ColorRect.new()
	room_text_backing.position = Vector2(18.0, 5.0)
	room_text_backing.size = Vector2(148.0, 10.0)
	room_text_backing.color = Color("17110de6")
	room_text_backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_panel.add_child(room_text_backing)
	room_label = _make_label(room_panel, Vector2(18.0, 5.0), Vector2(148.0, 10.0), 7, Color("fff0ca"))
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_panel.visible = false

	boss_status = BossStatusHUD.new()
	add_child(boss_status)

	help_panel = _make_panel(Rect2(192.0, 332.0, 256.0, 23.0), Color("171311c9"), Color("6e5337"), HELP_PANEL_TEXTURE)
	help_label = _make_label(help_panel, Vector2(5.0, 2.0), Vector2(246.0, 19.0), 6, Color("d8c39e"))
	help_label.text = "A/D MOVER | ESPAÇO PULAR/ACELERAR | E INTERAGIR\nJ FACÃO | K PISTOLA | L RIFLE | I ESPECIAL | M MENU"
	help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _update_boss_bar() -> void:
	var boss := get_tree().get_first_node_in_group("bosses") as EnemyBase
	if boss == null or not is_instance_valid(boss) or player.global_position.distance_to(boss.global_position) > 520.0:
		boss_status.hide_boss()
		return
	boss_status.show_boss(boss)


func _make_panel(rect: Rect2, background: Color, border: Color, panel_texture: Texture2D = null) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT if panel_texture != null else background
	style.border_color = Color.TRANSPARENT if panel_texture != null else border
	style.set_border_width_all(0 if panel_texture != null else 1)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.shadow_color = Color.TRANSPARENT if panel_texture != null else Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 0 if panel_texture != null else 2
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	if panel_texture != null:
		var frame := NinePatchRect.new()
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.texture = panel_texture
		frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		frame.patch_margin_left = 8
		frame.patch_margin_top = 6
		frame.patch_margin_right = 8
		frame.patch_margin_bottom = 6
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(frame)
	return panel


func _make_label(parent: Control, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label


func _on_health_changed(current: int, maximum: int) -> void:
	player_status.set_health(current, maximum)


func _on_ammo_changed(weapon_id: StringName, current: int, maximum: int) -> void:
	player_status.set_ammo(weapon_id, current, maximum)


func _on_heals_changed(current: int, maximum: int) -> void:
	player_status.set_heals(current, maximum)


func _on_room_entered(room_id: StringName, display_name: String) -> void:
	room_label.text = display_name
	room_fade = 2.0
	if room_id != &"casa_nilo":
		if opening_guide_active:
			GameState.set_dialogue_flag(&"opening_house_exited", true)
		opening_guide_active = false
		help_fade = 0.0


func _on_world_changed(region_id: StringName, state: StringName) -> void:
	if region_id != &"vila_umbuzeiro":
		return
	var liberated := state == WorldState.LIBERATED
	world_label.text = "VILA LIBERTADA" if liberated else "VILA OCUPADA"
	world_label.add_theme_color_override("font_color", Color("9ee39b") if liberated else Color("f2b36f"))
	world_fade = 3.2 if liberated else 2.2


func _on_currency_changed(current: int) -> void:
	world_label.text = "◆ %d" % current
	world_label.add_theme_color_override("font_color", Color("e4c181"))
	world_fade = 1.8


func begin_opening_guide() -> void:
	if GameState.current_room_id != &"casa_nilo" or bool(GameState.dialogue_flags.get("opening_house_exited", false)):
		return
	opening_guide_active = true
	opening_guide_stage = 0
	help_fade = 999.0
	help_label.text = "A/D MOVER   E INTERAGIR   ENCONTRE A SAÍDA"
	help_panel.visible = true


func _update_opening_guide() -> void:
	if opening_guide_stage == 0 and absf(Input.get_axis("move_left", "move_right")) > 0.2:
		opening_guide_stage = 1
		help_label.text = "SIGA PARA A DIREITA   E ABRIR A PORTA"
