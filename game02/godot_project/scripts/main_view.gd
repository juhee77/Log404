class_name MainView
extends Control

const CardItemScene = preload("res://scenes/card_item.tscn")
const ArchiveStateClass = preload("res://scripts/archive_state.gd")

@onready var bg_rect: ColorRect = $Bg
@onready var sub_title: Label = $VBox/TopBar/TopMargin/StatsVBox/TitleRow/TitleCol/SubTitle
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
@onready var tab_complete: Button = $VBox/FilterMargin/FilterBar/HBox/TabComplete
@onready var tab_fav: Button = $VBox/FilterMargin/FilterBar/HBox/TabFav
@onready var search_input: LineEdit = $VBox/FilterMargin/FilterBar/HBox/SearchInput
@onready var sort_btn: Button = $VBox/FilterMargin/FilterBar/HBox/SortBtn
@onready var random_pick_btn: Button = $VBox/TopBar/TopMargin/StatsVBox/SpineBanner/HBox/RandomPickBtn

@onready var card_grid: GridContainer = $VBox/GridMargin/Scroll/CardGrid
@onready var status_toast: Label = $VBox/BottomBar/Margin/VBox/ToastLabel
@onready var detail_modal: Control = $DetailModal
@onready var add_modal: Control = $AddModal

var archive_state = null
var web_preset_cursor: int = 0
var theme_cursor: int = 0
var quote_cursor: int = 0
var sort_mode: int = 0
var sort_by_volumes: bool:
	get: return sort_mode == 1
	set(val): sort_mode = 1 if val else 0
var filter_firsts_only: bool = false
var filter_completed_only: bool = false
var filter_favorites_only: bool = false

var ambient_sound_index: int = 0
const AMBIENT_SOUND_PRESETS = [
	"🔕 무음",
	"🌧️ 빗소리",
	"☕ 북카페",
	"📖 책장넘김",
	"🔥 모닥불",
	"🦗 밤귀뚜라미"
]

func cycle_ambient_sound() -> String:
	ambient_sound_index = (ambient_sound_index + 1) % AMBIENT_SOUND_PRESETS.size()
	var snd = AMBIENT_SOUND_PRESETS[ambient_sound_index]
	var ambient_btn: Button = get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AmbientBtn")
	if ambient_btn != null:
		ambient_btn.text = snd
	_show_toast("🎧 앰비언트: " + snd + " 재생")
	return snd

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

	var stat_items_panel: Control = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems
	var stat_vols_panel: Control = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols
	var stat_firsts_panel: Control = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts
	var stat_gacha_panel: Control = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha
	stat_items_panel.gui_input.connect(func(ev): if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT: _on_tab_all_pressed())
	stat_vols_panel.gui_input.connect(func(ev): if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT: _on_tab_manga_pressed())
	stat_firsts_panel.gui_input.connect(func(ev): if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT: _on_stat_firsts_clicked())
	stat_gacha_panel.gui_input.connect(func(ev): if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT: _on_tab_gacha_pressed())
	today_quote_label.mouse_filter = Control.MOUSE_FILTER_STOP
	today_quote_label.gui_input.connect(func(ev): if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT: open_current_quote_item())
	
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
	if random_pick_btn != null:
		random_pick_btn.add_theme_stylebox_override("normal", cream_btn)
		random_pick_btn.add_theme_color_override("font_color", Color(0.32, 0.24, 0.18))

	for b in [tab_all, tab_manga, tab_gacha, tab_complete, tab_fav, sort_btn]:
		if b != null:
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

func get_overall_reading_progress() -> float:
	if archive_state == null or archive_state.items.is_empty():
		return 0.0
	var sum_prog = 0.0
	var manga_cnt = 0
	for it in archive_state.items:
		if it.category == 0:
			manga_cnt += 1
			if it.status_tag == "전권완결" or it.status_tag == "완독":
				sum_prog += 100.0
			else:
				var p = clampf(float(it.volumes.size()) * 25.0, 20.0, 100.0)
				sum_prog += p
	if manga_cnt == 0:
		return 50.0
	return sum_prog / float(manga_cnt)

