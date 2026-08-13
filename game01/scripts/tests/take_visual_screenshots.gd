@tool
extends SceneTree

# take_visual_screenshots.gd - Captures screenshots of 1F, 2F, 3F & Decorating Mode for visual verification

func _init():
	print("📸 Starting Comprehensive 2.5D Isometric Visual Screenshot Capture...")
	
	var gs = root.get_node_or_null("GameState")
	var main_scene = load("res://scenes/main_scene.tscn")
	if main_scene == null:
		print("❌ Error loading main_scene.tscn")
		quit(1)
		return
		
	var root_node = main_scene.instantiate()
	root.add_child(root_node)
	
	# Wait for scene tree to initialize
	await create_timer(0.3).timeout
	
	var cafe_view = root_node.get_node_or_null("VBoxContainer/SubViewportContainer/SubViewport/CafeView")
	if cafe_view == null:
		print("❌ CafeView node not found!")
		quit(1)
		return

	# Access GameState autoload node from tree
	var game_state_node = root_node.get_node_or_null("/root/GameState")
	if game_state_node == null:
		game_state_node = root.get_node_or_null("GameState")
		
	if game_state_node != null:
		game_state_node.upgrades["expansion_2f"]["level"] = 1
		game_state_node.upgrades["expansion_3f"]["level"] = 1

		# 1. Capture 1F Main Study Zone
		game_state_node.current_floor = 1
		game_state_node.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_1f_main.png")
		print("✅ Captured 1F Main Study Zone -> game01/screenshot_1f_main.png")
		
		# 2. Capture 2F Noble Booth Zone
		game_state_node.current_floor = 2
		game_state_node.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_2f_booth.png")
		print("✅ Captured 2F Noble Booth Zone -> game01/screenshot_2f_booth.png")

		# 3. Capture 3F Rooftop Terrace Zone
		game_state_node.current_floor = 3
		game_state_node.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_3f_terrace.png")
		print("✅ Captured 3F Rooftop Terrace Zone -> game01/screenshot_3f_terrace.png")

		# 4. Capture Decorating Mode Grid
		game_state_node.current_floor = 1
		game_state_node.is_decorating_mode = true
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_decorating_grid.png")
		print("✅ Captured Decorating Mode Grid -> game01/screenshot_decorating_grid.png")

	print("🎉 All 4 Visual Screenshots Captured Successfully!")
	quit(0)

func capture_screenshot(save_path: String) -> void:
	var viewport = root.get_viewport()
	if viewport:
		var img = viewport.get_texture().get_image()
		if img:
			img.save_png(save_path)
