extends Control

@onready var checkbox: CheckButton = $CheckButton
@onready var hidden_popup: Control = $popup
@onready var knife_area: Area2D = $knife
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

# Knife (cursor)
var knife_equipped: bool = false
var knife_texture: Texture2D = null
var knife_visible: bool = false

func _ready() -> void:
	checkbox.toggled.connect(_on_checkbox_clicked)
	# Hide the scene knife icon until needed
	knife_area.visible = false
	knife_area.input_pickable = false
	knife_area.input_event.connect(_on_knife_area_clicked)
	
	# Listen to Global for synchronization
	Global.knife_spawned.connect(_on_global_knife_spawned)
	Global.knife_equipped_signal.connect(_on_global_knife_equipped)
	Global.popup_spawn_requested.connect(_on_global_popup_requested)
	Global.invasion_started.connect(_on_invasion_started)
	Global.terms_and_conditions_completed.connect(_on_terms_completed)

	# Preload knife texture for cursor drawing
	knife_texture = load("res://assets/icons/knife.png")
	# Hide built-in popup to start
	hidden_popup.visible = false

func _on_global_knife_spawned(pos: Vector2) -> void:
	if is_instance_valid(self ) and is_instance_valid(knife_area):
		knife_area.global_position = pos
		knife_area.visible = true
		knife_area.input_pickable = true

func _on_global_knife_equipped() -> void:
	if is_instance_valid(self ) and is_instance_valid(knife_area):
		knife_equipped = true
		knife_area.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_process_input(true)
		queue_redraw()

func _on_global_popup_requested(is_first: bool) -> void:
	if is_instance_valid(self ):
		_spawn_popup(is_first)

func _on_invasion_started() -> void:
	if is_instance_valid(self ):
		_transition_to_evasion()

func _on_terms_completed() -> void:
	if is_instance_valid(self ):
		_complete_game()

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
		hidden_popup.visible = true
	else:
		inst = popup_scene.instantiate()
		add_child(inst)

	popup_count += 1
	active_popups.append(inst)

	# Position: stagger from center, offset gets larger as more spawn
	var viewport = get_viewport_rect().size
	var center = viewport / 2.0
	var popup_size = Vector2(250, 150)
	var spread = min(popup_count * 30.0, 200.0)
	var offset = Vector2(
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	var target_pos = center - popup_size / 2.0 + offset
	target_pos.x = clamp(target_pos.x, 10, viewport.x - popup_size.x - 10)
	target_pos.y = clamp(target_pos.y, 10, viewport.y - popup_size.y - 10)
	inst.global_position = target_pos

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
	evasion_popup.visible = true
	evasion_popup.top_level = true

	var viewport = get_viewport_rect().size
	evasion_popup.global_position = viewport / 2.0 - Vector2(125, 75)

	# Disconnect old button signals so they don't keep spawning
	for btn_name in ["Yes", "No"]:
		var btn = evasion_popup.get_node_or_null(btn_name)
		if btn:
			# Disconnect all existing connections
			for conn in btn.pressed.get_connections():
				btn.pressed.disconnect(conn.callable)

	# Pick a random starting direction
	evasion_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

	# Notify Global to spawn the knife
	Global.spawn_knife(Vector2(60, get_viewport_rect().size.y - 60))

func _process(delta: float) -> void:
	if Global.is_invasion_active:
		if is_shaking:
			_process_shake(delta)
		else:
			_process_evasion(delta)

# ─────────────────────────────────────────
# INPUT - draw knife cursor
# ─────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if knife_equipped and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_attempt_stab()

func _draw() -> void:
	if knife_equipped and knife_texture:
		var mouse = get_local_mouse_position()
		var knife_size = Vector2(48, 48)
		draw_texture_rect(knife_texture, Rect2(mouse - knife_size / 2, knife_size), false)

func _process_evasion(delta: float) -> void:
	if not is_instance_valid(evasion_popup):
		return

	var viewport = get_viewport_rect().size
	var popup_size = evasion_popup.size
	var pos = evasion_popup.global_position

	pos += evasion_direction * evasion_speed * delta

	# Bounce off edges
	if pos.x <= 0 or pos.x + popup_size.x >= viewport.x:
		evasion_direction.x *= -1
		pos.x = clamp(pos.x, 0, viewport.x - popup_size.x)
	if pos.y <= 0 or pos.y + popup_size.y >= viewport.y:
		evasion_direction.y *= -1
		pos.y = clamp(pos.y, 0, viewport.y - popup_size.y)

	evasion_popup.global_position = pos

func _process_shake(delta: float) -> void:
	shake_timer -= delta
	if shake_timer <= 0:
		is_shaking = false
		evasion_popup.global_position = shake_origin
		Global.complete_terms_and_conditions()
		return
	# Shake by offsetting randomly each frame
	var shake_strength = 8.0
	evasion_popup.global_position = shake_origin + Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)

# ─────────────────────────────────────────
# KNIFE
# ─────────────────────────────────────────

func _on_knife_area_clicked(_viewport: Node, event: InputEvent, _shape: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Global.equip_knife()

func _equip_knife() -> void:
	# Keep for internal logic if needed, but the visual/state is now handled via the Global signal
	pass
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process_input(true)
	queue_redraw()

func _attempt_stab() -> void:
	if not is_instance_valid(evasion_popup) or is_shaking:
		return

	var mouse = get_global_mouse_position()
	var popup_rect = Rect2(evasion_popup.global_position, evasion_popup.size)

	if popup_rect.has_point(mouse):
		stab_count += 1
		print("Stabbed! %d / %d" % [stab_count, stab_required])
		# Flash the popup red on hit
		evasion_popup.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(evasion_popup):
			evasion_popup.modulate = Color.WHITE

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

func _complete_game() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if is_instance_valid(evasion_popup):
		evasion_popup.queue_free()
	if checkbox:
		checkbox.set_pressed_no_signal(true)
		checkbox.disabled = true
	await get_tree().create_timer(0.8).timeout
	queue_free()
