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
		leaderboard_panel.custom_minimum_size = Vector2(500, 420)
		leaderboard_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		leaderboard_panel.hide()
		add_child(leaderboard_panel)
		
	# Dynamically add Roasting Overlay
	var roast_script = load("res://scripts/ui/roasting_panel.gd")
	if roast_script != null:
		roasting_panel = PanelContainer.new()
		roasting_panel.set_script(roast_script)
		roasting_panel.custom_minimum_size = Vector2(520, 440)
		roasting_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		roasting_panel.hide()
		add_child(roasting_panel)

	# Dynamically add Quest Overlay
	var q_script = load("res://scripts/ui/quest_panel.gd")
	if q_script != null:
		quest_panel = PanelContainer.new()
		quest_panel.set_script(q_script)
		quest_panel.custom_minimum_size = Vector2(500, 360)
		quest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		quest_panel.hide()
		add_child(quest_panel)
	
	# Dynamically add HUD Buttons to BottomBar
	var bottom_hbox = $VBoxContainer/BottomBar/HBoxContainer
	if bottom_hbox:
		var btn_roast = Button.new()
		btn_roast.text = "☕ 원두 로스팅 머신"
		btn_roast.custom_minimum_size = Vector2(150, 40)
		bottom_hbox.add_child(btn_roast)
		btn_roast.pressed.connect(func():
			hide_all_overlays()
			if roasting_panel:
				roasting_panel.refresh_roasters()
				roasting_panel.show()
		)

		var btn_quest = Button.new()
		btn_quest.text = "📜 스토리 퀘스트"
		btn_quest.custom_minimum_size = Vector2(140, 40)
		bottom_hbox.add_child(btn_quest)
		btn_quest.pressed.connect(func():
			hide_all_overlays()
			if quest_panel:
				quest_panel.refresh_quest()
				quest_panel.show()
		)
		
		var btn_top10 = Button.new()
		btn_top10.text = "🏆 전국 TOP 10 랭킹"
		btn_top10.custom_minimum_size = Vector2(160, 40)
		bottom_hbox.add_child(btn_top10)
		btn_top10.pressed.connect(func():
			hide_all_overlays()
			if leaderboard_panel:
				leaderboard_panel.refresh_leaderboard()
				leaderboard_panel.show()
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

func hide_all_overlays() -> void:
	if upgrade_panel: upgrade_panel.hide()
	if review_panel: review_panel.hide()
	if snack_panel: snack_panel.hide()
	if leaderboard_panel: leaderboard_panel.hide()
	if roasting_panel: roasting_panel.hide()
	if quest_panel: quest_panel.hide()

func take_screenshot(path_name: String = "live_visual_check.png") -> void:
	await get_tree().process_frame
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
