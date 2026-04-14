extends Control

# Aimless movement parameters
@export var movement_speed: float = 2000.0
@export var direction_change_interval: float = 0.1 # Change direction very frequently
var current_direction: Vector2 = Vector2.RIGHT
var time_since_direction_change: float = 0.0

func _ready() -> void:
	print("PopupEvasion: Ready, starting ultra-fast movement")
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
	
	# We need to account for the actual size of the popup for clamping
	var popup_size = size if size != Vector2.ZERO else Vector2(250, 150)
	
	if global_position.x < safe_margin:
		global_position.x = safe_margin
		current_direction.x = abs(current_direction.x)
	elif global_position.x > viewport_rect.size.x - popup_size.x - safe_margin:
		global_position.x = viewport_rect.size.x - popup_size.x - safe_margin
		current_direction.x = - abs(current_direction.x)
	
	if global_position.y < safe_margin:
		global_position.y = safe_margin
		current_direction.y = abs(current_direction.y)
	elif global_position.y > viewport_rect.size.y - popup_size.y - safe_margin:
		global_position.y = viewport_rect.size.y - popup_size.y - safe_margin
		current_direction.y = - abs(current_direction.y)

func _pick_random_direction() -> void:
	var angle = randf_range(0, TAU)
	current_direction = Vector2(cos(angle), sin(angle)).normalized()
