extends Control

@export var misery_manager: MiseryManager

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the TryAgain button
	$TryAgain.pressed.connect(_on_try_again_pressed)
	
	if visible:
		update_report()

func update_report():
	# Ensure it's centered on the screen if its parent is a non-visual Node
	set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	var efficiency_rating = 0.0 # Efficiency as a percentage
	
	var total_score = ShiftManager.total_game_score
	var total_possible = 500 # Default or get from manager
	if misery_manager:
		total_possible = misery_manager.total_points_possible
	
	# Calculate efficiency if total points possible is not zero
	if total_possible > 0:
		efficiency_rating = (float(total_score) / float(total_possible)) * 100.0
	
	# Update the labels
	$TotalMisery.text = "Total Misery Generated: %d" % total_score
	$ProjectedGoal.text = "Projected Goal: %d" % total_possible
	
	# You can remove or repurpose the QuotaMet label
	$QuotaMet.text = "You have met %.0f%% of your Misery Quota for this cycle." % efficiency_rating

func _on_try_again_pressed():
	# Reset ShiftManager state
	ShiftManager.current_employee_index = 0
	ShiftManager.total_game_score = 0
	ShiftManager.current_shift_index = 1
	ShiftManager.seen_employees.clear()
	
	print("MiseryReport: Game state reset via ShiftManager")
	
	# Return to the beginning of the game
	get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")
