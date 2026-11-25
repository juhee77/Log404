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
var clouds: Array[Dictionary] = []

const HOTSPOTS: Dictionary = {
	"coat": {
		"rect": Rect2(130, 175, 165, 380),
		"label": "오버사이즈 코트"
	},
	"suitcase": {
		"rect": Rect2(365, 495, 225, 118),
		"label": "침대 밑 가죽 여행가방"
	},
	"window": {
		"rect": Rect2(845, 120, 510, 275),
		"label": "별바다가 보이는 아치형 창문"
	},
	"table": {
		"rect": Rect2(935, 395, 330, 210),
		"label": "원목 테이블 (회중시계 & 여행일지)"
	},
	"mirror": {
		"rect": Rect2(1495, 150, 210, 295),
		"label": "황동 프레임 거울"
	},
	"validator": {
		"rect": Rect2(1760, 275, 120, 175),
		"label": "황동 부엉이 검표기"
	},
	"door": {
		"rect": Rect2(1905, 140, 225, 465),
		"label": "5호차 출구 문"
	}
}


func _ready() -> void:
	_init_ambient_particles()
	GameState.flag_changed.connect(_on_flag_changed)


func _init_ambient_particles() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 404

	stars.clear()
	for i in range(85):
		stars.append({
			"x": rng.randf_range(0.0, 490.0),
			"y": rng.randf_range(8.0, 245.0),
			"r": rng.randf_range(1.0, 2.8),
			"speed": rng.randf_range(6.0, 24.0),
			"phase": rng.randf_range(0.0, TAU),
			"sparkle": rng.randf() > 0.78
		})

	clouds.clear()
	for i in range(7):
		clouds.append({
			"x": rng.randf_range(0.0, 520.0),
			"y": rng.randf_range(120.0, 235.0),
			"rx": rng.randf_range(65.0, 130.0),
			"ry": rng.randf_range(18.0, 34.0),
			"speed": rng.randf_range(12.0, 28.0),
			"alpha": rng.randf_range(0.08, 0.18)
		})

	dust_motes.clear()
	for i in range(45):
		dust_motes.append({
			"x": rng.randf_range(80.0, ROOM_WIDTH - 80.0),
			"y": rng.randf_range(120.0, 580.0),
			"r": rng.randf_range(1.1, 2.6),
			"phase": rng.randf_range(0.0, TAU),
			"drift": rng.randf_range(6.0, 16.0)
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
	# 열차 특유의 아주 미세한 흔들림(진동) 효과
	var sway_y := sin(anim_time * 3.4) * 0.9
	draw_set_transform(Vector2(0, sway_y), 0.0, Vector2.ONE)

	_draw_carriage_architecture()
	_draw_window_and_starry_sky()
	_draw_bed_and_coat()
	_draw_suitcase()
	_draw_table_and_props()
	_draw_mirror()
	_draw_validator()
	_draw_exit_door()
	_draw_tick_companion()
	_draw_gas_lamps_and_atmosphere()
	_draw_hover_highlight()

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ==============================================================================
# 1. 객차 건축 구조 (아치 천장, 웨인스코팅 마호가니 벽, 2.5D 원근 마룻바닥 & 카펫)
# ==============================================================================
func _draw_carriage_architecture() -> void:
	# 아치형 천장 베이스 + 깊이 그라데이션
	_draw_v_gradient_rect(Rect2(0, 0, ROOM_WIDTH, 114), Color("#110C1A"), Color("#261828"))
	# 천장 곡선 목재 리브(갈비뼈 구조)
	for x in range(80, int(ROOM_WIDTH), 260):
		draw_rect(Rect2(x, 0, 18, 102), Color("#362020"))
		draw_rect(Rect2(x + 3, 0, 4, 102), Color("#54332E"))
		draw_rect(Rect2(x, 96, 18, 10), Color("#C59B43"))

	# 천장 황동 코니스 몰딩
	draw_rect(Rect2(0, 102, ROOM_WIDTH, 14), Color("#8B6528"))
	draw_rect(Rect2(0, 105, ROOM_WIDTH, 4), Color("#E5C068"))
	draw_rect(Rect2(0, 114, ROOM_WIDTH, 5), Color("#1A0F12", 0.65))

	# 상단 벽지 영역 (깊은 벨벳 버건디 + 은은한 세로 스트라이프 & 다이아 문양)
	_draw_v_gradient_rect(Rect2(0, 116, ROOM_WIDTH, 326), Color("#2D1720"), Color("#43212A"))
	for x in range(0, int(ROOM_WIDTH), 36):
		draw_rect(Rect2(x, 116, 16, 326), Color("#4E2630", 0.25))
		for y in range(150, 420, 72):
			var c := Vector2(x + 18, y)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -6), c + Vector2(5, 0), c + Vector2(0, 6), c + Vector2(-5, 0)
			]), Color("#D4AF37", 0.08))

	# 허리선 마호가니 & 황동 레일
	draw_rect(Rect2(0, 438, ROOM_WIDTH, 16), Color("#331B1A"))
	draw_rect(Rect2(0, 442, ROOM_WIDTH, 5), Color("#D4AF37"))
	draw_rect(Rect2(0, 443, ROOM_WIDTH, 2), Color("#FDE68A", 0.6))

	# 하단 웨인스코팅 목재 패널 (베벨 + 나뭇결)
	_draw_v_gradient_rect(Rect2(0, 454, ROOM_WIDTH, 134), Color("#3C211E"), Color("#291514"))
	for x in range(12, int(ROOM_WIDTH) - 12, 160):
		var p := Rect2(x + 10, 466, 136, 104)
		draw_rect(p, Color("#492924"))
		draw_rect(p, Color("#613930"), false, 2.0)
		draw_rect(p.grow(-8), Color("#331B18"))
		draw_rect(p.grow(-8), Color("#231110"), false, 1.5)

	# 걸레받이(Baseboard) + 바닥 그림자
	draw_rect(Rect2(0, 582, ROOM_WIDTH, 14), Color("#221212"))
	draw_rect(Rect2(0, 582, ROOM_WIDTH, 2), Color("#8B6528", 0.6))

	# 2.5D 원근 나무 마룻바닥
	_draw_v_gradient_rect(Rect2(0, 596, ROOM_WIDTH, 124), Color("#2C1916"), Color("#180D0E"))
	var center_x := ROOM_WIDTH * 0.5
	for i in range(-18, 19):
		var top_x := center_x + i * 75.0
		var bot_x := center_x + i * 112.0
		draw_line(Vector2(top_x, 596), Vector2(bot_x, 720), Color("#150A0A", 0.65), 2.0)
	draw_line(Vector2(0, 642), Vector2(ROOM_WIDTH, 642), Color("#150A0A", 0.45), 1.5)
	draw_line(Vector2(0, 686), Vector2(ROOM_WIDTH, 686), Color("#150A0A", 0.45), 1.5)

	# 중앙 동화풍 보르도 벨벳 러그 (원근 사다리꼴 + 황금 자수)
	var rug := PackedVector2Array([
		Vector2(95, 616), Vector2(ROOM_WIDTH - 95, 616),
		Vector2(ROOM_WIDTH - 45, 704), Vector2(45, 704)
	])
	draw_colored_polygon(rug, Color("#601A2C"))
	draw_polyline(PackedVector2Array([
		Vector2(106, 623), Vector2(ROOM_WIDTH - 106, 623),
		Vector2(ROOM_WIDTH - 60, 697), Vector2(60, 697), Vector2(106, 623)
	]), Color("#D4AF37", 0.85), 2.5)
	draw_polyline(PackedVector2Array([
		Vector2(118, 631), Vector2(ROOM_WIDTH - 118, 631),
		Vector2(ROOM_WIDTH - 76, 689), Vector2(76, 689), Vector2(118, 631)
	]), Color("#FDE68A", 0.4), 1.5)


