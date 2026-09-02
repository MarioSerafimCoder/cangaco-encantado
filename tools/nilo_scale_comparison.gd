extends Node2D

const BASE_TEXTURE := preload("res://assets/sprites/usados/ferramentas/generic_sertanejo_chibi_4x4_64px.png")
const SHOOT_TEXTURE := preload("res://assets/sprites/usados/personagens/jogador/nilo_animacoes_de_tiro.png")
const OUTPUT_DIRECTORY := "res://prints_do_jogo/iteracao_0_2_4"
const TARGET_HEIGHT := 53.0 * 0.68
const BASELINE_Y := 126.0


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIRECTORY))
	_build_pose("IDLE", 40.0, BASE_TEXTURE, Rect2(0, 0, 64, 64), 53.0, 64.0)
	_build_pose("RUN", 120.0, BASE_TEXTURE, Rect2(0, 64, 64, 64), 51.0, 60.0)
	var cell_width := float(SHOOT_TEXTURE.get_width()) / 6.0
	_build_pose("REV", 200.0, SHOOT_TEXTURE, Rect2(cell_width * 3.0, 30, cell_width, 380), 270.0, 356.0)
	_build_pose("ESP", 280.0, SHOOT_TEXTURE, Rect2(cell_width * 3.0, 440, cell_width, 380), 271.0, 345.0)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUTPUT_DIRECTORY.path_join("nilo_comparacao_escala.png")))
	var names := ["nilo_idle.png", "nilo_run.png", "nilo_revolver.png", "nilo_shotgun.png"]
	var pose_width := image.get_width() / 4
	for index in 4:
		var pose_image := image.get_region(Rect2i(index * pose_width, 0, pose_width, image.get_height()))
		pose_image.save_png(ProjectSettings.globalize_path(OUTPUT_DIRECTORY.path_join(names[index])))
	get_tree().quit()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 320, 180), Color("191613"), true)
	for index in 4:
		draw_rect(Rect2(index * 80, 0, 80, 180), Color(0.11 + index * 0.012, 0.095, 0.08, 1.0), true)
		draw_line(Vector2(index * 80, 0), Vector2(index * 80, 180), Color(0.45, 0.34, 0.22, 0.45), 1.0)
	draw_line(Vector2(0, BASELINE_Y), Vector2(320, BASELINE_Y), Color("d29a4a"), 1.0)
	draw_rect(Rect2(0, BASELINE_Y + 1.0, 320, 54), Color("3a2a20"), true)


func _build_pose(label_text: String, x: float, pose_texture: Texture2D, frame_region: Rect2, useful_height: float, useful_bottom: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = pose_texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
	sprite.region_rect = frame_region
	var visual_scale := TARGET_HEIGHT / useful_height
	sprite.scale = Vector2(visual_scale, visual_scale)
	sprite.position = Vector2(x, BASELINE_Y - (useful_bottom - frame_region.size.y * 0.5) * visual_scale)
	add_child(sprite)
	var label := Label.new()
	label.position = Vector2(x - 38.0, 145.0)
	label.size = Vector2(76.0, 18.0)
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color("f2d49a"))
	add_child(label)
