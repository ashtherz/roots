extends Node

var previous_scene: Node = null

func switch_to_sub_scene(new_scene: PackedScene, transmit_player_position : bool = false) -> void:
	var root = get_tree().root
	var current_scene = get_tree().current_scene

	# We're not starting a scene stack here
	if previous_scene != null:
		return
	
	var old_player : CharacterBody2D = current_scene.find_child("Player")
	var old_position : Vector2 = old_player.global_position
	var old_velocity : Vector2 = old_player.velocity

	# Save reference to current scene and remove it from tree without freeing it
	previous_scene = current_scene
	root.remove_child(current_scene)

	var loaded_scene = new_scene.instantiate()
	root.add_child(loaded_scene)
	get_tree().current_scene = loaded_scene
	if transmit_player_position:
		var player : CharacterBody2D = loaded_scene.find_child("Player")
		player.global_position = old_position
		player.velocity = old_velocity

func return_to_previous_scene(player_position: Vector2 = Vector2.INF, player_velocity: Vector2 = Vector2.ZERO, platformer_complete : bool = false) -> void:
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
	var player : CharacterBody2D = previous_scene.find_child("Player")
	if player_position.is_finite():
		player.global_position = player_position
	player.velocity = player_velocity
	previous_scene = null
