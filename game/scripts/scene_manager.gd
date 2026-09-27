extends Node

var previous_scene: Node = null

func switch_to_sub_scene(new_scene: PackedScene) -> void:
	var root = get_tree().root
	var current_scene = get_tree().current_scene

	# We're not starting a scene stack here
	if previous_scene != null:
		return

	# Save reference to current scene and remove it from tree without freeing it
	previous_scene = current_scene
	root.remove_child(current_scene)

	var loaded_scene = new_scene.instantiate()
	root.add_child(loaded_scene)
	get_tree().current_scene = loaded_scene

func return_to_previous_scene() -> void:
	if previous_scene == null:
		return

	var root = get_tree().root
	var current_scene = get_tree().current_scene

	# Remove the temporary sub-scene and free it
	root.remove_child(current_scene)
	current_scene.queue_free()

	# Restore the previous scene
	root.add_child(previous_scene)
	get_tree().current_scene = previous_scene
	previous_scene = null