func _update_stats() -> void:
	stat_items.text = str(archive_state.items.size()) + "종"
	stat_vols.text = str(archive_state.get_total_volumes()) + "권"
	stat_firsts.text = str(archive_state.get_first_editions_count()) + "권"
	var g_count = 0
	for it in archive_state.items:
		if it.category == 1: # GACHA
			g_count += 1
	stat_gacha.text = str(g_count) + "개"
	
	var prog = get_overall_reading_progress()
	if sub_title != null:
		sub_title.text = "📔 2026. 11. 12 · 서재 완독률 " + str(int(prog)) + "% · MY ARCHIVE"
	
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
		spine.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var ribbon = ColorRect.new()
		ribbon.color = Color(0.96, 0.85, 0.55, 0.9)
		ribbon.size = Vector2(w, 3)
		spine.add_child(ribbon)
		var capture_item = it
		spine.tooltip_text = it.title + " (" + str(it.volumes.size()) + "권 소장)"
		spine.mouse_entered.connect(func(): _show_toast("📚 책등 엿보기: " + capture_item.title + " (" + str(capture_item.volumes.size()) + "권)"))
		spine.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				detail_modal.open(capture_item)
		)
		spine_shelf_row.add_child(spine)

func _collect_all_quotes() -> Array:
	var quotes: Array = []
	for it in archive_state.items:
		if it.volumes.size() > 0:
			for v in it.volumes:
				var q = str(v.get("quote", "")).strip_edges()
				if q != "":
					quotes.append({"text": "🖋️ 오늘의 밑줄: \"" + q + "\" — " + it.title, "item": it})
		elif it.memo != "":
			quotes.append({"text": "🖋️ 오늘의 밑줄: \"" + it.memo + "\" — " + it.title, "item": it})
	if quotes.is_empty():
		var fallback = archive_state.items[0] if archive_state.items.size() > 0 else null
		quotes.append({"text": "🖋️ 오늘의 밑줄: \"나만의 첫 독서 일기를 시작해보세요.\"", "item": fallback})
	return quotes

func _refresh_today_quote() -> void:
	if today_quote_label == null:
		return
	var quotes = _collect_all_quotes()
	quote_cursor = quote_cursor % quotes.size()
	today_quote_label.text = quotes[quote_cursor]["text"]

func _on_next_quote_btn_pressed() -> void:
	var quotes = _collect_all_quotes()
	quote_cursor = (quote_cursor + 1) % quotes.size()
	today_quote_label.text = quotes[quote_cursor]["text"]

func open_current_quote_item() -> void:
	var quotes = _collect_all_quotes()
	if quotes.is_empty():
		return
	quote_cursor = quote_cursor % quotes.size()
	var target_item = quotes[quote_cursor].get("item", null)
	if target_item != null:
		detail_modal.open(target_item)

func _render_cards() -> void:
	for child in card_grid.get_children():
		card_grid.remove_child(child)
		child.queue_free()
	
	var q = search_input.text
	var filtered = archive_state.get_filtered_items(archive_state.current_filter, q).duplicate()
	if filter_firsts_only:
		filtered = filtered.filter(func(it):
			if it.status_tag == "초판특전":
				return true
			for v in it.volumes:
				if v.get("status", "") == "first":
					return true
			return false
		)
	if filter_completed_only:
		filtered = filtered.filter(func(it):
			return it.status_tag == "전권완결" or it.status_tag == "완독" or it.volumes.size() >= 2
		)
	if filter_favorites_only:
		filtered = filtered.filter(func(it):
			return it.status_tag == "인생최애" or it.get_average_rating() >= 5.0
		)
	if sort_mode == 1:
		filtered.sort_custom(func(a, b): return a.volumes.size() > b.volumes.size())
	elif sort_mode == 2:
		filtered.sort_custom(func(a, b): return a.updated_at > b.updated_at)
	
	for it in filtered:
		var card = CardItemScene.instantiate()
		card_grid.add_child(card)
		card.setup(it)
		card.clicked.connect(_on_card_clicked)
		if card.has_signal("quick_advanced"):
			card.quick_advanced.connect(_on_card_quick_advanced)

func _on_card_quick_advanced(it) -> void:
	archive_state.save_to_file()
	_update_stats()
	_render_spine_shelf()
	_show_toast("📖 " + it.title + " " + str(it.volumes.size()) + "권 완독 기록 완료!")

func _on_stat_firsts_clicked() -> void:
	filter_firsts_only = true
	archive_state.current_filter = -1
	_render_cards()
	_show_toast("🔖 초판 스탬프 보유 작품만 필터링되었습니다.")

