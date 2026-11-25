extends Node2D

signal hotspot_clicked(hotspot_id: String)
signal hotspot_hovered(label_text: String)

const ROOM_WIDTH: float = 2200.0
const ROOM_HEIGHT: float = 720.0

var scroll_x: float = 420.0
var target_scroll_x: float = 420.0
var anim_time: float = 0.0
var hovered_hotspot: String = ""
var is_dragging: bool = false
var drag_start_mouse_x: float = 0.0
var drag_start_scroll_x: float = 0.0
var drag_distance: float = 0.0

var stars: Array[Dictionary] = []
var dust_motes: Array[Dictionary] = []

const HOTSPOTS: Dictionary = {
	"menu_board": {
		"rect": Rect2(140, 175, 195, 225),
		"label": "벽면 주문서 게시판"
	},
	"tea_bar": {
		"rect": Rect2(380, 320, 270, 270),
		"label": "황동 티 바 (홍차 선반)"
	},
	"tea_tables": {
		"rect": Rect2(745, 420, 490, 190),
		"label": "티테이블 A · B · C (홍차 세팅)"
	},
	"chef_madeleine": {
		"rect": Rect2(1265, 285, 165, 305),
		"label": "도자기 인형 요리사 '마들렌'"
	},
	"dumbwaiter": {
		"rect": Rect2(1540, 225, 215, 280),
		"label": "주방 덤웨이터 (음식 승강기)"
	},
	"car4_door": {
		"rect": Rect2(1905, 140, 225, 465),
		"label": "4호차 출구 문"
	}
}


func _ready() -> void:
	_init_particles()
	GameState.flag_changed.connect(_on_flag_changed)


func _init_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 405
	stars.clear()
	for i in range(60):
		stars.append({
			"x": rng.randf_range(0.0, 340.0),
			"y": rng.randf_range(8.0, 210.0),
			"r": rng.randf_range(1.0, 2.6),
			"speed": rng.randf_range(8.0, 22.0),
			"phase": rng.randf_range(0.0, TAU)
		})

	dust_motes.clear()
	for i in range(42):
		dust_motes.append({
			"x": rng.randf_range(80.0, ROOM_WIDTH - 80.0),
			"y": rng.randf_range(120.0, 580.0),
			"r": rng.randf_range(1.1, 2.5),
			"phase": rng.randf_range(0.0, TAU),
			"drift": rng.randf_range(6.0, 15.0)
		})


func _on_flag_changed(_flag_name: String, _value: bool) -> void:
	queue_redraw()


func scroll_by(delta_x: float) -> void:
	var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
	target_scroll_x = clampf(target_scroll_x + delta_x, 0.0, max_scroll)


func _process(delta: float) -> void:
	if not visible:
		return
	anim_time += delta

	var key_dir := Input.get_axis("ui_left", "ui_right")
	if absf(key_dir) > 0.01:
		scroll_by(key_dir * 640.0 * delta)

	var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
	target_scroll_x = clampf(target_scroll_x, 0.0, max_scroll)
	scroll_x = lerpf(scroll_x, target_scroll_x, minf(1.0, delta * 9.0))
	position.x = -scroll_x
	queue_redraw()


