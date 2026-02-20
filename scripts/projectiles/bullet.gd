# Brief: Player projectile with typed velocity, damage payload, and cleanup behavior.
class_name Bullet
extends Area2D

@export_group("Projectile")
@export var speed: float = 900.0
@export var damage: float = 10.0
@export var lifetime_seconds: float = 2.0

var _direction: Vector2 = Vector2.RIGHT
var _lifetime: float = 0.0
var _source_group: StringName

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func initialize(direction: Vector2, bullet_speed: float, bullet_damage: float, source_group: StringName) -> void:
	"""Initialize velocity direction and stats after spawn."""
	_direction = direction.normalized()
	speed = bullet_speed
	damage = bullet_damage
	_source_group = source_group

func get_damage() -> float:
	"""Expose projectile damage for hitbox components."""
	return damage

func get_damage_source() -> StringName:
	"""Return shooter group for friendly-fire filtering."""
	return _source_group

func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta
	_lifetime += delta
	if _lifetime >= lifetime_seconds:
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()
