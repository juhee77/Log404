class_name MainView
extends Control

const ArchiveStateClass = preload("res://scripts/archive_state.gd")
const CollectionItemClass = preload("res://scripts/collection_item.gd")
const UiTokensClass = preload("res://scripts/ui_tokens.gd")
const DsButtonClass = preload("res://scripts/ui/ds_button.gd")
const DsCardClass = preload("res://scripts/ui/ds_card.gd")
const DsBadgeClass = preload("res://scripts/ui/ds_badge.gd")
const DsInputClass = preload("res://scripts/ui/ds_input.gd")
const SettingsPageClass = preload("res://scripts/settings_page.gd")
const CardScene = preload("res://scenes/card_item.tscn")
const DetailModalScene = preload("res://scenes/detail_modal.tscn")
const AddModalScene = preload("res://scenes/add_modal.tscn")

var archive_state = ArchiveStateClass.new()
var _palette: Dictionary = UiTokensClass.get_palette("millie")
var _active_tab: int = 0 # 0: shelf, 1: showcase, 2: notes, 3: stats
var _filter_mode: String = "all" # all, book, gacha, done
var _sort_mode: int = 0 # 0: default, 1: rating, 2: value, 3: title
var _quote_idx: int = 0
var _showcase_led: bool = true
var _toast_seq: int = 0

var _bg_rect: ColorRect
var _dot_panel: PanelContainer
var _app_title_btn: Button
var _search_wrap: MarginContainer
var _search_input: LineEdit

var _tab_bar_panel: PanelContainer
var _top_tab_btns: Array = []

var _view_shelf: ScrollContainer
var _quote_body_lbl: Label
var _quote_meta_lbl: Label
var _filter_btns: Array = []
var _shelf_count_lbl: Label
var _col_toggle_btn
var _sort_option: OptionButton
var _shelf_rows_box: VBoxContainer

var _view_showcase: ScrollContainer
var _showcase_title_lbl: Label
var _showcase_count_lbl: Label
var _led_btn
var _cabinet_panel: PanelContainer
var _led_bar: PanelContainer
var _tiers_box: VBoxContainer

var _view_notes: ScrollContainer
var _notes_count_lbl: Label
var _notes_list: VBoxContainer

var _view_stats: ScrollContainer
var _stats_hero
var _st_val_lbl: Label
var _st_items_lbl: Label
var _st_vols_lbl: Label
var _st_rate_lbl: Label
var _stats_cat_card
var _st_cat_box: VBoxContainer

var _toast_panel: PanelContainer
var _toast_lbl: Label

