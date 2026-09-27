extends Node2D


func _ready() -> void:
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
