extends Node2D

@onready var world: VilaGraybox = $VilaDoUmbuzeiro
@onready var player: NiloPlayer = $Nilo
@onready var front_end: FrontEndMenu = $FrontEndMenu

var _start_immediately := false


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var starting_new_game := SaveManager.consume_new_game_request()
	_start_immediately = SaveManager.consume_skip_title_request()
	if starting_new_game:
		GameState.reset_new_game()
		WorldState.reset_new_game()
	elif not SaveManager.load_game():
		GameState.reset_new_game()
		WorldState.reset_new_game()


func _ready() -> void:
	player.global_position = GameState.checkpoint_position
	EventBus.boss_defeated.connect(_on_boss_defeated)
	if get_tree().current_scene == self and not _start_immediately:
		front_end.show_title(true)
	else:
		front_end.enter_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_liberate"):
		WorldState.liberate_vila()
		SaveManager.save_game()


func _on_boss_defeated(boss_id: StringName) -> void:
	if boss_id == &"ze_tranca":
		GameState.checkpoint_id = &"vila_liberada"
		GameState.checkpoint_position = world.get_room_center(&"praca_umbu")
		SaveManager.save_game()
