extends Control

signal ready_flag_changed(is_ready: bool)

@export var target_task_count: int = 0
@export var ready_color: Color = Color(0.3, 0.8, 0.5, 1)

@onready var submit_button: Button = $SubmitButton
@onready var scheduled_list: Node = $ScheduledTaskList

var _default_modulate: Color
var ready_flag: bool = false

func _ready():
	_default_modulate = submit_button.modulate
	ready_flag_changed.connect(_apply_ready_color)
	submit_button.submit_requested.connect(_on_submit_requested)
	if target_task_count <= 0:
		target_task_count = max(scheduled_list.count, 1)
	scheduled_list.tasks_changed.connect(_on_tasks_changed)
	_update_ready_state(scheduled_list.get_scheduled_task_count())
	_apply_ready_color(ready_flag)

func _on_tasks_changed(task_count: int):
	_update_ready_state(task_count)

func _update_ready_state(current_count: int):
	var should_be_ready = current_count >= target_task_count
	if ready_flag == should_be_ready:
		return
	ready_flag = should_be_ready
	ready_flag_changed.emit(ready_flag)

func is_ready() -> bool:
	return ready_flag

func get_current_score() -> int:
	return MiseryManager.get_current_employee_score()

func _apply_ready_color(ready_state: bool):
	submit_button.modulate = ready_color if ready_state else _default_modulate

func _on_submit_requested():
	if not is_ready():
		return
	
	# Submit score
	MiseryManager.submit_employee_score()
	
	# Check if this was the last employee
	if MiseryManager.is_last_employee():
		# Last employee - go to Misery Report
		get_tree().change_scene_to_file("res://Scenes/MiseryReport.tscn")
	else:
		# More employees to go - reset and load next
		MiseryManager.reset_for_next_employee()
		MiseryManager.advance_to_next_employee()
