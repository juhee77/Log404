class_name SettingsPage
extends Control

const UiTokensClass = preload("res://scripts/ui_tokens.gd")
const DsButtonClass = preload("res://scripts/ui/ds_button.gd")
const DsCardClass = preload("res://scripts/ui/ds_card.gd")
const DsInputClass = preload("res://scripts/ui/ds_input.gd")

signal owner_name_saved(new_name: String)
signal theme_selected(theme_id: String)
signal showcase_style_selected(style_id: String)
signal shelf_columns_toggled
signal backup_requested

var _palette: Dictionary = UiTokensClass.get_palette("millie")
var _current_theme_id: String = "millie"
var _current_showcase_id: String = "acrylic"
var _current_cols: int = 3

var _bg_rect: ColorRect
var _hdr_panel: PanelContainer
var _hdr_lbl: Label
var _section_labels: Array[Label] = []
var _cards: Array = []
var _owner_input: LineEdit
var _theme_btns: Dictionary = {}
var _case_btns: Dictionary = {}
var _col_btn: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()
	apply_theme(_palette, _current_theme_id, _current_showcase_id, _current_cols)

func _build_ui() -> void:
	for ch in get_children():
		ch.queue_free()

	_bg_rect = ColorRect.new()
	_bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg_rect)

	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 0)
	add_child(root_vbox)

	# Header Bar
	_hdr_panel = PanelContainer.new()
	root_vbox.add_child(_hdr_panel)

	var hdr_hbox := HBoxContainer.new()
	hdr_hbox.add_theme_constant_override("separation", 8)
	_hdr_panel.add_child(hdr_hbox)

	var back_btn = DsButtonClass.create("←", DsButtonClass.Variant.ICON, DsButtonClass.Size.MD, close)
	back_btn.add_theme_font_size_override("font_size", 18)
	hdr_hbox.add_child(back_btn)

	_hdr_lbl = Label.new()
	_hdr_lbl.text = "설정"
	_hdr_lbl.add_theme_font_size_override("font_size", 17)
	hdr_hbox.add_child(_hdr_lbl)

	# Scrollable Sections
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	var m := MarginContainer.new()
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_theme_constant_override("margin_left", 20)
	m.add_theme_constant_override("margin_right", 20)
	m.add_theme_constant_override("margin_top", 18)
	m.add_theme_constant_override("margin_bottom", 32)
	scroll.add_child(m)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 18)
	m.add_child(vbox)

	_section_labels.clear()
	_cards.clear()

	# Section 1: Library Profile
	var sec1 := _make_section(vbox, "서재 프로필")
	var c1 := _make_card(sec1)
	var c1_v := VBoxContainer.new()
	c1_v.add_theme_constant_override("separation", 8)
	c1.add_child(c1_v)

	var l1 := Label.new()
	l1.text = "서재 이름"
	l1.add_theme_font_size_override("font_size", 14)
	c1_v.add_child(l1)

	var d1 := Label.new()
	d1.text = "이름을 입력하면 'OOO의 서재'로 표시됩니다. 비워두면 '나의 서재'가 됩니다."
	d1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d1.add_theme_font_size_override("font_size", 12)
	c1_v.add_child(d1)

	var owner_row := HBoxContainer.new()
	owner_row.add_theme_constant_override("separation", 8)
	c1_v.add_child(owner_row)

	_owner_input = DsInputClass.create("이름 입력 (예: 주희, 민수)", DsInputClass.Variant.SURFACE, 40)
	_owner_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_owner_input.text_submitted.connect(func(_t): owner_name_saved.emit(_owner_input.text.strip_edges()))
	owner_row.add_child(_owner_input)

	var owner_save_btn = DsButtonClass.create("적용", DsButtonClass.Variant.PRIMARY, DsButtonClass.Size.LG, func(): owner_name_saved.emit(_owner_input.text.strip_edges()))
	owner_save_btn.custom_minimum_size = Vector2(68, 40)
	owner_row.add_child(owner_save_btn)

	# Section 2: Display & Theme
	var sec2 := _make_section(vbox, "화면 및 테마")
	var c2 := _make_card(sec2)
	var c2_v := VBoxContainer.new()
	c2_v.add_theme_constant_override("separation", 14)
	c2.add_child(c2_v)

	var th_lbl := Label.new()
	th_lbl.text = "서재 테마"
	th_lbl.add_theme_font_size_override("font_size", 14)
	c2_v.add_child(th_lbl)

	var th_row := HBoxContainer.new()
	th_row.add_theme_constant_override("separation", 8)
	c2_v.add_child(th_row)
	_theme_btns.clear()
	for tid in ["millie", "paper", "dark"]:
		var tp: Dictionary = UiTokensClass.get_palette(tid)
		var tb := Button.new()
		tb.text = tp["name"]
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.custom_minimum_size = Vector2(0, 42)
		tb.add_theme_font_size_override("font_size", 12)
		var cid: String = tid
		tb.pressed.connect(func(): theme_selected.emit(cid))
		th_row.add_child(tb)
		_theme_btns[tid] = tb

	var case_lbl := Label.new()
	case_lbl.text = "전시대 스타일"
	case_lbl.add_theme_font_size_override("font_size", 14)
	c2_v.add_child(case_lbl)

	var case_row := HBoxContainer.new()
	case_row.add_theme_constant_override("separation", 8)
	c2_v.add_child(case_row)
	_case_btns.clear()
	for sid in ["acrylic", "wood", "museum"]:
		var sp: Dictionary = UiTokensClass.get_showcase_style(sid)
		var cb := Button.new()
		cb.text = sp["name"]
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.custom_minimum_size = Vector2(0, 42)
		cb.add_theme_font_size_override("font_size", 12)
		var csid: String = sid
		cb.pressed.connect(func(): showcase_style_selected.emit(csid))
		case_row.add_child(cb)
		_case_btns[sid] = cb

	var col_row := HBoxContainer.new()
	col_row.add_theme_constant_override("separation", 8)
	c2_v.add_child(col_row)

	var col_txt := VBoxContainer.new()
	col_txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col_t := Label.new()
	col_t.text = "기본 책장 보기"
	col_t.add_theme_font_size_override("font_size", 14)
	var col_d := Label.new()
	col_d.text = "책장 한 줄에 표시할 표지 개수"
	col_d.add_theme_font_size_override("font_size", 12)
	col_txt.add_child(col_t)
	col_txt.add_child(col_d)
	col_row.add_child(col_txt)

	_col_btn = DsButtonClass.create("3열 보기", DsButtonClass.Variant.OUTLINE, DsButtonClass.Size.MD, func(): shelf_columns_toggled.emit())
	_col_btn.custom_minimum_size = Vector2(88, 36)
	_col_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col_row.add_child(_col_btn)

	# Section 3: Data Management
	var sec3 := _make_section(vbox, "데이터 관리")
	var c3 := _make_card(sec3)
	var c3_v := VBoxContainer.new()
	c3_v.add_theme_constant_override("separation", 8)
	c3.add_child(c3_v)

	var bk_d := Label.new()
	bk_d.text = "모든 작품과 권별 밑줄 기록을 JSON 형식으로 클립보드에 복사합니다."
	bk_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bk_d.add_theme_font_size_override("font_size", 12)
	c3_v.add_child(bk_d)

	var backup_btn = DsButtonClass.create("JSON 데이터 백업 복사", DsButtonClass.Variant.OUTLINE, DsButtonClass.Size.LG, func(): backup_requested.emit())
	c3_v.add_child(backup_btn)

	# Section 4: App Info
	var sec4 := _make_section(vbox, "앱 정보")
	var c4 := _make_card(sec4)
	var c4_h := HBoxContainer.new()
	c4.add_child(c4_h)
	var app_n := Label.new()
	app_n.text = "Pocket Archive"
	app_n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	app_n.add_theme_font_size_override("font_size", 13)
	var app_v := Label.new()
	app_v.text = "v2.2 · Design System"
	app_v.add_theme_font_size_override("font_size", 12)
	c4_h.add_child(app_n)
	c4_h.add_child(app_v)

