class_name DetailModal
extends Control

signal item_deleted(item)
signal volume_added(item)
signal diary_updated(item)

@onready var title_label: Label = $Panel/VBox/Header/HBox/TitleLabel
@onready var cat_badge: Label = $Panel/VBox/Header/HBox/CatBadge
@onready var cover_rect: ColorRect = $Panel/VBox/BodyMargin/Body/TopInfo/CoverRect
@onready var cover_icon: Label = $Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/CoverIcon
@onready var author_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/AuthorLabel
@onready var tag_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/TagLabel
@onready var memo_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/MemoLabel
@onready var vol_section: VBoxContainer = $Panel/VBox/BodyMargin/Body/VolSection
@onready var vol_header: Label = $Panel/VBox/BodyMargin/Body/VolSection/VolHeader
@onready var vol_list: VBoxContainer = $Panel/VBox/BodyMargin/Body/VolSection/Scroll/VolList
@onready var add_vol_btn: Button = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/AddVolBtn
@onready var quote_input: LineEdit = $Panel/VBox/BodyMargin/Body/QuoteEditRow/QuoteInput
@onready var save_quote_btn: Button = $Panel/VBox/BodyMargin/Body/QuoteEditRow/SaveQuoteBtn
@onready var stamp_row: HBoxContainer = $Panel/VBox/BodyMargin/Body/StampRow

var current_item = null
var editing_vol_index: int = -1
var obi_cursor: int = 0
var icon_cursor: int = 0

const ICON_PRESETS = ["📖", "📕", "✨", "🎀", "🏆", "🔮", "🌸", "🏀", "🪄", "🐱", "🏐", "🌙"]

const OBI_PRESETS = [
	"★ 초판 한정 홀로그램 책갈피 동봉",
	"★ 전권 완결 애장판 박스세트",
	"★ 아크릴 케이스 방진 전시중",
	"★ 주희의 다꾸 서재 인생 명작"
]

func _ready() -> void:
	visible = false
	_style_diary_controls()
	cover_rect.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			cycle_cover_icon()
	)

func _style_diary_controls() -> void:
	var stamp_sb = StyleBoxFlat.new()
	stamp_sb.bg_color = Color(0.99, 0.96, 0.94, 1)
	stamp_sb.border_width_left = 1
	stamp_sb.border_width_top = 1
	stamp_sb.border_width_right = 1
	stamp_sb.border_width_bottom = 1
	stamp_sb.border_color = Color(0.78, 0.35, 0.20, 0.65)
	stamp_sb.corner_radius_top_left = 6
	stamp_sb.corner_radius_top_right = 6
	stamp_sb.corner_radius_bottom_left = 6
	stamp_sb.corner_radius_bottom_right = 6

	for child in stamp_row.get_children():
		if child is Button:
			child.add_theme_stylebox_override("normal", stamp_sb)
			child.add_theme_color_override("font_color", Color(0.78, 0.35, 0.20))

	var input_sb = StyleBoxFlat.new()
	input_sb.bg_color = Color(0.98, 0.96, 0.92, 1)
	input_sb.border_width_bottom = 2
	input_sb.border_color = Color(0.78, 0.68, 0.56, 1)
	input_sb.content_margin_left = 8
	quote_input.add_theme_stylebox_override("normal", input_sb)
	quote_input.add_theme_color_override("font_color", Color(0.18, 0.14, 0.11))
	quote_input.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.42))

	var save_sb = StyleBoxFlat.new()
	save_sb.bg_color = Color(0.22, 0.16, 0.13, 1)
	save_sb.corner_radius_top_left = 6
	save_sb.corner_radius_top_right = 6
	save_sb.corner_radius_bottom_left = 6
	save_sb.corner_radius_bottom_right = 6
	save_quote_btn.add_theme_stylebox_override("normal", save_sb)
	save_quote_btn.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))

	var cream_btn = StyleBoxFlat.new()
	cream_btn.bg_color = Color(0.95, 0.91, 0.84, 1)
	cream_btn.border_width_left = 1
	cream_btn.border_width_top = 1
	cream_btn.border_width_right = 1
	cream_btn.border_width_bottom = 1
	cream_btn.border_color = Color(0.80, 0.72, 0.62, 1)
	cream_btn.corner_radius_top_left = 6
	cream_btn.corner_radius_top_right = 6
	cream_btn.corner_radius_bottom_left = 6
	cream_btn.corner_radius_bottom_right = 6
	add_vol_btn.add_theme_stylebox_override("normal", cream_btn)
	add_vol_btn.add_theme_color_override("font_color", Color(0.22, 0.16, 0.13))

	var rem_btn: Button = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/RemoveVolBtn
	rem_btn.add_theme_stylebox_override("normal", cream_btn)
	rem_btn.add_theme_color_override("font_color", Color(0.52, 0.36, 0.28))

	var del_btn: Button = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn
	del_btn.add_theme_stylebox_override("normal", cream_btn)
	del_btn.add_theme_color_override("font_color", Color(0.78, 0.25, 0.20))

	var close_btn: Button = $Panel/VBox/Header/HBox/CloseBtn
	close_btn.add_theme_stylebox_override("normal", cream_btn)
	close_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))

