extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var return_button = $ReturnToDesk

# Dialogue resource for the Dialogue Manager plugin
const CECIL_DIALOGUE = preload("res://break_time/dialogue/cecil.dialogue")

func _ready():
	input_pickable = true
	# Ensure the collision shape is active if it was hidden
	collision.visible = true
	# Scale collision to match sprite size better if needed
	z_index = 10
	
	# Connect the return button signal
	if return_button:
		return_button.pressed.connect(_on_return_to_desk_pressed)

var current_label: Label = null
var label_scene = preload("res://common/ui/interaction_label.tscn")

const ITEM_TEXTS = {
	"durian": "A spiky durian. It smells... interesting.",
	"coffemachine": "Decaf only...great.",
	"fridge": "A fridge with a time limit.",
	"files": "A ton of random old files."
}

func _on_return_to_desk_pressed():
	# Ensure dialogue is cleaned up
	var root = get_tree().root
	if root:
		for child in root.get_children():
			if child is CanvasLayer and (child.name.contains("Balloon") or child.name.contains("Dialogue")):
				child.queue_free()
	
	# Reference the parent scene (BreakOne/Cubicles) to handle movement/cleanup
	var parent_scene = get_parent()
	if parent_scene and parent_scene.name == "BreakOne":
		if parent_scene.get_parent() and parent_scene.get_parent().name == "Desktop":
			var desktop = parent_scene.get_parent()
			var misery_manager_scene = load("res://misery_manager/scenes/misery_manager.tscn")
			var misery_manager_instance = misery_manager_scene.instantiate()
			desktop.add_child(misery_manager_instance)
			parent_scene.queue_free()
		else:
			get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")
	else:
		# Standalone fallback
		get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")

func _input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		
		# Find the collision shape node to see what we actually clicked
		# This is more reliable than hardcoding indices if the scene structure changed
		var shapes = []
		for child in get_children():
			if child is CollisionShape2D:
				shapes.append(child)
		
		if shape_idx < shapes.size():
			var shape_node = shapes[shape_idx]
			print("Clicked shape: ", shape_node.name, " index: ", shape_idx)
			
			if shape_node.name == "CollisionShape2D": # This is the main one for Cecil
				start_dialogue()
			elif ITEM_TEXTS.has(shape_node.name):
				show_small_text(ITEM_TEXTS[shape_node.name], shape_node.global_position)
			elif shape_node.name == "CollisionShape2D2":
				show_small_text(ITEM_TEXTS["files"], shape_node.global_position)

func show_small_text(text: String, pos: Vector2):
	if current_label:
		current_label.queue_free()
	
	current_label = label_scene.instantiate()
	get_tree().current_scene.add_child(current_label)
	current_label.text = text
	
	# Determine offset based on position to avoid going off-screen
	var offset = Vector2(10, -30)
	var screen_width = get_viewport().get_visible_rect().size.x
	
	# If the object is on the right side of the screen, move the text to the left
	if pos.x > screen_width * 0.8:
		# Use a larger negative X offset to move the label to the left of the fridge/mouse
		offset = Vector2(-200, -30)
	
	current_label.global_position = pos + offset
	
	# Small tween to fade in/out
	current_label.modulate.a = 0
	var tween = current_label.create_tween()
	tween.tween_property(current_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property(current_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(current_label.queue_free)

func _input(event):
	if !visible: return
	# Manual radius check disabled in favor of _input_event shape_idx
	pass

func start_dialogue():
	print("Starting Cecil dialogue via Plugin")
	self.visible = false
	var balloon_scene = load("res://break_time/dialogue/dialogue_balloon.tscn")
	var balloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(CECIL_DIALOGUE, "start")
	
	# Connect to the tree_exited signal of the balloon to know when dialogue ends
	balloon.tree_exited.connect(func(): self.visible = true)
