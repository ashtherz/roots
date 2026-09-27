extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera : Camera2D = %Player.camera
	camera.limit_top = 0
	camera.limit_left = 0
	camera.limit_right = 1312
	camera.limit_bottom = 640
	camera.limit_enabled = true
	%Player/Spotlight.visible = true
