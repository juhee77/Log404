extends Node2D

signal hotspot_clicked(hotspot_id: String)
signal hotspot_hovered(label_text: String)

const ROOM_WIDTH: float = 2200.0
const ROOM_HEIGHT: float = 720.0

var scroll_x: float = 460.0
var target_scroll_x: float = 460.0
var anim_time: float = 0.0
var hovered_hotspot: String = ""
var is_dragging: bool = false
var drag_start_mouse_x: float = 0.0
var drag_start_scroll_x: float = 0.0
var drag_distance: float = 0.0

var stars: Array[Dictionary] = []

# 각 오브젝트의 월드 좌표(2200x720 기준) 히트박스
const HOTSPOTS: Dictionary = {
	"coat": {
		"rect": Rect2(145, 200, 145, 270),
		"label": "오버사이즈 코트"
	},
	"suitcase": {
		"rect": Rect2(360, 495, 220, 120),
		"label": "침대 밑 가죽 여행가방"
	},
	"window": {
		"rect": Rect2(860, 130, 480, 250),
		"label": "별바다가 보이는 아치형 창문"
	},
	"table": {
		"rect": Rect2(950, 405, 300, 195),
		"label": "원목 테이블 (회중시계 & 여행일지)"
	},
	"mirror": {
		"rect": Rect2(1505, 165, 195, 270),
		"label": "황동 프레임 거울"
	},
	"validator": {
		"rect": Rect2(1770, 290, 105, 155),
		"label": "황동 부엉이 검표기"
	},
	"door": {
		"rect": Rect2(1910, 145, 210, 455),
		"label": "5호차 출구 문"
	}
}


func _ready() -> void:
	_init_stars()
	GameState.flag_changed.connect(_on_flag_changed)


func _init_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 404
	stars.clear()
	for i in range(65):
		stars.append({
			"x": rng.randf_range(0.0, 480.0),
			"y": rng.randf_range(0.0, 240.0),
			"r": rng.randf_range(1.2, 3.0),
			"speed": rng.randf_range(8.0, 26.0),
			"phase": rng.randf_range(0.0, TAU)
		})


func _on_flag_changed(_flag_name: String, _value: bool) -> void:
	queue_redraw()


func scroll_by(delta_x: float) -> void:
	var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
	target_scroll_x = clampf(target_scroll_x + delta_x, 0.0, max_scroll)


func _process(delta: float) -> void:
	anim_time += delta

	# 키보드 좌우 스크롤 지원
	var key_dir := Input.get_axis("ui_left", "ui_right")
	if absf(key_dir) > 0.01:
		scroll_by(key_dir * 620.0 * delta)

	var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
	target_scroll_x = clampf(target_scroll_x, 0.0, max_scroll)
	scroll_x = lerpf(scroll_x, target_scroll_x, minf(1.0, delta * 9.0))
	position.x = -scroll_x
	queue_redraw()


