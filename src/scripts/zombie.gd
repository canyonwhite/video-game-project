extends CharacterBody3D
class_name PrototypeZombie

signal attack_landed(target: Node3D, damage: float)
signal state_changed(state: String)

@export var chase_speed: float = 1.4
@export var acceleration: float = 5.0
@export var turn_speed: float = 3.0
@export var sight_range: float = 12.0
@export var field_of_view: float = 100.0
@export var vertical_field_of_view: float = 120.0
@export_range(0.0, 5.0) var recognition_duration: float = 1.0
@export_range(0.1, 1.0) var recognition_visibility_threshold: float = 0.5
@export_flags_3d_physics var sight_mask: int = 3
@export var memory_duration: float = 7.0
@export var search_duration: float = 2.0
@export var attack_range: float = 1.35
@export var attack_damage: float = 15.0
@export var attack_windup: float = 0.65
@export var attack_recovery: float = 1.1
@export var max_health: float = 60.0
@export var model_scene: PackedScene

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var eyes: Marker3D = $Eyes
@onready var brain: BTPlayer = $BTPlayer
@onready var label: Label3D = $StateLabel

var target: Node3D
var health: float
var dead: bool = false
var can_see_target: bool = false
var memory_left: float = 0.0
var last_seen_position := Vector3.ZERO
var desired_velocity := Vector3.ZERO
var state: String = "IDLE"
var attacking: bool = false
var attack_elapsed: float = 0.0
var hit_checked: bool = false
var stagger_left: float = 0.0
var search_left: float = 0.0
var searching: bool = false
var repath_timer: float = 0.0
var navigation_ready: bool = false
var hit_count: int = 0
var visibility_fraction: float = 0.0
var recognition_elapsed: float = 0.0
var target_recognized: bool = false
var recognizing: bool = false

func _ready() -> void:
	health = max_health
	target = get_tree().get_first_node_in_group("player") as Node3D
	brain.update_mode = BTPlayer.MANUAL
	if model_scene != null:
		$Visuals/Placeholder.hide()
		$Visuals.add_child(model_scene.instantiate())
	await get_tree().physics_frame
	navigation_ready = true

func _physics_process(delta: float) -> void:
	desired_velocity = Vector3.ZERO
	memory_left = maxf(memory_left - delta, 0.0)
	stagger_left = maxf(stagger_left - delta, 0.0)
	repath_timer -= delta
	visibility_fraction = target_visibility() if not dead else 0.0
	can_see_target = visibility_fraction > 0.0
	if can_see_target:
		last_seen_position = target.global_position
		memory_left = memory_duration
		searching = false
	# Recognition requires consecutive ticks with almost the whole body visible.
	# A glimpse records a location but cannot unlock chase or an attack.
	var mostly_visible := visibility_fraction >= recognition_visibility_threshold
	recognizing = mostly_visible and not target_recognized and stagger_left <= 0.0
	if mostly_visible and stagger_left <= 0.0:
		if not target_recognized:
			recognition_elapsed += delta
			if recognition_elapsed + 0.000001 >= recognition_duration:
				target_recognized = true
				recognizing = false
	else:
		recognition_elapsed = 0.0
		target_recognized = false
		recognizing = false
	brain.blackboard.set_var("target", target)
	brain.blackboard.set_var("visible", can_see_target)
	brain.blackboard.set_var("recognized", target_recognized)
	brain.blackboard.set_var("recognizing", recognizing)
	brain.blackboard.set_var("memory_left", memory_left)
	brain.blackboard.set_var("last_seen_position", last_seen_position)
	brain.update(delta)
	var horizontal := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity, acceleration * delta)
	if attacking or dead or stagger_left > 0.0 or recognizing:
		horizontal = Vector3.ZERO
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif velocity.y < 0:
		velocity.y = 0
	move_and_slide()
	label.text = "%s\nHP %.0f" % [state, health]

