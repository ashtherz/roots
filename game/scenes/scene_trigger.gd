extends Area2D

@export var nextScene : PackedScene
@export var playerWaypoint : Node2D = null
@export var transmitPlayerPosition : bool = false

var triggered : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body == %Player:
		if not triggered:
			triggered = true
			if playerWaypoint != null:
				%Player.global_position = playerWaypoint.global_position
			SceneManager.call_deferred("switch_to_sub_scene", nextScene, transmitPlayerPosition)
