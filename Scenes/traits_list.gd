@tool
extends FlowContainer

@export_range(0, 20, 1) var count: int = 0:
	set(value):
		count = value

@export var traits_scene: PackedScene

var traitsList: Array[String] = []
var traitType: String = "IT"
var traitOptions = {
	"IT": ['Low patience', 'Arrogant', 'Hates ambiguity'],
	"Sales": ['Charismatic', 'People-pleaser', 'Hates to be alone'],
	"Demon Resources": ['Overly formal', 'Rule-oriented', 'Hates conflict and confrontation']
}

func _ready():
	var traitTitles = traitOptions[traitType]
	traitTitles.shuffle()
	for i in range(count):
		var traitTitle = traitTitles[i]
		traitsList.append(traitTitle)

	_place_components()


func _place_components():
	for traitTitle in traitsList:
		var traits_instance = traits_scene.instantiate()
		traits_instance.set_text(traitTitle)
		add_child(traits_instance)
