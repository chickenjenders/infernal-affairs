extends Node
class_name DialogueManager

# dictionary to store dialogue nodes, mimicking Twine's layout
# { "node_id": { "text": "...", "choices": [{"text": "...", "next": "node_id"}] } }
var dialogue_data = {}
var current_node = ""

signal dialogue_updated(text, choices)
signal dialogue_ended

func load_dialogue(data: Dictionary, start_node: String = "start"):
	dialogue_data = data
	current_node = start_node
	_display_current_node()

func next_node(choice_index: int = -1):
	if current_node == "" or not dialogue_data.has(current_node):
		end_dialogue()
		return

	var node = dialogue_data[current_node]
	
	if choice_index != -1:
		if node.has("choices") and choice_index < node["choices"].size():
			current_node = node["choices"][choice_index].get("next", "")
		else:
			current_node = ""
	else:
		current_node = node.get("next", "")

	if current_node == "" or not dialogue_data.has(current_node):
		end_dialogue()
	else:
		_display_current_node()

func _display_current_node():
	var node = dialogue_data[current_node]
	dialogue_updated.emit(node["text"], node.get("choices", []))

func end_dialogue():
	current_node = ""
	dialogue_ended.emit()
