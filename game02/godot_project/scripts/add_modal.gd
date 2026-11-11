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

func _style_inputs() -> void:
	var inp_sb = StyleBoxFlat.new()
	inp_sb.bg_color = Color(0.98, 0.96, 0.92, 1)
	inp_sb.border_width_bottom = 2
	inp_sb.border_color = Color(0.80, 0.72, 0.62, 1)
	inp_sb.content_margin_left = 8
	for le in [title_input, author_input, quote_input]:
		le.add_theme_stylebox_override("normal", inp_sb)
		le.add_theme_color_override("font_color", Color(0.18, 0.14, 0.11))
		le.add_theme_color_override("font_placeholder_color", Color(0.55, 0.48, 0.42))

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

func open() -> void:
	title_input.text = ""
	author_input.text = ""
	quote_input.text = ""
	cat_option.selected = 0
	selected_color = "#b91c1c"
	visible = true

func close() -> void:
	visible = false

func _on_close_btn_pressed() -> void:
	close()

func _on_submit_btn_pressed() -> void:
	var t = title_input.text.strip_edges()
	if t.is_empty():
		return
	var cat = cat_option.selected
	var a = author_input.text.strip_edges()
	var q = quote_input.text.strip_edges()
	item_submitted.emit(t, cat, a, selected_color, q)
	close()
