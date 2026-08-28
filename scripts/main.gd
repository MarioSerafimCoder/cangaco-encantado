extends Node2D

@export var show_title_on_start := true

@onready var world: VilaGraybox = $VilaDoUmbuzeiro
@onready var player: NiloPlayer = $Nilo
@onready var front_end: FrontEndMenu = $FrontEndMenu

var _start_immediately := false
var _starting_new_game := false
var _screen_fade: ColorRect
var _has_entered_game := false


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var starting_new_game := SaveManager.consume_new_game_request()
	_starting_new_game = starting_new_game
	_start_immediately = SaveManager.consume_skip_title_request()
	if starting_new_game:
		GameState.reset_new_game()
		WorldState.reset_new_game()
	elif not SaveManager.load_game():
		GameState.reset_new_game()
		WorldState.reset_new_game()


func _ready() -> void:
	_build_screen_fade()
	front_end.game_entered.connect(_on_game_entered)
	EventBus.player_died.connect(_on_player_died)
	player.global_position = GameState.checkpoint_position
	if _starting_new_game:
		SaveManager.save_game()
	if show_title_on_start and not _start_immediately:
		# A tela de transição fica acima do menu. No boot ela precisa começar
		# transparente; caso contrário o jogo carrega, mas aparenta não iniciar.
		_screen_fade.modulate.a = 0.0
		front_end.show_title(true)
	else:
		front_end.enter_game()


func _build_screen_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_screen_fade = ColorRect.new()
	_screen_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_screen_fade.color = Color(0.015, 0.01, 0.008, 1.0)
	_screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_screen_fade)


func _on_game_entered() -> void:
	if _has_entered_game:
		return
	_has_entered_game = true
	var hud := get_node_or_null("HUD") as GameHUD
	if hud != null:
		hud.begin_opening_guide()
	_screen_fade.modulate.a = 1.0
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.12)
	tween.tween_property(_screen_fade, "modulate:a", 0.0, 0.75).set_trans(Tween.TRANS_SINE)


func _on_player_died() -> void:
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_screen_fade, "modulate:a", 1.0, 0.48).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.28)
	tween.tween_property(_screen_fade, "modulate:a", 0.0, 0.58).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_liberate"):
		WorldState.liberate_vila()
		SaveManager.save_game()
