extends Control

@export var accuracy_label: Label

func _init():
	print("BAD ENDING: _init() called - script is loading")

func _ready():
	print("BAD ENDING: _ready() called - scene is ready")
	print("Node name: ", name)
	print("Scene file: ", scene_file_path if scene_file_path else "No scene file path")
	
	# Test if GlobalData is accessible
	if GlobalData == null:
		print("ERROR: GlobalData is null - not set up as AutoLoad!")
		return
	
	print("GlobalData exists, checking final_score_percentage...")
	print("GlobalData.final_score_percentage: ", GlobalData.final_score_percentage)
	
	if accuracy_label:
		var display_text = "Accuracy Score: %.1f%%" % GlobalData.final_score_percentage
		accuracy_label.text = display_text
		print("Accuracy label updated with text: ", display_text)
	else:
		print("WARNING: accuracy_label is not assigned in the Inspector!")