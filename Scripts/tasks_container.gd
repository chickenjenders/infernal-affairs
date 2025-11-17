@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var task_scene: PackedScene


func _ready():
	var taskTitles = MiseryManager.taskDetails[MiseryManager.department]
	taskTitles.shuffle()
	for i in range(count):
		var taskTitle = taskTitles[i]
		MiseryManager.taskList.append(taskTitle)

	_place_components()


func _place_components():
	for taskTitle in MiseryManager.taskList:
		var task_instance = task_scene.instantiate()
		task_instance.set_text(taskTitle)
		add_child(task_instance)
