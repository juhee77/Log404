class_name MainView
extends Control

const ArchiveStateClass = preload("res://scripts/archive_state.gd")
const CollectionItemClass = preload("res://scripts/collection_item.gd")
const UiTokensClass = preload("res://scripts/ui_tokens.gd")
const CardScene = preload("res://scenes/card_item.tscn")
const DetailModalScene = preload("res://scenes/detail_modal.tscn")
const AddModalScene = preload("res://scenes/add_modal.tscn")

var archive_state = ArchiveStateClass.new()
var _palette: Dictionary = UiTokensClass.get_palette("cream")
var _active_tab: int = 0 # 0: shelf, 1: quotes, 2: settings
var _filter_mode: String = "all" # all, book, gacha, done
var _sort_mode: int = 0 # 0: default, 1: rating, 2: value, 3: title
var _quote_idx: int = 0
var _toast_seq: int = 0

var _bg_rect: ColorRect
var _header_date_lbl: Label
var _app_title_btn: Button
var _add_btn: Button
var _summary_panel: PanelContainer
var _summary_left_lbl: Label
var _summary_right_lbl: Label

var _view_shelf: ScrollContainer
var _quote_card: PanelContainer
var _quote_kicker_lbl: Label
var _quote_open_btn: Button
var _quote_body_lbl: Label
var _quote_meta_lbl: Label
var _search_input: LineEdit
var _sort_option: OptionButton
var _filter_btns: Array[Button] = []
var card_grid: GridContainer

var _view_quotes: ScrollContainer
var _quotes_title_lbl: Label
var _quotes_list: VBoxContainer

var _view_settings: ScrollContainer
var _settings_title_lbl: Label
var _owner_card: PanelContainer
var _owner_input: LineEdit
var _owner_save_btn: Button
var _theme_card: PanelContainer
var _theme_btns: Dictionary = {}
var _backup_card: PanelContainer
var _backup_btn: Button

var _nav_bar: PanelContainer
var _nav_btns: Array[Button] = []
var _toast_panel: PanelContainer
var _toast_lbl: Label

var detail_modal: DetailModal
var add_modal: AddModal

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	archive_state.initialize_defaults()
	_palette = UiTokensClass.get_palette(archive_state.current_theme)
	_build_ui()
	_apply_theme()
	_refresh_all()