# ==============================================================================
# 2. 아치형 밤하늘 창문 (별바다, 은하수, 패럴랙스 구름, 유성, 숫자 4 별자리)
# ==============================================================================
func _draw_window_and_starry_sky() -> void:
	var win := Rect2(860, 132, 480, 250)

	# 창문 외곽 벽면 그림자
	draw_rect(win.grow(14), Color("#140A0E", 0.6))

	# 밤하늘 다층 그라데이션
	_draw_v_gradient_rect(win, Color("#060B1E"), Color("#18254F"))

	# 은하수 띠 (대각선 성운 글로우)
	for i in range(6):
		var offset := i * 16.0
		draw_line(
			win.position + Vector2(20, 210 - offset * 0.4),
			win.position + Vector2(460, 45 + offset * 0.4),
			Color(0.55, 0.58, 0.95, 0.045),
			26.0
		)

	# 패럴랙스 밤구름
	for c in clouds:
		var cx := fmod(float(c["x"]) - anim_time * float(c["speed"]) + 600.0, 560.0) - 40.0
		var pos := win.position + Vector2(cx, float(c["y"]))
		if pos.x > win.position.x - 40 and pos.x < win.end.x + 40:
			_draw_ellipse(pos, float(c["rx"]), float(c["ry"]), Color(0.28, 0.34, 0.58, float(c["alpha"])))

	# 흐르는 별빛 & 십자 스파클
	for s in stars:
		var sx := fmod(float(s["x"]) - anim_time * float(s["speed"]) + win.size.x * 12.0, win.size.x)
		var sy := float(s["y"])
		var twinkle := 0.45 + 0.55 * sin(anim_time * 2.8 + float(s["phase"]))
		var pos := win.position + Vector2(sx, sy)
		var r := float(s["r"])
		draw_circle(pos, r, Color(1.0, 0.97, 0.85, twinkle))
		if bool(s["sparkle"]):
			draw_line(pos - Vector2(r * 2.6, 0), pos + Vector2(r * 2.6, 0), Color(1.0, 0.96, 0.8, twinkle * 0.7), 1.0)
			draw_line(pos - Vector2(0, r * 2.6), pos + Vector2(0, r * 2.6), Color(1.0, 0.96, 0.8, twinkle * 0.7), 1.0)

	# 간헐적 유성 (6초 주기)
	var meteor_t := fmod(anim_time, 6.5)
	if meteor_t < 0.75:
		var prog := meteor_t / 0.75
		var head := win.position + Vector2(lerpf(420.0, 120.0, prog), lerpf(28.0, 118.0, prog))
		var tail := head + Vector2(48.0, -15.0)
		draw_line(head, tail, Color(1.0, 0.96, 0.78, (1.0 - prog) * 0.85), 2.2)
		draw_circle(head, 2.5, Color(1.0, 1.0, 0.92, 1.0 - prog))

	# 힌트 별자리: 숫자 '4' 모양
	var c_pts: Array[Vector2] = [
		win.position + Vector2(215, 52),
		win.position + Vector2(170, 132),
		win.position + Vector2(252, 132),
		win.position + Vector2(228, 70),
		win.position + Vector2(228, 184)
	]
	var pulse := 0.35 + 0.25 * sin(anim_time * 2.0)
	var line_col := Color(0.99, 0.91, 0.56, pulse)
	draw_line(c_pts[0], c_pts[1], line_col, 2.2)
	draw_line(c_pts[1], c_pts[2], line_col, 2.2)
	draw_line(c_pts[3], c_pts[4], line_col, 2.2)
	for pt in c_pts:
		draw_circle(pt, 9.0, Color(0.99, 0.91, 0.56, pulse * 0.35))
		draw_circle(pt, 4.0, Color("#FFFBEB"))

	# 부드러운 후광이 있는 초승달
	var moon_pos := win.position + Vector2(396, 74)
	draw_circle(moon_pos, 48.0, Color(0.99, 0.9, 0.54, 0.08))
	draw_circle(moon_pos, 32.0, Color(0.99, 0.9, 0.54, 0.14))
	draw_circle(moon_pos, 24.0, Color("#FEF08A"))
	draw_circle(moon_pos + Vector2(10, -6), 21.0, Color("#0C1532"))

	# 창문 유리 대각선 반사광
	draw_colored_polygon(PackedVector2Array([
		win.position + Vector2(40, 0), win.position + Vector2(95, 0),
		win.position + Vector2(25, win.size.y), win.position + Vector2(0, win.size.y)
	]), Color(1.0, 0.98, 0.9, 0.05))

	# 고급 마호가니 & 황동 창틀 + 창문 턱(Window Sill)
	draw_rect(win, Color("#4E2C24"), false, 14.0)
	draw_rect(win.grow(-4), Color("#D4AF37"), false, 3.5)
	draw_line(Vector2(win.position.x + win.size.x * 0.5, win.position.y), Vector2(win.position.x + win.size.x * 0.5, win.end.y), Color("#4E2C24"), 10.0)
	draw_line(Vector2(win.position.x + win.size.x * 0.5, win.position.y), Vector2(win.position.x + win.size.x * 0.5, win.end.y), Color("#D4AF37"), 2.5)
	# 창턱
	draw_rect(Rect2(win.position.x - 18, win.end.y + 2, win.size.x + 36, 14), Color("#5D352B"))
	draw_rect(Rect2(win.position.x - 18, win.end.y + 2, win.size.x + 36, 3), Color("#D4AF37", 0.7))

	# 벨벳 커튼 (좌/우 드레이프 주름 + 황금 타이백)
	_draw_curtain(Vector2(842, 122), true)
	_draw_curtain(Vector2(1358, 122), false)
	# 커튼 봉
	draw_rect(Rect2(822, 118, 556, 8), Color("#B8893A"))
	draw_circle(Vector2(822, 122), 9.0, Color("#E5C068"))
	draw_circle(Vector2(1378, 122), 9.0, Color("#E5C068"))


