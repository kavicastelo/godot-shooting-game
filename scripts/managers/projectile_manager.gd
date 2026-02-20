# Brief: Spawns and initializes projectiles from bus fire events.
class_name ProjectileManager
extends Node

@export_group("Projectile")
@export var projectile_parent_path: NodePath
@export var player_weapon_stats: WeaponStats

@onready var _projectile_parent: Node = get_node(projectile_parent_path)

func _ready() -> void:
	SignalBus.projectile_fired.connect(_on_projectile_fired)

func _on_projectile_fired(origin: Vector2, direction: Vector2, source_group: StringName) -> void:
	if source_group != StringName("player"):
		return
	if player_weapon_stats == null or player_weapon_stats.projectile_scene == null:
		return
	var bullet: Bullet = player_weapon_stats.projectile_scene.instantiate() as Bullet
	_projectile_parent.add_child(bullet)
	bullet.global_position = origin
	bullet.initialize(direction, player_weapon_stats.projectile_speed, player_weapon_stats.projectile_damage, source_group)
