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

func cycle_ambient_sound(delta: int = 1) -> String:
	ambient_sound_index = (ambient_sound_index + delta + AMBIENT_SOUND_PRESETS.size()) % AMBIENT_SOUND_PRESETS.size()
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
	detail_modal.volume_removed.connect(_on_volume_removed)
	detail_modal.card_copied.connect(_on_card_copied)
	detail_modal.navigate_requested.connect(_on_modal_navigate_requested)
	detail_modal.diary_updated.connect(_on_diary_updated)
	detail_modal.help_requested.connect(_on_modal_help_requested)
	detail_modal.summary_copy_requested.connect(copy_summary_to_clipboard)
	detail_modal.close_and_backup_requested.connect(_trigger_instant_json_backup)
	detail_modal.filter_category_requested.connect(func(cat: int) -> void:
		if cat == -1:
			_on_tab_all_pressed()
		elif cat == 1:
			_on_tab_gacha_pressed()
		else:
			_on_tab_manga_pressed()
	)
	detail_modal.search_author_requested.connect(func(author_name: String) -> void:
		if search_input != null:
			search_input.text = author_name
		_render_cards()
		_show_toast("🔍 작가·시리즈 검색: %s (%s)" % [author_name, _get_filtered_cards_summary()])
	)
	add_modal.item_submitted.connect(_on_item_submitted)

	var stat_configs := [
		[$VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems, _on_tab_all_pressed, copy_summary_to_clipboard, "좌클릭: 전체 서재 · 우클릭: 서재 리포트 클립보드 복사"],
		[$VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols, _on_tab_manga_pressed, func() -> void: _on_tab_manga_pressed(); _set_sort_mode(3), "좌클릭: 이북·단행본 · 우클릭: 이북 가치순 정렬"],
		[$VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts, _on_stat_firsts_clicked, show_library_infographic, "좌클릭: 초판 특전 필터 · 우클릭: 서재 인포그래픽 요약"],
		[$VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha, _on_tab_gacha_pressed, _trigger_instant_json_backup, "좌클릭: 가챠노트 필터 · 우클릭: 즉시 JSON 백업 저장"],
	]
	for cfg in stat_configs:
		var panel: Control = cfg[0]
		var lcb: Callable = cfg[1]
		var rcb: Callable = cfg[2]
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		panel.tooltip_text = cfg[3]
		panel.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					lcb.call()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					rcb.call()
		)
	today_quote_label.mouse_filter = Control.MOUSE_FILTER_STOP
	today_quote_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	today_quote_label.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed:
			if ev.button_index == MOUSE_BUTTON_LEFT:
				if ev.shift_pressed:
					DisplayServer.clipboard_set(today_quote_label.text)
					_show_toast("📋 오늘의 밑줄 복사 완료: %s" % today_quote_label.text)
				else:
					open_current_quote_item()
			elif ev.button_index == MOUSE_BUTTON_RIGHT:
				_step_today_quote(-1 if ev.shift_pressed else 1)
	)

	if search_input != null:
		search_input.clear_button_enabled = true
		search_input.tooltip_text = "작품명·작가·대사·태그·보관위치·날씨·장소·소장경로 통합 검색 (Enter: 첫 결과 열기 · ESC·우클릭: 지우기/추천 검색)"
		search_input.text_submitted.connect(func(_t: String) -> void: _open_first_filtered_card())
		search_input.gui_input.connect(func(ev):
			if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_ESCAPE and search_input.text != "":
				search_input.text = ""
				_render_cards()
				_show_toast("🔍 검색어 초기화 (%s)" % _get_filtered_cards_summary())
			elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
				if search_input.text != "":
					search_input.text = ""
					_render_cards()
					_show_toast("🔍 검색어 초기화 (%s)" % _get_filtered_cards_summary())
				elif archive_state != null and not archive_state.items.is_empty():
					var q_idx: int = quote_cursor % archive_state.items.size()
					var q_title: String = archive_state.items[q_idx].title
					search_input.text = q_title
					_render_cards()
					_show_toast("🔍 오늘의 밑줄 작품 검색: %s" % q_title)
		)
	for ctrl in [get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn"), get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AmbientBtn"), next_quote_btn, random_pick_btn, sort_btn, tab_all, tab_manga, tab_gacha, tab_complete, tab_fav]:
		if ctrl != null:
			ctrl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var tab_rclick_map := {
		tab_all: func() -> void: _reset_all_filters(); _set_sort_mode(0),
		tab_manga: func() -> void: _on_tab_manga_pressed(); _set_sort_mode(3),
		tab_gacha: func() -> void: _on_tab_gacha_pressed(); _set_sort_mode(3),
		tab_complete: func() -> void: _on_tab_complete_pressed(); _set_sort_mode(3),
		tab_fav: func() -> void: _on_tab_fav_pressed(); _set_sort_mode(3),
	}
	for t_btn in tab_rclick_map.keys():
		if t_btn != null:
			var t_cb: Callable = tab_rclick_map[t_btn]
			t_btn.gui_input.connect(func(ev: InputEvent) -> void:
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
					t_cb.call()
			)
	var top_add_btn: Control = get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn")
	if top_add_btn != null:
		top_add_btn.tooltip_text = "[N] 새 독서 일기·가챠 스크랩 직접 작성 (우클릭: 즉시 JSON 저장 · Shift+좌클릭: 샘플 채움 열기)"
		top_add_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					_trigger_instant_json_backup()
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					add_modal.open()
					add_modal.title_input.text = "나의 비밀 독서 일기"
					add_modal.author_input.text = "주희의 서재"
					add_modal.quote_input.text = "오늘도 한 페이지의 여운을 남겼다."
		)
	var top_amb_btn: Control = get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AmbientBtn")
	if top_amb_btn != null:
		top_amb_btn.tooltip_text = "[M] 독서 몰입 백색소음 전환 (우클릭·Shift+M: 이전 · Shift+좌클릭: 즉시 무음)"
		top_amb_btn.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					cycle_ambient_sound(-1)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					ambient_sound_index = 0
					var snd_mute: String = AMBIENT_SOUND_PRESETS[0]
					if top_amb_btn is Button:
						top_amb_btn.text = snd_mute
					_show_toast("🔕 백색소음 음소거 완료 (%s)" % snd_mute)
		)
	if sub_title != null:
		sub_title.mouse_filter = Control.MOUSE_FILTER_STOP
		sub_title.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		sub_title.tooltip_text = "좌클릭: 서재 인포그래픽 요약 · 우클릭: 서재 리포트 클립보드 복사 · Shift+좌/우클릭: 백업/단축키"
		sub_title.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						_trigger_instant_json_backup()
					else:
						show_library_infographic()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					if ev.shift_pressed:
						_show_shortcut_cheatsheet()
					else:
						copy_summary_to_clipboard()
		)
	var app_title: Control = get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/TitleCol/AppTitle")
	if app_title != null:
		app_title.mouse_filter = Control.MOUSE_FILTER_STOP
		app_title.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		app_title.tooltip_text = "좌클릭: 전체 서재 복원 (0) · 우클릭: 속지 테마 순환 (T) · Shift+좌클릭: 새 일기 쓰기 (N)"
		app_title.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						add_modal.open()
					else:
						_reset_all_filters()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					_step_theme(-1 if ev.shift_pressed else 1)
		)
	if status_toast != null:
		status_toast.mouse_filter = Control.MOUSE_FILTER_STOP
		status_toast.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		status_toast.tooltip_text = "좌클릭: 단축키 치트시트 보기 (H) · 우클릭: 오늘의 랜덤 추천 미리보기 (Shift+R) · Shift+좌/우클릭: 브리핑/복사"
		status_toast.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed:
						show_library_infographic()
					else:
						_show_shortcut_cheatsheet()
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					if ev.shift_pressed:
						DisplayServer.clipboard_set(status_toast.text)
						_show_toast("📋 상태 메시지 복사 완료!")
					else:
						pick_random_item(false)
		)
	if next_quote_btn != null:
		next_quote_btn.tooltip_text = "[Q] 서재 속 다음 밑줄 문장으로 넘기기"
	if random_pick_btn != null:
		random_pick_btn.tooltip_text = "[R] 오늘의 랜덤 작품 추천 열기 (우클릭·Shift+R: 미리보기 · Shift+좌클릭: 서재 필터)"
		random_pick_btn.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					pick_random_item(false)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					var picked = pick_random_item(false)
					if picked != null and search_input != null:
						search_input.text = picked.title
						_render_cards()
						_show_toast("🎲 랜덤 추천 서재 필터: %s" % picked.title)
		)
	if sort_btn != null:
		sort_btn.tooltip_text = "[S] 정렬 순환 (우클릭·Shift+S: 이전 · Shift+좌클릭: 기본순): 기본순 → 권수순 → 최신순 → 가치순"
		sort_btn.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_RIGHT:
					_step_sort(-1)
				elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
					_set_sort_mode(0)
		)
	var nav_row = get_node_or_null("VBox/BottomBar/Margin/VBox/NavRow")
	if nav_row != null:
		var nav_tips = [
			"웹에서 작품 표지와 기본 정보 자동 스크랩 추가 (우클릭: 이북·단행본 필터)",
			"실물 굿즈·단행본 폴라로이드 촬영 기록 추가 (우클릭: 가챠노트 필터)",
			"[N] 새 독서 일기·가챠 스크랩 직접 작성 (우클릭: 즉시 JSON 저장)",
			"[T] 다꾸 다이어리 속지 테마 순환 (우클릭·Shift+T: 이전 · Shift+좌클릭: 기본 테마)"
		]
		var nav_rclicks: Array[Callable] = [
			_on_tab_manga_pressed,
			_on_tab_gacha_pressed,
			_trigger_instant_json_backup,
			func() -> void: _step_theme(-1)
		]
		var children = nav_row.get_children()
		for i in range(min(children.size(), nav_tips.size())):
			if children[i] is Control:
				children[i].tooltip_text = nav_tips[i]
				var cb: Callable = nav_rclicks[i]
				var idx_cap: int = i
				children[i].gui_input.connect(func(ev: InputEvent) -> void:
					if ev is InputEventMouseButton and ev.pressed:
						if ev.button_index == MOUSE_BUTTON_RIGHT:
							cb.call()
						elif idx_cap == 3 and ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
							children[idx_cap].accept_event()
							_reset_theme()
				)
	
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
	var total_val = archive_state.get_total_collection_value() if archive_state.has_method("get_total_collection_value") else 0
	var val_str = archive_state.format_krw(total_val)
	var avg_lib = archive_state.get_average_library_rating() if archive_state.has_method("get_average_library_rating") else 5.0
	var dt = Time.get_date_dict_from_system()
	var date_str = "%04d. %02d. %02d" % [int(dt.get("year", 2026)), int(dt.get("month", 11)), int(dt.get("day", 15))]
	if sub_title != null:
		sub_title.text = "📔 " + date_str + " · 완독 " + str(int(prog)) + "% · ★" + String.num(avg_lib, 1) + " · 자산 " + val_str

	var first_cnt = archive_state.get_first_editions_count()
	var tot_vols = max(1, archive_state.get_total_volumes())
	var first_pct = int(round(float(first_cnt) / float(tot_vols) * 100.0))
	var gacha_val = 0
	for it in archive_state.items:
		if it.category == 1:
			gacha_val += it.get_item_value()
	var stat_tips = [
		[stat_items, "클릭 시 전체 서재 보기 · 평균 ★%s · 총 자산 %s" % [String.num(avg_lib, 1), val_str]],
		[stat_vols, "클릭 시 이북·단행본 필터 · 서재 완독률 %d%%" % int(prog)],
		[stat_firsts, "클릭 시 초판본 현황 · 전체 단행본 중 %d%% 초판" % first_pct],
		[stat_gacha, "클릭 시 가챠·굿즈 필터 · 굿즈 자산 %s" % archive_state.format_krw(gacha_val)],
	]
	for pair in stat_tips:
		var card_node = pair[0].get_parent().get_parent() if pair[0] != null and pair[0].get_parent() != null else null
		if card_node is Control:
			card_node.tooltip_text = pair[1]
	if tab_all != null:
		tab_all.tooltip_text = "[1] 전체 일기 (%d종) · 우클릭: 완전 초기화" % archive_state.items.size()
	if tab_manga != null:
		tab_manga.tooltip_text = "[2] 이북·단행본 (%d종) · 우클릭: 가치순 보기" % (archive_state.items.size() - g_count)
	if tab_gacha != null:
		tab_gacha.tooltip_text = "[3] 가챠·굿즈 (%d종) · 우클릭: 가치순 보기" % g_count
	if tab_complete != null:
		tab_complete.tooltip_text = "[4] 완독·2권 이상 작품 보기 · 우클릭: 가치순 보기"
	if tab_fav != null:
		tab_fav.tooltip_text = "[5] 인생최애·★5.0 만점작 보기 · 우클릭: 가치순 보기"
	
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
		spine.tooltip_text = "%s (%d권 소장 · 좌클릭: 열기 · 우클릭: 미리보기 · Shift+좌/우클릭: 검색/복사)" % [it.title, it.volumes.size()]
		spine.mouse_entered.connect(func(): _show_toast("📚 책등 엿보기: " + capture_item.title + " (" + str(capture_item.volumes.size()) + "권)"))
		spine.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed:
				if ev.button_index == MOUSE_BUTTON_LEFT:
					if ev.shift_pressed and search_input != null:
						search_input.text = capture_item.title
						_render_cards()
						_show_toast("🔍 책등 작품 필터: %s (%s)" % [capture_item.title, _get_filtered_cards_summary()])
					else:
						_open_detail_modal(capture_item)
				elif ev.button_index == MOUSE_BUTTON_RIGHT:
					if ev.shift_pressed:
						_on_card_quote_copy_requested(capture_item)
					else:
						_show_toast("📚 책등 상세 미리보기: 「%s」 · %d권 · %d%% · %s" % [capture_item.title, capture_item.volumes.size(), int(capture_item.get_completion_percentage()), ArchiveStateClass.format_krw(capture_item.get_item_value())])
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

