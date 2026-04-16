extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.modulate.a = 0

func fade_to_black(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	return tween.finished

func fade_from_black(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	# Ensure it starts at black
	color_rect.modulate.a = 1.0
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	return tween.finished
