class_name MainView
extends Control

const CardItemScene = preload("res://scenes/card_item.tscn")
const ArchiveStateClass = preload("res://scripts/archive_state.gd")

@onready var bg_rect: ColorRect = $Bg
@onready var stat_items: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems/Box/Val
@onready var stat_vols: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols/Box/Val
@onready var stat_firsts: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts/Box/Val
@onready var stat_gacha: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha/Box/Val
@onready var spine_shelf_row: HBoxContainer = $VBox/TopBar/TopMargin/StatsVBox/SpineBanner/HBox/SpineShelfRow
@onready var today_quote_label: Label = $VBox/TopBar/TopMargin/StatsVBox/SpineBanner/HBox/TodayQuoteLabel
@onready var next_quote_btn: Button = $VBox/TopBar/TopMargin/StatsVBox/SpineBanner/HBox/NextQuoteBtn

@onready var tab_all: Button = $VBox/FilterMargin/FilterBar/HBox/TabAll
@onready var tab_manga: Button = $VBox/FilterMargin/FilterBar/HBox/TabManga
@onready var tab_gacha: Button = $VBox/FilterMargin/FilterBar/HBox/TabGacha
@onready var search_input: LineEdit = $VBox/FilterMargin/FilterBar/HBox/SearchInput

@onready var card_grid: GridContainer = $VBox/GridMargin/Scroll/CardGrid
@onready var status_toast: Label = $VBox/BottomBar/Margin/VBox/ToastLabel
@onready var detail_modal: Control = $DetailModal
@onready var add_modal: Control = $AddModal

var archive_state = null
var web_preset_cursor: int = 0
var theme_cursor: int = 0
var quote_cursor: int = 0

const ROOM_THEMES = [
	{"name": "만년필 미색 노트 (Warm Ivory)", "bg": Color(0.98, 0.965, 0.94, 1)},
	{"name": "빈티지 크라프트 다꾸지 (Kraft)", "bg": Color(0.94, 0.89, 0.82, 1)},
	{"name": "리디 이북 세피아 리더 (Sepia)", "bg": Color(0.96, 0.92, 0.84, 1)},
	{"name": "보타니컬 세이지 일기장 (Sage)", "bg": Color(0.93, 0.96, 0.93, 1)}
]

func _ready() -> void:
	archive_state = ArchiveStateClass.new()
	archive_state.initialize_defaults()
	
	detail_modal.item_deleted.connect(_on_item_deleted)
	detail_modal.volume_added.connect(_on_volume_added)
	detail_modal.diary_updated.connect(_on_diary_updated)
	add_modal.item_submitted.connect(_on_item_submitted)
	
	_apply_journal_button_theme()
	_update_stats()
	_render_cards()

func _apply_journal_button_theme() -> void:
	var cream_btn = StyleBoxFlat.new()
	cream_btn.bg_color = Color(0.95, 0.91, 0.84, 1)
	cream_btn.border_width_left = 1
	cream_btn.border_width_top = 1
	cream_btn.border_width_right = 1
	cream_btn.border_width_bottom = 1
	cream_btn.border_color = Color(0.80, 0.72, 0.62, 1)
	cream_btn.corner_radius_top_left = 8
	cream_btn.corner_radius_top_right = 8
	cream_btn.corner_radius_bottom_left = 8
	cream_btn.corner_radius_bottom_right = 8

	var ink_btn = StyleBoxFlat.new()
	ink_btn.bg_color = Color(0.22, 0.16, 0.13, 1)
	ink_btn.corner_radius_top_left = 8
	ink_btn.corner_radius_top_right = 8
	ink_btn.corner_radius_bottom_left = 8
	ink_btn.corner_radius_bottom_right = 8

	var add_btn = $VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn
	add_btn.add_theme_stylebox_override("normal", ink_btn)
	add_btn.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))

	next_quote_btn.add_theme_stylebox_override("normal", cream_btn)
	next_quote_btn.add_theme_color_override("font_color", Color(0.32, 0.24, 0.18))

	for b in [tab_all, tab_manga, tab_gacha]:
		b.add_theme_stylebox_override("normal", cream_btn)
		b.add_theme_color_override("font_color", Color(0.22, 0.16, 0.13))

	var nav_row = $VBox/BottomBar/Margin/VBox/NavRow
	for nb in nav_row.get_children():
		if nb is Button:
			nb.add_theme_stylebox_override("normal", cream_btn)
			nb.add_theme_color_override("font_color", Color(0.22, 0.16, 0.13))

	var search_sb = StyleBoxFlat.new()
	search_sb.bg_color = Color(0.97, 0.95, 0.91, 1)
	search_sb.border_width_left = 1
	search_sb.border_width_top = 1
	search_sb.border_width_right = 1
	search_sb.border_width_bottom = 1
	search_sb.border_color = Color(0.84, 0.77, 0.68, 1)
	search_sb.corner_radius_top_left = 8
	search_sb.corner_radius_top_right = 8
	search_sb.corner_radius_bottom_left = 8
	search_sb.corner_radius_bottom_right = 8
	search_sb.content_margin_left = 8
	search_input.add_theme_stylebox_override("normal", search_sb)
	search_input.add_theme_color_override("font_color", Color(0.22, 0.16, 0.13))
	search_input.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.42))

func _update_stats() -> void:
	stat_items.text = str(archive_state.items.size()) + "종"
	stat_vols.text = str(archive_state.get_total_volumes()) + "권"
	stat_firsts.text = str(archive_state.get_first_editions_count()) + "권"
	var g_count = 0
	for it in archive_state.items:
		if it.category == 1: # GACHA
			g_count += 1
	stat_gacha.text = str(g_count) + "개"
	_render_spine_shelf()
	_refresh_today_quote()

