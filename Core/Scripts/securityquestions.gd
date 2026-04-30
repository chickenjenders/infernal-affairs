extends Control

@onready var password_input: LineEdit = $InputArea/PasswordInput
@onready var submit_button: Button = $InputArea/SubmitButton
@onready var requirements_list: VBoxContainer = $MainLayout/RequirementsList
@onready var invalid_password_label: Label = $invalid_password_label
@onready var popup: Control = $popup
@onready var security_label_panel: Panel = $SecurityLabel
@onready var start_button: Button = $SecurityLabel/Button

var requirements: Array[Node] = []
var current_requirement_index: int = 0
var error_messages = [
  "Not even close.", "Not even close.", "How could you forget?", "This is common knowledge."
]

var boring_music = preload("res://assets/sounds/boring.ogg")
var misery_music = preload("res://assets/sounds/miserymanager.ogg")
var interrupt_sound = preload("res://assets/sounds/interrupt.ogg")

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx(interrupt_sound)

	popup.visible = false
	var _continue_cb = Callable(self , "_on_popup_continue_pressed")
	if popup.has_signal("continue_pressed") and not popup.is_connected("continue_pressed", _continue_cb):
		popup.connect("continue_pressed", _continue_cb)
	security_label_panel.visible = true
	start_button.pressed.connect(_on_start_pressed)

	requirements = requirements_list.get_children()

	# Start with all requirements hidden until the player continues.
	for i in range(requirements.size()):
		requirements[i].visible = false

	submit_button.pressed.connect(_on_submit_pressed)
	password_input.text_submitted.connect(_on_submit_pressed)
	invalid_password_label.visible = false

func _on_start_pressed() -> void:
	security_label_panel.visible = false
	if requirements.size() > 0:
		requirements[0].visible = true
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
		invalid_password_label.visible = false
		# show the final popup with an interrupt SFX
		AudioManager.play_sfx(interrupt_sound)
		popup.visible = true

func _on_popup_continue_pressed() -> void:
	AudioManager.play_music(misery_music)
	# Find and free the password_reset scene as well
	var password_reset = get_tree().root.find_child("password_reset", true, false)
	if password_reset:
		password_reset.queue_free()
	queue_free()
