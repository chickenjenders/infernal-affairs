extends Node


var current_employee_index: int = 0

signal start_dialogue_requested(data, start_node)

func start_dialogue(data, start_node):
	start_dialogue_requested.emit(data, start_node)