func target_visibility() -> float:
	if not is_instance_valid(target):
		return 0.0
	if target.get("health") != null and target.get("health") <= 0:
		return 0.0
	var height := 1.8
	var half_width := 0.18
	var collision := target.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null and collision.shape is CapsuleShape3D:
		height = (collision.shape as CapsuleShape3D).height
		half_width = (collision.shape as CapsuleShape3D).radius * 0.6
	# Nine samples across upper body, torso, and legs. Width is measured
	# across the observer's view; crouching uses the current capsule height.
	var visible_samples := 0
	for height_ratio in [0.9, 0.6, 0.25]:
		for side in [-1.0, 0.0, 1.0]:
			var aim: Vector3 = target.global_position + Vector3.UP * height * height_ratio + global_basis.x * half_width * side
			if _sample_is_visible(aim):
				visible_samples += 1
	return float(visible_samples) / 9.0

func target_is_visible() -> bool:
	return target_visibility() > 0.0

func _sample_is_visible(aim: Vector3) -> bool:
	var offset := aim - eyes.global_position
	if offset.length() > sight_range:
		return false
	var flat := Vector3(offset.x, 0, offset.z)
	if absf(atan2(offset.y, flat.length())) > deg_to_rad(vertical_field_of_view * 0.5):
		return false
	if flat.length_squared() > 0.001:
		if (-global_basis.z).dot(flat.normalized()) < cos(deg_to_rad(field_of_view * 0.5)):
			return false
	var query := PhysicsRayQueryParameters3D.create(eyes.global_position, aim, sight_mask, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == target

func can_attack() -> bool:
	return target_recognized and is_instance_valid(target) and can_see_target and global_position.distance_to(target.global_position) <= attack_range

func tick_recognize() -> void:
	set_state("RECOGNIZE")

func tick_attack(delta: float) -> void:
	if not attacking:
		attacking = true
		attack_elapsed = 0.0
		hit_checked = false
		searching = false
	attack_elapsed += delta
	set_state("WINDUP" if attack_elapsed < attack_windup else "RECOVERY")
	if not hit_checked and attack_elapsed >= attack_windup:
		hit_checked = true
		if can_attack():
			var direction := target.global_position - global_position
			direction.y = 0
			if direction.length_squared() > 0.001 and (-global_basis.z).dot(direction.normalized()) > 0.5:
				hit_count += 1
				attack_landed.emit(target, attack_damage)
				if target.has_method("take_damage"):
					target.call("take_damage", attack_damage)
	if attack_elapsed >= attack_windup + attack_recovery:
		attacking = false

func tick_chase(delta: float) -> void:
	searching = false
	set_state("CHASE")
	move_to(last_seen_position, delta)

func tick_investigate(delta: float) -> void:
	if searching:
		set_state("SEARCH")
		rotation.y += delta * 0.7
		search_left -= delta
		if search_left <= 0:
			memory_left = 0
			searching = false
		return
	set_state("INVESTIGATE")
	move_to(last_seen_position, delta)
	var flat := last_seen_position - global_position
	flat.y = 0
	if flat.length() < 0.65:
		searching = true
		search_left = search_duration

func move_to(destination: Vector3, delta: float) -> void:
	if not navigation_ready:
		return
	if repath_timer <= 0:
		navigation.target_position = destination
		repath_timer = 0.25
	if navigation.is_navigation_finished():
		return
	var direction := navigation.get_next_path_position() - global_position
	direction.y = 0
	if direction.length_squared() > 0.001:
		direction = direction.normalized()
		rotation.y = rotate_toward(rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
		desired_velocity = direction * chase_speed

func take_damage(amount: float) -> void:
	if dead:
		return
	health = maxf(health - amount, 0)
	attacking = false
	if health <= 0:
		dead = true
	else:
		stagger_left = 0.8
		if is_instance_valid(target):
			last_seen_position = target.global_position
			memory_left = memory_duration

func hear_noise(location: Vector3) -> void:
	if dead or can_see_target or global_position.distance_to(location) > sight_range:
		return
	last_seen_position = location
	memory_left = memory_duration
	searching = false
	repath_timer = 0

func set_state(value: String) -> void:
	if state != value:
		state = value
		state_changed.emit(state)

func reset_encounter() -> void:
	health = max_health
	dead = false
	attacking = false
	stagger_left = 0
	memory_left = 0
	searching = false
	repath_timer = 0
	hit_count = 0
	visibility_fraction = 0.0
	can_see_target = false
	recognition_elapsed = 0.0
	target_recognized = false
	recognizing = false
	velocity = Vector3.ZERO
	brain.restart()
