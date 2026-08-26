class_name ZeTrancaBoss
extends EnemyBase

var attack_index := 0


func _ready() -> void:
	super()
	add_to_group("bosses")
	if GameState.defeated_bosses.get("ze_tranca", false):
		queue_free()


func _perform_attack() -> void:
	attack_index = (attack_index + 1) % 5
	var second_phase := health.current_health <= health.max_health / 2
	match attack_index:
		0:
			_spawn_projectile(Vector2(facing, 0.0), 300.0, 230.0, &"direct_shot")
		1:
			_spawn_projectile(Vector2(facing, 0.14).normalized(), 285.0, 210.0, &"low_shot")
		2:
			_spawn_melee()
		3:
			velocity.x = -facing * 155.0
			state_machine.transition(EnemyStateMachine.State.ATTACK, 0.28, true)
		4:
			_burst(5 if second_phase else 3)


func _burst(count: int) -> void:
	for index in count:
		var angle := lerpf(-0.16, 0.16, float(index) / maxf(1.0, count - 1.0))
		_spawn_projectile(Vector2(facing, 0.0).rotated(angle), 320.0, 240.0, &"burst_shot")


func _on_died() -> void:
	_cancel_attack()
	state_machine.transition(EnemyStateMachine.State.DEAD, 0.0, true)
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	$Hurtbox.set_deferred("monitorable", false)
	EventBus.boss_defeated.emit(&"ze_tranca")
	await get_tree().create_timer(data.death_duration).timeout
	queue_free()
