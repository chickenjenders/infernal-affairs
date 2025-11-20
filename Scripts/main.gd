extends Control

func _on_misery_manager_pressed() -> void:
	get_tree().change_scene_to_file("res://MiseryManager/Scenes/misery_manager.tscn")