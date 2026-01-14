extends Control

@onready var password_input: LineEdit = $InputArea/PasswordInput
@onready var submit_button: Button = $InputArea/SubmitButton
@onready var requirements_list: VBoxContainer = $MainLayout/RequirementsList
@onready var invalid_password_label: Label = $invalid_password_label
@onready var popup: Control = $popup

var requirements: Array[Node] = []
var current_requirement_index: int = 0
var error_messages = [
  "Not even close.", "Not even close.", "How could you forget?", "This is common knowledge."
]
func _ready() -> void:
	requirements = requirements_list.get_children()
	
	# Hide all except the first one
	for i in range(requirements.size()):
		requirements[i].visible = (i == 0)
	
	submit_button.pressed.connect(_on_submit_pressed)
	password_input.text_submitted.connect(_on_submit_pressed)
	invalid_password_label.visible = false

func _on_submit_pressed(_text: String = "") -> void:
	password_input.text = ""
	invalid_password_label.visible = true
	if current_requirement_index < requirements.size() - 1:
		current_requirement_index += 1
		requirements[current_requirement_index].visible = true
		invalid_password_label.text = error_messages[current_requirement_index]
	else:
		popup.visible = true
