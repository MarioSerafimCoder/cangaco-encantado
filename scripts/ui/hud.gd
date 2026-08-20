class_name GameHUD
extends CanvasLayer

var health_label: Label
var revolver_label: Label
var shotgun_label: Label
var heal_label: Label
var room_label: Label
var state_label: Label
var world_label: Label
var help_label: Label
var player: NiloPlayer
var room_fade := 0.0


func _ready() -> void:
	health_label = _make_label(Vector2(6.0, 5.0), 10)
	revolver_label = _make_label(Vector2(6.0, 18.0), 8)
	shotgun_label = _make_label(Vector2(6.0, 29.0), 8)
	heal_label = _make_label(Vector2(6.0, 40.0), 8)
	world_label = _make_label(Vector2(226.0, 5.0), 8)
	state_label = _make_label(Vector2(226.0, 16.0), 7)
	room_label = _make_label(Vector2(58.0, 58.0), 12)
	room_label.size = Vector2(204.0, 20.0)
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help_label = _make_label(Vector2(4.0, 166.0), 7)
	help_label.text = "A/D mover  Espaço pular  J facão  K revólver  L espingarda  Q cura  E interagir"
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


func _process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as NiloPlayer
	if player != null:
		state_label.text = "%s  vx:%d vy:%d" % [player.state_machine.state_name(), int(player.velocity.x), int(player.velocity.y)]
	room_fade = maxf(0.0, room_fade - delta)
	room_label.modulate.a = minf(1.0, room_fade)


func _make_label(position_value: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = position_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("fff1d0"))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)
	return label


func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "VIDA  %s%s" % ["♥".repeat(current), "·".repeat(maximum - current)]


func _on_ammo_changed(weapon_id: StringName, current: int, maximum: int) -> void:
	if weapon_id == &"revolver":
		revolver_label.text = "REVÓLVER  %d/%d" % [current, maximum]
	elif weapon_id == &"shotgun":
		shotgun_label.text = "ESPINGARDA  %d/%d" % [current, maximum]


func _on_heals_changed(current: int, maximum: int) -> void:
	heal_label.text = "CABAÇA  %d/%d" % [current, maximum]


func _on_room_entered(_room_id: StringName, display_name: String) -> void:
	room_label.text = display_name
	room_fade = 2.4


func _on_world_changed(region_id: StringName, state: StringName) -> void:
	if region_id == &"vila_umbuzeiro":
		world_label.text = "VILA: %s" % state