func _draw_curtain(origin: Vector2, is_left: bool) -> void:
	var dir := 1.0 if is_left else -1.0
	var outer := PackedVector2Array([
		origin,
		origin + Vector2(dir * 86, 0),
		origin + Vector2(dir * 52, 165),
		origin + Vector2(dir * 72, 272),
		origin + Vector2(0, 272)
	])
	draw_colored_polygon(outer, Color("#6E1A30"))
	# 주름 음영
	var fold := PackedVector2Array([
		origin + Vector2(dir * 26, 0),
		origin + Vector2(dir * 52, 0),
		origin + Vector2(dir * 34, 165),
		origin + Vector2(dir * 42, 272),
		origin + Vector2(dir * 18, 272)
	])
	draw_colored_polygon(fold, Color("#4D1020", 0.65))
	# 황금 커튼 끈(타이백)
	draw_line(origin + Vector2(0, 165), origin + Vector2(dir * 54, 165), Color("#E5C068"), 6.0)
	draw_circle(origin + Vector2(dir * 54, 165), 6.0, Color("#FDE68A"))


# ==============================================================================
# 3. 코트 행거 + 오버사이즈 코트 + 동화풍 1인 침대
# ==============================================================================
func _draw_bed_and_coat() -> void:
	# --- 황동 & 원목 코트 행거 ---
	draw_ellipse_shadow(Vector2(215, 594), 52.0, 14.0)
	# 삼발이 다리
	draw_line(Vector2(215, 540), Vector2(174, 592), Color("#3D221E"), 8.0)
	draw_line(Vector2(215, 540), Vector2(256, 592), Color("#3D221E"), 8.0)
	draw_line(Vector2(215, 175), Vector2(215, 588), Color("#4A2A24"), 12.0)
	draw_line(Vector2(213, 175), Vector2(213, 588), Color("#6B3E33"), 3.0)
	# 상단 황동 고리
	draw_arc(Vector2(197, 200), 16.0, PI * 0.2, PI * 1.1, 14, Color("#D4AF37"), 4.0)
	draw_arc(Vector2(233, 200), 16.0, -PI * 0.1, PI * 0.8, 14, Color("#D4AF37"), 4.0)
	draw_circle(Vector2(215, 174), 11.0, Color("#E5C068"))

	# --- 오버사이즈 남색 코트 (라펠, 단추, 주머니, 천 주름) ---
	var coat_body := PackedVector2Array([
		Vector2(180, 212), Vector2(252, 212),
		Vector2(278, 255), Vector2(272, 462),
		Vector2(158, 462), Vector2(152, 255)
	])
	draw_colored_polygon(coat_body, Color("#243352"))
	# 오른쪽 그림자면
	draw_colored_polygon(PackedVector2Array([
		Vector2(226, 212), Vector2(252, 212), Vector2(278, 255), Vector2(272, 462), Vector2(226, 462)
	]), Color("#1A263E", 0.55))
	draw_polyline(coat_body, Color("#131C30"), 2.5)
	# 옷깃(라펠)
	draw_colored_polygon(PackedVector2Array([
		Vector2(188, 212), Vector2(215, 272), Vector2(174, 260)
	]), Color("#32456D"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(242, 212), Vector2(215, 272), Vector2(256, 260)
	]), Color("#2A3B5E"))
	# 황동 단추 6개
	for row in range(3):
		var by := 294.0 + row * 40.0
		draw_circle(Vector2(202, by), 4.5, Color("#E5C068"))
		draw_circle(Vector2(228, by), 4.5, Color("#C59B43"))
	# 주머니 플랩
	draw_rect(Rect2(232, 344, 30, 10), Color("#1A263E"))
	draw_rect(Rect2(232, 344, 30, 3), Color("#465D8C"))

	# 코트 주머니 반짝임 (티크 합류 전)
	if not GameState.has_flag("coat_searched"):
		var pulse := 0.45 + 0.55 * absf(sin(anim_time * 3.2))
		var sp := Vector2(246, 352)
		draw_circle(sp, 16.0 + pulse * 6.0, Color(1.0, 0.88, 0.45, pulse * 0.35))
		draw_line(sp - Vector2(12, 0), sp + Vector2(12, 0), Color("#FFFBEB", pulse), 2.5)
		draw_line(sp - Vector2(0, 12), sp + Vector2(0, 12), Color("#FFFBEB", pulse), 2.5)
		draw_circle(sp, 4.5, Color("#FFFBEB"))

	# --- 동화풍 1인 침대 ---
	# 침대 바닥 그림자
	draw_rect(Rect2(316, 586, 434, 18), Color("#100709", 0.72))
	# 침대 밑 어두운 공간
	draw_rect(Rect2(342, 488, 378, 106), Color("#160C0E"))
	# 침대 머리판 & 발판 (조각 몰딩 + 황동 구슬)
	draw_rect(Rect2(314, 302, 34, 290), Color("#4E2B24"))
	draw_rect(Rect2(320, 314, 22, 160), Color("#63382E"))
	draw_circle(Vector2(331, 296), 13.0, Color("#D4AF37"))
	draw_circle(Vector2(328, 293), 5.0, Color("#FEF08A", 0.7))

	draw_rect(Rect2(716, 346, 28, 246), Color("#4E2B24"))
	draw_circle(Vector2(730, 340), 11.0, Color("#D4AF37"))

	# 침대 프레임 가로대
	draw_rect(Rect2(344, 456, 376, 36), Color("#593229"))
	draw_rect(Rect2(344, 462, 376, 5), Color("#C59B43", 0.65))

	# 베개 (푹신한 타원 + 주름)
	_draw_ellipse(Vector2(396, 376), 44.0, 22.0, Color("#F5EBD6"))
	_draw_ellipse(Vector2(396, 384), 42.0, 12.0, Color("#DFD1B5"))

	# 매트리스 시트
	draw_rect(Rect2(348, 396, 368, 60), Color("#F6EFE0"))
	draw_rect(Rect2(348, 444, 368, 12), Color("#D8CCB2"))

	# 별빛 퀼트 이불 (접힌 윗단 + 별 자수)
	var quilt := PackedVector2Array([
		Vector2(428, 388), Vector2(718, 388),
		Vector2(724, 474), Vector2(420, 474)
	])
	draw_colored_polygon(quilt, Color("#24365A"))
	# 이불 접힌 크림색 윗단
	draw_colored_polygon(PackedVector2Array([
		Vector2(426, 388), Vector2(464, 388), Vector2(458, 474), Vector2(420, 474)
	]), Color("#EDE0C4"))
	# 이불 위 작은 별 자수 패턴
	for bx in [505, 565, 625, 680]:
		for by in [414, 448]:
			draw_circle(Vector2(bx, by), 2.5, Color("#FDE68A", 0.65))
	draw_polyline(quilt, Color("#17233B"), 2.5)


