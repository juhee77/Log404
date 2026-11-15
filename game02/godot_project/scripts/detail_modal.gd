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
@onready var stamp_row: HFlowContainer = $Panel/VBox/BodyMargin/Body/StampRow

var current_item = null
var editing_vol_index: int = -1
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
	cover_rect.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			cycle_cover_icon()
	)
	var washi_node: ColorRect = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	if washi_node != null:
		washi_node.mouse_filter = Control.MOUSE_FILTER_STOP
		washi_node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		washi_node.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				cycle_washi_tape()
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

	var share_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	if share_btn != null:
		share_btn.add_theme_stylebox_override("normal", cream_btn)
		share_btn.add_theme_color_override("font_color", Color(0.28, 0.45, 0.38))

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

func set_fountain_pen_ink(ink_hex: String) -> void:
	if current_item == null:
		return
	current_item.memo_ink_color = ink_hex
	_apply_ink_style()
	diary_updated.emit(current_item)

func toggle_quote_highlight() -> void:
	if current_item == null:
		return
	current_item.highlight_enabled = !current_item.highlight_enabled
	_apply_ink_style()
	diary_updated.emit(current_item)

func cycle_pen_nib_size() -> int:
	if current_item == null:
		return 11
	var cur = int(current_item.get("pen_nib_size")) if current_item.get("pen_nib_size") != null else 11
	if cur == 10:
		current_item.pen_nib_size = 12
	elif cur == 12:
		current_item.pen_nib_size = 14
	else:
		current_item.pen_nib_size = 10
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
	var s_v = str(val_amt)
	var fmt_v = ""
	var c_v = 0
	for i in range(s_v.length() - 1, -1, -1):
		if c_v > 0 and c_v % 3 == 0:
			fmt_v = "," + fmt_v
		fmt_v = s_v[i] + fmt_v
		c_v += 1
	lines.append("💮 스탬프: " + current_item.status_tag + " | 평점: ★" + avg_str + " | 💎 ₩" + fmt_v)
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
	lines.append(ct + " · " + cg + " · " + cf + " · " + rw + " · " + rs + " · " + fc + " · " + sig)
	var card_text = "\n".join(lines)
	DisplayServer.clipboard_set(card_text)
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

func open(item) -> void:
	current_item = item
	editing_vol_index = -1
	title_label.text = "📔 " + item.title
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

func apply_stamp(stamp_name: String) -> void:
	if current_item == null:
		return
	current_item.status_tag = stamp_name
	_refresh_tag_label()
	diary_updated.emit(current_item)

func cycle_rarity_tier() -> String:
	if current_item == null:
		return "🌟노말"
	var r = current_item.cycle_rarity_tier() if current_item.has_method("cycle_rarity_tier") else "🌟노말"
	var r_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/RarityBtn")
	if r_btn != null:
		r_btn.text = r
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return r

func cycle_deco_sticker() -> String:
	if current_item == null:
		return "✨"
	var s = current_item.cycle_deco_sticker() if current_item.has_method("cycle_deco_sticker") else "✨"
	var deco_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn")
	if deco_btn != null:
		deco_btn.text = s + "스티커"
	_refresh_tag_label()
	memo_label.text = s + " 🖋️ \"" + (current_item.memo if current_item.memo != "" else "오늘 읽은 페이지의 감동을 일기장에 기록합니다.") + "\""
	_apply_ink_style()
	diary_updated.emit(current_item)
	return s

func cycle_paper_pattern() -> String:
	if current_item == null:
		return "ruled"
	var p = current_item.cycle_paper_pattern() if current_item.has_method("cycle_paper_pattern") else "ruled"
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

func cycle_storage_location() -> String:
	if current_item == null:
		return "🗄️ 1층 장식장"
	var s = current_item.cycle_storage_location() if current_item.has_method("cycle_storage_location") else "🗄️ 1층 장식장"
	var s_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/StorageBtn")
	if s_btn != null:
		s_btn.text = s
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return s

func cycle_acquisition_source() -> String:
	if current_item == null:
		return "🏪 오프라인 서점"
	var src = current_item.cycle_acquisition_source() if current_item.has_method("cycle_acquisition_source") else "🏪 오프라인 서점"
	var src_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/SourceBtn")
	if src_btn != null:
		src_btn.text = src
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return src

func cycle_reading_mood() -> String:
	if current_item == null:
		return "🥰 힐링"
	var m = current_item.cycle_reading_mood() if current_item.has_method("cycle_reading_mood") else "🥰 힐링"
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

func cycle_diary_signature() -> String:
	if current_item == null:
		return "✍️ 주희의 서재"
	var sig = current_item.cycle_diary_signature() if current_item.has_method("cycle_diary_signature") else "✍️ 주희의 서재"
	var sig_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn")
	if sig_btn != null:
		sig_btn.text = sig
	diary_updated.emit(current_item)
	return sig

func cycle_possession_state() -> String:
	if current_item == null:
		return "📦 소장중"
	var ps = current_item.cycle_possession_state() if current_item.has_method("cycle_possession_state") else "📦 소장중"
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

func cycle_custom_tag() -> String:
	if current_item == null:
		return "#소장각"
	var ct = current_item.cycle_custom_tag() if current_item.has_method("cycle_custom_tag") else "#소장각"
	var tag_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn")
	if tag_btn != null:
		tag_btn.text = ct
	diary_updated.emit(current_item)
	return ct

