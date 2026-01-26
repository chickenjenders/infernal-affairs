extends Control

@export var demon_name: String = "Greg Groves"
@export var department: String = "IT"
@export var blood_type: String = "A+"
@export var mbti: String = "ISTJ"
@export var zodiac_sign: String = "Capricorn"
@export var cod: String = "Fell asleep while driving due to not sleeping for 3 days so he could finish a work project"
@export var sentence: String = "Sold soul for middle management position"
@export var traits: Array = ["Low patience", "Arrogant", "Hates ambiguity"]
@export var portrait_texture: Texture2D

@export var trait_scene: PackedScene = preload("res://MiseryManager/Scenes/traits.tscn")

@onready var name_lbl: Label = $Name
@onready var dept_lbl: Label = $Dept
@onready var blood_lbl: Label = $BloodType
@onready var mbti_lbl: Label = $MBTI
@onready var sign_lbl: Label = $Sign
@onready var cod_lbl: Label = $COD
@onready var sentence_lbl: Label = $Sentence
@onready var traits_list: Node = $Traits/TraitsList
@onready var portrait_rect: TextureRect = $Portrait

func _ready():
	# Connect to MiseryManager to know when employee changes
	MiseryManager.employee_changed.connect(_on_employee_changed)
	
	# Load initial employee
	load_employee(Global.current_employee_index)
	
	# Apply the defaults to the UI labels on ready
	update_labels()
	# Make sure any child scripts have run before manipulating traits
	await get_tree().process_frame
	# Delegate traits rendering to traits_list
	if traits_list and traits_list.has_method("set_traits"):
		traits_list.set_traits(traits)

func update_labels() -> void:
	if name_lbl:
		name_lbl.text = demon_name
	if dept_lbl:
		dept_lbl.text = department
	if blood_lbl:
		blood_lbl.text = blood_type
	if mbti_lbl:
		mbti_lbl.text = mbti
	if sign_lbl:
		sign_lbl.text = zodiac_sign
	if cod_lbl:
		cod_lbl.text = cod
	if sentence_lbl:
		sentence_lbl.text = sentence
	# Update portrait texture
	if portrait_rect and portrait_texture:
		portrait_rect.texture = portrait_texture

## Delegate trait updates to traits_list
func update_traits() -> void:
	if traits_list and traits_list.has_method("set_traits"):
		traits_list.set_traits(traits)


func set_info(data: Dictionary) -> void:
	# Convenience method to update values from code and refresh UI
	if data.has("name"): demon_name = str(data["name"])
	if data.has("department"): department = str(data["department"])
	if data.has("blood_type"): blood_type = str(data["blood_type"])
	if data.has("mbti"): mbti = str(data["mbti"])
	if data.has("sign"): zodiac_sign = str(data["sign"])
	if data.has("cod"): cod = str(data["cod"])
	if data.has("sentence"): sentence = str(data["sentence"])
	if data.has("traits") and typeof(data["traits"]) == TYPE_ARRAY: traits = data["traits"]
	# Handle portrait if provided
	if data.has("portrait"):
		var p = data["portrait"]
		if typeof(p) == TYPE_OBJECT and p is Texture2D:
			portrait_texture = p
		elif typeof(p) == TYPE_STRING:
			portrait_texture = load(str(p))
		# Apply portrait immediately
		if portrait_rect and portrait_texture:
			portrait_rect.texture = portrait_texture

	update_labels()
	update_traits()


func _on_employee_changed(index: int) -> void:
	print("DemonInfo: Loading employee at index %d" % index)
	load_employee(index)

func load_employee(index: int):
		if index < 0 or index >= MiseryManager.employees.size():
			push_error("Invalid employee index: %s" % index)
			return
		var e = MiseryManager.employees[index]
		# Do NOT update global department/traits here; DemonInfo will present these values.

		# Update the DemonInfo UI with the provided fields
		var info = {
			"name": e["name"],
			"department": e["department"],
			"blood_type": e["blood_type"],
			"mbti": e["mbti"],
			"sign": e["sign"],
			"cod": e["cod"],
			"sentence": e["sentence"],
			"traits": e["traits"],
		}
		if e.has("portrait"):
			info["portrait"] = e["portrait"]
		set_info(info)

		print("Loaded employee: ", e["name"], " (", e["department"], ")")
