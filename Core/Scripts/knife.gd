extends Area2D

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Keep input_pickable true so we can actually click it!
	# Visibility is still handled by terms_and_conditions.gd
	input_pickable = true
	visible = false

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			# When picking up, ensure it's on top
			z_index = 100
			# Stop the event from propagating further
			get_viewport().set_input_as_handled()
		else:
			is_dragging = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func set_active(active: bool) -> void:
	visible = active
	input_pickable = active
