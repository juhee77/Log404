extends SceneTree

# take_3d_screenshot.gd - 3D Viewport capture runner

func _init() -> void:
	print("--- Capturing 3D Study Cafe Viewport ---")
	var scene = load("res://scenes/main_3d.tscn").instantiate()
	root.add_child(scene)
	
	await create_timer(1.0).timeout
	
	var vp = root.get_viewport()
	if vp != null:
		var tex = vp.get_texture()
		if tex != null:
			var img = tex.get_image()
			if img != null:
				var abs_path = ProjectSettings.globalize_path("res://shot_3d.png")
				img.save_png(abs_path)
				print("✔ 3D Screenshot saved to: ", abs_path)
				
	quit()
