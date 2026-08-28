extends Node

const OUTPUT_FOLDER := "res://prints_do_jogo/rua_das_cinzas_0_2_2"

var nilo: NiloPlayer
var camera: Camera2D
var hud: GameHUD
var room: RoomController


func _ready() -> void:
	await get_tree().process_frame
	nilo = $Main/Nilo as NiloPlayer
	camera = nilo.camera
	hud = $Main/HUD as GameHUD
	room = get_tree().get_first_node_in_group("production_rooms") as RoomController
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_FOLDER))
	_set_world_state(WorldState.OCCUPIED)

	await _prepare_player(room.to_global(Vector2(48.0, 138.0)))
	_capture("01_entrada_esquerda.png")
	await _prepare_player(room.to_global(Vector2(320.0, 138.0)))
	_capture("02_meio_da_sala.png")
	await _capture_combat()
	_arrange_room_enemies(false)
	await _prepare_player(room.to_global(Vector2(390.0, 138.0)))
	_capture("04_foreground.png")
	_arrange_room_enemies(true)
	await _prepare_player(room.to_global(Vector2(390.0, 138.0)))
	_capture("05_vila_ocupada.png")

	_set_world_state(WorldState.LIBERATED)
	await _prepare_player(room.to_global(Vector2(390.0, 138.0)))
	_capture("06_vila_libertada.png")
	get_tree().quit()


func _capture_combat() -> void:
	await _prepare_player(room.to_global(Vector2(270.0, 138.0)))
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is EnemyBase and room.get_global_bounds().has_point((enemy as EnemyBase).global_position):
			(enemy as EnemyBase).process_mode = Node.PROCESS_MODE_DISABLED
			(enemy as EnemyBase).global_position = room.to_global(Vector2(314.0, 137.0))
			break
	nilo.facing = 1.0
	nilo.state_machine.request(PlayerStateMachine.State.MELEE, 0.25, true)
	GameFeelFX.spawn(get_tree().current_scene, nilo.global_position + Vector2(12.0, -7.0), GameFeelFX.Kind.SLASH_HORIZONTAL, 1.0, 1.15)
	await _wait_frames(2)
	_capture("03_combate.png")


func _arrange_room_enemies(show_enemies: bool) -> void:
	var room_index := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is not EnemyBase or not room.get_global_bounds().has_point((enemy as EnemyBase).global_position):
			continue
		var actor := enemy as EnemyBase
		actor.process_mode = Node.PROCESS_MODE_DISABLED
		actor.visible = show_enemies
		actor.global_position = room.to_global(Vector2(170.0 if room_index == 0 else 500.0, 137.0))
		room_index += 1


func _prepare_player(target: Vector2) -> void:
	nilo.invulnerability_remaining = 0.0
	nilo.health.restore_full()
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	nilo.global_position = target
	nilo.velocity = Vector2.ZERO
	camera.reset_smoothing()
	await _wait_frames(18)
	hud.room_fade = 0.0
	hud.help_fade = 0.0
	await _wait_frames(2)


func _set_world_state(state: StringName) -> void:
	WorldState.region_states["vila_umbuzeiro"] = state
	EventBus.world_state_changed.emit(&"vila_umbuzeiro", state)


func _capture(filename: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUTPUT_FOLDER.path_join(filename)))


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame
