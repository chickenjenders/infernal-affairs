extends Node

@export var items: Dictionary = {
	"durian": "A spiky durian. It smells... interesting.",
	"coffemachine": "The office coffee machine. It screams when it grinds.",
	"fridge": "The breakroom fridge. Contains mostly labeled souls."
}

var current_label: Label = null
var label_scene = preload("res://common/ui/interaction_label.tscn")

func _ready():
	var parent = get_parent()
	if parent is Area2D:
		parent.input_pickable = true
		parent.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var parent = get_parent()
		# Find the shape name by index
		var shape_node = parent.get_child(shape_idx)
		if shape_node:
			var shape_name = shape_node.name
			if items.has(shape_name):
				show_text(items[shape_name], shape_node.global_position)

func show_text(text: String, pos: Vector2):
	if current_label:
		current_label.queue_free()
	
	current_label = label_scene.instantiate()
	get_tree().current_scene.add_child(current_label)
	current_label.text = text
	
	# Position near the object
	current_label.global_position = pos + Vector2(20, -20)
	
	# Auto-fade out or remove
	var tween = current_label.create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(current_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(current_label.queue_free)
