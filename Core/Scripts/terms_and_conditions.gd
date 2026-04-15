extends Control

@onready var checkbox: CheckButton = $CheckButton
@onready var hidden_popup: Control = $popup
@onready var knife_area: Area2D = $Area2D/Knife
var popup_scene = preload("res://popup.tscn")

enum Phase {IDLE, POPUP_SPAM, EVASION, COMPLETE}
var current_phase: Phase = Phase.IDLE

# Popup spam
var popup_spam_timer: float = 0.0
var popup_spam_duration: float = 15.0
var spam_phase_active: bool = false
var active_popups: Array[Node] = []
var popup_count: int = 0

# Evasion phase
var evasion_popup: Control = null
var evasion_speed: float = 300.0
var evasion_direction: Vector2 = Vector2(1, 1)
var stab_count: int = 0
var stab_required: int = 3
var shake_timer: float = 0.0
var is_shaking: bool = false
var shake_origin: Vector2 = Vector2.ZERO

# Completion Card
var completion_card: Panel = null

# Knife (drag and hold)
var knife_texture: Texture2D = null

func _ready() -> void:
	checkbox.toggled.connect(_on_checkbox_clicked)
	# Initially hide the scene's knife icon until the invasion starts
	if is_instance_valid(knife_area):
		knife_area.set_active(false)
		if knife_area.get_parent() is Area2D:
			knife_area.get_parent().visible = false
	
	# Listen to Global for synchronization
	Global.knife_spawned.connect(_on_global_knife_spawned)
	Global.popup_spawn_requested.connect(_on_global_popup_requested)
	Global.invasion_started.connect(_on_invasion_started)
	Global.terms_and_conditions_completed.connect(_on_terms_completed)
	Global.knife_equipped_signal.connect(_on_global_knife_equipped)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Try to get the texture from the existing sprite in the scene
	var sprite = knife_area.get_node_or_null("Sprite2D")
	if sprite:
		knife_texture = sprite.texture
		
	# Hide built-in popup to start
	hidden_popup.visible = false

func _on_global_knife_spawned(pos: Vector2) -> void:
	if is_instance_valid(self ) and is_instance_valid(knife_area):
		# Ensure the knife itself is visible and active
		knife_area.visible = true
		knife_area.global_position = pos
		# This is critical! Ensure set_active is true.
		knife_area.set_active(true)
		# Force it to be pickable just in case.
		knife_area.input_pickable = true
		
		# Ensure parent Area2D (if it's a wrapper) is visible but NOT blocking
		if knife_area.get_parent() is Area2D:
			knife_area.get_parent().visible = true
			# CRITICAL: Parent Area2D should not capture events meant for children.
			knife_area.get_parent().input_pickable = false
		
		# Ensure BG stays behind everything
		if has_node("BG"):
			$BG.z_index = 0
		
		# Ensure self is on top of common workspace elements
		z_index = 5
		
		print("Knife script: Scene knife made visible at ", pos)

func _on_global_knife_equipped() -> void:
	# This triggers if the knife was picked up in another scene
	# We just need to make sure our local knife is ready to go
	var viewport = get_viewport_rect().size
	_on_global_knife_spawned(Vector2(60, viewport.y - 60))

func _on_global_popup_requested(is_first: bool) -> void:
	if is_instance_valid(self ):
		_spawn_popup(is_first)

func _on_invasion_started() -> void:
	if is_instance_valid(self ):
		print("TermsAndConditions: Invasion started signal received")
		_transition_to_evasion()
		# Use timer to ensure everything is ready
		get_tree().create_timer(0.1).timeout.connect(func():
			var viewport = get_viewport_rect().size
			_on_global_knife_spawned(Vector2(100, viewport.y - 100))
		)

func _on_terms_completed() -> void:
	# This function is now mostly a bridge, 
	# as _process_shake handles closing the scene.
	pass


func _on_checkbox_clicked(_toggled: bool) -> void:
	if Global.is_popup_spam_active or Global.is_invasion_active:
		return
	Global.request_popup(true)

