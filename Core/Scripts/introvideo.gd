extends Control

@onready var intro_texture = $SlideShow/VBoxContainer/introvid

var fade_scene = preload("res://common/ui/fade_layer.tscn")
var slides = []
var current_slide_index = 0

var scaryinst = preload("res://assets/sounds/scaryinst.wav")
var bgmusic = preload("res://assets/sounds/bgmusic.wav")
var laugh = preload("res://assets/sounds/laugh.wav")

func _ready():
	var fade = fade_scene.instantiate()
	add_child(fade)
	fade.fade_from_black(1.5)
	load_slides()
	
	current_slide_index = 1
	set_slide(1)
	AudioManager.play_music(scaryinst)
	
	if has_node("Button"):
		$Button.pressed.connect(start_dialogue)
	else:
		start_dialogue()

func load_slides():
	for i in range(2, 23):
		var path = "res://assets/introslide/%d.png" % i
		if ResourceLoader.exists(path):
			slides.append(load(path))
		else:
			push_error("Missing slide image: " + path)

func start_dialogue():
	if has_node("Button"):
		$Button.hide()
		
	var dialogue_resource = load("res://core/dialogue/intro.dialogue")
	
	DialogueManager.show_dialogue_balloon_scene("res://break_time/dialogue/dialogue_balloon.tscn", dialogue_resource, "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.got_dialogue.connect(_on_got_dialogue)

func _on_got_dialogue(_line):
	current_slide_index += 1
	set_slide(current_slide_index)
	
	if current_slide_index == 2:
		AudioManager.play_music(bgmusic)
	elif current_slide_index == 6:
		AudioManager.play_music(laugh)
	elif current_slide_index == 7:
		AudioManager.play_music(bgmusic)
	elif current_slide_index == 15:
		AudioManager.play_music(scaryinst)
	elif current_slide_index == 16:
		AudioManager.play_music(bgmusic)

func set_slide(index: int):
	if index > 0 and index <= slides.size():
		intro_texture.texture = slides[index - 1]

func _on_dialogue_ended(_resource):
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://core/scenes/desktop.tscn")
