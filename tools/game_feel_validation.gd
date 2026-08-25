extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	nilo.global_position = Vector2(80.0, 126.0)
	await _wait_physics_frames(20)
	await _validate_run_frames(nilo)
	await _validate_crouch_hurtbox(nilo)
	await _validate_revolver_is_semi_automatic(nilo)
	if failures.is_empty():
		print("GAME_FEEL_VALIDATION_OK")
		get_tree().quit()
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)


func _validate_run_frames(nilo: NiloPlayer) -> void:
	var visual := nilo.get_node("Visual") as Sprite2D
	var seen_frames: Dictionary = {}
	Input.action_press("move_right")
	for _frame in 90:
		await get_tree().physics_frame
		var column := int(round(visual.region_rect.position.x / 64.0))
		var row := int(round(visual.region_rect.position.y / 64.0))
		if row == 1:
			seen_frames[column] = true
	Input.action_release("move_right")
	if seen_frames.size() != 4:
		failures.append("Corrida deveria percorrer 4 frames; observados: %s" % [seen_frames.keys()])


func _validate_crouch_hurtbox(nilo: NiloPlayer) -> void:
	Input.action_press("crouch")
	await _wait_physics_frames(3)
	var body_shape := nilo.body_collision.shape as RectangleShape2D
	var hurt_shape := nilo.hurt_collision.shape as RectangleShape2D
	if not is_equal_approx(body_shape.size.y, 14.0) or not is_equal_approx(hurt_shape.size.y, 14.0):
		failures.append("Collider e hurtbox não reduziram juntos no agachamento.")
	if not is_equal_approx(nilo.body_collision.position.y, nilo.hurt_collision.position.y):
		failures.append("Collider e hurtbox ficaram desalinhados no agachamento.")
	Input.action_release("crouch")
	await _wait_physics_frames(2)


func _validate_revolver_is_semi_automatic(nilo: NiloPlayer) -> void:
	var ammo_before := nilo.combat.revolver_ammo
	Input.action_press("shoot_revolver")
	await _wait_physics_frames(60)
	Input.action_release("shoot_revolver")
	var spent := ammo_before - nilo.combat.revolver_ammo
	if spent != 1:
		failures.append("Revólver semiautomático deveria gastar 1 bala ao segurar; gastou %d." % spent)


func _wait_physics_frames(count: int) -> void:
	for _frame in count:
		await get_tree().physics_frame
