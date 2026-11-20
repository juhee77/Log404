class_name DetailModal
extends Control

const ArchiveStateClass = preload("res://scripts/archive_state.gd")
const INK_SWATCH_MAP := {
	"InkEspresso": "#2c221e",
	"InkBurgundy": "#7f1d1d",
	"InkSepia": "#78350f",
	"InkForest": "#14532d"
}
const STAMP_PRESET_MAP := {
	"StampComplete": "전권완결",
	"StampFirst": "초판특전",
	"StampFav": "인생최애",
	"StampWish": "위시"
}

signal item_deleted(item)
signal volume_added(item)
signal volume_removed(item)
signal card_copied(item)
signal navigate_requested(delta: int)
signal diary_updated(item)
signal help_requested
signal summary_copy_requested
signal close_and_backup_requested
signal filter_category_requested(cat: int)
signal search_author_requested(author_name: String)

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
@onready var stamp_row: HFlowContainer = $Panel/VBox/BodyMargin/Body/StampRow

var current_item = null
var editing_vol_index: int = -1
var delete_armed: bool = false
var obi_cursor: int = 0
var icon_cursor: int = 0
var color_cursor: int = 0
var washi_cursor: int = 0

const ICON_PRESETS = ["📖", "📕", "✨", "🎀", "🏆", "🔮", "🌸", "🏀", "🪄", "🐱", "🏐", "🌙"]
const COLOR_PRESETS = ["#b91c1c", "#1d4ed8", "#c2410c", "#be185d", "#15803d", "#6d28d9", "#0f766e"]
const WASHI_PRESETS = ["#f4d394", "#fbcfe8", "#bbf7d0", "#bae6fd", "#e7d5c4"]
const INK_PRESETS = [
	{"name": "에스프레소", "hex": "#2c221e"},
	{"name": "버건디", "hex": "#7f1d1d"},
	{"name": "세피아", "hex": "#78350f"},
	{"name": "포레스트", "hex": "#14532d"}
]

const OBI_PRESETS = [
	"★ 초판 한정 홀로그램 책갈피 동봉",
	"★ 전권 완결 애장판 박스세트",
	"★ 아크릴 케이스 방진 전시중",
	"★ 주희의 다꾸 서재 인생 명작"
]