func handle_room_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				is_dragging = true
				drag_start_mouse_x = get_viewport().get_mouse_position().x
				drag_start_scroll_x = target_scroll_x
				drag_distance = 0.0
			else:
				var was_click := drag_distance < 10.0
				is_dragging = false
				if was_click:
					var hit := _hit_test(get_local_mouse_position())
					if hit != "":
						hotspot_clicked.emit(hit)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			scroll_by(-150.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			scroll_by(150.0)
	elif event is InputEventMouseMotion:
		var mouse_x := get_viewport().get_mouse_position().x
		if is_dragging:
			var dx := mouse_x - drag_start_mouse_x
			drag_distance = maxf(drag_distance, absf(dx))
			var max_scroll := maxf(0.0, ROOM_WIDTH - get_viewport_rect().size.x)
			target_scroll_x = clampf(drag_start_scroll_x - dx, 0.0, max_scroll)
		else:
			var hit := _hit_test(get_local_mouse_position())
			if hit != hovered_hotspot:
				hovered_hotspot = hit
				if hit != "":
					hotspot_hovered.emit(str(HOTSPOTS[hit]["label"]))
				else:
					hotspot_hovered.emit("")


func _hit_test(local_pos: Vector2) -> String:
	for id in HOTSPOTS.keys():
		var rect: Rect2 = HOTSPOTS[id]["rect"]
		if rect.has_point(local_pos):
			return id
	return ""


func _draw() -> void:
	var sway_y := sin(anim_time * 3.2) * 0.85
	draw_set_transform(Vector2(0, sway_y), 0.0, Vector2.ONE)

	_draw_dining_architecture()
	_draw_dining_windows()
	_draw_menu_board()
	_draw_tea_bar()
	_draw_tea_tables()
	_draw_chef_madeleine()
	_draw_dumbwaiter()
	_draw_exit_door()
	_draw_tick_companion()
	_draw_chandeliers_and_atmosphere()
	_draw_hover_highlight()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 1. 4호차 식당칸 건축 (에메랄드 벨벳 벽지, 마호가니 웨인스코팅, 원근 바닥 & 러그)
# ==============================================================================
func _draw_dining_architecture() -> void:
	_draw_v_gradient_rect(Rect2(0, 0, ROOM_WIDTH, 112), Color("#0E1A18"), Color("#1C302A"))
	for x in range(100, int(ROOM_WIDTH), 260):
		draw_rect(Rect2(x, 0, 18, 100), Color("#36201C"))
		draw_rect(Rect2(x, 94, 18, 10), Color("#D4AF37"))

	# 천장 황동 몰딩
	draw_rect(Rect2(0, 100, ROOM_WIDTH, 14), Color("#8B6528"))
	draw_rect(Rect2(0, 103, ROOM_WIDTH, 4), Color("#E5C068"))

	# 상단 벽지 (깊은 에메랄드 티룸 톤 + 금사 세로 줄무늬)
	_draw_v_gradient_rect(Rect2(0, 114, ROOM_WIDTH, 326), Color("#17342C"), Color("#23493E"))
	for x in range(0, int(ROOM_WIDTH), 40):
		draw_rect(Rect2(x, 114, 16, 326), Color("#2D5B4E", 0.28))
		draw_line(Vector2(x + 20, 114), Vector2(x + 20, 440), Color("#D4AF37", 0.09), 1.0)

	# 허리선 황동 레일
	draw_rect(Rect2(0, 438, ROOM_WIDTH, 14), Color("#38201B"))
	draw_rect(Rect2(0, 441, ROOM_WIDTH, 5), Color("#D4AF37"))

	# 하단 웨인스코팅
	_draw_v_gradient_rect(Rect2(0, 452, ROOM_WIDTH, 136), Color("#42251E"), Color("#2B1613"))
	for x in range(12, int(ROOM_WIDTH) - 12, 160):
		var p := Rect2(x + 10, 464, 136, 106)
		draw_rect(p, Color("#512E25"))
		draw_rect(p, Color("#6D4135"), false, 2.0)
		draw_rect(p.grow(-8), Color("#361D18"))

	# 2.5D 원근 나무 마룻바닥
	_draw_v_gradient_rect(Rect2(0, 594, ROOM_WIDTH, 126), Color("#301B16"), Color("#190E0C"))
	var center_x := ROOM_WIDTH * 0.5
	for i in range(-18, 19):
		draw_line(Vector2(center_x + i * 75.0, 594), Vector2(center_x + i * 114.0, 720), Color("#160B09", 0.65), 2.0)

	# 에메랄드 & 골드 카펫 러그
	var rug := PackedVector2Array([
		Vector2(90, 616), Vector2(ROOM_WIDTH - 90, 616),
		Vector2(ROOM_WIDTH - 40, 704), Vector2(40, 704)
	])
	draw_colored_polygon(rug, Color("#1A4338"))
	draw_polyline(PackedVector2Array([
		Vector2(102, 623), Vector2(ROOM_WIDTH - 102, 623),
		Vector2(ROOM_WIDTH - 56, 697), Vector2(56, 697), Vector2(102, 623)
	]), Color("#D4AF37", 0.85), 2.5)


# ==============================================================================
# 2. 식당칸 별바다 창문 2개
# ==============================================================================
func _draw_dining_windows() -> void:
	for wx in [730.0, 1110.0]:
		var win := Rect2(wx, 134, 330, 224)
		draw_rect(win.grow(10), Color("#101A16", 0.6))
		_draw_v_gradient_rect(win, Color("#070D24"), Color("#1A2A58"))

		for s in stars:
			var sx := fmod(float(s["x"]) - anim_time * float(s["speed"]) + win.size.x * 10.0, win.size.x)
			var tw := 0.45 + 0.55 * sin(anim_time * 2.6 + float(s["phase"]))
			draw_circle(win.position + Vector2(sx, float(s["y"])), float(s["r"]), Color(1.0, 0.96, 0.82, tw))

		draw_rect(win, Color("#4D2C22"), false, 12.0)
		draw_rect(win.grow(-3), Color("#D4AF37"), false, 3.0)
		draw_line(Vector2(win.get_center().x, win.position.y), Vector2(win.get_center().x, win.end.y), Color("#4D2C22"), 8.0)

		# 크림색 벨벳 커튼
		draw_colored_polygon(PackedVector2Array([
			Vector2(win.position.x - 10, win.position.y - 6), Vector2(win.position.x + 56, win.position.y - 6),
			Vector2(win.position.x + 34, win.position.y + 135), Vector2(win.position.x + 48, win.end.y + 8),
			Vector2(win.position.x - 10, win.end.y + 8)
		]), Color("#E8DCC4"))
		draw_colored_polygon(PackedVector2Array([
			Vector2(win.end.x + 10, win.position.y - 6), Vector2(win.end.x - 56, win.position.y - 6),
			Vector2(win.end.x - 34, win.position.y + 135), Vector2(win.end.x - 48, win.end.y + 8),
			Vector2(win.end.x + 10, win.end.y + 8)
		]), Color("#E8DCC4"))


# ==============================================================================
# 3. 벽면 주문서 게시판 (레이튼식 논리 단서)
# ==============================================================================
func _draw_menu_board() -> void:
	var b := Rect2(148, 184, 178, 205)
	draw_rect(Rect2(b.position.x + 6, b.position.y + 8, b.size.x, b.size.y), Color("#0B1612", 0.6))
	draw_rect(b, Color("#5C3724"))
	draw_rect(b.grow(-8), Color("#26352E"))
	draw_rect(b, Color("#D4AF37"), false, 3.5)

	# 양피지 주문서 2장
	draw_rect(Rect2(170, 206, 62, 82), Color("#FDF6E3"))
	draw_circle(Vector2(201, 212), 4.0, Color("#DC2626"))
	draw_rect(Rect2(244, 224, 62, 92), Color("#FEF3C7"))
	draw_circle(Vector2(275, 230), 4.0, Color("#D4AF37"))

	for ly in [228, 240, 252, 264]:
		draw_line(Vector2(178, ly), Vector2(224, ly), Color("#6B4E35", 0.65), 1.8)
	for ly in [248, 260, 272, 284, 296]:
		draw_line(Vector2(252, ly), Vector2(298, ly), Color("#6B4E35", 0.65), 1.8)

	# 아직 티 퍼즐을 안 풀었을 때 은은한 반짝임 유도
	if not GameState.has_flag("ch2_tea_solved"):
		var p := 0.4 + 0.5 * absf(sin(anim_time * 3.0))
		draw_circle(Vector2(275, 265), 14.0 + p * 5.0, Color(1.0, 0.9, 0.5, p * 0.3))


# ==============================================================================
# 4. 좌측 황동 티 바 (3가지 홍차 찻통 & 주전자)
# ==============================================================================
func _draw_tea_bar() -> void:
	var bar := Rect2(390, 442, 250, 152)
	draw_ellipse_shadow(Vector2(515, 600), 135.0, 14.0)
	_draw_v_gradient_rect(bar, Color("#613726"), Color("#3D2117"))
	draw_rect(Rect2(382, 434, 266, 16), Color("#7D4A34"))
	draw_rect(bar, Color("#D4AF37"), false, 2.5)

	# 상단 벽면 선반 + 3종 홍차 틴 케이스 (로즈·얼그레이·카모마일)
	draw_rect(Rect2(400, 386, 230, 12), Color("#5E3524"))
	var tin_cols: Array[Color] = [Color("#E11D48"), Color("#2563EB"), Color("#EAB308")]
	for i in range(3):
		var tx := 424.0 + i * 74.0
		draw_rect(Rect2(tx, 342, 40, 44), tin_cols[i])
		draw_rect(Rect2(tx - 2, 336, 44, 8), Color("#D4AF37"))
		draw_rect(Rect2(tx + 6, 354, 28, 18), Color("#FDF6E3"))

	# 카운터 위 황동 찻주전자
	var kp := Vector2(450, 414)
	_draw_ellipse(kp, 22.0, 18.0, Color("#D4AF37"))
	draw_circle(kp + Vector2(0, -18), 6.0, Color("#FDE68A"))
	draw_line(kp + Vector2(-18, 0), kp + Vector2(-32, -12), Color("#B8893A"), 5.0)
	draw_arc(kp + Vector2(20, 0), 10.0, -PI * 0.5, PI * 0.5, 10, Color("#B8893A"), 4.0)


# ==============================================================================
# 5. 중앙 3개 티테이블 (A: 창가, B: 중앙, C: 시계 옆)
# ==============================================================================
func _draw_tea_tables() -> void:
	var solved := GameState.has_flag("ch2_tea_solved")
	var tea_colors: Array[Color] = [Color("#FB7185"), Color("#60A5FA"), Color("#FACC15")]
	var positions: Array[float] = [825.0, 990.0, 1155.0]

	for i in range(3):
		var cx := positions[i]
		draw_ellipse_shadow(Vector2(cx, 604), 66.0, 12.0)
		# 테이블 다리
		draw_rect(Rect2(cx - 8, 490, 16, 112), Color("#4A2A20"))
		draw_rect(Rect2(cx - 28, 594, 56, 8), Color("#361D16"))
		# 하얀 식탁보 (물결 레이스)
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx - 66, 466), Vector2(cx + 66, 466),
			Vector2(cx + 72, 524), Vector2(cx - 72, 524)
		]), Color("#F8F4EA"))
		draw_line(Vector2(cx - 66, 466), Vector2(cx + 66, 466), Color("#D4AF37"), 3.0)
		# 찻잔 & 받침접시
		draw_rect(Rect2(cx - 18, 460, 36, 6), Color("#CBD5E1"))
		draw_rect(Rect2(cx - 12, 444, 24, 16), Color("#FFFFFF"))
		if solved:
			draw_rect(Rect2(cx - 9, 446, 18, 6), tea_colors[i])
			var sy := 436.0 - fmod(anim_time * 12.0 + i * 7.0, 18.0)
			draw_circle(Vector2(cx, sy), 3.5, Color(1, 1, 1, 0.25))


