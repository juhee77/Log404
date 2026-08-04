extends Control

# main_scene.gd - Main Game Orchestrator & UI Controller for Study Cafe Tycoon

@onready var top_bar: PanelContainer = $VBoxContainer/TopBar
@onready var cafe_view: Control = $VBoxContainer/MainContent/CafeView
@onready var upgrade_panel: PanelContainer = $UpgradePanelOverlay
@onready var review_panel: PanelContainer = $ReviewPanelOverlay
@onready var report_panel: PanelContainer = $DailyReportPanelOverlay

@onready var btn_open_upgrades: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnUpgrades
@onready var btn_open_reviews: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnReviews
@onready var btn_toggle_sound: Button = $VBoxContainer/BottomBar/HBoxContainer/BtnSound

func _ready() -> void:
	if upgrade_panel: upgrade_panel.hide()
	if review_panel: review_panel.hide()
	if report_panel: report_panel.hide()
	
	# Default sound is MUTED
	if btn_toggle_sound:
		btn_toggle_sound.text = "🔇 무음 모드" if not SoundManager.sound_enabled else "🔊 소리 켜짐"
		btn_toggle_sound.pressed.connect(func():
			var enabled = SoundManager.toggle_sound()
			btn_toggle_sound.text = "🔊 소리 켜짐" if enabled else "🔇 무음 모드"
		)
		
	if btn_open_upgrades:
		btn_open_upgrades.pressed.connect(func():
			if review_panel: review_panel.hide()
			if upgrade_panel:
				upgrade_panel.refresh_list()
				upgrade_panel.show()
		)
		
	if btn_open_reviews:
		btn_open_reviews.pressed.connect(func():
			if upgrade_panel: upgrade_panel.hide()
			if review_panel:
				review_panel.refresh_reviews()
				review_panel.show()
		)
