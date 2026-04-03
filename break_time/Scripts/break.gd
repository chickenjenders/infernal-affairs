extends Node2D

@onready var dialogue_controller_script = preload("res://common/scripts/dialogue_controller.gd")

func _ready():
	# Create a controller for this scene
	var controller = Node.new()
	controller.set_script(dialogue_controller_script)
	add_child(controller)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")
