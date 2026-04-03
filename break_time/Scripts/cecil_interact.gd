extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# Twine-compatible dictionary format
var cecil_dialogue = {
	"start": {
		"text": "Hello, there. I'm Cecil. You look new around here.",
		"choices": [
			{"text": "I am. What do you do here?", "next": "ask_about_job"},
			{"text": "Just looking around. What's with the cubicles?", "next": "ask_about_cubicles"}
		]
	},
	"ask_about_job": {
		"text": "I manage misery. It's a growth industry, truly. We maximize despair through efficiency. Would you like to see my spreadsheet?",
		"choices": [
			{"text": "Sounds fascinating. Let's see it.", "next": "show_spreadsheet"},
			{"text": "No, thanks. I've seen enough spreadsheets.", "next": "end_conversation"}
		]
	},
	"ask_about_cubicles": {
		"text": "They provide isolation. Perfect for focusing on one's regrets. It's a cozy circle of hell.",
		"choices": [
			{"text": "Regrets, huh? Sounds about right.", "next": "end_conversation"}
		]
	},
	"show_spreadsheet": {
		"text": "It's beautifully bleak. Look at those negative growth projections. It brings a tear to one's eye.",
		"choices": [
			{"text": "Well, back to work.", "next": "end_conversation"}
		]
	},
	"end_conversation": {
		"text": "Well, enjoy your stay in Infernal Affairs. Don't let the paperwork bite.",
		"choices": [] # Empty choices ends conversation
	}
}

func _ready():
	input_pickable = true
	# Ensure the collision shape is active if it was hidden
	collision.visible = true
	# Scale collision to match sprite size better if needed
	z_index = 10

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Cecil clicked directly via _input_event")
		get_viewport().set_input_as_handled()
		start_dialogue()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_mouse_pos = get_local_mouse_position()
		var shape_pos = collision.position
		var delta = local_mouse_pos - shape_pos
		var capsule = collision.shape as CapsuleShape2D
		
		# Rough distance check for circle-like area if capsule detection is tricky
		if delta.length() < capsule.radius:
			print("Cecil clicked via manual _input radius check")
			start_dialogue()

func start_dialogue():
	print("Starting Cecil dialogue")
	# Reference to global autoload or locally spawned dialogue
	if Global.has_method("start_dialogue"):
		Global.start_dialogue(cecil_dialogue, "start")
	else:
		# Fallback if Global isn't set up yet
		push_warning("Global.start_dialogue not found")
