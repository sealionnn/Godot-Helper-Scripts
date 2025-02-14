class_name Audio extends Node

static func play_varied_pitch(node: AudioStreamPlayer, base_range: float = 0.1) -> void:
	if !node:
		return
		
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play()

static func play_varied_pitch_2d(node: AudioStreamPlayer2D, base_range: float = 0.1, seek: float = 0.0) -> void:
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play(seek)
