extends Label

var dragging = false
var drag_offset = Vector2()
var task_index_in_scheduler: int = -1 # -1 if in taskList, slot index if in task_slots
var original_position: Vector2 # Store position before dragging
var original_parent: Node # Store parent before dragging
var task_data
@export var misery_manager: MiseryManager

func set_task_data(new_data) -> void:
	task_data = new_data
	if task_data:
		text = task_data.title

## Called when the task node is added to the scene tree.
## Sets up the task to receive mouse input for drag and drop functionality.
func _ready():
	# Make sure the label can receive mouse events
	mouse_filter = Control.MOUSE_FILTER_STOP

## Handles all mouse input for the task, including drag and drop.
## When the user clicks and drags a task, it can be moved between the task list
## and task scheduler slots. The task physically moves (reparents) rather than
## being deleted and recreated.
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				# Step 1: Verify task has a group assigned
				if not is_in_group("tasks_container") and not is_in_group("task_scheduler"):
					push_error("Task '", text, "' does not have a location group assigned!")
					return
				
				# Store original position and parent before dragging
				original_position = position
				original_parent = get_parent()
				
				# Store which slot this task came from (if any)
				if is_in_group("task_scheduler"):
					if original_parent:
						task_index_in_scheduler = original_parent.slot_index
						print("Task came from slot index: ", task_index_in_scheduler)
				
				# Notify MiseryManager that dragging started
				if not misery_manager:
					push_error("MiseryManager not found in scene tree")
					return
				misery_manager.start_dragging_task(self)
				
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				print("Started dragging: ", text)

## Monitor for mouse release globally since the task might be dragged away from its visual position
func _input(event):
	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			dragging = false
			print("Stopped dragging: ", text)
			
			# Wait a frame to let slots process the mouse release first
			await get_tree().process_frame
			
			# Notify MiseryManager that dragging stopped
			if not misery_manager:
				push_error("MiseryManager not found in scene tree")
				return
			misery_manager.stop_dragging_task(self)
			
			# If still not reparented (no slot accepted), handle fallback
			_handle_drop_fallback()
	elif dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - drag_offset

## Handles the case where no slot accepted the task on drop.
## Returns the task to its original position.
func _handle_drop_fallback():
	# Check if we're still in the original parent (no slot accepted)
	if get_parent() == original_parent:
		# Return to original position
		position = original_position
		print("Task '", text, "' returned to original position")
