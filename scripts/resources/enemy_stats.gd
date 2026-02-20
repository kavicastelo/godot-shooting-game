# Brief: Enemy tuning data for speed, durability, and score payout.
class_name EnemyStats
extends Resource

@export_group("Enemy")
@export var max_health: float = 40.0
@export var move_speed: float = 180.0
@export var contact_damage: float = 10.0
@export var score_value: int = 100
