extends Control

signal submitted(username: String)

@onready var username_input: LineEdit = $LineEdit
@onready var password_input: LineEdit = $LineEdit2

var interrupt_sound = preload("res://assets/sounds/interrupt.wav")

func _ready() -> void:
	AudioManager.play_sfx(interrupt_sound)
	password_input.secret = true

func _on_submit_button_pressed() -> void:
	var username := username_input.text
	Global.current_username = username
	submitted.emit(username)
	queue_free()