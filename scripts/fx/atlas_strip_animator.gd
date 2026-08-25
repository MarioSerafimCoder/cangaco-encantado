class_name AtlasStripAnimator
extends Sprite2D

@export var frame_rect := Rect2(0.0, 0.0, 16.0, 16.0)
@export_range(1, 32) var frame_count := 1
@export_range(0.1, 30.0) var frames_per_second := 8.0
@export var random_start := true

var _elapsed := 0.0
var _current_frame := -1


func _ready() -> void:
	region_enabled = true
	region_filter_clip_enabled = true
	if random_start and frame_count > 1:
		_elapsed = randf() * float(frame_count) / frames_per_second
	_apply_frame()


func _process(delta: float) -> void:
	_elapsed += delta
	_apply_frame()


func _apply_frame() -> void:
	var next_frame := int(floor(_elapsed * frames_per_second)) % maxi(frame_count, 1)
	if next_frame == _current_frame:
		return
	_current_frame = next_frame
	region_rect = Rect2(
		frame_rect.position + Vector2(frame_rect.size.x * float(_current_frame), 0.0),
		frame_rect.size
	)