func _ready() -> void:
	visible = false
	_style_diary_controls()
	if quote_input != null:
		quote_input.text_submitted.connect(func(_t): _on_save_quote_btn_pressed())
		quote_input.tooltip_text = "밑줄 문장·감상평 입력 (Enter: 저장 · 우클릭: 입력 비우기/원문 복원)"
		quote_input.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT and current_item != null:
				if quote_input.text != "":
					quote_input.text = ""
				else:
					editing_vol_index = -1
					quote_input.text = current_item.memo
					quote_input.placeholder_text = "🖋️ 오늘 밑줄 친 명대사·감상평 수정..."
		)
	var dimmer: Control = get_node_or_null("Dimmer")
	if dimmer != null:
		dimmer.tooltip_text = "좌클릭: 일기장 닫기 · 우클릭: 닫고 즉시 JSON 백업"
		dimmer.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					close()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					close()
					close_and_backup_requested.emit()
		)
	cover_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cover_rect.tooltip_text = "좌클릭·X: 표지 아이콘 변경(Shift+X: 이전) · 우클릭·Q: 표지 색상 변경(Shift+Q: 이전) · Shift+좌/우클릭: 마감/상태등급"
	if title_label != null:
		title_label.mouse_filter = Control.MOUSE_FILTER_STOP
		title_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		title_label.tooltip_text = "좌클릭: 작품 제목 클립보드 복사 · 우클릭: 감상 카드 전체 복사 (C)"
	if author_label != null:
		author_label.tooltip_text = "좌클릭: 이 작가·시리즈의 다른 작품 검색하기 · Shift+좌클릭: 작가명 복사 · 우클릭: 가치 +5,000원(Shift: -5,000원)"
	if tag_label != null:
		tag_label.tooltip_text = "좌클릭: 띠지 문구 다음 순환 (O) · 우클릭: 이전 순환 (Shift+O) · Shift+좌클릭: 태그 복사"
	if memo_label != null:
		memo_label.tooltip_text = "좌클릭: 밑줄 문장 편집 입력창 이동 (E) · 우클릭: 형광펜 토글 (L) · Shift+좌클릭: 감상평 복사"
		title_label.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					DisplayServer.clipboard_set(current_item.title)
					title_label.tooltip_text = "✅ 복사됨: " + current_item.title
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					card_copied.emit(current_item)
		)
	if cat_badge != null:
		cat_badge.mouse_filter = Control.MOUSE_FILTER_STOP
		cat_badge.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		cat_badge.tooltip_text = "좌클릭: 같은 카테고리(이북/가챠) 서재만 모아보기 · 우클릭: 전체 서재 보기"
		cat_badge.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					var target_cat: int = current_item.category
					close()
					filter_category_requested.emit(target_cat)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					close()
					filter_category_requested.emit(-1)
		)
	if author_label != null:
		author_label.mouse_filter = Control.MOUSE_FILTER_STOP
		author_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		author_label.tooltip_text = "좌클릭: 이 작가·시리즈의 다른 작품 검색하기 · Shift+좌클릭: 작가명 복사 · 우클릭: 가치 +5,000원(Shift: -5,000원)"
		author_label.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						DisplayServer.clipboard_set(current_item.author_or_series)
						author_label.tooltip_text = "✅ 작가 복사됨: " + current_item.author_or_series
					else:
						var author_q: String = current_item.author_or_series
						close()
						search_author_requested.emit(author_q)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					if ev.shift_pressed:
						reduce_estimated_value()
					else:
						boost_estimated_value()
		)
	if memo_label != null:
		memo_label.mouse_filter = Control.MOUSE_FILTER_STOP
		memo_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		memo_label.tooltip_text = "좌클릭: 밑줄 문장 편집 입력창 이동 (E) · 우클릭: 형광펜 토글 (L) · Shift+좌클릭: 감상평 복사"
		memo_label.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						DisplayServer.clipboard_set(current_item.memo)
						memo_label.tooltip_text = "✅ 감상평 복사됨: " + current_item.memo
					elif quote_input != null:
						quote_input.grab_focus()
						quote_input.caret_column = quote_input.text.length()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					toggle_quote_highlight()
		)
	if tag_label != null:
		tag_label.mouse_filter = Control.MOUSE_FILTER_STOP
		tag_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tag_label.tooltip_text = "좌클릭: 띠지 문구 다음 순환 (O) · 우클릭: 이전 순환 (Shift+O) · Shift+좌클릭: 태그 복사"
		tag_label.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						DisplayServer.clipboard_set(tag_label.text)
						tag_label.tooltip_text = "✅ 태그 복사됨: " + tag_label.text
					else:
						cycle_obi_preset(1)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					cycle_obi_preset(-1)
		)
	if vol_header != null:
		vol_header.mouse_filter = Control.MOUSE_FILTER_STOP
		vol_header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		vol_header.tooltip_text = "좌클릭: 새 권·파츠 추가 (+) · 우클릭: 마지막 권 삭제 (-) · Shift+좌클릭: 전권 북마크 일괄 토글"
		vol_header.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						var all_bm: bool = not current_item.volumes.is_empty()
						for v in current_item.volumes:
							if not bool(v.get("bookmarked", false)):
								all_bm = false
								break
						for v in current_item.volumes:
							v["bookmarked"] = not all_bm
						_render_volumes()
						_refresh_vol_header()
						diary_updated.emit(current_item)
					else:
						_on_add_vol_btn_pressed()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					remove_last_volume()
		)
	cover_rect.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			if ev.button_index == MOUSE_BUTTON_LEFT:
				if ev.shift_pressed:
					cycle_cover_finish(1)
				else:
					cycle_cover_icon()
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				if ev.shift_pressed:
					cycle_condition_grade(1)
				else:
					cycle_cover_color()
	)
	var washi_node: ColorRect = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	if washi_node != null:
		washi_node.mouse_filter = Control.MOUSE_FILTER_STOP
		washi_node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		washi_node.tooltip_text = "좌클릭: 마스킹 테이프 다음 색 · 우클릭: 이전 색 · Shift+좌/우클릭: 스티커/속지"
		washi_node.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						cycle_deco_sticker(1)
					else:
						cycle_washi_tape(1)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					if ev.shift_pressed:
						cycle_paper_pattern(1)
					else:
						cycle_washi_tape(-1)
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
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if STAMP_PRESET_MAP.has(child.name):
				var st_name: String = STAMP_PRESET_MAP[child.name]
				child.tooltip_text = "좌클릭: '%s' 인장 찍기 ([1]~[4]) · 우클릭: 인장+감상카드 복사 · Shift+좌클릭: 찍고 닫기" % st_name
				child.gui_input.connect(func(ev: InputEvent) -> void:
					if ev is InputEventMouseButton and ev.pressed:
						if ev.button_index == MOUSE_BUTTON_RIGHT:
							apply_stamp(st_name)
							copy_book_quote_card()
						elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
							child.accept_event()
							apply_stamp(st_name)
							close()
				)
	var stamp_lbl: Label = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/StampLbl")
	if stamp_lbl != null:
		stamp_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		stamp_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		stamp_lbl.tooltip_text = "좌클릭: 인장 프리셋 순환 (1~4) · 우클릭: 역순환"
		stamp_lbl.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT or ev.button_index == MOUSE_BUTTON_RIGHT:
					var presets: Array = STAMP_PRESET_MAP.values()
					var cur_idx: int = presets.find(current_item.status_tag)
					var step: int = -1 if ev.button_index == MOUSE_BUTTON_RIGHT else 1
					var next_idx: int = (cur_idx + step + presets.size()) % presets.size() if cur_idx != -1 else 0
					apply_stamp(presets[next_idx])
		)
	var ink_lbl: Label = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/InkLbl")
	if ink_lbl != null:
		ink_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		ink_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		ink_lbl.tooltip_text = "좌클릭: 만년필 잉크 순환 (I) · 우클릭: 역순환 (Shift+I)"
		ink_lbl.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and current_item != null:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					cycle_fountain_pen_ink(1)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					cycle_fountain_pen_ink(-1)
		)

	var input_sb = StyleBoxFlat.new()
	input_sb.bg_color = Color(0.98, 0.96, 0.92, 1)
	input_sb.border_width_bottom = 2
	input_sb.border_color = Color(0.78, 0.68, 0.56, 1)
	input_sb.content_margin_left = 8
	quote_input.clear_button_enabled = true
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
	rem_btn.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and current_item != null and not current_item.volumes.is_empty():
			if ev.button_index == MOUSE_BUTTON_RIGHT:
				toggle_volume_bookmark(current_item.volumes.size() - 1)
			elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
				rem_btn.accept_event()
				var all_bm: bool = true
				for vol_d in current_item.volumes:
					if not bool(vol_d.get("bookmarked", false)):
						all_bm = false
						break
				var target_bm: bool = not all_bm
				for vol_d in current_item.volumes:
					vol_d["bookmarked"] = target_bm
				_render_volumes()
				_refresh_vol_header()
				diary_updated.emit(current_item)
	)

	var share_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	if share_btn != null:
		share_btn.add_theme_stylebox_override("normal", cream_btn)
		share_btn.add_theme_color_override("font_color", Color(0.28, 0.45, 0.38))
		share_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					summary_copy_requested.emit()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					share_btn.accept_event()
					summary_copy_requested.emit()
		)

	var del_btn: Button = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn
	del_btn.add_theme_stylebox_override("normal", cream_btn)
	del_btn.add_theme_color_override("font_color", Color(0.78, 0.25, 0.20))

	var close_btn: Button = $Panel/VBox/Header/HBox/CloseBtn
	close_btn.add_theme_stylebox_override("normal", cream_btn)
	close_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))

	var hl_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/QuoteEditRow/HighlightBtn")
	if hl_btn != null:
		hl_btn.add_theme_stylebox_override("normal", cream_btn)
		hl_btn.add_theme_color_override("font_color", Color(0.55, 0.38, 0.12))

	var ink_row: HFlowContainer = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow")
	if ink_row != null:
		for btn in ink_row.get_children():
			if btn is Button:
				btn.add_theme_stylebox_override("normal", cream_btn)
				btn.add_theme_color_override("font_color", Color(0.28, 0.22, 0.18))
				btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				if INK_SWATCH_MAP.has(btn.name):
					var sw_hex: String = INK_SWATCH_MAP[btn.name]
					btn.tooltip_text = "좌클릭: 잉크색 적용 · 우클릭: 잉크 적용+형광펜 토글 · Shift+좌클릭: 잉크 적용+입력창"
					btn.gui_input.connect(func(ev: InputEvent) -> void:
						if ev is InputEventMouseButton and ev.pressed:
							if ev.button_index == MOUSE_BUTTON_RIGHT:
								set_fountain_pen_ink(sw_hex)
								toggle_quote_highlight()
							elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
								btn.accept_event()
								set_fountain_pen_ink(sw_hex)
								if quote_input != null:
									quote_input.grab_focus()
									quote_input.caret_column = quote_input.text.length()
					)
	for ctrl in [save_quote_btn, add_vol_btn, rem_btn, share_btn, del_btn, close_btn, hl_btn]:
		if ctrl != null:
			ctrl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if add_vol_btn != null:
		add_vol_btn.tooltip_text = "새 권·파츠 일기 1개 추가 (+) · 우클릭: 추가 후 바로 밑줄 입력 · Shift+좌클릭: 초판+북마크 추가"
		add_vol_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					_on_add_vol_btn_pressed()
					if current_item != null and not current_item.volumes.is_empty():
						start_editing_volume_quote(current_item.volumes.size() - 1)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					add_vol_btn.accept_event()
					_on_add_vol_btn_pressed()
					if current_item != null and not current_item.volumes.is_empty():
						var last_v = current_item.volumes[current_item.volumes.size() - 1]
						last_v["status"] = "first"
						last_v["bookmarked"] = true
						_render_volumes()
						_refresh_vol_header()
						diary_updated.emit(current_item)
		)
	if rem_btn != null:
		rem_btn.tooltip_text = "마지막 권·파츠 기록 삭제 (- · 우클릭: 마지막 권 북마크 토글 · Shift+좌클릭: 전권 북마크 일괄 토글)"
	if share_btn != null:
		share_btn.tooltip_text = "감상 카드 텍스트를 클립보드에 복사 (C · 우클릭·Shift+C: 전체 서재 리포트 복사 · Shift+좌클릭: 전체 서재 리포트 복사)"
	if del_btn != null:
		del_btn.tooltip_text = "이 작품의 일기장을 서재에서 삭제 (우클릭: 삭제 확인 해제 · Shift+좌클릭: 삭제 확인 해제)"
		del_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					if delete_armed:
						delete_armed = false
						_apply_delete_btn_style(false)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					del_btn.accept_event()
					if delete_armed:
						delete_armed = false
						_apply_delete_btn_style(false)
		)
	if save_quote_btn != null:
		save_quote_btn.tooltip_text = "작성한 밑줄·감상평 저장 (Enter · 우클릭: 원문 복원 · Shift+좌클릭: 저장+복사)"
		save_quote_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					if current_item != null and quote_input != null:
						editing_vol_index = -1
						quote_input.text = current_item.memo
						quote_input.placeholder_text = "🖋️ 오늘 밑줄 친 감상평 수정..."
						_render_volumes()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed and quote_input != null:
					var q_copy: String = quote_input.text.strip_edges()
					_on_save_quote_btn_pressed()
					if q_copy != "":
						DisplayServer.clipboard_set(q_copy)
						save_quote_btn.tooltip_text = "✅ 저장·복사됨: " + q_copy
		)
	if hl_btn != null:
		hl_btn.tooltip_text = "밑줄 문장 형광펜 하이라이트 켜기/끄기 (L · 우클릭: 잉크색 변경 · Shift+좌클릭: 속지)"
		hl_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					cycle_fountain_pen_ink(1)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					cycle_paper_pattern(1)
		)
	if close_btn != null:
		close_btn.tooltip_text = "일기장 닫기 (ESC · 우클릭: 닫고 즉시 JSON 백업 · Shift+좌클릭: 카드 복사+닫기)"
		close_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					close()
					close_and_backup_requested.emit()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					close_btn.accept_event()
					copy_book_quote_card()
					close()
		)
		var header_hbox: HBoxContainer = close_btn.get_parent() as HBoxContainer
		if header_hbox != null and header_hbox.get_node_or_null("PrevItemBtn") == null:
			var prev_btn := Button.new()
			prev_btn.name = "PrevItemBtn"
			prev_btn.text = "◀"
			prev_btn.custom_minimum_size = Vector2(26, 26)
			prev_btn.tooltip_text = "이전 작품 일기장 (← · 우클릭: 처음 · Shift+좌클릭: 처음)"
			prev_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			prev_btn.add_theme_stylebox_override("normal", cream_btn)
			prev_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
			prev_btn.pressed.connect(func(): navigate_requested.emit(-1))
			prev_btn.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_RIGHT:
						navigate_requested.emit(-9999)
					elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
						navigate_requested.emit(-9999)
						prev_btn.accept_event()
			)
			var next_btn := Button.new()
			next_btn.name = "NextItemBtn"
			next_btn.text = "▶"
			next_btn.custom_minimum_size = Vector2(26, 26)
			next_btn.tooltip_text = "다음 작품 일기장 (→ · 우클릭: 끝 · Shift+좌클릭: 끝)"
			next_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			next_btn.add_theme_stylebox_override("normal", cream_btn)
			next_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
			next_btn.pressed.connect(func(): navigate_requested.emit(1))
			next_btn.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_RIGHT:
						navigate_requested.emit(9999)
					elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
						navigate_requested.emit(9999)
						next_btn.accept_event()
			)
			var close_idx := close_btn.get_index()
			var page_lbl := Label.new()
			page_lbl.name = "PageBadgeLabel"
			page_lbl.text = "1/6"
			page_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			page_lbl.add_theme_font_size_override("font_size", 11)
			page_lbl.add_theme_color_override("font_color", Color(0.48, 0.38, 0.31))
			page_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
			page_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			page_lbl.tooltip_text = "현재 일기장 순번 (클릭: 다음 · 우클릭: 이전 · Shift+좌/우클릭·Home/End: 처음·끝)"
			page_lbl.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_LEFT:
						navigate_requested.emit(-9999 if ev.shift_pressed else 1)
					elif ev.button_index == MOUSE_BUTTON_RIGHT:
						navigate_requested.emit(9999 if ev.shift_pressed else -1)
			)
			header_hbox.add_child(prev_btn)
			header_hbox.move_child(prev_btn, close_idx)
			header_hbox.add_child(page_lbl)
			header_hbox.move_child(page_lbl, close_idx + 1)
			header_hbox.add_child(next_btn)
			header_hbox.move_child(next_btn, close_idx + 2)
	var row_tips := {
		"Panel/VBox/BodyMargin/Body/StampRow/ObiCycleBtn": "띠지 문구 프리셋 순환 (O) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/TapeCycleBtn": "상단 마스킹 테이프 컬러 순환 (W) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn": "다꾸 데코 스티커 팩 순환 (S) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/RarityBtn": "수집 레어도 등급 순환 (R) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/PaperBtn": "일기장 속지 패턴 순환 (P) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/StorageBtn": "실물 보관 위치 순환 (B) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/SourceBtn": "소장·입수 경로 순환 (A) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/MoodBtn": "독서·수집 기분 태그 순환 (M) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/StampRow/RereadBtn": "재독 횟수 +1 (Y / 우클릭·Shift+Y: -1 · Shift+좌클릭: -1)",
		"Panel/VBox/BodyMargin/Body/StampRow/DuplicateBtn": "복수 소장 수량 +1 (D / 우클릭·Shift+D: -1 · Shift+좌클릭: -1)",
		"Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn": "소장 상태 순환 (Z: 소장중·예약중·배송중·전시중) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/NibBtn": "만년필 펜촉 굵기 순환 (N: EF·M·B) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn": "다이어리 서명 스탬프 순환 · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn": "오늘 날짜로 구매·기념일 스탬프 갱신 · 우클릭: 기본값 초기화 · Shift+좌클릭: 구매일+전권 오늘 날짜 동기화",
		"Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn": "커스텀 해시태그 순환 (T) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/ValueBtn": "추정 소장 가치 +5,000원 (V / 우클릭·Shift+V: -5,000원 · Shift+좌클릭: -5,000원)",
		"Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn": "최애 캐릭터 태그 순환 (K) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn": "실물 컨디션 등급 순환 (G) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/FinishBtn": "표지 코팅 마감 순환 (F: 무광·유광·홀로그램·양장) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn": "독서·수집 날씨 스탬프 순환 (U) · 우클릭: 이전 · Shift+좌클릭: 이전",
		"Panel/VBox/BodyMargin/Body/InkRow/SpotBtn": "독서·수집 장소 스탬프 순환 (J) · 우클릭: 이전 · Shift+좌클릭: 이전"
	}
	for path in row_tips.keys():
		var tip_btn: Control = get_node_or_null(path)
		if tip_btn != null:
			tip_btn.tooltip_text = row_tips[path]
	var deco_rclick_map := {
		"Panel/VBox/BodyMargin/Body/StampRow/ObiCycleBtn": func() -> void: cycle_obi_preset(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/TapeCycleBtn": func() -> void: cycle_washi_tape(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn": func() -> void: cycle_deco_sticker(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/RarityBtn": func() -> void: cycle_rarity_tier(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/PaperBtn": func() -> void: cycle_paper_pattern(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/StorageBtn": func() -> void: cycle_storage_location(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/SourceBtn": func() -> void: cycle_acquisition_source(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/MoodBtn": func() -> void: cycle_reading_mood(-1),
		"Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn": func() -> void: cycle_possession_state(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/NibBtn": func() -> void: cycle_pen_nib_size(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn": func() -> void: cycle_diary_signature(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn": reset_purchase_date,
		"Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn": func() -> void: cycle_custom_tag(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn": func() -> void: cycle_favorite_character(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn": func() -> void: cycle_condition_grade(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/FinishBtn": func() -> void: cycle_cover_finish(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn": func() -> void: cycle_reading_weather(-1),
		"Panel/VBox/BodyMargin/Body/InkRow/SpotBtn": func() -> void: cycle_reading_spot(-1)
	}
	for deco_path in deco_rclick_map.keys():
		var deco_ctrl: Control = get_node_or_null(deco_path)
		if deco_ctrl != null:
			var deco_cb: Callable = deco_rclick_map[deco_path]
			var allow_shift_rev: bool = (deco_path != "Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
			deco_ctrl.gui_input.connect(func(ev: InputEvent) -> void:
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_RIGHT:
						deco_cb.call()
					elif allow_shift_rev and ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
						deco_ctrl.accept_event()
						deco_cb.call()
			)
	var date_stamp_ctrl: Control = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
	if date_stamp_ctrl != null:
		date_stamp_ctrl.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
				date_stamp_ctrl.accept_event()
				stamp_purchase_date()
				stamp_all_volumes_date()
		)
	var rr_btn: Control = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RereadBtn")
	if rr_btn != null:
		rr_btn.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					decrement_reread_count()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					rr_btn.accept_event()
					decrement_reread_count()
		)
	var dup_btn_ctrl: Control = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DuplicateBtn")
	if dup_btn_ctrl != null:
		dup_btn_ctrl.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					decrement_duplicate_count()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					dup_btn_ctrl.accept_event()
					decrement_duplicate_count()
		)
	var val_btn_ctrl: Control = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/ValueBtn")
	if val_btn_ctrl != null:
		val_btn_ctrl.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					reduce_estimated_value()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					val_btn_ctrl.accept_event()
					reduce_estimated_value()
		)

func set_fountain_pen_ink(ink_hex: String) -> void:
	if current_item == null:
		return
	current_item.memo_ink_color = ink_hex
	_apply_ink_style()
	diary_updated.emit(current_item)

func cycle_fountain_pen_ink(step: int = 1) -> String:
	if current_item == null:
		return ""
	var inks: Array[String] = ["#2c221e", "#7f1d1d", "#78350f", "#14532d"]
	var idx: int = inks.find(current_item.memo_ink_color)
	var next_hex: String = inks[0] if idx == -1 else inks[(idx + step + inks.size()) % inks.size()]
	set_fountain_pen_ink(next_hex)
	return next_hex

func toggle_quote_highlight() -> void:
	if current_item == null:
		return
	current_item.highlight_enabled = !current_item.highlight_enabled
	_apply_ink_style()
	diary_updated.emit(current_item)

func cycle_pen_nib_size(step: int = 1) -> int:
	if current_item == null:
		return 11
	const NIB_SIZES = [10, 12, 14]
	var cur = int(current_item.get("pen_nib_size")) if current_item.get("pen_nib_size") != null else 11
	var idx = NIB_SIZES.find(cur)
	if idx == -1:
		current_item.pen_nib_size = NIB_SIZES[0]
	else:
		current_item.pen_nib_size = NIB_SIZES[(idx + step + NIB_SIZES.size()) % NIB_SIZES.size()]
	_apply_ink_style()
	diary_updated.emit(current_item)
	return current_item.pen_nib_size

func copy_book_quote_card() -> String:
	if current_item == null:
		return ""
	var lines: Array = []
	lines.append("[📔 주희의 다꾸 서재 — 독서 감상 카드]")
	lines.append("📖 작품: " + current_item.title + " (" + current_item.author_or_series + ")")
	var avg_str = String.num(current_item.get_average_rating(), 1) if current_item.has_method("get_average_rating") else "5.0"
	var val_amt = current_item.get_item_value() if current_item.has_method("get_item_value") else 5000
	lines.append("💮 스탬프: " + current_item.status_tag + " | 평점: ★" + avg_str + " | 💎 " + ArchiveStateClass.format_krw(val_amt))
	lines.append("🖋️ \"" + current_item.memo + "\"")
	if current_item.obi_text != "":
		lines.append("🏷️ 띠지: " + current_item.obi_text)
	var ct = current_item.get("custom_tag") if current_item.get("custom_tag") != null else "#소장각"
	var sig = current_item.get("diary_signature") if current_item.get("diary_signature") != null else "✍️ 주희의 서재"
	var cg = current_item.get("condition_grade") if current_item.get("condition_grade") != null else "✨ S급(최상)"
	var fc = current_item.get("favorite_character") if current_item.get("favorite_character") != null else "🌟 최애 캐릭터"
	var cf = current_item.get("cover_finish") if current_item.get("cover_finish") != null else "📜 무광 매트"
	var rw = current_item.get("reading_weather") if current_item.get("reading_weather") != null else "☀️ 맑은 오후"
	var rs = current_item.get("reading_spot") if current_item.get("reading_spot") != null else "🛋️ 이불 속"
	var extra_meta = ""
	if int(current_item.reread_count) > 1:
		extra_meta += " · 🔁" + str(current_item.reread_count) + "회독"
	if int(current_item.duplicate_count) > 1:
		extra_meta += " · 👯×" + str(current_item.duplicate_count)
	lines.append(ct + " · " + cg + " · " + cf + " · " + rw + " · " + rs + " · " + fc + extra_meta + " · " + sig)
	var card_text = "\n".join(lines)
	DisplayServer.clipboard_set(card_text)
	var share_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	if share_btn != null:
		share_btn.text = "✅ 복사됨!"
	card_copied.emit(current_item)
	return card_text

func _apply_ink_style() -> void:
	if current_item == null:
		return
	var ink = Color.from_string(current_item.memo_ink_color, Color(0.18, 0.14, 0.11))
	if memo_label != null:
		memo_label.add_theme_color_override("font_color", ink)
		var nib = current_item.get("pen_nib_size") if current_item.get("pen_nib_size") != null else 11
		memo_label.add_theme_font_size_override("font_size", int(nib))
		if current_item.highlight_enabled:
			var hl_sb = StyleBoxFlat.new()
			hl_sb.bg_color = Color(1.0, 0.94, 0.70, 0.75) # Warm pastel highlighter yellow
			hl_sb.corner_radius_top_left = 4
			hl_sb.corner_radius_top_right = 4
			hl_sb.corner_radius_bottom_left = 4
			hl_sb.corner_radius_bottom_right = 4
			hl_sb.content_margin_left = 6
			hl_sb.content_margin_right = 6
			hl_sb.content_margin_top = 2
			hl_sb.content_margin_bottom = 2
			memo_label.add_theme_stylebox_override("normal", hl_sb)
		else:
			memo_label.remove_theme_stylebox_override("normal")
	if quote_input != null:
		quote_input.add_theme_color_override("font_color", ink)
	_highlight_active_ink_btn(current_item.memo_ink_color)
	var hl_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/QuoteEditRow/HighlightBtn")
	if hl_btn != null:
		var hl_on := bool(current_item.highlight_enabled)
		hl_btn.text = "🖍️ 형광펜 ON" if hl_on else "🖍️ 형광펜"
		var h_sb = StyleBoxFlat.new()
		h_sb.bg_color = Color(1.0, 0.94, 0.70, 1.0) if hl_on else Color(0.95, 0.91, 0.84, 1.0)
		h_sb.border_width_left = 2 if hl_on else 1
		h_sb.border_width_top = 2 if hl_on else 1
		h_sb.border_width_right = 2 if hl_on else 1
		h_sb.border_width_bottom = 2 if hl_on else 1
		h_sb.border_color = Color(0.82, 0.60, 0.12, 1.0) if hl_on else Color(0.80, 0.72, 0.62, 1.0)
		h_sb.corner_radius_top_left = 6
		h_sb.corner_radius_top_right = 6
		h_sb.corner_radius_bottom_left = 6
		h_sb.corner_radius_bottom_right = 6
		hl_btn.add_theme_stylebox_override("normal", h_sb)
		hl_btn.add_theme_color_override("font_color", Color(0.45, 0.28, 0.05, 1.0) if hl_on else Color(0.55, 0.38, 0.12))

func _highlight_active_ink_btn(active_hex: String) -> void:
	var ink_row: HFlowContainer = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow")
	if ink_row == null:
		return
	for node_name in INK_SWATCH_MAP.keys():
		var btn: Button = ink_row.get_node_or_null(node_name)
		if btn == null:
			continue
		var hex: String = INK_SWATCH_MAP[node_name]
		var is_active: bool = (active_hex.to_lower() == hex)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.98, 0.94, 0.87, 1) if is_active else Color(0.95, 0.91, 0.84, 1)
		sb.border_width_left = 2 if is_active else 1
		sb.border_width_top = 2 if is_active else 1
		sb.border_width_right = 2 if is_active else 1
		sb.border_width_bottom = 2 if is_active else 1
		sb.border_color = Color.from_string(hex, Color(0.28, 0.22, 0.18)) if is_active else Color(0.80, 0.72, 0.62, 1)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_color_override("font_color", Color.from_string(hex, Color(0.28, 0.22, 0.18)) if is_active else Color(0.28, 0.22, 0.18))

func open(item) -> void:
	current_item = item
	editing_vol_index = -1
	var share_btn_reset: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	if share_btn_reset != null:
		share_btn_reset.text = "💌 공유"
	delete_armed = false
	_apply_delete_btn_style(false)
	if save_quote_btn != null:
		save_quote_btn.text = "🖋️ 밑줄 저장"
	if quote_input != null:
		quote_input.release_focus()
		quote_input.placeholder_text = "🖋️ 오늘 밑줄 친 명대사·감상평 수정..."
	title_label.text = "📔 " + item.title
	title_label.tooltip_text = "좌클릭: 작품 제목 클립보드 복사 · 우클릭: 감상 카드 전체 복사 (C)"
	if author_label != null:
		author_label.tooltip_text = "좌클릭: 이 작가·시리즈의 다른 작품 검색하기 · Shift+좌클릭: 작가명 복사 · 우클릭: 가치 +5,000원(Shift: -5,000원)"
	if tag_label != null:
		tag_label.tooltip_text = "좌클릭: 띠지 문구 다음 순환 (O) · 우클릭: 이전 순환 (Shift+O) · Shift+좌클릭: 태그 복사"
	if memo_label != null:
		memo_label.tooltip_text = "좌클릭: 밑줄 문장 편집 입력창 이동 (E) · 우클릭: 형광펜 토글 (L) · Shift+좌클릭: 감상평 복사"
	_refresh_author_label()
	var sticker = current_item.get("deco_sticker") if current_item.get("deco_sticker") != null else "✨"
	var r_tier = current_item.get("rarity_tier") if current_item.get("rarity_tier") != null else "🌟노말"
	var loc = current_item.get("storage_location") if current_item.get("storage_location") != null else "🗄️ 1층 장식장"
	var src = current_item.get("acquisition_source") if current_item.get("acquisition_source") != null else "🏪 오프라인 서점"
	var mood = current_item.get("reading_mood") if current_item.get("reading_mood") != null else "🥰 힐링"
	_refresh_tag_label()
	memo_label.text = sticker + " 🖋️ \"" + (item.memo if item.memo != "" else "오늘 읽은 페이지의 감동을 일기장에 기록합니다.") + "\""
	quote_input.text = item.memo
	var deco_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn")
	if deco_btn != null:
		deco_btn.text = sticker + "스티커"
	var r_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RarityBtn")
	if r_btn != null:
		r_btn.text = r_tier
	var loc_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/StorageBtn")
	if loc_btn != null:
		loc_btn.text = loc
	var src_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/SourceBtn")
	if src_btn != null:
		src_btn.text = src
	var mood_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/MoodBtn")
	if mood_btn != null:
		mood_btn.text = mood
	var reread_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RereadBtn")
	if reread_btn != null:
		var rc = current_item.get("reread_count") if current_item.get("reread_count") != null else 1
		reread_btn.text = "🔁" + str(rc) + "회독"
	var dup_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DuplicateBtn")
	if dup_btn != null:
		var dc = current_item.get("duplicate_count") if current_item.get("duplicate_count") != null else 1
		dup_btn.text = "👯×" + str(dc)
	var sig_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn")
	if sig_btn != null:
		var sig = current_item.get("diary_signature") if current_item.get("diary_signature") != null else "✍️ 주희의 서재"
		sig_btn.text = sig
	var pos_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn")
	if pos_btn != null:
		var ps = current_item.get("possession_state") if current_item.get("possession_state") != null else "📦 소장중"
		pos_btn.text = ps
	var date_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
	if date_btn != null:
		var pd = current_item.get("purchase_date") if (current_item.get("purchase_date") != null and current_item.get("purchase_date") != "") else "📅 기념일"
		date_btn.text = pd
	var tag_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn")
	if tag_btn != null:
		var ct = current_item.get("custom_tag") if (current_item.get("custom_tag") != null and current_item.get("custom_tag") != "") else "#소장각"
		tag_btn.text = ct
	var fc_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn")
	if fc_btn != null:
		var fc = current_item.get("favorite_character") if (current_item.get("favorite_character") != null and current_item.get("favorite_character") != "") else "🌟 최애 캐릭터"
		fc_btn.text = fc
	var cond_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn")
	if cond_btn != null:
		var cg = current_item.get("condition_grade") if (current_item.get("condition_grade") != null and current_item.get("condition_grade") != "") else "✨ S급(최상)"
		cond_btn.text = cg
	var fin_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/FinishBtn")
	if fin_btn != null:
		var cf = current_item.get("cover_finish") if (current_item.get("cover_finish") != null and current_item.get("cover_finish") != "") else "📜 무광 매트"
		fin_btn.text = cf
	var w_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	if w_btn != null:
		var rw = current_item.get("reading_weather") if (current_item.get("reading_weather") != null and current_item.get("reading_weather") != "") else "☀️ 맑은 오후"
		w_btn.text = rw
	var sp_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SpotBtn")
	if sp_btn != null:
		var rs = current_item.get("reading_spot") if (current_item.get("reading_spot") != null and current_item.get("reading_spot") != "") else "🛋️ 이불 속"
		sp_btn.text = rs
	_apply_paper_style()
	_apply_ink_style()
	_apply_washi_style()
	_highlight_active_stamp_btn(item.status_tag)
	
	cover_rect.color = Color.from_string(item.cover_color, Color(0.65, 0.25, 0.2))
	_apply_cover_finish_style()
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

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		if quote_input != null and quote_input.has_focus():
			quote_input.release_focus()
		elif delete_armed:
			delete_armed = false
			_apply_delete_btn_style(false)
		else:
			close()
		get_viewport().set_input_as_handled()
	elif quote_input == null or not quote_input.has_focus():
		if event.keycode == KEY_LEFT:
			navigate_requested.emit(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT:
			navigate_requested.emit(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_HOME:
			navigate_requested.emit(-9999)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_END:
			navigate_requested.emit(9999)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_PAGEDOWN:
			navigate_requested.emit(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_PAGEUP:
			navigate_requested.emit(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			navigate_requested.emit(-1 if event.shift_pressed else 1)
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_EQUAL, KEY_PLUS, KEY_KP_ADD]:
			_on_add_vol_btn_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]:
			remove_last_volume()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_H:
			help_requested.emit()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E:
			if quote_input != null:
				quote_input.grab_focus()
				quote_input.caret_column = quote_input.text.length()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4]:
			var stamp_map := {
				KEY_1: "전권완결",
				KEY_2: "초판특전",
				KEY_3: "인생최애",
				KEY_4: "위시리스트",
			}
			apply_stamp(stamp_map[event.keycode])
			get_viewport().set_input_as_handled()
		else:
			var shift_pairs := {
				KEY_V: [boost_estimated_value, reduce_estimated_value],
				KEY_D: [increment_duplicate_count, decrement_duplicate_count],
				KEY_Y: [increment_reread_count, decrement_reread_count],
				KEY_C: [copy_book_quote_card, func() -> void: summary_copy_requested.emit()],
			}
			if shift_pairs.has(event.keycode):
				var pair: Array = shift_pairs[event.keycode]
				var fn: Callable = pair[1] if event.shift_pressed else pair[0]
				fn.call()
				get_viewport().set_input_as_handled()
				return
			var step_cyclers := {
				KEY_I: cycle_fountain_pen_ink,
				KEY_Q: cycle_cover_color,
				KEY_X: cycle_cover_icon,
				KEY_W: cycle_washi_tape,
				KEY_P: cycle_paper_pattern,
				KEY_S: cycle_deco_sticker,
				KEY_R: cycle_rarity_tier,
				KEY_O: cycle_obi_preset,
				KEY_M: cycle_reading_mood,
				KEY_G: cycle_condition_grade,
				KEY_T: cycle_custom_tag,
				KEY_F: cycle_cover_finish,
				KEY_A: cycle_acquisition_source,
				KEY_N: cycle_pen_nib_size,
				KEY_B: cycle_storage_location,
				KEY_K: cycle_favorite_character,
				KEY_U: cycle_reading_weather,
				KEY_J: cycle_reading_spot,
				KEY_Z: cycle_possession_state,
			}
			if step_cyclers.has(event.keycode):
				step_cyclers[event.keycode].call(-1 if event.shift_pressed else 1)
				get_viewport().set_input_as_handled()
				return
			var simple_actions := {
				KEY_L: toggle_quote_highlight,
				KEY_DELETE: _on_delete_btn_pressed,
				KEY_BACKSPACE: _on_delete_btn_pressed,
			}
			if simple_actions.has(event.keycode):
				simple_actions[event.keycode].call()
				get_viewport().set_input_as_handled()

func apply_stamp(stamp_name: String) -> void:
	if current_item == null:
		return
	current_item.status_tag = stamp_name
	_refresh_tag_label()
	_highlight_active_stamp_btn(stamp_name)
	diary_updated.emit(current_item)

func _highlight_active_stamp_btn(active_stamp: String) -> void:
	if stamp_row == null:
		return
	for node_name in STAMP_PRESET_MAP.keys():
		var btn: Button = stamp_row.get_node_or_null(node_name)
		if btn == null:
			continue
		var is_active: bool = (active_stamp == STAMP_PRESET_MAP[node_name])
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(1.0, 0.92, 0.88, 1.0) if is_active else Color(0.99, 0.96, 0.94, 1.0)
		sb.border_width_left = 2 if is_active else 1
		sb.border_width_top = 2 if is_active else 1
		sb.border_width_right = 2 if is_active else 1
		sb.border_width_bottom = 2 if is_active else 1
		sb.border_color = Color(0.78, 0.35, 0.20, 1.0) if is_active else Color(0.78, 0.35, 0.20, 0.65)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)

func cycle_rarity_tier(step: int = 1) -> String:
	if current_item == null:
		return "🌟노말"
	var r = current_item.cycle_rarity_tier(step) if current_item.has_method("cycle_rarity_tier") else "🌟노말"
	var r_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RarityBtn")
	if r_btn != null:
		r_btn.text = r
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return r

func cycle_deco_sticker(step: int = 1) -> String:
	if current_item == null:
		return "✨"
	var s = current_item.cycle_deco_sticker(step) if current_item.has_method("cycle_deco_sticker") else "✨"
	var deco_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn")
	if deco_btn != null:
		deco_btn.text = s + "스티커"
	_refresh_tag_label()
	memo_label.text = s + " 🖋️ \"" + (current_item.memo if current_item.memo != "" else "오늘 읽은 페이지의 감동을 일기장에 기록합니다.") + "\""
	_apply_ink_style()
	diary_updated.emit(current_item)
	return s

func cycle_paper_pattern(step: int = 1) -> String:
	if current_item == null:
		return "ruled"
	var p = current_item.cycle_paper_pattern(step) if current_item.has_method("cycle_paper_pattern") else "ruled"
	_apply_paper_style()
	diary_updated.emit(current_item)
	return p

func _apply_paper_style() -> void:
	if current_item == null:
		return
	var p = current_item.get("paper_pattern") if current_item.get("paper_pattern") != null else "ruled"
	var p_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/PaperBtn")
	if p_btn != null:
		match p:
			"grid": p_btn.text = "📜모눈"
			"blank": p_btn.text = "📋무지"
			"vintage": p_btn.text = "🍂양장"
			_: p_btn.text = "📄줄노트"

func cycle_storage_location(step: int = 1) -> String:
	if current_item == null:
		return "🗄️ 1층 장식장"
	var s = current_item.cycle_storage_location(step) if current_item.has_method("cycle_storage_location") else "🗄️ 1층 장식장"
	var s_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/StorageBtn")
	if s_btn != null:
		s_btn.text = s
	_refresh_tag_label()
	if current_item.category == 1:
		_refresh_vol_header()
	diary_updated.emit(current_item)
	return s

func cycle_acquisition_source(step: int = 1) -> String:
	if current_item == null:
		return "🏪 오프라인 서점"
	var src = current_item.cycle_acquisition_source(step) if current_item.has_method("cycle_acquisition_source") else "🏪 오프라인 서점"
	var src_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/SourceBtn")
	if src_btn != null:
		src_btn.text = src
	_refresh_tag_label()
	if current_item.category == 1:
		_refresh_vol_header()
	diary_updated.emit(current_item)
	return src

func cycle_reading_mood(step: int = 1) -> String:
	if current_item == null:
		return "🥰 힐링"
	var m = current_item.cycle_reading_mood(step) if current_item.has_method("cycle_reading_mood") else "🥰 힐링"
	var m_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/MoodBtn")
	if m_btn != null:
		m_btn.text = m
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return m

func increment_reread_count() -> int:
	if current_item == null:
		return 1
	var rc = current_item.increment_reread_count() if current_item.has_method("increment_reread_count") else 1
	var reread_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RereadBtn")
	if reread_btn != null:
		reread_btn.text = "🔁" + str(rc) + "회독"
	diary_updated.emit(current_item)
	return rc

func decrement_reread_count() -> int:
	if current_item == null:
		return 1
	current_item.reread_count = max(1, int(current_item.reread_count) - 1)
	var reread_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RereadBtn")
	if reread_btn != null:
		reread_btn.text = "🔁" + str(current_item.reread_count) + "회독"
	diary_updated.emit(current_item)
	return current_item.reread_count

func increment_duplicate_count() -> int:
	if current_item == null:
		return 1
	var dc = current_item.increment_duplicate_count() if current_item.has_method("increment_duplicate_count") else 1
	var dup_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DuplicateBtn")
	if dup_btn != null:
		dup_btn.text = "👯×" + str(dc)
	_refresh_author_label()
	diary_updated.emit(current_item)
	return dc

func decrement_duplicate_count() -> int:
	if current_item == null:
		return 1
	current_item.duplicate_count = max(1, int(current_item.duplicate_count) - 1)
	var dup_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DuplicateBtn")
	if dup_btn != null:
		dup_btn.text = "👯×" + str(current_item.duplicate_count)
	_refresh_author_label()
	diary_updated.emit(current_item)
	return current_item.duplicate_count

func cycle_diary_signature(step: int = 1) -> String:
	if current_item == null:
		return "✍️ 주희의 서재"
	var sig = current_item.cycle_diary_signature(step) if current_item.has_method("cycle_diary_signature") else "✍️ 주희의 서재"
	var sig_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn")
	if sig_btn != null:
		sig_btn.text = sig
	diary_updated.emit(current_item)
	return sig

func cycle_possession_state(step: int = 1) -> String:
	if current_item == null:
		return "📦 소장중"
	var ps = current_item.cycle_possession_state(step) if current_item.has_method("cycle_possession_state") else "📦 소장중"
	var pos_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn")
	if pos_btn != null:
		pos_btn.text = ps
	diary_updated.emit(current_item)
	return ps

func stamp_purchase_date() -> String:
	if current_item == null:
		return "📅 기념일"
	var pd = current_item.stamp_purchase_date() if current_item.has_method("stamp_purchase_date") else "📅 11.15"
	var date_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
	if date_btn != null:
		date_btn.text = pd
	diary_updated.emit(current_item)
	return pd

func reset_purchase_date() -> String:
	if current_item == null:
		return "📅 기념일"
	current_item.purchase_date = "📅 기념일"
	var date_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
	if date_btn != null:
		date_btn.text = "📅 기념일"
	diary_updated.emit(current_item)
	return "📅 기념일"

func cycle_custom_tag(step: int = 1) -> String:
	if current_item == null:
		return "#소장각"
	var ct = current_item.cycle_custom_tag(step) if current_item.has_method("cycle_custom_tag") else "#소장각"
	var tag_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn")
	if tag_btn != null:
		tag_btn.text = ct
	diary_updated.emit(current_item)
	return ct

func _refresh_author_label() -> void:
	if current_item == null or author_label == null:
		return
	var val_amt = current_item.get_item_value() if current_item.has_method("get_item_value") else 5000
	var avg_str = String.num(current_item.get_average_rating(), 1) if current_item.has_method("get_average_rating") else "5.0"
	author_label.text = "작가 · " + (current_item.author_or_series if current_item.author_or_series != "" else "미상") + " · ★" + avg_str + " · 💎 " + ArchiveStateClass.format_krw(val_amt)

func boost_estimated_value() -> int:
	if current_item == null:
		return 0
	var new_val = current_item.boost_estimated_value(5000) if current_item.has_method("boost_estimated_value") else 5000
	_refresh_author_label()
	diary_updated.emit(current_item)
	return new_val

func reduce_estimated_value() -> int:
	if current_item == null:
		return 0
	current_item.estimated_value = max(0, int(current_item.estimated_value) - 5000)
	_refresh_author_label()
	diary_updated.emit(current_item)
	return current_item.estimated_value

func cycle_favorite_character(step: int = 1) -> String:
	if current_item == null:
		return "🌟 최애 캐릭터"
	var fc = current_item.cycle_favorite_character(step) if current_item.has_method("cycle_favorite_character") else "🌟 최애 캐릭터"
	var fc_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn")
	if fc_btn != null:
		fc_btn.text = fc
	diary_updated.emit(current_item)
	return fc

func cycle_condition_grade(step: int = 1) -> String:
	if current_item == null:
		return "✨ S급(최상)"
	var cg = current_item.cycle_condition_grade(step) if current_item.has_method("cycle_condition_grade") else "✨ S급(최상)"
	var cond_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn")
	if cond_btn != null:
		cond_btn.text = cg
	if current_item.category == 1:
		_refresh_vol_header()
	diary_updated.emit(current_item)
	return cg

func cycle_cover_finish(step: int = 1) -> String:
	if current_item == null:
		return "📜 무광 매트"
	var cf = current_item.cycle_cover_finish(step) if current_item.has_method("cycle_cover_finish") else "📜 무광 매트"
	var fin_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/FinishBtn")
	if fin_btn != null:
		fin_btn.text = cf
	_apply_cover_finish_style()
	diary_updated.emit(current_item)
	return cf

func _apply_cover_finish_style() -> void:
	if current_item == null or cover_rect == null:
		return
	var base_c = Color.from_string(current_item.cover_color, Color(0.65, 0.25, 0.2))
	var cf = current_item.get("cover_finish") if current_item.get("cover_finish") != null else "📜 무광 매트"
	if cf == "🌟 홀로그램":
		cover_rect.color = base_c.lightened(0.12)
	elif cf == "✨ 유광 코팅":
		cover_rect.color = base_c.lightened(0.06)
	elif cf == "🧶 패브릭 양장":
		cover_rect.color = base_c.darkened(0.08)
	else:
		cover_rect.color = base_c

func _refresh_tag_label() -> void:
	if current_item == null or tag_label == null:
		return
	var sticker = current_item.get("deco_sticker") if current_item.get("deco_sticker") != null else "✨"
	var r_tier = current_item.get("rarity_tier") if current_item.get("rarity_tier") != null else "🌟노말"
	var loc = current_item.get("storage_location") if current_item.get("storage_location") != null else "🗄️ 1층 장식장"
	var mood = current_item.get("reading_mood") if current_item.get("reading_mood") != null else "🥰 힐링"
	var rw = current_item.get("reading_weather") if (current_item.get("reading_weather") != null and current_item.get("reading_weather") != "") else "☀️ 맑은 오후"
	var rs = current_item.get("reading_spot") if (current_item.get("reading_spot") != null and current_item.get("reading_spot") != "") else "🛋️ 이불 속"
	tag_label.text = "💮 " + current_item.status_tag + " " + sticker + " [" + mood + " · " + r_tier + " · " + loc + " · " + rw + " · " + rs + "] | " + current_item.obi_text

func cycle_reading_weather(step: int = 1) -> String:
	if current_item == null:
		return "☀️ 맑은 오후"
	var rw = current_item.cycle_reading_weather(step) if current_item.has_method("cycle_reading_weather") else "☀️ 맑은 오후"
	var w_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	if w_btn != null:
		w_btn.text = rw
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return rw

func cycle_reading_spot(step: int = 1) -> String:
	if current_item == null:
		return "🛋️ 이불 속"
	var rs = current_item.cycle_reading_spot(step) if current_item.has_method("cycle_reading_spot") else "🛋️ 이불 속"
	var sp_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SpotBtn")
	if sp_btn != null:
		sp_btn.text = rs
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return rs

func cycle_obi_preset(step: int = 1) -> void:
	if current_item == null:
		return
	obi_cursor = (obi_cursor + step + OBI_PRESETS.size()) % OBI_PRESETS.size()
	if OBI_PRESETS[obi_cursor] == current_item.obi_text:
		obi_cursor = (obi_cursor + step + OBI_PRESETS.size()) % OBI_PRESETS.size()
	current_item.obi_text = OBI_PRESETS[obi_cursor]
	_refresh_tag_label()
	diary_updated.emit(current_item)

func cycle_cover_icon(step: int = 1) -> void:
	if current_item == null:
		return
	icon_cursor = (icon_cursor + step + ICON_PRESETS.size()) % ICON_PRESETS.size()
	if ICON_PRESETS[icon_cursor] == current_item.icon_emoji:
		icon_cursor = (icon_cursor + step + ICON_PRESETS.size()) % ICON_PRESETS.size()
	current_item.icon_emoji = ICON_PRESETS[icon_cursor]
	cover_icon.text = current_item.icon_emoji
	diary_updated.emit(current_item)

func cycle_cover_color(step: int = 1) -> void:
	if current_item == null:
		return
	color_cursor = (color_cursor + step + COLOR_PRESETS.size()) % COLOR_PRESETS.size()
	if COLOR_PRESETS[color_cursor] == current_item.cover_color:
		color_cursor = (color_cursor + step + COLOR_PRESETS.size()) % COLOR_PRESETS.size()
	current_item.cover_color = COLOR_PRESETS[color_cursor]
	cover_rect.color = Color.from_string(current_item.cover_color, Color(0.65, 0.25, 0.2))
	diary_updated.emit(current_item)

func cycle_washi_tape(step: int = 1) -> String:
	if current_item == null:
		return "#f4d394"
	washi_cursor = (washi_cursor + step + WASHI_PRESETS.size()) % WASHI_PRESETS.size()
	if WASHI_PRESETS[washi_cursor] == current_item.get("washi_tape_color"):
		washi_cursor = (washi_cursor + step + WASHI_PRESETS.size()) % WASHI_PRESETS.size()
	current_item.washi_tape_color = WASHI_PRESETS[washi_cursor]
	_apply_washi_style()
	diary_updated.emit(current_item)
	return current_item.washi_tape_color

func _apply_washi_style() -> void:
	if current_item == null:
		return
	var washi_node: ColorRect = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	if washi_node != null:
		var c = Color.from_string(current_item.get("washi_tape_color"), Color(0.94, 0.82, 0.56, 0.85))
		c.a = 0.88
		washi_node.color = c

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

func start_editing_volume_quote(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	if editing_vol_index == vol_idx:
		editing_vol_index = -1
		if quote_input != null:
			quote_input.text = current_item.memo
			quote_input.placeholder_text = "🖋️ 오늘 밑줄 친 명대사·감상평 수정..."
		if save_quote_btn != null:
			save_quote_btn.text = "🖋️ 밑줄 저장"
		_render_volumes()
		return
	editing_vol_index = vol_idx
	var v = current_item.volumes[vol_idx]
	var vol_num = int(v.get("vol", vol_idx + 1))
	if quote_input != null:
		quote_input.text = str(v.get("quote", ""))
		quote_input.placeholder_text = "🖋️ %d권 밑줄 문장 편집 중..." % vol_num
		quote_input.grab_focus()
	if save_quote_btn != null:
		save_quote_btn.text = "🖋️ %d권 저장" % vol_num
	_render_volumes()

func _on_save_quote_btn_pressed() -> void:
	if current_item == null:
		return
	var trimmed = quote_input.text.strip_edges()
	if trimmed != "":
		if editing_vol_index >= 0 and editing_vol_index < current_item.volumes.size():
			update_volume_quote(editing_vol_index, trimmed)
			editing_vol_index = -1
			if save_quote_btn != null:
				save_quote_btn.text = "🖋️ 밑줄 저장"
			if quote_input != null:
				quote_input.placeholder_text = "🖋️ 오늘 밑줄 친 명대사·감상평 수정..."
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
	_refresh_author_label()
	diary_updated.emit(current_item)

func reverse_cycle_volume_rating(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var cur_r = int(current_item.volumes[vol_idx].get("rating", 5))
	var prev_r = 5 if cur_r <= 3 else (cur_r - 1)
	current_item.volumes[vol_idx]["rating"] = prev_r
	_render_volumes()
	_refresh_author_label()
	diary_updated.emit(current_item)

func stamp_volume_date(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var d = Time.get_date_dict_from_system()
	current_item.volumes[vol_idx]["date"] = "%04d.%02d.%02d" % [d.year, d.month, d.day]
	_render_volumes()
	diary_updated.emit(current_item)

func stamp_all_volumes_date() -> void:
	if current_item == null or current_item.volumes.is_empty():
		return
	var d = Time.get_date_dict_from_system()
	var today_str = "%04d.%02d.%02d" % [d.year, d.month, d.day]
	for v in current_item.volumes:
		v["date"] = today_str
	_render_volumes()
	diary_updated.emit(current_item)

func _refresh_vol_header() -> void:
	if current_item == null or vol_header == null:
		return
	if current_item.volumes.is_empty() and current_item.category == 1:
		vol_header.text = "🔮 가챠 · 굿즈 파츠 체크리스트 (" + current_item.storage_location + " · " + current_item.condition_grade + ")"
		return
	var first_cnt = 0
	for v in current_item.volumes:
		if v.get("status", "") == "first":
			first_cnt += 1
	var tgt_v = max(int(current_item.target_volumes), current_item.volumes.size())
	var pct_v = int(round(float(current_item.volumes.size()) / float(tgt_v) * 100.0))
	var bm_cnt = current_item.get_bookmarked_volumes_count() if current_item.has_method("get_bookmarked_volumes_count") else 0
	var bm_part = (" · 🔖" + str(bm_cnt)) if bm_cnt > 0 else ""
	vol_header.text = "📌 권별 밑줄 노트 (소장 " + str(current_item.volumes.size()) + "/" + str(tgt_v) + "권 · " + str(pct_v) + "% · 초판 " + str(first_cnt) + "권" + bm_part + ")"

func _render_volumes() -> void:
	for child in vol_list.get_children():
		vol_list.remove_child(child)
		child.queue_free()
	
	if current_item == null:
		return

	if current_item.volumes.is_empty():
		if current_item.category == 1:
			_refresh_vol_header()
			var gacha_notes = [
				"🔖 캡슐 미니북(보증서) 스크랩북 보관 완료",
				"✨ 아크릴 케이스 방진 전시 완료",
				"🎁 %s · %s · %s" % [current_item.acquisition_source, current_item.reading_mood, current_item.favorite_character]
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

	_refresh_vol_header()

	for idx in range(current_item.volumes.size()):
		var v = current_item.volumes[idx]
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		var is_editing_row := (idx == editing_vol_index)
		var is_bm_row := bool(v.get("bookmarked", false))
		sb.bg_color = Color(1.0, 0.96, 0.88, 1) if is_editing_row else (Color(0.99, 0.965, 0.91, 1) if is_bm_row else Color(0.97, 0.945, 0.90, 1))
		sb.border_width_left = 2 if is_editing_row else (3 if is_bm_row else 0)
		sb.border_width_top = 2 if is_editing_row else 0
		sb.border_width_right = 2 if is_editing_row else 0
		sb.border_width_bottom = 2 if is_editing_row else 1
		sb.border_color = Color(0.78, 0.35, 0.20, 0.85) if is_editing_row else (Color(0.85, 0.58, 0.16, 0.90) if is_bm_row else Color(0.86, 0.80, 0.72, 1))
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
		
		var capture_idx = idx
		var vol_lbl = Label.new()
		vol_lbl.text = str(int(v.get("vol", 1))) + "권"
		vol_lbl.add_theme_font_size_override("font_size", 12)
		vol_lbl.add_theme_color_override("font_color", Color(0.17, 0.13, 0.11))
		vol_lbl.custom_minimum_size = Vector2(28, 0)
		vol_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		vol_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		vol_lbl.tooltip_text = "좌클릭: %d권 밑줄 문장 편집 · 우클릭: 북마크 토글 · Shift+좌클릭: 초판+북마크+★5" % int(v.get("vol", idx + 1))
		vol_lbl.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					vol_lbl.accept_event()
					if current_item != null and capture_idx >= 0 and capture_idx < current_item.volumes.size():
						var target_v = current_item.volumes[capture_idx]
						target_v["status"] = "first"
						target_v["bookmarked"] = true
						target_v["rating"] = 5
						_render_volumes()
						_refresh_vol_header()
						_refresh_author_label()
						diary_updated.emit(current_item)
				elif ev.button_index == MOUSE_BUTTON_LEFT:
					start_editing_volume_quote(capture_idx)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					toggle_volume_bookmark(capture_idx)
		)
		
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
		status_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		status_btn.tooltip_text = "클릭하여 초판특전 / 소장완료 전환 (우클릭: 초판+북마크 동시 토글 · Shift+좌클릭: 전권 일괄 전환)"
		status_btn.pressed.connect(func(): toggle_volume_status(capture_idx))
		status_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					toggle_volume_status(capture_idx)
					toggle_volume_bookmark(capture_idx)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed and current_item != null and capture_idx < current_item.volumes.size():
					status_btn.accept_event()
					var next_st: String = "owned" if current_item.volumes[capture_idx].get("status", "") == "first" else "first"
					for vol_d in current_item.volumes:
						vol_d["status"] = next_st
					_render_volumes()
					_refresh_vol_header()
					diary_updated.emit(current_item)
		)
		
		var date_btn = Button.new()
		var d_val = str(v.get("date", "2026.11.12"))
		var short_d = d_val.substr(5) if d_val.length() >= 10 else d_val
		date_btn.text = "📅 " + short_d
		date_btn.add_theme_font_size_override("font_size", 9)
		var date_sb = StyleBoxFlat.new()
		date_sb.bg_color = Color(0.95, 0.92, 0.86, 0.8)
		date_sb.border_width_bottom = 1
		date_sb.border_color = Color(0.8, 0.72, 0.62, 0.8)
		date_sb.corner_radius_top_left = 4
		date_sb.corner_radius_top_right = 4
		date_sb.corner_radius_bottom_left = 4
		date_sb.corner_radius_bottom_right = 4
		date_btn.add_theme_stylebox_override("normal", date_sb)
		date_btn.add_theme_color_override("font_color", Color(0.48, 0.38, 0.3))
		date_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		date_btn.tooltip_text = "클릭하여 오늘 날짜로 읽은 날 스탬프 갱신 · 우클릭: 이 권 대사 복사 · Shift+좌클릭: 전권 오늘 날짜 일괄 스탬프"
		date_btn.pressed.connect(func(): stamp_volume_date(capture_idx))
		date_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					if current_item != null and capture_idx >= 0 and capture_idx < current_item.volumes.size():
						var v_data = current_item.volumes[capture_idx]
						var q_str = str(v_data.get("quote", ""))
						var copy_str = "%s %d권: \"%s\"" % [current_item.title, int(v_data.get("vol", capture_idx + 1)), q_str if q_str != "" else current_item.memo]
						DisplayServer.clipboard_set(copy_str)
						date_btn.text = "✅ 복사됨"
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					stamp_all_volumes_date()
					date_btn.accept_event()
		)

		var bm_btn = Button.new()
		var is_bm = bool(v.get("bookmarked", false))
		bm_btn.text = "🔖" if is_bm else "🏷️"
		bm_btn.flat = true
		bm_btn.add_theme_font_size_override("font_size", 10)
		bm_btn.add_theme_color_override("font_color", Color(0.85, 0.55, 0.15) if is_bm else Color(0.65, 0.58, 0.50))
		bm_btn.tooltip_text = "이 권을 북마크에 추가/해제합니다 (우클릭: 이 권 밑줄 편집 · Shift+좌클릭: 초판+북마크)"
		bm_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		bm_btn.pressed.connect(func(): toggle_volume_bookmark(capture_idx))
		bm_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					start_editing_volume_quote(capture_idx)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed and current_item != null and capture_idx < current_item.volumes.size():
					bm_btn.accept_event()
					current_item.volumes[capture_idx]["status"] = "first"
					current_item.volumes[capture_idx]["bookmarked"] = true
					_render_volumes()
					_refresh_vol_header()
					diary_updated.emit(current_item)
		)

		var quote_lbl = Label.new()
		var q = v.get("quote", "")
		quote_lbl.text = "🖋️ \"" + q + "\"" if q != "" else "🖋️ 읽고 남긴 한 줄 일기"
		quote_lbl.add_theme_font_size_override("font_size", 10)
		quote_lbl.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
		quote_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		quote_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		quote_lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		quote_lbl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		quote_lbl.tooltip_text = "클릭하여 %d권 밑줄 문장 편집 · 우클릭: 밑줄 문장 복사 · Shift+좌클릭: 복사+북마크" % int(v.get("vol", idx + 1))
		quote_lbl.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed and current_item != null:
					quote_lbl.accept_event()
					if capture_idx >= 0 and capture_idx < current_item.volumes.size():
						var target_v = current_item.volumes[capture_idx]
						var v_quote_str: String = str(target_v.get("quote", ""))
						DisplayServer.clipboard_set("%s %d권: \"%s\"" % [current_item.title, int(target_v.get("vol", capture_idx + 1)), v_quote_str])
						target_v["bookmarked"] = true
						_render_volumes()
						_refresh_vol_header()
						diary_updated.emit(current_item)
				elif ev.button_index == MOUSE_BUTTON_LEFT:
					start_editing_volume_quote(capture_idx)
				elif ev.button_index == MOUSE_BUTTON_RIGHT and current_item != null:
					var v_quote_str: String = str(v.get("quote", ""))
					DisplayServer.clipboard_set("%s %d권: \"%s\"" % [current_item.title, int(v.get("vol", idx + 1)), v_quote_str])
					quote_lbl.tooltip_text = "✅ 복사됨: " + v_quote_str
		)
		
		var star_btn = Button.new()
		var r = int(v.get("rating", 5))
		star_btn.text = "★".repeat(r)
		star_btn.flat = true
		star_btn.add_theme_font_size_override("font_size", 11)
		star_btn.add_theme_color_override("font_color", Color(0.78, 0.35, 0.2))
		star_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		star_btn.tooltip_text = "클릭: 별점 순환 · 우클릭: 역순환 (★★★~★★★★★) · Shift+좌클릭: ★5+북마크"
		star_btn.pressed.connect(func(): cycle_volume_rating(capture_idx))
		star_btn.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					reverse_cycle_volume_rating(capture_idx)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed and current_item != null and capture_idx < current_item.volumes.size():
					star_btn.accept_event()
					current_item.volumes[capture_idx]["rating"] = 5
					current_item.volumes[capture_idx]["bookmarked"] = true
					_render_volumes()
					_refresh_author_label()
					_refresh_vol_header()
					diary_updated.emit(current_item)
		)
		
		hbox.add_child(vol_lbl)
		hbox.add_child(status_btn)
		hbox.add_child(date_btn)
		hbox.add_child(bm_btn)
		hbox.add_child(quote_lbl)
		hbox.add_child(star_btn)
		margin.add_child(hbox)
		panel.add_child(margin)
		vol_list.add_child(panel)

func toggle_volume_bookmark(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var cur = bool(current_item.volumes[vol_idx].get("bookmarked", false))
	current_item.volumes[vol_idx]["bookmarked"] = not cur
	_render_volumes()
	diary_updated.emit(current_item)

func _on_close_btn_pressed() -> void:
	close()

func _on_ink_espresso_pressed() -> void:
	set_fountain_pen_ink("#2c221e")

func _on_ink_burgundy_pressed() -> void:
	set_fountain_pen_ink("#7f1d1d")

func _on_ink_sepia_pressed() -> void:
	set_fountain_pen_ink("#78350f")

func _on_ink_forest_pressed() -> void:
	set_fountain_pen_ink("#14532d")

func _on_add_vol_btn_pressed() -> void:
	if current_item != null:
		var next_num = current_item.volumes.size() + 1
		current_item.add_volume(next_num, "first", 5, str(next_num) + "권 읽고 밑줄 친 오늘의 문장")
		_render_volumes()
		_refresh_author_label()
		volume_added.emit(current_item)

func remove_last_volume() -> void:
	if current_item != null and current_item.volumes.size() > 0:
		current_item.volumes.pop_back()
		_render_volumes()
		_refresh_author_label()
		volume_removed.emit(current_item)

func _apply_delete_btn_style(armed: bool) -> void:
	var del_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn")
	if del_btn == null:
		return
	del_btn.text = "⚠️ 삭제 확인" if armed else "일기 삭제"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.85, 0.22, 0.18, 1.0) if armed else Color(0.95, 0.91, 0.84, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.65, 0.12, 0.10, 1.0) if armed else Color(0.80, 0.72, 0.62, 1.0)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	del_btn.add_theme_stylebox_override("normal", sb)
	del_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0) if armed else Color(0.78, 0.25, 0.20, 1.0))

func _on_delete_btn_pressed() -> void:
	if current_item == null:
		return
	if not delete_armed:
		delete_armed = true
		_apply_delete_btn_style(true)
		return
	delete_armed = false
	_apply_delete_btn_style(false)
	item_deleted.emit(current_item)
	close()
