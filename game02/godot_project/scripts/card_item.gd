class_name CardItem
extends VBoxContainer

const UiTokensClass = preload("res://scripts/ui_tokens.gd")
const DsBadgeClass = preload("res://scripts/ui/ds_badge.gd")

signal card_clicked(item)

var current_item = null
var _palette: Dictionary = UiTokensClass.get_palette("millie")
var _cols: int = 3

var _cover_panel: PanelContainer
var _cover_tex: TextureRect
var _cover_scrim: ColorRect
var _cat_badge
var _done_badge
var _cover_title_lbl: Label
var _title_lbl: Label
var _sub_lbl: Label

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 6)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build_ui()

func _build_ui() -> void:
	_cover_panel = PanelContainer.new()
	_cover_panel.custom_minimum_size = Vector2(0, 158)
	_cover_panel.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_cover_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cover_panel)

	var cov_layer := Control.new()
	cov_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover_panel.add_child(cov_layer)

	_cover_tex = TextureRect.new()
	_cover_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover_tex.visible = false
	_cover_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_layer.add_child(_cover_tex)

	_cover_scrim = ColorRect.new()
	_cover_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover_scrim.color = Color(0.05, 0.05, 0.05, 0.34)
	_cover_scrim.visible = false
	_cover_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_layer.add_child(_cover_scrim)

	var cov_m := MarginContainer.new()
	cov_m.set_anchors_preset(Control.PRESET_FULL_RECT)
	cov_m.add_theme_constant_override("margin_left", 9)
	cov_m.add_theme_constant_override("margin_right", 8)
	cov_m.add_theme_constant_override("margin_top", 8)
	cov_m.add_theme_constant_override("margin_bottom", 10)
	cov_m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_layer.add_child(cov_m)

	var cov_vbox := VBoxContainer.new()
	cov_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_m.add_child(cov_vbox)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 4)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(top_row)

	_cat_badge = DsBadgeClass.create("BOOK", DsBadgeClass.Variant.DARK_OVERLAY, 9)
	top_row.add_child(_cat_badge)

	var sp_top := Control.new()
	sp_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(sp_top)

	_done_badge = DsBadgeClass.create("완독", DsBadgeClass.Variant.MILLIE, 9)
	top_row.add_child(_done_badge)

	var sp_mid := Control.new()
	sp_mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sp_mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(sp_mid)

	_cover_title_lbl = Label.new()
	_cover_title_lbl.add_theme_font_size_override("font_size", 12)
	_cover_title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.98))
	_cover_title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_cover_title_lbl.max_lines_visible = 2
	_cover_title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_cover_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cov_vbox.add_child(_cover_title_lbl)

	var cap_vbox := VBoxContainer.new()
	cap_vbox.add_theme_constant_override("separation", 2)
	cap_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cap_vbox)

	_title_lbl = Label.new()
	_title_lbl.add_theme_font_size_override("font_size", 12)
	_title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap_vbox.add_child(_title_lbl)

	_sub_lbl = Label.new()
	_sub_lbl.add_theme_font_size_override("font_size", 10)
	_sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap_vbox.add_child(_sub_lbl)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_item != null:
			card_clicked.emit(current_item)

func get_reading_progress() -> int:
	if current_item == null:
		return 0
	if current_item.status_tag == "전권완결" or current_item.status_tag == "완독" or current_item.category == 1:
		return 100
	if current_item.target_volumes > 0:
		return clampi(int(round(float(current_item.volumes.size()) / float(current_item.target_volumes) * 100.0)), 10, 100)
	return clampi(current_item.volumes.size() * 25, 20, 100)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	_title_lbl.add_theme_color_override("font_color", p["ink"])
	_sub_lbl.add_theme_color_override("font_color", p["ink_sub"])
	UiTokensClass.theme_ds_tree(self, p)

func setup(item, p: Dictionary = {}, cols: int = 3) -> void:
	current_item = item
	_cols = cols
	if not p.is_empty():
		_palette = p

	_cover_panel.custom_minimum_size = Vector2(0, 210 if cols == 2 else 156)
	_cover_title_lbl.add_theme_font_size_override("font_size", 14 if cols == 2 else 11)

	var base_col := Color.from_string(item.cover_color, Color("#C82342"))
	_cover_panel.add_theme_stylebox_override("panel", UiTokensClass.make_cover_box(base_col, 4, 10))

	var tex := UiTokensClass.load_cover_texture(str(item.cover_path))
	if tex != null:
		_cover_tex.texture = tex
		_cover_tex.visible = true
		_cover_scrim.visible = true
	else:
		_cover_tex.texture = null
		_cover_tex.visible = false
		_cover_scrim.visible = false

	var prog := get_reading_progress()
	_cat_badge.text = "BOOK" if item.category == 0 else "GOODS"
	_done_badge.visible = (prog >= 100)
	_cover_title_lbl.text = item.title
	_title_lbl.text = item.title
	var author_str: String = item.author_or_series if item.author_or_series != "" else "작가 미상"
	_sub_lbl.text = "%s · %d%%" % [author_str, prog]

	apply_theme(_palette)
