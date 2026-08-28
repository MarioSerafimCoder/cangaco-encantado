class_name AbilityGate
extends StaticBody2D

const UI_ATLAS := preload("res://assets/area_01/ui/dialogo_loja_atlas.png")
const SEAL_REGION := Rect2(1245, 112, 120, 150)

@export var required_ability: StringName = &"dash"
@export var gate_size := Vector2(10.0, 54.0)
@export var label := "SELO DO VENTO"

var _collision: CollisionShape2D
var _opened := false
var _visual: Sprite2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	_collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	_collision.shape = shape
	add_child(_collision)
	_visual = Sprite2D.new()
	_visual.texture = UI_ATLAS
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.region_enabled = true
	_visual.region_filter_clip_enabled = true
	_visual.region_rect = SEAL_REGION
	_visual.scale = Vector2.ONE * 0.18
	_visual.z_index = 7
	add_child(_visual)
	EventBus.ability_unlocked.connect(_on_ability_unlocked)
	_refresh()


func _on_ability_unlocked(ability_id: StringName, _display_name: String) -> void:
	if ability_id == required_ability:
		_refresh()


func _refresh() -> void:
	_opened = bool(GameState.abilities.get(String(required_ability), false))
	_collision.set_deferred("disabled", _opened)
	_visual.visible = not _opened
