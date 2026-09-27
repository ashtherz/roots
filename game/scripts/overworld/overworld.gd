extends Node2D

var gamesComplete: Dictionary[String, bool] = {
	"Platformer": false,
	"Suika": false,
	"Packing": false,
}

@onready var dialogue = %DialogueLayer/Dialogue

func _ready() -> void:
	%Player.silhouette.visible = true
	%IntroCameraLimits.call_deferred("enable_limits")
	# Deferred so we never start dialogue mid-physics-callback (the platformer returns from body_entered).
	SceneManager.returned_to_previous_scene.connect(_on_returned, CONNECT_DEFERRED)
	dialogue.play.call_deferred("intro")


func _on_returned() -> void:
	var trigger = SceneManager.lastTrigger
	SceneManager.lastTrigger = null
	if trigger != null and trigger.dialogueAfter != "":
		await dialogue.play(trigger.dialogueAfter)


func _lorem_ipsum() -> void:
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
	if gamesComplete["Platformer"] and gamesComplete["Suika"] and gamesComplete["Packing"] and not $Credits.visible:
		await %DialogueLayer/Dialogue.play("ending")
		$Credits.visible = true

func register_game_complete(game: String) -> void:
	if game == "Platformer":
		%DarknessSource.disabled = true
		%InteractableManager.light_up_all()
	gamesComplete[game] = true
	
	if gamesComplete["Platformer"] and gamesComplete["Suika"] and gamesComplete["Packing"]:
		%DialogueLayer/Dialogue.queue_text("player", "All tasks complete!")
		%DialogueLayer/Dialogue.queue_text("player", "Let's return to the surface and invite everyone in!")
		%DialogueLayer/Dialogue.call_deferred("start_text", true)


func _on_ending_trigger_body_entered(body: Node2D) -> void:
	if body == %Player:
		_check_win_condition()
