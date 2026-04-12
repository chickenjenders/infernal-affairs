extends Control

signal decision_made(response) # custom signal

func _ready():
	# Try to connect button signals if they exist
	var yes_button = get_node_or_null("Yes")
	var no_button = get_node_or_null("No")
	
	if yes_button and yes_button.has_signal("pressed"):
		yes_button.pressed.connect(_on_yes_button_pressed)
	if no_button and no_button.has_signal("pressed"):
		no_button.pressed.connect(_on_no_button_pressed)

# This function sets up the text *just before* the popup appears
func setup_popup(text_to_show):
	var label = get_node_or_null("Label")
	if label:
		label.text = text_to_show

func _on_yes_button_pressed():
	emit_signal("decision_made", "yes")
	# Don't auto-delete; let the parent manager control when to remove

func _on_no_button_pressed():
	emit_signal("decision_made", "no")
	# Don't auto-delete; let the parent manager control when to remove
