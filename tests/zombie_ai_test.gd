extends SceneTree

var room: Node3D
var zombie: PrototypeZombie
var player: CharacterBody3D
var failed: bool = false

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if value:
		print("PASS: " + message)
	else:
		push_error("FAIL: " + message)
		failed = true

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func place(enemy_position: Vector3, player_position: Vector3, yaw: float = 0.0) -> void:
	zombie.reset_encounter()
	zombie.global_position = enemy_position
	zombie.rotation = Vector3(0, yaw, 0)
	player.global_position = player_position
	player.velocity = Vector3.ZERO
	player.restore_health()
	await frames(2)

func run() -> void:
	room = load("res://src/scenes/zombie_test_room.tscn").instantiate()
	root.add_child(room)
	zombie = room.get_node("Zombie")
	player = room.get_node("Player")
	player.set_physics_process(false)
	while not room.ready_for_test:
		await physics_frame
	await frames(5)
	check(room.get_node("NavigationRegion3D").navigation_mesh.get_polygon_count() > 0, "Navigation mesh baked")
	await test_recognition()
	# The recognition cases above use the real one-second delay. The remaining
	# combat/navigation regression cases use instant recognition to isolate them.
	zombie.recognition_duration = 0.0
	zombie.set_physics_process(true)
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	check(zombie.can_see_target, "Player visible in forward field of view")
	var start := zombie.global_position
	await frames(50)
	check(zombie.global_position.distance_to(start) > 0.5, "LimboAI chase follows navigation")
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 7))
	check(not zombie.can_see_target, "Player behind zombie is not detected")
	await place(Vector3(0, 0.02, 4), Vector3(0, 0.02, -4))
	check(not zombie.can_see_target, "Cover blocks sight")
	zombie.hear_noise(Vector3(0, 0.02, -4))
	await frames(2)
	check(zombie.state == "INVESTIGATE", "Noise starts location-based investigation")
	var path := NavigationServer3D.map_get_path(zombie.navigation.get_navigation_map(), Vector3(0, 0, 4), Vector3(0, 0, -4), true)
	var detours := false
	for point in path:
		if absf(point.x) > 2.0:
			detours = true
	check(detours, "Navigation path detours around cover")
	var largest_x := 0.0
	for i in range(300):
		await physics_frame
		largest_x = maxf(largest_x, absf(zombie.global_position.x))
	check(largest_x > 2.0, "Zombie actually moves around cover instead of into it")
	# Detection is refreshed only while visible.
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	var remembered := zombie.last_seen_position
	player.global_position = Vector3(-4, 0.02, -4)
	await frames(2)
	check(not zombie.can_see_target and zombie.last_seen_position == remembered, "Lost player does not update last-seen position")
	check(zombie.state == "INVESTIGATE", "Lost sight interrupts chase")
	# Hold both actors stationary while testing attack time precisely.
	zombie.set_physics_process(false)
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 3))
	zombie._physics_process(0.1)
	check(zombie.state == "WINDUP" and player.health == player.max_health, "Attack telegraphs before damage")
	for i in range(6):
		zombie._physics_process(0.1)
	check(zombie.hit_count == 1 and player.health == player.max_health - zombie.attack_damage, "One hit at windup completion")
	for i in range(5):
		zombie._physics_process(0.1)
	check(zombie.hit_count == 1, "Recovery cannot deal repeated damage")
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 3))
	zombie._physics_process(0.1)
	player.global_position = Vector3(4, 0.02, 0)
	await frames(2)
	for i in range(7):
		zombie._physics_process(0.1)
	check(zombie.hit_count == 0, "Leaving attack reach avoids damage")
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 3))
	zombie._physics_process(0.1)
	zombie.take_damage(20)
	zombie._physics_process(0.1)
	check(zombie.state == "STAGGER" and not zombie.attacking and zombie.hit_count == 0, "Stagger interrupts windup before damage")
	zombie.take_damage(100)
	zombie._physics_process(0.1)
	check(zombie.state == "DEAD" and zombie.desired_velocity == Vector3.ZERO, "Death wins over all behaviors")
	zombie.reset_encounter()
	zombie.target = null
	zombie._physics_process(0.1)
	check(zombie.state == "IDLE", "Missing target safely idles")
	zombie.target = player
	zombie.global_position = Vector3(-4, 0.02, 4)
	zombie.last_seen_position = zombie.global_position
	zombie.memory_left = 5
	zombie.searching = false
	zombie._physics_process(0.1)
	check(zombie.searching, "Arriving at last-known position starts search")
	for i in range(30):
		zombie._physics_process(0.1)
	check(zombie.state == "IDLE", "Search expires into idle")
	print("Zombie AI test result: " + ("FAILED" if failed else "PASSED"))
	room.queue_free()
	await process_frame
	quit(1 if failed else 0)

