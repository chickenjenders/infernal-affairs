extends Node

signal shift_changed(shift_index)
signal employee_changed(employee_data)
signal shift_completed

var current_shift_index: int = 1
var current_employee_index: int = 0 # Global index across all employees
var employees_per_shift: int = 5 # Example: 5 employees per shift

var trait_options_file: String = "res://configs/trait_options.json"

# Data containers
var employees: Array = []
var trait_options: Dictionary = {}
var task_templates: Array = []
var trait_definitions: Dictionary = {}

# Tracking state
var seen_employees: Dictionary = {} # employee_id -> bool
var current_employee_score: int = 0
var total_game_score: int = 0

func _ready():
	_load_data()
	# Initialize first shift if needed
	
func _load_data():
	if not FileAccess.file_exists(trait_options_file):
		push_error("Trait options file not found: " + trait_options_file)
		return
		
	var file = FileAccess.open(trait_options_file, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			trait_options = data.get("traits", {})
			employees = data.get("employees", [])
			task_templates = data.get("task_templates", [])
			trait_definitions = data.get("trait_definitions", {})
			print("ShiftManager: Data loaded. Total employees: ", employees.size())
		else:
			push_error("Unexpected data structure in trait_options.json")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())

func get_current_employee_data():
	if current_employee_index < employees.size():
		var emp = employees[current_employee_index]
		# Mark as seen if not already
		if not seen_employees.has(emp.get("id", current_employee_index)):
			seen_employees[emp.get("id", current_employee_index)] = true
		return emp
	return null

func advance_to_next_employee():
	current_employee_index += 1
	if current_employee_index >= employees.size():
		print("ShiftManager: All employees processed.")
		# Handle end of game or loops
	else:
		emit_signal("employee_changed", get_current_employee_data())
		# Check if we've moved to a new shift
		if is_shift_complete():
			current_shift_index += 1
			emit_signal("shift_changed", current_shift_index)

# Helper to check if current employee is the last one in the current "shift" logic
# For now, assumes all employees in one big list; adapt logic if shifts are defined differently
func is_shift_complete() -> bool:
	# Example logic: shift ends after N employees
	return (current_employee_index + 1) % employees_per_shift == 0

func submit_score(score: int):
	current_employee_score = score
	total_game_score += score
	print("ShiftManager: Score submitted. Current: ", current_employee_score, " Total: ", total_game_score)

func get_trait_options(department: String) -> Array:
	if trait_options.has(department):
		return trait_options[department]
	return []
