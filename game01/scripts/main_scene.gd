extends Control

# main_scene.gd - Master Game Controller handling UI, Zone Navigation, Decorating Mode & Minigames

@onready var top_bar: PanelContainer = $VBoxContainer/TopBar
@onready var cafe_view: Control = $VBoxContainer/MainContent/CafeView

@onready var upgrade_panel: PanelContainer = $UpgradePanelOverlay
@onready var review_panel: PanelContainer = $ReviewPanelOverlay
@onready var snack_panel: PanelContainer = $SnackRestockPanelOverlay

@onready var btn_zone_study: Button = find_child("BtnZoneStudy", true, false)
@onready var btn_zone_lounge: Button = find_child("BtnZoneLounge", true, false)
@onready var btn_zone_front: Button = find_child("BtnZoneFront", true, false)
@onready var btn_decorate: Button = find_child("BtnDecorate", true, false)

@onready var btn_open_upgrades: Button = find_child("BtnUpgrades", true, false)
@onready var btn_open_snack: Button = find_child("BtnSnackMinigame", true, false)
@onready var btn_open_reviews: Button = find_child("BtnReviews", true, false)
@onready var btn_toggle_sound: Button = find_child("BtnSound", true, false)
var leaderboard_panel: PanelContainer
var roasting_panel: PanelContainer
var quest_panel: PanelContainer
var bakery_panel: PanelContainer
var casting_panel: PanelContainer
var uniform_panel: PanelContainer
var expansion_panel: PanelContainer
var desk_shop_panel: PanelContainer
var tech_systems_panel: PanelContainer

