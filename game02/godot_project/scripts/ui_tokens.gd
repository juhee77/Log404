class_name UiTokens
extends RefCounted

const THEMES := {
	"cream": {
		"name": "크림 페이퍼",
		"bg": Color("#F8F5F0"),
		"surface": Color("#FFFFFF"),
		"surface_soft": Color("#F2ECE3"),
		"border": Color("#E8E0D5"),
		"ink": Color("#1F1A17"),
		"ink_sub": Color("#736860"),
		"ink_muted": Color("#9E9288"),
		"accent": Color("#C85A32"),
		"accent_soft": Color("#FDF1EC"),
		"sage": Color("#3D6B59"),
		"sage_soft": Color("#ECF4F0"),
		"danger": Color("#C53030"),
		"danger_soft": Color("#FEECEC"),
		"hl_bg": Color("#FEF08A"),
		"hl_ink": Color("#854D0E"),
		"shadow": Color(0.12, 0.10, 0.09, 0.07)
	},
	"sepia": {
		"name": "웜 세피아",
		"bg": Color("#F1E8D9"),
		"surface": Color("#FAF4E8"),
		"surface_soft": Color("#E8DEC9"),
		"border": Color("#DDD0BA"),
		"ink": Color("#2A2118"),
		"ink_sub": Color("#6E5F4F"),
		"ink_muted": Color("#968674"),
		"accent": Color("#B84D27"),
		"accent_soft": Color("#F5E2D6"),
		"sage": Color("#35614F"),
		"sage_soft": Color("#E0EDE6"),
		"danger": Color("#B92B2B"),
		"danger_soft": Color("#F7DFDF"),
		"hl_bg": Color("#FDE68A"),
		"hl_ink": Color("#78350F"),
		"shadow": Color(0.16, 0.12, 0.08, 0.08)
	},
	"dark": {
		"name": "미드나잇",
		"bg": Color("#171513"),
		"surface": Color("#221F1C"),
		"surface_soft": Color("#2C2824"),
		"border": Color("#38332E"),
		"ink": Color("#F3EFEA"),
		"ink_sub": Color("#B3AAA1"),
		"ink_muted": Color("#7F766D"),
		"accent": Color("#E27A53"),
		"accent_soft": Color(0.89, 0.48, 0.33, 0.18),
		"sage": Color("#69A88E"),
		"sage_soft": Color(0.41, 0.66, 0.56, 0.18),
		"danger": Color("#F87171"),
		"danger_soft": Color(0.97, 0.44, 0.44, 0.16),
		"hl_bg": Color(0.95, 0.82, 0.32, 0.30),
		"hl_ink": Color("#FDE68A"),
		"shadow": Color(0.0, 0.0, 0.0, 0.32)
	}
}

const COVER_COLORS := [
	"#C82342", "#0077B6", "#D9480F", "#DB2777", "#6D28D9", "#2E5947"
]

const INK_PRESETS := [
	{"name": "에스프레소", "hex": "#2C221E"},
	{"name": "버건디", "hex": "#8C2D3B"},
	{"name": "세피아", "hex": "#7D542E"},
	{"name": "포레스트", "hex": "#2E5947"}
]

const STAMP_PRESETS := ["전권완결", "초판특전", "인생최애", "소장중", "위시"]

static func get_palette(theme_id: String) -> Dictionary:
	return THEMES.get(theme_id, THEMES["cream"])

static func make_box(bg: Color, radius: int = 14, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0, pad_x: int = 12, pad_y: int = 8, shadow_col: Color = Color(0, 0, 0, 0), shadow_sz: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	if border_w > 0:
		sb.border_width_left = border_w
		sb.border_width_top = border_w
		sb.border_width_right = border_w
		sb.border_width_bottom = border_w
		sb.border_color = border_col
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	if shadow_sz > 0:
		sb.shadow_color = shadow_col
		sb.shadow_size = shadow_sz
		sb.shadow_offset = Vector2(0, 3)
	return sb

static func make_cover_box(base_color: Color, r_left: int = 6, r_right: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = base_color
	sb.corner_radius_top_left = r_left
	sb.corner_radius_bottom_left = r_left
	sb.corner_radius_top_right = r_right
	sb.corner_radius_bottom_right = r_right
	sb.border_width_left = 8
	sb.border_color = base_color.darkened(0.28)
	sb.shadow_color = Color(0.12, 0.10, 0.08, 0.16)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	return sb

static func make_sheet_box(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = 26
	sb.corner_radius_top_right = 26
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.shadow_color = Color(0, 0, 0, 0.24)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, -4)
	return sb

static func style_button(btn: Button, bg: Color, fg: Color, radius: int = 12, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0, pad_x: int = 12, pad_y: int = 6) -> void:
	if btn == null:
		return
	var normal_sb := make_box(bg, radius, border_col, border_w, pad_x, pad_y)
	var hover_sb := make_box(bg.lightened(0.05) if bg.v < 0.5 else bg.darkened(0.04), radius, border_col, border_w, pad_x, pad_y)
	var pressed_sb := make_box(bg.darkened(0.08), radius, border_col, border_w, pad_x, pad_y)
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", fg)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

static func style_line_edit(le: LineEdit, p: Dictionary, bg_override: Color = Color(0, 0, 0, 0)) -> void:
	if le == null:
		return
	var bg: Color = p["surface"] if bg_override.a == 0.0 else bg_override
	var normal_sb := make_box(bg, 12, p["border"], 1, 12, 8)
	var focus_sb := make_box(bg, 12, p["accent"], 1, 12, 8)
	le.add_theme_stylebox_override("normal", normal_sb)
	le.add_theme_stylebox_override("focus", focus_sb)
	le.add_theme_color_override("font_color", p["ink"])
	le.add_theme_color_override("font_placeholder_color", p["ink_muted"])
	le.add_theme_color_override("caret_color", p["accent"])

static func style_text_edit(te: TextEdit, p: Dictionary) -> void:
	if te == null:
		return
	var normal_sb := make_box(p["surface"], 12, p["border"], 1, 12, 10)
	var focus_sb := make_box(p["surface"], 12, p["accent"], 1, 12, 10)
	te.add_theme_stylebox_override("normal", normal_sb)
	te.add_theme_stylebox_override("focus", focus_sb)
	te.add_theme_color_override("font_color", p["ink"])
	te.add_theme_color_override("font_placeholder_color", p["ink_muted"])
	te.add_theme_color_override("caret_color", p["accent"])

