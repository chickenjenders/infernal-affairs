extends Node

var currently_dragging_task: Node = null # Track which task is being dragged
var taskList := []
var traitOptions = {
	"IT": ['Low patience', 'Arrogant', 'Hates ambiguity'],
	"Sales": ['Charismatic', 'People-pleaser', 'Hates to be alone'],
	"Demon Resources": ['Overly formal', 'Rule-oriented', 'Hates conflict and confrontation']
}
var department: String = "IT"
var traitsList: Array[String] = []
var task_slots := [
	
]
var total_misery_score: int = 0

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
	_update_total_score()
	return {"success": true, "displaced_task": existing_task, "should_swap": should_swap}

func _update_total_score():
	total_misery_score = 0
	for slot in task_slots:
		if slot["task"] != null:
			total_misery_score += slot["task"].misery_score
	print("MiseryManager: Total score updated to: ", total_misery_score)

func get_total_misery_score() -> int:
	return total_misery_score

# Employee list - demons / employees we can load into the UI
var employees: Array = [
		{
			"name": "Greg Groves",
			"department": "IT",
			"blood_type": "A+",
			"mbti": "ISTJ",
			"sign": "Capricorn",
			"cod": "Fell asleep while driving due to not sleeping for 3 days so he could finish a work project",
			"sentence": "Sold soul for middle management position",
			"traits": ["Low patience", "Arrogant", "Hates ambiguity"],
			"portrait": "res://Assets/portraits/greg.png",
		},
		{
			"name": "Sheila McCarthy",
			"department": "Sales",
			"blood_type": "O-",
			"mbti": "ENFP",
			"sign": "Aries",
			"cod": "“Accidentally” fell off a mountain during a hike",
			"sentence": "Traded soul for 20 years with her ex-husband’s fortune",
			"traits": ["Charismatic", "People-pleaser", "Hates to be alone"],
			"portrait": "res://Assets/portraits/sheila.PNG",
		},
		{
			"name": "Raymond Dacosta",
			"department": "Demon Resources",
			"blood_type": "B+",
			"mbti": "ENFJ",
			"sign": "Libra",
			"cod": "Heart failure after drinking a red bull everyday for 40 years",
			"sentence": "Literally not a soul on earth liked this man",
			"traits": ["Overly formal", "Rule-oriented", "Hates conflict and confrontation"],
			"portrait": "res://Assets/portraits/raymond.PNG",
		}
	]
