# Brief: Orchestrates game loop state transitions and restart requests.
class_name GameManager
extends Node

enum GameState {
	START,
	PLAYING,
	GAMEOVER
}

var current_state: int = -1

func _ready() -> void:
	SignalBus.player_died.connect(_on_player_died)
	change_state(GameState.START)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and current_state == GameState.GAMEOVER:
		SignalBus.restart_requested.emit()

func change_state(next_state: GameState) -> void:
	"""Transition to a new game state and emit a global notification."""
	if current_state == next_state:
		return
	var previous_state: int = current_state
	current_state = next_state
	SignalBus.game_state_changed.emit(previous_state, current_state)
	match current_state:
		GameState.START:
			_enter_start()
		GameState.PLAYING:
			_enter_playing()
		GameState.GAMEOVER:
			_enter_gameover()

func _enter_start() -> void:
	SignalBus.score_changed.emit(0)
	change_state(GameState.PLAYING)

func _enter_playing() -> void:
	pass

func _enter_gameover() -> void:
	pass

func _on_player_died() -> void:
	change_state(GameState.GAMEOVER)
