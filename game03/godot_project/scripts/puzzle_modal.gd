extends Control

signal modal_closed

var panel: PanelContainer
var title_label: Label
var content_box: VBoxContainer
var close_button: Button

var dial_values: Array[int] = [0, 0, 0]
var dial_labels: Array[Label] = []
var current_mode: String = ""


func _ready() -> void:
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_base_ui()


func _build_base_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.04, 0.06, 0.12, 0.78)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 380)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1F1826")
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

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

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

	var art := Label.new()
	art.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art.add_theme_font_size_override("font_size", 28)
	art.add_theme_color_override("font_color", Color("#FEF08A"))
	art.text = "✦       ★\n      ╱   │\n    ★ ── ★ ── ★\n          │\n          ★"
	content_box.add_child(art)

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

	var clock_lbl := Label.new()
	clock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_lbl.add_theme_font_size_override("font_size", 36)
	clock_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
	clock_lbl.text = "🕰️  04 : 04"
	content_box.add_child(clock_lbl)

	var note_panel := PanelContainer.new()
	var nstyle := StyleBoxFlat.new()
	nstyle.bg_color = Color("#FDF6E3")
	nstyle.set_corner_radius_all(8)
	nstyle.set_content_margin_all(16)
	note_panel.add_theme_stylebox_override("panel", nstyle)
	content_box.add_child(note_panel)

	var note_lbl := Label.new()
	note_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_lbl.add_theme_font_size_override("font_size", 17)
	note_lbl.add_theme_color_override("font_color", Color("#3B2322"))
	note_lbl.text = "[ 낡은 여행일지의 메모 ]\n\n\"가방의 비밀을 잊었을 때를 위해 적어둔다.\n  첫째는 창밖의 별이 그린 숫자,\n  둘째는 김을 닦아낸 거울 속 보름달,\n  셋째는 멈춰버린 시계의 분침이 가리키는 수.\""
	note_panel.add_child(note_lbl)

	visible = true


func open_mirror_view() -> void:
	current_mode = "mirror"
	_clear_content()
	title_label.text = "황동 프레임 거울"

	var wiped := GameState.has_flag("mirror_wiped")
	var mirror_box := PanelContainer.new()
	mirror_box.custom_minimum_size = Vector2(260, 170)
	mirror_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var mstyle := StyleBoxFlat.new()
	mstyle.bg_color = Color("#334155") if wiped else Color("#94A3B8")
	mstyle.border_color = Color("#D4AF37")
	mstyle.set_border_width_all(4)
	mstyle.set_corner_radius_all(10)
	mirror_box.add_theme_stylebox_override("panel", mstyle)
	content_box.add_child(mirror_box)

	var symbol := Label.new()
	symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	symbol.add_theme_font_size_override("font_size", 64 if wiped else 22)
	symbol.add_theme_color_override("font_color", Color("#FDE68A") if wiped else Color("#E2E8F0"))
	symbol.text = "0" if wiped else "(뿌옇게 김이 서려 있다)"
	mirror_box.add_child(symbol)

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
	info.text = "3자리 황동 다이얼 자물쇠가 단단히 잠겨 있다."
	content_box.add_child(info)

	var dial_row := HBoxContainer.new()
	dial_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dial_row.add_theme_constant_override("separation", 28)
	content_box.add_child(dial_row)

	for idx in range(3):
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", 8)
		dial_row.add_child(col)

		var up_btn := Button.new()
		up_btn.text = "▲"
		up_btn.custom_minimum_size = Vector2(68, 36)
		up_btn.pressed.connect(_change_dial.bind(idx, 1))
		col.add_child(up_btn)

		var num_lbl := Label.new()
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.add_theme_font_size_override("font_size", 36)
		num_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
		num_lbl.text = str(dial_values[idx])
		col.add_child(num_lbl)
		dial_labels.append(num_lbl)

		var down_btn := Button.new()
		down_btn.text = "▼"
		down_btn.custom_minimum_size = Vector2(68, 36)
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
