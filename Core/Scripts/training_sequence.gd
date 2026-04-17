extends Control

@onready var slide_image: TextureRect = $SlideShow/VBoxContainer/slideimage
@onready var next_button: Button = $SlideShow/VBoxContainer/HBoxContainer/next
@onready var video_player: VideoStreamPlayer = $Video/VideoStreamPlayer

@onready var slideshow_container: Control = $SlideShow
@onready var quiz_container: Control = $Quiz
@onready var quiz_intro: Control = $Quiz/Intro
@onready var quiz_questions: Control = $Quiz/Questions
@onready var question_label: Label = $Quiz/Questions/QuestionLabel
@onready var options_container: VBoxContainer = $Quiz/Questions/OptionsContainer
@onready var quiz_results: Control = $Quiz/Results
@onready var score_label: Label = $Quiz/Results/ScoreLabel
@onready var quiz_start_button: Button = $Quiz/Intro/startquiz
@onready var quiz_finish_button: Button = $Quiz/Results/finishquiz
@onready var feedback_card: Control = $Quiz/FeedbackCard
@onready var feedback_label: Label = $Quiz/FeedbackCard/VBox/FeedbackLabel
@onready var next_question_button: Button = $Quiz/FeedbackCard/VBox/NextQuestionButton
@onready var urgent_popup: Control = $UrgentPopup
@onready var start_training_button: Button = $UrgentPopup/Panel/VBox/StartTrainingButton

var audio_player: AudioStreamPlayer

var fish_scene = preload("res://core/scenes/fish.tscn")
var slide_fishes: Array = []

var slides: Array[Texture2D] = []
var current_slide_index: int = 0

# Configuration for fish on each slide (0-4)
# positions are relative to SlideShow/VBoxContainer (which covers the screen)
var fish_positions = [
	[], # Slide 1 (no fish)
	[Vector2(400, 600)], # Slide 2 (good)
	[Vector2(100, 400)], # Slide 3 (keep left fish only)
	[Vector2(400, 600)], # Slide 4 (same as Slide 2)
	[] # Slide 5 (no fish)
]

var quiz_data = [
	{
		"q": "Who was the first person to ever go fishing?",
		"o": ["Adam", "Jerry from Accounting", "Dave", "A fish"],
		"a": 3,
		"right": "Wow, you actually know your history. Or you just guessed.",
		"wrong": "Wrong. It was a fish. Obviously."
	},
	{
		"q": "What color was the third fish on the right at 0:30?",
		"o": ["Green", "Blue", "Red", "Yellow"],
		"a": 1,
		"right": "I can only assume you've seen this video before",
		"wrong": "Did you even watch the video? It was blue."
	},
	{
		"q": "Which is better: fishing or hunting?",
		"o": ["Fishing", "Hunting", "They are the same", "Neither"],
		"a": 3,
		"right": "Good work, you DO know something! Hibernation is truly the best hobby.",
		"wrong": "Are you insane? Hibernation is the only answer."
	},
	{
		"q": "What was the technique used by the fisher at 0:44?",
		"o": ["The 'Flip-a-whapow!", "Trolling", "'Whippy-whop-bam!'", "Using a net"],
		"a": 2,
		"right": "Correct! Whippy-whop-bam IS the most metal of fishing techniques.",
		"wrong": "Incorrect. You should really know this."
	},
	{
		"q": "What is the national fish of Hell?",
		"o": ["Salmon", "Lava Eel", "The Devil Ray", "A sunfish"],
		"a": 3,
		"right": "A sunfish, indeed. Majestic and terrifying.",
		"wrong": "How do you not know your own national fish?"
	}
]
var current_question_index = 0
var score = 0

func _ready() -> void:
	# Hide everything initially except the urgent popup
	slideshow_container.visible = false
	quiz_container.visible = false
	video_player.visible = false
	urgent_popup.visible = true
	
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/sounds/fishing.wav")
	add_child(audio_player)
	
	load_slides()
	if slides.size() > 0:
		show_slide(0)
	else:
		push_error("No slides found in assets/phishing/")
	
	start_training_button.pressed.connect(_on_start_training_pressed)
	next_button.pressed.connect(_on_next_pressed)
	quiz_start_button.pressed.connect(start_quiz)
	quiz_finish_button.pressed.connect(_on_finish_quiz_pressed)
	video_player.finished.connect(_on_video_finished)
	next_question_button.pressed.connect(_on_next_question_pressed)

func _on_start_training_pressed() -> void:
	urgent_popup.visible = false
	slideshow_container.visible = true