var settings_page: Control
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

	# --- TOP HEADER (Millie Style) ---
	var hdr_m := MarginContainer.new()
	hdr_m.add_theme_constant_override("margin_left", 20)
	hdr_m.add_theme_constant_override("margin_right", 16)
	hdr_m.add_theme_constant_override("margin_top", 16)
	hdr_m.add_theme_constant_override("margin_bottom", 8)
	main_vbox.add_child(hdr_m)

	var hdr_hbox := HBoxContainer.new()
	hdr_hbox.add_theme_constant_override("separation", 6)
	hdr_m.add_child(hdr_hbox)

	var left_hbox := HBoxContainer.new()
	left_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_hbox.add_theme_constant_override("separation", 8)
	hdr_hbox.add_child(left_hbox)

	_dot_panel = PanelContainer.new()
	_dot_panel.custom_minimum_size = Vector2(10, 10)
	_dot_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left_hbox.add_child(_dot_panel)

	_app_title_btn = Button.new()
	_app_title_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_app_title_btn.flat = true
	_app_title_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_app_title_btn.add_theme_font_size_override("font_size", 20)
	_app_title_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_app_title_btn.pressed.connect(_open_settings)
	left_hbox.add_child(_app_title_btn)

	var search_btn = DsButtonClass.create("🔍", DsButtonClass.Variant.ICON, DsButtonClass.Size.MD, _toggle_search)
	search_btn.add_theme_font_size_override("font_size", 15)
	hdr_hbox.add_child(search_btn)

	var theme_btn = DsButtonClass.create("🎨", DsButtonClass.Variant.ICON, DsButtonClass.Size.MD, _cycle_theme_quick)
	theme_btn.add_theme_font_size_override("font_size", 15)
	hdr_hbox.add_child(theme_btn)

	var settings_btn = DsButtonClass.create("⚙️", DsButtonClass.Variant.ICON, DsButtonClass.Size.MD, _open_settings)
	settings_btn.add_theme_font_size_override("font_size", 15)
	hdr_hbox.add_child(settings_btn)

	# Expandable Search Bar
	_search_wrap = MarginContainer.new()
	_search_wrap.visible = false
	_search_wrap.add_theme_constant_override("margin_left", 20)
	_search_wrap.add_theme_constant_override("margin_right", 20)
	_search_wrap.add_theme_constant_override("margin_bottom", 8)
	main_vbox.add_child(_search_wrap)

	_search_input = DsInputClass.create("작품명, 작가, 밑줄 문장 검색", DsInputClass.Variant.FILLED, 38)
	_search_input.clear_button_enabled = true
	_search_input.text_changed.connect(func(_t): _render_shelf())
	_search_wrap.add_child(_search_input)

	# --- TOP UNDERLINE TABS ---
	_tab_bar_panel = PanelContainer.new()
	main_vbox.add_child(_tab_bar_panel)

	var tab_hbox := HBoxContainer.new()
	tab_hbox.add_theme_constant_override("separation", 18)
	_tab_bar_panel.add_child(tab_hbox)

	_top_tab_btns.clear()
	var tab_labels := ["책장", "전시대", "독서 노트", "통계"]
	for i in range(tab_labels.size()):
		var idx := i
		var tb = DsButtonClass.create(tab_labels[i], DsButtonClass.Variant.TAB, DsButtonClass.Size.MD, func(): _switch_tab(idx))
		tb.is_selected = (i == 0)
		tab_hbox.add_child(tb)
		_top_tab_btns.append(tb)

	# --- CONTENT STACK ---
	var content_wrap := Control.new()
	content_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content_wrap)

	# 1. SHELF TAB
	_view_shelf = ScrollContainer.new()
	_view_shelf.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_shelf.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_wrap.add_child(_view_shelf)

	var shelf_m := MarginContainer.new()
	shelf_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_m.add_theme_constant_override("margin_left", 20)
	shelf_m.add_theme_constant_override("margin_right", 20)
	shelf_m.add_theme_constant_override("margin_top", 14)
	shelf_m.add_theme_constant_override("margin_bottom", 86)
	_view_shelf.add_child(shelf_m)

	var shelf_vbox := VBoxContainer.new()
	shelf_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelf_vbox.add_theme_constant_override("separation", 12)
	shelf_m.add_child(shelf_vbox)

	# Millie Quote Card
	var quote_card = DsCardClass.create(DsCardClass.Variant.SUBTLE, 16, 14, 16)
	quote_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quote_card.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_quote_idx += 1
			_render_quote_card()
	)
	shelf_vbox.add_child(quote_card)

	var q_vbox := VBoxContainer.new()
	q_vbox.add_theme_constant_override("separation", 6)
	q_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quote_card.add_child(q_vbox)

	var q_top := HBoxContainer.new()
	q_vbox.add_child(q_top)

	var q_badge = DsBadgeClass.create("오늘의 밑줄", DsBadgeClass.Variant.MILLIE, 11)
	q_top.add_child(q_badge)

	var q_sp := Control.new()
	q_sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	q_sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	q_top.add_child(q_sp)

	var q_open_btn = DsButtonClass.create("원문 보기 ›", DsButtonClass.Variant.GHOST, DsButtonClass.Size.SM, _open_current_quote_source)
	q_top.add_child(q_open_btn)

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

	# Filter Chips Row
	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	shelf_vbox.add_child(filter_row)

	_filter_btns.clear()
	for f in [["all", "전체"], ["book", "만화·도서"], ["gacha", "가챠·굿즈"], ["done", "완독"]]:
		var fid: String = f[0]
		var fb = DsButtonClass.create(f[1], DsButtonClass.Variant.CHIP, DsButtonClass.Size.SM, func():
			_filter_mode = fid
			for btn in _filter_btns:
				btn.set_selected(str(btn.get_meta("filter_id", "")) == _filter_mode)
			_render_shelf()
		)
		fb.set_meta("filter_id", fid)
		fb.is_selected = (fid == "all")
		filter_row.add_child(fb)
		_filter_btns.append(fb)

	# Shelf Controls Row
	var ctrl_row := HBoxContainer.new()
	ctrl_row.add_theme_constant_override("separation", 8)
	shelf_vbox.add_child(ctrl_row)

	_shelf_count_lbl = Label.new()
	_shelf_count_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelf_count_lbl.add_theme_font_size_override("font_size", 12)
	ctrl_row.add_child(_shelf_count_lbl)

	_col_toggle_btn = DsButtonClass.create("3열 보기", DsButtonClass.Variant.SECONDARY, DsButtonClass.Size.SM, _toggle_shelf_columns)
	ctrl_row.add_child(_col_toggle_btn)

	_sort_option = OptionButton.new()
	_sort_option.add_theme_font_size_override("font_size", 12)
	_sort_option.add_item("등록순", 0)
	_sort_option.add_item("별점순", 1)
	_sort_option.add_item("가치순", 2)
	_sort_option.add_item("가나다순", 3)
	_sort_option.item_selected.connect(func(idx: int):
		_sort_mode = idx
		_render_shelf()
	)
	ctrl_row.add_child(_sort_option)

	_shelf_rows_box = VBoxContainer.new()
	_shelf_rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shelf_rows_box.add_theme_constant_override("separation", 18)
	shelf_vbox.add_child(_shelf_rows_box)

	# 2. SHOWCASE TAB
	_view_showcase = ScrollContainer.new()
	_view_showcase.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_showcase.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_view_showcase.visible = false
	content_wrap.add_child(_view_showcase)

	var sc_m := MarginContainer.new()
	sc_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc_m.add_theme_constant_override("margin_left", 20)
	sc_m.add_theme_constant_override("margin_right", 20)
	sc_m.add_theme_constant_override("margin_top", 14)
	sc_m.add_theme_constant_override("margin_bottom", 86)
	_view_showcase.add_child(sc_m)

	var sc_vbox := VBoxContainer.new()
	sc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc_vbox.add_theme_constant_override("separation", 14)
	sc_m.add_child(sc_vbox)

	var sc_hdr := HBoxContainer.new()
	sc_vbox.add_child(sc_hdr)

	var sc_left := VBoxContainer.new()
	sc_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc_left.add_theme_constant_override("separation", 2)
	sc_hdr.add_child(sc_left)

	_showcase_title_lbl = Label.new()
	_showcase_title_lbl.text = "피규어 전시대"
	_showcase_title_lbl.add_theme_font_size_override("font_size", 15)
	sc_left.add_child(_showcase_title_lbl)

	_showcase_count_lbl = Label.new()
	_showcase_count_lbl.add_theme_font_size_override("font_size", 12)
	sc_left.add_child(_showcase_count_lbl)

	_led_btn = DsButtonClass.create("💡 조명 ON", DsButtonClass.Variant.ACCENT, DsButtonClass.Size.SM, _toggle_showcase_led)
	_led_btn.custom_minimum_size = Vector2(88, 32)
	_led_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sc_hdr.add_child(_led_btn)

	_cabinet_panel = PanelContainer.new()
	sc_vbox.add_child(_cabinet_panel)

	var cab_vbox := VBoxContainer.new()
	cab_vbox.add_theme_constant_override("separation", 14)
	_cabinet_panel.add_child(cab_vbox)

	var led_center := CenterContainer.new()
	_led_bar = PanelContainer.new()
	_led_bar.custom_minimum_size = Vector2(220, 6)
	led_center.add_child(_led_bar)
	cab_vbox.add_child(led_center)

	_tiers_box = VBoxContainer.new()
	_tiers_box.add_theme_constant_override("separation", 16)
	cab_vbox.add_child(_tiers_box)

	# 3. NOTES TAB
	_view_notes = ScrollContainer.new()
	_view_notes.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_notes.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_view_notes.visible = false
	content_wrap.add_child(_view_notes)

	var nm := MarginContainer.new()
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.add_theme_constant_override("margin_left", 20)
	nm.add_theme_constant_override("margin_right", 20)
	nm.add_theme_constant_override("margin_top", 14)
	nm.add_theme_constant_override("margin_bottom", 86)
	_view_notes.add_child(nm)

	var n_vbox := VBoxContainer.new()
	n_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n_vbox.add_theme_constant_override("separation", 12)
	nm.add_child(n_vbox)

	_notes_count_lbl = Label.new()
	_notes_count_lbl.add_theme_font_size_override("font_size", 13)
	n_vbox.add_child(_notes_count_lbl)

	_notes_list = VBoxContainer.new()
	_notes_list.add_theme_constant_override("separation", 10)
	n_vbox.add_child(_notes_list)

	# 4. STATS TAB
	_view_stats = ScrollContainer.new()
	_view_stats.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_stats.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_view_stats.visible = false
	content_wrap.add_child(_view_stats)

	var stm := MarginContainer.new()
	stm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stm.add_theme_constant_override("margin_left", 20)
	stm.add_theme_constant_override("margin_right", 20)
	stm.add_theme_constant_override("margin_top", 14)
	stm.add_theme_constant_override("margin_bottom", 86)
	_view_stats.add_child(stm)

	var st_vbox := VBoxContainer.new()
	st_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	st_vbox.add_theme_constant_override("separation", 14)
	stm.add_child(st_vbox)

	_stats_hero = DsCardClass.create(DsCardClass.Variant.SUBTLE, 18, 16, 18)
	st_vbox.add_child(_stats_hero)
	var hero_v := VBoxContainer.new()
	hero_v.add_theme_constant_override("separation", 12)
	_stats_hero.add_child(hero_v)

	var hero_sub := Label.new()
	hero_sub.text = "내 서재 총 소장 가치"
	hero_sub.add_theme_font_size_override("font_size", 12)
	hero_v.add_child(hero_sub)

	_st_val_lbl = Label.new()
	_st_val_lbl.add_theme_font_size_override("font_size", 26)
	hero_v.add_child(_st_val_lbl)

	var kpi_row := HBoxContainer.new()
	kpi_row.add_theme_constant_override("separation", 10)
	hero_v.add_child(kpi_row)

	_st_items_lbl = _make_kpi_col(kpi_row, "전체 작품")
	_st_vols_lbl = _make_kpi_col(kpi_row, "기록 권수")
	_st_rate_lbl = _make_kpi_col(kpi_row, "평균 완독률")

	_stats_cat_card = DsCardClass.create(DsCardClass.Variant.SUBTLE, 18, 16, 18)
	st_vbox.add_child(_stats_cat_card)
	var cat_v := VBoxContainer.new()
	cat_v.add_theme_constant_override("separation", 12)
	_stats_cat_card.add_child(cat_v)

	var cat_hdr := Label.new()
	cat_hdr.text = "카테고리 구성"
	cat_hdr.add_theme_font_size_override("font_size", 14)
	cat_v.add_child(cat_hdr)

	_st_cat_box = VBoxContainer.new()
	_st_cat_box.add_theme_constant_override("separation", 10)
	cat_v.add_child(_st_cat_box)

	# --- FLOATING ADD FAB ---
	var fab_btn = DsButtonClass.create("+ 기록 추가", DsButtonClass.Variant.PRIMARY, DsButtonClass.Size.FAB, func(): add_modal.open(_palette))
	fab_btn.anchor_left = 1.0
	fab_btn.anchor_right = 1.0
	fab_btn.anchor_top = 1.0
	fab_btn.anchor_bottom = 1.0
	fab_btn.offset_left = -132
	fab_btn.offset_right = -20
	fab_btn.offset_top = -68
	fab_btn.offset_bottom = -20
	add_child(fab_btn)

	# --- FLOATING TOAST ---
	_toast_panel = PanelContainer.new()
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.anchor_left = 0.5
	_toast_panel.anchor_right = 0.5
	_toast_panel.anchor_top = 1.0
	_toast_panel.anchor_bottom = 1.0
	_toast_panel.offset_left = -150
	_toast_panel.offset_right = 150
	_toast_panel.offset_top = -112
	_toast_panel.offset_bottom = -76
	add_child(_toast_panel)

	_toast_lbl = Label.new()
	_toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast_lbl.add_theme_font_size_override("font_size", 12)
	_toast_panel.add_child(_toast_lbl)

	# --- FULL-SCREEN SETTINGS PAGE ---
	settings_page = SettingsPageClass.new()
	settings_page.owner_name_saved.connect(_on_save_owner_name)
	settings_page.theme_selected.connect(_on_select_theme)
	settings_page.showcase_style_selected.connect(_on_select_showcase_style)
	settings_page.shelf_columns_toggled.connect(_toggle_shelf_columns)
	settings_page.backup_requested.connect(_on_backup_requested)
	add_child(settings_page)

	# --- MODALS ---
	detail_modal = DetailModalScene.instantiate()
	detail_modal.diary_updated.connect(_on_diary_updated)
	detail_modal.item_deleted.connect(_on_item_deleted)
	detail_modal.toast_requested.connect(_show_toast)
	add_child(detail_modal)

	add_modal = AddModalScene.instantiate()
	add_modal.item_submitted.connect(_on_item_submitted)
	add_child(add_modal)

