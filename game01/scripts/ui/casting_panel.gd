extends PanelContainer

# casting_panel.gd - Street Casting & Intimacy Dialogue Quiz UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	refresh_casting()

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
	title.text = "🚶 길거리 캐스팅 & 단골 손님 1:1 대화"
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

func refresh_casting() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var title_lbl = Label.new()
	title_lbl.text = "👥 카페 주변 단골 손님 친밀도 (❤️ Lv.1 ~ Lv.5)"
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	list_container.add_child(title_lbl)
	
	for key in GameState.guest_intimacy:
		var g = GameState.guest_intimacy[key]
		
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
		icon_lbl.text = "❤️"
		icon_lbl.custom_minimum_size = Vector2(40, 0)
		icon_lbl.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s (❤️ Lv.%d | XP: %d/%d)" % [g["name"], g["level"], g["xp"], g["max_xp"]]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var reward_lbl = Label.new()
		var r_text = g.get("reward", g.get("title", "원목 독서대"))
		reward_lbl.text = "달성 보상: %s" % r_text
		reward_lbl.add_theme_font_size_override("font_size", 12)
		reward_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(reward_lbl)
		
		var cast_btn = Button.new()
		cast_btn.custom_minimum_size = Vector2(130, 40)
		cast_btn.text = "💬 1:1 캐스팅 대화"
		var g_key = key
		cast_btn.pressed.connect(func():
			var cur_g = GameState.guest_intimacy[g_key]
			cur_g["xp"] += 25
			if cur_g["xp"] >= cur_g["max_xp"]:
				cur_g["xp"] -= cur_g["max_xp"]
				cur_g["level"] += 1
			GameState.add_money(500.0)
			GameState.update_quest_progress(1)
			refresh_casting()
		)
		hbox.add_child(cast_btn)
		
		list_container.add_child(card)