func _build_ui() -> void:
	for ch in get_children():
		ch.queue_free()

	_bg_rect = ColorRect.new()
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg_rect)

	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# --- HEADER ---
	var hdr_m := MarginContainer.new()
	hdr_m.add_theme_constant_override("margin_left", 18)
	hdr_m.add_theme_constant_override("margin_right", 18)
	hdr_m.add_theme_constant_override("margin_top", 16)
	hdr_m.add_theme_constant_override("margin_bottom", 10)
	main_vbox.add_child(hdr_m)

	var hdr_vbox := VBoxContainer.new()
	hdr_vbox.add_theme_constant_override("separation", 10)
	hdr_m.add_child(hdr_vbox)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	hdr_vbox.add_child(title_row)

	var title_col := VBoxContainer.new()
	title_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_col.add_theme_constant_override("separation", 2)
	title_row.add_child(title_col)

	_header_date_lbl = Label.new()
	_header_date_lbl.add_theme_font_size_override("font_size", 11)
	title_col.add_child(_header_date_lbl)

	_app_title_btn = Button.new()
	_app_title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_app_title_btn.flat = true
	_app_title_btn.add_theme_font_size_override("font_size", 20)
	_app_title_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_app_title_btn.tooltip_text = "눌러서 서재 이름 변경"
	_app_title_btn.pressed.connect(func():
		_switch_tab(2)
		if _owner_input != null:
			_owner_input.grab_focus()
			_owner_input.select_all()
	)
	title_col.add_child(_app_title_btn)

	_add_btn = Button.new()
	_add_btn.text = "+ 새 기록"
	_add_btn.custom_minimum_size = Vector2(88, 36)
	_add_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_add_btn.add_theme_font_size_override("font_size", 13)
	_add_btn.pressed.connect(func(): add_modal.open(_palette))
	title_row.add_child(_add_btn)

	# Compact 1-Line Summary Strip
	_summary_panel = PanelContainer.new()
	hdr_vbox.add_child(_summary_panel)

	var sum_hbox := HBoxContainer.new()
	sum_hbox.add_theme_constant_override("separation", 8)
	_summary_panel.add_child(sum_hbox)

	_summary_left_lbl = Label.new()
	_summary_left_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary_left_lbl.add_theme_font_size_override("font_size", 12)
	sum_hbox.add_child(_summary_left_lbl)

	_summary_right_lbl = Label.new()
	_summary_right_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_summary_right_lbl.add_theme_font_size_override("font_size", 13)
	sum_hbox.add_child(_summary_right_lbl)

	# --- CONTENT STACK ---
	var content_wrap := Control.new()
	content_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content_wrap)

	# 1. SHELF VIEW
	_view_shelf = ScrollContainer.new()
	_view_shelf.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_shelf.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_wrap.add_child(_view_shelf)

	var shelf_m := MarginContainer.new()
	shelf_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_m.add_theme_constant_override("margin_left", 18)
	shelf_m.add_theme_constant_override("margin_right", 18)
	shelf_m.add_theme_constant_override("margin_top", 2)
	shelf_m.add_theme_constant_override("margin_bottom", 20)
	_view_shelf.add_child(shelf_m)

	var shelf_vbox := VBoxContainer.new()
	shelf_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_vbox.add_theme_constant_override("separation", 12)
	shelf_m.add_child(shelf_vbox)

	# Dedicated Quote Card
	_quote_card = PanelContainer.new()
	_quote_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_quote_card.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_quote_idx += 1
			_render_quote_card()
	)
	shelf_vbox.add_child(_quote_card)

	var q_vbox := VBoxContainer.new()
	q_vbox.add_theme_constant_override("separation", 6)
	q_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_quote_card.add_child(q_vbox)

	var q_top := HBoxContainer.new()
	q_vbox.add_child(q_top)

	_quote_kicker_lbl = Label.new()
	_quote_kicker_lbl.text = "오늘의 밑줄"
	_quote_kicker_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quote_kicker_lbl.add_theme_font_size_override("font_size", 11)
	_quote_kicker_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	q_top.add_child(_quote_kicker_lbl)

	_quote_open_btn = Button.new()
	_quote_open_btn.text = "원문 보기 →"
	_quote_open_btn.add_theme_font_size_override("font_size", 11)
	_quote_open_btn.pressed.connect(_open_current_quote_source)
	q_top.add_child(_quote_open_btn)

	_quote_body_lbl = Label.new()
	_quote_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quote_body_lbl.add_theme_font_size_override("font_size", 14)
	_quote_body_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	q_vbox.add_child(_quote_body_lbl)

	_quote_meta_lbl = Label.new()
	_quote_meta_lbl.add_theme_font_size_override("font_size", 12)
	_quote_meta_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_quote_meta_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	q_vbox.add_child(_quote_meta_lbl)

	# Search & Sort Row
	var search_row := HBoxContainer.new()
	search_row.add_theme_constant_override("separation", 8)
	shelf_vbox.add_child(search_row)

	_search_input = LineEdit.new()
	_search_input.placeholder_text = "작품명, 작가, 밑줄 검색"
	_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_input.custom_minimum_size = Vector2(0, 38)
	_search_input.clear_button_enabled = true
	_search_input.add_theme_font_size_override("font_size", 13)
	_search_input.text_changed.connect(func(_t): _render_cards())
	search_row.add_child(_search_input)

	_sort_option = OptionButton.new()
	_sort_option.custom_minimum_size = Vector2(92, 38)
	_sort_option.add_theme_font_size_override("font_size", 12)
	_sort_option.add_item("기본순", 0)
	_sort_option.add_item("별점순", 1)
	_sort_option.add_item("가치순", 2)
	_sort_option.add_item("이름순", 3)
	_sort_option.item_selected.connect(func(idx: int):
		_sort_mode = idx
		_render_cards()
	)
	search_row.add_child(_sort_option)

	# Clean 4 Filter Pills
	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	shelf_vbox.add_child(filter_row)

	_filter_btns.clear()
	var filters := [
		["all", "전체"],
		["book", "만화·도서"],
		["gacha", "가챠·굿즈"],
		["done", "완독"]
	]
	for f in filters:
		var fb := Button.new()
		fb.text = f[1]
		fb.set_meta("filter_id", f[0])
		fb.add_theme_font_size_override("font_size", 12)
		var fid: String = f[0]
		fb.pressed.connect(func():
			_filter_mode = fid
			_style_filter_pills()
			_render_cards()
		)
		filter_row.add_child(fb)
		_filter_btns.append(fb)

	# 2-Column Editorial Card Grid
	card_grid = GridContainer.new()
	card_grid.columns = 2
	card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_grid.add_theme_constant_override("h_separation", 12)
	card_grid.add_theme_constant_override("v_separation", 14)
	shelf_vbox.add_child(card_grid)

	# 2. QUOTES ARCHIVE VIEW
	_view_quotes = ScrollContainer.new()
	_view_quotes.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_quotes.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_view_quotes.visible = false
	content_wrap.add_child(_view_quotes)

	var qm := MarginContainer.new()
	qm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qm.add_theme_constant_override("margin_left", 18)
	qm.add_theme_constant_override("margin_right", 18)
	qm.add_theme_constant_override("margin_top", 4)
	qm.add_theme_constant_override("margin_bottom", 20)
	_view_quotes.add_child(qm)

	var qlist_vbox := VBoxContainer.new()
	qlist_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qlist_vbox.add_theme_constant_override("separation", 12)
	qm.add_child(qlist_vbox)

	_quotes_title_lbl = Label.new()
	_quotes_title_lbl.text = "밑줄 아카이브"
	_quotes_title_lbl.add_theme_font_size_override("font_size", 16)
	qlist_vbox.add_child(_quotes_title_lbl)

	_quotes_list = VBoxContainer.new()
	_quotes_list.add_theme_constant_override("separation", 10)
	qlist_vbox.add_child(_quotes_list)

	# 3. SETTINGS & THEME VIEW
	_view_settings = ScrollContainer.new()
	_view_settings.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_settings.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_view_settings.visible = false
	content_wrap.add_child(_view_settings)

	var sm := MarginContainer.new()
	sm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sm.add_theme_constant_override("margin_left", 18)
	sm.add_theme_constant_override("margin_right", 18)
	sm.add_theme_constant_override("margin_top", 4)
	sm.add_theme_constant_override("margin_bottom", 20)
	_view_settings.add_child(sm)

	var set_vbox := VBoxContainer.new()
	set_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	set_vbox.add_theme_constant_override("separation", 14)
	sm.add_child(set_vbox)

	_settings_title_lbl = Label.new()
	_settings_title_lbl.text = "서재 설정 & 테마"
	_settings_title_lbl.add_theme_font_size_override("font_size", 16)
	set_vbox.add_child(_settings_title_lbl)

	# Owner Name Card
	_owner_card = PanelContainer.new()
	set_vbox.add_child(_owner_card)
	var owner_vbox := VBoxContainer.new()
	owner_vbox.add_theme_constant_override("separation", 8)
	_owner_card.add_child(owner_vbox)

	var owner_hdr := Label.new()
	owner_hdr.text = "서재 이름 설정"
	owner_hdr.add_theme_font_size_override("font_size", 13)
	owner_vbox.add_child(owner_hdr)

	var owner_desc := Label.new()
	owner_desc.text = "이름을 입력하면 'OOO의 서재'로 표시됩니다. 비워두면 '나의 서재'가 됩니다."
	owner_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	owner_desc.add_theme_font_size_override("font_size", 12)
	owner_vbox.add_child(owner_desc)

	var owner_row := HBoxContainer.new()
	owner_row.add_theme_constant_override("separation", 8)
	owner_vbox.add_child(owner_row)

	_owner_input = LineEdit.new()
	_owner_input.placeholder_text = "이름 입력 (예: 주희, 민수)"
	_owner_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_owner_input.custom_minimum_size = Vector2(0, 38)
	_owner_input.add_theme_font_size_override("font_size", 13)
	_owner_input.text_submitted.connect(func(_t): _on_save_owner_name())
	owner_row.add_child(_owner_input)

	_owner_save_btn = Button.new()
	_owner_save_btn.text = "적용"
	_owner_save_btn.custom_minimum_size = Vector2(68, 38)
	_owner_save_btn.add_theme_font_size_override("font_size", 13)
	_owner_save_btn.pressed.connect(_on_save_owner_name)
	owner_row.add_child(_owner_save_btn)

	# Theme Picker Card
	_theme_card = PanelContainer.new()
	set_vbox.add_child(_theme_card)
	var th_vbox := VBoxContainer.new()
	th_vbox.add_theme_constant_override("separation", 10)
	_theme_card.add_child(th_vbox)

	var th_hdr := Label.new()
	th_hdr.text = "종이 테마 선택"
	th_hdr.add_theme_font_size_override("font_size", 13)
	th_vbox.add_child(th_hdr)

	var th_row := HBoxContainer.new()
	th_row.add_theme_constant_override("separation", 8)
	th_vbox.add_child(th_row)

	_theme_btns.clear()
	for tid in ["cream", "sepia", "dark"]:
		var tp: Dictionary = UiTokensClass.get_palette(tid)
		var tb := Button.new()
		tb.text = tp["name"]
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.custom_minimum_size = Vector2(0, 44)
		tb.add_theme_font_size_override("font_size", 12)
		var capture_tid: String = tid
		tb.pressed.connect(func(): _on_select_theme(capture_tid))
		th_row.add_child(tb)
		_theme_btns[tid] = tb

	# Backup Card
	_backup_card = PanelContainer.new()
	set_vbox.add_child(_backup_card)
	var bk_vbox := VBoxContainer.new()
	bk_vbox.add_theme_constant_override("separation", 8)
	_backup_card.add_child(bk_vbox)

	var bk_hdr := Label.new()
	bk_hdr.text = "서재 데이터 백업"
	bk_hdr.add_theme_font_size_override("font_size", 13)
	bk_vbox.add_child(bk_hdr)

	var bk_desc := Label.new()
	bk_desc.text = "현재 기록된 모든 작품과 권별 밑줄을 JSON 형식으로 클립보드에 복사합니다."
	bk_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bk_desc.add_theme_font_size_override("font_size", 12)
	bk_vbox.add_child(bk_desc)

	_backup_btn = Button.new()
	_backup_btn.text = "JSON 백업 복사하기"
	_backup_btn.custom_minimum_size = Vector2(0, 40)
	_backup_btn.add_theme_font_size_override("font_size", 13)
	_backup_btn.pressed.connect(func():
		DisplayServer.clipboard_set(archive_state.to_backup_json())
		_show_toast("서재 JSON 백업을 클립보드에 복사했어요")
	)
	bk_vbox.add_child(_backup_btn)

	# --- BOTTOM 3-TAB NAVIGATION BAR ---
	_nav_bar = PanelContainer.new()
	main_vbox.add_child(_nav_bar)

	var nav_hbox := HBoxContainer.new()
	nav_hbox.add_theme_constant_override("separation", 4)
	_nav_bar.add_child(nav_hbox)

	_nav_btns.clear()
	var nav_defs := ["📚 서재", "🖋️ 밑줄 노트", "🎨 테마·설정"]
	for i in range(nav_defs.size()):
		var nb := Button.new()
		nb.text = nav_defs[i]
		nb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nb.custom_minimum_size = Vector2(0, 48)
		nb.add_theme_font_size_override("font_size", 13)
		var idx := i
		nb.pressed.connect(func(): _switch_tab(idx))
		nav_hbox.add_child(nb)
		_nav_btns.append(nb)

	# --- FLOATING EPHEMERAL TOAST ---
	_toast_panel = PanelContainer.new()
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.anchor_left = 0.5
	_toast_panel.anchor_right = 0.5
	_toast_panel.anchor_top = 1.0
	_toast_panel.anchor_bottom = 1.0
	_toast_panel.offset_left = -150
	_toast_panel.offset_right = 150
	_toast_panel.offset_top = -104
	_toast_panel.offset_bottom = -68
	add_child(_toast_panel)

	_toast_lbl = Label.new()
	_toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast_lbl.add_theme_font_size_override("font_size", 12)
	_toast_panel.add_child(_toast_lbl)

	# --- MODALS ---
	detail_modal = DetailModalScene.instantiate()
	detail_modal.diary_updated.connect(_on_diary_updated)
	detail_modal.item_deleted.connect(_on_item_deleted)
	detail_modal.toast_requested.connect(_show_toast)
	add_child(detail_modal)

	add_modal = AddModalScene.instantiate()
	add_modal.item_submitted.connect(_on_item_submitted)
	add_child(add_modal)

