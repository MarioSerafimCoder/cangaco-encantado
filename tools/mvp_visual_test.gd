extends Node


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	nilo.global_position = Vector2(640.0, 126.0)
	var camera := nilo.get_node("Camera2D") as Camera2D
	camera.reset_smoothing()
	await _wait_frames(30)
	var output_directory := ProjectSettings.globalize_path("res://screenshots")
	DirAccess.make_dir_recursive_absolute(output_directory)
	_capture(output_directory.path_join("mvp_rua.png"))
	nilo.global_position = Vector2(6400.0, 126.0)
	camera.reset_smoothing()
	await _wait_frames(30)
	_capture(output_directory.path_join("mvp_boss.png"))
	get_tree().quit()


func _wait_frames(count: int) -> void:
	for _frame in count:
		await get_tree().process_frame


func _capture(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(path)
