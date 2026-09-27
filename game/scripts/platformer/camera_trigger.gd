extends Area2D

@export var enableSilhouette : bool = false

var topLeft : Vector2 = Vector2(0,0)
var bottomRight : Vector2 = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size : Vector2 = $CollisionShape2D.shape.extents
	topLeft = $CollisionShape2D.global_position - size
	bottomRight = $CollisionShape2D.global_position + size
	print(topLeft, bottomRight)

func enable_limits() -> void:
	var camera : Camera2D = %Player.camera
	camera.limit_left = roundi(topLeft.x)
	camera.limit_top = roundi(topLeft.y)
	camera.limit_right = roundi(bottomRight.x)
	camera.limit_bottom = roundi(bottomRight.y)
	camera.limit_enabled = true


func _on_body_entered(body: Node2D) -> void:
	if body == %Player:
		enable_limits()
		%Player.silhouette.visible = enableSilhouette
