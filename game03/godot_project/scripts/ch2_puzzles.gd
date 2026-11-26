class_name Ch2Puzzles
extends RefCounted

const TEA_OPTIONS: Array[String] = ["홍차 선택", "🌹 로즈 티", "🫖 얼그레이", "🌼 카모마일"]
const DESSERT_OPTIONS: Array[String] = ["디저트 선택", "🍬 마카롱", "🥐 스콘", "🥧 타르트"]
const JUG_CAPS: Array[int] = [8, 5, 3]


# ==============================================================================
# 미니게임 1: 황동 티 바 — 8·5·3oz 홍차 계량 퍼즐 (레이튼식 물 옮기기)
# ==============================================================================
class WaterJugPuzzle extends VBoxContainer:
	var on_done: Callable
	var amounts: Array[int] = [8, 0, 0]
	var selected_idx: int = -1
	var jug_buttons: Array[Button] = []
	var status_lbl: Label

	func _ready() -> void:
		add_theme_constant_override("separation", 14)

		var desc := Label.new()
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 16)
		desc.text = "8oz · 5oz · 3oz 용기를 옮겨 담아, 어느 용기든 정확히 [ 4oz ]의 홍차를 만드세요.\n(출발 용기를 누른 뒤, 부을 도착 용기를 클릭)"
		add_child(desc)

		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 20)
		add_child(row)

		for i in range(3):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(148, 126)
			btn.pressed.connect(_on_jug_clicked.bind(i))
			row.add_child(btn)
			jug_buttons.append(btn)

		status_lbl = Label.new()
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_font_size_override("font_size", 15)
		status_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
		add_child(status_lbl)

		var reset_btn := Button.new()
		reset_btn.text = "처음 상태로 되돌리기 (8 / 0 / 0)"
		reset_btn.custom_minimum_size = Vector2(240, 40)
		reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		reset_btn.pressed.connect(func():
			amounts = [8, 0, 0]
			selected_idx = -1
			_refresh()
		)
		add_child(reset_btn)
		_refresh()

	func _on_jug_clicked(idx: int) -> void:
		if selected_idx == -1:
			if amounts[idx] > 0:
				selected_idx = idx
			_refresh()
			return

		if selected_idx == idx:
			selected_idx = -1
			_refresh()
			return

		var pour := mini(amounts[selected_idx], Ch2Puzzles.JUG_CAPS[idx] - amounts[idx])
		if pour > 0:
			var next_amt: Array[int] = amounts.duplicate()
			next_amt[selected_idx] -= pour
			next_amt[idx] += pour
			amounts = next_amt
		selected_idx = -1
		_refresh()

		if amounts.has(4):
			GameState.set_flag("ch2_tea_brewed", true)
			GameState.add_item("golden_tea_pot")
			GameState.say("티크", "와! 정확히 4oz 황금 비율로 홍차를 우려냈어! [황금 홍차 포트]를 얻었으니 이제 중앙 티테이블에 세팅하러 가자!")
			if on_done.is_valid():
				on_done.call()

	func _refresh() -> void:
		var names: Array[String] = ["큰 주전자", "중간 컵", "작은 컵"]
		for i in range(3):
			var cap := Ch2Puzzles.JUG_CAPS[i]
			var bar := "■".repeat(amounts[i]) + "□".repeat(cap - amounts[i])
			var mark := "◀ 선택됨" if selected_idx == i else ""
			jug_buttons[i].text = "%s (%doz)\n\n%d / %doz\n%s\n%s" % [names[i], cap, amounts[i], cap, bar, mark]
		if selected_idx == -1:
			status_lbl.text = "물을 따를 출발 용기를 선택하세요."
		else:
			status_lbl.text = "%doz 용기 선택됨 → 물을 부을 도착 용기를 누르세요." % Ch2Puzzles.JUG_CAPS[selected_idx]


