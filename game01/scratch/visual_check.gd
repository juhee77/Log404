extends Node

# Runs the real main scene (autoloads active) and captures the isometric floor.
func _ready() -> void:
	var main = load("res://scenes/main_scene.tscn").instantiate()
	add_child(main)
	var GameState = get_node("/root/GameState")
	for i in range(30):
		await get_tree().process_frame

	var cafe = main.find_child("CafeView", true, false)
	if cafe == null:
		print("❌ CafeView not found")
		get_tree().quit(1)
		return

	GameState.is_decorating_mode = false

	# unlock every floor so all three can be captured
	GameState.unlocked_floors = [1, 2, 3]
	GameState.upgrades["open_seats"]["level"] = max(2, GameState.upgrades["open_seats"]["level"])
	for fl in [1, 2, 3]:
		GameState.current_floor = fl
		cafe.queue_redraw()
		await _capture("res://scratch/check_floor%d.png" % fl)
	GameState.current_floor = 1

	# seat some customers so the character rendering can be checked
	GameState.reputation = 4.9
	# 네 가지 손님 타입을 한 명씩 확실히 앉혀 비교한다
	for tname in ["student", "examinee", "developer", "worker"]:
		GameState.spawn_customer()
		if GameState.active_customers.is_empty(): continue
		var cc = GameState.active_customers[-1]
		for t in GameState.CUSTOMER_TYPES:
			if t["type"] == tname:
				cc["type"] = t["type"]; cc["color"] = t["color"]; cc["icon"] = t["icon"]
				break
	for c in GameState.active_customers:
		c["state"] = "STUDYING"
		c["pos"] = GameState.get_seat_position(c["seat_index"])
		c["study_time"] = 3.0
	cafe.queue_redraw()
	await _capture("res://scratch/check_normal.png")
	await _capture("res://scratch/check_customers.png")

	# story beat card
	cafe._on_story_beat({
		"kind": "act",
		"title": "🏢 3막 — 길 건너 포커스존",
		"body": "길 건너에 24시간 프랜차이즈 「포커스존」이 열렸다. 통유리, 대형 간판, 첫 달 반값.\n단골 자리가 하루가 다르게 비어간다. 민서가 물었다. — \"우리는 뭐가 달라요?\"",
		"speaker": "🏢 강 팀장 — \"길 건너에 저희가 들어옵니다.\""
	})
	cafe.story_card_t = 2.0
	cafe.queue_redraw()
	await _capture("res://scratch/check_story.png")
	cafe.story_card = {}

	# door shut vs door open
	cafe.door_open = 0.0
	cafe.queue_redraw()
	await _capture("res://scratch/check_door_shut.png")
	cafe.door_open = 1.0
	cafe.queue_redraw()
	await _capture("res://scratch/check_door_open.png")

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
