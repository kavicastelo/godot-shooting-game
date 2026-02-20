# Brief: Heads-up display for score, health, and game-over feedback via SignalBus.
class_name GameHud
extends Control

@onready var score_label: Label = $TopBar/StatsRow/ScoreLabel
@onready var health_label: Label = $TopBar/StatsRow/HealthLabel
@onready var game_over_label: Label = $OverlayCenter/GameOverLabel

func _ready() -> void:
	SignalBus.score_changed.connect(_on_score_changed)
	SignalBus.player_damaged.connect(_on_player_damaged)
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	_on_score_changed(0)
	_on_player_damaged(100.0, 100.0)
	game_over_label.visible = false

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_player_damaged(current_health: float, max_health: float) -> void:
	health_label.text = "HP: %d / %d" % [int(current_health), int(max_health)]

func _on_game_state_changed(_previous_state: int, new_state: int) -> void:
	game_over_label.visible = new_state == GameManager.GameState.GAMEOVER
	if game_over_label.visible:
		game_over_label.text = "GAME OVER\nPress R to Restart"