# ==============================================================================
# 6. 도자기 인형 요리사 '마들렌' (+ 케이크 전달 시 촛불 생일상)
# ==============================================================================
func _draw_chef_madeleine() -> void:
	var bob := sin(anim_time * 2.6) * 2.0
	var cx := 1345.0
	var base_y := 590.0

	draw_ellipse_shadow(Vector2(cx, base_y + 4), 48.0, 12.0)

	# 요리사 드레스/앞치마 몸체
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 26, 430 + bob), Vector2(cx + 26, 430 + bob),
		Vector2(cx + 46, base_y), Vector2(cx - 46, base_y)
	]), Color("#1E293B"))
	# 하얀 앞치마
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 18, 448 + bob), Vector2(cx + 18, 448 + bob),
		Vector2(cx + 28, base_y - 6), Vector2(cx - 28, base_y - 6)
	]), Color("#FFFBEB"))
	# 빨간 스카프 리본
	draw_circle(Vector2(cx, 434 + bob), 7.0, Color("#DC2626"))

	# 등 뒤 황동 태엽
	draw_circle(Vector2(cx + 34, 462 + bob), 10.0, Color("#D4AF37"))
	draw_circle(Vector2(cx + 34, 462 + bob), 4.0, Color("#23493E"))

	# 도자기 얼굴
	var head := Vector2(cx, 396 + bob)
	draw_circle(head, 28.0, Color("#FEF3E2"))
	draw_circle(head + Vector2(-10, -2), 3.5, Color("#1E293B"))
	draw_circle(head + Vector2(10, -2), 3.5, Color("#1E293B"))
	# 발그레한 볼
	draw_circle(head + Vector2(-15, 6), 4.5, Color("#FDA4AF", 0.55))
	draw_circle(head + Vector2(15, 6), 4.5, Color("#FDA4AF", 0.55))
	# 미소
	if GameState.has_flag("ch2_cake_served"):
		draw_arc(head + Vector2(0, 6), 7.0, 0.1, PI - 0.1, 10, Color("#9F1239"), 2.2)
	else:
		draw_line(head + Vector2(-5, 10), head + Vector2(5, 10), Color("#78350F"), 2.0)

	# 푹신한 하얀 요리사 모자(토크)
	draw_rect(Rect2(cx - 24, 356 + bob, 48, 22), Color("#FFFFFF"))
	draw_circle(Vector2(cx - 16, 344 + bob), 18.0, Color("#FFFFFF"))
	draw_circle(Vector2(cx, 336 + bob), 21.0, Color("#FFFFFF"))
	draw_circle(Vector2(cx + 16, 344 + bob), 18.0, Color("#FFFFFF"))

	# 촛불 켜진 생일 케이크가 완성되었을 때 마들렌 앞 트레이에 표시
	if GameState.has_flag("ch2_cake_served"):
		var ck := Vector2(cx, 478 + bob)
		draw_rect(Rect2(ck.x - 32, ck.y + 10, 64, 8), Color("#D4AF37"))
		draw_rect(Rect2(ck.x - 24, ck.y - 12, 48, 22), Color("#FFFBEB"))
		draw_rect(Rect2(ck.x - 24, ck.y - 12, 48, 7), Color("#FB7185"))
		# 촛불 3개 + 따뜻한 후광
		for ox in [-12.0, 0.0, 12.0]:
			draw_rect(Rect2(ck.x + ox - 2, ck.y - 24, 4, 12), Color("#FDE68A"))
			var fl := Vector2(ck.x + ox, ck.y - 28)
			draw_circle(fl, 14.0, Color(1.0, 0.85, 0.35, 0.25))
			draw_circle(fl, 4.0, Color("#FFFBEB"))