func _make_kpi_col(parent: HBoxContainer, title: String) -> Label:
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 3)
	parent.add_child(vb)
	var tl := Label.new()
	tl.text = title
	tl.add_theme_font_size_override("font_size", 11)
	vb.add_child(tl)
	var vl := Label.new()
	vl.add_theme_font_size_override("font_size", 17)
	vb.add_child(vl)
	return vl

func _apply_theme() -> void:
	var p := _palette
	_bg_rect.color = p["bg"]
	_dot_panel.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["millie"], 99, Color(0, 0, 0, 0.1), 1, 0, 0))
	_app_title_btn.add_theme_color_override("font_color", p["ink"])
	_app_title_btn.add_theme_color_override("font_hover_color", p["ink_sub"])
	_app_title_btn.add_theme_color_override("font_pressed_color", p["ink_sub"])

	var tb_sb := StyleBoxFlat.new()
	tb_sb.bg_color = p["bg"]
	tb_sb.border_width_bottom = 1
	tb_sb.border_color = p["border"]
	tb_sb.content_margin_left = 20
	tb_sb.content_margin_right = 20
	_tab_bar_panel.add_theme_stylebox_override("panel", tb_sb)

	_quote_body_lbl.add_theme_color_override("font_color", p["ink"])
	_quote_meta_lbl.add_theme_color_override("font_color", p["ink_sub"])
	_shelf_count_lbl.add_theme_color_override("font_color", p["ink_sub"])
	UiTokensClass.style_button(_sort_option, Color(0, 0, 0, 0), p["ink"], 8, Color(0, 0, 0, 0), 0, 6, 4)

	_showcase_title_lbl.add_theme_color_override("font_color", p["ink"])
	_showcase_count_lbl.add_theme_color_override("font_color", p["ink_sub"])
	_notes_count_lbl.add_theme_color_override("font_color", p["ink_sub"])

	for sc in [_stats_hero, _stats_cat_card]:
		for lbl in sc.find_children("*", "Label", true, false):
			lbl.add_theme_color_override("font_color", p["ink"] if lbl.get_theme_font_size("font_size") >= 14 else p["ink_sub"])
	_st_rate_lbl.add_theme_color_override("font_color", p["sage"])

	_toast_panel.add_theme_stylebox_override("panel", UiTokensClass.make_box(p["ink"], 99, Color(0, 0, 0, 0), 0, 16, 8, Color(0, 0, 0, 0.25), 8))
	_toast_lbl.add_theme_color_override("font_color", p["bg"])

	# Single-call Design System re-theming across all DsButton, DsCard, DsBadge, DsInput, DsSegmented!
	UiTokensClass.theme_ds_tree(self, p)

	if settings_page != null:
		settings_page.apply_theme(p, archive_state.current_theme, archive_state.showcase_style, archive_state.shelf_columns)
	if detail_modal != null:
		detail_modal.apply_theme(p)
	if add_modal != null:
		add_modal.apply_theme(p)