func _refresh_author_label() -> void:
	if current_item == null or author_label == null:
		return
	var val_amt = current_item.get_item_value() if current_item.has_method("get_item_value") else 5000
	var s_val = str(val_amt)
	var formatted_val = ""
	var cnt_v = 0
	for i in range(s_val.length() - 1, -1, -1):
		if cnt_v > 0 and cnt_v % 3 == 0:
			formatted_val = "," + formatted_val
		formatted_val = s_val[i] + formatted_val
		cnt_v += 1
	var avg_str = String.num(current_item.get_average_rating(), 1) if current_item.has_method("get_average_rating") else "5.0"
	author_label.text = "작가 · " + (current_item.author_or_series if current_item.author_or_series != "" else "미상") + " · ★" + avg_str + " · 💎 ₩" + formatted_val

func boost_estimated_value() -> int:
	if current_item == null:
		return 0
	var new_val = current_item.boost_estimated_value(5000) if current_item.has_method("boost_estimated_value") else 5000
	_refresh_author_label()
	diary_updated.emit(current_item)
	return new_val

func cycle_favorite_character() -> String:
	if current_item == null:
		return "🌟 최애 캐릭터"
	var fc = current_item.cycle_favorite_character() if current_item.has_method("cycle_favorite_character") else "🌟 최애 캐릭터"
	var fc_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn")
	if fc_btn != null:
		fc_btn.text = fc
	diary_updated.emit(current_item)
	return fc

func cycle_condition_grade() -> String:
	if current_item == null:
		return "✨ S급(최상)"
	var cg = current_item.cycle_condition_grade() if current_item.has_method("cycle_condition_grade") else "✨ S급(최상)"
	var cond_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn")
	if cond_btn != null:
		cond_btn.text = cg
	diary_updated.emit(current_item)
	return cg

func cycle_cover_finish() -> String:
	if current_item == null:
		return "📜 무광 매트"
	var cf = current_item.cycle_cover_finish() if current_item.has_method("cycle_cover_finish") else "📜 무광 매트"
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

func cycle_reading_weather() -> String:
	if current_item == null:
		return "☀️ 맑은 오후"
	var rw = current_item.cycle_reading_weather() if current_item.has_method("cycle_reading_weather") else "☀️ 맑은 오후"
	var w_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	if w_btn != null:
		w_btn.text = rw
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return rw

func cycle_reading_spot() -> String:
	if current_item == null:
		return "🛋️ 이불 속"
	var rs = current_item.cycle_reading_spot() if current_item.has_method("cycle_reading_spot") else "🛋️ 이불 속"
	var sp_btn: Button = get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/SpotBtn")
	if sp_btn != null:
		sp_btn.text = rs
	_refresh_tag_label()
	diary_updated.emit(current_item)
	return rs

func cycle_obi_preset() -> void:
	if current_item == null:
		return
	obi_cursor = (obi_cursor + 1) % OBI_PRESETS.size()
	if OBI_PRESETS[obi_cursor] == current_item.obi_text:
		obi_cursor = (obi_cursor + 1) % OBI_PRESETS.size()
	current_item.obi_text = OBI_PRESETS[obi_cursor]
	_refresh_tag_label()
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

func cycle_cover_color() -> void:
	if current_item == null:
		return
	color_cursor = (color_cursor + 1) % COLOR_PRESETS.size()
	if COLOR_PRESETS[color_cursor] == current_item.cover_color:
		color_cursor = (color_cursor + 1) % COLOR_PRESETS.size()
	current_item.cover_color = COLOR_PRESETS[color_cursor]
	cover_rect.color = Color.from_string(current_item.cover_color, Color(0.65, 0.25, 0.2))
	diary_updated.emit(current_item)

func cycle_washi_tape() -> String:
	if current_item == null:
		return "#f4d394"
	washi_cursor = (washi_cursor + 1) % WASHI_PRESETS.size()
	if WASHI_PRESETS[washi_cursor] == current_item.get("washi_tape_color"):
		washi_cursor = (washi_cursor + 1) % WASHI_PRESETS.size()
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
	_refresh_author_label()
	diary_updated.emit(current_item)

func stamp_volume_date(vol_idx: int) -> void:
	if current_item == null or vol_idx < 0 or vol_idx >= current_item.volumes.size():
		return
	var d = Time.get_date_dict_from_system()
	current_item.volumes[vol_idx]["date"] = "%04d.%02d.%02d" % [d.year, d.month, d.day]
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
		date_btn.pressed.connect(func(): stamp_volume_date(capture_idx))

		var bm_btn = Button.new()
		var is_bm = bool(v.get("bookmarked", false))
		bm_btn.text = "🔖" if is_bm else "🏷️"
		bm_btn.flat = true
		bm_btn.add_theme_font_size_override("font_size", 10)
		bm_btn.add_theme_color_override("font_color", Color(0.85, 0.55, 0.15) if is_bm else Color(0.65, 0.58, 0.50))
		bm_btn.tooltip_text = "이 권을 북마크에 추가/해제합니다"
		bm_btn.pressed.connect(func(): toggle_volume_bookmark(capture_idx))

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
		diary_updated.emit(current_item)

func _on_delete_btn_pressed() -> void:
	if current_item != null:
		item_deleted.emit(current_item)
		close()
