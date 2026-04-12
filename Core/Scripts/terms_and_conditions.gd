extends Control

@onready var checkbox: CheckButton = $CheckButton
@onready var hidden_popup: Control = $Control
@onready var popup_scene = preload("res://popup.tscn")

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
var knife: Node2D
var mini_game_popup: Node

func _ready() -> void:
	checkbox.toggled.connect(_on_checkbox_clicked)

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
	if popup_spam_timer >= popup_spam_duration:
		spam_phase_active = false
		_transition_to_mini_game()
		return
	
	if spam_phase_active:
		popup_spam_timer += delta

func _spawn_popup() -> void:
	var popup_instance = popup_scene.instantiate()
	add_child(popup_instance)
	
	# Get the base position to stagger from (either center or the previous popup)
	var base_pos: Vector2
	if active_popups.is_empty():
		var viewport_size = get_viewport_rect().size
		base_pos = viewport_size / 2.0 - Vector2(519, 209)
	else:
		base_pos = active_popups[-1].global_position
	
	active_popups.append(popup_instance)
	
	# Reset local position to zero so global_position works correctly
	popup_instance.position = Vector2.ZERO
	
	# Stagger popups relative to the PREVIOUS one to create a cascading stack
	# Added more variation and randomness to the stagger direction
	var stagger_x = randf_range(-60, 80)
	var stagger_y = randf_range(-60, 80)
	
	# Ensure there's always SOME minimum distance so they don't overlap perfectly
	if abs(stagger_x) < 20: stagger_x = 20 * (1 if stagger_x >= 0 else -1)
	if abs(stagger_y) < 20: stagger_y = 20 * (1 if stagger_y >= 0 else -1)
	
	popup_instance.global_position = base_pos + Vector2(stagger_x, stagger_y)
	
	# Keep within screen bounds slightly
	var screen = get_viewport_rect().size
	popup_instance.global_position.x = clamp(popup_instance.global_position.x, 20, screen.x - 550)
	popup_instance.global_position.y = clamp(popup_instance.global_position.y, 20, screen.y - 320)
	
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
	print("Terms & Conditions: Transitioning to mini-game phase")
	
	# Clear all active popups
	for popup in active_popups:
		if is_instance_valid(popup):
			if popup == hidden_popup:
				popup.visible = false
			else:
				popup.queue_free()
	active_popups.clear()
	
	# We use the existing hidden popup for the mini-game
	mini_game_popup = hidden_popup
	mini_game_popup.visible = true
	
	# Reset position for mini-game
	mini_game_popup.global_position = get_viewport_rect().size / 2.0 - Vector2(250, 150)
	
	# Add evasion script to the popup's script
	var evasion_script = preload("res://core/scripts/popup_evasion.gd")
	mini_game_popup.set_script(evasion_script)
	
	# Spawn knife
	_spawn_knife()
	
	# Equip knife automatically for mini-game
	await get_tree().process_frame
	if is_instance_valid(knife):
		knife.equip()

func _spawn_knife() -> void:
	knife = Node2D.new()
	knife.name = "Knife"
	add_child(knife)
	
	# Add knife script for proximity detection and visuals
	var knife_script = preload("res://core/scripts/knife.gd")
	knife.set_script(knife_script)
	knife.terms_and_conditions_manager = self
	knife.popup_target = mini_game_popup

func _on_knife_stab() -> void:
	stab_count += 1
	print("Stab count: ", stab_count, "/", stab_required)
	
	if stab_count >= stab_required:
		_complete_game()

func _complete_game() -> void:
	current_phase = Phase.COMPLETE
	print("Terms & Conditions: Game complete!")
	
	# Clean up
	if is_instance_valid(mini_game_popup):
		if mini_game_popup == hidden_popup:
			mini_game_popup.visible = false
			# Restore original script if necessary or just let it die with queue_free
		else:
			mini_game_popup.queue_free()
	if is_instance_valid(knife):
		knife.queue_free()
	
	# Small delay then clean up and let misery manager resume
	await get_tree().create_timer(0.5).timeout
	print("Terms & Conditions: Returning to Misery Manager")
	queue_free()