# ==============================================================================
# 7. 우측 주방 덤웨이터 (음식 승강기)
# ==============================================================================
func _draw_dumbwaiter() -> void:
	var dw := Rect2(1552, 238, 188, 250)
	var used := GameState.has_flag("ch2_dumbwaiter_used")

	draw_rect(dw.grow(10), Color("#2B1613"))
	draw_rect(dw.grow(6), Color("#C59B43"))

	if used:
		# 열린 덤웨이터 내부 (아래 주방의 따뜻한 불빛)
		_draw_v_gradient_rect(dw, Color("#291A14"), Color("#543222"))
		draw_rect(Rect2(dw.position.x + 12, dw.end.y - 22, dw.size.x - 24, 14), Color("#D4AF37"))
		# 도르래 줄
		draw_line(Vector2(dw.get_center().x, dw.position.y), Vector2(dw.get_center().x, dw.end.y - 22), Color("#94A3B8"), 3.0)
	else:
		# 닫힌 셔터 문
		_draw_v_gradient_rect(dw, Color("#593326"), Color("#3D2017"))
		for sy in range(int(dw.position.y) + 24, int(dw.end.y), 24):
			draw_line(Vector2(dw.position.x + 6, sy), Vector2(dw.end.x - 6, sy), Color("#26120D"), 2.5)

	# 오른쪽 옆 핸들 소켓
	var sock := Vector2(dw.end.x + 22, dw.get_center().y)
	draw_circle(sock, 14.0, Color("#8B6528"))
	draw_circle(sock, 7.0, Color("#4ADE80") if used else Color("#18120E"))


