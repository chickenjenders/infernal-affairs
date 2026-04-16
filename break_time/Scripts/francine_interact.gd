extends Area2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var return_button = $ReturnToDesk

# Dialogue resource for the Dialogue Manager plugin
const FRANCINE_DIALOGUE = preload("res://break_time/dialogue/francine.dialogue")

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
	"durian": "This durian is still here.",
	"coffemachine": "This coffee looks old and gross.",
	"fridge": "Where does anyone get food from anyway?",
	"files": "Who is reading these?"
}

func _on_return_to_desk_pressed():
	# Ensure dialogue is cleaned up
	var root = get_tree().root
	if root:
		for child in root.get_children():
			if child is CanvasLayer and (child.name.contains("Balloon") or child.name.contains("Dialogue")):
				child.queue_free()
	
	# Reference the parent scene (BreakTwo/Francine) to handle movement/cleanup
	var parent_scene = get_parent()
	if parent_scene and (parent_scene.name == "BreakOne" or parent_scene.name == "BreakTwo"):
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
		
		# More robust way to find the clicked shape
		var clicked_shape_node = null
		var shape_count = 0
		for child in get_children():
			if child is CollisionShape2D:
				if shape_count == shape_idx:
					clicked_shape_node = child
					break
				shape_count += 1
		
		if clicked_shape_node:
			print("Clicked shape: ", clicked_shape_node.name, " index: ", shape_idx)
			
			if clicked_shape_node.name == "CollisionShape2D": # This is the main one for Francine
				start_dialogue()
			elif ITEM_TEXTS.has(clicked_shape_node.name):
				show_small_text(ITEM_TEXTS[clicked_shape_node.name], clicked_shape_node.global_position)
			elif clicked_shape_node.name == "CollisionShape2D2":
				show_small_text(ITEM_TEXTS["files"], clicked_shape_node.global_position)

func show_small_text(text: String, pos: Vector2):
	if current_label:
		current_label.queue_free()
	
	current_label = label_scene.instantiate()
	get_tree().current_scene.add_child(current_label)
	current_label.text = text
	
	var offset = Vector2(10, -30)
	var screen_width = get_viewport().get_visible_rect().size.x
	
	if pos.x > screen_width * 0.8:
		offset = Vector2(-200, -30)
	
	current_label.global_position = pos + offset
	
	current_label.modulate.a = 0
	var tween = current_label.create_tween()
	tween.tween_property(current_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.0)
	tween.tween_property(current_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(current_label.queue_free)

func _input(event):
	if !visible: return
	pass

func start_dialogue():
	print("Starting Francine dialogue via Plugin")
	self.visible = false
	var balloon_scene = load("res://break_time/dialogue/dialogue_balloon.tscn")
	var balloon = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(FRANCINE_DIALOGUE, "start")
	
	balloon.tree_exited.connect(func(): self.visible = true)
