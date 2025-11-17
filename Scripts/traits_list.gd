@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var traits_scene: PackedScene


func _ready():
	var traitTitles = MiseryManager.traitOptions[MiseryManager.department]
	traitTitles.shuffle()
	for i in range(count):
		var traitTitle = traitTitles[i]
		MiseryManager.traitsList.append(traitTitle)

	_place_components()


func _place_components():
	for traitTitle in MiseryManager.traitsList:
		var traits_instance = traits_scene.instantiate()
		traits_instance.set_text(traitTitle)
		add_child(traits_instance)
