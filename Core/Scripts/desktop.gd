extends Control

var current_label: Label = null
var label_scene = preload("res://common/ui/interaction_label.tscn")

func _ready() -> void:
	var misery = $IconDock/MiseryManager
	var files = $IconDock/Files
	var email = $IconDock/Email
	var recycle = $IconDock/Recycle
	
	if misery:
		misery.mouse_entered.connect(_on_icon_mouse_entered.bind(misery, "Misery Manager"))
		misery.mouse_exited.connect(_on_icon_mouse_exited)
	if files:
		files.mouse_entered.connect(_on_icon_mouse_entered.bind(files, "Empty Folder"))
		files.mouse_exited.connect(_on_icon_mouse_exited)
	if email:
		email.mouse_entered.connect(_on_icon_mouse_entered.bind(email, "Email"))
		email.mouse_exited.connect(_on_icon_mouse_exited)
	if recycle:
		recycle.mouse_entered.connect(_on_icon_mouse_entered.bind(recycle, "Recycle"))
		recycle.mouse_exited.connect(_on_icon_mouse_exited)

func _on_icon_mouse_entered(icon_node: Control, text: String) -> void:
	if current_label:
		current_label.queue_free()
		current_label = null
	
	current_label = label_scene.instantiate()
	add_child(current_label)
	current_label.text = text
	
	# Position label to the right of the icon with an offset
	var rect = icon_node.get_global_rect()
	var right_edge = rect.position.x + rect.size.x
	var center_y = rect.position.y + rect.size.y / 2.0
	current_label.global_position = Vector2(right_edge + 10, center_y - 15)
	
	current_label.modulate.a = 0
	var tween = current_label.create_tween()
	tween.tween_property(current_label, "modulate:a", 1.0, 0.2)
	
func _on_icon_mouse_exited() -> void:
	if current_label:
		var tween = current_label.create_tween()
		tween.tween_property(current_label, "modulate:a", 0.0, 0.2)
		tween.tween_callback(current_label.queue_free)
		current_label = null

func _on_misery_manager_pressed() -> void:
	var misery_manager_scene = load("res://misery_manager/scenes/misery_manager.tscn")
	var misery_manager_instance = misery_manager_scene.instantiate()
	add_child(misery_manager_instance)
