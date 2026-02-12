extends Control

func _on_misery_manager_pressed() -> void:
	var misery_manager_scene = load("res://MiseryManager/Scenes/Components/misery_manager.tscn")
	var misery_manager_instance = misery_manager_scene.instantiate()
	add_child(misery_manager_instance)
