extends Label

var dragging = false
var drag_offset = Vector2()

func _ready():
	# Make sure the label can receive mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				dragging = true
				MiseryManager.draggingTask = text
				drag_offset = get_global_mouse_position() - global_position
				print("Started dragging: ", text)
			else:
				dragging = false
				print("Stopped dragging: ", text)
				var slot = snap_to_nearest_slot()
				# Update through MiseryManager to trigger signal
				if slot:
					MiseryManager.update_task_slot(slot.slot_index, text)
					# Delete this task - it will be recreated in the slot by refresh_ui()
					queue_free()
				MiseryManager.draggingTask = ""
			
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = get_global_mouse_position() - drag_offset

func snap_to_nearest_slot():
	# Find the task scheduler in the scene tree
	var task_scheduler = get_tree().get_first_node_in_group("task_scheduler")
	
	if not task_scheduler:
		print("No task scheduler found")
		return null
	
	# Get all task slot children
	var slots = task_scheduler.get_children()
	if slots.is_empty():
		print("No task slots found")
		return null
	
	# Find the nearest slot
	var nearest_slot = null
	var min_distance = INF
	var task_center = global_position + size / 2
	
	for slot in slots:
		if slot is Control:
			var slot_center = slot.global_position + slot.size / 2
			var distance = task_center.distance_to(slot_center)
			
			if distance < min_distance:
				min_distance = distance
				nearest_slot = slot
	
	# Snap to the nearest slot
	if nearest_slot:
		# Center the task within the slot
		global_position = nearest_slot.global_position + (nearest_slot.size - size) / 2
		print("Snapped to slot at: ", global_position)
	
	return nearest_slot
