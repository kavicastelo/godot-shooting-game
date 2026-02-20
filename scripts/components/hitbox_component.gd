# Brief: Area2D hitbox that forwards incoming damage payloads to a HealthComponent.
class_name HitboxComponent
extends Area2D

@export_group("Damage")
@export var health_component_path: NodePath

var _health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not health_component_path.is_empty():
		_health_component = get_node_or_null(health_component_path) as HealthComponent

func _on_area_entered(area: Area2D) -> void:
	if _health_component == null:
		return
	if area.has_method("get_damage"):
		var damage: float = area.call("get_damage") as float
		_health_component.apply_damage(damage)
