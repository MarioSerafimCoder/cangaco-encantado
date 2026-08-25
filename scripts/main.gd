extends Node2D

@onready var world: VilaGraybox = $VilaDoUmbuzeiro
@onready var player: NiloPlayer = $Nilo


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not SaveManager.load_game():
		GameState.reset_new_game()
		WorldState.reset_new_game()


func _ready() -> void:
	player.global_position = GameState.checkpoint_position
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_right = int(world.world_width)
	camera.limit_top = -40
	camera.limit_bottom = 220
	camera.limit_smoothed = true
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
	if event.is_action_pressed("debug_liberate"):
		WorldState.liberate_vila()
		SaveManager.save_game()


func _on_boss_defeated(boss_id: StringName) -> void:
	if boss_id == &"ze_tranca":
		GameState.checkpoint_id = &"vila_liberada"
		GameState.checkpoint_position = world.get_room_center(&"praca_umbu")
		SaveManager.save_game()
