extends Node2D

@export var isOverworld = false

var sprites : Array[Sprite2D] = []
var interactCount : int = 0
var canReturn : bool = false

func light_up_all() -> void:
	for sprite in sprites:
		sprite.light_up()
	%Darkness.set_darkness(0.0)

func _hide_ending_layer() -> void:
	%EndingLayer.visible = false
	
func _ending_text() -> void:
	var dialogue = %DialogueLayer/Dialogue
	dialogue.queue_text("player", "Placeholder ending")
	dialogue.call_deferred("start_text", true)
	dialogue.textFinished.connect(_hide_ending_layer)

func play_game_win() -> void:
	light_up_all()
	if isOverworld:
		return
	%EndingLayer.visible = true
	canReturn = true
	_ending_text()

func _on_interact(_sprite: Sprite2D) -> void:
	if isOverworld:
		# Do nothing in overworld
		return
	interactCount += 1
	if not isOverworld:
		update_mushrooms_left()
		if interactCount == 2:
			%InteractHint.visible = false
		if interactCount == len(sprites):
			call_deferred("play_game_win")

func _ready() -> void:
	for node in get_children():
		if is_instance_of(node, Area2D):
			var sprite : Sprite2D = node.find_child("Sprite2D")
			if sprite != null:
				sprites.append(sprite)
				if isOverworld:
					sprite.interactionState = "DISABLED"
				else:
					sprite.interacted.connect(_on_interact)

	if not isOverworld:
		start_game()

func update_mushrooms_left() -> void:
	%MushroomCount.text = str(len(sprites) - interactCount)

func start_game() -> void:
	update_mushrooms_left()


func _on_return_trigger_body_entered(body: Node2D) -> void:
	if body == %Player and canReturn:
		SceneManager.call_deferred("return_to_previous_scene", "Platformer", %Player.global_position, %Player.velocity)