func filter_by_smart_tag(tag: String) -> int:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	search_input.text = ""
	match tag:
		"#전체":
			archive_state.current_filter = -1
		"#만화":
			archive_state.current_filter = 0
		"#가챠":
			archive_state.current_filter = 1
		"#완독":
			filter_completed_only = true
		"#초판":
			filter_firsts_only = true
		"#인생작":
			filter_favorites_only = true
		_:
			search_input.text = tag
	_render_cards()
	_show_toast("🏷️ 스마트 태그: " + tag)
	return card_grid.get_child_count()

func _on_sort_btn_pressed() -> void:
	sort_mode = (sort_mode + 1) % 3
	if sort_btn != null:
		match sort_mode:
			0: sort_btn.text = "↕ 기본순"
			1: sort_btn.text = "↕ 다독순"
			2: sort_btn.text = "↕ 최신순"
	_render_cards()
	var mode_name = "기본 등록순" if sort_mode == 0 else ("권수 많은 순(다독순)" if sort_mode == 1 else "최근 기록순(최신순)")
	_show_toast("📚 정렬 기준 변경: " + mode_name)

func _show_toast(msg: String) -> void:
	if status_toast != null:
		status_toast.text = msg

func copy_summary_to_clipboard() -> String:
	var summary = archive_state.export_diary_summary()
	DisplayServer.clipboard_set(summary)
	_show_toast("📋 내 서재 일기장 요약 리포트가 클립보드에 복사되었습니다!")
	return summary

func show_library_infographic() -> String:
	var total_bms = 0
	var sum_quotes = 0
	for it in archive_state.items:
		total_bms += it.get_bookmarked_volumes_count() if it.has_method("get_bookmarked_volumes_count") else 0
		for v in it.volumes:
			if v.get("quote", "") != "":
				sum_quotes += 1
	var prog = int(get_overall_reading_progress())
	var text = "📊 소장: %d종 (%d권) · 완독률: %d%% · 북마크: %d권 · 밑줄: %d개" % [
		archive_state.items.size(),
		archive_state.get_total_volumes(),
		prog,
		total_bms,
		sum_quotes
	]
	_show_toast(text)
	return text

func _on_card_clicked(item) -> void:
	detail_modal.open(item)

func _on_tab_all_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = -1
	_highlight_tabs(tab_all)
	_render_cards()

func _on_tab_manga_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = 0
	_highlight_tabs(tab_manga)
	_render_cards()

func _on_tab_gacha_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = 1
	_highlight_tabs(tab_gacha)
	_render_cards()

func _on_tab_complete_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = true
	filter_favorites_only = false
	archive_state.current_filter = 0
	_highlight_tabs(tab_complete)
	_render_cards()
	_show_toast("💮 완독한 작품만 모아봅니다.")

func _on_tab_fav_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = true
	archive_state.current_filter = -1
	_highlight_tabs(tab_fav)
	_render_cards()
	_show_toast("★ 내 인생 최애 만점(5.0) 작품만 모아봅니다.")

func _highlight_tabs(active_btn: Button) -> void:
	for btn in [tab_all, tab_manga, tab_gacha, tab_complete, tab_fav]:
		if btn != null:
			btn.modulate = Color(1, 1, 1, 0.65) if btn != active_btn else Color(1, 1, 1, 1)

func pick_random_item():
	if archive_state == null or archive_state.items.is_empty():
		return null
	var r_idx = randi() % archive_state.items.size()
	var picked = archive_state.items[r_idx]
	detail_modal.open(picked)
	_show_toast("🎲 오늘 서재가 추천하는 작품: " + picked.title)
	return picked

func _on_random_pick_btn_pressed() -> void:
	pick_random_item()

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

func _on_volume_added(item) -> void:
	if item != null:
		item.updated_at = int(Time.get_unix_time_from_system())
	archive_state.save_to_file()
	_update_stats()
	_render_cards()
	_show_toast("📖 다음 권이 추가되고 로컬 JSON에 저장되었습니다.")

func _on_diary_updated(item) -> void:
	if item != null:
		item.updated_at = int(Time.get_unix_time_from_system())
	archive_state.save_to_file()
	_update_stats()
	_render_cards()
	_show_toast("💮 일기장 스탬프·밑줄 문장이 저장되었습니다: " + item.title)
