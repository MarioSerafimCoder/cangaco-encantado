extends Node

signal input_device_changed(gamepad: bool)

const KEYBOARD_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE],
	"crouch": [KEY_CTRL],
	"melee": [KEY_J],
	"shoot_pistol": [KEY_K],
	"shoot_rifle": [KEY_L],
	"special_attack": [KEY_I],
	"aim": [KEY_SHIFT],
	"heal": [KEY_Q],
	"interact": [KEY_E],
	"dash": [KEY_C],
	"map": [KEY_M],
	"pause": [KEY_ESCAPE],
	"toggle_debug": [KEY_F3],
	"debug_liberate": [KEY_F12],
}

const JOYPAD_BUTTON_BINDINGS := {
	"jump": JOY_BUTTON_A,
	"crouch": JOY_BUTTON_LEFT_STICK,
	"melee": JOY_BUTTON_X,
	"shoot_rifle": JOY_BUTTON_RIGHT_SHOULDER,
	"special_attack": JOY_BUTTON_LEFT_SHOULDER,
	"heal": JOY_BUTTON_B,
	"interact": JOY_BUTTON_Y,
	"dash": JOY_BUTTON_RIGHT_STICK,
	"map": JOY_BUTTON_BACK,
	"pause": JOY_BUTTON_START,
}

var last_input_was_gamepad := false


func _enter_tree() -> void:
	for action in KEYBOARD_BINDINGS:
		_ensure_action(action)
		for keycode in KEYBOARD_BINDINGS[action]:
			_add_key_if_missing(action, keycode)
	for action in JOYPAD_BUTTON_BINDINGS:
		_ensure_action(action)
		_add_joy_button_if_missing(action, JOYPAD_BUTTON_BINDINGS[action])
	_add_joy_axis_if_missing("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis_if_missing("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis_if_missing("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis_if_missing("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_axis_if_missing("aim", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_joy_axis_if_missing("shoot_pistol", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_add_joy_button_if_missing("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_joy_button_if_missing("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button_if_missing("move_up", JOY_BUTTON_DPAD_UP)
	_add_joy_button_if_missing("move_down", JOY_BUTTON_DPAD_DOWN)
	_ensure_action("ui_accept")
	_ensure_action("ui_cancel")
	_add_key_if_missing("ui_accept", KEY_ENTER)
	_add_key_if_missing("ui_cancel", KEY_ESCAPE)
	_add_joy_button_if_missing("ui_accept", JOY_BUTTON_A)
	_add_joy_button_if_missing("ui_cancel", JOY_BUTTON_B)


func _input(event: InputEvent) -> void:
	var previous := last_input_was_gamepad
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_was_gamepad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		last_input_was_gamepad = false
	if previous != last_input_was_gamepad:
		input_device_changed.emit(last_input_was_gamepad)


func interact_prompt() -> String:
	return InputGlyphResolver.label_for_action(&"interact")


func _ensure_action(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.3)


func _add_key_if_missing(action: StringName, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


func _add_joy_button_if_missing(action: StringName, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


func _add_joy_axis_if_missing(action: StringName, axis: JoyAxis, value: float) -> void:
	_ensure_action(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
