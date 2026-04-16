extends Node2D

func _ready():
	pass

func _on_start_pressed() -> void:
	# Ensure dialogue is cleaned up
	var root = get_tree().root
	if root:
		for child in root.get_children():
			if child is CanvasLayer and (child.name.contains("Balloon") or child.name.contains("Dialogue")):
				child.queue_free()
	
	# If we are inside the Desktop/Windows system (running the full game)
	if get_parent() and get_parent().name == "Desktop":
		var desktop = get_parent()
		# Return to Misery Manager inside the Desktop
		var misery_manager_scene = load("res://misery_manager/scenes/misery_manager.tscn")
		var misery_manager_instance = misery_manager_scene.instantiate()
		desktop.add_child(misery_manager_instance)
		queue_free() # Remove the Break scene
	else:
		# Fallback for "Run Current Scene" or standalone testing
		get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")