func test_recognition() -> void:
	zombie.set_physics_process(false)
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	var start := zombie.global_position
	zombie._physics_process(0.4)
	check(zombie.visibility_fraction >= zombie.recognition_visibility_threshold, "Almost entire body is visible")
	check(zombie.state == "RECOGNIZE" and not zombie.target_recognized, "Full sight starts recognition instead of chase")
	var displacement := zombie.global_position - start
	check(Vector2(displacement.x, displacement.z).length() < 0.01, "Zombie stays planted while recognizing")
	zombie._physics_process(0.5)
	check(not zombie.target_recognized and zombie.state == "RECOGNIZE", "No chase before one full second")
	zombie._physics_process(0.1)
	check(zombie.target_recognized and zombie.state == "CHASE", "One continuous second unlocks chase")
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	zombie._physics_process(0.4)
	var remembered := zombie.last_seen_position
	player.global_position = Vector3(-4, 0.02, -4)
	await frames(2)
	zombie._physics_process(0.1)
	check(zombie.recognition_elapsed == 0 and not zombie.target_recognized, "Losing sight resets recognition completely")
	check(zombie.state == "INVESTIGATE" and zombie.last_seen_position == remembered, "Interrupted glimpse investigates last visible position")
	player.global_position = Vector3(4, 0.02, 0)
	await frames(2)
	zombie._physics_process(0.5)
	check(not zombie.target_recognized and is_equal_approx(zombie.recognition_elapsed, 0.5), "Reappearing starts a fresh timer without accumulated credit")
	zombie._physics_process(0.5)
	check(zombie.target_recognized, "Fresh uninterrupted visibility completes recognition")
	# A chest-high occluder leaves only the upper-body samples visible.
	var cover := StaticBody3D.new()
	cover.position = Vector3(4, 0.7, 2)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2, 1.4, 0.3)
	collision.shape = shape
	cover.add_child(collision)
	room.add_child(cover)
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	zombie._physics_process(0.1)
	check(zombie.visibility_fraction > 0 and zombie.visibility_fraction < zombie.recognition_visibility_threshold, "Head-only exposure does not count as almost entirely visible")
	check(zombie.state == "INVESTIGATE" and zombie.recognition_elapsed == 0, "Partial exposure investigates without starting recognition")
	cover.collision_layer = 0
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 0))
	zombie._physics_process(0.4)
	cover.collision_layer = 1
	await frames(2)
	zombie._physics_process(0.1)
	check(zombie.state == "INVESTIGATE" and zombie.recognition_elapsed == 0 and not zombie.target_recognized, "Partial occlusion interrupts an active recognition timer")
	cover.queue_free()
	await frames(2)
	await place(Vector3(4, 0.02, 4), Vector3(4, 0.02, 3))
	zombie._physics_process(0.1)
	check(zombie.state == "RECOGNIZE" and not zombie.attacking and player.health == player.max_health, "Close targets cannot bypass recognition through attacks")
	await place(Vector3(4, 0.02, 4), Vector3(7.1, 0.02, 1.4))
	zombie._physics_process(0.2)
	check(zombie.visibility_fraction > 0 and zombie.visibility_fraction < zombie.recognition_visibility_threshold and not zombie.recognizing, "Body straddling field-of-view edge cannot start timer")
