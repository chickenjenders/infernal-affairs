extends Control

@export var misery_manager: MiseryManager

# Called when the node enters the scene tree for the first time.
func _ready():
	var efficiency_rating = 0.0 # Efficiency as a percentage
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	
	# Calculate efficiency if total points possible is not zero
	if misery_manager.total_points_possible > 0:
		efficiency_rating = (float(misery_manager.total_game_score) / float(misery_manager.total_points_possible)) * 100.0
	
	# Update the labels
	$TotalMisery.text = "Total Misery Generated: %d" % misery_manager.total_game_score
	$ProjectedGoal.text = "Projected Goal: %d" % misery_manager.total_points_possible
	
	# You can remove or repurpose the QuotaMet label
	$QuotaMet.text = "You have met %.0f%% of your Misery Quota for this cycle." % efficiency_rating
	
	# Connect the TryAgain button
	$TryAgain.pressed.connect(_on_try_again_pressed)

func _on_try_again_pressed():
	# Reset all game state variables in MiseryManager
	if not misery_manager:
		push_error("MiseryManager not found in scene tree")
		return
	misery_manager.total_game_score = 0
	misery_manager.current_employee_index = 0
	misery_manager.current_employee_score = 0
	misery_manager.currently_dragging_task = null
	misery_manager.department = "IT"
	misery_manager.task_list.clear()
	misery_manager.traits_list.clear()
	
	# Clear all task slots
	for slot in misery_manager.task_slots:
		slot["task"] = null
	
	print("MiseryReport: Game state reset completely")
	
	# Return to the beginning of the game
	get_tree().change_scene_to_file("res://misery_manager/scenes/misery_manager.tscn")
