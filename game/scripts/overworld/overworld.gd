extends Node2D

## Kitchen (packing), bedroom (platformer), bathroom (suika).
const AREA_COUNT := 3

var areas_done : int = 0

@onready var dialogue = %DialogueLayer/Dialogue

func _ready() -> void:
	%Player.silhouette.visible = true
	%IntroCameraLimits.call_deferred("enable_limits")
	# Deferred so we never start dialogue mid-physics-callback (the platformer returns from body_entered).
	SceneManager.returned_to_previous_scene.connect(_on_returned, CONNECT_DEFERRED)
	dialogue.play.call_deferred("intro")

func _on_returned() -> void:
	var trigger = SceneManager.last_trigger
	SceneManager.last_trigger = null
	if trigger != null and trigger.dialogueAfter != "":
		await dialogue.play(trigger.dialogueAfter)

	areas_done += 1
	if areas_done == AREA_COUNT:
		await dialogue.play("ending")
		# TODO: end screen / credits go here