func _apply_theme() -> void:
	var p := _palette
	_bg_rect.color = p["bg"]
	_header_date_lbl.add_theme_color_override("font_color", p["ink_muted"])
	_app_title_btn.add_theme_color_override("font_color", p["ink"])
	_app_title_btn.add_theme_color_override("font_hover_color", p["accent"])
	_app_title_btn.add_theme_color_override("font_pressed_color", p["accent"])
	UiTokensClass.style_button(_add_btn, p["ink"], p["bg"], 99, Color(0, 0, 0, 0), 0, 14, 6)

	_summary_panel.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], 14, p["border"], 1, 14, 10))
	_summary_left_lbl.add_theme_color_override("font_color", p["ink_sub"])
	_summary_right_lbl.add_theme_color_override("font_color", p["ink"])

	_quote_card.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], 16, p["border"], 1, 16, 14, p["shadow"], 6))
	_quote_kicker_lbl.add_theme_color_override("font_color", p["accent"])
	UiTokensClass.style_button(_quote_open_btn, p["surface_soft"], p["ink_sub"], 99, Color(0, 0, 0, 0), 0, 10, 3)
	_quote_body_lbl.add_theme_color_override("font_color", p["ink"])
	_quote_meta_lbl.add_theme_color_override("font_color", p["ink_sub"])

	UiTokensClass.style_line_edit(_search_input, p)
	UiTokensClass.style_button(_sort_option, p["surface"], p["ink"], 12, p["border"], 1, 10, 6)

	_style_filter_pills()

	_quotes_title_lbl.add_theme_color_override("font_color", p["ink"])
	_settings_title_lbl.add_theme_color_override("font_color", p["ink"])
	for card in [_owner_card, _theme_card, _backup_card]:
		card.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], 16, p["border"], 1, 16, 14))
		for lbl in card.find_children("*", "Label", true, false):
			lbl.add_theme_color_override("font_color", p["ink"] if lbl.get_theme_font_size("font_size") >= 13 else p["ink_sub"])
	UiTokensClass.style_line_edit(_owner_input, p, p["bg"])
	UiTokensClass.style_button(_owner_save_btn, p["ink"], p["bg"], 12)
	UiTokensClass.style_button(_backup_btn, p["surface_soft"], p["ink"], 12)

	for tid in _theme_btns.keys():
		var tp: Dictionary = UiTokensClass.get_palette(tid)
		var is_sel: bool = (archive_state.current_theme == tid)
		UiTokensClass.style_button(_theme_btns[tid], tp["bg"], tp["ink"], 12, p["accent"] if is_sel else tp["border"], 2 if is_sel else 1, 8, 8)

	var nav_sb := StyleBoxFlat.new()
	nav_sb.bg_color = p["surface"]
	nav_sb.border_width_top = 1
	nav_sb.border_color = p["border"]
	nav_sb.content_margin_left = 10
	nav_sb.content_margin_right = 10
	nav_sb.content_margin_top = 4
	nav_sb.content_margin_bottom = 6
	_nav_bar.add_theme_stylebox_override("panel", nav_sb)
	_style_nav_tabs()

	_toast_panel.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["ink"], 99, Color(0, 0, 0, 0), 0, 16, 8, Color(0, 0, 0, 0.25), 8))
	_toast_lbl.add_theme_color_override("font_color", p["bg"])

	if detail_modal != null:
		detail_modal.apply_theme(p)
	if add_modal != null:
		add_modal.apply_theme(p)

