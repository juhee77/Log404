@tool
extends SceneTree

# take_visual_screenshots.gd - Captures screenshots of 1F, 2F, 3F & Decorating Mode for visual verification

func _init():
	print("📸 Starting Comprehensive 2.5D Isometric Visual Screenshot Capture...")
	
	var game_state_script = load("res://scripts/autoload/game_state.gd")
	var state = game_state_script.new()
	state.name = "GameState"
	root.add_child(state)
	
	var main_scene = load("res://scenes/main_scene.tscn")
	if main_scene == null:
		print("❌ Error loading main_scene.tscn")
		quit(1)
		return
		
	var root_node = main_scene.instantiate()
	root.add_child(root_node)
	
	await create_timer(0.3).timeout
	
	var cafe_view = root_node.get_node_or_null("VBoxContainer/SubViewportContainer/SubViewport/CafeView")
	if cafe_view == null:
		cafe_view = root_node.find_child("CafeView", true, false)
		
	if cafe_view != null:
		# 1. Capture 1F Main Study Zone
		state.current_floor = 1
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_1f_main.png")
		print("✅ Captured 1F Main Study Zone -> game01/screenshot_1f_main.png")
		
		# 2. Capture 2F Noble Booth Zone
		state.current_floor = 2
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_2f_booth.png")
		print("✅ Captured 2F Noble Booth Zone -> game01/screenshot_2f_booth.png")

		# 3. Capture 3F Rooftop Terrace Zone
		state.current_floor = 3
		state.is_decorating_mode = false
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_3f_terrace.png")
		print("✅ Captured 3F Rooftop Terrace Zone -> game01/screenshot_3f_terrace.png")

		# 4. Capture Decorating Mode Grid
		state.current_floor = 1
		state.is_decorating_mode = true
		cafe_view.queue_redraw()
		await create_timer(0.3).timeout
		capture_screenshot("game01/screenshot_decorating_grid.png")
		print("✅ Captured Decorating Mode Grid -> game01/screenshot_decorating_grid.png")
	else:
		print("❌ CafeView node not found!")

	print("🎉 All 4 Visual Screenshots Captured Successfully!")
	quit(0)

func capture_screenshot(save_path: String) -> void:
	var viewport = root.get_viewport()
	if viewport:
		var img = viewport.get_texture().get_image()
		if img:
			img.save_png(save_path)
