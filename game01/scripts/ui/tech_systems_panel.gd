extends PanelContainer

# tech_systems_panel.gd - 매장 설비 관제 오버레이 (Facilities Control Overlay)

signal closed

var scroll_container: ScrollContainer
var container_list: VBoxContainer
var btn_close: Button
var card_nodes: Dictionary = {}

# 설비 목록은 GameState.get_facility_readouts() 가 실제 매장 상태에서 만든다.

func _ready() -> void:
	custom_minimum_size = Vector2(720, 500)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_layout()

func build_layout() -> void:
	for c in get_children():
		c.queue_free()
		
	var main_margin = MarginContainer.new()
	main_margin.add_theme_constant_override("margin_left", 20)
	main_margin.add_theme_constant_override("margin_top", 16)
	main_margin.add_theme_constant_override("margin_right", 20)
	main_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(main_margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	main_margin.add_child(main_vbox)
	
	# Header
	var header_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = "🛠️ 매장 설비 관제실 (Facilities)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 0.85))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header_hbox.add_child(btn_close)
	main_vbox.add_child(header_hbox)
	
	# Subtitle
	var sub_lbl = Label.new()
	sub_lbl.text = "매장의 실제 상태를 읽어 보여줍니다. 주황색은 손볼 곳입니다."
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	main_vbox.add_child(sub_lbl)
	
	# Scroll area for categories
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_vbox.add_child(scroll_container)
	
	container_list = VBoxContainer.new()
	container_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_list.add_theme_constant_override("separation", 16)
	scroll_container.add_child(container_list)
	
	refresh_cards()

func refresh_cards() -> void:
	if not container_list: return
	for child in container_list.get_children():
		child.queue_free()

	# 실제 매장 상태에서 계기판을 만든다. 예전에는 45종을 나열했지만 전부 HUD
	# 토글일 뿐 게임플레이에 아무 영향이 없었고, 수치도 코드에 박힌 상수였다.
	var readouts = GameState.get_facility_readouts()
	var current_cat = ""
	for item in readouts:
		if item["cat"] != current_cat:
			current_cat = item["cat"]
			var cat_lbl = Label.new()
			cat_lbl.text = current_cat
			cat_lbl.add_theme_font_size_override("font_size", 14)
			cat_lbl.add_theme_color_override("font_color", Color(0.2, 0.85, 0.55))
			container_list.add_child(cat_lbl)

		var card = PanelContainer.new()
		var card_margin = MarginContainer.new()
		for side in ["left", "right"]:
			card_margin.add_theme_constant_override("margin_" + side, 10)
		for side in ["top", "bottom"]:
			card_margin.add_theme_constant_override("margin_" + side, 7)
		card.add_child(card_margin)

		var row = HBoxContainer.new()
		card_margin.add_child(row)

		var icon = Label.new()
		icon.text = item["icon"]
		icon.custom_minimum_size = Vector2(32, 0)
		icon.add_theme_font_size_override("font_size", 18)
		row.add_child(icon)

		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)

		var name_lbl = Label.new()
		name_lbl.text = item["name"]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		info.add_child(name_lbl)

		var note = Label.new()
		note.text = item["note"]
		note.add_theme_font_size_override("font_size", 10)
		note.add_theme_color_override("font_color", Color(0.60, 0.59, 0.56))
		info.add_child(note)

		var value = Label.new()
		value.text = item["value"]
		value.custom_minimum_size = Vector2(150, 0)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.add_theme_font_size_override("font_size", 14)
		value.add_theme_color_override("font_color",
			Color(0.35, 0.92, 0.60) if item["ok"] else Color(0.98, 0.62, 0.35))
		row.add_child(value)

		container_list.add_child(card)