func _style_filter_pills() -> void:
	for fb in _filter_btns:
		var act: bool = (str(fb.get_meta("filter_id", "")) == _filter_mode)
		UiTokensClass.style_button(
			fb,
			_palette["ink"] if act else _palette["surface"],
			_palette["bg"] if act else _palette["ink_sub"],
			99, _palette["ink"] if act else _palette["border"], 1, 14, 6
		)

func _style_nav_tabs() -> void:
	for i in range(_nav_btns.size()):
		var act := (i == _active_tab)
		UiTokensClass.style_button(
			_nav_btns[i],
			Color(0, 0, 0, 0),
			_palette["accent"] if act else _palette["ink_muted"],
			10, Color(0, 0, 0, 0), 0, 4, 4
		)

func _switch_tab(idx: int) -> void:
	_active_tab = idx
	_view_shelf.visible = (idx == 0)
	_view_quotes.visible = (idx == 1)
	_view_settings.visible = (idx == 2)
	_style_nav_tabs()
	if idx == 1:
		_render_quotes_archive()
	elif idx == 2:
		_owner_input.text = archive_state.owner_name

func _refresh_all() -> void:
	var dt := Time.get_date_dict_from_system()
	_header_date_lbl.text = "%04d. %02d. %02d · POCKET ARCHIVE" % [int(dt.get("year", 2026)), int(dt.get("month", 11)), int(dt.get("day", 23))]
	_app_title_btn.text = archive_state.get_library_title()
	_owner_input.text = archive_state.owner_name

	var total_items: int = archive_state.items.size()
	var total_vols: int = archive_state.get_total_volumes()
	var prog: int = int(round(_get_overall_progress()))
	var total_val: int = archive_state.get_total_collection_value()
	_summary_left_lbl.text = "%d 작품  |  %d 권  |  완독 %d%%" % [total_items, total_vols, prog]
	_summary_right_lbl.text = ArchiveStateClass.format_krw(total_val)

	_render_quote_card()
	_render_cards()
	if _active_tab == 1:
		_render_quotes_archive()

