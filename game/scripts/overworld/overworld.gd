extends Node2D

## Kitchen (packing), bedroom (platformer), bathroom (suika).
const AREA_COUNT := 3

var gamesComplete: Dictionary[String, bool] = {
	"Platformer": false,
	"Suika": false,
	"Packing": false,
}
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


func lorem_ipsum() -> void:
	%DialogueLayer/Dialogue.queue_text("player", "What a lovely fall day~")
	%DialogueLayer/Dialogue.queue_text("player", "What a relief that the placeholder text works! I wonder if pressing [ESC] will help me skip the dialogue...")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC])")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC])")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC])")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC] please)")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC] pretty please)")
	%DialogueLayer/Dialogue.queue_text("player", "(Press [ESC] pretty pretty please...)")
	%DialogueLayer/Dialogue.queue_text("player", "(...)")
	%DialogueLayer/Dialogue.queue_text("player", "(......)")
	%DialogueLayer/Dialogue.queue_text("player", "(...... you're not doing it right)")
	%DialogueLayer/Dialogue.call_deferred("start_text", true)
	
func _check_win_condition() -> void:
	if gamesComplete["Platformer"] and gamesComplete["Suika"] and gamesComplete["Packing"]:
		%DialogueLayer/Dialogue.queue_text("player", "Hey everyone! The shelter is ready for new inhabitants!")
		%DialogueLayer/Dialogue.call_deferred("start_text", true)

func register_game_complete(game: String) -> void:
	if game == "Platformer":
		%DarknessSource.disabled = true
		%InteractableManager.light_up_all()
	gamesComplete[game] = true
	
	if gamesComplete["Platformer"] and gamesComplete["Suika"] and gamesComplete["Packing"]:
		%DialogueLayer/Dialogue.queue_text("player", "All challenges done!")
		%DialogueLayer/Dialogue.queue_text("player", "Let's return to the surface and invite everyone in!")
		%DialogueLayer/Dialogue.call_deferred("start_text", true)
