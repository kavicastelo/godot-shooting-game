# Brief: Wave settings used by SpawnManager to control cadence.
class_name SpawnWave
extends Resource

@export_group("Wave")
@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var max_alive_enemies: int = 15