# ==============================================================================
# 미니게임 2: 중앙 티테이블 A·B·C — 2차원 논리 추리 (홍차 × 디저트)
# ==============================================================================
class TeaLogicPuzzle extends VBoxContainer:
	var on_done: Callable
	var tea_picks: Array[int] = [0, 0, 0]
	var dessert_picks: Array[int] = [0, 0, 0]
	var tea_btns: Array[Button] = []
	var dessert_btns: Array[Button] = []

	func _ready() -> void:
		add_theme_constant_override("separation", 14)

		var info := Label.new()
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info.add_theme_font_size_override("font_size", 16)
		info.text = "주문서 게시판의 5가지 단서에 따라 각 테이블의 [홍차]와 [디저트]를 모두 맞추세요."
		add_child(info)

		var names: Array[String] = ["테이블 A (창가)", "테이블 B (중앙)", "테이블 C (시계 옆)"]
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 14)
		add_child(row)

		for idx in range(3):
			var card := PanelContainer.new()
			var cstyle := StyleBoxFlat.new()
			cstyle.bg_color = Color("#1A352D")
			cstyle.border_color = Color("#D4AF37")
			cstyle.set_border_width_all(2)
			cstyle.set_corner_radius_all(10)
			cstyle.set_content_margin_all(12)
			card.add_theme_stylebox_override("panel", cstyle)
			row.add_child(card)

			var col := VBoxContainer.new()
			col.alignment = BoxContainer.ALIGNMENT_CENTER
			col.add_theme_constant_override("separation", 10)
			card.add_child(col)

			var lbl := Label.new()
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 15)
			lbl.add_theme_color_override("font_color", Color("#FDE68A"))
			lbl.text = names[idx]
			col.add_child(lbl)

			var tbtn := Button.new()
			tbtn.custom_minimum_size = Vector2(140, 42)
			tbtn.text = Ch2Puzzles.TEA_OPTIONS[0]
			tbtn.pressed.connect(_cycle_tea.bind(idx))
			col.add_child(tbtn)
			tea_btns.append(tbtn)

			var dbtn := Button.new()
			dbtn.custom_minimum_size = Vector2(140, 42)
			dbtn.text = Ch2Puzzles.DESSERT_OPTIONS[0]
			dbtn.pressed.connect(_cycle_dessert.bind(idx))
			col.add_child(dbtn)
			dessert_btns.append(dbtn)

		var submit := Button.new()
		submit.text = "티세트 서빙 완료"
		submit.custom_minimum_size = Vector2(220, 44)
		submit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		submit.pressed.connect(_check_answer)
		add_child(submit)

	func _cycle_tea(idx: int) -> void:
		var next_arr: Array[int] = tea_picks.duplicate()
		next_arr[idx] = (next_arr[idx] + 1) % Ch2Puzzles.TEA_OPTIONS.size()
		tea_picks = next_arr
		tea_btns[idx].text = Ch2Puzzles.TEA_OPTIONS[tea_picks[idx]]

	func _cycle_dessert(idx: int) -> void:
		var next_arr: Array[int] = dessert_picks.duplicate()
		next_arr[idx] = (next_arr[idx] + 1) % Ch2Puzzles.DESSERT_OPTIONS.size()
		dessert_picks = next_arr
		dessert_btns[idx].text = Ch2Puzzles.DESSERT_OPTIONS[dessert_picks[idx]]

	func _check_answer() -> void:
		# A: 로즈(1)+마카롱(1), B: 얼그레이(2)+스콘(2), C: 카모마일(3)+타르트(3)
		if tea_picks == [1, 2, 3] and dessert_picks == [1, 2, 3]:
			GameState.remove_item("golden_tea_pot")
			GameState.set_flag("ch2_tea_solved", true)
			GameState.add_item("dumbwaiter_handle")
			GameState.say("마들렌", "\"어머, 홍차와 디저트 페어링이 완벽해요! 감사해요, 이 [덤웨이터 핸들]로 오른쪽 승강기를 수리해 케이크를 올려주시겠어요?\"")
			if on_done.is_valid():
				on_done.call()
		else:
			GameState.say("티크", "어딘가 주문서랑 맞지 않아! 왼쪽 [주문서 게시판]의 5가지 단서를 다시 찬찬히 읽어보자.")


