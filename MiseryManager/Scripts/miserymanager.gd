class_name MiseryManager
extends Node

signal employee_changed(index: int)

var currently_dragging_task: Node = null # Track which task is being dragged
var taskList := []
# Data loaded from ShiftManager now
# @export_file("*.json") var trait_options_file: String = "res://Configs/trait_options.json"
# var trait_options: Dictionary = {}
# var task_templates: Array = []
# var trait_definitions: Dictionary = {}

func _ready():
	# _load_trait_options()
    # Sync with ShiftManager state if needed
    pass

# func _load_trait_options(): ... (Removed)

func get_traits_for_department(dept_name: String) -> Array:
	return ShiftManager.get_trait_options(dept_name)

var department: String = "IT"
var traitsList: Array[String] = []
var task_slots := [
	
]
var current_employee_score: int = 0
var total_game_score: int = 0
var total_points_possible: int = 500

func _enter_tree():
	add_to_group("misery_manager")


## Called when a task starts being dragged
func start_dragging_task(task: Node):
	currently_dragging_task = task
	print("MiseryManager: Started dragging '", task.text, "'")

## Called when a task stops being dragged
func stop_dragging_task(task: Node):
	if currently_dragging_task == task:
		currently_dragging_task = null
		print("MiseryManager: Stopped dragging '", task.text, "'")

## Schedules a task into a specific slot
## Returns a dict containing the outcome plus any displaced task data
func schedule_task(task_data, slot_index: int, old_slot_index: int = -1) -> Dictionary:
	if slot_index < 0 or slot_index >= task_slots.size():
		push_error("Invalid slot index: ", slot_index)
		return {"success": false, "displaced_task": null}

	# Check if target slot already has a task
	var existing_task = task_slots[slot_index]["task"]
	var should_swap = (existing_task != null and old_slot_index != -1)

	# Clear the old slot if task came from a slot
	if old_slot_index != -1 and old_slot_index < task_slots.size():
		if should_swap:
			# Swap: put the displaced task in the old slot
			task_slots[old_slot_index]["task"] = existing_task
			print("MiseryManager: Swapping '", task_data.title, "' with '", existing_task.title if existing_task else "", "'")
		else:
			task_slots[old_slot_index]["task"] = null
	else:
		# Task came from taskList, so remove it from there
		if task_data in taskList:
			taskList.erase(task_data)
			print("MiseryManager: Removed '", task_data.title, "' from taskList")
		
		# If target slot has a task and source is taskList, return displaced task to taskList
		if existing_task != null:
			taskList.append(existing_task)
			print("MiseryManager: Returned '", existing_task.title, "' to taskList")

	# Update the new slot's data
	task_slots[slot_index]["task"] = task_data
	print("MiseryManager: Scheduled '", task_data.title, "' to slot ", slot_index)
	_update_current_score()
	return {"success": true, "displaced_task": existing_task, "should_swap": should_swap}

func _update_current_score():
	current_employee_score = 0
	for slot in task_slots:
		if slot["task"] != null:
			current_employee_score += slot["task"].misery_score
	print("MiseryManager: Current employee score updated to: ", current_employee_score)

func get_current_employee_score() -> int:
	return current_employee_score

func get_total_game_score() -> int:
	return ShiftManager.total_game_score

func submit_employee_score():
	ShiftManager.submit_score(current_employee_score)

func is_last_employee() -> bool:
	return ShiftManager.current_employee_index >= ShiftManager.employees.size() - 1

func advance_to_next_employee():
	ShiftManager.advance_to_next_employee()
	print("MiseryManager: Advanced to employee ", ShiftManager.current_employee_index)
	employee_changed.emit(ShiftManager.current_employee_index)
	
	if ShiftManager.current_employee_index == 2:
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/password_reset.tscn")

func reset_for_next_employee():
	# Clear all task slots
	for slot in task_slots:
		slot["task"] = null
	
	# Clear task list
	taskList.clear()
	
	# Reset current employee score
	current_employee_score = 0
	
	print("MiseryManager: Reset for next employee")

# Employee list - loaded from ShiftManager
# var employees: Array = []
