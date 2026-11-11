extends SceneTree

func _init() -> void:
	print("Rendering Godot Viewport to PNG...")
	var main_packed = load("res://scenes/main.tscn")
	var main_inst = main_packed.instantiate()
	root.add_child(main_inst)

	# Process frames so layout and visuals update
	for i in range(20):
		await process_frame

	var vp = root.get_viewport()
	var tex = vp.get_texture()
	if tex != null:
		var img = tex.get_image()
		if img != null:
			img.save_png("res://screenshots/godot_app_screen.png")
			print("✓ Saved to res://screenshots/godot_app_screen.png")
	quit(0)