# ==============================================================================
# 미니게임 3: 주방 덤웨이터 — 3×3 황동 증기 파이프 회전 연결 퍼즐
# ==============================================================================
class PipeTile extends Control:
	signal rotated
	# kind: "straight" (초기 L-R), "corner" (초기 U-R)
	var kind: String = "straight"
	var rot_steps: int = 0 # 0..3 (시계방향 90도)
	var powered: bool = false

	func _ready() -> void:
		custom_minimum_size = Vector2(76, 76)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			rot_steps = (rot_steps + 1) % 4
			queue_redraw()
			rotated.emit()

	# 비트마스크: 1=UP, 2=RIGHT, 4=DOWN, 8=LEFT
	func get_ports() -> int:
		var base := 10 if kind == "straight" else 3 # straight: L(8)+R(2)=10, corner: U(1)+R(2)=3
		var mask := base
		for _i in range(rot_steps):
			var next_m := 0
			if mask & 1: next_m |= 2
			if mask & 2: next_m |= 4
			if mask & 4: next_m |= 8
			if mask & 8: next_m |= 1
			mask = next_m
		return mask

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("#241914"))
		draw_rect(r, Color("#8B6528"), false, 2.0)

		var c := r.get_center()
		var p_col := Color("#FDE68A") if powered else Color("#B8893A")
		var ports := get_ports()
		if ports & 1:
			draw_line(c, Vector2(c.x, 0), p_col, 14.0)
		if ports & 2:
			draw_line(c, Vector2(r.size.x, c.y), p_col, 14.0)
		if ports & 4:
			draw_line(c, Vector2(c.x, r.size.y), p_col, 14.0)
		if ports & 8:
			draw_line(c, Vector2(0, c.y), p_col, 14.0)
		draw_circle(c, 9.0, p_col)


class PipePuzzle extends VBoxContainer:
	var on_done: Callable
	var tiles: Array[PipeTile] = []

	func _ready() -> void:
		add_theme_constant_override("separation", 12)

		var desc := Label.new()
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.add_theme_font_size_override("font_size", 16)
		desc.text = "파이프를 클릭해 회전시켜 [왼쪽 위 입구 ▶]에서 [오른쪽 아래 출구 ▶]까지 증기를 연결하세요!"
		add_child(desc)

		var board_row := HBoxContainer.new()
		board_row.alignment = BoxContainer.ALIGNMENT_CENTER
		board_row.add_theme_constant_override("separation", 10)
		add_child(board_row)

		var in_lbl := Label.new()
		in_lbl.text = "증기 ▶\n\n\n\n"
		in_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
		board_row.add_child(in_lbl)

		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 4)
		grid.add_theme_constant_override("v_separation", 4)
		board_row.add_child(grid)

		var out_lbl := Label.new()
		out_lbl.text = "\n\n\n\n▶ 승강기"
		out_lbl.add_theme_color_override("font_color", Color("#4ADE80"))
		board_row.add_child(out_lbl)

		# 확정 해법 경로: (0,0)straight -> (1,0)corner -> (1,1)straight -> (1,2)corner -> (2,2)straight
		var layout: Array[Array] = [
			["straight", 1], ["corner", 0], ["corner", 2],
			["corner", 1], ["straight", 0], ["corner", 3],
			["straight", 1], ["corner", 2], ["straight", 1]
		]
		for spec in layout:
			var t := PipeTile.new()
			t.kind = str(spec[0])
			t.rot_steps = int(spec[1])
			t.rotated.connect(_update_flow)
			grid.add_child(t)
			tiles.append(t)

		_update_flow()

	func _update_flow() -> void:
		for t in tiles:
			t.powered = false

		var visited: Dictionary = {}
		var queue: Array[int] = []
		# (0,0)의 왼쪽 포트(8)가 열려 있어야 증기 유입
		if tiles[0].get_ports() & 8:
			visited[0] = true
			queue.append(0)

		var dirs: Array[Array] = [
			[-3, 1, 4], # UP: delta=-3, my=1, opp=4
			[1, 2, 8],  # RIGHT
			[3, 4, 1],  # DOWN
			[-1, 8, 2]  # LEFT
		]

		while not queue.is_empty():
			var cur: int = queue.pop_front()
			tiles[cur].powered = true
			var cx := cur % 3
			var cy := cur / 3
			var my_ports := tiles[cur].get_ports()

			for d in dirs:
				var delta: int = d[0]
				var my_bit: int = d[1]
				var opp_bit: int = d[2]
				if (my_ports & my_bit) == 0:
					continue
				if my_bit == 2 and cx == 2: continue
				if my_bit == 8 and cx == 0: continue
				if my_bit == 1 and cy == 0: continue
				if my_bit == 4 and cy == 2: continue
				var nxt := cur + delta
				if nxt >= 0 and nxt < 9 and not visited.has(nxt):
					if (tiles[nxt].get_ports() & opp_bit) != 0:
						visited[nxt] = true
						queue.append(nxt)

		for t in tiles:
			t.queue_redraw()

		# (2,2) index=8 이 powered 이고 오른쪽 포트(2)가 열려 있으면 클리어!
		if tiles[8].powered and (tiles[8].get_ports() & 2) != 0:
			GameState.remove_item("dumbwaiter_handle")
			GameState.set_flag("ch2_dumbwaiter_used", true)
			GameState.add_item("birthday_cake")
			GameState.add_item("star_match")
			GameState.say("티크", "쉬이익— 덜컹! 증기가 연결되면서 아래 주방에서 [생일 케이크]랑 [별빛 성냥]이 올라왔어! 소지품에서 둘을 합쳐보자!")
			if on_done.is_valid():
				on_done.call()


