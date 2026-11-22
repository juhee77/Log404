class_name AddModal
extends Control

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

signal item_submitted(title: String, category: int, author: String, cover_color: String, quote: String, price: int)

var _palette: Dictionary = UiTokensClass.get_palette("cream")
var _selected_cat: int = 0
var _selected_color: String = UiTokensClass.COVER_COLORS[0]

var _sheet: PanelContainer
var _handle: ColorRect
var _hdr_lbl: Label
var _close_btn: Button
var _cat_book_btn: Button
var _cat_gacha_btn: Button
var _title_input: LineEdit
var _author_input: LineEdit
var _price_input: LineEdit
var _quote_input: LineEdit
var _color_lbl: Label
var _color_row: HBoxContainer
var _submit_btn: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()
	apply_theme(_palette)

func _build_ui() -> void:
	for ch in get_children():
		ch.queue_free()

	var dimmer := ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.07, 0.05, 0.04, 0.48)
	dimmer.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close()
	)
	add_child(dimmer)

	_sheet = PanelContainer.new()
	_sheet.anchor_left = 0.0
	_sheet.anchor_right = 1.0
	_sheet.anchor_top = 0.30
	_sheet.anchor_bottom = 1.0
	add_child(_sheet)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 0)
	_sheet.add_child(root_vbox)

	var handle_center := CenterContainer.new()
	handle_center.custom_minimum_size = Vector2(0, 18)
	_handle = ColorRect.new()
	_handle.custom_minimum_size = Vector2(40, 4)
	handle_center.add_child(_handle)
	root_vbox.add_child(handle_center)

	var hdr_m := MarginContainer.new()
	hdr_m.add_theme_constant_override("margin_left", 20)
	hdr_m.add_theme_constant_override("margin_right", 20)
	hdr_m.add_theme_constant_override("margin_top", 4)
	hdr_m.add_theme_constant_override("margin_bottom", 12)
	root_vbox.add_child(hdr_m)

	var hdr_hbox := HBoxContainer.new()
	hdr_m.add_child(hdr_hbox)

	_hdr_lbl = Label.new()
	_hdr_lbl.text = "새 소장 기록"
	_hdr_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hdr_lbl.add_theme_font_size_override("font_size", 17)
	hdr_hbox.add_child(_hdr_lbl)

	_close_btn = Button.new()
	_close_btn.text = "✕"
	_close_btn.custom_minimum_size = Vector2(32, 32)
	_close_btn.add_theme_font_size_override("font_size", 14)
	_close_btn.pressed.connect(close)
	hdr_hbox.add_child(_close_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	var form_m := MarginContainer.new()
	form_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_m.add_theme_constant_override("margin_left", 20)
	form_m.add_theme_constant_override("margin_right", 20)
	form_m.add_theme_constant_override("margin_top", 4)
	form_m.add_theme_constant_override("margin_bottom", 24)
	scroll.add_child(form_m)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	form_m.add_child(vbox)

	var cat_row := HBoxContainer.new()
	cat_row.add_theme_constant_override("separation", 8)
	vbox.add_child(cat_row)

	_cat_book_btn = Button.new()
	_cat_book_btn.text = "만화·도서"
	_cat_book_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cat_book_btn.custom_minimum_size = Vector2(0, 38)
	_cat_book_btn.add_theme_font_size_override("font_size", 13)
	_cat_book_btn.pressed.connect(func(): _select_cat(0))
	cat_row.add_child(_cat_book_btn)

	_cat_gacha_btn = Button.new()
	_cat_gacha_btn.text = "가챠·굿즈"
	_cat_gacha_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cat_gacha_btn.custom_minimum_size = Vector2(0, 38)
	_cat_gacha_btn.add_theme_font_size_override("font_size", 13)
	_cat_gacha_btn.pressed.connect(func(): _select_cat(1))
	cat_row.add_child(_cat_gacha_btn)

	_title_input = LineEdit.new()
	_title_input.placeholder_text = "작품명 또는 굿즈 이름 *"
	_title_input.custom_minimum_size = Vector2(0, 42)
	_title_input.add_theme_font_size_override("font_size", 13)
	_title_input.text_submitted.connect(func(_t): _author_input.grab_focus())
	vbox.add_child(_title_input)

	var pair_row := HBoxContainer.new()
	pair_row.add_theme_constant_override("separation", 8)
	vbox.add_child(pair_row)

	_author_input = LineEdit.new()
	_author_input.placeholder_text = "작가 / 브랜드"
	_author_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_author_input.custom_minimum_size = Vector2(0, 40)
	_author_input.add_theme_font_size_override("font_size", 13)
	pair_row.add_child(_author_input)

	_price_input = LineEdit.new()
	_price_input.placeholder_text = "가격 (원)"
	_price_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_price_input.custom_minimum_size = Vector2(0, 40)
	_price_input.add_theme_font_size_override("font_size", 13)
	pair_row.add_child(_price_input)

	_quote_input = LineEdit.new()
	_quote_input.placeholder_text = "기억하고 싶은 첫 문장 또는 메모"
	_quote_input.custom_minimum_size = Vector2(0, 40)
	_quote_input.add_theme_font_size_override("font_size", 13)
	_quote_input.text_submitted.connect(func(_t): _on_submit())
	vbox.add_child(_quote_input)

	_color_lbl = Label.new()
	_color_lbl.text = "표지 컬러"
	_color_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_color_lbl)

	_color_row = HBoxContainer.new()
	_color_row.add_theme_constant_override("separation", 10)
	vbox.add_child(_color_row)

	_submit_btn = Button.new()
	_submit_btn.text = "서재에 등록하기"
	_submit_btn.custom_minimum_size = Vector2(0, 44)
	_submit_btn.add_theme_font_size_override("font_size", 14)
	_submit_btn.pressed.connect(_on_submit)
	vbox.add_child(_submit_btn)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	if _sheet == null:
		return
	_sheet.add_theme_stylebox_override("panel", UiTokensClass.make_sheet_box(p["bg"]))
	_handle.color = p["border"]
	_hdr_lbl.add_theme_color_override("font_color", p["ink"])
	UiTokensClass.style_button(_close_btn, p["surface_soft"], p["ink"], 99, Color(0, 0, 0, 0), 0, 0, 0)
	UiTokensClass.style_line_edit(_title_input, p)
	UiTokensClass.style_line_edit(_author_input, p)
	UiTokensClass.style_line_edit(_price_input, p)
	UiTokensClass.style_line_edit(_quote_input, p)
	_color_lbl.add_theme_color_override("font_color", p["ink_sub"])
	UiTokensClass.style_button(_submit_btn, p["accent"], Color.WHITE, 12)
	_select_cat(_selected_cat)
	_render_colors()

