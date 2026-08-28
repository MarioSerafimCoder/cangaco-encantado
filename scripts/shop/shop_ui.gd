class_name ShopUI
extends CanvasLayer

const PIXEL_FONT := preload("res://assets/ui/fonts/Tiny5-Regular.ttf")
const CATALOG_PATH := "res://resources/shop/area_01_shop.json"
const UI_ATLAS := preload("res://assets/area_01/ui/dialogo_loja_atlas.png")
const SHOP_ORNAMENT := Rect2(390, 305, 535, 145)

var is_open := false
var shop_id: StringName
var _catalog: Dictionary = {}
var _on_close: Callable
var _root: Control
var _items: VBoxContainer
var _currency_label: Label
var _description: Label
var _feedback: Label
var _controls_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 85
	_load_catalog()
	_build_ui()
	_root.visible = false


func open(id: StringName, on_close := Callable()) -> void:
	if is_open:
		return
	is_open = true
	shop_id = id
	_on_close = on_close
	_root.visible = true
	_refresh()
	EventBus.shop_opened.emit(shop_id)


func close() -> void:
	if not is_open:
		return
	is_open = false
	_root.visible = false
	EventBus.shop_closed.emit(shop_id)
	if _on_close.is_valid():
		_on_close.call()


func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("pause") or event.is_action_pressed("map")):
		get_viewport().set_input_as_handled()
		close()


func _process(_delta: float) -> void:
	if not is_open or _controls_label == null:
		return
	_controls_label.text = "D-PAD  SELECIONAR   A  COMPRAR   B  FECHAR" if InputBootstrap.last_input_was_gamepad else "W/S  SELECIONAR   ENTER  COMPRAR   ESC  FECHAR"


func _load_catalog() -> void:
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_catalog = parsed


func _refresh() -> void:
	for child in _items.get_children():
		_items.remove_child(child)
		child.queue_free()
	_currency_label.text = "MOEDA DO SERTÃO  ◆ %d" % GameState.currency
	var definition: Dictionary = _catalog.get(String(shop_id), {})
	for item in definition.get("items", []):
		var button := Button.new()
		var sold_out := bool(item.get("unique", false)) and bool(GameState.purchased_items.get(String(item.id), false))
		button.text = "%s     %s" % [String(item.name), "ESGOTADO" if sold_out else "◆ %d" % int(item.price)]
		button.disabled = sold_out
		button.custom_minimum_size = Vector2(286, 19)
		button.add_theme_font_override("font", PIXEL_FONT)
		button.add_theme_font_size_override("font_size", 9)
		_apply_item_button_theme(button)
		button.focus_entered.connect(_describe.bind(item))
		button.mouse_entered.connect(_describe.bind(item))
		button.pressed.connect(_buy.bind(item))
		_items.add_child(button)
	if _items.get_child_count() > 0:
		(_items.get_child(0) as Button).grab_focus.call_deferred()


func _describe(item: Dictionary) -> void:
	_description.text = String(item.get("description", ""))
	_feedback.text = ""


func _buy(item: Dictionary) -> void:
	var item_id := StringName(item.get("id", ""))
	var price := int(item.get("price", 0))
	if bool(item.get("unique", false)) and bool(GameState.purchased_items.get(String(item_id), false)):
		_feedback.text = "ITEM JÁ ADQUIRIDO."
		return
	if not GameState.spend_currency(price):
		_feedback.text = "MOEDAS INSUFICIENTES."
		return
	var category := StringName(item.get("category", "consumables"))
	GameState.add_inventory_item(category, item_id, int(item.get("amount", 1)))
	if bool(item.get("unique", false)):
		GameState.purchased_items[String(item_id)] = true
	_apply_immediate_effect(item_id)
	_feedback.text = "COMPRA REALIZADA."
	EventBus.request_autosave.emit(&"shop_purchase")
	_refresh.call_deferred()


func _apply_immediate_effect(item_id: StringName) -> void:
	var player := get_tree().get_first_node_in_group("player") as NiloPlayer
	if player == null:
		return
	match item_id:
		&"carga_cabaca":
			player.combat.heal_charges = mini(player.config.heal_charges, player.combat.heal_charges + 1)
			GameState.heal_charges = player.combat.heal_charges
			EventBus.player_heal_charges_changed.emit(player.combat.heal_charges, player.config.heal_charges)
		&"municao_pistola", &"municao_rifle":
			player.combat.refill_at_checkpoint()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.015, 0.01, 0.54)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(overlay)
	var panel := Panel.new()
	panel.position = Vector2(148, 70)
	panel.size = Vector2(344, 220)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.026, 0.02, 0.96)
	style.border_color = Color("816044")
	style.set_border_width_all(2)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	panel.add_theme_stylebox_override("panel", style)
	_root.add_child(panel)
	var ornament := Sprite2D.new()
	var ornament_texture := AtlasTexture.new()
	ornament_texture.atlas = UI_ATLAS
	ornament_texture.region = SHOP_ORNAMENT
	ornament.texture = ornament_texture
	ornament.position = Vector2(172, 20)
	ornament.scale = Vector2(160.0 / SHOP_ORNAMENT.size.x, 42.0 / SHOP_ORNAMENT.size.y)
	ornament.modulate.a = 0.42
	ornament.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.add_child(ornament)
	var title := _label(panel, Vector2(20, 12), Vector2(304, 20), 13, Color("dfbd82"))
	title.z_index = 2
	title.text = "MERCADOR DA PRAÇA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_currency_label = _label(panel, Vector2(24, 36), Vector2(296, 16), 9, Color("f3e8d1"))
	_items = VBoxContainer.new()
	_items.position = Vector2(29, 56)
	_items.size = Vector2(286, 106)
	_items.add_theme_constant_override("separation", 2)
	panel.add_child(_items)
	_description = _label(panel, Vector2(24, 166), Vector2(296, 24), 8, Color("d6c6ab"))
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback = _label(panel, Vector2(24, 191), Vector2(296, 12), 8, Color("dca76d"))
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_controls_label = _label(panel, Vector2(20, 205), Vector2(304, 10), 6, Color("a99272"))
	_controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _label(parent: Control, position_value: Vector2, size_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position_value
	label.size = size_value
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _apply_item_button_theme(button: Button) -> void:
	button.add_theme_color_override("font_color", Color("e9dcc5"))
	button.add_theme_color_override("font_hover_color", Color("fff0c7"))
	button.add_theme_color_override("font_focus_color", Color("fff0c7"))
	button.add_theme_color_override("font_pressed_color", Color("21150d"))
	button.add_theme_color_override("font_disabled_color", Color("766755"))
	button.add_theme_stylebox_override("normal", _button_style(Color("241a13dc"), Color("5f4933"), 1))
	button.add_theme_stylebox_override("hover", _button_style(Color("3d2b1de8"), Color("b9894d"), 1))
	button.add_theme_stylebox_override("focus", _button_style(Color("3d2b1df2"), Color("e2aa58"), 2))
	button.add_theme_stylebox_override("pressed", _button_style(Color("d3a15a"), Color("f0ce8e"), 1))
	button.add_theme_stylebox_override("disabled", _button_style(Color("17120fb8"), Color("493b2e"), 1))


func _button_style(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 7.0
	style.content_margin_right = 7.0
	return style
