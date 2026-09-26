extends Node2D


var sprites : Array[Sprite2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_children():
		if is_instance_of(node, Area2D):
			var sprite : Sprite2D = node.find_child("Sprite2D")
			if sprite != null:
				sprites.append(sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
