extends Node

var dialogue_manager = preload("res://common/scripts/dialogue_manager.gd").new()
var dialogue_ui_scene = preload("res://common/ui/dialogue_ui.tscn")
var dialogue_ui = null

func _ready():
	Global.start_dialogue_requested.connect(_on_start_dialogue)
	add_child(dialogue_manager)
	
	dialogue_manager.dialogue_updated.connect(_on_dialogue_updated)
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

func _on_start_dialogue(data, start_node):
	if dialogue_ui == null:
		dialogue_ui = dialogue_ui_scene.instantiate()
		get_tree().root.add_child(dialogue_ui)
		dialogue_ui.choice_selected.connect(_on_choice_selected)
		dialogue_ui.dialogue_complete.connect(_on_dialogue_complete)
	
	dialogue_manager.load_dialogue(data, start_node)

func _on_dialogue_updated(text, choices):
	dialogue_ui.setup(text, choices)

func _on_choice_selected(index):
	dialogue_manager.next_node(index)

func _on_dialogue_complete():
	dialogue_manager.next_node()

func _on_dialogue_ended():
	if dialogue_ui:
		dialogue_ui.visible = false
