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

var boring_music = preload("res://assets/sounds/boring.wav")
var interrupt_sound = preload("res://assets/sounds/interrupt.wav")

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx(interrupt_sound)
	popup.visible = true
	
	var popup_btn = popup.get_node("SubmitButton")
	if popup_btn.is_connected("pressed", Callable(popup, "_on_submit_button_pressed")):
		popup_btn.disconnect("pressed", Callable(popup, "_on_submit_button_pressed"))
	popup_btn.pressed.connect(_on_popup_closed)
	requirements = requirements_list.get_children()

	# Hide all except the first one
	for i in range(requirements.size()):
		requirements[i].visible = (i == 0)
	
	submit_button.pressed.connect(_on_submit_pressed)
	password_input.text_submitted.connect(_on_submit_pressed)
	invalid_password_label.visible = false
	
	# Ensure input focus when scene loads

func _on_popup_closed() -> void:
	popup.visible = false
	AudioManager.play_music(boring_music)
	password_input.grab_focus()

func _on_submit_pressed(_text: String = "") -> void:
	password_input.text = ""
	invalid_password_label.visible = true
	if current_requirement_index < requirements.size() - 1:
		current_requirement_index += 1
		requirements[current_requirement_index].visible = true
		invalid_password_label.text = error_messages[current_requirement_index]
	else:
		var root = get_tree().root
		var nodes_to_remove = []
	
		for child in root.get_children():
			var node_name = child.name.to_lower()
			if node_name.contains("password") or node_name.contains("security"):
				nodes_to_remove.append(child)
		for node in nodes_to_remove:
			node.queue_free()