func _apply_today_quote(entry: Dictionary, total_count: int = 1) -> void:
	today_quote_label.text = entry["text"]
	var target_item = entry.get("item", null)
	if target_item != null:
		today_quote_label.tooltip_text = "좌클릭: 「%s」 독서 일기장 펼치기 · 우클릭: 다음 밑줄 · Shift+좌클릭: 복사 (%d/%d)" % [target_item.title, quote_cursor + 1, maxi(1, total_count)]
	else:
		today_quote_label.tooltip_text = "나만의 첫 독서 일기를 시작해보세요"
	if next_quote_btn != null:
		next_quote_btn.tooltip_text = "[Q] 다음 밑줄 (우클릭·Shift+Q: 이전 · Shift+좌클릭: 작품 열기) (%d/%d)" % [quote_cursor + 1, maxi(1, total_count)]
		if not next_quote_btn.has_meta("rclick_wired"):
			next_quote_btn.set_meta("rclick_wired", true)
			next_quote_btn.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed:
					if ev.button_index == MOUSE_BUTTON_RIGHT:
						_step_today_quote(-1)
					elif ev.button_index == MOUSE_BUTTON_LEFT and ev.shift_pressed:
						open_current_quote_item()
			)

func _step_today_quote(delta: int) -> void:
	var quotes = _collect_all_quotes()
	if quotes.is_empty():
		return
	quote_cursor = (quote_cursor + delta + quotes.size()) % quotes.size()
	_apply_today_quote(quotes[quote_cursor], quotes.size())

