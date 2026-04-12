extends Node2D

# References
var terms_and_conditions_manager: Node
var popup_target: Node

# Knife properties
@export var knife_size: float = 30.0
@export var stab_proximity_radius: float = 50.0
@export var knife_color: Color = Color.RED

var is_equipped: bool = false
var knife_area: Area2D
var stab_cooldown: float = 0.0
var stab_cooldown_duration: float = 0.5
var last_mouse_down: bool = false

func _ready() -> void:
	# Create visual representation
	var knife_sprite = Line2D.new()
	knife_sprite.name = "KnifeVisual"
	knife_sprite.width = 5.0
	knife_sprite.points = PackedVector2Array([Vector2(-10, -knife_size), Vector2(10, knife_size)])
	knife_sprite.modulate = knife_color
	add_child(knife_sprite)
	
	# Start following mouse
	set_process(true)

func _process(delta: float) -> void:
	# Follow mouse cursor
	global_position = get_global_mouse_position()
	
	# Update cooldown
	if stab_cooldown > 0:
		stab_cooldown -= delta
	
	# Check for stab on left mouse button click
	var mouse_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if mouse_pressed and not last_mouse_down:
		_attempt_stab()
	last_mouse_down = mouse_pressed

func _attempt_stab() -> void:
	# Check if we're close enough to the popup's yes button
	if not is_instance_valid(popup_target):
		print("Knife: Popup target is no longer valid")
		return
	
	var yes_button = popup_target.get_node_or_null("Yes")
	if not yes_button:
		print("Knife: Yes button not found in popup")
		return
	
	# Calculate distance to yes button
	var button_global_pos = yes_button.global_position + yes_button.size / 2.0
	var distance = global_position.distance_to(button_global_pos)
	
	# If within stab range and cooldown expired
	if distance < stab_proximity_radius and stab_cooldown <= 0:
		stab_cooldown = stab_cooldown_duration
		print("Knife: Stabbed the YES button! Distance was: ", distance)
		terms_and_conditions_manager._on_knife_stab()

func equip() -> void:
	is_equipped = true
	print("Knife: Equipped and ready!")
	# Make the knife visible/prominent
	if has_node("KnifeVisual"):
		get_node("KnifeVisual").modulate = Color.RED

func unequip() -> void:
	is_equipped = false
	print("Knife: Unequipped")
	if has_node("KnifeVisual"):
		get_node("KnifeVisual").modulate = Color.GRAY
