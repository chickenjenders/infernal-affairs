extends Node

signal knife_spawned(position: Vector2)
signal knife_equipped_signal
signal popup_spawn_requested(is_first: bool)
signal invasion_started
signal terms_and_conditions_completed

var current_employee_index: int = 0
var is_knife_equipped: bool = false
var terms_accepted: bool = false

# Phase flags
var is_popup_spam_active: bool = false
var is_invasion_active: bool = false

# Timers
var spam_duration: float = 15.0
var current_spam_timer: float = 0.0

func _process(delta: float) -> void:
	if is_popup_spam_active:
		current_spam_timer += delta
		if current_spam_timer >= spam_duration:
			start_invasion()

func spawn_knife(pos: Vector2) -> void:
	knife_spawned.emit(pos)

func equip_knife() -> void:
	is_knife_equipped = true
	knife_equipped_signal.emit()

func request_popup(is_first: bool = false) -> void:
	if is_first:
		is_popup_spam_active = true
		current_spam_timer = 0.0
	popup_spawn_requested.emit(is_first)

func start_invasion() -> void:
	if is_invasion_active:
		return
	print("Global: Starting invasion phase")
	is_popup_spam_active = false
	is_invasion_active = true
	invasion_started.emit()

func complete_terms_and_conditions() -> void:
	is_invasion_active = false
	terms_accepted = true
	terms_and_conditions_completed.emit()
