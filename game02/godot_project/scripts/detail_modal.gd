class_name DetailModal
extends Control

const ArchiveStateClass = preload("res://scripts/archive_state.gd")
const UiTokensClass = preload("res://scripts/ui_tokens.gd")
const DsButtonClass = preload("res://scripts/ui/ds_button.gd")
const DsCardClass = preload("res://scripts/ui/ds_card.gd")
const DsBadgeClass = preload("res://scripts/ui/ds_badge.gd")
const DsInputClass = preload("res://scripts/ui/ds_input.gd")
const DsSegmentedClass = preload("res://scripts/ui/ds_segmented.gd")

signal diary_updated(item)
signal item_deleted(item)
signal toast_requested(msg: String)

var current_item = null
var _palette: Dictionary = UiTokensClass.get_palette("millie")
var _active_tab: int = 0
var _delete_armed: bool = false

var _sheet
var _handle: ColorRect
var _cover_panel: PanelContainer
var _cover_tex: TextureRect
var _cover_lbl: Label
var _badge_lbl
var _title_lbl: Label
var _author_lbl: Label
var _seg_tabs

var _panel_vols: VBoxContainer
var _vol_summary_lbl: Label
var _vol_list: VBoxContainer

var _panel_memo: VBoxContainer
var _hl_btn
var _memo_preview_panel
var _memo_preview_lbl: Label
var _memo_input: TextEdit
var _ink_row: HBoxContainer