# ==============================================================================
# 4. 침대 밑 빈티지 가죽 여행가방
# ==============================================================================
func _draw_suitcase() -> void:
	var opened := GameState.has_flag("suitcase_opened")
	var box := Rect2(378, 508, 198, 88)

	# 바닥 그림자
	draw_rect(Rect2(372, 592, 212, 10), Color("#090406", 0.8))

	# 가죽 본체 그라데이션
	_draw_v_gradient_rect(box, Color("#854B2E"), Color("#5B301C"))
	draw_rect(box, Color("#33190E"), false, 3.0)

	# 네 모서리 황동 보호대
	var corner_col := Color("#D4AF37")
	draw_rect(Rect2(box.position.x, box.position.y, 16, 16), corner_col)
	draw_rect(Rect2(box.end.x - 16, box.position.y, 16, 16), corner_col)
	draw_rect(Rect2(box.position.x, box.end.y - 16, 16, 16), corner_col)
	draw_rect(Rect2(box.end.x - 16, box.end.y - 16, 16, 16), corner_col)

	# 가죽 손잡이
	draw_arc(Vector2(box.get_center().x, box.position.y + 2), 20.0, PI, TAU, 14, Color("#3F2012"), 6.0)

	# 가죽 벨트 2줄 + 황동 버클
	for bx in [416.0, 522.0]:
		draw_rect(Rect2(bx, box.position.y, 16, box.size.y), Color("#462314"))
		draw_rect(Rect2(bx + 2, box.position.y + 34, 12, 18), Color("#D4AF37"), false, 2.5)

	# 빈티지 여행 스티커 (별/달)
	draw_rect(Rect2(442, 518, 22, 16), Color("#FDE68A", 0.85))
	draw_circle(Vector2(453, 526), 4.0, Color("#24365A"))

	# 3자리 다이얼 황동 자물쇠
	var lock_rect := Rect2(457, 540, 40, 30)
	draw_rect(lock_rect, Color("#4ADE80") if opened else Color("#D4AF37"))
	draw_rect(lock_rect, Color("#5C4212"), false, 2.0)
	for i in range(3):
		draw_rect(Rect2(463 + i * 10, 549, 7, 12), Color("#1E1B18"))

	if opened:
		draw_rect(Rect2(382, 494, 190, 14), Color("#9B5B3A"))
		draw_rect(Rect2(382, 494, 190, 14), Color("#33190E"), false, 2.0)


