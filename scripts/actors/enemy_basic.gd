# Brief: Basic enemy AI that chases player and emits score event on death.
class_name EnemyBasic
extends CharacterBody2D

@export_group("Config")
@export var enemy_stats: EnemyStats
@export var target_group: StringName = &"player"

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var health_component: HealthComponent = $Components/HealthComponent as HealthComponent
@onready var hitbox_component: HitboxComponent = $Components/HitboxComponent as HitboxComponent

var _target: Node2D

func _ready() -> void:
	health_component.died.connect(_on_died)
	if enemy_stats != null:
		health_component.max_health = enemy_stats.max_health
		health_component.reset_health()
		hitbox_component.inflicted_damage = enemy_stats.contact_damage
	SignalBus.enemy_spawned.emit(self)

func _physics_process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group(target_group) as Node2D
	if _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var direction: Vector2 = (_target.global_position - global_position).normalized()
	if navigation_agent.is_navigation_finished() == false:
		navigation_agent.target_position = _target.global_position
		var desired_position: Vector2 = navigation_agent.get_next_path_position()
		direction = (desired_position - global_position).normalized()
	var speed: float = enemy_stats.move_speed if enemy_stats != null else 160.0
	velocity = direction * speed
	move_and_slide()

func get_damage() -> float:
	"""Return contact damage for player hitbox interactions."""
	return enemy_stats.contact_damage if enemy_stats != null else 10.0

func get_damage_source() -> StringName:
	"""Return group used for friendly-fire filtering."""
	return StringName("enemy")

func _on_died() -> void:
	var score_value: int = enemy_stats.score_value if enemy_stats != null else 100
	SignalBus.enemy_died.emit(global_position, score_value)
	queue_free()