func _refresh_today_quote() -> void:
	if today_quote_label == null:
		return
	var quotes = _collect_all_quotes()
	quote_cursor = quote_cursor % quotes.size()
	_apply_today_quote(quotes[quote_cursor], quotes.size())

func _on_next_quote_btn_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		open_current_quote_item()
		return
	_step_today_quote(1)

func open_current_quote_item() -> void:
	var quotes = _collect_all_quotes()
	if quotes.is_empty():
		return
	quote_cursor = quote_cursor % quotes.size()
	var target_item = quotes[quote_cursor].get("item", null)
	if target_item != null:
		_open_detail_modal(target_item)

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
	elif sort_mode == 3:
		filtered.sort_custom(func(a, b): return a.get_item_value() > b.get_item_value())
	
	if filtered.is_empty():
		var empty_box := VBoxContainer.new()
		empty_box.name = "EmptyStateBox"
		empty_box.custom_minimum_size = Vector2(360, 140)
		empty_box.alignment = BoxContainer.ALIGNMENT_CENTER
		var empty_lbl := Label.new()
		empty_lbl.name = "EmptyStateLabel"
		empty_lbl.text = "📭 조건에 맞는 서재 기록이 없습니다.\n검색어를 비우거나 '+ 일기 쓰기'로 새 추억을 남겨보세요!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_color_override("font_color", Color(0.45, 0.37, 0.30, 1.0))
		empty_lbl.add_theme_font_size_override("font_size", 13)
		var reset_btn := Button.new()
		reset_btn.name = "EmptyStateResetBtn"
		reset_btn.text = "🔄 전체 서재 보기"
		reset_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		reset_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var r_sb := StyleBoxFlat.new()
		r_sb.bg_color = Color(0.95, 0.91, 0.84, 1.0)
		r_sb.border_width_left = 1
		r_sb.border_width_top = 1
		r_sb.border_width_right = 1
		r_sb.border_width_bottom = 1
		r_sb.border_color = Color(0.80, 0.72, 0.62, 1.0)
		r_sb.corner_radius_top_left = 8
		r_sb.corner_radius_top_right = 8
		r_sb.corner_radius_bottom_left = 8
		r_sb.corner_radius_bottom_right = 8
		r_sb.content_margin_left = 12
		r_sb.content_margin_right = 12
		r_sb.content_margin_top = 6
		r_sb.content_margin_bottom = 6
		reset_btn.add_theme_stylebox_override("normal", r_sb)
		reset_btn.add_theme_color_override("font_color", Color(0.28, 0.22, 0.18, 1.0))
		reset_btn.add_theme_font_size_override("font_size", 12)
		reset_btn.pressed.connect(_reset_all_filters)
		reset_btn.tooltip_text = "좌클릭: 전체 서재 복원 · 우클릭: 복원 후 랜덤 추천 미리보기"
		reset_btn.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
				_reset_all_filters()
				pick_random_item(false)
		)
		empty_box.add_child(empty_lbl)
		empty_box.add_child(reset_btn)
		card_grid.add_child(empty_box)
		return

	for it in filtered:
		var card = CardItemScene.instantiate()
		card_grid.add_child(card)
		card.setup(it)
		card.clicked.connect(_on_card_clicked)
		if card.has_signal("quick_advanced"):
			card.quick_advanced.connect(_on_card_quick_advanced)
		if card.has_signal("quote_copy_requested"):
			card.quote_copy_requested.connect(_on_card_quote_copy_requested)
		if card.has_signal("author_filter_requested"):
			card.author_filter_requested.connect(_on_card_author_filter_requested)