func handle_room_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				is_dragging = true
				drag_start_mouse_x = mb.position.x
				drag_start_scroll_x = target_scroll_x
				drag_distance = 0.0
			else:
				var was_click := drag_distance < 10.0
				is_dragging = false
				if was_click:
					var world_pos := mb.position + Vector2(scroll_x, 0.0)
					var hit := _hit_test(world_pos)
					if hit != "":
						hotspot_clicked.emit(hit)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			scroll_by(-140.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			scroll_by(140.0)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if is_dragging:
			var dx := mm.position.x - drag_start_mouse_x
			drag_distance = maxf(drag_distance, absf(dx))
			var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
			target_scroll_x = clampf(drag_start_scroll_x - dx, 0.0, max_scroll)
		else:
			var world_pos := mm.position + Vector2(scroll_x, 0.0)
			var hit := _hit_test(world_pos)
			if hit != hovered_hotspot:
				hovered_hotspot = hit
				if hit != "":
					hotspot_hovered.emit(str(HOTSPOTS[hit]["label"]))
				else:
					hotspot_hovered.emit("")


func _hit_test(world_pos: Vector2) -> String:
	for id in HOTSPOTS.keys():
		var rect: Rect2 = HOTSPOTS[id]["rect"]
		if rect.has_point(world_pos):
			return id
	return ""


func _draw() -> void:
	_draw_carriage_shell()
	_draw_window_and_sky()
	_draw_bed_and_coat()
	_draw_suitcase()
	_draw_table_and_props()
	_draw_mirror()
	_draw_validator()
	_draw_exit_door()
	_draw_gas_lamps()
	_draw_hover_highlight()


func _draw_carriage_shell() -> void:
	# 상단 아치형 천장
	draw_rect(Rect2(0, 0, ROOM_WIDTH, 110), Color("#1C1427"))
	draw_rect(Rect2(0, 100, ROOM_WIDTH, 14), Color("#B8893A"))

	# 마호가니 목재 벽면
	draw_rect(Rect2(0, 114, ROOM_WIDTH, 476), Color("#3B2322"))

	# 벽면 세로 우드 패널 장식 (2.5D 깊이감)
	for x in range(0, int(ROOM_WIDTH), 180):
		draw_rect(Rect2(x + 14, 130, 152, 435), Color("#472B29"))
		draw_rect(Rect2(x + 14, 130, 152, 435), Color("#2D1918"), false, 2.0)

	# 황동 허리 몰딩
	draw_rect(Rect2(0, 445, ROOM_WIDTH, 8), Color("#C59B43"))

	# 바닥 (원근 톤 & 보르도 카펫)
	draw_rect(Rect2(0, 590, ROOM_WIDTH, 130), Color("#241518"))
	draw_rect(Rect2(40, 610, ROOM_WIDTH - 80, 95), Color("#5E1E2B"))
	draw_rect(Rect2(48, 618, ROOM_WIDTH - 96, 79), Color("#C59B43"), false, 2.5)


func _draw_window_and_sky() -> void:
	var win := Rect2(860, 130, 480, 250)
	# 밤하늘 배경
	draw_rect(win, Color("#0B132B"))
	draw_rect(Rect2(win.position.x, win.position.y + 135, win.size.x, 115), Color("#172042"))

	# 흐르는 별빛 애니메이션
	for s in stars:
		var sx := fmod(float(s["x"]) - anim_time * float(s["speed"]) + win.size.x * 10.0, win.size.x)
		var twinkle := 0.55 + 0.45 * sin(anim_time * 2.5 + float(s["phase"]))
		var col := Color(1.0, 0.96, 0.82, twinkle)
		draw_circle(win.position + Vector2(sx, float(s["y"])), float(s["r"]), col)

	# 힌트 별자리: 숫자 '4' 모양의 빛나는 별자리 (은은하게 고정)
	var c_pts: Array[Vector2] = [
		win.position + Vector2(215, 52),
		win.position + Vector2(175, 128),
		win.position + Vector2(248, 128),
		win.position + Vector2(228, 72),
		win.position + Vector2(228, 178)
	]
	var line_col := Color(0.99, 0.9, 0.54, 0.35 + 0.2 * sin(anim_time * 1.8))
	draw_line(c_pts[0], c_pts[1], line_col, 2.0)
	draw_line(c_pts[1], c_pts[2], line_col, 2.0)
	draw_line(c_pts[3], c_pts[4], line_col, 2.0)
	for pt in c_pts:
		draw_circle(pt, 4.2, Color("#FEF08A"))

	# 초승달
	draw_circle(win.position + Vector2(395, 72), 26.0, Color("#FDE68A"))
	draw_circle(win.position + Vector2(406, 66), 23.0, Color("#0B132B"))

	# 황동 창틀 & 커튼
	draw_rect(win, Color("#C59B43"), false, 8.0)
	draw_line(Vector2(win.position.x + win.size.x * 0.5, win.position.y), Vector2(win.position.x + win.size.x * 0.5, win.end.y), Color("#B8893A"), 5.0)
	# 좌/우 벨벳 커튼
	draw_colored_polygon(PackedVector2Array([
		Vector2(845, 120), Vector2(920, 120), Vector2(895, 285), Vector2(845, 385)
	]), Color("#6D1D32"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(1355, 120), Vector2(1280, 120), Vector2(1305, 285), Vector2(1355, 385)
	]), Color("#6D1D32"))


