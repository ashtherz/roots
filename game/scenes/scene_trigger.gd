extends Area2D

@export var nextScene : PackedScene

var triggered : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body == %Player and not triggered:
		triggered = true
		SceneManager.call_deferred("switch_to_sub_scene", nextScene)
