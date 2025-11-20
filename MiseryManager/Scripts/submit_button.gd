extends Button

func _ready() -> void:
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	var schedule = get_parent()
	if not schedule:
		return
	if not schedule.is_ready():
		return
	print("SubmitButton: total misery score:", schedule.get_total_misery_score())
