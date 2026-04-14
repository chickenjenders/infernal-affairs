extends Control

# Path-based circular movement
@export var movement_speed: float = 150.0 # pixels per second around the path
var path_progress: float = 0.0
var path_total_length: float = 0.0
var is_moving: bool = true
var stab_count: int = 0

# Screen dimensions for the path calculations
var viewport_size: Vector2
var path_points: Array[Vector2] = []

func _ready() -> void:
	print("PopupEvasion: Ready, setting up circular path movement")
	viewport_size = get_viewport_rect().size
	print("PopupEvasion: Popup size at ready: ", size)
	print("PopupEvasion: Viewport size: ", viewport_size)
	_setup_circular_path()
	path_total_length = _calculate_path_length()
	print("PopupEvasion: Path total length calculated: ", path_total_length)

func _process(delta: float) -> void:
	if not is_moving:
		return
	
	# Move along the path
	path_progress += movement_speed * delta
	
	# Wrap around when reaching the end
	if path_progress >= path_total_length:
		path_progress = fmod(path_progress, path_total_length)
	
	# Calculate position based on path progress
	global_position = _get_position_on_path(path_progress)

func _setup_circular_path() -> void:
	# Create a rectangular path around the screen edges
	# Start from top-left and go clockwise
	var margin = 10.0 # Distance from screen edge
	var popup_size = size if size != Vector2.ZERO else Vector2(250, 150)
	
	print("PopupEvasion: Setting up path with popup_size: ", popup_size)
	
	# Top edge (left to right)
	var x = margin
	while x < viewport_size.x - popup_size.x - margin:
		path_points.append(Vector2(x, margin))
		x += 20.0
	
	# Right edge (top to bottom)
	var y = margin
	while y < viewport_size.y - popup_size.y - margin:
		path_points.append(Vector2(viewport_size.x - popup_size.x - margin, y))
		y += 20.0
	
	# Bottom edge (right to left)
	x = viewport_size.x - popup_size.x - margin
	while x > margin:
		path_points.append(Vector2(x, viewport_size.y - popup_size.y - margin))
		x -= 20.0
	
	# Left edge (bottom to top)
	y = viewport_size.y - popup_size.y - margin
	while y > margin:
		path_points.append(Vector2(margin, y))
		y -= 20.0
	
	# Close the loop
	path_points.append(path_points[0])
	
	print("PopupEvasion: Path points created: ", path_points.size())

func _calculate_path_length() -> float:
	var length = 0.0
	for i in range(path_points.size() - 1):
		length += path_points[i].distance_to(path_points[i + 1])
	return length

func _get_position_on_path(progress: float) -> Vector2:
	# Find which segment of the path we're on
	var current_distance = 0.0
	for i in range(path_points.size() - 1):
		var segment_length = path_points[i].distance_to(path_points[i + 1])
		if current_distance + segment_length >= progress:
			# We're on this segment
			var segment_progress = (progress - current_distance) / segment_length
			return path_points[i].lerp(path_points[i + 1], segment_progress)
		current_distance += segment_length
	
	# Fallback to last point
	return path_points[-1]

func record_stab() -> void:
	stab_count += 1
	print("PopupEvasion: Stabbed! Count: ", stab_count, "/3")
	if stab_count >= 3:
		stop_moving()

func stop_moving() -> void:
	is_moving = false
	print("PopupEvasion: Popup stopped!")
