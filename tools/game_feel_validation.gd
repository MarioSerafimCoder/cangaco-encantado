extends Node

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	var nilo := $Main/Nilo as NiloPlayer
	nilo.global_position = Vector2(80.0, 126.0)
	await _wait_physics_frames(20)
	await _validate_continuous_run(nilo)
	await _validate_turn_transition(nilo)
	await _validate_jump_phases(nilo)
	await _validate_crouch_hurtbox(nilo)
	await _validate_visual_scale_consistency(nilo)
	await _validate_revolver_is_semi_automatic(nilo)
	await _validate_machete_buffer_and_variants(nilo)
	await _validate_projectile_orientation()
	_validate_feedback_configuration(nilo)
	_validate_temporary_hud()
	_release_test_inputs()
	if failures.is_empty():
		print("GAME_FEEL_VALIDATION_OK")
		get_tree().quit()
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)


func _validate_continuous_run(nilo: NiloPlayer) -> void:
	var visual := nilo.visual
	var seen_frames: Dictionary = {}
	var start_contacts := visual.foot_contact_count
	var phase_advanced := false
	var bob_matches_phase := true
	var previous_phase := visual.run_phase
	Input.action_press("move_right")
	for _frame in 90:
		await get_tree().physics_frame
		var column := int(round(visual.region_rect.position.x / 64.0))
		var row := int(round(visual.region_rect.position.y / 64.0))
		if row == 1:
			seen_frames[column] = true
		if not is_equal_approx(previous_phase, visual.run_phase):
			phase_advanced = true
		previous_phase = visual.run_phase
		if visual.smoothed_speed_ratio > 0.2 and nilo.is_on_floor():
			var contact_amount := absf(cos(visual.run_phase * TAU))
			var expected := -(1.0 - contact_amount) * lerpf(0.08, 0.46, visual.smoothed_speed_ratio)
			if absf(visual.bob_offset - expected) > 0.035:
				bob_matches_phase = false
	Input.action_release("move_right")
	if seen_frames.size() != 4:
		failures.append("Corrida deveria percorrer 4 frames; observados: %s" % [seen_frames.keys()])
	if not phase_advanced:
		failures.append("run_phase não avançou continuamente durante a corrida.")
	if not bob_matches_phase:
		failures.append("Bob visual deixou de derivar do mesmo run_phase da animação.")
	if visual.foot_contact_count - start_contacts < 2:
		failures.append("Corrida não registrou contatos de pé suficientes para sincronizar poeira.")


func _validate_turn_transition(nilo: NiloPlayer) -> void:
	Input.action_press("move_right")
	await _wait_physics_frames(12)
	Input.action_release("move_right")
	Input.action_press("move_left")
	var saw_turn := false
	for _frame in 35:
		await get_tree().physics_frame
		if nilo.visual.visual_transition == NiloVisualController.VisualTransition.TURN:
			saw_turn = true
	Input.action_release("move_left")
	if not saw_turn:
		failures.append("Troca brusca de direção não acionou a transição TURN.")


func _validate_jump_phases(nilo: NiloPlayer) -> void:
	nilo.global_position = Vector2(150.0, 126.0)
	nilo.velocity = Vector2.ZERO
	await _wait_physics_frames(5)
	var phases: Dictionary = {}
	Input.action_press("jump")
	for frame in 150:
		await get_tree().physics_frame
		phases[nilo.visual.air_phase] = true
		if frame == 4:
			Input.action_release("jump")
		if frame > 20 and nilo.is_on_floor():
			break
	Input.action_release("jump")
	for required_phase in [&"ascent", &"apex", &"fall"]:
		if not phases.has(required_phase):
			failures.append("Salto não apresentou a fase visual %s." % required_phase)
	if nilo.visual.landing_intensity <= 0.08:
		failures.append("Pouso de salto não produziu intensidade visual mensurável.")


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


func _validate_visual_scale_consistency(nilo: NiloPlayer) -> void:
	var samples: Dictionary = {}
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	await _wait_physics_frames(2)
	samples[&"idle"] = Vector2(nilo.visual.normalized_visual_height, nilo.visual.normalized_baseline_offset)
	nilo.velocity.x = nilo.config.move_speed
	nilo.state_machine.request(PlayerStateMachine.State.RUN, 0.12, true)
	await _wait_physics_frames(2)
	samples[&"run"] = Vector2(nilo.visual.normalized_visual_height, nilo.visual.normalized_baseline_offset)
	nilo.velocity.x = 0.0
	nilo.state_machine.request(PlayerStateMachine.State.SHOOT, 0.24, true)
	await _wait_physics_frames(5)
	samples[&"revolver"] = Vector2(nilo.visual.normalized_visual_height, nilo.visual.normalized_baseline_offset)
	nilo.state_machine.request(PlayerStateMachine.State.SHOTGUN, 0.36, true)
	await _wait_physics_frames(6)
	samples[&"shotgun"] = Vector2(nilo.visual.normalized_visual_height, nilo.visual.normalized_baseline_offset)
	nilo.state_machine.request(PlayerStateMachine.State.IDLE, 0.0, true)
	var reference: Vector2 = samples[&"idle"]
	for pose_id in samples:
		var sample: Vector2 = samples[pose_id]
		if absf(sample.x - reference.x) > 0.05:
			failures.append("Altura visual de Nilo divergiu em %s: %.3f vs %.3f." % [pose_id, sample.x, reference.x])
		if absf(sample.y - reference.y) > 0.05:
			failures.append("Baseline visual de Nilo divergiu em %s: %.3f vs %.3f." % [pose_id, sample.y, reference.y])
	if nilo.get_node_or_null("ContactShadow") == null:
		failures.append("Nilo não possui ContactShadow reutilizável.")


