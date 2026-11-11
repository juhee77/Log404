class_name DetailModal
extends Control

signal item_deleted(item)
signal volume_added(item)

@onready var title_label: Label = $Panel/VBox/Header/HBox/TitleLabel
@onready var cat_badge: Label = $Panel/VBox/Header/HBox/CatBadge
@onready var author_label: Label = $Panel/VBox/Body/TopInfo/MetaVBox/AuthorLabel
@onready var tag_label: Label = $Panel/VBox/Body/TopInfo/MetaVBox/TagLabel
@onready var memo_label: Label = $Panel/VBox/Body/TopInfo/MetaVBox/MemoLabel
@onready var vol_section: VBoxContainer = $Panel/VBox/Body/VolSection
@onready var vol_list: VBoxContainer = $Panel/VBox/Body/VolSection/Scroll/VolList
@onready var add_vol_btn: Button = $Panel/VBox/Body/TopInfo/MetaVBox/BtnRow/AddVolBtn

var current_item = null

func _ready() -> void:
	visible = false

func open(item) -> void:
	current_item = item
	title_label.text = item.title
	author_label.text = "작가/시리즈: " + (item.author_or_series if item.author_or_series != "" else "미상")
	tag_label.text = "상태: " + item.status_tag
	memo_label.text = item.memo if item.memo != "" else "남겨진 메모가 없습니다."
	
	if item.category == 0: # MANGA
		cat_badge.text = "만화책"
		vol_section.visible = true
		add_vol_btn.visible = true
		_render_volumes()
	else:
		cat_badge.text = "가챠·피규어"
		vol_section.visible = false
		add_vol_btn.visible = false
	
	visible = true

func close() -> void:
	visible = false

func _render_volumes() -> void:
	for child in vol_list.get_children():
		child.queue_free()
	
	if current_item == null or current_item.volumes.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "등록된 권별 기록이 없습니다."
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vol_list.add_child(empty_lbl)
		return

	for v in current_item.volumes:
		var panel = PanelContainer.new()
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		var vol_lbl = Label.new()
		vol_lbl.text = str(v.get("vol", 1)) + "권"
		vol_lbl.add_theme_font_size_override("font_size", 12)
		vol_lbl.custom_minimum_size = Vector2(30, 0)
		
		var status_lbl = Label.new()
		var is_first = v.get("status", "") == "first"
		status_lbl.text = "👑 초판특전" if is_first else "✅ 소장완료"
		status_lbl.add_theme_font_size_override("font_size", 10)
		status_lbl.add_theme_color_override("font_color", Color(0.85, 0.6, 0.1) if is_first else Color(0.2, 0.7, 0.4))
		
		var quote_lbl = Label.new()
		var q = v.get("quote", "")
		quote_lbl.text = '"' + q + '"' if q != "" else ""
		quote_lbl.add_theme_font_size_override("font_size", 11)
		quote_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		quote_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var star_lbl = Label.new()
		var r = v.get("rating", 5)
		star_lbl.text = "★".repeat(r)
		star_lbl.add_theme_font_size_override("font_size", 11)
		star_lbl.add_theme_color_override("font_color", Color(0.95, 0.7, 0.1))
		
		hbox.add_child(vol_lbl)
		hbox.add_child(status_lbl)
		hbox.add_child(quote_lbl)
		hbox.add_child(star_lbl)
		panel.add_child(hbox)
		vol_list.add_child(panel)

func _on_close_btn_pressed() -> void:
	close()

func _on_add_vol_btn_pressed() -> void:
	if current_item != null:
		var next_num = current_item.volumes.size() + 1
		current_item.add_volume(next_num, "owned", 5, "")
		_render_volumes()
		volume_added.emit(current_item)

func _on_delete_btn_pressed() -> void:
	if current_item != null:
		item_deleted.emit(current_item)
		close()
