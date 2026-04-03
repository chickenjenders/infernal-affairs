extends CanvasLayer

@onready var dialogue_label = $Panel/VBoxContainer/DialogueLabel
@onready var choices_container = $Panel/VBoxContainer/ChoicesContainer
@onready var next_prompt = $Panel/NextPrompt

var current_text = ""
var text_segments = []
var segment_index = 0
var current_choices = []
var is_waiting_for_input = false

signal choice_selected(index)
signal dialogue_complete

func _ready():
	visible = false

func setup(text: String, choices: Array):
	visible = true
	# Reset state
	next_prompt.text = "Press Enter to continue"
	# Split by sentences (handling ". " separator)
	text_segments = text.split(". ", false)
	segment_index = 0
	current_choices = choices
	show_next_segment()

func _input(event):
	if visible and is_waiting_for_input and event.is_action_pressed("ui_accept"): # Enter key
		if segment_index > text_segments.size():
			dialogue_complete.emit()
			visible = false
		else:
			show_next_segment()

func show_next_segment():
	if segment_index < text_segments.size():
		var segment = text_segments[segment_index].strip_edges()
		if not segment.ends_with("."):
			segment += "."
		dialogue_label.text = segment
		segment_index += 1
		is_waiting_for_input = true
		next_prompt.visible = true
		choices_container.visible = false
	else:
		display_choices()

func display_choices():
	is_waiting_for_input = false
	next_prompt.visible = false
	
	for child in choices_container.get_children():
		child.queue_free()
	
	if current_choices.size() > 0:
		choices_container.visible = true
		for i in range(current_choices.size()):
			var btn = Button.new()
			btn.text = current_choices[i]["text"]
			btn.pressed.connect(_on_choice_pressed.bind(i))
			choices_container.add_child(btn)
	else:
		# No choices, showing end message with "Enter to close"
		next_prompt.text = "Press Enter to end conversation"
		next_prompt.visible = true
		is_waiting_for_input = true
		segment_index = text_segments.size() + 1 # Flag to end

func _on_choice_pressed(index):
	choice_selected.emit(index)