func _render_spine_shelf() -> void:
	if spine_shelf_row == null:
		return
	for child in spine_shelf_row.get_children():
		spine_shelf_row.remove_child(child)
		child.queue_free()
	for it in archive_state.items:
		var spine = ColorRect.new()
		var w = clamp(6 + it.volumes.size() * 2, 7, 13)
		spine.custom_minimum_size = Vector2(w, 20)
		spine.color = Color.from_string(it.cover_color, Color(0.65, 0.25, 0.20))
		spine_shelf_row.add_child(spine)

func _collect_all_quotes() -> Array:
	var quotes: Array = []
	for it in archive_state.items:
		if it.volumes.size() > 0:
			for v in it.volumes:
				var q = str(v.get("quote", "")).strip_edges()
				if q != "":
					quotes.append("🖋️ 오늘의 밑줄: \"" + q + "\" — " + it.title)
		elif it.memo != "":
			quotes.append("🖋️ 오늘의 밑줄: \"" + it.memo + "\" — " + it.title)
	if quotes.is_empty():
		quotes.append("🖋️ 오늘의 밑줄: \"나만의 첫 독서 일기를 시작해보세요.\"")
	return quotes

func _refresh_today_quote() -> void:
	if today_quote_label == null:
		return
	var quotes = _collect_all_quotes()
	quote_cursor = quote_cursor % quotes.size()
	today_quote_label.text = quotes[quote_cursor]

func _on_next_quote_btn_pressed() -> void:
	var quotes = _collect_all_quotes()
	quote_cursor = (quote_cursor + 1) % quotes.size()
	today_quote_label.text = quotes[quote_cursor]

func _render_cards() -> void:
	for child in card_grid.get_children():
		card_grid.remove_child(child)
		child.queue_free()
	
	var q = search_input.text
	var filtered = archive_state.get_filtered_items(archive_state.current_filter, q)
	
	for it in filtered:
		var card = CardItemScene.instantiate()
		card_grid.add_child(card)
		card.setup(it)
		card.clicked.connect(_on_card_clicked)

func _show_toast(msg: String) -> void:
	if status_toast != null:
		status_toast.text = msg

func _on_card_clicked(item) -> void:
	detail_modal.open(item)

func _on_tab_all_pressed() -> void:
	archive_state.current_filter = -1
	_highlight_tabs(tab_all)
	_render_cards()

func _on_tab_manga_pressed() -> void:
	archive_state.current_filter = 0
	_highlight_tabs(tab_manga)
	_render_cards()

func _on_tab_gacha_pressed() -> void:
	archive_state.current_filter = 1
	_highlight_tabs(tab_gacha)
	_render_cards()

func _highlight_tabs(active_btn: Button) -> void:
	for btn in [tab_all, tab_manga, tab_gacha]:
		btn.modulate = Color(1, 1, 1, 0.65) if btn != active_btn else Color(1, 1, 1, 1)

func _on_search_text_changed(_new_text: String) -> void:
	_render_cards()

func _on_add_btn_pressed() -> void:
	add_modal.open()

func _on_web_scrape_btn_pressed() -> void:
	var added = archive_state.scrape_web_preset(web_preset_cursor)
	web_preset_cursor = (web_preset_cursor + 1) % archive_state.WEB_PRESET_CATALOG.size()
	_update_stats()
	_render_cards()
	_show_toast("🌐 웹 표지 자동 스크랩 완료: " + added.title)

func _on_camera_snap_btn_pressed() -> void:
	var added = archive_state.add_item(
		"카메라 실물 촬영 단행본 #" + str(archive_state.items.size() + 1),
		0,
		"LIVE 카메라 스캔",
		"#0d9488",
		"📸",
		"★ 카메라 뷰파인더 2:3 자동 크롭 완료",
		"실물인증"
	)
	_update_stats()
	_render_cards()
	_show_toast("📸 카메라 찰칵! 실물 표지가 등록되었습니다: " + added.title)

func _on_theme_btn_pressed() -> void:
	theme_cursor = (theme_cursor + 1) % ROOM_THEMES.size()
	var t = ROOM_THEMES[theme_cursor]
	bg_rect.color = t["bg"]
	_show_toast("🎨 진열장 배경 테마 변경: " + t["name"])

func _on_item_submitted(p_title: String, p_cat: int, p_author: String, p_color: String = "#b91c1c", p_quote: String = "") -> void:
	var ic = "📕" if p_cat == 0 else "🔮"
	var added = archive_state.add_item(p_title, p_cat, p_author, p_color, ic, "★ 직접 쓴 다꾸 일기장", "나만의책")
	if p_quote != "":
		added.memo = p_quote
		if added.volumes.size() > 0:
			added.volumes[0]["quote"] = p_quote
		archive_state.save_to_file()
	_update_stats()
	_render_cards()
	_show_toast("✨ 새 일기장이 서재에 꽂혔습니다: " + p_title)

func _on_item_deleted(item) -> void:
	archive_state.remove_item(item.id)
	_update_stats()
	_render_cards()
	_show_toast("🗑️ 소장품이 삭제되었습니다.")

func _on_volume_added(_item) -> void:
	archive_state.save_to_file()
	_update_stats()
	_render_cards()
	_show_toast("📖 다음 권이 추가되고 로컬 JSON에 저장되었습니다.")

func _on_diary_updated(item) -> void:
	archive_state.save_to_file()
	_update_stats()
	_render_cards()
	_show_toast("💮 일기장 스탬프·밑줄 문장이 저장되었습니다: " + item.title)
