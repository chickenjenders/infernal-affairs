extends Area2D

signal knife_equipped

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	input_pickable = true
	# Area2D doesn't have a mouse_filter property; that's for Control nodes.
	# We use input_pickable which you already have.
	
	if sprite:
		sprite.pause()
		sprite.frame = 0
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)

func _input(eventAt: InputEvent) -> void:
	if eventAt is InputEventMouseButton and eventAt.button_index == MOUSE_BUTTON_LEFT and eventAt.pressed:
		var mouse_pos = get_global_mouse_position()
		# Direct distance check to the collision center as a fallback
		# since the knife has a known position
		var capsule_center = Vector2(117, 720) # Center of your CollisionShape2D
		# Account for any global transformation of the knife root
		var global_center = to_global(capsule_center)
		
		# If the click is within 100 pixels of the capsule center
		if mouse_pos.distance_to(global_center) < 100:
			print("Knife script: Click detected via manual global distance check")
			equip()
			get_viewport().set_input_as_handled()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Keep the original event for redundancy
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Knife script: Click detected via _input_event")
		equip()

func equip() -> void:
	print("Knife script: Equipping knife...")
	
	# The physical knife icon is now handled via TermsAndConditions.gd dragging logic
	# We don't want to use a giant texture as a custom cursor.
	# Just hide this world object and notify Global.
	
	Global.equip_knife()
	visible = false
	print("Knife script: Equipped via Global")

func _on_mouse_entered() -> void:
	if sprite:
		sprite.frame = 1

func _on_mouse_exited() -> void:
	if sprite:
		sprite.frame = 0
