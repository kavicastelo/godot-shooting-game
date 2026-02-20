# Brief: Player controller for movement, mouse aiming, and fire-rate throttled shooting.
class_name PlayerController
extends CharacterBody2D

@export_group("Movement")
@export var move_speed: float = 320.0

@export_group("Combat")
@export var weapon_stats: WeaponStats
@export var muzzle_path: NodePath

@onready var muzzle: Marker2D = get_node(muzzle_path) as Marker2D
@onready var health_component: HealthComponent = $Components/HealthComponent as HealthComponent

var _fire_cooldown: float = 0.0

func _ready() -> void:
	health_component.damaged.connect(_on_health_damaged)
	health_component.died.connect(_on_health_died)
	SignalBus.player_spawned.emit(self)
	SignalBus.player_damaged.emit(health_component.current_health, health_component.max_health)

func _physics_process(delta: float) -> void:
	_process_movement()
	look_at(get_global_mouse_position())
	_fire_cooldown = max(_fire_cooldown - delta, 0.0)
	if Input.is_action_pressed("fire"):
		_try_fire()

func _process_movement() -> void:
	"""Read WASD input and move the player body."""
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * move_speed
	move_and_slide()

func _try_fire() -> void:
	"""Spawn projectile via SignalBus when fire cooldown allows."""
	if weapon_stats == null or _fire_cooldown > 0.0:
		return
	var direction: Vector2 = (get_global_mouse_position() - muzzle.global_position).normalized()
	SignalBus.projectile_fired.emit(muzzle.global_position, direction, StringName("player"))
	_fire_cooldown = 1.0 / weapon_stats.fire_rate

func _on_health_damaged(current_health: float, max_health: float) -> void:
	SignalBus.player_damaged.emit(current_health, max_health)

func _on_health_died() -> void:
	SignalBus.player_died.emit()
	queue_free()
