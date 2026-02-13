extends Control

signal ready_flag_changed(is_ready: bool)

@export var target_task_count: int = 0
@export var ready_color: Color = Color(0.3, 0.8, 0.5, 1)

@onready var submit_button: Button = $SubmitButton
@onready var scheduled_list: Node = $ScheduledTaskList
@export var misery_manager: Node

var _default_modulate: Color
var ready_flag: bool = false

func _ready():
	_default_modulate = submit_button.modulate
	ready_flag_changed.connect(_apply_ready_color)
	submit_button.submit_requested.connect(_on_submit_requested)
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return

	scheduled_list.tasks_changed.connect(_on_tasks_changed)
	_update_ready_state(scheduled_list.get_scheduled_task_count())
	_apply_ready_color(ready_flag)

func _on_tasks_changed(task_count: int):
	print("Schedule: tasks_changed signal received with count: ", task_count)
	_update_ready_state(task_count)

func _update_ready_state(current_count: int):
	var should_be_ready = current_count >= misery_manager.task_slots.size()
	print("Schedule: _update_ready_state - current_count: ", current_count, ", task_slots.size: ", misery_manager.task_slots.size(), ", should_be_ready: ", should_be_ready, ", ready_flag: ", ready_flag)
	if ready_flag == should_be_ready:
		print("Schedule: Early return - no state change needed")
		return
	ready_flag = should_be_ready
	print("Schedule: Emitting ready_flag_changed with: ", ready_flag)
	ready_flag_changed.emit(ready_flag)

func get_current_score() -> int:
	return misery_manager.get_current_employee_score()

func _apply_ready_color(ready_state: bool):
	print("Schedule: _apply_ready_color called with ready_state: ", ready_state)
	print("Schedule: Setting modulate to: ", ready_color if ready_state else _default_modulate)
	submit_button.modulate = ready_color if ready_state else _default_modulate

func _on_submit_requested():
	if not ready_flag:
		return

	# Submit score
	misery_manager.submit_employee_score()

	var is_last_in_game = misery_manager.is_last_employee()
	var is_last_in_shift = misery_manager.is_shift_complete()

	if is_last_in_game:
		# Absolute last employee - show the misery report popup (now a hidden node)
		var report_node = misery_manager.get_node_or_null("MiseryReport")
		if report_node:
			report_node.visible = true
			if report_node.has_method("update_report"):
				report_node.update_report()
		else:
			# Fallback if node not found as child
			report_node = misery_manager.get_parent().get_node_or_null("MiseryReport")
			if report_node:
				report_node.visible = true
				if report_node.has_method("update_report"):
					report_node.update_report()
			else:
				# Fallback if node completely missing: instantiate it
				var report_scene = load("res://core/scenes/MiseryReport.tscn")
				var report_instance = report_scene.instantiate()
				if "misery_manager" in report_instance:
					report_instance.misery_manager = misery_manager
				misery_manager.add_child(report_instance)
		
		print("Schedule: Game complete, showing Misery Report")
	elif is_last_in_shift:
		# Shift complete - advance index for when we return, then go to Break scene
		misery_manager.advance_to_next_employee()
		
		var break_scene = load("res://break_time/scenes/cubicles.tscn")
		var break_instance = break_scene.instantiate()
		var mm_root = misery_manager.get_parent()
		mm_root.get_parent().add_child(break_instance)
		mm_root.queue_free()
	else:
		# More employees in the current shift - reset and load next
		misery_manager.reset_for_next_employee()
		misery_manager.advance_to_next_employee()
