# Brief: Handles player/enemy spawning based on game state and wave resources.
class_name SpawnManager
extends Node

@export_group("Scenes")
@export var player_scene: PackedScene
@export var player_parent_path: NodePath
@export var enemy_parent_path: NodePath
@export var spawn_points_path: NodePath

@export_group("Wave")
@export var wave: SpawnWave

var _elapsed: float = 0.0
var _player_instance: Node2D
var _is_playing_state: bool = false

@onready var _player_parent: Node = get_node(player_parent_path)
@onready var _enemy_parent: Node = get_node(enemy_parent_path)
@onready var _spawn_points_root: Node = get_node(spawn_points_path)
@onready var _game_manager: GameManager = get_parent().get_node("GameManager") as GameManager

func _ready() -> void:
	SignalBus.game_state_changed.connect(_on_game_state_changed)
	SignalBus.restart_requested.connect(_on_restart_requested)
	_spawn_player()

func _process(delta: float) -> void:
	if wave == null or _is_playing_state == false:
		return
	if _enemy_parent.get_child_count() >= wave.max_alive_enemies:
		return
	_elapsed += delta
	if _elapsed >= wave.spawn_interval:
		_elapsed = 0.0
		_spawn_enemy()

func _spawn_player() -> void:
	if player_scene == null:
		return
	if _player_instance != null and is_instance_valid(_player_instance):
		_player_instance.queue_free()
	_player_instance = player_scene.instantiate() as Node2D
	_player_parent.add_child(_player_instance)
	_player_instance.global_position = Vector2(640.0, 360.0)

func _spawn_enemy() -> void:
	if wave == null or wave.enemy_scene == null:
		return
	var enemy: Node2D = wave.enemy_scene.instantiate() as Node2D
	_enemy_parent.add_child(enemy)
	var spawn_points: Array[Node] = _spawn_points_root.get_children()
	if spawn_points.is_empty():
		enemy.global_position = Vector2(120.0, 120.0)
		return
	var marker: Marker2D = spawn_points[randi_range(0, spawn_points.size() - 1)] as Marker2D
	enemy.global_position = marker.global_position

func _on_game_state_changed(_previous_state: int, new_state: int) -> void:
	_elapsed = 0.0
	_is_playing_state = new_state == GameManager.GameState.PLAYING

func _on_restart_requested() -> void:
	for enemy: Node in _enemy_parent.get_children():
		enemy.queue_free()
	_spawn_player()
	if _game_manager != null:
		_game_manager.change_state(GameManager.GameState.START)
