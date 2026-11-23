class_name DsButton
extends Button

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

enum Variant { PRIMARY, ACCENT, SECONDARY, OUTLINE, GHOST, CHIP, ICON, DANGER, TAB }
enum Size { SM, MD, LG, FAB }

var variant: int = Variant.PRIMARY
var btn_size: int = Size.MD
var is_selected: bool = false
var _palette: Dictionary = UiTokensClass.get_palette("millie")

static func create(p_text: String, p_variant: int = Variant.PRIMARY, p_size: int = Size.MD, on_pressed: Callable = Callable()) -> DsButton:
	var btn := DsButton.new()
	btn.add_to_group("ds_component")
	btn.text = p_text
	btn.variant = p_variant
	btn.btn_size = p_size
	if on_pressed.is_valid():
		btn.pressed.connect(on_pressed)
	btn.apply_theme(btn._palette)
	return btn

func set_selected(sel: bool) -> void:
	is_selected = sel
	apply_theme(_palette)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var fsize: int = 12
	var min_h: int = 36
	var pad_x: int = 14
	var pad_y: int = 6
	var radius: int = 12

	match btn_size:
		Size.SM:
			fsize = 11
			min_h = 28
			pad_x = 10
			pad_y = 4
			radius = 9
		Size.MD:
			fsize = 12
			min_h = 36
			pad_x = 14
			pad_y = 6
			radius = 12
		Size.LG:
			fsize = 13
			min_h = 42
			pad_x = 16
			pad_y = 8
			radius = 12
		Size.FAB:
			fsize = 14
			min_h = 48
			pad_x = 18
			pad_y = 10
			radius = 99

	add_theme_font_size_override("font_size", fsize)

	if variant == Variant.ICON:
		custom_minimum_size = Vector2(36, 36)
		UiTokensClass.style_button(self, Color(0, 0, 0, 0), p["ink"], 99, Color(0, 0, 0, 0), 0, 0, 0)
		return

	if variant == Variant.TAB:
		custom_minimum_size = Vector2(0, 40)
		add_theme_font_size_override("font_size", 14)
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.border_width_bottom = 3 if is_selected else 0
		sb.border_color = p["ink"]
		sb.content_margin_left = 2
		sb.content_margin_right = 2
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		add_theme_stylebox_override("normal", sb)
		add_theme_stylebox_override("hover", sb)
		add_theme_stylebox_override("pressed", sb)
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		add_theme_color_override("font_color", p["ink"] if is_selected else p["ink_muted"])
		add_theme_color_override("font_hover_color", p["ink"])
		add_theme_color_override("font_pressed_color", p["ink"])
		return

	custom_minimum_size = Vector2(custom_minimum_size.x, min_h)

	match variant:
		Variant.PRIMARY:
			var is_dark: bool = (p["bg"].v < 0.25)
			var bg: Color = p["millie"] if (btn_size == Size.FAB and is_dark) else p["ink"]
			var fg: Color = p["millie_ink"] if (btn_size == Size.FAB and is_dark) else p["bg"]
			UiTokensClass.style_button(self, bg, fg, radius, Color(0, 0, 0, 0), 0, pad_x, pad_y)
		Variant.ACCENT:
			UiTokensClass.style_button(self, p["millie"], p["millie_ink"], radius, Color(0, 0, 0, 0), 0, pad_x, pad_y)
		Variant.SECONDARY:
			UiTokensClass.style_button(self, p["surface_soft"], p["ink"], radius, Color(0, 0, 0, 0), 0, pad_x, pad_y)
		Variant.OUTLINE:
			UiTokensClass.style_button(self, p["surface"], p["ink"], radius, p["border"], 1, pad_x, pad_y)
		Variant.GHOST:
			UiTokensClass.style_button(self, Color(0, 0, 0, 0), p["ink_sub"], radius, Color(0, 0, 0, 0), 0, 6, 4)
		Variant.CHIP:
			var c_bg: Color = p["ink"] if is_selected else p["surface"]
			var c_fg: Color = p["bg"] if is_selected else p["ink_sub"]
			var c_bd: Color = p["ink"] if is_selected else p["border"]
			UiTokensClass.style_button(self, c_bg, c_fg, 99, c_bd, 1, 13, 5)
		Variant.DANGER:
			UiTokensClass.style_button(self, p["danger_soft"], p["danger"], radius, Color(0, 0, 0, 0), 0, pad_x, pad_y)