var _panel_info: VBoxContainer
var _stamp_row: HFlowContainer
var _price_input: LineEdit
var _loc_input: LineEdit
var _photo_remove_btn
var _delete_btn

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

	_sheet = DsCardClass.create(DsCardClass.Variant.SHEET)
	_sheet.anchor_left = 0.0
	_sheet.anchor_right = 1.0
	_sheet.anchor_top = 0.14
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

	# Header
	var hdr_margin := MarginContainer.new()
	hdr_margin.add_theme_constant_override("margin_left", 20)
	hdr_margin.add_theme_constant_override("margin_right", 20)
	hdr_margin.add_theme_constant_override("margin_top", 4)
	hdr_margin.add_theme_constant_override("margin_bottom", 14)
	root_vbox.add_child(hdr_margin)

	var hdr_hbox := HBoxContainer.new()
	hdr_hbox.add_theme_constant_override("separation", 12)
	hdr_margin.add_child(hdr_hbox)

	_cover_panel = PanelContainer.new()
	_cover_panel.custom_minimum_size = Vector2(56, 74)
	_cover_panel.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_cover_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_cover_panel.tooltip_text = "눌러서 표지 사진 변경"
	_cover_panel.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_on_pick_cover_photo()
	)
	hdr_hbox.add_child(_cover_panel)

	var cov_layer := Control.new()
	cov_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover_panel.add_child(cov_layer)

	_cover_tex = TextureRect.new()
	_cover_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover_tex.visible = false
	_cover_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_layer.add_child(_cover_tex)

	var cov_m := MarginContainer.new()
	cov_m.set_anchors_preset(Control.PRESET_FULL_RECT)
	cov_m.add_theme_constant_override("margin_left", 6)
	cov_m.add_theme_constant_override("margin_right", 6)
	cov_m.add_theme_constant_override("margin_top", 6)
	cov_m.add_theme_constant_override("margin_bottom", 6)
	cov_m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_layer.add_child(cov_m)

	_cover_lbl = Label.new()
	_cover_lbl.add_theme_font_size_override("font_size", 10)
	_cover_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	_cover_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cover_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_cover_lbl.max_lines_visible = 3
	_cover_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cov_m.add_child(_cover_lbl)

	var meta_col := VBoxContainer.new()
	meta_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta_col.alignment = BoxContainer.ALIGNMENT_CENTER
	meta_col.add_theme_constant_override("separation", 4)
	hdr_hbox.add_child(meta_col)

	var badge_row := HBoxContainer.new()
	meta_col.add_child(badge_row)
	_badge_lbl = DsBadgeClass.create("소장중", DsBadgeClass.Variant.MILLIE, 11)
	badge_row.add_child(_badge_lbl)

	_title_lbl = Label.new()
	_title_lbl.add_theme_font_size_override("font_size", 17)
	_title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	meta_col.add_child(_title_lbl)

	_author_lbl = Label.new()
	_author_lbl.add_theme_font_size_override("font_size", 12)
	_author_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	meta_col.add_child(_author_lbl)

	var close_btn = DsButtonClass.create("✕", DsButtonClass.Variant.SECONDARY, DsButtonClass.Size.SM, close)
	close_btn.custom_minimum_size = Vector2(34, 34)
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	hdr_hbox.add_child(close_btn)

	# 3-Tab Segmented Control (Shared DS Component)
	var seg_margin := MarginContainer.new()
	seg_margin.add_theme_constant_override("margin_left", 20)
	seg_margin.add_theme_constant_override("margin_right", 20)
	seg_margin.add_theme_constant_override("margin_bottom", 10)
	root_vbox.add_child(seg_margin)

	_seg_tabs = DsSegmentedClass.create(PackedStringArray(["권별 기록", "감상·밑줄", "소장 정보"]), _switch_tab)
	seg_margin.add_child(_seg_tabs)

	# Scrollable Body
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	var body_m := MarginContainer.new()
	body_m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_m.add_theme_constant_override("margin_left", 20)
	body_m.add_theme_constant_override("margin_right", 20)
	body_m.add_theme_constant_override("margin_top", 4)
	body_m.add_theme_constant_override("margin_bottom", 24)
	scroll.add_child(body_m)

	var body_stack := VBoxContainer.new()
	body_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_m.add_child(body_stack)

	# TAB 0: Volumes
	_panel_vols = VBoxContainer.new()
	_panel_vols.add_theme_constant_override("separation", 10)
	body_stack.add_child(_panel_vols)

	var vol_top := HBoxContainer.new()
	_panel_vols.add_child(vol_top)

	_vol_summary_lbl = Label.new()
	_vol_summary_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vol_summary_lbl.add_theme_font_size_override("font_size", 12)
	vol_top.add_child(_vol_summary_lbl)

	var add_vol_btn = DsButtonClass.create("+ 다음 권 추가", DsButtonClass.Variant.PRIMARY, DsButtonClass.Size.SM, _on_add_volume)
	vol_top.add_child(add_vol_btn)

	_vol_list = VBoxContainer.new()
	_vol_list.add_theme_constant_override("separation", 10)
	_panel_vols.add_child(_vol_list)

	# TAB 1: Memo & Ink
	_panel_memo = VBoxContainer.new()
	_panel_memo.add_theme_constant_override("separation", 12)
	body_stack.add_child(_panel_memo)

	var memo_hdr := HBoxContainer.new()
	_panel_memo.add_child(memo_hdr)

	var memo_title := Label.new()
	memo_title.text = "대표 감상 & 밑줄"
	memo_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memo_title.add_theme_font_size_override("font_size", 13)
	memo_hdr.add_child(memo_title)

	_hl_btn = DsButtonClass.create("형광펜 OFF", DsButtonClass.Variant.OUTLINE, DsButtonClass.Size.SM, _on_toggle_highlight)
	memo_hdr.add_child(_hl_btn)

	_memo_preview_panel = DsCardClass.create(DsCardClass.Variant.SUBTLE, 14, 12, 14)
	_panel_memo.add_child(_memo_preview_panel)

	_memo_preview_lbl = Label.new()
	_memo_preview_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_memo_preview_lbl.add_theme_font_size_override("font_size", 14)
	_memo_preview_panel.add_child(_memo_preview_lbl)

	_memo_input = TextEdit.new()
	_memo_input.custom_minimum_size = Vector2(0, 88)
	_memo_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_memo_input.placeholder_text = "기억하고 싶은 문장이나 감상을 적어보세요"
	_memo_input.add_theme_font_size_override("font_size", 13)
	_panel_memo.add_child(_memo_input)

	var save_memo_btn = DsButtonClass.create("감상 저장", DsButtonClass.Variant.PRIMARY, DsButtonClass.Size.LG, _on_save_memo)
	_panel_memo.add_child(save_memo_btn)

	var ink_panel = DsCardClass.create(DsCardClass.Variant.SUBTLE, 14, 12, 14)
	_panel_memo.add_child(ink_panel)
	var ink_vbox := VBoxContainer.new()
	ink_vbox.add_theme_constant_override("separation", 8)
	ink_panel.add_child(ink_vbox)

	var ink_lbl := Label.new()
	ink_lbl.text = "만년필 잉크 컬러"
	ink_lbl.add_theme_font_size_override("font_size", 12)
	ink_vbox.add_child(ink_lbl)

	_ink_row = HBoxContainer.new()
	_ink_row.add_theme_constant_override("separation", 8)
	ink_vbox.add_child(_ink_row)

	# TAB 2: Info
	_panel_info = VBoxContainer.new()
	_panel_info.add_theme_constant_override("separation", 14)
	body_stack.add_child(_panel_info)

	var info_card = DsCardClass.create(DsCardClass.Variant.SUBTLE, 16, 14, 16)
	_panel_info.add_child(info_card)
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 12)
	info_card.add_child(info_vbox)

	var st_lbl := Label.new()
	st_lbl.text = "소장 상태 배지"
	st_lbl.add_theme_font_size_override("font_size", 12)
	info_vbox.add_child(st_lbl)

	_stamp_row = HFlowContainer.new()
	_stamp_row.add_theme_constant_override("h_separation", 8)
	_stamp_row.add_theme_constant_override("v_separation", 8)
	info_vbox.add_child(_stamp_row)

	var fields_row := HBoxContainer.new()
	fields_row.add_theme_constant_override("separation", 10)
	info_vbox.add_child(fields_row)

	var price_col := VBoxContainer.new()
	price_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_col.add_theme_constant_override("separation", 4)
	var p_lbl := Label.new()
	p_lbl.text = "추정 가치 (원)"
	p_lbl.add_theme_font_size_override("font_size", 12)
	_price_input = DsInputClass.create("예: 21000", DsInputClass.Variant.SURFACE, 38)
	price_col.add_child(p_lbl)
	price_col.add_child(_price_input)
	fields_row.add_child(price_col)

	var loc_col := VBoxContainer.new()
	loc_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loc_col.add_theme_constant_override("separation", 4)
	var l_lbl := Label.new()
	l_lbl.text = "보관 위치"
	l_lbl.add_theme_font_size_override("font_size", 12)
	_loc_input = DsInputClass.create("예: 거실 책장 1층", DsInputClass.Variant.SURFACE, 38)
	loc_col.add_child(l_lbl)
	loc_col.add_child(_loc_input)
	fields_row.add_child(loc_col)

	var photo_row := HBoxContainer.new()
	photo_row.add_theme_constant_override("separation", 8)
	info_vbox.add_child(photo_row)

	var photo_change_btn = DsButtonClass.create("📷 표지 사진 변경", DsButtonClass.Variant.OUTLINE, DsButtonClass.Size.MD, _on_pick_cover_photo)
	photo_change_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	photo_row.add_child(photo_change_btn)

	_photo_remove_btn = DsButtonClass.create("사진 제거", DsButtonClass.Variant.DANGER, DsButtonClass.Size.MD, _on_remove_cover_photo)
	_photo_remove_btn.custom_minimum_size = Vector2(78, 36)
	photo_row.add_child(_photo_remove_btn)

	var save_info_btn = DsButtonClass.create("소장 정보 저장", DsButtonClass.Variant.PRIMARY, DsButtonClass.Size.LG, _on_save_info)
	info_vbox.add_child(save_info_btn)

	_delete_btn = DsButtonClass.create("이 작품 기록 삭제", DsButtonClass.Variant.DANGER, DsButtonClass.Size.LG, _on_delete_pressed)
	_panel_info.add_child(_delete_btn)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	if _sheet == null:
		return
	_handle.color = p["border"]
	_title_lbl.add_theme_color_override("font_color", p["ink"])
	_author_lbl.add_theme_color_override("font_color", p["ink_sub"])
	_vol_summary_lbl.add_theme_color_override("font_color", p["ink_sub"])
	UiTokensClass.style_text_edit(_memo_input, p)
	UiTokensClass.theme_ds_tree(self, p)
	if current_item != null and visible:
		_refresh_all()