func _validate_revolver_is_semi_automatic(nilo: NiloPlayer) -> void:
	var ammo_before := nilo.combat.revolver_ammo
	var shooting_frames: Dictionary = {}
	Input.action_press("shoot_revolver")
	for frame in 60:
		await get_tree().physics_frame
		if frame < 18 and nilo.state_machine.current_state == PlayerStateMachine.State.SHOOT:
			shooting_frames[nilo.visual.shooting_frame] = true
	Input.action_release("shoot_revolver")
	var spent := ammo_before - nilo.combat.revolver_ammo
	if spent != 1:
		failures.append("Revólver semiautomático deveria gastar 1 bala ao segurar; gastou %d." % spent)
	if not shooting_frames.has(2) or not shooting_frames.has(3) or not shooting_frames.has(5):
		failures.append("Disparo do revólver não percorreu mira, clarão e recuperação da folha dedicada: %s." % shooting_frames.keys())


func _validate_machete_buffer_and_variants(nilo: NiloPlayer) -> void:
	await _wait_physics_frames(20)
	Input.action_press("melee")
	await get_tree().process_frame
	Input.action_release("melee")
	var buffered := false
	for _frame in 40:
		await get_tree().physics_frame
		if nilo.combat.attack_phase == PlayerCombat.AttackPhase.FOLLOW_THROUGH and not buffered:
			Input.action_press("melee")
			await get_tree().process_frame
			Input.action_release("melee")
			buffered = true
		if nilo.combat.combo_step == 2 and nilo.combat.attack_phase != PlayerCombat.AttackPhase.NONE:
			break
	if not buffered or nilo.combat.combo_step != 2:
		failures.append("Buffer do facão não encadeou o segundo golpe do combo.")
	for _frame in 120:
		await get_tree().physics_frame
		if nilo.combat.attack_phase == PlayerCombat.AttackPhase.NONE and nilo.combat.cooldown <= 0.0:
			break
	Input.action_press("move_up")
	await get_tree().process_frame
	nilo.combat.request_melee_input()
	if nilo.combat.current_melee_variant != &"machete_up":
		failures.append("Entrada para cima não selecionou a variante machete_up.")
	if nilo.combat.attack_phase != PlayerCombat.AttackPhase.ANTICIPATION:
		failures.append("Facão deveria iniciar em ANTICIPATION antes do hitbox ativo.")
	Input.action_release("move_up")


func _validate_projectile_orientation() -> void:
	var projectile := CombatProjectile.new()
	projectile.team = "player"
	projectile.velocity = Vector2(100.0, -100.0)
	projectile.max_distance = 1000.0
	projectile.lifetime = 1.0
	projectile.setup_shape(Vector2(4.0, 2.0))
	add_child(projectile)
	projectile.global_position = Vector2(-100.0, -100.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	if absf(angle_difference(projectile.rotation, projectile.velocity.angle())) > 0.02:
		failures.append("Projétil não orientou sprite/trail na direção da velocidade.")
	projectile.queue_free()


func _validate_feedback_configuration(nilo: NiloPlayer) -> void:
	var config := nilo.combat.feedback_config
	if config == null:
		failures.append("CombatFeedbackConfig não foi carregado no PlayerCombat.")
		return
	if config.machete_hitstop(1) <= 0.0 or config.machete_hitstop(3) <= config.machete_hitstop(1):
		failures.append("Hitstop do facão não escala até o terceiro golpe.")
	if config.shotgun_hitstop <= config.revolver_hitstop:
		failures.append("Espingarda deveria ter hitstop maior que o revólver.")


func _validate_temporary_hud() -> void:
	var hud := $Main/HUD as GameHUD
	if hud.world_panel.size.y > 17.0 or hud.room_panel.size.y > 18.0:
		failures.append("HUD contextual excedeu a altura compacta definida para 0.2.1.")
	hud.world_fade = 0.0
	hud.room_fade = 0.0
	hud.help_fade = 0.0


func _release_test_inputs() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "jump", "crouch", "melee", "shoot_revolver"]:
		Input.action_release(action)


func _wait_physics_frames(count: int) -> void:
	for _frame in count:
		await get_tree().physics_frame
