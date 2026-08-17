extends PanelContainer

# roasting_panel.gd - Robust Standalone UI with Dynamic Component Builder

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	
	GameState.roaster_updated.connect(func(_idx, _data): refresh_roasters())
	GameState.beans_changed.connect(func(_amt): refresh_roasters())
	refresh_roasters()

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
	
	# Header HBox
	var header = HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title = Label.new()
	title.text = "☕ 원두 로스팅 머신 관리"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.custom_minimum_size = Vector2(80, 32)
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header.add_child(btn_close)
	
	# ScrollContainer
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)

func refresh_roasters() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var info_lbl = Label.new()
	info_lbl.text = "☕ 보유 원두: %d 자루 | Manager Lv.%d (XP: %d/%d)" % [GameState.beans_inventory, GameState.manager_level, GameState.manager_xp, GameState.max_manager_xp]
	info_lbl.add_theme_font_size_override("font_size", 15)
	info_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	list_container.add_child(info_lbl)
	
	for idx in range(GameState.roasters.size()):
		var r = GameState.roasters[idx]
		
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 12)
		card_margin.add_theme_constant_override("margin_top", 10)
		card_margin.add_theme_constant_override("margin_right", 20)
		card_margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(card_margin)
		
		var hbox = HBoxContainer.new()
		card_margin.add_child(hbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = "☕" if r["state"] == "IDLE" else ("🔥" if r["state"] == "ROASTING" else ("🌱" if r["state"] == "READY" else "🖤"))
		icon_lbl.custom_minimum_size = Vector2(40, 0)
		icon_lbl.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "로스팅 머신 #%d : %s" % [idx + 1, r["name"]]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.add_theme_font_size_override("font_size", 12)
		sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		
		var action_btn = Button.new()
		action_btn.custom_minimum_size = Vector2(130, 40)
		hbox.add_child(action_btn)
		
		var r_idx = idx
		if r["state"] == "IDLE":
			sub_lbl.text = "수확량: %d 자루 | 경험치: +%d XP | 소요시간: %d초" % [r["yield"], r["xp"], int(r["max_time"])]
			action_btn.text = "🔥 로스팅 시작"
			action_btn.pressed.connect(func():
				GameState.start_roasting(r_idx)
				refresh_roasters()
			)
		elif r["state"] == "ROASTING":
			sub_lbl.text = "로스팅 중... 남은 시간: %d초" % int(r["timer"])
			action_btn.text = "⏳ 볶는 중..."
			action_btn.disabled = true
		elif r["state"] == "READY":
			sub_lbl.text = "🌱 로스팅 완료! 터치하여 원두 수확"
			action_btn.text = "🌱 원두 수확!"
			action_btn.pressed.connect(func():
				GameState.harvest_beans(r_idx)
				refresh_roasters()
			)
		elif r["state"] == "BURNT":
			sub_lbl.text = "🖤 원두가 탔습니다! 복구 비용: 100 ₩"
			action_btn.text = "🖤 탄 원두 복구"
			action_btn.pressed.connect(func():
				GameState.repair_burnt_beans(r_idx)
				refresh_roasters()
			)
			
		vbox.add_child(sub_lbl)
		list_container.add_child(card)
