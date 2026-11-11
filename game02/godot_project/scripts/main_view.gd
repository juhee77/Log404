class_name MainView
extends Control

const CardItemScene = preload("res://scenes/card_item.tscn")
const ArchiveStateClass = preload("res://scripts/archive_state.gd")

@onready var bg_rect: ColorRect = $Bg
@onready var stat_items: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems/Box/Val
@onready var stat_vols: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols/Box/Val
@onready var stat_firsts: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts/Box/Val
@onready var stat_gacha: Label = $VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha/Box/Val

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

const ROOM_THEMES = [
	{"name": "클린 화이트", "bg": Color(0.95, 0.96, 0.98, 1)},
	{"name": "따뜻한 원목", "bg": Color(0.97, 0.94, 0.90, 1)},
	{"name": "파스텔 핑크", "bg": Color(0.99, 0.94, 0.96, 1)},
	{"name": "라벤더 드림", "bg": Color(0.95, 0.94, 0.99, 1)}
]

func _ready() -> void:
	archive_state = ArchiveStateClass.new()
	archive_state.initialize_defaults()
	
	detail_modal.item_deleted.connect(_on_item_deleted)
	detail_modal.volume_added.connect(_on_volume_added)
	add_modal.item_submitted.connect(_on_item_submitted)
	
	_update_stats()
	_render_cards()

func _update_stats() -> void:
	stat_items.text = str(archive_state.items.size()) + "종"
	stat_vols.text = str(archive_state.get_total_volumes()) + "권"
	stat_firsts.text = str(archive_state.get_first_editions_count()) + "권"
	var g_count = 0
	for it in archive_state.items:
		if it.category == 1: # GACHA
			g_count += 1
	stat_gacha.text = str(g_count) + "개"

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

func _on_item_submitted(p_title: String, p_cat: int, p_author: String) -> void:
	var col = "#6366f1" if p_cat == 0 else "#ec4899"
	var ic = "📕" if p_cat == 0 else "🔮"
	archive_state.add_item(p_title, p_cat, p_author, col, ic, "★ 커스텀 신규 등록", "신규소장")
	_update_stats()
	_render_cards()
	_show_toast("✨ 새 소장품이 책장에 추가되었습니다: " + p_title)

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
