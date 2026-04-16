extends Node2D

var fade_scene = preload("res://common/ui/fade_layer.tscn")

func _on_start_pressed() -> void:
	var fade = fade_scene.instantiate()
	add_child(fade)
	await fade.fade_to_black(1.0)
	get_tree().change_scene_to_file("res://core/scenes/introvideo.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
