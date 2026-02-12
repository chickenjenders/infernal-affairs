extends Button

signal submit_requested

func _ready() -> void:
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	submit_requested.emit()