func _on_card_author_filter_requested(it) -> void:
	if it == null or search_input == null:
		return
	search_input.text = it.author_or_series
	_render_cards()
	_show_toast("🔍 작가·시리즈 검색: %s (%s)" % [it.author_or_series, _get_filtered_cards_summary()])

func _on_card_quote_copy_requested(it) -> void:
	if it == null:
		return
	var q_txt: String = it.memo if it.memo != "" else "소장 기록"
	var text := "📖 「%s」 — \"%s\" (%s · %s)" % [it.title, q_txt, it.author_or_series, ArchiveStateClass.format_krw(it.get_item_value())]
	DisplayServer.clipboard_set(text)
	_show_toast("📋 카드 감상 요약 클립보드 복사됨: 「%s」" % it.title)

func _on_card_quick_advanced(it) -> void:
	archive_state.save_to_file()
	_update_stats()
	_render_spine_shelf()
	_show_toast("📖 %s %d권 완독 기록 완료! (%s)" % [it.title, it.volumes.size(), ArchiveStateClass.format_krw(it.get_item_value())])

func _on_stat_firsts_clicked() -> void:
	filter_firsts_only = true
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = -1
	_highlight_tabs(tab_all)
	_render_cards()
	_show_toast("🔖 초판 스탬프 보유 작품 (%s)만 모아봅니다." % _get_filtered_cards_summary())

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
	_show_toast("🏷️ 스마트 태그 %s (%s)" % [tag, _get_filtered_cards_summary()])
	return card_grid.get_child_count()

