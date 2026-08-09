extends PanelContainer

# uniform_panel.gd - Staff Uniform Apron & Headwear Wardrobe UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

var aprons: Array = ["클래식 레드 에이프런", "데님 서스펜더 유니폼", "골드 트위드 정장", "고양이 파자마 앞치마"]
var headwears: Array = ["고양이 귀 머리띠", "바리스타 베레모", "왕관 핀", "선글라스"]

var selected_apron: int = 0
var selected_headwear: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	refresh_uniforms()

func build_panel_ui() -> void:
	for child in get_children():
		child.queue_free()
		
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(main_vbox)
	
	var header = HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title = Label.new()
	title.text = "👔 알바 유니폼 옷장 스타일링"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.custom_minimum_size = Vector2(80, 32)
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header.add_child(btn_close)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)

func refresh_uniforms() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var info_lbl = Label.new()
	info_lbl.text = "현재 착용: 앞치마 [%s] | 헤어 [%s]" % [aprons[selected_apron], headwears[selected_headwear]]
	info_lbl.add_theme_font_size_override("font_size", 15)
	info_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	list_container.add_child(info_lbl)
	
	for idx in range(aprons.size()):
		var card = PanelContainer.new()
		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 12)
		card_margin.add_theme_constant_override("margin_top", 10)
		card_margin.add_theme_constant_override("margin_right", 12)
		card_margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(card_margin)
		
		var hbox = HBoxContainer.new()
		card_margin.add_child(hbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = "👔"
		icon_lbl.custom_minimum_size = Vector2(40, 0)
		icon_lbl.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = aprons[idx]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = "착용 시 매장 이동 속도 +15% 및 팁 수금 +20%"
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(desc_lbl)
		
		var wear_btn = Button.new()
		wear_btn.custom_minimum_size = Vector2(120, 40)
		wear_btn.text = "✅ 착용 중" if selected_apron == idx else "👔 착용하기"
		wear_btn.disabled = (selected_apron == idx)
		var a_idx = idx
		wear_btn.pressed.connect(func():
			selected_apron = a_idx
			refresh_uniforms()
		)
		hbox.add_child(wear_btn)
		
		list_container.add_child(card)
