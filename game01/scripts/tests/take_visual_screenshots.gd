extends SceneTree

# take_visual_screenshots.gd - Visual GUI testing script for Godot 4 render inspection

func _init() -> void:
	print("--- Running Visual UI Screenshot Capture Test ---")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	
	# Wait for rendering pipeline
	await create_timer(0.5).timeout
	
	# Shot 1: Study Zone
	GameState.change_zone("study")
	await create_timer(0.3).timeout
	save_viewport_png("res://shot_study.png")
	print("✔ Captured shot_study.png")
	
	# Shot 2: Lounge Zone
	GameState.change_zone("lounge")
	await create_timer(0.3).timeout
	save_viewport_png("res://shot_lounge.png")
	print("✔ Captured shot_lounge.png")
	
	# Shot 3: Front Zone
	GameState.change_zone("front")
	await create_timer(0.3).timeout
	save_viewport_png("res://shot_front.png")
	print("✔ Captured shot_front.png")
	
	# Shot 4: Upgrades Overlay
	if scene.upgrade_panel:
		scene.upgrade_panel.refresh_list()
		scene.upgrade_panel.show()
		await create_timer(0.3).timeout
		save_viewport_png("res://shot_upgrades.png")
		print("✔ Captured shot_upgrades.png")
		scene.upgrade_panel.hide()
		
	# Shot 5: TOP 10 Leaderboard Overlay
	if scene.leaderboard_panel:
		scene.leaderboard_panel.refresh_leaderboard()
		scene.leaderboard_panel.show()
		await create_timer(0.3).timeout
		save_viewport_png("res://shot_top10.png")
		print("✔ Captured shot_top10.png")
		scene.leaderboard_panel.hide()
		
	print("🎉 ALL VISUAL SCREENSHOTS CAPTURED SUCCESSFULLY!")
	quit()

func save_viewport_png(path: String) -> void:
	var vp = root.get_viewport()
	if vp != null:
		var tex = vp.get_texture()
		if tex != null:
			var img = tex.get_image()
			if img != null:
				img.save_png(path)
