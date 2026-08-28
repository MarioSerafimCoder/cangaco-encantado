extends CanvasLayer

const TOAST_SCENE := preload("res://scenes/ui/components/notification_toast.tscn")

var _queue: Array[Dictionary] = []
var _active := false
var _suppressed := false
var _toast: PanelContainer
var _label: Label


func _ready() -> void:
	layer = 92
	process_mode = Node.PROCESS_MODE_ALWAYS
	_toast = TOAST_SCENE.instantiate()
	_toast.position = Vector2(210, 42)
	_toast.size = Vector2(220, 34)
	_toast.modulate.a = 0.0
	_toast.visible = false
	add_child(_toast)
	_label = _toast.get_node("Margin/Message") as Label
	EventBus.ability_unlocked.connect(func(_id, display_name): enqueue("NOVA HABILIDADE\n%s" % display_name, 90, &"ability"))
	EventBus.permanent_upgrade_collected.connect(func(_id, display_name): enqueue("MELHORIA PERMANENTE\n%s" % display_name, 80, &"upgrade"))
	EventBus.secret_discovered.connect(func(_id): enqueue("SEGREDO DESCOBERTO", 55, &"secret"))
	EventBus.lore_collectible_found.connect(func(_id, display_name): enqueue("RELATO ENCONTRADO\n%s" % display_name, 60, &"lore"))
	EventBus.world_state_changed.connect(_on_world_state_changed)
	EventBus.objective_changed.connect(func(text): enqueue("RASTRO ATUAL\n%s" % text, 70, &"objective", 3.4))


func enqueue(message: String, priority := 50, kind: StringName = &"info", duration := 2.4) -> void:
	var entry := {"message": message, "priority": priority, "kind": kind, "duration": duration}
	var insert_at := _queue.size()
	for index in _queue.size():
		if priority > int(_queue[index].priority):
			insert_at = index
			break
	_queue.insert(insert_at, entry)
	if not _active:
		_show_next.call_deferred()


func _show_next() -> void:
	if _active or _queue.is_empty():
		return
	_active = true
	var entry: Dictionary = _queue.pop_front()
	_label.text = String(entry.message)
	_toast.position = Vector2(210, 38)
	_toast.modulate.a = 0.0
	_toast.visible = not _suppressed
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_toast, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(_toast, "position:y", 42.0, 0.12)
	tween.tween_interval(float(entry.duration))
	tween.tween_property(_toast, "modulate:a", 0.0, 0.22)
	tween.tween_callback(_finish_active)


func _finish_active() -> void:
	_toast.visible = false
	_active = false
	_show_next()


func set_suppressed(value: bool) -> void:
	_suppressed = value
	if _toast != null and _active:
		_toast.visible = not value


func _on_world_state_changed(region_id: StringName, state: StringName) -> void:
	if region_id != &"vila_umbuzeiro":
		return
	enqueue("VILA LIBERTADA" if state == WorldState.LIBERATED else "VILA OCUPADA", 75, &"region")


func pending_count() -> int:
	return _queue.size() + (1 if _active else 0)
