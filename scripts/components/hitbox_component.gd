# Brief: Area2D hitbox that forwards incoming damage payloads to a HealthComponent.
class_name HitboxComponent
extends Area2D

@export_group("Damage")
@export var health_component_path: NodePath
@export var owner_group: StringName
@export var inflicted_damage: float = 0.0

var _health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not health_component_path.is_empty():
		_health_component = get_node_or_null(health_component_path) as HealthComponent

func get_damage() -> float:
	"""Expose contact damage when this hitbox is used offensively."""
	return inflicted_damage

func get_damage_source() -> StringName:
	"""Return team/group source for friendly-fire filtering."""
	return owner_group

func _on_area_entered(area: Area2D) -> void:
	if _health_component == null:
		return
	if area.has_method("get_damage") == false:
		return
	var source_group: StringName = StringName()
	if area.has_method("get_damage_source"):
		source_group = area.call("get_damage_source") as StringName
	if not owner_group.is_empty() and source_group == owner_group:
		return
	var damage: float = area.call("get_damage") as float
	if damage <= 0.0:
		return
	_health_component.apply_damage(damage)
