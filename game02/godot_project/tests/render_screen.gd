extends SceneTree

func _init() -> void:
	print("Rendering Godot Viewport to PNG...")
	var main_packed = load("res://scenes/main.tscn")
	var main_inst = main_packed.instantiate()
	root.add_child(main_inst)

	for i in range(15):
		await process_frame

	var vp = root.get_viewport()
	var tex = vp.get_texture()
	if tex != null:
		var img = tex.get_image()
		if img != null:
			img.save_png("res://screenshots/godot_app_screen.png")
			print("✓ Saved main view to res://screenshots/godot_app_screen.png")

	# Also open DetailModal on first book and capture modal screenshot
	if main_inst.archive_state.items.size() > 0:
		main_inst._on_card_clicked(main_inst.archive_state.items[0])
		for i in range(10):
			await process_frame
		var modal_img = vp.get_texture().get_image()
		if modal_img != null:
			modal_img.save_png("res://screenshots/godot_modal_screen.png")
			print("✓ Saved modal view to res://screenshots/godot_modal_screen.png")

	quit(0)
