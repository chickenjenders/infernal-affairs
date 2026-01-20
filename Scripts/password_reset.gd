extends Control

@onready var password_input: LineEdit = $InputArea/PasswordInput
@onready var submit_button: Button = $InputArea/SubmitButton
@onready var requirements_list: VBoxContainer = $MainLayout/RequirementsList
@onready var invalid_password_label: Label = $invalid_password_label

var current_requirement_index: int = 0
var requirements: Array[Node] = []
var elapsed_time = 0

func _ready() -> void:
	requirements = requirements_list.get_children()
	
	# Hide all except the first one
	for i in range(requirements.size()):
		requirements[i].visible = (i == 0)
	
	submit_button.pressed.connect(_on_submit_pressed)
	password_input.text_submitted.connect(_on_submit_pressed)
	invalid_password_label.visible = false

func _process(delta: float) -> void:
	if current_requirement_index == 8:
		elapsed_time += delta
		if elapsed_time >= 10:
			get_tree().change_scene_to_file("res://Scenes/securityquestions.tscn")

func _on_submit_pressed(_text: String = "") -> void:
	var password = password_input.text
	
	if check_requirements(password):
		password_input.text = ""
		invalid_password_label.visible = false
		if current_requirement_index < requirements.size() - 1:
			current_requirement_index += 1
			requirements[current_requirement_index].visible = true
			password_input.grab_focus()
		else:
			print("Password reset complete!")
			get_tree().change_scene_to_file("res://MiseryManager/Scenes/misery_manager.tscn")
	else:
		invalid_password_label.visible = true
		print("Requirements not met, text is: ", _text)

func check_requirements(text: String) -> bool:
	# Check all revealed requirements
	for i in range(current_requirement_index + 1):
		if not validate_rule(i, text):
			return false
	return true

func validate_rule(index: int, text: String) -> bool:
	match index:
		0: # Must include 3 numbers
			var count = 0
			for i in text.length():
				if text[i] >= "0" and text[i] <= "9":
					count += 1
			return count >= 3
			
		1: # Must include 6 capital letters
			var count = 0
			for i in text.length():
				var c = text[i]
				if c >= "A" and c <= "Z":
					count += 1
			return count >= 6
			
		2: # Must include 2 special characters
			var count = 0
			var special_chars = "!@#$%^&*()_+-=[]{}|;':\",.<>/?`~"
			for i in text.length():
				if special_chars.contains(text[i]):
					count += 1
			return count >= 2
			
		3: # Must include an onomatopoeia
			var onomatopoeias = [
				"bang", "pow", "boom", "crash", "zap", "meow", "woof", "moo", "beep", "click",
				"clank", "clunk", "thud", "whack", "smash", "kaboom", "splat", "boing", "honk",
				"quack", "ribbit", "buzz", "hiss", "sizzle", "pop", "snap", "crackle", "ding",
				"dong", "ring", "chirp", "tweet", "roar", "growl", "purr", "screech", "vroom",
				"zoom", "whoosh", "swish", "splash", "drip", "drop", "plop", "tick", "tock",
				"knock", "tap", "thump", "slap", "clap", "stomp", "crunch", "munch", "gulp",
				"slurp", "burp", "fart", "sneeze", "cough", "hiccup", "snore", "yawn", "gasp",
				"sigh", "groan", "moan", "squeak", "creak", "rattle", "clatter", "jingle",
				"clang", "bong", "gong", "toot", "hum", "whistle", "whisper", "mumble", "shout",
				"yell", "scream", "howl", "bark", "bleat", "neigh", "bray", "cluck", "crow",
				"caw", "coo", "hoot", "peep", "squawk", "chirrup", "trill", "warble", "croak",
				"grunt", "snort", "squeal", "whimper", "whine", "argh", "ugh", "ouch", "ow"
			]
			var lower_text = text.to_lower()
			for word in onomatopoeias:
				if lower_text.contains(word):
					return true
			return false
			
		4: # Must include at least one unnecessary underscore (_)
			return text.contains("_")

		5: # Must include one apology
			var apologies = [
				"sorry", "apologize", "forgive", "my bad", "oops", "pardon", "excuse me",
				"my apologies", "my fault", "my mistake", "i regret", "mea culpa", "beg your pardon",
				"so sorry", "terribly sorry", "awfully sorry", "deeply sorry", "sincerest apologies",
				"please forgive", "forgive me", "i messed up", "i screwed up", "i was wrong",
				"my error", "whoops", "oopsie", "regret", "remorse", "contrite", "penitent",
				"ashamed", "guilty", "bad conscience", "conscience-stricken", "rueful",
				"remorseful", "apologetic", "i apologize", "please excuse", "my badness"
			]
			var lower_text = text.to_lower()
			for word in apologies:
				if lower_text.contains(word):
					return true
			print("incorrect:", lower_text)
			return false
			
		6: # Must include a date in MM/DD format
			var regex = RegEx.new()
			regex.compile("\\d{2}/\\d{2}")
			return regex.search(text) != null
			
		7: # Must include the word 'password' somewhere but not at the start
			return text.contains("password") and not text.begins_with("password")
			
		8: # Must make your password symmetrical (palindrome)
			var length = text.length()
			for i in range(length >> 1):
				if text[i] != text[length - 1 - i]:
					return false
			return true
			
		_:
			return true
