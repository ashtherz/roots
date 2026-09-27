extends Node2D

var gamesComplete: Dictionary[String, bool] = {
	"Platformer": false,
	"Suika": false,
	"Packing": false,
}

func _ready() -> void:
	%Player.silhouette.visible = true
	%IntroCameraLimits.call_deferred("enable_limits")
	lorem_ipsum()

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

func register_game_complete(game: String) -> void:
	if game == "Platformer":
		%DarknessSource.disabled = true
		%InteractableManager.light_up_all()
	gamesComplete[game] = true