func open(item, p: Dictionary = {}) -> void:
	current_item = item
	_delete_armed = false
	_delete_btn.text = "이 작품 기록 삭제"
	if not p.is_empty():
		apply_theme(p)
	_refresh_all()
	_seg_tabs.set_active(0)
	_switch_tab(0)
	visible = true

func close() -> void:
	visible = false

func _switch_tab(idx: int) -> void:
	_active_tab = idx
	_panel_vols.visible = (idx == 0)
	_panel_memo.visible = (idx == 1)
	_panel_info.visible = (idx == 2)

func _refresh_all() -> void:
	if current_item == null:
		return
	var base_col := Color.from_string(current_item.cover_color, Color("#C82342"))
	_cover_panel.add_theme_stylebox_override("panel", UiTokensClass.make_cover_box(base_col, 5, 10))
	var tex := UiTokensClass.load_cover_texture(str(current_item.cover_path))
	if tex != null:
		_cover_tex.texture = tex
		_cover_tex.visible = true
		_cover_lbl.visible = false
	else:
		_cover_tex.texture = null
		_cover_tex.visible = false
		_cover_lbl.visible = true
		_cover_lbl.text = current_item.title
	_photo_remove_btn.visible = (tex != null)

	_badge_lbl.text = current_item.status_tag if current_item.status_tag != "" else "소장중"
	_title_lbl.text = current_item.title
	var avg_r: float = current_item.get_average_rating() if current_item.has_method("get_average_rating") else 5.0
	var est_v: int = current_item.get_item_value() if current_item.has_method("get_item_value") else int(current_item.estimated_value)
	var author_str: String = current_item.author_or_series if current_item.author_or_series != "" else "작가 미상"
	_author_lbl.text = "%s · ★%.1f · %s" % [author_str, avg_r, ArchiveStateClass.format_krw(est_v)]

	_render_volumes()
	_render_memo_panel()
	_render_info_panel()

