extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var room = load("res://src/scenes/zombie_test_room.tscn").instantiate()
	root.add_child(room)
	for i in range(90):
		await process_frame
	await RenderingServer.frame_post_draw
	var screenshot := root.get_texture().get_image()
	var result := screenshot.save_png("res://.godot/zombie-demo.png")
	print("Demo screenshot saved: " + str(result))
	room.queue_free()
	await process_frame
	quit(result)