func _set_sort_mode(target_mode: int) -> void:
	sort_mode = (target_mode % 4 + 4) % 4
	if sort_btn != null:
		match sort_mode:
			0: sort_btn.text = "↕ 기본순"
			1: sort_btn.text = "↕ 다독순"
			2: sort_btn.text = "↕ 최신순"
			3: sort_btn.text = "↕ 가치순"
	_render_cards()
	var mode_name = "기본 등록순" if sort_mode == 0 else ("권수 많은 순(다독순)" if sort_mode == 1 else ("최근 기록순(최신순)" if sort_mode == 2 else "소장 가치순(고액순)"))
	_show_toast("📚 정렬 기준 변경: %s (%s)" % [mode_name, _get_filtered_cards_summary()])

func _step_sort(delta: int) -> void:
	_set_sort_mode(sort_mode + delta)

func _on_sort_btn_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		_set_sort_mode(0)
		return
	_step_sort(1)

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
	var total_val = archive_state.get_total_collection_value() if archive_state.has_method("get_total_collection_value") else 0
	var total_rereads = archive_state.get_total_rereads() if archive_state.has_method("get_total_rereads") else archive_state.items.size()
	var val_str = archive_state.format_krw(total_val)
	var avg_lib = archive_state.get_average_library_rating() if archive_state.has_method("get_average_library_rating") else 5.0
	var text = "📊 소장: %d종 (%d권) · 완독률: %d%% · 평균 ★%s · 북마크: %d권 · 밑줄: %d개 · 총 재독: %d회 · 총 가치: %s" % [
		archive_state.items.size(),
		archive_state.get_total_volumes(),
		prog,
		String.num(avg_lib, 1),
		total_bms,
		sum_quotes,
		total_rereads,
		val_str
	]
	_show_toast(text)
	return text

