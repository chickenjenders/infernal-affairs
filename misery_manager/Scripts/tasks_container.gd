@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var task_scene: PackedScene
@export var misery_manager: Node

const TaskDataResource = preload("res://MiseryManager/Scripts/task_data.gd")

var pregenerated_task_data := []

## Called when the container is added to the scene tree.
## Initializes the task list with random tasks from the current department
## and creates the task nodes to display them.
func _ready():
	add_to_group("tasks_container") # Add group for task detection
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return

	# Removed the task_templates check since it's now in ShiftManager
	_build_pregenerated_task_data()
	var available_tasks := []
	for task_data in pregenerated_task_data:
		available_tasks.append(_duplicate_task_data(task_data))
	available_tasks.shuffle()
	for i in range(min(count, available_tasks.size())):
		misery_manager.taskList.append(available_tasks[i])

	_place_components()
	
	# Listen for employee change to regenerate tasks
	misery_manager.employee_changed.connect(_on_employee_changed)

## Creates and displays all task nodes from the MiseryManager.taskList.
## Each task is assigned to the "tasks_container" group so it knows it belongs
## to the task list (not in a scheduler slot).
func _place_components():
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	for task_data in misery_manager.taskList:
		var task_instance = task_scene.instantiate()
		task_instance.set_task_data(task_data)
		if "misery_manager" in task_instance:
			task_instance.misery_manager = misery_manager
		task_instance.add_to_group("tasks_container") # Assign group BEFORE adding to tree
		add_child(task_instance)

func _build_pregenerated_task_data():
	pregenerated_task_data.clear()
	var templates = misery_manager.get_task_templates()
	for template in templates:
		pregenerated_task_data.append(_create_task_data_from_template(template))

func _create_task_data_from_template(template: Dictionary):
	var data = TaskDataResource.new()
	data.title = template.get("title", "")
	data.description = template.get("description", "")
	data.department = template.get("department", misery_manager.department)
	data.tags = template.get("tags", [])
	data.misery_score = template.get("misery_score", 0)
	return data

func _duplicate_task_data(data: TaskData):
	return data.duplicate()

func _on_employee_changed(_index: int):
	print("TasksContainer: Regenerating tasks for next employee")
	regenerate_tasks()

func regenerate_tasks():
	# Clear all existing task nodes
	for child in get_children():
		child.queue_free()
	
	# Generate new random tasks
	var available_tasks := []
	for task_data in pregenerated_task_data:
		available_tasks.append(_duplicate_task_data(task_data))
	available_tasks.shuffle()
	for i in range(min(count, available_tasks.size())):
		misery_manager.taskList.append(available_tasks[i])
	
	# Place new task components
	_place_components()
