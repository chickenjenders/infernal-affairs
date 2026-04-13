extends Control

# Aimless movement parameters
@export var movement_speed: float = 1200.0
@export var direction_change_interval: float = 0.2 # Change direction more frequently
var current_direction: Vector2 = Vector2.RIGHT
var time_since_direction_change: float = 0.0

func _ready() -> void:
	print("PopupEvasion: Ready, starting erratic movement")
	time_since_direction_change = 0.0
	_pick_random_direction()

func _process(delta: float) -> void:
	# Change direction periodically or when hitting edges
	time_since_direction_change += delta
	if time_since_direction_change >= direction_change_interval:
		_pick_random_direction()
		time_since_direction_change = 0.0
	
	# Move in current direction
	global_position += current_direction * movement_speed * delta
	
	# Keep popup within screen bounds with bouncy behavior
	var viewport_rect = get_viewport_rect()
	var safe_margin = 20.0
	
	if global_position.x < safe_margin:
		global_position.x = safe_margin
		current_direction.x = abs(current_direction.x)
		_pick_random_direction() # More erratic on hit
	elif global_position.x > viewport_rect.size.x - size.x - safe_margin:
		global_position.x = viewport_rect.size.x - size.x - safe_margin
		current_direction.x = - abs(current_direction.x)
		_pick_random_direction()
	
	if global_position.y < safe_margin:
		global_position.y = safe_margin
		current_direction.y = abs(current_direction.y)
		_pick_random_direction()
	elif global_position.y > viewport_rect.size.y - size.y - safe_margin:
		global_position.y = viewport_rect.size.y - size.y - safe_margin
		current_direction.y = - abs(current_direction.y)
		_pick_random_direction()

func _pick_random_direction() -> void:
	var angle = randf_range(0, TAU)
	current_direction = Vector2(cos(angle), sin(angle)).normalized()
