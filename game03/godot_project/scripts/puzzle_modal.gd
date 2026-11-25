extends Control

signal modal_closed

var panel: PanelContainer
var title_label: Label
var content_box: VBoxContainer
var close_button: Button

var dial_values: Array[int] = [0, 0, 0]
var dial_labels: Array[Label] = []
var current_mode: String = ""


class ModalArtCanvas extends Control:
	var art_type: String = ""
	var is_wiped: bool = false

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		match art_type:
			"window":
				_draw_window_art(r)
			"clock":
				_draw_clock_art(r)
			"mirror":
				_draw_mirror_art(r)

	func _draw_window_art(r: Rect2) -> void:
		draw_polygon(
			PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]),
			PackedColorArray([Color("#060B1E"), Color("#060B1E"), Color("#1A2A58"), Color("#1A2A58")])
		)
		draw_rect(r, Color("#D4AF37"), false, 4.0)

		# 배경 작은 별들
		var bg_stars: Array[Vector2] = [
			Vector2(45, 32), Vector2(88, 72), Vector2(130, 28), Vector2(310, 44),
			Vector2(360, 128), Vector2(68, 148), Vector2(420, 152), Vector2(280, 162)
		]
		for p in bg_stars:
			draw_circle(p, 2.0, Color(1.0, 0.96, 0.82, 0.7))

		# 초승달
		var m := Vector2(395, 58)
		draw_circle(m, 34.0, Color(0.99, 0.9, 0.54, 0.14))
		draw_circle(m, 22.0, Color("#FEF08A"))
		draw_circle(m + Vector2(9, -5), 19.0, Color("#0C1636"))

		# 빛나는 '4' 모양 별자리
		var pts: Array[Vector2] = [
			Vector2(220, 32), Vector2(165, 118), Vector2(262, 118),
			Vector2(236, 52), Vector2(236, 168)
		]
		draw_line(pts[0], pts[1], Color("#FDE68A", 0.78), 2.5)
		draw_line(pts[1], pts[2], Color("#FDE68A", 0.78), 2.5)
		draw_line(pts[3], pts[4], Color("#FDE68A", 0.78), 2.5)
		for pt in pts:
			draw_circle(pt, 10.0, Color(0.99, 0.9, 0.54, 0.28))
			draw_circle(pt, 4.8, Color("#FFFBEB"))

	func _draw_clock_art(r: Rect2) -> void:
		var c := r.get_center()
		# 회중시계 고리 & 용두
		draw_arc(c + Vector2(0, -74), 14.0, 0.0, TAU, 24, Color("#D4AF37"), 4.0)
		draw_rect(Rect2(c.x - 10, c.y - 68, 20, 14), Color("#B8893A"))
		# 시계 외곽 황동 베젤
		draw_circle(c, 58.0, Color("#8C6226"))
		draw_circle(c, 54.0, Color("#E5C068"))
		draw_circle(c, 47.0, Color("#FFFBEB"))
		draw_arc(c, 47.0, 0.0, TAU, 48, Color("#B8893A"), 2.0)

		# 12시간 눈금
		for i in range(12):
			var a := float(i) / 12.0 * TAU - PI * 0.5
			var p1 := c + Vector2(cos(a), sin(a)) * 38.0
			var p2 := c + Vector2(cos(a), sin(a)) * 44.0
			draw_line(p1, p2, Color("#3B2322"), 2.5 if i % 3 == 0 else 1.5)

		# 04:04 시침(4시 방향) & 분침(4분 방향)
		var hour_a := (4.0 + 4.0 / 60.0) / 12.0 * TAU - PI * 0.5
		var min_a := (4.0 / 60.0) * TAU - PI * 0.5
		draw_line(c, c + Vector2(cos(hour_a), sin(hour_a)) * 24.0, Color("#1E293B"), 4.0)
		draw_line(c, c + Vector2(cos(min_a), sin(min_a)) * 34.0, Color("#334155"), 2.8)
		draw_circle(c, 4.5, Color("#B45309"))

	func _draw_mirror_art(r: Rect2) -> void:
		var m := r.grow(-8)
		draw_rect(r, Color("#A67C2E"))
		draw_rect(r.grow(-3), Color("#E5C068"))
		draw_rect(m, Color("#1E293B") if is_wiped else Color("#94A3B8"))

		if is_wiped:
			draw_colored_polygon(PackedVector2Array([
				m.position + Vector2(22, 0), m.position + Vector2(64, 0),
				m.position + Vector2(0, 92), m.position + Vector2(0, 50)
			]), Color(1, 1, 1, 0.09))
			draw_arc(m.get_center(), 52.0, 0.0, TAU, 44, Color(0.99, 0.9, 0.54, 0.25), 18.0)
			draw_arc(m.get_center(), 52.0, 0.0, TAU, 44, Color("#FEF08A"), 8.0)
		else:
			draw_circle(m.get_center() + Vector2(-42, -26), 54.0, Color(1, 1, 1, 0.26))
			draw_circle(m.get_center() + Vector2(36, 22), 60.0, Color(1, 1, 1, 0.24))
			draw_circle(m.get_center() + Vector2(-8, 44), 46.0, Color(1, 1, 1, 0.22))


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_base_ui()


