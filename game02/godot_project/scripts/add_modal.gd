class_name AddModal
extends Control

signal item_submitted(title: String, category: int, author: String, color_hex: String, quote_text: String)
signal help_requested(copy_to_clipboard: bool)

@onready var title_input: LineEdit = $Panel/VBox/BodyMargin/Body/TitleInput
@onready var author_input: LineEdit = $Panel/VBox/BodyMargin/Body/AuthorInput
@onready var quote_input: LineEdit = $Panel/VBox/BodyMargin/Body/QuoteInput
@onready var cat_option: OptionButton = $Panel/VBox/BodyMargin/Body/CatOption
@onready var color_row: HBoxContainer = $Panel/VBox/BodyMargin/Body/ColorRow
@onready var submit_btn: Button = $Panel/VBox/BodyMargin/Body/SubmitBtn
@onready var close_btn: Button = $Panel/VBox/Header/HBox/CloseBtn

const COVER_SWATCHES = [
	{"name": "크림슨", "hex": "#b91c1c"},
	{"name": "코발트", "hex": "#1d4ed8"},
	{"name": "테라코타", "hex": "#c2410c"},
	{"name": "로즈", "hex": "#be185d"},
	{"name": "포레스트", "hex": "#15803d"},
	{"name": "바이올렛", "hex": "#6d28d9"}
]

var selected_color: String = "#b91c1c"

func _ready() -> void:
	visible = false
	cat_option.clear()
	cat_option.add_item("📖 이북 · 만화 단행본 일기", 0)
	cat_option.add_item("🔮 가챠 · 굿즈 스크랩 노트", 1)
	_build_color_swatches()
	_style_inputs()
	title_input.text_submitted.connect(func(_t): author_input.grab_focus())
	author_input.text_submitted.connect(func(_t): _on_submit_btn_pressed())
	quote_input.text_submitted.connect(func(_t): _on_submit_btn_pressed())
	var input_samples := [
		[title_input, "나의 비밀 독서 일기"],
		[author_input, "주희의 서재"],
		[quote_input, "오늘도 한 페이지의 여운을 남겼다."]
	]
	for pair in input_samples:
		var fld: LineEdit = pair[0]
		var smp: String = pair[1]
		if fld != null:
			fld.tooltip_text = "우클릭: 입력 비우기 / 샘플 채움 · Shift+좌클릭: 샘플 채움"
			fld.gui_input.connect(func(ev: InputEvent) -> void:
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_RIGHT:
						fld.text = "" if fld.text != "" else smp
					elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
						fld.accept_event()
						fld.text = smp
			)
	var dimmer: Control = get_node_or_null("Dimmer")
	if dimmer != null:
		dimmer.tooltip_text = "좌클릭: 일기 작성 창 닫기 · 우클릭·Shift+좌클릭: 입력 내용만 비우기"
		dimmer.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					dimmer.accept_event()
					clear_inputs()
				elif ev.button_index == MOUSE_BUTTON_LEFT:
					close()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					clear_inputs()
		)
	var header_title: Label = get_node_or_null("Panel/VBox/Header/HBox/TitleLabel")
	if header_title != null:
		header_title.mouse_filter = Control.MOUSE_FILTER_STOP
		header_title.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		header_title.tooltip_text = "좌클릭: 샘플 일기 일괄 채움 · 우클릭: 입력 전체 비우기 · Shift+좌클릭: 샘플 즉시 등록"
		header_title.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					header_title.accept_event()
					_submit_with_sample_fallback()
				elif ev.button_index == MOUSE_BUTTON_LEFT:
					title_input.text = "나의 비밀 독서 일기"
					author_input.text = "주희의 서재"
					quote_input.text = "오늘도 한 페이지의 여운을 남겼다."
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					clear_inputs()
		)

