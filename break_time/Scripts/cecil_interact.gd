extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# Dialogue resource for the Dialogue Manager plugin
const CECIL_DIALOGUE = preload("res://break_time/scripts/cecil.dialogue")

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
		
		# Distance check for circle-like area
		if delta.length() < capsule.radius:
			print("Cecil clicked via manual _input radius check")
			get_viewport().set_input_as_handled()
			start_dialogue()

func start_dialogue():
	print("Starting Cecil dialogue via Plugin")
	DialogueManager.show_example_balloon(CECIL_DIALOGUE, "start")
