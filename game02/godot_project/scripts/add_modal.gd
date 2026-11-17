class_name AddModal
extends Control

signal item_submitted(title: String, category: int, author: String, color_hex: String, quote_text: String)

@onready var title_input: LineEdit = $Panel/VBox/BodyMargin/Body/TitleInput
@onready var author_input: LineEdit = $Panel/VBox/BodyMargin/Body/AuthorInput
@onready var quote_input: LineEdit = $Panel/VBox/BodyMargin/Body/QuoteInput
@onready var cat_option: OptionButton = $Panel/VBox/BodyMargin/Body/CatOption
@onready var color_row: HBoxContainer = $Panel/VBox/BodyMargin/Body/ColorRow
@onready var submit_btn: Button = $Panel/VBox/BodyMargin/Body/SubmitBtn
@onready var close_btn: Button = $Panel/VBox/Header/HBox/CloseBtn

const COVER_SWATCHES = [
	{"name": "크림슨", "hex": "#b91c1c"},
	{"name": "코발트", "hex": "#1d4ed8"},
	{"name": "테라코타", "hex": "#c2410c"},
	{"name": "로즈", "hex": "#be185d"},
	{"name": "포레스트", "hex": "#15803d"},
	{"name": "바이올렛", "hex": "#6d28d9"}
]

var selected_color: String = "#b91c1c"

func _ready() -> void:
	visible = false
	cat_option.clear()
	cat_option.add_item("📖 이북 · 만화 단행본 일기", 0)
	cat_option.add_item("🔮 가챠 · 굿즈 스크랩 노트", 1)
	_build_color_swatches()
	_style_inputs()
	title_input.text_submitted.connect(func(_t): author_input.grab_focus())
	author_input.text_submitted.connect(func(_t): _on_submit_btn_pressed())
	quote_input.text_submitted.connect(func(_t): _on_submit_btn_pressed())
	var dimmer: Control = get_node_or_null("Dimmer")
	if dimmer != null:
		dimmer.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				close()
		)

func _build_color_swatches() -> void:
	for child in color_row.get_children():
		child.queue_free()
	for sw in COVER_SWATCHES:
		var btn = Button.new()
		btn.text = sw["name"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 9)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.from_string(sw["hex"], Color(0.7, 0.2, 0.2))
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		var hex_val = sw["hex"]
		btn.pressed.connect(func(): select_color(hex_val))
		color_row.add_child(btn)
	_highlight_selected_swatch()

func _style_inputs() -> void:
	var inp_sb = StyleBoxFlat.new()
	inp_sb.bg_color = Color(0.98, 0.96, 0.92, 1)
	inp_sb.border_width_bottom = 2
	inp_sb.border_color = Color(0.80, 0.72, 0.62, 1)
	inp_sb.content_margin_left = 8
	for le in [title_input, author_input, quote_input]:
		le.clear_button_enabled = true
		le.add_theme_stylebox_override("normal", inp_sb)
		le.add_theme_color_override("font_color", Color(0.18, 0.14, 0.11))
		le.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.42))
	for ctrl in [submit_btn, close_btn, cat_option]:
		if ctrl != null:
			ctrl.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var ink_sb = StyleBoxFlat.new()
	ink_sb.bg_color = Color(0.22, 0.16, 0.13, 1)
	ink_sb.corner_radius_top_left = 8
	ink_sb.corner_radius_top_right = 8
	ink_sb.corner_radius_bottom_left = 8
	ink_sb.corner_radius_bottom_right = 8
	submit_btn.add_theme_stylebox_override("normal", ink_sb)
	submit_btn.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))

	var cream_btn = StyleBoxFlat.new()
	cream_btn.bg_color = Color(0.95, 0.91, 0.84, 1)
	cream_btn.corner_radius_top_left = 6
	cream_btn.corner_radius_top_right = 6
	cream_btn.corner_radius_bottom_left = 6
	cream_btn.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("normal", cream_btn)
	close_btn.add_theme_color_override("font_color", Color(0.32, 0.25, 0.20))

func select_color(hex_code: String) -> void:
	selected_color = hex_code
	_highlight_selected_swatch()

func _highlight_selected_swatch() -> void:
	if color_row == null:
		return
	var children = color_row.get_children()
	for i in range(min(children.size(), COVER_SWATCHES.size())):
		var btn = children[i]
		if not (btn is Button):
			continue
		var sw = COVER_SWATCHES[i]
		var is_sel = (selected_color.to_lower() == sw["hex"].to_lower())
		btn.text = ("✓ " + sw["name"]) if is_sel else sw["name"]
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.from_string(sw["hex"], Color(0.7, 0.2, 0.2))
		sb.border_width_left = 2 if is_sel else 0
		sb.border_width_top = 2 if is_sel else 0
		sb.border_width_right = 2 if is_sel else 0
		sb.border_width_bottom = 2 if is_sel else 0
		sb.border_color = Color(0.99, 0.96, 0.88, 1)
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_left = 6
		sb.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sb)

func open() -> void:
	title_input.text = ""
	title_input.placeholder_text = "작품·굿즈 제목 (예: 슬램덩크 신장재편판)"
	author_input.text = ""
	quote_input.text = ""
	cat_option.selected = 0
	selected_color = "#b91c1c"
	_highlight_selected_swatch()
	visible = true
	title_input.grab_focus()

func close() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()

func _on_close_btn_pressed() -> void:
	close()

func _on_submit_btn_pressed() -> void:
	var t = title_input.text.strip_edges()
	if t.is_empty():
		title_input.placeholder_text = "⚠️ 작품 제목을 먼저 입력해주세요!"
		title_input.grab_focus()
		return
	var cat = cat_option.selected
	var a = author_input.text.strip_edges()
	var q = quote_input.text.strip_edges()
	item_submitted.emit(t, cat, a, selected_color, q)
	close()