func _draw_bed_and_coat() -> void:
	# 코트 걸이 & 오버사이즈 코트 (좌측)
	draw_rect(Rect2(210, 165, 16, 360), Color("#2A1817"))
	draw_circle(Vector2(218, 172), 10.0, Color("#D4AF37"))
	var coat_poly := PackedVector2Array([
		Vector2(175, 215), Vector2(260, 215), Vector2(280, 445), Vector2(155, 445)
	])
	draw_colored_polygon(coat_poly, Color("#2E3B59"))
	draw_polyline(coat_poly, Color("#1D263B"), 3.0)
	# 코트 주머니 반짝임 (티크 합류 전 유도)
	if not GameState.has_flag("coat_searched"):
		var pulse := 0.4 + 0.5 * absf(sin(anim_time * 3.0))
		draw_circle(Vector2(238, 345), 11.0 + pulse * 4.0, Color(1.0, 0.88, 0.45, pulse))
		draw_circle(Vector2(238, 345), 4.0, Color("#FFFBEB"))

	# 1인 침대 (2.5D 측면 뷰)
	draw_rect(Rect2(315, 365, 420, 130), Color("#341E1D"))
	draw_rect(Rect2(315, 315, 28, 255), Color("#5A332D")) # 침대 머리판
	draw_rect(Rect2(710, 355, 25, 215), Color("#5A332D")) # 침대 발판
	# 매트리스 & 별빛 이불
	draw_rect(Rect2(343, 390, 367, 45), Color("#F4EBD0"))
	draw_rect(Rect2(410, 385, 300, 72), Color("#29395C"))
	draw_rect(Rect2(352, 362, 72, 30), Color("#FDF6E3")) # 베개
	# 침대 밑 어두운 공간
	draw_rect(Rect2(343, 490, 367, 98), Color("#1A0F12"))


func _draw_suitcase() -> void:
	var opened := GameState.has_flag("suitcase_opened")
	var box := Rect2(375, 505, 195, 92)
	draw_rect(box, Color("#6F3E28"))
	draw_rect(box, Color("#3B1E12"), false, 3.0)
	# 가죽 벨트 2줄
	draw_rect(Rect2(410, 505, 16, 92), Color("#422316"))
	draw_rect(Rect2(518, 505, 16, 92), Color("#422316"))
	# 황동 자물쇠
	var lock_col := Color("#4ADE80") if opened else Color("#D4AF37")
	draw_rect(Rect2(455, 535, 34, 28), lock_col)
	if opened:
		draw_rect(Rect2(382, 488, 180, 18), Color("#8B5135")) # 살짝 열린 뚜껑


func _draw_table_and_props() -> void:
	# 원목 테이블
	draw_rect(Rect2(960, 465, 280, 22), Color("#6B3E2E"))
	draw_rect(Rect2(985, 487, 18, 115), Color("#4A2A1F"))
	draw_rect(Rect2(1195, 487, 18, 115), Color("#4A2A1F"))

	# 펼쳐진 여행일지
	draw_rect(Rect2(995, 435, 86, 30), Color("#FDF6E3"))
	draw_line(Vector2(1038, 435), Vector2(1038, 465), Color("#C2B59B"), 2.0)

	# 황동 회중시계 (04:04)
	draw_circle(Vector2(1155, 446), 22.0, Color("#D4AF37"))
	draw_circle(Vector2(1155, 446), 17.0, Color("#FFFBEB"))
	draw_line(Vector2(1155, 446), Vector2(1165, 452), Color("#1E293B"), 2.5)
	draw_line(Vector2(1155, 446), Vector2(1164, 438), Color("#1E293B"), 2.0)

	# 작은 티컵
	draw_rect(Rect2(1098, 444, 24, 20), Color("#E2E8F0"))


