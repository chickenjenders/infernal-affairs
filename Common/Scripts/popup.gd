extends Control


func _on_submit_button_pressed() -> void:
	# Since password_reset and security_questions are added to root (not nested),
	# we need to find and remove them from root's children
	var root = get_tree().root
	var nodes_to_remove = []
	
	for child in root.get_children():
		var node_name = child.name.to_lower()
		# Find password_reset, security_questions, and popup scenes
		if node_name.contains("password") or node_name.contains("security") or node_name.contains("popup"):
			nodes_to_remove.append(child)
	
	# Remove all found scenes
	for node in nodes_to_remove:
		node.queue_free()
