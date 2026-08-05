extends PanelContainer

# student_dialogue_panel.gd - Special Regular Student Story & Intimacy Dialogue System

signal closed

@onready var label_name: Label = $MarginContainer/VBoxContainer/Header/Title
@onready var label_dialogue: Label = $MarginContainer/VBoxContainer/DialogueBox/LabelDialogue
@onready var btn_option1: Button = $MarginContainer/VBoxContainer/OptionsBox/BtnOption1
@onready var btn_option2: Button = $MarginContainer/VBoxContainer/OptionsBox/BtnOption2
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose

var current_student: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if btn_close:
		btn_close.pressed.connect(func(): hide(); closed.emit())
		
	if btn_option1:
		btn_option1.pressed.connect(func(): select_option(1))
	if btn_option2:
		btn_option2.pressed.connect(func(): select_option(2))

func trigger_dialogue(student_data: Dictionary) -> void:
	current_student = student_data
	if label_name:
		label_name.text = "💬 단골 열공생 고민 상담 - %s (❤️ 친밀도 Lv.%d)" % [student_data["name"], student_data.get("intimacy", 1)]
	if label_dialogue:
		label_dialogue.text = student_data["story"]
		
	if btn_option1:
		btn_option1.text = "1. " + student_data["opt1"]
	if btn_option2:
		btn_option2.text = "2. " + student_data["opt2"]
		
	show()

func select_option(opt_index: int) -> void:
	if opt_index == 1:
		GameState.reputation = min(5.0, GameState.reputation + 0.1)
		GameState.add_money(500.0)
		SoundManager.play_coin_sfx()
	hide()
	closed.emit()
