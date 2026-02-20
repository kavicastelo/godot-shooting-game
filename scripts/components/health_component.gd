# Brief: Reusable health logic for actors with typed damage/death signals.
class_name HealthComponent
extends Node

signal damaged(current_health: float, max_health: float)
signal died()

@export_group("Health")
@export var max_health: float = 100.0

var current_health: float = 0.0

func _ready() -> void:
	current_health = max_health

func reset_health() -> void:
	"""Restore health to maximum and emit a damage update for UI sync."""
	current_health = max_health
	damaged.emit(current_health, max_health)

func apply_damage(amount: float) -> void:
	"""Apply incoming damage and emit death when health reaches zero."""
	if amount <= 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	damaged.emit(current_health, max_health)
	if is_zero_approx(current_health):
		died.emit()