func _build_color_swatches() -> void:
	for child in color_row.get_children():
		child.queue_free()
	for sw in COVER_SWATCHES:
		var btn = Button.new()
		btn.text = sw["name"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 9)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.from_string(sw["hex"], Color(0.7, 0.2, 0.2))
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		var hex_val = sw["hex"]
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.tooltip_text = "좌클릭: '%s' 표지색 선택 · 우클릭: 이 색으로 즉시 등록 · Shift+좌클릭: 이 색으로 즉시 등록" % sw["name"]
		btn.pressed.connect(func(): select_color(hex_val))
		btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					select_color(hex_val)
					_submit_with_sample_fallback()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					btn.accept_event()
					select_color(hex_val)
					_submit_with_sample_fallback()
		)
		color_row.add_child(btn)
	_highlight_selected_swatch()

func _style_inputs() -> void:
	var inp_sb = StyleBoxFlat.new()
	inp_sb.bg_color = Color(0.98, 0.96, 0.92, 1)
	inp_sb.border_width_bottom = 2
	inp_sb.border_color = Color(0.80, 0.72, 0.62, 1)
	inp_sb.content_margin_left = 8
	for le in [title_input, author_input, quote_input]:
		le.clear_button_enabled = true
		le.add_theme_stylebox_override("normal", inp_sb)
		le.add_theme_color_override("font_color", Color(0.18, 0.14, 0.11))
		le.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.42))
	for ctrl in [submit_btn, close_btn, cat_option]:
		if ctrl != null:
			ctrl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if cat_option != null:
		cat_option.tooltip_text = "작품 분류 선택 (우클릭·Shift+좌클릭: 이북 ↔ 가챠 즉시 전환)"
		cat_option.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					cat_option.select(1 if cat_option.selected == 0 else 0)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					cat_option.accept_event()
					cat_option.select(1 if cat_option.selected == 0 else 0)
		)

	var ink_sb = StyleBoxFlat.new()
	ink_sb.bg_color = Color(0.22, 0.16, 0.13, 1)
	ink_sb.corner_radius_top_left = 8
	ink_sb.corner_radius_top_right = 8
	ink_sb.corner_radius_bottom_left = 8
	ink_sb.corner_radius_bottom_right = 8
	submit_btn.add_theme_stylebox_override("normal", ink_sb)
	submit_btn.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))

	var cream_btn = StyleBoxFlat.new()
	cream_btn.bg_color = Color(0.95, 0.91, 0.84, 1)
	cream_btn.corner_radius_top_left = 6
	cream_btn.corner_radius_top_right = 6
	cream_btn.corner_radius_bottom_left = 6
	cream_btn.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("normal", cream_btn)
	close_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
	close_btn.tooltip_text = "닫기 (ESC · 우클릭: 입력란 모두 비우기 · Shift+좌클릭: 입력란 모두 비우기)"
	close_btn.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			if ev.button_index == MOUSE_BUTTON_RIGHT:
				clear_inputs()
			elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
				close_btn.accept_event()
				clear_inputs()
	)
	submit_btn.tooltip_text = "서재에 등록 (Enter · 우클릭: 빈 제목 시 샘플 자동 채움 등록 · Shift+좌클릭: 샘플 자동 채움 등록)"
	submit_btn.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			if ev.button_index == MOUSE_BUTTON_RIGHT:
				_submit_with_sample_fallback()
			elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
				submit_btn.accept_event()
				_submit_with_sample_fallback()
	)

func _submit_with_sample_fallback() -> void:
	if title_input.text.strip_edges() == "":
		title_input.text = "오늘의 독서 스크랩"
		if author_input.text.strip_edges() == "":
			author_input.text = "주희의 다꾸 서재"
		if quote_input.text.strip_edges() == "":
			quote_input.text = "소중한 한 권의 기억을 담다."
	_on_submit_btn_pressed()

func fill_sample_inputs() -> void:
	if title_input != null and title_input.text.strip_edges() == "":
		title_input.text = "오늘의 독서 스크랩"
	if author_input != null and author_input.text.strip_edges() == "":
		author_input.text = "주희의 다꾸 서재"
	if quote_input != null and quote_input.text.strip_edges() == "":
		quote_input.text = "소중한 한 권의 기억을 담다."

