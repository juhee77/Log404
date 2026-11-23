extends SceneTree

func _init() -> void:
	print("Rendering Godot Viewport to PNG...")
	var main_packed = load("res://scenes/main.tscn")
	var main_inst = main_packed.instantiate()
	root.add_child(main_inst)

	for i in range(10):
		await process_frame

	if main_inst.archive_state != null:
		main_inst.archive_state.reset_to_rich_defaults()
		main_inst._refresh_all()
		for i in range(5):
			await process_frame

	var vp = root.get_viewport()
	if vp.get_texture() != null:
		var img = vp.get_texture().get_image()
		if img != null:
			img.save_png("res://screenshots/godot_app_screen.png")
			print("✓ Saved main bookshelf view")

	# Capture Figure Showcase Tab (전시대)
	main_inst._switch_tab(1)
	for i in range(6):
		await process_frame
	var sc_img = vp.get_texture().get_image()
	if sc_img != null:
		sc_img.save_png("res://screenshots/godot_showcase_screen.png")
		print("✓ Saved figure showcase view")

	# Capture DetailModal Bottom Sheet
	main_inst._switch_tab(0)
	if main_inst.archive_state.items.size() > 0:
		main_inst.detail_modal.open(main_inst.archive_state.items[0], main_inst._palette)
		for i in range(6):
			await process_frame
		var modal_img = vp.get_texture().get_image()
		if modal_img != null:
			modal_img.save_png("res://screenshots/godot_modal_screen.png")
			print("✓ Saved detail modal view")
		main_inst.detail_modal.close()

	# Capture Dedicated Settings Page (설정)
	main_inst._open_settings()
	for i in range(6):
		await process_frame
	var set_img = vp.get_texture().get_image()
	if set_img != null:
		set_img.save_png("res://screenshots/godot_settings_screen.png")
		print("✓ Saved dedicated settings page view")

	quit(0)