func _update_modal_nav_tooltips(item) -> void:
	if detail_modal == null or archive_state == null or archive_state.items.is_empty():
		return
	var total: int = archive_state.items.size()
	var idx: int = archive_state.items.find(item)
	if idx == -1:
		idx = 0
	var prev_idx: int = (idx - 1 + total) % total
	var next_idx: int = (idx + 1) % total
	var prev_btn = detail_modal.find_child("PrevItemBtn", true, false)
	var next_btn = detail_modal.find_child("NextItemBtn", true, false)
	var page_lbl = detail_modal.find_child("PageBadgeLabel", true, false)
	if prev_btn != null:
		prev_btn.tooltip_text = "◀ 이전 일기 (%d/%d): %s (← · 우클릭: 처음)" % [prev_idx + 1, total, archive_state.items[prev_idx].title]
	if next_btn != null:
		next_btn.tooltip_text = "▶ 다음 일기 (%d/%d): %s (→ · 우클릭: 끝)" % [next_idx + 1, total, archive_state.items[next_idx].title]
	if page_lbl != null:
		page_lbl.text = "%d/%d" % [idx + 1, total]

func _open_detail_modal(item) -> void:
	if item == null or detail_modal == null:
		return
	detail_modal.open(item)
	_update_modal_nav_tooltips(item)

func _on_card_clicked(item) -> void:
	_open_detail_modal(item)

func _open_first_filtered_card() -> void:
	if card_grid != null and card_grid.get_child_count() > 0:
		var first_node = card_grid.get_child(0)
		if first_node != null and first_node.get("current_item") != null:
			_open_detail_modal(first_node.current_item)
			return
	_show_toast("📭 검색 결과가 없습니다. (ESC로 초기화)")

func _trigger_instant_json_backup() -> void:
	archive_state.save_to_file()
	_show_toast("💾 로컬 JSON 서재 백업 저장 완료 (%s)" % _get_filtered_cards_summary())

func _reset_all_filters() -> void:
	if search_input != null:
		search_input.text = ""
	_on_tab_all_pressed()
	_show_toast("📚 전체 서재가 복원되었습니다. (%s)" % _get_filtered_cards_summary())

func _on_tab_all_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = -1
	_highlight_tabs(tab_all)
	_render_cards()
	_show_toast("📚 전체 서재 (%s)를 펼쳤습니다." % _get_filtered_cards_summary())

func _on_tab_manga_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = 0
	_highlight_tabs(tab_manga)
	_render_cards()
	_show_toast("📖 이북·단행본 (%s)만 모아봅니다." % _get_filtered_cards_summary())

func _on_tab_gacha_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = false
	archive_state.current_filter = 1
	_highlight_tabs(tab_gacha)
	_render_cards()
	_show_toast("🔮 가챠·굿즈 (%s)만 모아봅니다." % _get_filtered_cards_summary())

func _get_filtered_cards_summary() -> String:
	var count: int = 0
	var total_val: int = 0
	for c in card_grid.get_children():
		if not c.is_queued_for_deletion() and c.get("current_item") != null:
			count += 1
			total_val += c.current_item.get_item_value()
	return "%d종 · %s" % [count, ArchiveStateClass.format_krw(total_val)]

func _on_tab_complete_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = true
	filter_favorites_only = false
	archive_state.current_filter = 0
	_highlight_tabs(tab_complete)
	_render_cards()
	_show_toast("💮 완독 작품 (%s)만 모아봅니다." % _get_filtered_cards_summary())

func _on_tab_fav_pressed() -> void:
	filter_firsts_only = false
	filter_completed_only = false
	filter_favorites_only = true
	archive_state.current_filter = -1
	_highlight_tabs(tab_fav)
	_render_cards()
	_show_toast("★ 내 인생 최애 만점(5.0) 작품 (%s)만 모아봅니다." % _get_filtered_cards_summary())

func _highlight_tabs(active_btn: Button) -> void:
	for btn in [tab_all, tab_manga, tab_gacha, tab_complete, tab_fav]:
		if btn != null:
			btn.modulate = Color(1, 1, 1, 0.65) if btn != active_btn else Color(1, 1, 1, 1)

