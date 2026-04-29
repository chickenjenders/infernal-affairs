import re

with open('core/scripts/securityquestions.gd', 'r') as f:
    content = f.read()

# We need to map:
# - start: show SecurityLabel, hide popup
# - SecurityLabel's Button pressed: hide SecurityLabel, start music, grab focus
# - ends: show popup, and its submit button queue_frees the scene (which goes back to misery manager naturally if we don't interfere, or wait! misery manager's children aren't removed, they instantiate this in front). Wait, in popup.gd it removes security_questions AND password_reset from root!

replacement = """extends Control

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

var boring_music = preload("res://assets/sounds/boring.wav")
var interrupt_sound = preload("res://assets/sounds/interrupt.wav")

func _ready() -> void:
\tAudioManager.stop_music()
\tAudioManager.play_sfx(interrupt_sound)
\t
\tpupup.visible = false
\tsecurity_label_panel.visible = true
\tstart_button.pressed.connect(_on_start_pressed)

\trequirements = requirements_list.get_children()

\t# Hide all except the first one
\tfor i in range(requirements.size()):
\t\trequirements[i].visible = (i == 0)

\tsubmit_button.pressed.connect(_on_submit_pressed)
\tpassword_input.text_submitted.connect(_on_submit_pressed)
\tinvalid_password_label.visible = false

func _on_start_pressed() -> void:
\tsecurity_label_panel.visible = false
\tAudioManager.play_music(boring_music)
\tpassword_input.grab_focus()

func _on_submit_pressed(_text: String = "") -> void:
\tpassword_input.text = ""
\tinvalid_password_label.visible = true
\tif current_requirement_index < requirements.size() - 1:
\t\tcurrent_requirement_index += 1
\t\trequirements[current_requirement_index].visible = true
\t\tinvalid_password_label.text = error_messages[current_requirement_index]
\telse:
\t\tinvalid_password_label.visible = false
\t\tpopup.visible = true
"""

# Let's completely replace the whole thing since it's short.
import sys
with open('core/scripts/securityquestions.gd', 'w') as f:
    f.write(replacement.replace('pupup', 'popup'))

