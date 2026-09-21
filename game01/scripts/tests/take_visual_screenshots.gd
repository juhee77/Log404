extends Node

# take_visual_screenshots.gd - README 용 스크린샷 캡처
#
# 예전에는 `extends SceneTree` + `--script` 로 실행했는데, 그 모드에서는 Godot 이
# 오토로드를 올리지 않아 GameState 를 찾지 못하고 모든 UI 스크립트가 컴파일에
# 실패했다. 결과적으로 네 장 모두 같은 빈 화면이 저장됐다(각 36,241 바이트).
# 실제 씬으로 실행해야 오토로드가 살아 있다:
#
#   godot --path game01 scenes/take_screenshots.tscn

const SHOTS := [
	{ "floor": 1, "decor": false, "file": "screenshot_1f.png" },
	{ "floor": 2, "decor": false, "file": "screenshot_2f.png" },
	{ "floor": 3, "decor": false, "file": "screenshot_3f.png" },
	{ "floor": 1, "decor": true,  "file": "screenshot_decorating.png" }
]

func _ready() -> void:
	var main = load("res://scenes/main_scene.tscn").instantiate()
	add_child(main)
	for i in range(30):
		await get_tree().process_frame

	var cafe = main.find_child("CafeView", true, false)
	if cafe == null:
		push_error("CafeView not found")
		get_tree().quit(1)
		return

	# 모든 층을 캡처할 수 있도록 해금하고, 손님을 앉혀 매장이 비어 보이지 않게 한다
	GameState.unlocked_floors = [1, 2, 3]
	GameState.reputation = 4.9
	for i in range(8):
		GameState.spawn_customer()
	for c in GameState.active_customers:
		c["state"] = "STUDYING"
		c["pos"] = GameState.get_seat_position(c["seat_index"])
		c["study_time"] = 4.0

	for shot in SHOTS:
		GameState.current_floor = shot["floor"]
		GameState.is_decorating_mode = shot["decor"]
		if shot["decor"]:
			cafe.hover_cell = Vector2i(2, 4)
		cafe.queue_redraw()
		for i in range(5):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img = get_viewport().get_texture().get_image()
		img.save_png("res://" + shot["file"])
		print("📸 %s" % shot["file"])

	print("✅ 스크린샷 %d장 저장 완료" % SHOTS.size())
	get_tree().quit()
