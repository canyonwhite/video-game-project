extends "res://src/scripts/player.gd"

signal health_changed(value: float)
@export var max_health: float = 100.0
var health: float = 100.0

func _ready() -> void:
	super._ready()
	add_to_group("player")
	health = max_health
	collision_layer = 2
	collision_mask = 5
	$MeshInstance3D.hide()

func _physics_process(delta: float) -> void:
	if health <= 0:
		velocity = Vector3.ZERO
		return
	super._physics_process(delta)

func take_damage(amount: float) -> void:
	health = maxf(health - amount, 0)
	health_changed.emit(health)
	if health <= 0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func restore_health() -> void:
	health = max_health
	health_changed.emit(health)
