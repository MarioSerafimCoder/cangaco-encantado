extends Node

const COMMAND_ATLAS := preload("res://assets/sprites/usados/interface/menu_diario/atlas_comandos.png")
const COLUMN_WIDTH := 156.75
const ROW_TOPS := [238.0, 420.0, 610.0, 800.0]
const GLYPH_SIZE := Vector2(132.0, 170.0)

const KEYBOARD_GLYPHS := {
	&"move_up": 0, &"move_left": 1, &"move_down": 2, &"move_right": 3,
	&"jump": 4, &"crouch": 5, &"aim": 6, &"ui_accept": 7,
	&"melee": 8, &"shoot_pistol": 9, &"shoot_rifle": 10, &"special_attack": 11,
	&"heal": 12, &"interact": 13, &"dash": 14, &"map": 15, &"pause": 16,
}
const GAMEPAD_GLYPHS := {
	&"move_up": 18, &"move_left": 18, &"move_down": 18, &"move_right": 18,
	&"jump": 19, &"heal": 20, &"melee": 21, &"interact": 22,
	&"special_attack": 23, &"shoot_rifle": 24, &"aim": 25, &"shoot_pistol": 26,
	&"crouch": 27, &"dash": 28, &"map": 29, &"pause": 30, &"ui_accept": 19,
}
const KEYBOARD_LABELS := {
	&"move_up": "W", &"move_left": "A", &"move_down": "S", &"move_right": "D",
	&"jump": "ESPAÇO", &"crouch": "CTRL", &"aim": "SHIFT", &"ui_accept": "ENTER",
	&"melee": "J", &"shoot_pistol": "K", &"shoot_rifle": "L", &"special_attack": "I",
	&"heal": "Q", &"interact": "E", &"dash": "C", &"map": "M", &"pause": "ESC",
}
const GAMEPAD_LABELS := {
	&"move_up": "LS", &"move_left": "LS", &"move_down": "LS", &"move_right": "LS",
	&"jump": "A", &"heal": "B", &"melee": "X", &"interact": "Y",
	&"special_attack": "LB", &"shoot_rifle": "RB", &"aim": "LT", &"shoot_pistol": "RT",
	&"crouch": "L3", &"dash": "R3", &"map": "BACK", &"pause": "START", &"ui_accept": "A",
}


func label_for_action(action: StringName) -> String:
	var labels := GAMEPAD_LABELS if InputBootstrap.last_input_was_gamepad else KEYBOARD_LABELS
	return String(labels.get(action, String(action).to_upper()))


func prompt(action: StringName, verb: String) -> String:
	return "[%s] %s" % [label_for_action(action), verb]


func texture_for_action(action: StringName) -> AtlasTexture:
	var glyphs := GAMEPAD_GLYPHS if InputBootstrap.last_input_was_gamepad else KEYBOARD_GLYPHS
	var index := int(glyphs.get(action, 7))
	var texture := AtlasTexture.new()
	texture.atlas = COMMAND_ATLAS
	var row := floori(float(index) / 8.0)
	texture.region = Rect2(Vector2(float(index % 8) * COLUMN_WIDTH + 12.0, ROW_TOPS[row]), GLYPH_SIZE)
	return texture