func _step_color(delta: int) -> void:
	if COVER_SWATCHES.is_empty():
		return
	var cur_idx: int = 0
	for i in range(COVER_SWATCHES.size()):
		if COVER_SWATCHES[i]["hex"].to_lower() == selected_color.to_lower():
			cur_idx = i
			break
	var next_idx: int = (cur_idx + delta + COVER_SWATCHES.size()) % COVER_SWATCHES.size()
	select_color(COVER_SWATCHES[next_idx]["hex"])

func clear_inputs() -> void:
	title_input.text = ""
	author_input.text = ""
	quote_input.text = ""
	title_input.grab_focus()

func select_color(hex_code: String) -> void:
	selected_color = hex_code
	_highlight_selected_swatch()

func _highlight_selected_swatch() -> void:
	if color_row == null:
		return
	var children = color_row.get_children()
	for i in range(min(children.size(), COVER_SWATCHES.size())):
		var btn = children[i]
		if not (btn is Button):
			continue
		var sw = COVER_SWATCHES[i]
		var is_sel = (selected_color.to_lower() == sw["hex"].to_lower())
		btn.text = ("✓ " + sw["name"]) if is_sel else sw["name"]
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.from_string(sw["hex"], Color(0.7, 0.2, 0.2))
		sb.border_width_left = 2 if is_sel else 0
		sb.border_width_top = 2 if is_sel else 0
		sb.border_width_right = 2 if is_sel else 0
		sb.border_width_bottom = 2 if is_sel else 0
		sb.border_color = Color(0.99, 0.96, 0.88, 1)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)

func open() -> void:
	title_input.text = ""
	title_input.placeholder_text = "작품·굿즈 제목 (예: 슬램덩크 신장재편판)"
	author_input.text = ""
	quote_input.text = ""
	cat_option.selected = 0
	selected_color = "#b91c1c"
	_highlight_selected_swatch()
	visible = true
	title_input.grab_focus()