# ==============================================================================
# 5. 원목 테이블 + 여행일지 + 황동 회중시계 + 김 나는 찻잔
# ==============================================================================
func _draw_table_and_props() -> void:
	# 바닥 그림자
	draw_ellipse_shadow(Vector2(1100, 606), 145.0, 18.0)

	# 곡선 원목 다리 + 하단 선반
	draw_rect(Rect2(980, 488, 16, 118), Color("#4C2B21"))
	draw_rect(Rect2(1204, 488, 16, 118), Color("#4C2B21"))
	draw_rect(Rect2(986, 558, 228, 10), Color("#3D211A"))

	# 상판 (입체감 + 황동 테두리)
	draw_rect(Rect2(952, 464, 296, 26), Color("#6E3F2D"))
	draw_rect(Rect2(952, 464, 296, 6), Color("#8D543D"))
	draw_rect(Rect2(952, 484, 296, 6), Color("#3D2016"))
	# 레이스 테이블 러너
	draw_rect(Rect2(1010, 464, 180, 20), Color("#F4EBD0", 0.85))
	draw_rect(Rect2(1010, 482, 180, 4), Color("#D4AF37", 0.7))

	# --- 펼쳐진 양피지 여행일지 ---
	draw_colored_polygon(PackedVector2Array([
		Vector2(986, 444), Vector2(1038, 438), Vector2(1090, 444),
		Vector2(1086, 468), Vector2(1038, 464), Vector2(990, 468)
	]), Color("#FDF6E3"))
	draw_line(Vector2(1038, 438), Vector2(1038, 464), Color("#C2B59B"), 2.0)
	# 필기선 & 빨간 리본 책갈피
	for ly in [448, 454, 460]:
		draw_line(Vector2(998, ly), Vector2(1030, ly - 1), Color("#8B7355", 0.65), 1.5)
		draw_line(Vector2(1046, ly - 1), Vector2(1078, ly), Color("#8B7355", 0.65), 1.5)
	draw_line(Vector2(1038, 464), Vector2(1044, 478), Color("#B91C1C"), 3.0)

	# --- 김이 모락모락 나는 도자기 찻잔 ---
	draw_ellipse_shadow(Vector2(1112, 466), 20.0, 5.0)
	draw_rect(Rect2(1098, 446, 26, 20), Color("#F8FAFC"))
	draw_arc(Vector2(1124, 456), 6.0, -PI * 0.5, PI * 0.5, 10, Color("#E2E8F0"), 2.5)
	draw_line(Vector2(1098, 450), Vector2(1124, 450), Color("#D4AF37"), 2.0)
	# 올라가는 수증기 곡선
	for i in range(2):
		var st := anim_time * 1.8 + i * 1.4
		var sx := 1108.0 + i * 8.0 + sin(st) * 3.0
		var sy := 438.0 - fmod(st * 10.0, 22.0)
		draw_circle(Vector2(sx, sy), 3.5, Color(1, 1, 1, 0.22))

	# --- 황동 회중시계 (체인 + 04:04 바늘) ---
	var wp := Vector2(1172, 444)
	# 시계 체인
	draw_arc(wp + Vector2(22, 16), 24.0, 0.2, 2.2, 14, Color("#D4AF37"), 2.0)
	draw_circle(wp + Vector2(0, -24), 6.0, Color("#D4AF37"))
	draw_circle(wp, 24.0, Color("#C59B43"))
	draw_circle(wp, 20.0, Color("#E5C068"))
	draw_circle(wp, 17.5, Color("#FFFBEB"))
	# 04:04 시침/분침
	draw_line(wp, wp + Vector2(9, 6), Color("#1E293B"), 2.8)
	draw_line(wp, wp + Vector2(6, -11), Color("#1E293B"), 2.0)
	draw_circle(wp, 2.5, Color("#B45309"))


