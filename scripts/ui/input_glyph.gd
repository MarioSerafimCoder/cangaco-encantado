class_name InputGlyph
extends HBoxContainer

@export var action: StringName = &"interact"
@export var verb := "INTERAGIR"

@onready var icon: TextureRect = $Icon
@onready var label: Label = $Verb


func _ready() -> void:
	InputBootstrap.input_device_changed.connect(_on_input_device_changed)
	refresh()


func setup(action_id: StringName, verb_text: String) -> InputGlyph:
	action = action_id
	verb = verb_text
	if is_node_ready():
		refresh()
	return self


func refresh() -> void:
	icon.texture = InputGlyphResolver.texture_for_action(action)
	label.text = verb


func _on_input_device_changed(_gamepad: bool) -> void:
	refresh()
