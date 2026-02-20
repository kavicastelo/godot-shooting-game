# Brief: Global event hub for decoupled cross-scene communication.
extends Node

signal player_spawned(player: CharacterBody2D)
signal player_damaged(current_health: float, max_health: float)
signal player_died()
signal enemy_spawned(enemy: CharacterBody2D)
signal enemy_died(enemy_position: Vector2, score_value: int)
signal projectile_fired(origin: Vector2, direction: Vector2, source_group: StringName)
signal score_changed(new_score: int)
signal game_state_changed(previous_state: int, new_state: int)
signal restart_requested()
