extends Area2D

signal knife_equipped

func _ready() -> void:
	input_pickable = true
	# Area2D doesn't have a mouse_filter property; that's for Control nodes.
	# We use input_pickable which you already have.

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
	
	# Try to load the texture again (ensure path is correct)
	var knife_texture = load("res://assets/icons/knife.png")
	
	if knife_texture:
		# Use a hotspot that makes sense for a knife (the tip of the blade)
		# Usually (0,0) is top-left, but you might want to center it or 
		# use the sharp end. Common for 64x64 is (32,32).
		Input.set_custom_mouse_cursor(knife_texture, Input.CURSOR_ARROW, Vector2(16, 16))
		print("Knife script: Cursor changed successfully")
		
		# Emit the signal so TermsAndConditions knows we're ready
		knife_equipped.emit()
		
		# Hide the physical knife sprite
		visible = false
	else:
		# FALLBACK: Try a secondary path if the first one failed
		print("Error: Could not load knife texture at res://assets/icons/knife.png")
