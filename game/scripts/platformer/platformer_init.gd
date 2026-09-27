extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera : Camera2D = %Player.camera
	# spdskatr: I accidentally moved the tilemap global position in the
	# overworld and this is my bandaid fix
	camera.limit_top = -37
	camera.limit_left = -79
	camera.limit_right = 1312 - 79
	camera.limit_bottom = 640 - 37
	camera.limit_enabled = true
	%Player/Spotlight.visible = true
