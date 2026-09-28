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
	title.text = "☕ 로스팅 & 음료 바"
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

	_build_drink_menu()

# ── 음료 메뉴 ─────────────────────────────────────────────────
# 이 음료들은 전부 GameState 에 매출·재고·메시지까지 구현돼 있었지만, 호출하는
# UI 가 없어 게임에서 한 번도 만들 수 없었다.
const DRINKS: Array = [
	{ "fn": "brew_handdrip_single_origin", "icon": "☕", "name": "핸드드립 싱글 오리진", "price": 5800 },
	{ "fn": "tap_nitro_cold_brew",         "icon": "🍺", "name": "질소 나이트로 콜드브루", "price": 4500 },
	{ "fn": "brew_organic_matcha_latte",   "icon": "🍵", "name": "유기농 말차 라떼", "price": 3400 },
	{ "fn": "brew_fruit_ade",              "icon": "🍹", "name": "청포도 과일 에이드", "price": 2200 },
	{ "fn": "brew_herbal_tea",             "icon": "🌿", "name": "허브티", "price": 2500 },
	{ "fn": "blend_protein_smoothie_shake","icon": "🥤", "name": "프로틴 스무디", "price": 4800 },
	{ "fn": "blend_berry_acai_bowl",       "icon": "🫐", "name": "베리 아사이볼", "price": 4800 },
	{ "fn": "scoop_organic_matcha_gelato", "icon": "🍨", "name": "수제 말차 젤라또", "price": 3900 },
	{ "fn": "dispense_truffle_chocolate_buffet", "icon": "🍫", "name": "트러플 초콜릿", "price": 3600 },
	{ "fn": "dispense_dark_chocolate",     "icon": "🍩", "name": "다크 초콜릿", "price": 1200 }
]

func _build_drink_menu() -> void:
	var sep = HSeparator.new()
	list_container.add_child(sep)

	var hdr = Label.new()
	hdr.text = "🥤 음료 & 디저트 메뉴 — 만들면 바로 매출이 잡힙니다"
	hdr.add_theme_font_size_override("font_size", 14)
	hdr.add_theme_color_override("font_color", Color(0.2, 0.85, 0.55))
	list_container.add_child(hdr)

	for d in DRINKS:
		if not GameState.has_method(d["fn"]):
			continue
		var card = PanelContainer.new()
		var cm = MarginContainer.new()
		for side in ["left", "right"]:
			cm.add_theme_constant_override("margin_" + side, 10)
		for side in ["top", "bottom"]:
			cm.add_theme_constant_override("margin_" + side, 6)
		card.add_child(cm)

		var row = HBoxContainer.new()
		cm.add_child(row)

		var icon = Label.new()
		icon.text = d["icon"]
		icon.custom_minimum_size = Vector2(34, 0)
		icon.add_theme_font_size_override("font_size", 19)
		row.add_child(icon)

		var name_lbl = Label.new()
		name_lbl.text = d["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		row.add_child(name_lbl)

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(150, 34)
		btn.text = "만들기  +%s ₩" % GameState.format_money(float(d["price"]))
		var fname = d["fn"]
		btn.pressed.connect(func():
			var res = GameState.call(fname)
			var note = Label.new()
			note.text = str(res.get("msg", "완료!")) if res is Dictionary else "완료!"
			note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			note.custom_minimum_size = Vector2(520, 0)
			note.add_theme_font_size_override("font_size", 11)
			var ok = not (res is Dictionary) or res.get("success", true)
			note.add_theme_color_override("font_color",
				Color(0.4, 0.9, 0.6) if ok else Color(0.95, 0.5, 0.4))
			list_container.add_child(note)
		)
		row.add_child(btn)
		list_container.add_child(card)
