extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var efficiency_rating = 0.0 # Efficiency as a percentage
	
	# Calculate efficiency if total points possible is not zero
	if MiseryManager.total_points_possible > 0:
		efficiency_rating = (float(MiseryManager.total_game_score) / float(MiseryManager.total_points_possible)) * 100.0
	
	# Update the labels
	$TotalMisery.text = "Total Misery Generated: %d" % MiseryManager.total_game_score
	$ProjectedGoal.text = "Projected Goal: %d" % MiseryManager.total_points_possible
	
	# You can remove or repurpose the QuotaMet label
	$QuotaMet.text = "You have met %.0f%% of your Misery Quota for this cycle." % efficiency_rating
	
	# Connect the TryAgain button
	$TryAgain.pressed.connect(_on_try_again_pressed)

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://MiseryManager/Scenes/misery_manager.tscn")