func _select_cat(c: int) -> void:
	_selected_cat = c
	UiTokensClass.style_button(
		_cat_book_btn,
		_palette["ink"] if c == 0 else _palette["surface"],
		_palette["bg"] if c == 0 else _palette["ink_sub"],
		12, _palette["ink"] if c == 0 else _palette["border"], 1
	)
	UiTokensClass.style_button(
		_cat_gacha_btn,
		_palette["ink"] if c == 1 else _palette["surface"],
		_palette["bg"] if c == 1 else _palette["ink_sub"],
		12, _palette["ink"] if c == 1 else _palette["border"], 1
	)

func _render_colors() -> void:
	for ch in _color_row.get_children():
		ch.queue_free()
	for hex in UiTokensClass.COVER_COLORS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(34, 34)
		var c_hex: String = str(hex)
		var col := Color.from_string(c_hex, Color("#C82342"))
		var is_sel: bool = (_selected_color.to_lower() == c_hex.to_lower())
		b.text = "✓" if is_sel else ""
		b.add_theme_font_size_override("font_size", 14)
		UiTokensClass.style_button(b, col, Color.WHITE, 99, _palette["ink"] if is_sel else Color(0, 0, 0, 0), 2 if is_sel else 0, 0, 0)
		b.pressed.connect(func():
			_selected_color = c_hex
			_render_colors()
		)
		_color_row.add_child(b)

func open(p: Dictionary = {}) -> void:
	_selected_cat = 0
	_selected_color = UiTokensClass.COVER_COLORS[0]
	_title_input.text = ""
	_title_input.placeholder_text = "작품명 또는 굿즈 이름 *"
	_author_input.text = ""
	_price_input.text = ""
	_quote_input.text = ""
	if not p.is_empty():
		apply_theme(p)
	else:
		_select_cat(0)
		_render_colors()
	visible = true
	_title_input.grab_focus()

func close() -> void:
	visible = false

func _on_submit() -> void:
	var t := _title_input.text.strip_edges()
	if t.is_empty():
		_title_input.placeholder_text = "작품명을 먼저 입력해 주세요"
		_title_input.grab_focus()
		return
	var a := _author_input.text.strip_edges()
	var q := _quote_input.text.strip_edges()
	var p_str := _price_input.text.strip_edges().replace(",", "")
	var price_val: int = maxi(0, int(p_str)) if p_str.is_valid_int() else 0
	item_submitted.emit(t, _selected_cat, a, _selected_color, q, price_val)
	close()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
