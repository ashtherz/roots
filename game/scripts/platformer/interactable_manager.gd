extends Node2D

var sprites : Array[Sprite2D] = []
var interactCount : int = 0
var canReturn : bool = false

func play_game_win() -> void:
	for sprite in sprites:
		sprite.light_up()
	canReturn = true

func _on_interact(_sprite: Sprite2D) -> void:
	interactCount += 1
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
				sprite.interacted.connect(_on_interact)
	start_game()

func update_mushrooms_left() -> void:
	%MushroomCount.text = str(len(sprites) - interactCount)

func start_game() -> void:
	update_mushrooms_left()


func _on_return_trigger_body_entered(body: Node2D) -> void:
	if body == %Player and canReturn:
		SceneManager.return_to_previous_scene()