func _switch_tab(idx: int) -> void:
	_active_tab = idx
	_view_shelf.visible = (idx == 0)
	_view_showcase.visible = (idx == 1)
	_view_notes.visible = (idx == 2)
	_view_stats.visible = (idx == 3)
	for i in range(_top_tab_btns.size()):
		_top_tab_btns[i].set_selected(i == idx)
	if idx == 1:
		_render_showcase()
	elif idx == 2:
		_render_notes()
	elif idx == 3:
		_render_stats()

func _toggle_search() -> void:
	_search_wrap.visible = not _search_wrap.visible
	if _search_wrap.visible:
		_search_input.grab_focus()
	else:
		_search_input.text = ""
		_render_shelf()

func _cycle_theme_quick() -> void:
	var order := ["millie", "paper", "dark"]
	var cur := order.find(archive_state.current_theme)
	_on_select_theme(order[(cur + 1) % order.size()])

func _open_settings() -> void:
	settings_page.open(archive_state.owner_name, _palette, archive_state.current_theme, archive_state.showcase_style, archive_state.shelf_columns)

func _toggle_shelf_columns() -> void:
	archive_state.shelf_columns = 2 if archive_state.shelf_columns == 3 else 3
	archive_state.save_to_file()
	_col_toggle_btn.text = "3열 보기" if archive_state.shelf_columns == 3 else "2열 보기"
	settings_page.apply_theme(_palette, archive_state.current_theme, archive_state.showcase_style, archive_state.shelf_columns)
	_render_shelf()