func _draw_mirror() -> void:
	var m := Rect2(1515, 175, 175, 245)
	draw_rect(m.grow(10), Color("#C59B43"))
	draw_rect(m, Color("#94A3B8"))

	if GameState.has_flag("mirror_wiped"):
		# 김 서림이 닦인 맑은 거울 + 보름달 모양 숫자 '0'
		draw_rect(m, Color("#334155"))
		draw_arc(m.get_center(), 46.0, 0.0, TAU, 36, Color("#FDE68A"), 7.0)
	else:
		# 뿌연 김 서림 표현
		draw_rect(m, Color("#CBD5E1", 0.72))
		draw_circle(m.get_center() + Vector2(-20, -25), 42.0, Color(1, 1, 1, 0.25))
		draw_circle(m.get_center() + Vector2(24, 30), 48.0, Color(1, 1, 1, 0.22))


func _draw_validator() -> void:
	var v := Rect2(1780, 300, 86, 132)
	draw_rect(v, Color("#8C6226"))
	draw_rect(v, Color("#D4AF37"), false, 4.0)
	# 부엉이 눈 장식
	var eye_col := Color("#4ADE80") if GameState.has_flag("door_unlocked") else (Color("#FACC15") if GameState.has_flag("validator_wound") else Color("#475569"))
	draw_circle(Vector2(1808, 338), 11.0, eye_col)
	draw_circle(Vector2(1838, 338), 11.0, eye_col)
	# 승차권 투입구
	draw_rect(Rect2(1798, 376, 50, 10), Color("#1E1B18"))
	# 태엽 구멍
	draw_circle(Vector2(1823, 408), 8.0, Color("#1E1B18"))


func _draw_exit_door() -> void:
	var d := Rect2(1920, 155, 190, 435)
	var unlocked := GameState.has_flag("door_unlocked")
	draw_rect(d.grow(8), Color("#B8893A"))
	if unlocked:
		# 문이 열리며 4호차의 따뜻한 빛이 새어 나옴
		draw_rect(d, Color("#FDE68A", 0.9))
		draw_rect(Rect2(d.position.x + 25, d.position.y + 30, 140, 385), Color("#FFFBEB", 0.85))
	else:
		draw_rect(d, Color("#4E2A25"))
		# 문 상단 아치형 유리창
		draw_rect(Rect2(1955, 195, 120, 150), Color("#1E293B"))
		draw_rect(Rect2(1955, 195, 120, 150), Color("#C59B43"), false, 4.0)
		# 문패 'CAR 5'
		draw_rect(Rect2(1975, 370, 80, 28), Color("#D4AF37"))
		# 손잡이
		draw_circle(Vector2(1945, 425), 9.0, Color("#FDE68A"))


func _draw_gas_lamps() -> void:
	var lamp_positions: Array[Vector2] = [Vector2(560, 145), Vector2(1425, 145)]
	var flicker := 0.85 + 0.15 * sin(anim_time * 5.2)
	for pos in lamp_positions:
		draw_circle(pos, 72.0 * flicker, Color(0.98, 0.78, 0.28, 0.12))
		draw_circle(pos, 36.0 * flicker, Color(0.99, 0.88, 0.45, 0.24))
		draw_circle(pos, 11.0, Color("#FEF3C7"))
		draw_rect(Rect2(pos.x - 8, pos.y - 24, 16, 14), Color("#C59B43"))


func _draw_hover_highlight() -> void:
	if hovered_hotspot == "" or not HOTSPOTS.has(hovered_hotspot):
		return
	var rect: Rect2 = HOTSPOTS[hovered_hotspot]["rect"]
	var alpha := 0.55 + 0.35 * sin(anim_time * 5.0)
	draw_rect(rect, Color(0.99, 0.9, 0.54, alpha), false, 3.5)
