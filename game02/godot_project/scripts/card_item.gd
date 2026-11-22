class_name CardItem
extends PanelContainer

const ArchiveStateClass = preload("res://scripts/archive_state.gd")
const UiTokensClass = preload("res://scripts/ui_tokens.gd")

signal card_clicked(item)

var current_item = null
var _palette: Dictionary = UiTokensClass.get_palette("cream")

var _cover_panel: PanelContainer
var _cat_lbl: Label
var _stamp_lbl: Label
var _cover_title_lbl: Label
var _cover_author_lbl: Label
var _meta_left_lbl: Label
var _meta_right_lbl: Label
var _progress_bar: ProgressBar

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(180, 256)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_ui()

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	# Editorial Book Cover (Rounded + Spine Crease)
	_cover_panel = PanelContainer.new()
	_cover_panel.custom_minimum_size = Vector2(0, 186)
	_cover_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_cover_panel)

	var cov_margin := MarginContainer.new()
	cov_margin.add_theme_constant_override("margin_left", 10)
	cov_margin.add_theme_constant_override("margin_right", 10)
	cov_margin.add_theme_constant_override("margin_top", 10)
	cov_margin.add_theme_constant_override("margin_bottom", 12)
	cov_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover_panel.add_child(cov_margin)

	var cov_vbox := VBoxContainer.new()
	cov_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_margin.add_child(cov_vbox)

	# Top Badges Row
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 6)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(top_row)

	_cat_lbl = Label.new()
	_cat_lbl.add_theme_font_size_override("font_size", 10)
	_cat_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	_cat_lbl.add_theme_stylebox_override("normal", UiTokensClass.make_box(Color(0, 0, 0, 0.30), 99, Color(0, 0, 0, 0), 0, 8, 2))
	_cat_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(_cat_lbl)

	var spacer_top := Control.new()
	spacer_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(spacer_top)

	_stamp_lbl = Label.new()
	_stamp_lbl.add_theme_font_size_override("font_size", 10)
	_stamp_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.96))
	_stamp_lbl.add_theme_stylebox_override("normal", UiTokensClass.make_box(Color(1, 1, 1, 0.22), 99, Color(0, 0, 0, 0), 0, 8, 2))
	_stamp_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(_stamp_lbl)

	# Middle push spacer
	var mid_spacer := Control.new()
	mid_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(mid_spacer)

	# Bottom Editorial Title & Author inside cover
	_cover_title_lbl = Label.new()
	_cover_title_lbl.add_theme_font_size_override("font_size", 14)
	_cover_title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	_cover_title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cover_title_lbl.max_lines_visible = 2
	_cover_title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_cover_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(_cover_title_lbl)

	_cover_author_lbl = Label.new()
	_cover_author_lbl.add_theme_font_size_override("font_size", 11)
	_cover_author_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.82))
	_cover_author_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_cover_author_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(_cover_author_lbl)

	# Bottom Info Area (Below Cover — NO duplicate title!)
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 6)
	info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(info_vbox)

	var meta_row := HBoxContainer.new()
	meta_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(meta_row)

	_meta_left_lbl = Label.new()
	_meta_left_lbl.add_theme_font_size_override("font_size", 12)
	_meta_left_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_meta_left_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta_row.add_child(_meta_left_lbl)

	_meta_right_lbl = Label.new()
	_meta_right_lbl.add_theme_font_size_override("font_size", 12)
	_meta_right_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_meta_right_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta_row.add_child(_meta_right_lbl)

	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(0, 6)
	_progress_bar.show_percentage = false
	_progress_bar.max_value = 100.0
	_progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_progress_bar)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_item != null:
			card_clicked.emit(current_item)

func get_reading_progress() -> float:
	if current_item == null:
		return 0.0
	if current_item.status_tag == "전권완결" or current_item.status_tag == "완독":
		return 100.0
	if current_item.target_volumes > 0:
		return clampf(float(current_item.volumes.size()) / float(current_item.target_volumes) * 100.0, 10.0, 100.0)
	if current_item.category == 1:
		return 100.0
	return clampf(float(current_item.volumes.size()) * 25.0, 20.0, 100.0)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], 16, p["border"], 1, 10, 10, p["shadow"], 6))
	_meta_left_lbl.add_theme_color_override("font_color", p["ink"])
	_meta_right_lbl.add_theme_color_override("font_color", p["ink_sub"])
	var prog := get_reading_progress()
	_progress_bar.add_theme_stylebox_override("background", UiTokensClass.make_box(p["surface_soft"], 4, Color(0, 0, 0, 0), 0, 0, 0))
	var fill_col: Color = p["sage"] if prog >= 100.0 else p["accent"]
	_progress_bar.add_theme_stylebox_override("fill", UiTokensClass.make_box(fill_col, 4, Color(0, 0, 0, 0), 0, 0, 0))

func setup(item, p: Dictionary = {}) -> void:
	current_item = item
	if not p.is_empty():
		_palette = p

	var base_col := Color.from_string(item.cover_color, Color("#C82342"))
	_cover_panel.add_theme_stylebox_override("panel", UiTokensClass.make_cover_box(base_col, 6, 12))

	_cat_lbl.text = "BOOK" if item.category == 0 else "GOODS"
	_stamp_lbl.text = item.status_tag if item.status_tag != "" else "소장중"
	_cover_title_lbl.text = item.title
	_cover_author_lbl.text = item.author_or_series if item.author_or_series != "" else "작가 미상"

	var avg_r: float = item.get_average_rating() if item.has_method("get_average_rating") else 5.0
	var left_prefix: String = "%d권" % item.volumes.size() if item.category == 0 else "소장"
	_meta_left_lbl.text = "%s · ★%.1f" % [left_prefix, avg_r]

	var est_val: int = item.get_item_value() if item.has_method("get_item_value") else int(item.estimated_value)
	_meta_right_lbl.text = ArchiveStateClass.format_krw(est_val)

	_progress_bar.value = get_reading_progress()
	apply_theme(_palette)
