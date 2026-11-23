class_name DsInput
extends LineEdit

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

enum Variant { SURFACE, FILLED }

var variant: int = Variant.SURFACE
var _palette: Dictionary = UiTokensClass.get_palette("millie")

static func create(p_placeholder: String, p_variant: int = Variant.SURFACE, p_height: int = 40) -> DsInput:
	var inp := DsInput.new()
	inp.add_to_group("ds_component")
	inp.placeholder_text = p_placeholder
	inp.variant = p_variant
	inp.custom_minimum_size = Vector2(0, p_height)
	inp.add_theme_font_size_override("font_size", 13)
	inp.apply_theme(inp._palette)
	return inp

func apply_theme(p: Dictionary) -> void:
	_palette = p
	var bg: Color = p["surface"] if variant == Variant.SURFACE else p["surface_soft"]
	var bw: int = 1 if variant == Variant.SURFACE else 0
	var normal_sb := UiTokensClass.make_box(bg, 12, p["border"], bw, 12, 8)
	var focus_sb := UiTokensClass.make_box(bg, 12, p["ink"], 1, 12, 8)
	add_theme_stylebox_override("normal", normal_sb)
	add_theme_stylebox_override("focus", focus_sb)
	add_theme_color_override("font_color", p["ink"])
	add_theme_color_override("font_placeholder_color", p["ink_muted"])
	add_theme_color_override("caret_color", p["ink"])