# ==============================================================================
# 6. 화려한 황동 프레임 거울
# ==============================================================================
func _draw_mirror() -> void:
	var m := Rect2(1514, 172, 174, 248)
	# 벽면 그림자
	draw_rect(m.grow(14), Color("#140A0E", 0.55))
	# 이중 황동 프레임
	draw_rect(m.grow(10), Color("#A67C2E"))
	draw_rect(m.grow(6), Color("#E5C068"))
	draw_rect(m.grow(2), Color("#6B4E16"))
	# 상단 별 문양 왕관 장식
	var top_c := Vector2(m.get_center().x, m.position.y - 16)
	draw_circle(top_c, 13.0, Color("#D4AF37"))
	draw_circle(top_c, 6.0, Color("#FEF08A"))

	if GameState.has_flag("mirror_wiped"):
		_draw_v_gradient_rect(m, Color("#1E293B"), Color("#334155"))
		# 대각선 유리 반사광
		draw_colored_polygon(PackedVector2Array([
			m.position + Vector2(24, 0), m.position + Vector2(62, 0),
			m.position + Vector2(0, 96), m.position + Vector2(0, 52)
		]), Color(1, 1, 1, 0.08))
		# 빛나는 보름달 모양 숫자 '0'
		var glow := 0.25 + 0.15 * sin(anim_time * 2.2)
		draw_arc(m.get_center(), 46.0, 0.0, TAU, 40, Color(0.99, 0.9, 0.54, glow), 16.0)
		draw_arc(m.get_center(), 46.0, 0.0, TAU, 40, Color("#FEF08A"), 7.0)
	else:
		_draw_v_gradient_rect(m, Color("#94A3B8"), Color("#CBD5E1"))
		# 뿌연 김 서림 구름
		draw_circle(m.get_center() + Vector2(-28, -36), 46.0, Color(1, 1, 1, 0.28))
		draw_circle(m.get_center() + Vector2(30, 22), 52.0, Color(1, 1, 1, 0.26))
		draw_circle(m.get_center() + Vector2(-12, 48), 38.0, Color(1, 1, 1, 0.22))


