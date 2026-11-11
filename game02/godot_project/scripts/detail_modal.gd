class_name DetailModal
extends Control

signal item_deleted(item)
signal volume_added(item)

@onready var title_label: Label = $Panel/VBox/Header/HBox/TitleLabel
@onready var cat_badge: Label = $Panel/VBox/Header/HBox/CatBadge
@onready var cover_rect: ColorRect = $Panel/VBox/BodyMargin/Body/TopInfo/CoverRect
@onready var cover_icon: Label = $Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/CoverIcon
@onready var author_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/AuthorLabel
@onready var tag_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/TagLabel
@onready var memo_label: Label = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/MemoLabel
@onready var vol_section: VBoxContainer = $Panel/VBox/BodyMargin/Body/VolSection
@onready var vol_list: VBoxContainer = $Panel/VBox/BodyMargin/Body/VolSection/Scroll/VolList
@onready var add_vol_btn: Button = $Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/AddVolBtn

var current_item = null

func _ready() -> void:
	visible = false

func open(item) -> void:
	current_item = item
	title_label.text = "📔 " + item.title
	author_label.text = "작가 · " + (item.author_or_series if item.author_or_series != "" else "미상")
	tag_label.text = "💮 스탬프: " + item.status_tag + "  |  " + item.obi_text
	memo_label.text = "🖋️ \"" + (item.memo if item.memo != "" else "오늘 읽은 페이지의 감동을 일기장에 기록합니다.") + "\""
	
	cover_rect.color = Color.from_string(item.cover_color, Color(0.65, 0.25, 0.2))
	cover_icon.text = item.icon_emoji if item.icon_emoji != "" else "📖"

	if item.category == 0: # MANGA
		cat_badge.text = " [이북·단행본 일기] "
		vol_section.visible = true
		add_vol_btn.visible = true
		_render_volumes()
	else:
		cat_badge.text = " [가챠·굿즈 스크랩] "
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
		empty_lbl.text = "아직 기록된 권별 일기가 없습니다."
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.5, 0.44, 0.38))
		vol_list.add_child(empty_lbl)
		return

	for v in current_item.volumes:
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
		vol_lbl.custom_minimum_size = Vector2(32, 0)
		
		var status_lbl = Label.new()
		var is_first = v.get("status", "") == "first"
		status_lbl.text = "🔖초판특전" if is_first else "✓소장완료"
		status_lbl.add_theme_font_size_override("font_size", 10)
		status_lbl.add_theme_color_override("font_color", Color(0.78, 0.35, 0.2) if is_first else Color(0.29, 0.45, 0.36))
		
		var quote_lbl = Label.new()
		var q = v.get("quote", "")
		quote_lbl.text = "🖋️ \"" + q + "\"" if q != "" else "🖋️ 읽고 남긴 한 줄 일기"
		quote_lbl.add_theme_font_size_override("font_size", 10)
		quote_lbl.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))
		quote_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		quote_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		var star_lbl = Label.new()
		var r = v.get("rating", 5)
		star_lbl.text = "★".repeat(r)
		star_lbl.add_theme_font_size_override("font_size", 11)
		star_lbl.add_theme_color_override("font_color", Color(0.78, 0.35, 0.2))
		
		hbox.add_child(vol_lbl)
		hbox.add_child(status_lbl)
		hbox.add_child(quote_lbl)
		hbox.add_child(star_lbl)
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

func _on_delete_btn_pressed() -> void:
	if current_item != null:
		item_deleted.emit(current_item)
		close()