func _build_base_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.05, 0.11, 0.8)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 420)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1D1624")
	style.border_color = Color("#D4AF37")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 16)
	panel.add_child(root_vbox)

	var header := HBoxContainer.new()
	root_vbox.add_child(header)

	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color("#FDE68A"))
	header.add_child(title_label)

	close_button = Button.new()
	close_button.text = "닫기 ✕"
	close_button.custom_minimum_size = Vector2(88, 36)
	close_button.pressed.connect(close_modal)
	header.add_child(close_button)

	root_vbox.add_child(HSeparator.new())

	content_box = VBoxContainer.new()
	content_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_box.add_theme_constant_override("separation", 14)
	root_vbox.add_child(content_box)


func _clear_content() -> void:
	for child in content_box.get_children():
		child.queue_free()
	dial_labels.clear()


func close_modal() -> void:
	visible = false
	current_mode = ""
	modal_closed.emit()


func open_window_view() -> void:
	current_mode = "window"
	_clear_content()
	title_label.text = "창밖의 별바다"

	var canvas := ModalArtCanvas.new()
	canvas.art_type = "window"
	canvas.custom_minimum_size = Vector2(460, 195)
	canvas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content_box.add_child(canvas)

	var desc := Label.new()
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 17)
	desc.text = "유리창 너머 밤하늘에서 유독 밝게 빛나는 별들이 선으로 이어져 있다.\n마치 숫자 '4'를 그려놓은 듯한 별자리다."
	content_box.add_child(desc)

	visible = true


func open_table_view() -> void:
	current_mode = "table"
	_clear_content()
	title_label.text = "회중시계 & 여행일지"

	var top_row := HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 24)
	content_box.add_child(top_row)

	var clock_canvas := ModalArtCanvas.new()
	clock_canvas.art_type = "clock"
	clock_canvas.custom_minimum_size = Vector2(150, 155)
	top_row.add_child(clock_canvas)

	var time_lbl := Label.new()
	time_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	time_lbl.add_theme_font_size_override("font_size", 28)
	time_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
	time_lbl.text = "04 : 04\n(멈춰 있음)"
	top_row.add_child(time_lbl)

	var note_panel := PanelContainer.new()
	var nstyle := StyleBoxFlat.new()
	nstyle.bg_color = Color("#FDF6E3")
	nstyle.border_color = Color("#C2B59B")
	nstyle.set_border_width_all(2)
	nstyle.set_corner_radius_all(8)
	nstyle.set_content_margin_all(16)
	note_panel.add_theme_stylebox_override("panel", nstyle)
	content_box.add_child(note_panel)

	var note_lbl := Label.new()
	note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_lbl.add_theme_font_size_override("font_size", 16)
	note_lbl.add_theme_color_override("font_color", Color("#3B2322"))
	note_lbl.text = "[ 낡은 여행일지의 메모 ]\n\"가방의 비밀을 잊었을 때를 위해 적어둔다.\n  첫째는 창밖의 별이 그린 숫자,\n  둘째는 김을 닦아낸 거울 속 보름달,\n  셋째는 멈춰버린 시계의 분침이 가리키는 수.\""
	note_panel.add_child(note_lbl)

	visible = true


func open_mirror_view() -> void:
	current_mode = "mirror"
	_clear_content()
	title_label.text = "황동 프레임 거울"

	var wiped := GameState.has_flag("mirror_wiped")
	var canvas := ModalArtCanvas.new()
	canvas.art_type = "mirror"
	canvas.is_wiped = wiped
	canvas.custom_minimum_size = Vector2(260, 190)
	canvas.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content_box.add_child(canvas)

	var desc := Label.new()
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 17)
	if wiped:
		desc.text = "김 서림을 닦아내자 둥근 보름달 모양의 숫자 '0'이 선명하게 떠올랐다."
		content_box.add_child(desc)
	else:
		desc.text = "밤공기 때문인지 거울 표면에 뽀얗게 김이 서려 있다."
		content_box.add_child(desc)
		var wipe_btn := Button.new()
		wipe_btn.text = "소매로 거울 닦기"
		wipe_btn.custom_minimum_size = Vector2(220, 44)
		wipe_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		wipe_btn.pressed.connect(func():
			GameState.set_flag("mirror_wiped", true)
			GameState.say("티크", "와, 거울에 보름달처럼 동그란 '0'이 숨어 있었어!")
			open_mirror_view()
		)
		content_box.add_child(wipe_btn)

	visible = true