func _get_overall_progress() -> float:
	if archive_state.items.is_empty():
		return 0.0
	var s := 0.0
	for it in archive_state.items:
		if it.status_tag == "전권완결" or it.status_tag == "완독" or it.category == 1:
			s += 100.0
		elif it.target_volumes > 0:
			s += clampf(float(it.volumes.size()) / float(it.target_volumes) * 100.0, 10.0, 100.0)
		else:
			s += clampf(float(it.volumes.size()) * 25.0, 20.0, 100.0)
	return s / float(archive_state.items.size())

func _get_all_quotes() -> Array:
	var out: Array = []
	for it in archive_state.items:
		for v in it.volumes:
			var q := str(v.get("quote", "")).strip_edges()
			if not q.is_empty():
				out.append({"item": it, "vol": int(v.get("vol", 1)), "quote": q})
	return out

func _render_quote_card() -> void:
	var quotes := _get_all_quotes()
	if quotes.is_empty():
		_quote_body_lbl.text = "\"첫 번째 밑줄 문장을 기록해 보세요.\""
		_quote_meta_lbl.text = archive_state.get_library_title()
		return
	var entry: Dictionary = quotes[_quote_idx % quotes.size()]
	var it = entry["item"]
	_quote_body_lbl.text = "\"%s\"" % entry["quote"]
	var author_str: String = it.author_or_series if it.author_or_series != "" else "작가 미상"
	_quote_meta_lbl.text = "%s %d권 · %s" % [it.title, entry["vol"], author_str]