func _toggle_showcase_led() -> void:
	_showcase_led = not _showcase_led
	_led_btn.text = "💡 조명 ON" if _showcase_led else "조명 OFF"
	_led_btn.variant = DsButtonClass.Variant.ACCENT if _showcase_led else DsButtonClass.Variant.SECONDARY
	_led_btn.apply_theme(_palette)
	_render_showcase()

func _refresh_all() -> void:
	_app_title_btn.text = archive_state.get_library_title()
	_col_toggle_btn.text = "3열 보기" if archive_state.shelf_columns == 3 else "2열 보기"
	_render_quote_card()
	_render_shelf()
	_render_showcase()
	if _active_tab == 2:
		_render_notes()
	elif _active_tab == 3:
		_render_stats()

func _get_item_progress(it) -> int:
	if it.status_tag == "전권완결" or it.status_tag == "완독" or it.category == 1:
		return 100
	if it.target_volumes > 0:
		return clampi(int(round(float(it.volumes.size()) / float(it.target_volumes) * 100.0)), 10, 100)
	return clampi(it.volumes.size() * 25, 20, 100)

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
	detail_modal.open(quotes[_quote_idx % quotes.size()]["item"], _palette)

func _render_shelf() -> void:
	for ch in _shelf_rows_box.get_children():
		ch.queue_free()

	var q := _search_input.text.strip_edges().to_lower()
	var list: Array = []
	for it in archive_state.items:
		if _filter_mode == "book" and it.category != 0:
			continue
		if _filter_mode == "gacha" and it.category != 1:
			continue
		if _filter_mode == "done" and _get_item_progress(it) < 100:
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

	var total_val: int = 0
	for it in list:
		total_val += it.get_item_value()
	_shelf_count_lbl.text = "총 %d작품 · %s" % [list.size(), ArchiveStateClass.format_krw(total_val)]

	if list.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "조건에 맞는 작품이 없습니다."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", _palette["ink_muted"])
		_shelf_rows_box.add_child(empty_lbl)
		return

	var cols: int = archive_state.shelf_columns
	for start_i in range(0, list.size(), cols):
		var row_wrap := VBoxContainer.new()
		row_wrap.add_theme_constant_override("separation", 10)
		_shelf_rows_box.add_child(row_wrap)

		var row_grid := HBoxContainer.new()
		row_grid.add_theme_constant_override("separation", 14 if cols == 2 else 12)
		row_wrap.add_child(row_grid)

		for offset in range(cols):
			var idx := start_i + offset
			if idx < list.size():
				var card: CardItem = CardScene.instantiate()
				card.setup(list[idx], _palette, cols)
				card.card_clicked.connect(func(clicked_it): detail_modal.open(clicked_it, _palette))
				row_grid.add_child(card)
			else:
				var filler := Control.new()
				filler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row_grid.add_child(filler)

		var ledge := PanelContainer.new()
		ledge.custom_minimum_size = Vector2(0, 6)
		ledge.add_theme_stylebox_override("panel", UiTokensClass.make_box(_palette["surface_soft"], 4, Color(0, 0, 0, 0), 0, 0, 0, _palette["shadow"], 6))
		row_wrap.add_child(ledge)