func _render_volumes() -> void:
	var first_cnt: int = 0
	for v in current_item.volumes:
		if str(v.get("status", "")) == "first":
			first_cnt += 1
	var target: int = maxi(1, current_item.target_volumes if current_item.target_volumes > 0 else current_item.volumes.size())
	var pct: int = 100 if (current_item.status_tag == "전권완결" or current_item.status_tag == "완독") else mini(100, int(round(float(current_item.volumes.size()) / float(target) * 100.0)))
	_vol_summary_lbl.text = "총 %d권 · 초판 %d권 · 완독 %d%%" % [current_item.volumes.size(), first_cnt, pct]

	for ch in _vol_list.get_children():
		ch.queue_free()

	for i in range(current_item.volumes.size()):
		var v: Dictionary = current_item.volumes[i]
		var idx := i
		var card = DsCardClass.create(DsCardClass.Variant.SUBTLE, 14, 12, 14)
		card.apply_theme(_palette)
		_vol_list.add_child(card)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 8)
		card.add_child(vb)

		var top := HBoxContainer.new()
		top.add_theme_constant_override("separation", 8)
		vb.add_child(top)

		var num_lbl := Label.new()
		num_lbl.text = "%d권" % int(v.get("vol", i + 1))
		num_lbl.add_theme_font_size_override("font_size", 14)
		num_lbl.add_theme_color_override("font_color", _palette["ink"])
		top.add_child(num_lbl)

		var is_first: bool = str(v.get("status", "")) == "first"
		var st_btn = DsButtonClass.create(
			"초판특전" if is_first else "소장완료",
			DsButtonClass.Variant.ACCENT if is_first else DsButtonClass.Variant.SECONDARY,
			DsButtonClass.Size.SM,
			func():
				current_item.volumes[idx]["status"] = "owned" if is_first else "first"
				_refresh_all()
				diary_updated.emit(current_item)
		)
		st_btn.apply_theme(_palette)
		top.add_child(st_btn)

		var dt_lbl := Label.new()
		dt_lbl.text = str(v.get("date", ""))
		dt_lbl.add_theme_font_size_override("font_size", 11)
		dt_lbl.add_theme_color_override("font_color", _palette["ink_muted"])
		dt_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(dt_lbl)

		var r_val: int = clampi(int(v.get("rating", 5)), 1, 5)
		var star_btn = DsButtonClass.create("★".repeat(r_val) + "☆".repeat(5 - r_val), DsButtonClass.Variant.GHOST, DsButtonClass.Size.SM, func():
			current_item.volumes[idx]["rating"] = (r_val % 5) + 1
			_refresh_all()
			diary_updated.emit(current_item)
		)
		star_btn.add_theme_font_size_override("font_size", 13)
		star_btn.add_theme_color_override("font_color", Color("#D97706"))
		top.add_child(star_btn)

		var q_edit = DsInputClass.create("이 권의 밑줄 문장을 입력하세요", DsInputClass.Variant.SURFACE, 36)
		q_edit.text = str(v.get("quote", ""))
		q_edit.add_theme_font_size_override("font_size", 12)
		q_edit.apply_theme(_palette)
		q_edit.text_submitted.connect(func(new_txt: String):
			current_item.volumes[idx]["quote"] = new_txt.strip_edges()
			diary_updated.emit(current_item)
			toast_requested.emit("밑줄 문장을 저장했어요")
			q_edit.release_focus()
		)
		q_edit.focus_exited.connect(func():
			if current_item != null and idx < current_item.volumes.size():
				var clean: String = q_edit.text.strip_edges()
				if str(current_item.volumes[idx].get("quote", "")) != clean:
					current_item.volumes[idx]["quote"] = clean
					diary_updated.emit(current_item)
		)
		vb.add_child(q_edit)

