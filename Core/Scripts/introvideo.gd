extends Control

@onready var intro_texture = $SlideShow/VBoxContainer/introvid

var fade_scene = preload("res://common/ui/fade_layer.tscn")
var slides = []
var current_slide_index = 0

func _ready():
	var fade = fade_scene.instantiate()
	add_child(fade)
	fade.fade_from_black(1.5)
	load_slides()
	start_dialogue()

func load_slides():
	for i in range(2, 23):
		var path = "res://assets/introslide/%d.png" % i
		if ResourceLoader.exists(path):
			slides.append(load(path))
		else:
			push_error("Missing slide image: " + path)

func start_dialogue():
	var dialogue_resource = load("res://core/dialogue/intro.dialogue")
	current_slide_index = 0
	
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_got_dialogue)

func _on_got_dialogue(_line):
	current_slide_index += 1
	set_slide(current_slide_index)

func set_slide(index: int):
	if index > 0 and index <= slides.size():
		intro_texture.texture = slides[index - 1]

func _on_dialogue_ended(_resource):
	get_tree().change_scene_to_file("res://core/scenes/desktop.tscn")
