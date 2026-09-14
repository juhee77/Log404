extends Node

# Runs the real main scene (autoloads active) and captures the isometric floor.
func _ready() -> void:
	var main = load("res://scenes/main_scene.tscn").instantiate()
	add_child(main)
	for i in range(30):
		await get_tree().process_frame

	var cafe = main.find_child("CafeView", true, false)
	if cafe == null:
		print("❌ CafeView not found")
		get_tree().quit(1)
		return

	print("CafeView size = ", cafe.get_rect().size)
	GameState.is_decorating_mode = false
	cafe.queue_redraw()
	await _capture("res://scratch/check_normal.png")

	GameState.is_decorating_mode = true
	cafe.hover_cell = Vector2i(2, 2)
	cafe.queue_redraw()
	await _capture("res://scratch/check_decorating.png")

	# simulate: pick up desk #0 and hover an occupied tile
	cafe.selected_drag_seat = 0
	cafe.is_dragging = true
	cafe.hover_cell = Vector2i(3, 0)
	cafe.queue_redraw()
	await _capture("res://scratch/check_dragging.png")

	print("✅ captured")
	get_tree().quit()

func _capture(path: String) -> void:
	for i in range(4):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img = get_viewport().get_texture().get_image()
	img.save_png(path)
