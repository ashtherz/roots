extends Node2D

const DARKEN_THRESHOLD : float = 1200.0

var disabled : bool = false

func _process(_delta: float) -> void:
	if not disabled:
		var rel_x = %Player.global_position.x - global_position.x
		var darkness = clamp(rel_x / DARKEN_THRESHOLD + 1, 0, 1)
		%Darkness.set_darkness(darkness)
