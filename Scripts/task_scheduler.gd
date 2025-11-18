extends VBoxContainer

@export var task_slot_scene: PackedScene
@export var task_scene: PackedScene
@export_range(0, 20, 1) var count: int = 0

## Called when the scheduler is added to the scene tree.
## Initializes the task_slots data array and creates all the slot UI elements.
func _ready():
	# Add to group so tasks can find this scheduler
	add_to_group("task_scheduler")
	
	# Initialize task slots data
	for i in range(count):
		MiseryManager.task_slots.append({
			"task": "",
			"global_pos": Vector2(0, 0)
		})
	
	# Initial render - only needed once at startup
	_initialize_slots()

## Creates all the slot containers and any tasks that should start in slots.
## This only runs once at startup. After that, tasks move themselves between
## slots via drag and drop without recreating the UI.
func _initialize_slots():
	var separation = get_theme_constant("separation")
	var slot_height = size.y / count - separation
	slot_height = max(slot_height, 10) # prevent negative/zero
	
	# Create slot containers only
	for i in range(len(MiseryManager.task_slots)):
		var task_slot_instance = task_slot_scene.instantiate()
		task_slot_instance.custom_minimum_size = Vector2(size.x, slot_height)
		task_slot_instance.slot_index = i
		add_child(task_slot_instance)
		
		# Update global_pos after adding to tree
		await get_tree().process_frame
		MiseryManager.task_slots[i].global_pos = task_slot_instance.global_position
		
		# If this slot has a task, create and add the task node
		var task_name = MiseryManager.task_slots[i]["task"]
		if task_name != "":
			var task_instance = task_scene.instantiate()
			task_instance.set_text(task_name)
			task_instance.task_index_in_scheduler = i
			task_instance.add_to_group("task_scheduler") # Assign group BEFORE adding to tree
			task_slot_instance.add_child(task_instance)
			print("Added task '", task_name, "' to slot ", i)

	
# func _process(delta: float) -> void:
	# print("parent", get_parent().size)
