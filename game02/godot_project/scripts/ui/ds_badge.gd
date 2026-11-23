class_name DsBadge
extends Label

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

enum Variant { MILLIE, DARK_OVERLAY, SAGE, ACCENT_SOFT }

var variant: int = Variant.MILLIE
var _palette: Dictionary = UiTokensClass.get_palette("millie")

static func create(p_text: String, p_variant: int = Variant.MILLIE, p_font_size: int = 10) -> DsBadge:
	var b := DsBadge.new()
	b.add_to_group("ds_component")
	b.text = p_text
	b.variant = p_variant
	b.add_theme_font_size_override("font_size", p_font_size)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.apply_theme(b._palette)
	return b

func apply_theme(p: Dictionary) -> void:
	_palette = p
	match variant:
		Variant.MILLIE:
			add_theme_stylebox_override("normal", UiTokensClass.make_box(p["millie"], 6, Color(0, 0, 0, 0), 0, 8, 3))
			add_theme_color_override("font_color", p["millie_ink"])
		Variant.DARK_OVERLAY:
			add_theme_stylebox_override("normal", UiTokensClass.make_box(Color(0, 0, 0, 0.36), 5, Color(0, 0, 0, 0), 0, 6, 2))
			add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
		Variant.SAGE:
			add_theme_stylebox_override("normal", UiTokensClass.make_box(p["sage_soft"], 99, Color(0, 0, 0, 0), 0, 10, 3))
			add_theme_color_override("font_color", p["sage"])
		Variant.ACCENT_SOFT:
			add_theme_stylebox_override("normal", UiTokensClass.make_box(p["accent_soft"], 99, Color(0, 0, 0, 0), 0, 10, 3))
			add_theme_color_override("font_color", p["accent"])