func open(item) -> void:
	current_item = item
	editing_vol_index = -1
	title_label.text = "📔 " + item.title
	author_label.text = "작가 · " + (item.author_or_series if item.author_or_series != "" else "미상")
	tag_label.text = "💮 스탬프: " + item.status_tag + "  |  " + item.obi_text
	memo_label.text = "🖋️ \"" + (item.memo if item.memo != "" else "오늘 읽은 페이지의 감동을 일기장에 기록합니다.") + "\""
	quote_input.text = item.memo
	
	cover_rect.color = Color.from_string(item.cover_color, Color(0.65, 0.25, 0.2))
	cover_icon.text = item.icon_emoji if item.icon_emoji != "" else "📖"

	vol_section.visible = true
	add_vol_btn.visible = true
	if item.category == 0: # MANGA
		cat_badge.text = " [이북·단행본 일기] "
		add_vol_btn.text = "🖋️ + 다음 권 일기 추가"
	else:
		cat_badge.text = " [가챠·굿즈 스크랩] "
		add_vol_btn.text = "🔮 + 파츠·보증서 기록 추가"
	_render_volumes()
	
	visible = true

func close() -> void:
	visible = false

func apply_stamp(stamp_name: String) -> void:
	if current_item == null:
		return
	current_item.status_tag = stamp_name
	tag_label.text = "💮 스탬프: " + current_item.status_tag + "  |  " + current_item.obi_text
	diary_updated.emit(current_item)

func cycle_obi_preset() -> void:
	if current_item == null:
		return
	obi_cursor = (obi_cursor + 1) % OBI_PRESETS.size()
	if OBI_PRESETS[obi_cursor] == current_item.obi_text:
		obi_cursor = (obi_cursor + 1) % OBI_PRESETS.size()
	current_item.obi_text = OBI_PRESETS[obi_cursor]
	tag_label.text = "💮 스탬프: " + current_item.status_tag + "  |  " + current_item.obi_text
	diary_updated.emit(current_item)

func cycle_cover_icon() -> void:
	if current_item == null:
		return
	icon_cursor = (icon_cursor + 1) % ICON_PRESETS.size()
	if ICON_PRESETS[icon_cursor] == current_item.icon_emoji:
		icon_cursor = (icon_cursor + 1) % ICON_PRESETS.size()
	current_item.icon_emoji = ICON_PRESETS[icon_cursor]
	cover_icon.text = current_item.icon_emoji
	diary_updated.emit(current_item)

func _on_stamp_complete_pressed() -> void:
	apply_stamp("전권완결")

func _on_stamp_first_pressed() -> void:
	apply_stamp("초판특전")

func _on_stamp_fav_pressed() -> void:
	apply_stamp("인생최애")

func _on_stamp_wish_pressed() -> void:
	apply_stamp("위시리스트")

func update_volume_quote(vol_idx: int, new_quote: String) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	current_item.volumes[vol_idx]["quote"] = new_quote.strip_edges()
	_render_volumes()
	diary_updated.emit(current_item)

func _on_save_quote_btn_pressed() -> void:
	if current_item == null:
		return
	var trimmed = quote_input.text.strip_edges()
	if trimmed != "":
		if editing_vol_index >= 0 and editing_vol_index < current_item.volumes.size():
			update_volume_quote(editing_vol_index, trimmed)
			editing_vol_index = -1
		else:
			current_item.memo = trimmed
			memo_label.text = "🖋️ \"" + current_item.memo + "\""
			diary_updated.emit(current_item)

