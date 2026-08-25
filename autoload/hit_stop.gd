extends Node

var _freeze_counts: Dictionary = {}
var _original_modes: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func apply(nodes: Array, duration: float) -> void:
	if duration <= 0.0:
		return
	var frozen: Array[Node] = []
	for node in nodes:
		if node == null or not is_instance_valid(node) or node == self:
			continue
		var target := node as Node
		var instance_id: int = target.get_instance_id()
		if not _freeze_counts.has(instance_id):
			_freeze_counts[instance_id] = 0
			_original_modes[instance_id] = target.process_mode
		_freeze_counts[instance_id] = int(_freeze_counts[instance_id]) + 1
		target.process_mode = Node.PROCESS_MODE_DISABLED
		frozen.append(target)
	_release_after(frozen, duration)


func _release_after(nodes: Array[Node], duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout
	for node in nodes:
		if node == null or not is_instance_valid(node):
			continue
		var instance_id: int = node.get_instance_id()
		if not _freeze_counts.has(instance_id):
			continue
		_freeze_counts[instance_id] = int(_freeze_counts[instance_id]) - 1
		if int(_freeze_counts[instance_id]) <= 0:
			node.process_mode = int(_original_modes.get(instance_id, Node.PROCESS_MODE_INHERIT))
			_freeze_counts.erase(instance_id)
			_original_modes.erase(instance_id)
