extends Panel

@onready var user_label: Label = $UserLabel

func _ready() -> void:
	if is_instance_valid(user_label):
		if Global.current_username.is_empty():
			user_label.visible = false
		else:
			user_label.visible = true
			user_label.text = "User:" + Global.current_username