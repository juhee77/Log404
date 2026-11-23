class_name DsSegmented
extends PanelContainer

const UiTokensClass = preload("res://scripts/ui_tokens.gd")

signal tab_changed(index: int)

var active_index: int = 0
var _palette: Dictionary = UiTokensClass.get_palette("millie")
var _hbox: HBoxContainer
var _btns: Array[Button] = []

static func create(labels: Array[String], on_changed: Callable = Callable()) -> DsSegmented:
	var seg := DsSegmented.new()
	seg.add_to_group("ds_component")
	seg._setup_items(labels)
	if on_changed.is_valid():
		seg.tab_changed.connect(on_changed)
	seg.apply_theme(seg._palette)
	return seg

func _setup_items(labels: Array[String]) -> void:
	_hbox = HBoxContainer.new()
	_hbox.add_theme_constant_override("separation", 4)
	add_child(_hbox)
	_btns.clear()
	for i in range(labels.size()):
		var b := Button.new()
		b.text = labels[i]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 34)
		b.add_theme_font_size_override("font_size", 13)
		var idx := i
		b.pressed.connect(func():
			set_active(idx)
			tab_changed.emit(idx)
		)
		_hbox.add_child(b)
		_btns.append(b)

func set_active(idx: int) -> void:
	active_index = clampi(idx, 0, maxi(0, _btns.size() - 1))
	apply_theme(_palette)

func apply_theme(p: Dictionary) -> void:
	_palette = p
	add_theme_stylebox_override("panel", UiTokensClass.make_box(p["surface_soft"], 13, Color(0, 0, 0, 0), 0, 4, 4))
	for i in range(_btns.size()):
		var act := (i == active_index)
		UiTokensClass.style_button(
			_btns[i],
			p["surface"] if act else Color(0, 0, 0, 0),
			p["ink"] if act else p["ink_sub"],
			9, Color(0, 0, 0, 0), 0, 8, 5
		)
