extends Node

const SAQUEADOR_SCENE := preload("res://scenes/enemies/saqueador.tscn")
const PISTOLEIRO_SCENE := preload("res://scenes/enemies/pistoleiro.tscn")
const RUA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/rua_das_cinzas.tscn")
const PRACA_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/praca_do_umbu.tscn")
const BARRACOS_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/barracos_queimados.tscn")
const POSTO_SCENE := preload("res://scenes/world/vila_umbuzeiro/rooms/posto_de_comando.tscn")

var failures: Array[String] = []
var player_target: Node2D


func _ready() -> void:
	WorldState.reset_new_game()
	player_target = Node2D.new()
	player_target.add_to_group("player")
	add_child(player_target)
	await get_tree().physics_frame
	_validate_patrol_and_return()
	await _validate_perception_memory()
	_validate_ranged_spacing()
	await _validate_obstacle_respect()
	await _validate_damage_and_death_timing()
	_validate_encounter_combinations()
	if failures.is_empty():
		print("ENEMY_AI_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_patrol_and_return() -> void:
	var enemy := _spawn_enemy(SAQUEADOR_SCENE, Vector2(-400.0, -120.0))
	enemy.configure_post(enemy.global_position, 1.0, 22.0)
	enemy.patrol_wait_remaining = 0.0
	var direction := float(enemy.call("_patrol_or_return_direction", 0.1))
	if direction <= 0.0 or enemy.state_machine.current != EnemyStateMachine.State.PATROL:
		failures.append("Saqueador não iniciou patrulha a partir do posto.")
	enemy.global_position.x = enemy.home_position.x + 34.0
	direction = float(enemy.call("_patrol_or_return_direction", 0.1))
	if direction >= 0.0 or enemy.state_machine.current != EnemyStateMachine.State.RETURN:
		failures.append("Inimigo fora do raio não retornou ao posto.")
	enemy.queue_free()


func _validate_perception_memory() -> void:
	var enemy := _spawn_enemy(SAQUEADOR_SCENE, Vector2(-300.0, -100.0))
	enemy.configure_post(enemy.global_position, 1.0, 30.0)
	player_target.global_position = enemy.global_position + Vector2(80.0, 0.0)
	var wall := _make_static_rect(enemy.global_position + Vector2(40.0, -5.0), Vector2(8.0, 60.0))
	await get_tree().physics_frame
	enemy.call("_update_perception", 0.1)
	if enemy.target != null or enemy.target_visible:
		failures.append("Inimigo detectou Nilo através de uma parede sem contato prévio.")
	wall.queue_free()
	await get_tree().physics_frame
	enemy.call("_update_perception", 0.1)
	if enemy.target != player_target or not enemy.target_visible:
		failures.append("Inimigo não adquiriu Nilo com linha de visão livre.")
	wall = _make_static_rect(enemy.global_position + Vector2(40.0, -5.0), Vector2(8.0, 60.0))
	await get_tree().physics_frame
	enemy.call("_update_perception", 0.1)
	if enemy.target != player_target or enemy.target_visible or enemy.target_memory_remaining <= 0.0:
		failures.append("Inimigo não guardou a última posição vista após perder a visão.")
	enemy.call("_update_perception", enemy.data.target_memory + 0.2)
	if enemy.target != null:
		failures.append("Inimigo continuou perseguindo depois de esgotar a memória do alvo.")
	wall.queue_free()
	enemy.queue_free()
	await get_tree().process_frame


func _validate_ranged_spacing() -> void:
	var enemy := _spawn_enemy(PISTOLEIRO_SCENE, Vector2(-200.0, -100.0))
	enemy.configure_post(enemy.global_position, 1.0, 30.0)
	enemy.target = player_target
	enemy.target_visible = true
	player_target.global_position = enemy.global_position + Vector2(35.0, 0.0)
	var direction := float(enemy.call("_combat_direction"))
	if direction >= 0.0 or enemy.state_machine.current != EnemyStateMachine.State.RETREAT:
		failures.append("Pistoleiro não recuou quando Nilo entrou na distância mínima.")
	enemy.attack_phase = EnemyBase.AttackPhase.NONE
	enemy.attack_cooldown = 0.5
	player_target.global_position = enemy.global_position + Vector2(145.0, 0.0)
	direction = float(enemy.call("_combat_direction"))
	if direction <= 0.0 or enemy.state_machine.current != EnemyStateMachine.State.CHASE:
		failures.append("Pistoleiro não avançou para recuperar a distância de tiro.")
	enemy.queue_free()


func _validate_obstacle_respect() -> void:
	var floor := _make_static_rect(Vector2(-100.0, 10.0), Vector2(180.0, 10.0))
	var enemy := SAQUEADOR_SCENE.instantiate() as EnemyBase
	add_child(enemy)
	enemy.global_position = Vector2(-130.0, -20.0)
	enemy.configure_post(enemy.global_position, 1.0, 30.0)
	for _frame in 20:
		await get_tree().physics_frame
	enemy.set_physics_process(false)
	var wall := _make_static_rect(enemy.global_position + Vector2(12.0, -6.0), Vector2(6.0, 42.0))
	await get_tree().physics_frame
	if not enemy.is_on_floor():
		failures.append("Cenário de obstáculo não assentou o inimigo no chão.")
	elif not is_zero_approx(enemy.movement.safe_direction(enemy, 1.0)):
		failures.append("Movimento inimigo tentou atravessar uma parede à frente.")
	wall.queue_free()
	floor.queue_free()
	enemy.queue_free()
	await get_tree().process_frame


func _validate_damage_and_death_timing() -> void:
	var enemy := _spawn_enemy(SAQUEADOR_SCENE, Vector2(-420.0, -120.0))
	player_target.global_position = enemy.global_position - Vector2(20.0, 0.0)
	var accepted := enemy.receive_hit({"damage": 1, "posture_damage": 0.0, "knockback": Vector2(20.0, -5.0), "source": player_target})
	if not accepted or enemy.state_machine.current != EnemyStateMachine.State.HURT:
		failures.append("Inimigo não entrou em reação de dano.")
	if enemy.state_machine.lock_remaining < enemy.data.hurt_duration * 0.9:
		failures.append("Reação de dano terminou antes da duração configurada.")
	enemy.receive_hit({"damage": 9, "posture_damage": 0.0, "source": player_target})
	if enemy.state_machine.current != EnemyStateMachine.State.DEAD:
		failures.append("Inimigo derrotado não entrou na animação de morte.")
	await get_tree().create_timer(enemy.data.death_duration * 0.45).timeout
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
		failures.append("Inimigo desapareceu antes da animação longa de morte.")
	await get_tree().create_timer(enemy.data.death_duration * 0.7).timeout
	if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
		failures.append("Inimigo permaneceu após o encerramento da animação de morte.")


func _validate_encounter_combinations() -> void:
	var expectations := [
		[RUA_SCENE, 1, "Rua das Cinzas"],
		[PRACA_SCENE, 0, "Praça do Umbu"],
		[BARRACOS_SCENE, 2, "Barracos Queimados"],
		[POSTO_SCENE, 2, "Posto de Comando"],
	]
	for entry in expectations:
		var room := (entry[0] as PackedScene).instantiate()
		var count := 0
		for candidate in room.find_children("*", "", true, false):
			if candidate is EnemySpawn:
				count += 1
		if count != int(entry[1]):
			failures.append("%s deveria ter %d posições inimigas no ritmo da Área 01; encontrou %d." % [entry[2], entry[1], count])
		room.free()


func _spawn_enemy(scene: PackedScene, position_value: Vector2) -> EnemyBase:
	var enemy := scene.instantiate() as EnemyBase
	add_child(enemy)
	enemy.set_physics_process(false)
	enemy.global_position = position_value
	enemy.configure_post(position_value, 1.0, 30.0)
	return enemy


func _make_static_rect(center: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	body.global_position = center
	return body
