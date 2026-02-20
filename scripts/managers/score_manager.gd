# Brief: Tracks score from enemy death events and rebroadcasts updates.
class_name ScoreManager
extends Node

var score: int = 0

func _ready() -> void:
	SignalBus.enemy_died.connect(_on_enemy_died)
	SignalBus.restart_requested.connect(_on_restart_requested)

func _on_enemy_died(_enemy_position: Vector2, score_value: int) -> void:
	score += score_value
	SignalBus.score_changed.emit(score)

func _on_restart_requested() -> void:
	score = 0
	SignalBus.score_changed.emit(score)