func _render_showcase() -> void:
	var cs: Dictionary = UiTokensClass.get_showcase_style(archive_state.showcase_style)
	_cabinet_panel.add_theme_stylebox_override("panel", UiTokensClass.make_box(cs["bg"], 22, cs["border"], 2, 14, 14))
	_led_bar.visible = _showcase_led
	_led_bar.add_theme_stylebox_override("panel", UiTokensClass.make_box(Color("#FFF7C2"), 99, Color(0, 0, 0, 0), 0, 0, 0, Color(1.0, 0.93, 0.55, 0.72), 14))

	for ch in _tiers_box.get_children():
		ch.queue_free()

	var gachas: Array = []
	var total_val: int = 0
	for it in archive_state.items:
		if it.category == 1:
			gachas.append(it)
			total_val += it.get_item_value()

	_showcase_count_lbl.text = "진열 중 %d개 · %s" % [gachas.size(), ArchiveStateClass.format_krw(total_val)]

	if gachas.is_empty():
		var emp := Label.new()
		emp.text = "전시할 가챠·피규어를 '+ 기록 추가'로 등록해 보세요."
		emp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		emp.add_theme_font_size_override("font_size", 13)
		emp.add_theme_color_override("font_color", cs["sub_ink"])
		_tiers_box.add_child(emp)
		return

	for start_i in range(0, gachas.size(), 2):
		var tier_wrap := VBoxContainer.new()
		tier_wrap.add_theme_constant_override("separation", 10)
		_tiers_box.add_child(tier_wrap)

		var pair_row := HBoxContainer.new()
		pair_row.add_theme_constant_override("separation", 12)
		tier_wrap.add_child(pair_row)

		for off in range(2):
			var idx := start_i + off
			if idx >= gachas.size():
				var f := Control.new()
				f.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				pair_row.add_child(f)
				continue

			var it = gachas[idx]
			var slot := VBoxContainer.new()
			slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot.alignment = BoxContainer.ALIGNMENT_CENTER
			slot.add_theme_constant_override("separation", 4)
			slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			slot.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
					detail_modal.open(it, _palette)
			)
			pair_row.add_child(slot)

			var dome_center := CenterContainer.new()
			dome_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(dome_center)

			var dome := PanelContainer.new()
			dome.custom_minimum_size = Vector2(118, 124)
			dome.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
			dome.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var base_col := Color.from_string(it.cover_color, Color("#DB2777"))
			dome.add_theme_stylebox_override("panel", UiTokensClass.make_dome_box(base_col, Color(1, 1, 1, 0.65)))
			dome_center.add_child(dome)

			var dome_layer := Control.new()
			dome_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dome.add_child(dome_layer)

			var tex := UiTokensClass.load_cover_texture(str(it.cover_path))
			if tex != null:
				var tr := TextureRect.new()
				tr.set_anchors_preset(Control.PRESET_FULL_RECT)
				tr.texture = tex
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
				dome_layer.add_child(tr)
			else:
				var dl := Label.new()
				dl.set_anchors_preset(Control.PRESET_FULL_RECT)
				dl.offset_left = 10
				dl.offset_right = -10
				dl.text = it.title
				dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				dl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				dl.add_theme_font_size_override("font_size", 12)
				dl.add_theme_color_override("font_color", Color.WHITE)
				dl.mouse_filter = Control.MOUSE_FILTER_IGNORE
				dome_layer.add_child(dl)

			var ped_c := CenterContainer.new()
			ped_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(ped_c)
			var ped := PanelContainer.new()
			ped.custom_minimum_size = Vector2(100, 10)
			ped.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ped.add_theme_stylebox_override("panel", UiTokensClass.make_box(cs["pedestal"], 99, Color(1, 1, 1, 0.5), 1, 0, 0))
			ped_c.add_child(ped)

			var plaque := Label.new()
			plaque.text = it.title
			plaque.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			plaque.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			plaque.add_theme_font_size_override("font_size", 11)
			plaque.add_theme_color_override("font_color", cs["plaque_ink"])
			plaque.add_theme_stylebox_override("normal", UiTokensClass.make_box(cs["plaque_bg"], 6, Color(0, 0, 0, 0.06), 1, 8, 3))
			plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(plaque)

			var sub := Label.new()
			var loc_s: String = it.storage_location if it.storage_location != "" else "전시 중"
			sub.text = "%s · %s" % [loc_s, ArchiveStateClass.format_krw(it.get_item_value())]
			sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			sub.add_theme_font_size_override("font_size", 10)
			sub.add_theme_color_override("font_color", cs["sub_ink"])
			sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(sub)

		var glass := PanelContainer.new()
		glass.custom_minimum_size = Vector2(0, 9)
		glass.add_theme_stylebox_override("panel", UiTokensClass.make_box(cs["shelf"], 99, Color(1, 1, 1, 0.45), 1, 0, 0, Color(0, 0, 0, 0.14), 6))
		tier_wrap.add_child(glass)