func _render_memo_panel() -> void:
	var hl_on: bool = bool(current_item.highlight_enabled)
	_hl_btn.text = "형광펜 ON" if hl_on else "형광펜 OFF"
	_hl_btn.variant = DsButtonClass.Variant.ACCENT if hl_on else DsButtonClass.Variant.OUTLINE
	_hl_btn.apply_theme(_palette)

	var memo_txt: String = current_item.memo if current_item.memo != "" else "감상평을 남겨보세요."
	_memo_preview_lbl.text = "\"%s\"" % memo_txt
	var ink_col := Color.from_string(current_item.memo_ink_color, _palette["ink"])
	if _palette["bg"].v < 0.3:
		ink_col = _palette["ink"]
	_memo_preview_lbl.add_theme_color_override("font_color", ink_col)
	_memo_preview_panel.add_theme_stylebox_override(
		"panel",
		UiTokensClass.make_box(_palette["hl_bg"] if hl_on else _palette["bg_subtle"], 14, Color(0, 0, 0, 0), 0, 14, 12)
	)
	_memo_input.text = current_item.memo

	for ch in _ink_row.get_children():
		ch.queue_free()
	for ink in UiTokensClass.INK_PRESETS:
		var hex: String = ink["hex"]
		var is_sel: bool = current_item.memo_ink_color.to_lower() == hex.to_lower()
		var col := Color.from_string(hex, _palette["ink"])
		var b := Button.new()
		b.text = ink["name"]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 34)
		b.add_theme_font_size_override("font_size", 12)
		UiTokensClass.style_button(b, _palette["surface"], col if _palette["bg"].v > 0.3 else _palette["ink"], 10, col if is_sel else _palette["border"], 2 if is_sel else 1, 6, 4)
		b.pressed.connect(func():
			current_item.memo_ink_color = hex
			_render_memo_panel()
			diary_updated.emit(current_item)
		)
		_ink_row.add_child(b)

func _render_info_panel() -> void:
	for ch in _stamp_row.get_children():
		ch.queue_free()
	for st in UiTokensClass.STAMP_PRESETS:
		var stamp_val: String = st
		var b = DsButtonClass.create(stamp_val, DsButtonClass.Variant.CHIP, DsButtonClass.Size.SM, func():
			current_item.status_tag = stamp_val
			_refresh_all()
			diary_updated.emit(current_item)
		)
		b.is_selected = (current_item.status_tag == stamp_val)
		b.apply_theme(_palette)
		_stamp_row.add_child(b)

	var est_v: int = current_item.get_item_value() if current_item.has_method("get_item_value") else int(current_item.estimated_value)
	_price_input.text = str(est_v)
	_loc_input.text = str(current_item.storage_location)

func _on_add_volume() -> void:
	if current_item == null:
		return
	var next_v: int = current_item.volumes.size() + 1
	current_item.add_volume(next_v, "owned", 5, "")
	_refresh_all()
	diary_updated.emit(current_item)
	toast_requested.emit("%d권 기록을 추가했어요" % next_v)

func _on_toggle_highlight() -> void:
	if current_item == null:
		return
	current_item.highlight_enabled = !current_item.highlight_enabled
	_render_memo_panel()
	diary_updated.emit(current_item)

func _on_save_memo() -> void:
	if current_item == null:
		return
	current_item.memo = _memo_input.text.strip_edges()
	_render_memo_panel()
	diary_updated.emit(current_item)
	toast_requested.emit("감상평을 저장했어요")

func _on_pick_cover_photo() -> void:
	if current_item == null:
		return
	UiTokensClass.open_image_picker(self, func(saved_path: String, _file_name: String):
		if current_item == null or saved_path.is_empty():
			return
		current_item.cover_path = saved_path
		_refresh_all()
		diary_updated.emit(current_item)
		toast_requested.emit("표지 사진을 적용했어요")
	)

func _on_remove_cover_photo() -> void:
	if current_item == null:
		return
	current_item.cover_path = ""
	_refresh_all()
	diary_updated.emit(current_item)
	toast_requested.emit("표지 사진을 제거했어요")

func _on_save_info() -> void:
	if current_item == null:
		return
	var p_txt := _price_input.text.strip_edges().replace(",", "")
	if p_txt.is_valid_int():
		current_item.estimated_value = maxi(0, int(p_txt))
	current_item.storage_location = _loc_input.text.strip_edges()
	_refresh_all()
	diary_updated.emit(current_item)
	toast_requested.emit("소장 정보를 업데이트했어요")

func _on_delete_pressed() -> void:
	if current_item == null:
		return
	if not _delete_armed:
		_delete_armed = true
		_delete_btn.text = "한 번 더 누르면 삭제됩니다"
		return
	var target = current_item
	close()
	item_deleted.emit(target)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
