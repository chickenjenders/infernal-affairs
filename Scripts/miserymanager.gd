extends Node

var currently_dragging_task: Node = null # Track which task is being dragged
var taskList: Array[String] = []
var traitOptions = {
	"IT": ['Low patience', 'Arrogant', 'Hates ambiguity'],
	"Sales": ['Charismatic', 'People-pleaser', 'Hates to be alone'],
	"Demon Resources": ['Overly formal', 'Rule-oriented', 'Hates conflict and confrontation']
}
var department: String = "IT"
var traitsList: Array[String] = []
var task_slots := [
	
]

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
## Returns true if successful, false otherwise
## If target slot has a task and source is also a slot, returns the displaced task name
func schedule_task(task_name: String, slot_index: int, old_slot_index: int = -1) -> Dictionary:
	if slot_index < 0 or slot_index >= task_slots.size():
		push_error("Invalid slot index: ", slot_index)
		return {"success": false, "displaced_task": ""}
	
	# Check if target slot already has a task
	var existing_task = task_slots[slot_index]["task"]
	var should_swap = (existing_task != "" and old_slot_index != -1)
	
	# Clear the old slot if task came from a slot
	if old_slot_index != -1 and old_slot_index < task_slots.size():
		if should_swap:
			# Swap: put the displaced task in the old slot
			task_slots[old_slot_index]["task"] = existing_task
			print("MiseryManager: Swapping '", task_name, "' with '", existing_task, "'")
		else:
			task_slots[old_slot_index]["task"] = ""
	else:
		# Task came from taskList, so remove it from there
		var index = taskList.find(task_name)
		if index != -1:
			taskList.erase(task_name)
			print("MiseryManager: Removed '", task_name, "' from taskList")
		
		# If target slot has a task and source is taskList, return displaced task to taskList
		if existing_task != "":
			taskList.append(existing_task)
			print("MiseryManager: Returned '", existing_task, "' to taskList")
	
	# Update the new slot's data
	task_slots[slot_index]["task"] = task_name
	print("MiseryManager: Scheduled '", task_name, "' to slot ", slot_index)
	return {"success": true, "displaced_task": existing_task, "should_swap": should_swap}

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
		}
	]


@onready var demon_info_node: Node = $MainLayout/DemonInfo

## Helper to detect digits in a string
## Simple task preparation: return task dictionaries with text only
## We'll add proper classification later
