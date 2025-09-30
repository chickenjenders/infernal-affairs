extends Control

# === SOUL DATA ===
# Later, 
var souls = [
	{
		"name": "Rafael Niebles",
		"portrait": preload("res://Assets/rafael.png"),
		"death": "Crashed his car while live streaming",
		"offenses": "Crypto scammed his viewers, sold Alibaba merch, forgot his Mom’s birthday",
		"justification": "Sold his soul for a million subscribers",
		"correct_department": "Mortal Affairs"
	},
	{
		"name": "Patricia Lee",
		"portrait": preload("res://Assets/patricia.PNG"),
		"death": "Heart attack during tax season",
		"offenses": "Cooked the books for 10 years, almond mom, made her kids give her credit on school projects she helped with",
		"justification": "Signed a deal to never get caught",
		"correct_department": "Souls and Acquisitions"
	},
	{
		"name": "James Smith",
		"portrait": preload("res://Assets/james.PNG"),
		"death": "Old age",
		"offenses": "Terroized employees, followed a carnivore diet, doxxed a highschooler they got into a fight with on Twitter",
		"justification": "Hated by everyone they knew",
		"correct_department": "Operations and Compliance"
	}
]

var current_soul_index := 0
var quota_met := 0 # This will track total submissions, not just correct ones
var daily_quota := 8
var correct_submissions := 0 # Track correct answers separately
var selected_department := "" # updated when player clicks a department button

func _ready():
	# The scene already has signal connections for department buttons
	# We just need to connect the submit button
	$SubmitButton.connect("pressed", Callable(self, "_on_submit_pressed"))
	
	load_soul(current_soul_index)
	update_quota_label()

# === UI UPDATE ===
func load_soul(index):
	var soul = souls[index]
	var portrait_node = $SoulCard/Portrait/SoulPortrait
	portrait_node.texture = soul["portrait"]
	
	# Control how the image is scaled/fitted
	portrait_node.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL # Keeps aspect ratio
	
	$SoulCard/NameLabel.text = soul["name"]
	$SoulCard/DeathCause.text = soul["death"]
	$SoulCard/Offenses.text = soul["offenses"]
	$SoulCard/Justification.text = soul["justification"]
	selected_department = "" # reset department selection

func update_quota_label():
	$QuotaLabel.text = "%d/%d Quota Met" % [quota_met, daily_quota]

# === INPUT HANDLING ===
func _on_demon_relations_pressed():
	_on_department_pressed("Demon Relations")

func _on_agony_despair_pressed():
	_on_department_pressed("Agony and Despair")

func _on_motral_affairs_pressed():
	_on_department_pressed("Mortal Affairs")

func _on_souls_acquisitions_pressed():
	_on_department_pressed("Souls and Acquisitions")

func _on_operations_compliance_pressed():
	_on_department_pressed("Operations and Compliance")

func _on_department_pressed(department_name):
	selected_department = department_name
	print("Selected Department: ", selected_department)

func _on_submit_pressed():
	if selected_department == "":
		print("No  selected!")
		return
		
	# Increment quota on every submission (regardless of correctness)
	quota_met += 1
	
	var soul = souls[current_soul_index]
	if selected_department == soul["correct_department"]:
		print("Submissions: %d/%d | Correct: %d" % [quota_met, daily_quota, correct_submissions])
	else:
		print("Submissions: %d/%d | Correct: %d" % [soul["correct_department"], quota_met, daily_quota, correct_submissions])
	
	update_quota_label()
	
	# Go to next soul or end day
	current_soul_index += 1
	if current_soul_index < souls.size():
		load_soul(current_soul_index)
	else:
		print("Day over! Final Score: %d correct out of %d submissions" % [correct_submissions, quota_met])