func open_suitcase_view() -> void:
	current_mode = "suitcase"
	_clear_content()
	title_label.text = "침대 밑 가죽 여행가방"

	if GameState.has_flag("suitcase_opened"):
		var opened_lbl := Label.new()
		opened_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		opened_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		opened_lbl.add_theme_font_size_override("font_size", 18)
		opened_lbl.text = "자물쇠(4-0-4)가 풀려 있다.\n가방 안의 물건은 이미 모두 챙겼다."
		content_box.add_child(opened_lbl)
		visible = true
		return

	var info := Label.new()
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 17)
	info.text = "가죽 벨트 사이로 3자리 황동 다이얼 자물쇠가 단단히 잠겨 있다."
	content_box.add_child(info)

	var lock_plate := PanelContainer.new()
	lock_plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var lstyle := StyleBoxFlat.new()
	lstyle.bg_color = Color("#462314")
	lstyle.border_color = Color("#D4AF37")
	lstyle.set_border_width_all(3)
	lstyle.set_corner_radius_all(12)
	lstyle.set_content_margin_all(20)
	lock_plate.add_theme_stylebox_override("panel", lstyle)
	content_box.add_child(lock_plate)

	var dial_row := HBoxContainer.new()
	dial_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dial_row.add_theme_constant_override("separation", 24)
	lock_plate.add_child(dial_row)

	for idx in range(3):
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 8)
		dial_row.add_child(col)

		var up_btn := Button.new()
		up_btn.text = "▲"
		up_btn.custom_minimum_size = Vector2(72, 36)
		up_btn.pressed.connect(_change_dial.bind(idx, 1))
		col.add_child(up_btn)

		var num_frame := PanelContainer.new()
		var nf := StyleBoxFlat.new()
		nf.bg_color = Color("#18120E")
		nf.border_color = Color("#E5C068")
		nf.set_border_width_all(2)
		nf.set_corner_radius_all(6)
		nf.set_content_margin_all(6)
		num_frame.add_theme_stylebox_override("panel", nf)
		col.add_child(num_frame)

		var num_lbl := Label.new()
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.custom_minimum_size = Vector2(54, 46)
		num_lbl.add_theme_font_size_override("font_size", 34)
		num_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
		num_lbl.text = str(dial_values[idx])
		num_frame.add_child(num_lbl)
		dial_labels.append(num_lbl)

		var down_btn := Button.new()
		down_btn.text = "▼"
		down_btn.custom_minimum_size = Vector2(72, 36)
		down_btn.pressed.connect(_change_dial.bind(idx, -1))
		col.add_child(down_btn)

	var unlock_btn := Button.new()
	unlock_btn.text = "자물쇠 열어보기"
	unlock_btn.custom_minimum_size = Vector2(220, 46)
	unlock_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	unlock_btn.pressed.connect(_try_unlock_suitcase)
	content_box.add_child(unlock_btn)

	visible = true


func _change_dial(index: int, delta: int) -> void:
	var next_dials: Array[int] = dial_values.duplicate()
	next_dials[index] = (next_dials[index] + delta + 10) % 10
	dial_values = next_dials
	if index < dial_labels.size():
		dial_labels[index].text = str(dial_values[index])


func _try_unlock_suitcase() -> void:
	if dial_values == [4, 0, 4]:
		GameState.set_flag("suitcase_opened", true)
		GameState.add_item("ticket_right")
		GameState.add_item("brass_key")
		GameState.say("티크", "찰칵! 열렸어! 안에서 [찢어진 승차권 (우)]이랑 [황동 태엽 열쇠]를 찾았어!")
		close_modal()
	else:
		GameState.say("티크", "음, 숫자가 맞지 않는 것 같아. 테이블 위 여행일지의 힌트를 다시 확인해 볼까?")


func open_chapter_clear_view() -> void:
	current_mode = "clear"
	_clear_content()
	title_label.text = "Chapter 1 Clear — 5호차 탈출!"

	var story := Label.new()
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story.add_theme_font_size_override("font_size", 18)
	story.text = "황동 문이 부드럽게 열리며 따뜻한 홍차 향기가 흘러들어온다.\n\n스피커 너머로 부엉이 차장의 목소리가 울린다.\n\"404번 승객님, 첫 번째 문을 통과하셨군요.\n다음 칸은 '끝없는 티타임의 4호차 식당칸'입니다.\"\n\n[ Demo Chapter 1 완료 ]"
	content_box.add_child(story)

	var restart_btn := Button.new()
	restart_btn.text = "5호차 처음부터 다시 플레이"
	restart_btn.custom_minimum_size = Vector2(260, 46)
	restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_btn.pressed.connect(func():
		dial_values = [0, 0, 0]
		GameState.reset_state()
		close_modal()
		GameState.say("나레이션", "눈을 뜨자 별빛이 흐르는 야간열차의 침대칸이다. 시계는 새벽 4시 04분에 멈춰 있다.")
	)
	content_box.add_child(restart_btn)

	visible = true
