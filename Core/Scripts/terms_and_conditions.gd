extends Control

@onready var checkbox: CheckButton = $CheckButton
@onready var hidden_popup: Control = $popup
@onready var popup_scene = preload("res://popup.tscn")
@onready var knife_area: Area2D = $Area2D

# Game phases
enum Phase {POPUP_SPAM, MINI_GAME, COMPLETE}
var current_phase: Phase = Phase.POPUP_SPAM

# Popup spam phase variables
var popup_spam_timer: float = 0.0
var popup_spam_duration: float = 15.0
var active_popups: Array[Node] = []
var spam_phase_active: bool = false

# Mini-game phase variables
var knife_equipped: bool = false
var stab_count: int = 0
var stab_required: int = 3
var knife_instance: Node2D
var mini_game_popup: Node

func _ready() -> void:
	checkbox.toggled.connect(_on_checkbox_clicked)
	if knife_area:
		knife_area.visible = false
		knife_area.input_pickable = false

func _process(delta: float) -> void:
	match current_phase:
		Phase.POPUP_SPAM:
			_handle_popup_spam_phase(delta)
		Phase.MINI_GAME:
			pass # Mini-game phase is handled by evasion and knife scripts
		Phase.COMPLETE:
			pass

func _on_checkbox_clicked(_toggled: bool) -> void:
	if current_phase == Phase.POPUP_SPAM and not spam_phase_active:
		# Start the spam phase by showing the first popup
		spam_phase_active = true
		popup_spam_timer = 0.0
		
		# Setup the hidden popup existing in the scene
		hidden_popup.visible = true
		active_popups.append(hidden_popup)
		
		# Connect buttons of the pre-existing popup
		var yes_button = hidden_popup.get_node_or_null("Yes")
		var no_button = hidden_popup.get_node_or_null("No")
		if yes_button:
			yes_button.pressed.connect(_on_popup_button_pressed)
		if no_button:
			no_button.pressed.connect(_on_popup_button_pressed)

func _handle_popup_spam_phase(delta: float) -> void:
	if not spam_phase_active:
		return
		
	popup_spam_timer += delta
	
	if popup_spam_timer >= popup_spam_duration:
		spam_phase_active = false
		_transition_to_mini_game()
		return
	
	# Optional: spawn a popup every 1 second during spam phase if user isn't clicking
	if int(popup_spam_timer) > int(popup_spam_timer - delta):
		_spawn_popup()

func _spawn_popup() -> void:
	var popup_instance = popup_scene.instantiate()
	add_child(popup_instance)
	
	# Get the base position to stagger from (either center or the previous popup)
	var base_pos: Vector2
	if active_popups.is_empty():
		var viewport_size = get_viewport_rect().size
		base_pos = viewport_size / 2.0 - Vector2(125, 75) # Half of typical popup size
	else:
		base_pos = active_popups[-1].global_position
	
	active_popups.append(popup_instance)
	
	# Reset local position to zero so global_position works correctly
	popup_instance.position = Vector2.ZERO
	
	# Stagger popups relative to the PREVIOUS one to create a cascading stack
	var stagger_x = randf_range(-60, 80)
	var stagger_y = randf_range(-60, 80)
	
	popup_instance.global_position = base_pos + Vector2(stagger_x, stagger_y)
	
	# Keep within screen bounds slightly
	var screen = get_viewport_rect().size
	popup_instance.global_position.x = clamp(popup_instance.global_position.x, 20, screen.x - 270)
	popup_instance.global_position.y = clamp(popup_instance.global_position.y, 20, screen.y - 170)
	
	# Connect buttons to trigger more popups during spam phase
	var yes_button = popup_instance.get_node_or_null("Yes")
	var no_button = popup_instance.get_node_or_null("No")
	
	if yes_button:
		yes_button.pressed.connect(_on_popup_button_pressed)
	if no_button:
		no_button.pressed.connect(_on_popup_button_pressed)

func _on_popup_button_pressed() -> void:
	# During spam phase, clicking either button spawns exactly one more popup
	if current_phase == Phase.POPUP_SPAM:
		_spawn_popup()

func _transition_to_mini_game() -> void:
	current_phase = Phase.MINI_GAME
	print("Terms & Conditions: Transitioning to mini-game phase. Show the knife!")
	
	# Clear all active popups except the one we'll use for mini-game
	for popup in active_popups:
		if is_instance_valid(popup):
			if popup == hidden_popup:
				popup.visible = false
			else:
				popup.queue_free()
	active_popups.clear()
	
	# Show the knife scene that was hidden
	if knife_area:
		knife_area.visible = true
		knife_area.input_pickable = true
		# Connect the knife click
		if not knife_area.input_event.is_connected(_on_knife_clicked):
			knife_area.input_event.connect(_on_knife_clicked)

func _on_knife_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_equip_knife()

func _equip_knife() -> void:
	if knife_equipped:
		return
		
	knife_equipped = true
	print("Terms & Conditions: Knife equipped!")
	
	# Hide the physical knife object in the scene
	if knife_area:
		knife_area.visible = false
	
	# Spawn the knife script that handles the cursor and stabbing
	var knife_script_scene = preload("res://core/scripts/knife.gd")
	knife_instance = Node2D.new()
	knife_instance.set_script(knife_script_scene)
	add_child(knife_instance)
	
	# Manually initialize required references in the knife script
	knife_instance.terms_and_conditions_manager = self
	
	# Hide the real mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Start the mini-game popup part
	_start_evasion_popup()

func _start_evasion_popup() -> void:
	print("Terms & Conditions: Starting the move-and-stab mini-game!")
	
	# We use the existing hidden popup for the mini-game
	mini_game_popup = hidden_popup
	mini_game_popup.visible = true
	
	# Set target for the knife
	if knife_instance:
		knife_instance.popup_target = mini_game_popup
	
	# Reset position for mini-game to middle of screen
	var viewport_size = get_viewport_rect().size
	mini_game_popup.global_position = viewport_size / 2.0 - Vector2(125, 75)
	
	# Reset manager variables for the mini-game
	stab_count = 0
	
	# Set script for logic and motion
	var evasion_script = preload("res://core/scripts/popup_evasion.gd")
	mini_game_popup.set_script(evasion_script)
	
	# Ensure it can receive mouse clicks!
	mini_game_popup.mouse_default_cursor_shape = Control.CURSOR_ARROW
	mini_game_popup.mouse_filter = Control.MOUSE_FILTER_PASS

func _on_knife_stab() -> void:
	stab_count += 1
	print("Stab count: ", stab_count, "/", stab_required)
	
	if stab_count >= stab_required:
		_complete_game()

func _complete_game() -> void:
	current_phase = Phase.COMPLETE
	print("Terms & Conditions: Game complete!")
	
	# Restore normal cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Clean up
	if is_instance_valid(mini_game_popup):
		mini_game_popup.queue_free()
	
	if is_instance_valid(knife_instance):
		knife_instance.queue_free()
	
	# Check the box (visual only since we're leaving)
	if checkbox:
		checkbox.set_pressed_no_signal(true)
		checkbox.disabled = true
	
	# Small delay then clean up and let misery manager resume
	await get_tree().create_timer(1.0).timeout
	print("Terms & Conditions: Returning to Misery Manager")
	queue_free()