# ==============================================================================
# 7. 황동 부엉이 검표기
# ==============================================================================
func _draw_validator() -> void:
	var v := Rect2(1776, 294, 92, 138)
	var wound := GameState.has_flag("validator_wound")
	var unlocked := GameState.has_flag("door_unlocked")

	# 벽면 그림자
	draw_rect(Rect2(v.position.x + 6, v.position.y + 8, v.size.x, v.size.y), Color("#140A0E", 0.55))
	# 황동 본체 + 부엉이 귀깃
	draw_colored_polygon(PackedVector2Array([
		Vector2(v.position.x + 8, v.position.y + 6),
		Vector2(v.position.x + 2, v.position.y - 16),
		Vector2(v.position.x + 30, v.position.y + 4)
	]), Color("#B8893A"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(v.end.x - 8, v.position.y + 6),
		Vector2(v.end.x - 2, v.position.y - 16),
		Vector2(v.end.x - 30, v.position.y + 4)
	]), Color("#B8893A"))

	_draw_v_gradient_rect(v, Color("#A97A2E"), Color("#704D19"))
	draw_rect(v, Color("#E5C068"), false, 3.5)

	# 부엉이 둥근 렌즈 눈 (상태에 따라 회색 → 황금빛 → 에메랄드빛)
	var eye_col := Color("#4ADE80") if unlocked else (Color("#FACC15") if wound else Color("#334155"))
	for ex in [v.position.x + 28.0, v.position.x + 64.0]:
		var ep := Vector2(ex, v.position.y + 42.0)
		draw_circle(ep, 15.0, Color("#523711"))
		draw_circle(ep, 12.0, eye_col)
		if wound or unlocked:
			draw_circle(ep, 20.0, Color(eye_col.r, eye_col.g, eye_col.b, 0.22))
		draw_circle(ep + Vector2(-3, -3), 3.5, Color(1, 1, 1, 0.7))

	# 부리 모양 승차권 투입구
	draw_colored_polygon(PackedVector2Array([
		Vector2(v.get_center().x - 12, v.position.y + 58),
		Vector2(v.get_center().x + 12, v.position.y + 58),
		Vector2(v.get_center().x, v.position.y + 74)
	]), Color("#E5C068"))
	draw_rect(Rect2(v.position.x + 18, v.position.y + 82, 56, 10), Color("#18120E"))
	draw_rect(Rect2(v.position.x + 18, v.position.y + 82, 56, 10), Color("#E5C068"), false, 1.5)

	# 태엽 열쇠 구멍
	draw_circle(Vector2(v.get_center().x, v.position.y + 114), 11.0, Color("#4E3410"))
	draw_circle(Vector2(v.get_center().x, v.position.y + 114), 6.0, Color("#18120E"))


# ==============================================================================
# 8. 5호차 출구 문 (스테인드글라스 아치창 & CAR 05 황동 명판)
# ==============================================================================
func _draw_exit_door() -> void:
	var d := Rect2(1918, 152, 196, 444)
	var unlocked := GameState.has_flag("door_unlocked")

	# 문틀
	draw_rect(d.grow(10), Color("#2B1615"))
	draw_rect(d.grow(6), Color("#B8893A"))

	if unlocked:
		# 문이 열리며 4호차 식당칸의 따뜻한 호박빛이 쏟아짐
		_draw_v_gradient_rect(d, Color("#FEF3C7"), Color("#F59E0B"))
		draw_rect(Rect2(d.position.x + 22, d.position.y + 24, d.size.x - 44, d.size.y - 36), Color("#FFFBEB", 0.88))
		# 바닥으로 쏟아지는 빛 사다리꼴
		draw_colored_polygon(PackedVector2Array([
			Vector2(d.position.x, d.end.y), Vector2(d.end.x, d.end.y),
			Vector2(d.end.x + 40, 720), Vector2(d.position.x - 80, 720)
		]), Color(1.0, 0.92, 0.62, 0.22))
	else:
		_draw_v_gradient_rect(d, Color("#562D27"), Color("#3A1D1A"))
		# 상단 유리창 + 금색 격자(스테인드글라스 느낌)
		var g := Rect2(1950, 190, 132, 162)
		_draw_v_gradient_rect(g, Color("#1E293B"), Color("#3B2E4A"))
		draw_line(Vector2(g.get_center().x, g.position.y), Vector2(g.get_center().x, g.end.y), Color("#C59B43"), 2.5)
		draw_line(Vector2(g.position.x, g.get_center().y), Vector2(g.end.x, g.get_center().y), Color("#C59B43"), 2.5)
		draw_circle(g.get_center(), 24.0, Color("#FDE68A", 0.14))
		draw_rect(g, Color("#D4AF37"), false, 4.0)

		# 황동 명판 '05'
		var plate := Rect2(1972, 376, 88, 32)
		draw_rect(plate, Color("#D4AF37"))
		draw_rect(plate.grow(-3), Color("#6E4E16"), false, 1.5)

		# 하단 우드 패널
		draw_rect(Rect2(1946, 434, 140, 132), Color("#46231F"))
		draw_rect(Rect2(1946, 434, 140, 132), Color("#2A1311"), false, 2.5)

		# 곡선 황동 문손잡이
		draw_rect(Rect2(1930, 412, 16, 44), Color("#C59B43"))
		draw_circle(Vector2(1938, 424), 9.0, Color("#FDE68A"))