func _open_current_quote_source() -> void:
	var quotes := _get_all_quotes()
	if quotes.is_empty():
		return
	var entry: Dictionary = quotes[_quote_idx % quotes.size()]
	detail_modal.open(entry["item"], _palette)

func _render_cards() -> void:
	for ch in card_grid.get_children():
		ch.queue_free()

	var q := _search_input.text.strip_edges().to_lower()
	var list: Array = []
	for it in archive_state.items:
		if _filter_mode == "book" and it.category != 0:
			continue
		if _filter_mode == "gacha" and it.category != 1:
			continue
		if _filter_mode == "done" and not (it.status_tag == "전권완결" or it.status_tag == "완독"):
			continue
		if not q.is_empty():
			var hay := ("%s %s %s" % [it.title, it.author_or_series, it.memo]).to_lower()
			var matched := hay.find(q) != -1
			if not matched:
				for v in it.volumes:
					if str(v.get("quote", "")).to_lower().find(q) != -1:
						matched = true
						break
			if not matched:
				continue
		list.append(it)

	if _sort_mode == 1:
		list.sort_custom(func(a, b): return a.get_average_rating() > b.get_average_rating())
	elif _sort_mode == 2:
		list.sort_custom(func(a, b): return a.get_item_value() > b.get_item_value())
	elif _sort_mode == 3:
		list.sort_custom(func(a, b): return a.title.naturalnocasecmp_to(b.title) < 0)

	if list.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "조건에 맞는 작품이 없습니다."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", _palette["ink_muted"])
		card_grid.add_child(empty_lbl)
		return

	for it in list:
		var card: CardItem = CardScene.instantiate()
		card.setup(it, _palette)
		card.card_clicked.connect(func(clicked_item): detail_modal.open(clicked_item, _palette))
		card_grid.add_child(card)

