extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Darkness.set_darkness(1)
	%DialogueLayer/Dialogue.play.call_deferred("bedroom_before")
