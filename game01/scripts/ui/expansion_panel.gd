extends PanelContainer

# expansion_panel.gd - Store Territory Expansion & Decor Score UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

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
	
	var area_lbl = Label.new()
	area_lbl.text = "🏗️ 현재 개방 면적: %d칸 (%s)" % [GameState.get_study_cell_count(),
		GameState.STUDY_AREA_STAGES[GameState.study_area_level]["name"]]
	area_lbl.add_theme_font_size_override("font_size", 14)
	area_lbl.add_theme_color_override("font_color", Color(0.2, 0.85, 0.55))
	list_container.add_child(area_lbl)

	for si in range(GameState.STUDY_AREA_STAGES.size()):
		var stage = GameState.STUDY_AREA_STAGES[si]
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
		name_lbl.text = "%s  —  %d칸" % [stage["name"], stage["w"] * stage["h"]]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var req_lbl = Label.new()
		req_lbl.text = "필요 꾸미기 점수: 🌟 %d점  |  확장 비용: %s ₩" % [stage["req_score"], GameState.format_money(stage["cost"])]
		req_lbl.add_theme_font_size_override("font_size", 12)
		req_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(req_lbl)
		
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(130, 40)
		if si <= GameState.study_area_level:
			buy_btn.text = "✅ 개방됨"
			buy_btn.disabled = true
		elif si > GameState.study_area_level + 1:
			buy_btn.text = "🔒 이전 단계 먼저"
			buy_btn.disabled = true
		else:
			buy_btn.text = "🏗️ 면적 확장"
			buy_btn.pressed.connect(func():
				var res = GameState.expand_study_area()
				var msg = Label.new()
				msg.text = res["msg"]
				msg.add_theme_font_size_override("font_size", 12)
				msg.add_theme_color_override("font_color",
					Color(0.2, 0.85, 0.55) if res["success"] else Color(0.95, 0.45, 0.35))
				list_container.add_child(msg)
				if res["success"]:
					refresh_expansion()
			)


		hbox.add_child(buy_btn)
		list_container.add_child(card)
