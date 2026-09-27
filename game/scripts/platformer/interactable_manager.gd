extends Node2D

var sprites : Array[Sprite2D] = []
var interactCount : int = 0

func _play_game_win() -> void:
	for sprite in sprites:
			sprite.light_up()

func _on_interact(_sprite: Sprite2D) -> void:
	interactCount += 1
	update_mushrooms_left()
	if interactCount == len(sprites):
		_play_game_win()

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
