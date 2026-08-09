extends Control

# main_scene.gd - Master Game Controller handling UI, Zone Navigation, Decorating Mode & Minigames

@onready var top_bar: PanelContainer = $VBoxContainer/TopBar
@onready var cafe_view: Control = $VBoxContainer/MainContent/CafeView

@onready var upgrade_panel: PanelContainer = $UpgradePanelOverlay
@onready var review_panel: PanelContainer = $ReviewPanelOverlay
@onready var snack_panel: PanelContainer = $SnackRestockPanelOverlay

@onready var btn_zone_study: Button = $VBoxContainer/ZoneBar/HBoxContainer/BtnZoneStudy
@onready var btn_zone_lounge: Button = $VBoxContainer/ZoneBar/HBoxContainer/BtnZoneLounge
@onready var btn_zone_front: Button = $VBoxContainer/ZoneBar/HBoxContainer/BtnZoneFront
@onready var btn_decorate: Button = $VBoxContainer/ZoneBar/HBoxContainer/BtnDecorate

@onready var btn_open_upgrades: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnUpgrades
@onready var btn_open_snack: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnSnackMinigame
@onready var btn_open_reviews: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnReviews
@onready var btn_toggle_sound: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnSound
var leaderboard_panel: PanelContainer
var roasting_panel: PanelContainer
var quest_panel: PanelContainer
var bakery_panel: PanelContainer
var casting_panel: PanelContainer
var uniform_panel: PanelContainer
var expansion_panel: PanelContainer

func _ready() -> void:
	if upgrade_panel: upgrade_panel.hide()
	if review_panel: review_panel.hide()
	if snack_panel: snack_panel.hide()
	
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		take_screenshot("live_visual_check.png")
	)
	
	# Dynamically add Leaderboard Overlay
	var lb_script = load("res://scripts/ui/leaderboard_panel.gd")
	if lb_script != null:
		leaderboard_panel = PanelContainer.new()
		leaderboard_panel.set_script(lb_script)
		leaderboard_panel.custom_minimum_size = Vector2(680, 500)
		leaderboard_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		leaderboard_panel.hide()
		add_child(leaderboard_panel)
		
	# Dynamically add Roasting Overlay
	var roast_script = load("res://scripts/ui/roasting_panel.gd")
	if roast_script != null:
		roasting_panel = PanelContainer.new()
		roasting_panel.set_script(roast_script)
		roasting_panel.custom_minimum_size = Vector2(680, 500)
		roasting_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		roasting_panel.hide()
		add_child(roasting_panel)

	# Dynamically add Quest Overlay
	var q_script = load("res://scripts/ui/quest_panel.gd")
	if q_script != null:
		quest_panel = PanelContainer.new()
		quest_panel.set_script(q_script)
		quest_panel.custom_minimum_size = Vector2(680, 500)
		quest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		quest_panel.hide()
		add_child(quest_panel)

	# Dynamically add Bakery Overlay
	var b_script = load("res://scripts/ui/bakery_panel.gd")
	if b_script != null:
		bakery_panel = PanelContainer.new()
		bakery_panel.set_script(b_script)
		bakery_panel.custom_minimum_size = Vector2(680, 500)
		bakery_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		bakery_panel.hide()
		add_child(bakery_panel)

	# Dynamically add Casting Overlay
	var c_script = load("res://scripts/ui/casting_panel.gd")
	if c_script != null:
		casting_panel = PanelContainer.new()
		casting_panel.set_script(c_script)
		casting_panel.custom_minimum_size = Vector2(680, 500)
		casting_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		casting_panel.hide()
		add_child(casting_panel)

	# Dynamically add Uniform Overlay
	var u_script = load("res://scripts/ui/uniform_panel.gd")
	if u_script != null:
		uniform_panel = PanelContainer.new()
		uniform_panel.set_script(u_script)
		uniform_panel.custom_minimum_size = Vector2(680, 500)
		uniform_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		uniform_panel.hide()
		add_child(uniform_panel)

	# Dynamically add Expansion Overlay
	var e_script = load("res://scripts/ui/expansion_panel.gd")
	if e_script != null:
		expansion_panel = PanelContainer.new()
		expansion_panel.set_script(e_script)
		expansion_panel.custom_minimum_size = Vector2(680, 500)
		expansion_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		expansion_panel.hide()
		add_child(expansion_panel)
	
	# Dynamically add HUD Buttons to BottomBar
	var bottom_hbox = $VBoxContainer/BottomBar/HBoxContainer
	if bottom_hbox:
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
	
	# Connect Map Navigation & Decorate Mode
	if btn_zone_study:
		btn_zone_study.pressed.connect(func(): GameState.change_zone("study"))
	if btn_zone_lounge:
		btn_zone_lounge.pressed.connect(func(): GameState.change_zone("lounge"))
	if btn_zone_front:
		btn_zone_front.pressed.connect(func(): GameState.change_zone("front"))
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

func take_screenshot(path_name: String = "live_visual_check.png") -> void:
	for i in range(8):
		await get_tree().process_frame
	var vp = get_viewport()
	if vp != null:
		var tex = vp.get_texture()
		if tex != null:
			var img = tex.get_image()
			if img != null:
				var abs_path = ProjectSettings.globalize_path("res://" + path_name)
				img.save_png(abs_path)
				print("✔ Live visual screenshot saved to: ", abs_path)