func pick_random_item(open_modal: bool = true):
	if archive_state == null or archive_state.items.is_empty():
		return null
	var r_idx = randi() % archive_state.items.size()
	var picked = archive_state.items[r_idx]
	if open_modal:
		_open_detail_modal(picked)
		_show_toast("🎲 오늘 서재가 추천하는 작품: " + picked.title + " · " + picked.reading_weather + " · " + picked.reading_spot)
	else:
		_show_toast("🎲 오늘의 추천 미리보기: 「%s」 · %s · %s · %s" % [picked.title, picked.reading_weather, picked.reading_spot, ArchiveStateClass.format_krw(picked.get_item_value())])
	return picked

func _on_random_pick_btn_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		var picked = pick_random_item(false)
		if picked != null and search_input != null:
			search_input.text = picked.title
			_render_cards()
			_show_toast("🎲 랜덤 추천 서재 필터: %s" % picked.title)
		return
	pick_random_item()

func _on_search_text_changed(new_text: String) -> void:
	_render_cards()
	var q: String = new_text.strip_edges()
	if q.is_empty():
		_show_toast("📚 전체 서재 (%s)를 펼쳤습니다." % _get_filtered_cards_summary())
	else:
		_show_toast("🔍 '%s' 검색 결과 (%s)" % [q, _get_filtered_cards_summary()])

func _on_add_btn_pressed() -> void:
	add_modal.open()

func _on_web_scrape_btn_pressed() -> void:
	var added = archive_state.scrape_web_preset(web_preset_cursor)
	web_preset_cursor = (web_preset_cursor + 1) % archive_state.WEB_PRESET_CATALOG.size()
	_update_stats()
	_on_tab_all_pressed()
	_show_toast("🌐 웹 표지 자동 스크랩 완료: %s (%s)" % [added.title, _get_filtered_cards_summary()])

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
	_on_tab_all_pressed()
	_show_toast("📸 카메라 찰칵! 실물 표지가 등록되었습니다: %s (%s)" % [added.title, _get_filtered_cards_summary()])

func _step_theme(delta: int) -> void:
	theme_cursor = (theme_cursor + delta + ROOM_THEMES.size()) % ROOM_THEMES.size()
	var t = ROOM_THEMES[theme_cursor]
	bg_rect.color = t["bg"]
	_show_toast("🎨 진열장 배경 테마 변경: " + t["name"])

func _reset_theme() -> void:
	theme_cursor = 0
	var t = ROOM_THEMES[0]
	bg_rect.color = t["bg"]
	_show_toast("🎨 기본 속지 테마 복원: " + t["name"])

func _on_theme_btn_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		_reset_theme()
		return
	_step_theme(1)

func _on_item_submitted(p_title: String, p_cat: int, p_author: String, p_color: String = "#b91c1c", p_quote: String = "") -> void:
	var ic = "📕" if p_cat == 0 else "🔮"
	var added = archive_state.add_item(p_title, p_cat, p_author, p_color, ic, "★ 직접 쓴 다꾸 일기장", "나만의책")
	if p_quote != "":
		added.memo = p_quote
		if added.volumes.size() > 0:
			added.volumes[0]["quote"] = p_quote
		archive_state.save_to_file()
	_update_stats()
	_on_tab_all_pressed()
	_show_toast("✨ 새 일기장이 서재에 꽂혔습니다: %s (%s)" % [p_title, _get_filtered_cards_summary()])

func _on_item_deleted(item) -> void:
	var del_title: String = item.title if item != null else "소장품"
	archive_state.remove_item(item.id)
	_update_stats()
	_render_cards()
	_show_toast("🗑️ 「%s」 일기장이 삭제되었습니다. (%s)" % [del_title, _get_filtered_cards_summary()])

func _on_volume_added(item) -> void:
	if item != null:
		item.updated_at = int(Time.get_unix_time_from_system())
	archive_state.save_to_file()
	_update_stats()
	_render_cards()
	if item != null:
		_show_toast("📖 %s %d권 기록 추가! (%s)" % [item.title, item.volumes.size(), ArchiveStateClass.format_krw(item.get_item_value())])
	else:
		_show_toast("📖 다음 권이 추가되고 로컬 JSON에 저장되었습니다.")

