extends PanelContainer

# expansion_panel.gd - Store Territory Expansion & Decor Score UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

var expansion_stages: Array = [
	{"stage": 1, "name": "1단계 8x8 타일 기본 독서실", "req_score": 0, "cost": 0, "unlocked": true},
	{"stage": 2, "name": "2단계 12x12 타일 중형 매장 (스낵바 구역 해금)", "req_score": 600, "cost": 50000.0, "unlocked": false},
	{"stage": 3, "name": "3단계 16x16 타일 대형 플래그십 (프런트 & 1인실 해금)", "req_score": 2000, "cost": 200000.0, "unlocked": false}
]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	refresh_expansion()

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
	title.text = "🏰 매장 평수 영토 대형 확장"
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

func refresh_expansion() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var info_lbl = Label.new()
	info_lbl.text = "🌟 현재 인테리어 꾸미기 점수: %d 점" % GameState.decor_score
	info_lbl.add_theme_font_size_override("font_size", 15)
	info_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	list_container.add_child(info_lbl)
	
	for stage in expansion_stages:
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
		icon_lbl.text = "🏰"
		icon_lbl.custom_minimum_size = Vector2(40, 0)
		icon_lbl.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = stage["name"]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var req_lbl = Label.new()
		req_lbl.text = "필요 꾸미기 점수: 🌟 %d점 | 필요 확장 비용: %d ₩" % [stage["req_score"], int(stage["cost"])]
		req_lbl.add_theme_font_size_override("font_size", 12)
		req_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(req_lbl)
		
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(130, 40)
		if stage["unlocked"]:
			buy_btn.text = "✅ 확장 완료"
			buy_btn.disabled = true
		else:
			buy_btn.text = "🏰 2배 영토 확장"
			var st = stage
			buy_btn.pressed.connect(func():
				if GameState.decor_score >= st["req_score"]:
					st["unlocked"] = true
					GameState.add_money(-st["cost"])
					GameState.update_quest_progress(1)
					refresh_expansion()
			)
			
		hbox.add_child(buy_btn)
		list_container.add_child(card)
