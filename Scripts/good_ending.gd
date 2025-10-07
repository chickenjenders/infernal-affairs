extends Control

@export var accuracy_label: Label

func _ready():
	print("=== GOOD ENDING SCENE ===")
	print("GlobalData.final_score_percentage: ", GlobalData.final_score_percentage)
	
	if accuracy_label:
		var display_text = "Accuracy Score: %.1f%%" % GlobalData.final_score_percentage
		accuracy_label.text = display_text
		print("Accuracy label updated with text: ", display_text)
	else:
		print("WARNING: accuracy_label is not assigned in the Inspector!")