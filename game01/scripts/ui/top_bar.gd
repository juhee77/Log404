extends PanelContainer

# top_bar.gd - Top HUD Bar displaying continuous time-of-day & financial status

@onready var label_money: Label = $HBoxContainer/MoneyBox/LabelMoney
@onready var label_income: Label = $HBoxContainer/IncomeBox/LabelIncome
@onready var label_rep: Label = $HBoxContainer/RepBox/LabelRep
@onready var label_cap: Label = $HBoxContainer/CapBox/LabelCap
@onready var label_temp: Label = $HBoxContainer/TempBox/LabelTemp
@onready var label_time: Label = $HBoxContainer/TimeBox/LabelTime

@onready var btn_temp_down: Button = $HBoxContainer/TempBox/BtnTempDown
@onready var btn_temp_up: Button = $HBoxContainer/TempBox/BtnTempUp

func _ready() -> void:
	GameState.money_changed.connect(_on_money_changed)
	GameState.reputation_changed.connect(_on_reputation_changed)
	GameState.temperature_changed.connect(_on_temperature_changed)
	GameState.time_of_day_changed.connect(func(_tod): update_hud())
	
	if btn_temp_down:
		btn_temp_down.pressed.connect(func(): GameState.adjust_temperature(-0.5))
	if btn_temp_up:
		btn_temp_up.pressed.connect(func(): GameState.adjust_temperature(0.5))
		
	update_hud()

func _process(_delta: float) -> void:
	update_hud()

func update_hud() -> void:
	if label_money:
		label_money.text = "💰 %s ₩" % format_money(GameState.money)
	if label_income:
		label_income.text = "+%s ₩/초" % format_money(GameState.get_total_income_rate())
	if label_rep:
		label_rep.text = "⭐ %.1f | 🤫 %d%% | 🔊 %.0fdB" % [GameState.reputation, GameState.quietness_score, GameState.white_noise_db]
	if label_cap:
		label_cap.text = "👥 %d/%d명 | 📚 D-%d | 🧊 %d%%" % [GameState.active_customers.size(), GameState.get_max_capacity(), GameState.exam_dday, GameState.ice_maker_stock]
	if label_temp:
		label_temp.text = "🌡️ %.1f°C" % GameState.temperature
	if label_time:
		var tod_icon = "☀️"
		var tod_name = "낮"
		if GameState.time_of_day == "DUSK":
			tod_icon = "🌅"
			tod_name = "노을"
		elif GameState.time_of_day == "NIGHT":
			tod_icon = "🌙"
			tod_name = "밤"
			
		var hrs = int(GameState.game_time)
		var mins = int(fmod(GameState.game_time * 60.0, 60.0))
		label_time.text = "%s DAY %d  %02d:%02d (%s)" % [tod_icon, GameState.day_count, hrs, mins, tod_name]

func _on_money_changed(_new_amount: float, _change: float) -> void:
	update_hud()

func _on_reputation_changed(_new_rep: float) -> void:
	update_hud()

func _on_temperature_changed(_new_temp: float) -> void:
	update_hud()

func format_money(val: float) -> String:
	var num = int(val)
	var str_val = str(num)
	var res = ""
	var count = 0
	for i in range(str_val.length() - 1, -1, -1):
		res = str_val[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	return res
