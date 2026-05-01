extends Area2D

var is_dragging: bool = false
var has_been_clicked: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	# Keep input_pickable true so we can actually click it!
	# Visibility is still handled by terms_and_conditions.gd
	input_pickable = true
	visible = false
	
	if sprite:
		sprite.pause()
		sprite.frame = 0

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not has_been_clicked:
				has_been_clicked = true
				if sprite:
					sprite.stop()
					sprite.frame = 0
			
			is_dragging = true
			# When picking up, ensure it's on top
			z_index = 100
			# Stop the event from propagating further
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()

func set_active(active: bool) -> void:
	visible = active
	input_pickable = active
	
	if active and not has_been_clicked and sprite:
		sprite.play("default")