func close() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F1:
		help_requested.emit(event.shift_pressed)
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
		_on_submit_btn_pressed()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_S:
		if event.shift_pressed:
			_submit_with_sample_fallback()
		else:
			_on_submit_btn_pressed()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_R and not COVER_SWATCHES.is_empty():
		var next_r_idx: int = randi() % COVER_SWATCHES.size()
		if COVER_SWATCHES.size() > 1 and COVER_SWATCHES[next_r_idx]["hex"].to_lower() == selected_color.to_lower():
			next_r_idx = (next_r_idx + 1) % COVER_SWATCHES.size()
		select_color(COVER_SWATCHES[next_r_idx]["hex"])
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_L:
		clear_inputs()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_I:
		fill_sample_inputs()
		if event.shift_pressed:
			_submit_with_sample_fallback()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_G and cat_option != null:
		cat_option.select(1)
		if event.shift_pressed:
			_submit_with_sample_fallback()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_E and cat_option != null:
		cat_option.select(0)
		if event.shift_pressed:
			_submit_with_sample_fallback()
		get_viewport().set_input_as_handled()
		return
	if (event.ctrl_pressed or event.meta_pressed) and event.keycode == KEY_W:
		if event.shift_pressed:
			clear_inputs()
		close()
		get_viewport().set_input_as_handled()
		return
	if event.shift_pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
		_submit_with_sample_fallback()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE:
		if event.shift_pressed:
			clear_inputs()
			get_viewport().set_input_as_handled()
			return
		for le in [title_input, author_input, quote_input]:
			if le != null and le.has_focus() and le.text != "":
				le.text = ""
				get_viewport().set_input_as_handled()
				return
		close()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_TAB:
		var fields := [title_input, author_input, quote_input]
		var f_idx: int = -1
		for i in range(fields.size()):
			if fields[i] != null and fields[i].has_focus():
				f_idx = i
				break
		if event.shift_pressed:
			if f_idx > 0 and fields[f_idx - 1] != null:
				fields[f_idx - 1].grab_focus()
			elif f_idx == 0 and fields[0] != null:
				fields[0].release_focus()
			elif fields[fields.size() - 1] != null:
				fields[fields.size() - 1].grab_focus()
		else:
			if f_idx == -1 and fields[0] != null:
				fields[0].grab_focus()
			elif f_idx >= 0 and f_idx < fields.size() - 1 and fields[f_idx + 1] != null:
				fields[f_idx + 1].grab_focus()
			elif f_idx == fields.size() - 1 and fields[f_idx] != null:
				fields[f_idx].release_focus()
		get_viewport().set_input_as_handled()
		return
	var any_focused: bool = false
	for le in [title_input, author_input, quote_input]:
		if le != null and le.has_focus():
			any_focused = true
			break
	if not any_focused:
		if event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]:
			var sw_idx: int = event.keycode - KEY_1
			if sw_idx >= 0 and sw_idx < COVER_SWATCHES.size():
				select_color(COVER_SWATCHES[sw_idx]["hex"])
				if event.shift_pressed:
					_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_7, KEY_8] and cat_option != null:
			cat_option.select(0 if event.keycode == KEY_7 else 1)
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_9:
			fill_sample_inputs()
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C and cat_option != null:
			cat_option.select(1 if cat_option.selected == 0 else 0)
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_F:
			fill_sample_inputs()
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_X:
			clear_inputs()
			if event.shift_pressed:
				close()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_LEFT:
			_step_color(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT:
			_step_color(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_S:
			if event.shift_pressed:
				_submit_with_sample_fallback()
			else:
				_on_submit_btn_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E and cat_option != null:
			cat_option.select(0)
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_G and cat_option != null:
			cat_option.select(1)
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_T and title_input != null:
			if event.shift_pressed:
				title_input.text = ""
			title_input.grab_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_A and author_input != null:
			if event.shift_pressed:
				author_input.text = ""
			author_input.grab_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_Q and quote_input != null:
			if event.shift_pressed:
				quote_input.text = ""
			quote_input.grab_focus()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			_step_color(-1 if event.shift_pressed else 1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R and not COVER_SWATCHES.is_empty():
			var next_r_idx: int = randi() % COVER_SWATCHES.size()
			if COVER_SWATCHES.size() > 1 and COVER_SWATCHES[next_r_idx]["hex"].to_lower() == selected_color.to_lower():
				next_r_idx = (next_r_idx + 1) % COVER_SWATCHES.size()
			select_color(COVER_SWATCHES[next_r_idx]["hex"])
			if event.shift_pressed:
				_submit_with_sample_fallback()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_0:
			clear_inputs()
			if cat_option != null:
				cat_option.select(0)
			if not COVER_SWATCHES.is_empty():
				select_color(COVER_SWATCHES[0]["hex"])
			if event.shift_pressed:
				close()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_HOME and not COVER_SWATCHES.is_empty():
			select_color(COVER_SWATCHES[0]["hex"])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_END and not COVER_SWATCHES.is_empty():
			select_color(COVER_SWATCHES[COVER_SWATCHES.size() - 1]["hex"])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_BACKSPACE:
			clear_inputs()
			if event.shift_pressed:
				close()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_submit_btn_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_H or (event.keycode == KEY_SLASH and event.shift_pressed):
			help_requested.emit(event.shift_pressed and event.keycode == KEY_H)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SLASH and not event.shift_pressed and title_input != null:
			title_input.grab_focus()
			title_input.select_all()
			get_viewport().set_input_as_handled()

func _on_close_btn_pressed() -> void:
	close()

func _on_submit_btn_pressed() -> void:
	var t = title_input.text.strip_edges()
	if t.is_empty():
		title_input.placeholder_text = "⚠️ 작품 제목을 먼저 입력해주세요!"
		title_input.grab_focus()
		return
	var cat = cat_option.selected
	var a = author_input.text.strip_edges()
	var q = quote_input.text.strip_edges()
	item_submitted.emit(t, cat, a, selected_color, q)
	close()
