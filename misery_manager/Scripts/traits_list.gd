@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var traits_scene: PackedScene
@export var misery_manager: Node


func _ready():
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	var trait_titles = misery_manager.get_traits_for_department(misery_manager.department)
	if trait_titles.is_empty():
		return
	
	trait_titles.shuffle()
	var actual_count = min(count, trait_titles.size())
	for i in range(actual_count):
		var trait_title = trait_titles[i]
		misery_manager.traits_list.append(trait_title)

	_place_components()


func _place_components():
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	for trait_title in misery_manager.traits_list:
		var traits_instance = traits_scene.instantiate()
		traits_instance.set_text(trait_title)
		add_child(traits_instance)

## Set traits from an array and re-render the list
func set_traits(trait_array: Array):
	# Clear existing children
	for child in get_children():
		child.queue_free()
	
	# Add each trait
	for trait_text in trait_array:
		var traits_instance = traits_scene.instantiate()
		traits_instance.set_text(trait_text)
		add_child(traits_instance)
