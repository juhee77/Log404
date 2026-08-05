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

func _ready() -> void:
	if upgrade_panel: upgrade_panel.hide()
	if review_panel: review_panel.hide()
	if snack_panel: snack_panel.hide()
	
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
			btn_decorate.text = "✅ 꾸미기 완료" if active else "🔨 인테리어 꾸미기"
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