func _render_notes() -> void:
	for ch in _notes_list.get_children():
		ch.queue_free()
	var quotes := _get_all_quotes()
	_notes_count_lbl.text = "저장된 밑줄 %d개" % quotes.size()
	for entry in quotes:
		var it = entry["item"]
		var card = DsCardClass.create(DsCardClass.Variant.SUBTLE, 16, 14, 16)
		card.apply_theme(_palette)
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				detail_modal.open(it, _palette)
		)
		_notes_list.add_child(card)

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
		meta.text = "%s %d권 · %s" % [it.title, entry["vol"], author_str]
		meta.add_theme_font_size_override("font_size", 12)
		meta.add_theme_color_override("font_color", _palette["ink_sub"])
		meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_child(meta)

func _render_stats() -> void:
	var total_val: int = archive_state.get_total_collection_value()
	var total_items: int = archive_state.items.size()
	var total_vols: int = archive_state.get_total_volumes()
	var sum_p: int = 0
	var books_cnt: int = 0
	var gachas_cnt: int = 0
	for it in archive_state.items:
		sum_p += _get_item_progress(it)
		if it.category == 0:
			books_cnt += 1
		else:
			gachas_cnt += 1
	var avg_rate: int = int(round(float(sum_p) / float(maxi(1, total_items))))

	_st_val_lbl.text = ArchiveStateClass.format_krw(total_val)
	_st_items_lbl.text = "%d종" % total_items
	_st_vols_lbl.text = "%d권" % total_vols
	_st_rate_lbl.text = "%d%%" % avg_rate

	for ch in _st_cat_box.get_children():
		ch.queue_free()

	var bp: int = int(round(float(books_cnt) / float(maxi(1, total_items)) * 100.0))
	var gp: int = 100 - bp
	_add_stat_bar("만화·도서 (%d종)" % books_cnt, bp, _palette["ink"])
	_add_stat_bar("가챠·굿즈 (%d종)" % gachas_cnt, gp, _palette["millie"])

