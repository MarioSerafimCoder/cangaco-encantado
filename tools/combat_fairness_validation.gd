extends Node

const SAQUEADOR_SCENE := preload("res://scenes/enemies/saqueador.tscn")

var failures: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	await _validate_enemy_attack_phases()
	await _validate_projectile_stops_at_world()
	await _validate_line_of_sight()
	if failures.is_empty():
		print("COMBAT_FAIRNESS_VALIDATION_OK")
		get_tree().quit()
		return
	for failure in failures:
		push_error(failure)
	get_tree().quit(1)


func _validate_enemy_attack_phases() -> void:
	var enemy := SAQUEADOR_SCENE.instantiate() as EnemyBase
	add_child(enemy)
	enemy.set_physics_process(false)
	enemy.position = Vector2(-400.0, -200.0)
	var before := _count_attack_hitboxes()
	enemy.set("attack_cooldown", 0.0)
	enemy.call("_begin_attack")
	if enemy.attack_phase != EnemyBase.AttackPhase.ANTICIPATION:
		failures.append("Ataque inimigo não começou em ANTICIPATION.")
	if _count_attack_hitboxes() != before:
		failures.append("Hitbox inimiga nasceu antes da antecipação terminar.")
	enemy.call("_update_attack_sequence", enemy.data.attack_windup * 0.5)
	if _count_attack_hitboxes() != before:
		failures.append("Hitbox inimiga ficou ativa durante a primeira metade da antecipação.")
	enemy.call("_update_attack_sequence", enemy.data.attack_windup)
	if enemy.attack_phase != EnemyBase.AttackPhase.ACTIVE:
		failures.append("Ataque inimigo não entrou na fase ACTIVE após o aviso.")
	if _count_attack_hitboxes() != before + 1:
		failures.append("Ataque corpo a corpo deveria criar exatamente uma hitbox na fase ACTIVE.")
	enemy.call("_update_attack_sequence", enemy.data.attack_active_time + 0.01)
	if enemy.attack_phase != EnemyBase.AttackPhase.RECOVERY:
		failures.append("Ataque inimigo não entrou em RECOVERY após a fase ativa.")
	for child in get_children():
		if child is AttackHitbox:
			child.queue_free()
	enemy.queue_free()
	await get_tree().process_frame


func _validate_projectile_stops_at_world() -> void:
	var wall := _make_wall(Vector2(-200.0, -100.0), Vector2(8.0, 80.0))
	await get_tree().physics_frame
	var projectile := CombatProjectile.new()
	projectile.team = "player"
	projectile.velocity = Vector2(680.0, 0.0)
	projectile.max_distance = 200.0
	projectile.lifetime = 1.0
	projectile.setup_shape(Vector2(4.0, 2.0))
	add_child(projectile)
	projectile.global_position = Vector2(-235.0, -100.0)
	for _frame in 8:
		await get_tree().physics_frame
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			break
	if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
		failures.append("Projétil atravessou um StaticBody2D da camada World.")
		projectile.queue_free()
	wall.queue_free()
	await get_tree().process_frame


func _validate_line_of_sight() -> void:
	var wall := _make_wall(Vector2(-200.0, -100.0), Vector2(8.0, 80.0))
	var origin := Node2D.new()
	var candidate := Node2D.new()
	var detection := EnemyDetection.new()
	add_child(origin)
	add_child(candidate)
	add_child(detection)
	origin.global_position = Vector2(-230.0, -94.0)
	candidate.global_position = Vector2(-170.0, -94.0)
	await get_tree().physics_frame
	if detection.has_line_of_sight(origin, candidate):
		failures.append("Linha de visão inimiga ignorou uma parede entre inimigo e alvo.")
	wall.queue_free()
	await get_tree().physics_frame
	if not detection.has_line_of_sight(origin, candidate):
		failures.append("Linha de visão permaneceu bloqueada depois de remover a parede.")
	origin.queue_free()
	candidate.queue_free()
	detection.queue_free()


func _make_wall(center: Vector2, size: Vector2) -> StaticBody2D:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	add_child(wall)
	wall.global_position = center
	return wall


func _count_attack_hitboxes() -> int:
	var count := 0
	for child in get_children():
		if child is AttackHitbox and child is not CombatProjectile:
			count += 1
	return count
