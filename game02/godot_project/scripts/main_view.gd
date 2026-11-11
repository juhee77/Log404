class_name MainView
extends Control

const CardItemScene = preload("res://scenes/card_item.tscn")
const ArchiveStateClass = preload("res://scripts/archive_state.gd")

@onready var stat_items: Label = $VBox/TopBar/StatsVBox/StatRow/StatItems/Val
@onready var stat_vols: Label = $VBox/TopBar/StatsVBox/StatRow/StatVols/Val
@onready var stat_firsts: Label = $VBox/TopBar/StatsVBox/StatRow/StatFirsts/Val
@onready var stat_gacha: Label = $VBox/TopBar/StatsVBox/StatRow/StatGacha/Val

@onready var tab_all: Button = $VBox/FilterBar/HBox/TabAll
@onready var tab_manga: Button = $VBox/FilterBar/HBox/TabManga
@onready var tab_gacha: Button = $VBox/FilterBar/HBox/TabGacha
@onready var search_input: LineEdit = $VBox/FilterBar/HBox/SearchInput

@onready var card_grid: GridContainer = $VBox/Scroll/CardGrid
@onready var detail_modal: Control = $DetailModal
@onready var add_modal: Control = $AddModal

var archive_state = null

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
		btn.modulate = Color(1, 1, 1, 0.6) if btn != active_btn else Color(1, 1, 1, 1)

func _on_search_text_changed(new_text: String) -> void:
	_render_cards()

func _on_add_btn_pressed() -> void:
	add_modal.open()

func _on_item_submitted(p_title: String, p_cat: int, p_author: String) -> void:
	archive_state.add_item(p_title, p_cat, p_author)
	_update_stats()
	_render_cards()

func _on_item_deleted(item) -> void:
	archive_state.remove_item(item.id)
	_update_stats()
	_render_cards()

func _on_volume_added(item) -> void:
	_update_stats()
	_render_cards()