func _add_stat_bar(label_txt: String, pct: int, fill_col: Color) -> void:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 5)
	_st_cat_box.add_child(vb)

	var top := HBoxContainer.new()
	vb.add_child(top)
	var l1 := Label.new()
	l1.text = label_txt
	l1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l1.add_theme_font_size_override("font_size", 12)
	l1.add_theme_color_override("font_color", _palette["ink"])
	top.add_child(l1)
	var l2 := Label.new()
	l2.text = "%d%%" % pct
	l2.add_theme_font_size_override("font_size", 12)
	l2.add_theme_color_override("font_color", _palette["ink_sub"])
	top.add_child(l2)

	var pb := ProgressBar.new()
	pb.custom_minimum_size = Vector2(0, 8)
	pb.show_percentage = false
	pb.value = pct
	pb.add_theme_stylebox_override("background", UiTokensClass.make_box(_palette["border"], 99, Color(0, 0, 0, 0), 0, 0, 0))
	pb.add_theme_stylebox_override("fill", UiTokensClass.make_box(fill_col, 99, Color(0, 0, 0, 0), 0, 0, 0))
	vb.add_child(pb)

func _on_save_owner_name(new_name: String) -> void:
	archive_state.owner_name = new_name
	archive_state.save_to_file()
	_refresh_all()
	_show_toast("서재 이름을 '%s'(으)로 변경했어요" % archive_state.get_library_title())

func _on_select_theme(tid: String) -> void:
	archive_state.current_theme = tid
	archive_state.save_to_file()
	_palette = UiTokensClass.get_palette(tid)
	_apply_theme()
	_render_shelf()
	_render_showcase()
	_show_toast("'%s' 테마를 적용했어요" % _palette["name"])

func _on_select_showcase_style(sid: String) -> void:
	archive_state.showcase_style = sid
	archive_state.save_to_file()
	settings_page.apply_theme(_palette, archive_state.current_theme, archive_state.showcase_style, archive_state.shelf_columns)
	_render_showcase()
	var sname: String = UiTokensClass.get_showcase_style(sid)["name"]
	_show_toast("전시대를 '%s'(으)로 변경했어요" % sname)

func _on_backup_requested() -> void:
	DisplayServer.clipboard_set(archive_state.to_backup_json())
	_show_toast("JSON 백업을 클립보드에 복사했어요")

func _on_item_submitted(p_title: String, p_cat: int, p_author: String, p_color: String, p_quote: String, p_price: int, p_cover_path: String = "") -> void:
	var new_id := "item_%d" % Time.get_unix_time_from_system()
	var item = CollectionItemClass.new(new_id, p_cat, p_title, p_author if p_author != "" else "작가 미상", "소장중", p_color, "", "")
	item.memo = p_quote if p_quote != "" else "새롭게 추가한 소장 기록"
	item.cover_path = p_cover_path
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