func _ready() -> void:
	hide_all_overlays()
	var report_overlay = get_node_or_null("DailyReportPanelOverlay")
	if report_overlay != null: report_overlay.hide()
	
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		take_screenshot("live_visual_check.png")
	)
	
	# Dynamically add Desk Shop Overlay
	var ds_script = load("res://scripts/ui/desk_shop_panel.gd")
	if ds_script != null:
		desk_shop_panel = PanelContainer.new()
		desk_shop_panel.set_script(ds_script)
		desk_shop_panel.custom_minimum_size = Vector2(660, 460)
		desk_shop_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		desk_shop_panel.hide()
		add_child(desk_shop_panel)

	# Dynamically add Leaderboard Overlay
	var lb_script = load("res://scripts/ui/leaderboard_panel.gd")
	if lb_script != null:
		leaderboard_panel = PanelContainer.new()
		leaderboard_panel.set_script(lb_script)
		leaderboard_panel.custom_minimum_size = Vector2(660, 460)
		leaderboard_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		leaderboard_panel.hide()
		add_child(leaderboard_panel)

	# Dynamically add Roasting Overlay
	var roast_script = load("res://scripts/ui/roasting_panel.gd")
	if roast_script != null:
		roasting_panel = PanelContainer.new()
		roasting_panel.set_script(roast_script)
		roasting_panel.custom_minimum_size = Vector2(660, 460)
		roasting_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		roasting_panel.hide()
		add_child(roasting_panel)

	# Dynamically add Quest Overlay
	var q_script = load("res://scripts/ui/quest_panel.gd")
	if q_script != null:
		quest_panel = PanelContainer.new()
		quest_panel.set_script(q_script)
		quest_panel.custom_minimum_size = Vector2(660, 460)
		quest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		quest_panel.hide()
		add_child(quest_panel)

	# Dynamically add Bakery Overlay
	var b_script = load("res://scripts/ui/bakery_panel.gd")
	if b_script != null:
		bakery_panel = PanelContainer.new()
		bakery_panel.set_script(b_script)
		bakery_panel.custom_minimum_size = Vector2(660, 460)
		bakery_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		bakery_panel.hide()
		add_child(bakery_panel)

	# Dynamically add Casting Overlay
	var c_script = load("res://scripts/ui/casting_panel.gd")
	if c_script != null:
		casting_panel = PanelContainer.new()
		casting_panel.set_script(c_script)
		casting_panel.custom_minimum_size = Vector2(660, 460)
		casting_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		casting_panel.hide()
		add_child(casting_panel)

	# Dynamically add Uniform Overlay
	var u_script = load("res://scripts/ui/uniform_panel.gd")
	if u_script != null:
		uniform_panel = PanelContainer.new()
		uniform_panel.set_script(u_script)
		uniform_panel.custom_minimum_size = Vector2(660, 460)
		uniform_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		uniform_panel.hide()
		add_child(uniform_panel)

	# Dynamically add Expansion Overlay
	var e_script = load("res://scripts/ui/expansion_panel.gd")
	if e_script != null:
		expansion_panel = PanelContainer.new()
		expansion_panel.set_script(e_script)
		expansion_panel.custom_minimum_size = Vector2(660, 460)
		expansion_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		expansion_panel.hide()
		add_child(expansion_panel)

	# Dynamically add Tech Systems Overlay
	var ts_script = load("res://scripts/ui/tech_systems_panel.gd")
	if ts_script != null:
		tech_systems_panel = PanelContainer.new()
		tech_systems_panel.set_script(ts_script)
		tech_systems_panel.custom_minimum_size = Vector2(720, 500)
		tech_systems_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		tech_systems_panel.hide()
		add_child(tech_systems_panel)

	GameState.tech_systems_requested.connect(func():
		hide_all_overlays()
		if tech_systems_panel:
			tech_systems_panel.refresh_cards()
			tech_systems_panel.show()
	)
	
	# Dynamically add HUD Buttons to BottomBar
	var bottom_bar = get_node_or_null("VBoxContainer/BottomBar")
	var bottom_hbox = bottom_bar.find_child("HBoxContainer", true, false) if bottom_bar else null
	if bottom_hbox:
		var btn_shop = Button.new()
		btn_shop.text = "🛒 책상 상점"
		btn_shop.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_shop)
		btn_shop.pressed.connect(func():
			hide_all_overlays()
			if desk_shop_panel:
				desk_shop_panel.refresh_catalog()
				desk_shop_panel.show()
		)

		var btn_roast = Button.new()
		btn_roast.text = "☕ 로스팅"
		btn_roast.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_roast)
		btn_roast.pressed.connect(func():
			hide_all_overlays()
			if roasting_panel:
				roasting_panel.refresh_roasters()
				roasting_panel.show()
		)

		var btn_quest = Button.new()
		btn_quest.text = "📜 퀘스트"
		btn_quest.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_quest)
		btn_quest.pressed.connect(func():
			hide_all_overlays()
			if quest_panel:
				quest_panel.refresh_quest()
				quest_panel.show()
		)
		
		var btn_bake = Button.new()
		btn_bake.text = "🥐 베이커리"
		btn_bake.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_bake)
		btn_bake.pressed.connect(func():
			hide_all_overlays()
			if bakery_panel:
				bakery_panel.refresh_ovens()
				bakery_panel.show()
		)

		var btn_cast = Button.new()
		btn_cast.text = "💬 캐스팅"
		btn_cast.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_cast)
		btn_cast.pressed.connect(func():
			hide_all_overlays()
			if casting_panel:
				casting_panel.refresh_casting()
				casting_panel.show()
		)

		var btn_uni = Button.new()
		btn_uni.text = "👔 유니폼"
		btn_uni.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_uni)
		btn_uni.pressed.connect(func():
			hide_all_overlays()
			if uniform_panel:
				uniform_panel.refresh_uniforms()
				uniform_panel.show()
		)

		var btn_exp = Button.new()
		btn_exp.text = "🏰 확장"
		btn_exp.custom_minimum_size = Vector2(110, 42)
		bottom_hbox.add_child(btn_exp)
		btn_exp.pressed.connect(func():
			hide_all_overlays()
			if expansion_panel:
				expansion_panel.refresh_expansion()
				expansion_panel.show()
		)
	
	# Connect Map Navigation & Floor Switching Engine
	var update_floor_ui = func():
		var cur = GameState.current_floor
		if btn_zone_study:
			btn_zone_study.text = "🏢 1F 메인 [선택됨]" if cur == 1 else "🏢 1F 메인 스터디 존"
		if btn_zone_lounge:
			if not GameState.unlocked_floors.has(2):
				btn_zone_lounge.text = "🔒 2F 노블리스 (5만₩ 해금)"
			else:
				btn_zone_lounge.text = "🏢 2F 노블리스 [선택됨]" if cur == 2 else "🏢 2F 노블리스 부스존"
		if btn_zone_front:
			if not GameState.unlocked_floors.has(3):
				btn_zone_front.text = "🔒 3F 루프탑 (15만₩ 해금)"
			else:
				btn_zone_front.text = "🌿 3F 루프탑 [선택됨]" if cur == 3 else "🌿 3F 루프탑 테라스"

	update_floor_ui.call()
	GameState.floor_changed.connect(func(_f): update_floor_ui.call())

	if btn_zone_study:
		btn_zone_study.pressed.connect(func(): GameState.change_floor(1))
	if btn_zone_lounge:
		btn_zone_lounge.pressed.connect(func():
			if not GameState.unlocked_floors.has(2):
				if GameState.can_afford(50000.0):
					if GameState.buy_floor(2):
						if cafe_view: cafe_view.spawn_floating_text(Vector2(500, 250), "🎉 2층 노블리스 부스존 해금 완료!", Color(0.1, 0.9, 0.5))
				else:
					if cafe_view: cafe_view.spawn_floating_text(Vector2(500, 250), "❌ 2층 해금 자금(50,000 ₩)이 부족합니다!", Color(1.0, 0.3, 0.3))
			else:
				GameState.change_floor(2)
		)
	if btn_zone_front:
		btn_zone_front.pressed.connect(func():
			if not GameState.unlocked_floors.has(3):
				if GameState.can_afford(150000.0):
					if GameState.buy_floor(3):
						if cafe_view: cafe_view.spawn_floating_text(Vector2(500, 250), "🎉 3층 루프탑 테라스 해금 완료!", Color(0.1, 0.9, 0.5))
				else:
					if cafe_view: cafe_view.spawn_floating_text(Vector2(500, 250), "❌ 3층 해금 자금(150,000 ₩)이 부족합니다!", Color(1.0, 0.3, 0.3))
			else:
				GameState.change_floor(3)
		)
	if btn_decorate:
		btn_decorate.pressed.connect(func():
			var active = GameState.toggle_decorating_mode()
			btn_decorate.text = "✅ 꾸미기 완료" if active else "🔨 책상 자리 옮기기 & 인테리어"
		)
		
	# Default Sound is MUTED
	if btn_toggle_sound:
		btn_toggle_sound.text = "🔇 무음 모드" if not SoundManager.sound_enabled else "🔊 소리 켜짐"
		btn_toggle_sound.pressed.connect(func():
			var enabled = SoundManager.toggle_sound()
			btn_toggle_sound.text = "🔊 소리 켜짐" if enabled else "🔇 무음 모드"
		)
		
	if btn_open_upgrades:
		btn_open_upgrades.pressed.connect(func():
			hide_all_overlays()
			if upgrade_panel:
				upgrade_panel.refresh_list()
				upgrade_panel.show()
		)
		
	if btn_open_snack:
		btn_open_snack.pressed.connect(func():
			hide_all_overlays()
			if snack_panel:
				snack_panel.update_view()
				snack_panel.show()
		)
		
	if btn_open_reviews:
		btn_open_reviews.pressed.connect(func():
			hide_all_overlays()
			if review_panel:
				review_panel.refresh_reviews()
				review_panel.show()
		)

	# Auto-start roasting so timers actively run
	GameState.start_roasting(0)
	GameState.start_roasting(1)

	# Add dynamic customer spawner timer (Every 2.0s)
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(func():
		var free_seat = -1
		for i in range(GameState.get_max_capacity()):
			if GameState.get_customer_at_seat(i).is_empty():
				free_seat = i
				break
		if free_seat != -1:
			GameState.spawn_customer()
	)
	add_child(spawn_timer)