# ==============================================================================
# 8. 4호차 출구 문 (열리면 3호차 온실의 푸른 별빛이 쏟아짐)
# ==============================================================================
func _draw_exit_door() -> void:
	var d := Rect2(1918, 152, 196, 444)
	var unlocked := GameState.has_flag("ch2_door_unlocked")

	draw_rect(d.grow(10), Color("#1A2923"))
	draw_rect(d.grow(6), Color("#B8893A"))

	if unlocked:
		_draw_v_gradient_rect(d, Color("#BAE6FD"), Color("#6366F1"))
		draw_rect(Rect2(d.position.x + 22, d.position.y + 24, d.size.x - 44, d.size.y - 36), Color("#E0F2FE", 0.85))
		draw_colored_polygon(PackedVector2Array([
			Vector2(d.position.x, d.end.y), Vector2(d.end.x, d.end.y),
			Vector2(d.end.x + 40, 720), Vector2(d.position.x - 80, 720)
		]), Color(0.58, 0.82, 1.0, 0.24))
	else:
		_draw_v_gradient_rect(d, Color("#244439"), Color("#162B24"))
		var g := Rect2(1950, 190, 132, 162)
		_draw_v_gradient_rect(g, Color("#1E293B"), Color("#312E81"))
		draw_rect(g, Color("#D4AF37"), false, 4.0)
		draw_rect(Rect2(1972, 376, 88, 32), Color("#D4AF37"))
		draw_rect(Rect2(1946, 434, 140, 132), Color("#1B362D"))
		draw_rect(Rect2(1930, 412, 16, 44), Color("#C59B43"))
		draw_circle(Vector2(1938, 424), 9.0, Color("#FDE68A"))


