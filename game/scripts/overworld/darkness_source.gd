extends Node2D

const DARKEN_THRESHOLD : float = 1200.0

func _process(delta: float) -> void:
	var rel_x = %Player.global_position.x - global_position.x
	var darkness = clamp(rel_x / DARKEN_THRESHOLD + 1, 0, 1)
	%Darkness.set_darkness(darkness)