func _render_quotes_archive() -> void:
	for ch in _quotes_list.get_children():
		ch.queue_free()
	var quotes := _get_all_quotes()
	for entry in quotes:
		var it = entry["item"]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiTokensClass.make_box(_palette["surface"], 16, _palette["border"], 1, 16, 14))
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				detail_modal.open(it, _palette)
		)
		_quotes_list.add_child(card)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 6)
		vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(vb)

		var ql := Label.new()
		ql.text = "\"%s\"" % entry["quote"]
		ql.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ql.add_theme_font_size_override("font_size", 14)
		ql.add_theme_color_override("font_color", _palette["ink"])
		ql.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(ql)

		var meta := Label.new()
		var author_str: String = it.author_or_series if it.author_or_series != "" else "작가 미상"
		meta.text = "%s · %d권  (%s)" % [it.title, entry["vol"], author_str]
		meta.add_theme_font_size_override("font_size", 12)
		meta.add_theme_color_override("font_color", _palette["ink_sub"])
		meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(meta)

func _on_save_owner_name() -> void:
	archive_state.owner_name = _owner_input.text.strip_edges()
	archive_state.save_to_file()
	_refresh_all()
	_show_toast("서재 이름을 '%s'(으)로 변경했어요" % archive_state.get_library_title())

func _on_select_theme(tid: String) -> void:
	archive_state.current_theme = tid
	archive_state.save_to_file()
	_palette = UiTokensClass.get_palette(tid)
	_apply_theme()
	_render_cards()
	_show_toast("'%s' 테마를 적용했어요" % _palette["name"])

func _on_item_submitted(p_title: String, p_cat: int, p_author: String, p_color: String, p_quote: String, p_price: int) -> void:
	var new_id := "item_%d" % Time.get_unix_time_from_system()
	var item = CollectionItemClass.new(new_id, p_cat, p_title, p_author if p_author != "" else "작가 미상", "소장중", p_color, "", "")
	item.memo = p_quote if p_quote != "" else "새롭게 추가한 소장 기록"
	if p_price > 0:
		item.estimated_value = p_price
	item.add_volume(1, "owned", 5, p_quote)
	archive_state.items.insert(0, item)
	archive_state.save_to_file()
	_refresh_all()
	_show_toast("「%s」 기록을 추가했어요" % p_title)

func _on_diary_updated(_item) -> void:
	archive_state.save_to_file()
	_refresh_all()

func _on_item_deleted(item) -> void:
	archive_state.remove_item(item)
	archive_state.save_to_file()
	_refresh_all()
	_show_toast("작품 기록을 삭제했어요")

func _show_toast(msg: String) -> void:
	_toast_lbl.text = msg
	_toast_panel.visible = true
	_toast_seq += 1
	var my_seq := _toast_seq
	if is_inside_tree():
		get_tree().create_timer(2.0).timeout.connect(func():
			if is_instance_valid(_toast_panel) and _toast_seq == my_seq:
				_toast_panel.visible = false
		)
