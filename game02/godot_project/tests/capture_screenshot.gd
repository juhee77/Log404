extends SceneTree

func _init() -> void:
	print("Capturing Godot screenshot...")
	var main_packed = load("res://scenes/main.tscn")
	var main_inst = main_packed.instantiate()
	root.add_child(main_inst)

	# Wait a couple of frames for UI layout and rendering
	for i in range(10):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	var err = img.save_png("res://screenshots/main_view.png")
	if err == OK:
		print("Screenshot successfully saved to res://screenshots/main_view.png")
	else:
		print("Failed to save screenshot: ", err)
	quit(0)