# ==============================================================================
# 미니게임 4: 생일 케이크 5-촛불 라이트온 (Lights On) 퍼즐
# ==============================================================================
class CandleLightsPuzzle extends VBoxContainer:
	var on_done: Callable
	# 초기 상태 [0, 1, 1, 1, 0] -> 3수(2 -> 1 -> 4)로 100% 해법 보장!
	var lit: Array[bool] = [false, true, true, true, false]
	var candle_btns: Array[Button] = []

	func _ready() -> void:
		add_theme_constant_override("separation", 16)

		var desc := Label.new()
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 16)
		desc.text = "촛불 하나를 누르면 그 촛불과 바로 양옆 촛불의 불이 함께 바뀝니다.\n5개의 생일 촛불을 모두 켜주세요!"
		add_child(desc)

		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 14)
		add_child(row)

		for i in range(5):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(88, 120)
			btn.pressed.connect(_toggle_candle.bind(i))
			row.add_child(btn)
			candle_btns.append(btn)

		var reset_btn := Button.new()
		reset_btn.text = "촛불 초기화"
		reset_btn.custom_minimum_size = Vector2(180, 40)
		reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		reset_btn.pressed.connect(func():
			lit = [false, true, true, true, false]
			_refresh()
		)
		add_child(reset_btn)
		_refresh()

	func _toggle_candle(idx: int) -> void:
		var next_lit: Array[bool] = lit.duplicate()
		for k in [idx - 1, idx, idx + 1]:
			if k >= 0 and k < 5:
				next_lit[k] = not next_lit[k]
		lit = next_lit
		_refresh()

		if not lit.has(false):
			GameState.remove_item("lit_cake")
			GameState.set_flag("ch2_cake_served", true)
			GameState.set_flag("ch2_door_unlocked", true)
			GameState.say("나레이션", "다섯 개의 촛불이 모두 켜진 순간, 누군가와 나란히 앉아 생일 노래를 부르던 따뜻한 기억이 되살아났다! 딸깍— 4호차 출구 문이 열렸다!")
			if on_done.is_valid():
				on_done.call()

	func _refresh() -> void:
		for i in range(5):
			candle_btns[i].text = ("🔥\n🕯️\nON" if lit[i] else "·\n🕯️\nOFF")

