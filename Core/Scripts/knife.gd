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
	var knife_sprite = Sprite2D.new()
	knife_sprite.name = "KnifeVisual"
	# Load the knife icon from assets/icons/knife.png
	var tex = load("res://assets/icons/knife.png")
	if tex:
		knife_sprite.texture = tex
	else:
		# Fallback if the specific path doesn't exist
		printerr("Knife: Texture not found at res://assets/icons/knife.png")
	
	# Adjust scale if needed
	knife_sprite.scale = Vector2(0.5, 0.5)
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
	# Check if we're close enough to the popup
	if not is_instance_valid(popup_target):
		return
	
	# Instead of just the "Yes" button, let's allow stabbing anywhere on the popup
	# or at least the general area of it.
	var popup_rect = Rect2(popup_target.global_position, popup_target.size)
	
	# If mouse is within the popup bounds and cooldown expired
	if popup_rect.has_point(global_position) and stab_cooldown <= 0:
		stab_cooldown = stab_cooldown_duration
		print("Knife: Stabbed the popup!")
		if terms_and_conditions_manager and terms_and_conditions_manager.has_method("_on_knife_stab"):
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
