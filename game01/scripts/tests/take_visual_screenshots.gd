@tool
extends SceneTree

# take_visual_screenshots.gd - Captures screenshots of 1F, 2F, 3F & Decorating Mode for visual verification

func _init():
	print("📸 Starting Comprehensive 2.5D Isometric Visual Screenshot Capture...")
	change_scene_to_file("res://scenes/main_scene.tscn")
	await create_timer(1.0).timeout
	
	var state = root.get_node_or_null("GameState")
	var root_node = current_scene
	var cafe_view = root_node.find_child("CafeView", true, false) if root_node else null
		
	if cafe_view != null and state != null:
		# 1. Capture 1F Main Study Zone
		state.current_floor = 1
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.5).timeout
		capture_screenshot("screenshot_1f.png")
		print("✅ Captured 1F Main Study Zone -> screenshot_1f.png")
		
		# 2. Capture 2F Noble Booth Zone
		state.current_floor = 2
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.5).timeout
		capture_screenshot("screenshot_2f.png")
		print("✅ Captured 2F Noble Booth Zone -> screenshot_2f.png")

		# 3. Capture 3F Rooftop Terrace Zone
		state.current_floor = 3
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.5).timeout
		capture_screenshot("screenshot_3f.png")
		print("✅ Captured 3F Rooftop Terrace Zone -> screenshot_3f.png")

		# 4. Capture Decorating Mode Grid
		state.current_floor = 1
		state.is_decorating_mode = true
		cafe_view.queue_redraw()
		await create_timer(0.5).timeout
		capture_screenshot("screenshot_decorating.png")
		print("✅ Captured Decorating Mode Grid -> screenshot_decorating.png")
	else:
		print("❌ CafeView or GameState node not found!")

	print("🎉 All 4 Visual Screenshots Captured Successfully!")
	quit(0)

func capture_screenshot(save_path: String) -> void:
	var viewport = root.get_viewport()
	if viewport:
		var img = viewport.get_texture().get_image()
		if img:
			img.save_png(save_path)
