extends Control

signal task_dropped_on_slot(slot: Control, task: Node) # Signal to notify scheduler

var slot_index: int = -1 # Store the index associated with MiseryManager.task_slots
@export var misery_manager: MiseryManager

func _ready():
	# Enable mouse detection for this slot
	mouse_filter = Control.MOUSE_FILTER_PASS

## Called every frame to check for mouse release events over this slot.
## If a task is being dragged and mouse is released over this slot,
## the slot signals the scheduler to handle task placement.
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			# Check if mouse is over this slot and a task is being dragged
			if _is_mouse_over() and misery_manager and misery_manager.currently_dragging_task:
				var task = misery_manager.currently_dragging_task
				print("Slot ", slot_index, " requesting to accept task '", task.text, "'")
				# Signal the scheduler to handle this
				task_dropped_on_slot.emit(self, task)

## Checks if the mouse is currently within this slot's bounds.
func _is_mouse_over() -> bool:
	var mouse_pos = get_global_mouse_position()
	var rect = Rect2(global_position, size)
	return rect.has_point(mouse_pos)