func _spawn_popup(is_first: bool = false) -> void:
	if not is_instance_valid(self ): return
	
	var inst: Control
	if is_first:
		if not is_instance_valid(hidden_popup): return
		# Use the pre-existing popup for the first one
		inst = hidden_popup
		# Ensure it's not hidden behind background elements
		inst.top_level = true
		inst.z_index = 10
		inst.visible = true
	else:
		inst = popup_scene.instantiate()
		inst.top_level = true
		inst.z_index = 10
		add_child(inst)

	popup_count += 1
	active_popups.append(inst)

	# Position: stagger from center, offset gets larger as more spawn
	var viewport = get_viewport_rect().size
	var center = viewport / 2.0
	# The popup is 1152x648 (full screen) in popup.tscn,
	# but its content is a 400x200 ColorRect at the center.
	# To stagger the Content, we apply the offset to the whole overlay.
	var spread = min(popup_count * 30.0, 200.0)
	var offset = Vector2(
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	
	# We reset the position to (0,0) first, then add the offset.
	# If we set global_position, we're moving the top-left corner of the 1152x648 scene.
	inst.global_position = offset

	# Connect both buttons to spawn another popup via Global
	for btn_name in ["Yes", "No"]:
		var btn = inst.get_node_or_null(btn_name)
		if btn and not btn.pressed.is_connected(_on_popup_button_pressed):
			btn.pressed.connect(_on_popup_button_pressed)

func _on_popup_button_pressed() -> void:
	if Global.is_popup_spam_active:
		Global.request_popup(false)

# ─────────────────────────────────────────
# PHASE 2 — EVASION + KNIFE
# ─────────────────────────────────────────

func _transition_to_evasion() -> void:
	# Clear all popups except one — keep the first (hidden_popup)
	for popup in active_popups:
		if is_instance_valid(popup) and popup != hidden_popup:
			popup.queue_free()
	active_popups.clear()

	evasion_popup = hidden_popup
	if is_instance_valid(evasion_popup):
		evasion_popup.visible = true
		evasion_popup.mouse_filter = Control.MOUSE_FILTER_PASS
		
		# Internal node called "ColorRect" might be blocking clicks too
		var cr = evasion_popup.get_node_or_null("ColorRect")
		if cr: cr.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Transition internal phase
	current_phase = Phase.EVASION

	# Disconnect old button signals so they don't keep spawning
	if is_instance_valid(evasion_popup):
		for btn_name in ["Yes", "No"]:
			var btn = evasion_popup.get_node_or_null(btn_name)
			if btn:
				for conn in btn.pressed.get_connections():
					btn.pressed.disconnect(conn.callable)

	# Pick a random starting direction
	evasion_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	evasion_speed = 1200.0

	# Ensure the knife's parent is visible
	var area2d = get_node_or_null("Area2D")
	if area2d:
		area2d.visible = true

func _process(delta: float) -> void:
	if current_phase == Phase.EVASION:
		if is_shaking:
			_process_shake(delta)
		else:
			_process_evasion(delta)
			
		# Automatically attempt a stab if the knife is being dragged and overlaps the popup
		var knife = $Area2D/Knife
		if is_instance_valid(knife) and knife.get("is_dragging"):
			_attempt_stab()

# ─────────────────────────────────────────
# INPUT - drag and hold
# ─────────────────────────────────────────

func _input(event: InputEvent) -> void:
	# Keep the old explicit click-to-stab logic as backup, or relying on _process for constant tracking
	pass

func _draw() -> void:
	# No longer need custom draw since we are moving the actual Area2D
	pass

func _process_evasion(delta: float) -> void:
	if not is_instance_valid(evasion_popup):
		return

	var viewport = get_viewport_rect().size
	# The popup is actually a full screen overlay (1152x648) with centered content.
	# We need to treat it as a smaller box for movement.
	var content = evasion_popup.get_node_or_null("ColorRect") # Assuming the visual part is ColorRect
	var popup_size = Vector2(400, 200) # Default content size
	if content:
		popup_size = content.size

	var pos = evasion_popup.global_position
	pos += evasion_direction * evasion_speed * delta

	# Boundaries for the CENTERED content
	var margin_x = (viewport.x - popup_size.x) / 2.0
	var margin_y = (viewport.y - popup_size.y) / 2.0
	
	if pos.x + margin_x <= 0 or pos.x + margin_x + popup_size.x >= viewport.x:
		evasion_direction.x *= -1
		# Ensure it doesn't get stuck outside
		pos.x = clamp(pos.x, -margin_x, viewport.x - margin_x - popup_size.x)
	if pos.y + margin_y <= 0 or pos.y + margin_y + popup_size.y >= viewport.y:
		evasion_direction.y *= -1
		# Ensure it doesn't get stuck outside
		pos.y = clamp(pos.y, -margin_y, viewport.y - margin_y - popup_size.y)

	evasion_popup.global_position = pos

func _process_shake(delta: float) -> void:
	shake_timer -= delta
	if shake_timer <= 0:
		is_shaking = false
		if is_instance_valid(evasion_popup):
			evasion_popup.global_position = shake_origin
		
		# Now that shake is done, show the confirmation card
		_show_completion_card()
		return
	# Shake by offsetting randomly each frame
	var shake_strength = 8.0
	if is_instance_valid(evasion_popup):
		evasion_popup.global_position = shake_origin + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

# ─────────────────────────────────────────
# KNIFE
# ─────────────────────────────────────────

func _equip_knife() -> void:
	# Keep for internal logic if needed, but the visual/state is now handled via the Global signal
	pass

func _attempt_stab() -> void:
	if not is_instance_valid(evasion_popup) or is_shaking:
		return

	# Use the knife's position for the stab, not just the mouse, 
	# though they should be synonymous while dragging.
	var knife = $Area2D/Knife
	var knife_pos = knife.global_position
	
	# Find the visual content (ColorRect) in the popup
	var content = evasion_popup.get_node_or_null("ColorRect")
	if not content:
		return
	
	# Global rect of the UI content
	var popup_rect = content.get_global_rect()

	if popup_rect.has_point(knife_pos):
		stab_count += 1
		print("Stabbed! %d / %d" % [stab_count, stab_required])
		
		# Make the popup flash red temporarily
		evasion_popup.modulate = Color.RED
		
		# Teleport the popup to a new random location immediately 
		# so it's not stabbed multiple times in one frame
		var viewport = get_viewport_rect().size
		var popup_size = content.size
		var margin_x = (viewport.x - popup_size.x) / 2.0
		var margin_y = (viewport.y - popup_size.y) / 2.0
		evasion_popup.global_position = Vector2(
			randf_range(-margin_x, viewport.x - margin_x - popup_size.x),
			randf_range(-margin_y, viewport.y - margin_y - popup_size.y)
		)
		
		# Pick a new direction
		evasion_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		# Increase speed slightly
		evasion_speed += 75.0
		
		# Reset color after a brief moment
		get_tree().create_timer(0.1).timeout.connect(func():
			if is_instance_valid(evasion_popup):
				evasion_popup.modulate = Color.WHITE
		)

		if stab_count >= stab_required:
			_start_shake()

func _start_shake() -> void:
	is_shaking = true
	shake_timer = 1.2
	shake_origin = evasion_popup.global_position
	evasion_speed = 0.0

# ─────────────────────────────────────────
# COMPLETE
# ─────────────────────────────────────────

func _show_completion_card() -> void:
	# Disable the knife
	var knife = $Area2D/Knife
	if is_instance_valid(knife):
		knife.set_active(false)

	# Create UI overlay
	completion_card = Panel.new()
	completion_card.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	completion_card.custom_minimum_size = Vector2(450, 250)
	add_child(completion_card)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	completion_card.add_child(vbox)

	var msg = Label.new()
	msg.text = "Your obedience has been confirmed.\nPlease continue to return to your tasks."
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(msg)

	var btn = Button.new()
	btn.text = "Continue"
	btn.custom_minimum_size = Vector2(120, 40)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(_on_continue_button_pressed)
	vbox.add_child(btn)

	# Bring to front
	completion_card.z_index = 200

func _on_continue_button_pressed() -> void:
	_complete_game()

func _complete_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Emit completion signal to global state
	Global.complete_terms_and_conditions()
	
	if is_instance_valid(evasion_popup):
		evasion_popup.queue_free()
	if is_instance_valid(completion_card):
		completion_card.queue_free()
	if checkbox:
		checkbox.set_pressed_no_signal(true)
		checkbox.disabled = true
	# Give short feedback before dismissing scene
	await get_tree().create_timer(0.4).timeout
	queue_free()
