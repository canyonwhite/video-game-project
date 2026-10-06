extends Node3D

@onready var player = $Player
@onready var zombie: PrototypeZombie = $Zombie
var status: Label
var ready_for_test: bool = false

func _ready() -> void:
	var region := NavigationRegion3D.new()
	region.name = "NavigationRegion3D"
	var navmesh := NavigationMesh.new()
	navmesh.agent_radius = 0.4
	navmesh.agent_height = 1.8
	navmesh.cell_size = 0.2
	navmesh.cell_height = 0.1
	navmesh.agent_max_climb = 0.2
	# This standalone room owns the default map; use matching bake precision.
	var map := get_world_3d().navigation_map
	NavigationServer3D.map_set_cell_size(map, navmesh.cell_size)
	NavigationServer3D.map_set_cell_height(map, navmesh.cell_height)
	navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	navmesh.geometry_collision_mask = 1
	region.navigation_mesh = navmesh
	add_child(region)
	_box(region, "Floor", Vector3(0, -0.25, 0), Vector3(16, 0.5, 20), Color("41443f"))
	_box(region, "West", Vector3(-8, 1.5, 0), Vector3(0.3, 3, 20), Color("6c6558"))
	_box(region, "East", Vector3(8, 1.5, 0), Vector3(0.3, 3, 20), Color("6c6558"))
	_box(region, "North", Vector3(0, 1.5, -10), Vector3(16, 3, 0.3), Color("6c6558"))
	_box(region, "South", Vector3(0, 1.5, 10), Vector3(16, 3, 0.3), Color("6c6558"))
	# Break sight here and watch the zombie navigate around the ends.
	_box(region, "Cover", Vector3(0, 1.25, 0), Vector3(4, 2.5, 0.6), Color("76664e"))
	_box(region, "Crate", Vector3(-5, 0.75, 3), Vector3(1.5, 1.5, 1.5), Color("76664e"))
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("202731")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b5c5d4")
	environment.ambient_light_energy = 0.6
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60, -25, 0)
	sun.shadow_enabled = true
	add_child(sun)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var instructions := Label.new()
	instructions.position = Vector2(20, 20)
	instructions.text = "ZOMBIE AI PROTOTYPE\nWASD move | Shift sprint | Ctrl/C crouch | Mouse look\nR reset encounter | H make a noise | Left click hit zombie within 3 m\nEsc release mouse | Click capture | Hide behind the middle wall"
	canvas.add_child(instructions)
	status = Label.new()
	status.position = Vector2(20, 130)
	canvas.add_child(status)
	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	canvas.add_child(crosshair)
	# Bake only this room's static collision, excluding characters.
	region.bake_navigation_mesh(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	ready_for_test = true

func _process(_delta: float) -> void:
	status.text = "Player HP: %.0f | Zombie: %s | Memory: %.1fs | Hits: %d" % [player.health, zombie.state, zombie.memory_left, zombie.hit_count]
	status.text += "\nBody visible: %.0f%% | Recognition: %.2f / %.2fs" % [zombie.visibility_fraction * 100, zombie.recognition_elapsed, zombie.recognition_duration]
	if player.health <= 0:
		status.text += "\nYOU DIED — press R to reset"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			reset_encounter()
		elif event.physical_keycode == KEY_H:
			zombie.hear_noise(player.global_position)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and player.health > 0:
			var camera: Camera3D = player.get_node("Head/CameraEffects/Camera3D")
			var query := PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position - camera.global_basis.z * 3, 5, [player.get_rid()])
			var hit := get_world_3d().direct_space_state.intersect_ray(query)
			if hit.get("collider") == zombie:
				zombie.take_damage(20)

func reset_encounter() -> void:
	player.global_position = Vector3(4, 0.05, 6)
	player.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO
	player.restore_health()
	zombie.global_position = Vector3(4, 0.05, -4)
	zombie.rotation = Vector3(0, PI, 0)
	zombie.reset_encounter()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _box(parent: Node3D, title: String, position_: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = title
	body.position = position_
	parent.add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
