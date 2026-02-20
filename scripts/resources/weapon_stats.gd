# Brief: Weapon tuning data for actor fire behavior.
class_name WeaponStats
extends Resource

@export_group("Firing")
@export var fire_rate: float = 5.0
@export var projectile_speed: float = 800.0
@export var projectile_damage: float = 20.0
@export var projectile_scene: PackedScene
