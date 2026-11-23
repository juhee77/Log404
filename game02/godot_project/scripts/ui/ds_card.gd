class_name DsCard
extends PanelContainer

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

enum Variant { SUBTLE, SURFACE, ELEVATED, SHEET }

var variant: int = Variant.SUBTLE
var radius: int = 16
var pad_x: int = 16
var pad_y: int = 14
var _palette: Dictionary = UiTokensClass.get_palette("millie")

static func create(p_variant: int = Variant.SUBTLE, p_pad_x: int = 16, p_pad_y: int = 14, p_radius: int = 16) -> DsCard:
	var c := DsCard.new()
	c.add_to_group("ds_component")
	c.variant = p_variant
	c.pad_x = p_pad_x
	c.pad_y = p_pad_y
	c.radius = p_radius
	c.apply_theme(c._palette)
	return c

func apply_theme(p: Dictionary) -> void:
	_palette = p
	match variant:
		Variant.SUBTLE:
			add_theme_stylebox_override("panel", UiTokensClass.make_box(p["bg_subtle"], radius, Color(0, 0, 0, 0), 0, pad_x, pad_y))
		Variant.SURFACE:
			add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], radius, p["border"], 1, pad_x, pad_y))
		Variant.ELEVATED:
			add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface"], radius, p["border"], 1, pad_x, pad_y, p["shadow"], 6))
		Variant.SHEET:
			add_theme_stylebox_override("panel", UiTokensClass.make_sheet_box(p["bg"]))