func capture_all_floor_screenshots() -> void:
	for i in range(12):
		await get_tree().process_frame
	if not GameState.unlocked_floors.has(2):
		GameState.unlocked_floors.append(2)
	if not GameState.unlocked_floors.has(3):
		GameState.unlocked_floors.append(3)
	
	# 1. Capture 1F
	GameState.change_floor(1)
	GameState.is_decorating_mode = false
	await take_screenshot("screenshot_1f.png")
	
	# 2. Capture 2F
	GameState.change_floor(2)
	GameState.is_decorating_mode = false
	await take_screenshot("screenshot_2f.png")
	
	# 3. Capture 3F
	GameState.change_floor(3)
	GameState.is_decorating_mode = false
	await take_screenshot("screenshot_3f.png")
	
	# 4. Capture Decorating Mode Grid
	GameState.change_floor(1)
	GameState.is_decorating_mode = true
	await take_screenshot("screenshot_decorating.png")
	
	# Reset to 1F
	GameState.is_decorating_mode = false
	GameState.change_floor(1)

func hide_all_overlays() -> void:
	if upgrade_panel: upgrade_panel.hide()
	if review_panel: review_panel.hide()
	if snack_panel: snack_panel.hide()
	if leaderboard_panel: leaderboard_panel.hide()
	if roasting_panel: roasting_panel.hide()
	if quest_panel: quest_panel.hide()
	if bakery_panel: bakery_panel.hide()
	if casting_panel: casting_panel.hide()
	if uniform_panel: uniform_panel.hide()
	if expansion_panel: expansion_panel.hide()
	if desk_shop_panel: desk_shop_panel.hide()
	if tech_systems_panel: tech_systems_panel.hide()

func take_screenshot(path_name: String = "live_visual_check.png") -> void:
	await get_tree().create_timer(0.25).timeout
	var vp = get_viewport()
	if vp != null:
		var tex = vp.get_texture()
		if tex != null:
			var img = tex.get_image()
			if img != null:
				var abs_path = ProjectSettings.globalize_path("res://" + path_name)
				img.save_png(abs_path)
				print("✔ Screenshot saved to: ", abs_path)