func toggle_volume_status(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var cur = str(current_item.volumes[vol_idx].get("status", "owned"))
	current_item.volumes[vol_idx]["status"] = "owned" if cur == "first" else "first"
	_render_volumes()
	diary_updated.emit(current_item)

func cycle_volume_rating(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var cur_r = int(current_item.volumes[vol_idx].get("rating", 5))
	var next_r = 3 if cur_r >= 5 else (cur_r + 1)
	current_item.volumes[vol_idx]["rating"] = next_r
	_render_volumes()
	diary_updated.emit(current_item)

func _render_volumes() -> void:
	for child in vol_list.get_children():
		child.queue_free()
	
	if current_item == null:
		return

	if current_item.volumes.is_empty():
		if current_item.category == 1:
			vol_header.text = "🔮 가챠 · 굿즈 소장 파츠 & 전시 체크리스트"
			var gacha_notes = [
				"🔖 캡슐 미니북(보증서) 스크랩북 보관 완료",
				"✨ 아크릴 케이스 방진 전시 완료"
			]
			for gn in gacha_notes:
				var glbl = Label.new()
				glbl.text = gn
				glbl.add_theme_font_size_override("font_size", 11)
				glbl.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
				vol_list.add_child(glbl)
			return
		vol_header.text = "📌 권별 밑줄 문장 & 초판 스탬프 노트 (0권)"
		var empty_lbl = Label.new()
		empty_lbl.text = "아직 기록된 권별 일기가 없습니다."
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.44, 0.38))
		vol_list.add_child(empty_lbl)
		return

	var first_cnt = 0
	for v in current_item.volumes:
		if v.get("status", "") == "first":
			first_cnt += 1
	vol_header.text = "📌 권별 밑줄 노트 (소장 " + str(current_item.volumes.size()) + "권 · 초판 " + str(first_cnt) + "권)"

	for idx in range(current_item.volumes.size()):
		var v = current_item.volumes[idx]
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.97, 0.945, 0.90, 1)
		sb.border_width_bottom = 1
		sb.border_color = Color(0.86, 0.80, 0.72, 1)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		panel.add_theme_stylebox_override("panel", sb)

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 5)
		margin.add_theme_constant_override("margin_bottom", 5)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		
		var vol_lbl = Label.new()
		vol_lbl.text = str(int(v.get("vol", 1))) + "권"
		vol_lbl.add_theme_font_size_override("font_size", 12)
		vol_lbl.add_theme_color_override("font_color", Color(0.17, 0.13, 0.11))
		vol_lbl.custom_minimum_size = Vector2(28, 0)
		
		var status_btn = Button.new()
		var is_first = v.get("status", "") == "first"
		status_btn.text = "🔖초판특전" if is_first else "✓소장완료"
		status_btn.add_theme_font_size_override("font_size", 9)
		var btn_sb = StyleBoxFlat.new()
		btn_sb.bg_color = Color(0.99, 0.96, 0.94, 1) if is_first else Color(0.93, 0.96, 0.94, 1)
		btn_sb.border_width_left = 1
		btn_sb.border_width_top = 1
		btn_sb.border_width_right = 1
		btn_sb.border_width_bottom = 1
		btn_sb.border_color = Color(0.78, 0.35, 0.2, 0.5) if is_first else Color(0.29, 0.45, 0.36, 0.5)
		btn_sb.corner_radius_top_left = 4
		btn_sb.corner_radius_top_right = 4
		btn_sb.corner_radius_bottom_left = 4
		btn_sb.corner_radius_bottom_right = 4
		status_btn.add_theme_stylebox_override("normal", btn_sb)
		status_btn.add_theme_color_override("font_color", Color(0.78, 0.35, 0.2) if is_first else Color(0.29, 0.45, 0.36))
		var capture_idx = idx
		status_btn.pressed.connect(func(): toggle_volume_status(capture_idx))
		
		var quote_lbl = Label.new()
		var q = v.get("quote", "")
		quote_lbl.text = "🖋️ \"" + q + "\"" if q != "" else "🖋️ 읽고 남긴 한 줄 일기"
		quote_lbl.add_theme_font_size_override("font_size", 10)
		quote_lbl.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
		quote_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		quote_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		var star_btn = Button.new()
		var r = int(v.get("rating", 5))
		star_btn.text = "★".repeat(r)
		star_btn.flat = true
		star_btn.add_theme_font_size_override("font_size", 11)
		star_btn.add_theme_color_override("font_color", Color(0.78, 0.35, 0.2))
		star_btn.pressed.connect(func(): cycle_volume_rating(capture_idx))
		
		hbox.add_child(vol_lbl)
		hbox.add_child(status_btn)
		hbox.add_child(quote_lbl)
		hbox.add_child(star_btn)
		margin.add_child(hbox)
		panel.add_child(margin)
		vol_list.add_child(panel)

func _on_close_btn_pressed() -> void:
	close()

func _on_add_vol_btn_pressed() -> void:
	if current_item != null:
		var next_num = current_item.volumes.size() + 1
		current_item.add_volume(next_num, "first", 5, str(next_num) + "권 읽고 밑줄 친 오늘의 문장")
		_render_volumes()
		volume_added.emit(current_item)

func remove_last_volume() -> void:
	if current_item != null and current_item.volumes.size() > 0:
		current_item.volumes.pop_back()
		_render_volumes()
		diary_updated.emit(current_item)

func _on_delete_btn_pressed() -> void:
	if current_item != null:
		item_deleted.emit(current_item)
		close()
