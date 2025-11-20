extends VBoxContainer

signal tasks_changed(count: int)

@export var task_slot_scene: PackedScene
@export var task_scene: PackedScene
@export var SLOT_PADDING = 12 # Extra space for comfortable drop target

## Called when the scheduler is added to the scene tree.
## Initializes the task_slots data array and creates all the slot UI elements.
func _ready():
	# Add to group so tasks can find this scheduler
	add_to_group("task_scheduler")

	var schedule = get_parent()
	# Initialize task slots data
	MiseryManager.task_slots.clear()
	for i in range(schedule.target_task_count):
		MiseryManager.task_slots.append({
			"task": null,
			"global_pos": Vector2(0, 0)
		})

	# Initial render - only needed once at startup
	_initialize_slots()
	emit_signal("tasks_changed", get_scheduled_task_count())

	# Listen for employee change to clear slots
	MiseryManager.employee_changed.connect(_on_employee_changed)

## Creates all the slot containers and any tasks that should start in slots.
## This only runs once at startup. After that, tasks move themselves between
## slots via drag and drop without recreating the UI.
func _initialize_slots():
	# Infer task height from the task scene
	var temp_task = task_scene.instantiate()
	var task_height = temp_task.custom_minimum_size.y
	temp_task.queue_free()

	var slot_height = task_height + SLOT_PADDING

	# Create slot containers only
	for i in range(len(MiseryManager.task_slots)):
		var task_slot_instance = task_slot_scene.instantiate()
		task_slot_instance.custom_minimum_size = Vector2(size.x, slot_height)
		task_slot_instance.slot_index = i
		add_child(task_slot_instance)

		# Connect slot signal to scheduler handler
		task_slot_instance.task_dropped_on_slot.connect(_on_task_dropped_on_slot)

		# Update global_pos after adding to tree
		await get_tree().process_frame
		MiseryManager.task_slots[i].global_pos = task_slot_instance.global_position

		# If this slot has a task, create and add the task node
		var task_data = MiseryManager.task_slots[i]["task"]
		if task_data:
			var task_instance = task_scene.instantiate()
			task_instance.set_task_data(task_data)
			task_instance.task_index_in_scheduler = i
			task_instance.add_to_group("task_scheduler") # Assign group BEFORE adding to tree
			task_slot_instance.add_child(task_instance)
			print("Added task '", task_data.title, "' to slot ", i)

## Called when a slot wants to accept a task that was dropped on it.
## The scheduler handles visual reparenting after MiseryManager updates data.
func _on_task_dropped_on_slot(slot: Control, task: Node):
	if not slot or not task:
		push_error("Invalid slot or task in drop handler")
		return

	# Get the old slot index if task came from a slot
	var old_slot_index = task.task_index_in_scheduler

	# Check if target slot has an existing task
	var existing_task_node = null
	for child in slot.get_children():
		if child.is_in_group("task_scheduler") or child.is_in_group("tasks_container"):
			existing_task_node = child
			break

	# Ask MiseryManager to schedule the task (handles swap logic)
	var result = MiseryManager.schedule_task(task.task_data, slot.slot_index, old_slot_index)

	if not result["success"]:
		push_error("Failed to schedule task")
		return

	# Handle visual reparenting
	if result["should_swap"] and existing_task_node:
		# Swap: move existing task to old slot
		var old_slot = get_child(old_slot_index)
		existing_task_node.reparent(old_slot)
		existing_task_node.position = Vector2.ZERO
		existing_task_node.task_index_in_scheduler = old_slot_index
		print("Scheduler: Moved '", existing_task_node.text, "' to slot ", old_slot_index)
	elif existing_task_node and result["displaced_task"] != null:
		# Task from taskList displaced a slot task - return displaced task to tasks_container
		var tasks_container = get_tree().get_first_node_in_group("tasks_container")
		if tasks_container:
			existing_task_node.reparent(tasks_container)
			existing_task_node.position = Vector2.ZERO
			existing_task_node.task_index_in_scheduler = -1
			existing_task_node.remove_from_group("task_scheduler")
			existing_task_node.add_to_group("tasks_container")
			print("Scheduler: Returned '", existing_task_node.text, "' to tasks_container")

	# Move the dragged task to new slot
	task.reparent(slot)

	# Reset position to be relative to new parent
	task.position = Vector2.ZERO

	# Update task's tracking variables and groups
	task.task_index_in_scheduler = slot.slot_index
	task.add_to_group("task_scheduler")
	task.remove_from_group("tasks_container")

	print("Scheduler: Placed task '", task.text, "' into slot ", slot.slot_index)
	emit_signal("tasks_changed", get_scheduled_task_count())


# func _process(delta: float) -> void:
	# print("parent", get_parent().size)

func get_scheduled_task_count():
	var scheduled = 0
	for slot in MiseryManager.task_slots:
		if slot["task"] != null:
			scheduled += 1
	return scheduled

func _on_employee_changed(_index: int):
	print("ScheduledTaskList: Clearing slots for next employee")
	clear_all_slots()

func clear_all_slots():
	# Remove all task nodes from slots
	for i in range(get_child_count()):
		var slot = get_child(i)
		for child in slot.get_children():
			if child.is_in_group("task_scheduler"):
				child.queue_free()

	emit_signal("tasks_changed", 0)