func load_slides() -> void:
	# Slides are named 1.png, 2.png, etc. in assets/phishing/
	var dir = DirAccess.open("res://assets/phishing/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var slide_paths = []
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png") and not file_name.ends_with(".import"):
				slide_paths.append("res://assets/phishing/" + file_name)
			file_name = dir.get_next()
		
		# Sort paths to ensure 1, 2, 3... order
		slide_paths.sort()
		
		for path in slide_paths:
			var texture = load(path)
			if texture is Texture2D:
				slides.append(texture)
	else:
		print("An error occurred when trying to access the phishing assets folder.")

func show_slide(index: int) -> void:
	if index >= 0 and index < slides.size():
		current_slide_index = index
		slide_image.texture = slides[index]
		
		# Clear existing fish
		for f in slide_fishes:
			f.queue_free()
		slide_fishes.clear()
		
		# Add new fish for this slide
		if current_slide_index < fish_positions.size():
			var positions = fish_positions[current_slide_index]
			for pos in positions:
				var f = fish_scene.instantiate()
				$SlideShow/VBoxContainer.add_child(f)
				f.position = pos
				slide_fishes.append(f)
		
		# If this is the second to last slide, the "Next" button 
		# will lead to the last slide + video automatic start.
		if current_slide_index == slides.size() - 2:
			next_button.text = "Watch Video"
		elif current_slide_index == slides.size() - 1:
			next_button.text = "Finish Training"
			play_phishing_video()
		else:
			next_button.text = "Next >"

func _on_next_pressed() -> void:
	if current_slide_index < slides.size() - 1:
		show_slide(current_slide_index + 1)
	else:
		# If the video is already over or hasn't started, we're likely in the "Finish training" state
		# But the video finish signal should handle transition to quiz.
		# If the user clicks "Finish Training" button (which this button becomes during video),
		# and video hasn't finished, maybe we skip to quiz?
		video_player.stop()
		show_quiz_intro()

func play_phishing_video() -> void:
	# Hide existing fish when video starts
	for f in slide_fishes:
		f.queue_free()
	slide_fishes.clear()
	
	var video_path = "res://assets/phishing/phishingvid.ogv"
	var video_stream = load(video_path)
	if video_stream:
		# Ensure video player is visible and playable
		video_player.visible = true
		video_player.stream = video_stream
		video_player.play()
		audio_player.play()
		# Hide the slide elements
		slide_image.visible = false
	else:
		push_error("Could not load video: " + video_path)

func _on_video_finished() -> void:
	show_quiz_intro()

func show_quiz_intro() -> void:
	slideshow_container.visible = false
	video_player.stop()
	audio_player.stop()
	video_player.visible = false
	quiz_container.visible = true
	quiz_intro.visible = true
	quiz_questions.visible = false
	quiz_results.visible = false

func start_quiz() -> void:
	quiz_intro.visible = false
	quiz_questions.visible = true
	current_question_index = 0
	score = 0
	show_question()

func show_question() -> void:
	for child in options_container.get_children():
		child.queue_free()
	
	var data = quiz_data[current_question_index]
	question_label.text = data["q"]
	
	for i in range(data["o"].size()):
		var btn = Button.new()
		btn.text = data["o"][i]
		btn.add_theme_font_override("font", load("res://assets/font/Garet-Heavy.ttf"))
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", Color(0.12, 0.12, 0.12, 1))
		btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.1, 0, 0, 1))
		btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		
		# Corporate Cream & Red styles
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(0.96, 0.94, 0.88, 1) # Cream
		normal.set_corner_radius_all(30)
		normal.set_border_width_all(2)
		normal.border_color = Color(0.8, 0.75, 0.65, 1)
		normal.content_margin_left = 24
		normal.content_margin_right = 24
		normal.content_margin_top = 12
		normal.content_margin_bottom = 12
		
		var hover = normal.duplicate()
		hover.bg_color = Color(1.0, 0.98, 0.92, 1) # Lighter cream
		hover.border_color = Color(0.68, 0.12, 0.15, 1) # Corporate Red
		
		var pressed = normal.duplicate()
		pressed.bg_color = Color(0.85, 0.82, 0.75, 1) # Darker cream
		pressed.border_color = Color(0.4, 0.1, 0.1, 1)
		
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed)
		btn.add_theme_stylebox_override("focus", hover)
		
		btn.pressed.connect(_on_answer_selected.bind(i))
		options_container.add_child(btn)

func _on_answer_selected(index: int) -> void:
	var data = quiz_data[current_question_index]
	var is_correct = index == data["a"]
	
	if is_correct:
		score += 1
		feedback_label.text = data["right"]
	else:
		feedback_label.text = data["wrong"]
	
	feedback_card.visible = true
	quiz_questions.modulate.a = 0.3 # Fade out questions while feedback is shown

func _on_next_question_pressed() -> void:
	feedback_card.visible = false
	quiz_questions.modulate.a = 1.0
	
	current_question_index += 1
	if current_question_index < quiz_data.size():
		show_question()
	else:
		show_results()

func show_results() -> void:
	quiz_questions.visible = false
	quiz_results.visible = true
	quiz_finish_button.text = "Close Training"
	
	if score == quiz_data.size():
		score_label.text = "Perfect score.... incredibly suspicious.\nYou will be assigned this training again to check it wasn't a fluke."
	else:
		score_label.text = "You have failed to complete this quiz with a 100%.\nYou will be assigned this training again until perfection is obtained."

func _on_finish_quiz_pressed() -> void:
	# Both outcomes now close the training to reveal the game state underneath
	queue_free()