# ==============================================================================
# 9. 황동 태엽 참새 '티크' (합류 후 테이블 가장자리에서 함께 숨 쉬며 동행)
# ==============================================================================
func _draw_tick_companion() -> void:
	if not GameState.has_flag("tick_joined"):
		return
	var bob := sin(anim_time * 4.0) * 2.5
	var pos := Vector2(1218, 444 + bob)

	# 작은 그림자
	draw_ellipse_shadow(Vector2(1218, 464), 14.0, 4.0)
	# 다리
	draw_line(pos + Vector2(-4, 12), Vector2(1214, 464), Color("#8B6528"), 2.0)
	draw_line(pos + Vector2(4, 12), Vector2(1222, 464), Color("#8B6528"), 2.0)
	# 꼬리 & 등 태엽 키
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(12, 2), pos + Vector2(24, -4), pos + Vector2(22, 6)
	]), Color("#B8893A"))
	draw_circle(pos + Vector2(8, -14), 5.0, Color("#E5C068"))
	# 황동 몸통 & 날개
	_draw_ellipse(pos, 15.0, 12.0, Color("#D4AF37"))
	_draw_ellipse(pos + Vector2(3, 1), 9.0, 6.0, Color("#FDE68A", 0.75))
	# 머리, 부리, 반짝이는 눈
	draw_circle(pos + Vector2(-11, -8), 9.0, Color("#E5C068"))
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-19, -9), pos + Vector2(-26, -6), pos + Vector2(-18, -4)
	]), Color("#F59E0B"))
	draw_circle(pos + Vector2(-13, -10), 2.3, Color("#0F172A"))
	draw_circle(pos + Vector2(-14, -11), 0.9, Color.WHITE)


# ==============================================================================
# 10. 가스등 (유리 갓 + 불꽃 + 따뜻한 다층 조명 + 떠다니는 금빛 먼지)
# ==============================================================================
func _draw_gas_lamps_and_atmosphere() -> void:
	var lamp_positions: Array[Vector2] = [Vector2(565, 162), Vector2(1425, 162)]
	var flicker := 0.92 + 0.08 * sin(anim_time * 6.5) + 0.04 * cos(anim_time * 13.0)

	for pos in lamp_positions:
		# 넓은 환경광 글로우
		draw_circle(pos, 175.0 * flicker, Color(0.98, 0.72, 0.24, 0.055))
		draw_circle(pos, 96.0 * flicker, Color(0.99, 0.8, 0.32, 0.11))
		draw_circle(pos, 42.0 * flicker, Color(1.0, 0.9, 0.55, 0.22))

		# 황동 벽걸이 브래킷 & 갓
		draw_rect(Rect2(pos.x - 10, pos.y - 34, 20, 14), Color("#B8893A"))
		draw_colored_polygon(PackedVector2Array([
			pos + Vector2(-22, -16), pos + Vector2(22, -16),
			pos + Vector2(14, -26), pos + Vector2(-14, -26)
		]), Color("#D4AF37"))
		# 유리 글로브 & 흔들리는 불꽃
		_draw_ellipse(pos + Vector2(0, -2), 14.0, 16.0, Color(1.0, 0.95, 0.78, 0.72))
		_draw_ellipse(pos + Vector2(0, -1), 5.0 * flicker, 9.0 * flicker, Color("#FFFBEB"))

	# 공기 중 떠다니는 금빛 먼지 입자
	for d in dust_motes:
		var dx := float(d["x"]) + sin(anim_time * 0.7 + float(d["phase"])) * float(d["drift"])
		var dy := float(d["y"]) + cos(anim_time * 0.5 + float(d["phase"])) * 10.0
		var alpha := 0.12 + 0.18 * absf(sin(anim_time * 1.4 + float(d["phase"])))
		draw_circle(Vector2(dx, dy), float(d["r"]), Color(1.0, 0.92, 0.65, alpha))


func _draw_hover_highlight() -> void:
	if hovered_hotspot == "" or not HOTSPOTS.has(hovered_hotspot):
		return
	var rect: Rect2 = HOTSPOTS[hovered_hotspot]["rect"]
	var alpha := 0.5 + 0.4 * sin(anim_time * 5.0)
	draw_rect(rect.grow(3), Color(0.99, 0.9, 0.54, alpha * 0.28), false, 7.0)
	draw_rect(rect, Color(1.0, 0.95, 0.7, alpha), false, 2.5)


# ==============================================================================
# 드로잉 헬퍼 (그라데이션 사각형, 타원, 그림자)
# ==============================================================================
func _draw_v_gradient_rect(rect: Rect2, top_col: Color, bot_col: Color) -> void:
	var pts := PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y)
	])
	var cols := PackedColorArray([top_col, top_col, bot_col, bot_col])
	draw_polygon(pts, cols)


func _draw_ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var segs := 24
	for i in range(segs):
		var a := float(i) / float(segs) * TAU
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)


func draw_ellipse_shadow(center: Vector2, rx: float, ry: float) -> void:
	_draw_ellipse(center, rx, ry, Color(0.05, 0.02, 0.04, 0.52))