# ==============================================================================
# 9. 티크 동행 (좌측 티 바 위)
# ==============================================================================
func _draw_tick_companion() -> void:
	var bob := sin(anim_time * 4.2) * 2.4
	var pos := Vector2(582, 414 + bob)
	draw_ellipse_shadow(Vector2(582, 434), 14.0, 4.0)
	draw_line(pos + Vector2(-4, 12), Vector2(578, 434), Color("#8B6528"), 2.0)
	draw_line(pos + Vector2(4, 12), Vector2(586, 434), Color("#8B6528"), 2.0)
	draw_circle(pos + Vector2(8, -14), 5.0, Color("#E5C068"))
	_draw_ellipse(pos, 15.0, 12.0, Color("#D4AF37"))
	_draw_ellipse(pos + Vector2(3, 1), 9.0, 6.0, Color("#FDE68A", 0.75))
	draw_circle(pos + Vector2(-11, -8), 9.0, Color("#E5C068"))
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-19, -9), pos + Vector2(-26, -6), pos + Vector2(-18, -4)
	]), Color("#F59E0B"))
	draw_circle(pos + Vector2(-13, -10), 2.3, Color("#0F172A"))


# ==============================================================================
# 10. 황동 샹들리에 & 금빛 먼지
# ==============================================================================
func _draw_chandeliers_and_atmosphere() -> void:
	var flicker := 0.92 + 0.08 * sin(anim_time * 6.0)
	for cx in [650.0, 1450.0]:
		var p := Vector2(cx, 136)
		draw_line(Vector2(cx, 0), p, Color("#C59B43"), 4.0)
		draw_arc(p, 56.0, 0.15, PI - 0.15, 18, Color("#D4AF37"), 4.0)
		draw_circle(p + Vector2(0, 22), 185.0 * flicker, Color(1.0, 0.82, 0.35, 0.06))
		for ox in [-48.0, 0.0, 48.0]:
			var fp := p + Vector2(ox, 16)
			draw_circle(fp, 24.0 * flicker, Color(1.0, 0.88, 0.45, 0.2))
			draw_circle(fp, 5.0, Color("#FFFBEB"))

	for d in dust_motes:
		var dx := float(d["x"]) + sin(anim_time * 0.7 + float(d["phase"])) * float(d["drift"])
		var dy := float(d["y"]) + cos(anim_time * 0.5 + float(d["phase"])) * 10.0
		var alpha := 0.12 + 0.18 * absf(sin(anim_time * 1.4 + float(d["phase"])))
		draw_circle(Vector2(dx, dy), float(d["r"]), Color(1.0, 0.94, 0.7, alpha))


func _draw_hover_highlight() -> void:
	if hovered_hotspot == "" or not HOTSPOTS.has(hovered_hotspot):
		return
	var rect: Rect2 = HOTSPOTS[hovered_hotspot]["rect"]
	var alpha := 0.5 + 0.4 * sin(anim_time * 5.0)
	draw_rect(rect.grow(3), Color(0.99, 0.9, 0.54, alpha * 0.28), false, 7.0)
	draw_rect(rect, Color(1.0, 0.95, 0.7, alpha), false, 2.5)


func _draw_v_gradient_rect(rect: Rect2, top_col: Color, bot_col: Color) -> void:
	draw_polygon(
		PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
		PackedColorArray([top_col, top_col, bot_col, bot_col])
	)


func _draw_ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(24):
		var a := float(i) / 24.0 * TAU
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)


func draw_ellipse_shadow(center: Vector2, rx: float, ry: float) -> void:
	_draw_ellipse(center, rx, ry, Color(0.04, 0.02, 0.03, 0.5))