func _unhandled_input(event: InputEvent) -> void:
	if (detail_modal != null and detail_modal.visible) or (add_modal != null and add_modal.visible):
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var is_find: bool = (event.keycode == KEY_F and (event.ctrl_pressed or event.meta_pressed)) or (event.keycode == KEY_SLASH and not event.ctrl_pressed and not event.meta_pressed)
		if is_find and search_input != null:
			search_input.grab_focus()
			search_input.select_all()
			get_viewport().set_input_as_handled()
		elif search_input == null or not search_input.has_focus():
			match event.keycode:
				KEY_0:
					_reset_all_filters()
					get_viewport().set_input_as_handled()
				KEY_1:
					_on_tab_all_pressed()
					get_viewport().set_input_as_handled()
				KEY_2:
					_on_tab_manga_pressed()
					get_viewport().set_input_as_handled()
				KEY_3:
					_on_tab_gacha_pressed()
					get_viewport().set_input_as_handled()
				KEY_4:
					_on_tab_complete_pressed()
					get_viewport().set_input_as_handled()
				KEY_5:
					_on_tab_fav_pressed()
					get_viewport().set_input_as_handled()
				KEY_S:
					_step_sort(-1 if event.shift_pressed else 1)
					get_viewport().set_input_as_handled()
				KEY_R:
					pick_random_item(not event.shift_pressed)
					get_viewport().set_input_as_handled()
				KEY_N:
					_on_add_btn_pressed()
					get_viewport().set_input_as_handled()
				KEY_T:
					_step_theme(-1 if event.shift_pressed else 1)
					get_viewport().set_input_as_handled()
				KEY_M:
					cycle_ambient_sound(-1 if event.shift_pressed else 1)
					get_viewport().set_input_as_handled()
				KEY_Q:
					_step_today_quote(-1 if event.shift_pressed else 1)
					get_viewport().set_input_as_handled()
				KEY_I:
					show_library_infographic()
					get_viewport().set_input_as_handled()
				KEY_C:
					copy_summary_to_clipboard()
					get_viewport().set_input_as_handled()
				KEY_H:
					_show_shortcut_cheatsheet()
					get_viewport().set_input_as_handled()

func _show_shortcut_cheatsheet() -> void:
	_show_toast("⌨️ 단축키: [0] 초기화 · [1~5] 탭 · [/] 검색 · [Space] 책장 · [S/T/M/Q] 순환(Shift+역순) · [R] 추천(Shift+미리보기) · [N] 새 일기 · [I] 요약 · [C] 복사 · [우클릭] 역순환·백업")

func _on_modal_help_requested() -> void:
	_show_toast("⌨️ 모달 단축키: [←/→] 넘김 · [Home/End] 처음·끝 · [1~4] 인장 · [+/-] 권 · [X] 아이콘 · [Q] 표지색 · [Y] 회독 · [Z] 상태 · [I] 잉크 · [N] 펜촉 · [W] 마테 · [S] 스티커 · [R] 레어도 · [P] 속지 · [O] 띠지 · [M] 기분 · [G] 등급 · [T] 태그 · [F] 마감 · [A] 경로 · [B] 보관 · [D] 복수 · [K] 최애캐 · [U] 날씨 · [J] 장소 · [V] 가치 · [Shift+순환키] 역순환 · [E] 문장 · [L] 형광펜 · [C] 복사(Shift+C: 리포트) · [Del] 삭제 · [ESC] 닫기")

func _on_modal_navigate_requested(delta: int) -> void:
	if archive_state == null or archive_state.items.is_empty():
		return
	var total: int = archive_state.items.size()
	var idx: int = archive_state.items.find(detail_modal.current_item)
	if idx == -1:
		idx = 0
	var next_idx: int = 0
	if delta <= -9999:
		next_idx = 0
	elif delta >= 9999:
		next_idx = total - 1
	else:
		next_idx = (idx + delta + total) % total
	var next_item = archive_state.items[next_idx]
	_open_detail_modal(next_item)
	_show_toast("📖 책장 넘김 (%d/%d): %s" % [next_idx + 1, total, next_item.title])

func _on_card_copied(item) -> void:
	if item != null:
		_show_toast("💌 「" + item.title + "」 독서 감상 카드가 클립보드에 복사되었습니다!")

func _on_volume_removed(item) -> void:
	if item != null:
		item.updated_at = int(Time.get_unix_time_from_system())
	archive_state.save_to_file()
	_update_stats()
	_refresh_today_quote()
	_render_cards()
	if item != null:
		_show_toast("🗑️ %s 마지막 권 기록 삭제 (현재 %d권 · %s)" % [item.title, item.volumes.size(), ArchiveStateClass.format_krw(item.get_item_value())])

func _on_diary_updated(item) -> void:
	if item != null:
		item.updated_at = int(Time.get_unix_time_from_system())
	archive_state.save_to_file()
	_update_stats()
	_refresh_today_quote()
	_render_cards()
	_show_toast("💮 일기장 스탬프·밑줄 문장이 저장되었습니다: " + item.title)