func _make_section(parent: VBoxContainer, title: String) -> VBoxContainer:
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 8)
	parent.add_child(sv)
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 12)
	sv.add_child(lbl)
	_section_labels.append(lbl)
	return sv

func _make_card(parent: VBoxContainer) -> PanelContainer:
	var pc = DsCardClass.create(DsCardClass.Variant.SUBTLE, 16, 14, 16)
	parent.add_child(pc)
	_cards.append(pc)
	return pc

func apply_theme(p: Dictionary, theme_id: String, showcase_id: String, cols: int) -> void:
	_palette = p
	_current_theme_id = theme_id
	_current_showcase_id = showcase_id
	_current_cols = cols
	if _bg_rect == null:
		return

	_bg_rect.color = p["bg"]
	var hdr_sb := StyleBoxFlat.new()
	hdr_sb.bg_color = p["bg"]
	hdr_sb.border_width_bottom = 1
	hdr_sb.border_color = p["border"]
	hdr_sb.content_margin_left = 14
	hdr_sb.content_margin_right = 16
	hdr_sb.content_margin_top = 14
	hdr_sb.content_margin_bottom = 12
	_hdr_panel.add_theme_stylebox_override("panel", hdr_sb)
	_hdr_lbl.add_theme_color_override("font_color", p["ink"])

	# One-line Design System auto-theming for all DsButton/DsCard/DsInput children!
	UiTokensClass.theme_ds_tree(self, p)

	for sl in _section_labels:
		sl.add_theme_color_override("font_color", p["ink_muted"])
	for c in _cards:
		for lbl in c.find_children("*", "Label", true, false):
			lbl.add_theme_color_override("font_color", p["ink"] if lbl.get_theme_font_size("font_size") >= 13 else p["ink_sub"])

	_col_btn.text = "3열 보기" if cols == 3 else "2열 보기"

	for tid in _theme_btns.keys():
		var tp: Dictionary = UiTokensClass.get_palette(tid)
		var is_sel: bool = (tid == theme_id)
		UiTokensClass.style_button(_theme_btns[tid], tp["bg"], tp["ink"], 12, p["ink"] if is_sel else tp["border"], 2 if is_sel else 1, 8, 8)

	for sid in _case_btns.keys():
		var sp: Dictionary = UiTokensClass.get_showcase_style(sid)
		var is_sel: bool = (sid == showcase_id)
		UiTokensClass.style_button(_case_btns[sid], sp["bg"], sp["plaque_ink"], 12, p["ink"] if is_sel else sp["border"], 2 if is_sel else 1, 8, 8)

func open(owner_name: String, p: Dictionary, theme_id: String, showcase_id: String, cols: int) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_owner_input.text = owner_name
	apply_theme(p, theme_id, showcase_id, cols)
	visible = true

func close() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
