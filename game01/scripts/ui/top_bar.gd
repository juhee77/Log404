extends PanelContainer

# top_bar.gd - Top HUD Bar with Interactive Thermostat Control for Study Cafe Tycoon

@onready var label_money: Label = $HBoxContainer/MoneyBox/LabelMoney
@onready var label_income: Label = $HBoxContainer/IncomeBox/LabelIncome
@onready var label_rep: Label = $HBoxContainer/RepBox/LabelRep
@onready var label_capacity: Label = $HBoxContainer/CapBox/LabelCap
@onready var label_time: Label = $HBoxContainer/TimeBox/LabelTime
@onready var label_temp: Label = $HBoxContainer/TempBox/LabelTemp

@onready var btn_temp_down: Button = $HBoxContainer/TempBox/BtnTempDown
@onready var btn_temp_up: Button = $HBoxContainer/TempBox/BtnTempUp

func _ready() -> void:
	GameState.money_changed.connect(func(_new_m, _change): update_hud())
	GameState.reputation_changed.connect(func(_rep): update_hud())
	GameState.customer_arrived.connect(func(_c): update_hud())
	GameState.customer_left.connect(func(_c, _e): update_hud())
	GameState.upgrade_purchased.connect(func(_cat, _lvl): update_hud())
	GameState.temperature_changed.connect(func(_t): update_hud())
	
	if btn_temp_down:
		btn_temp_down.pressed.connect(func(): GameState.adjust_temperature(-1.0))
	if btn_temp_up:
		btn_temp_up.pressed.connect(func(): GameState.adjust_temperature(1.0))

func _process(_delta: float) -> void:
	update_hud()

func update_hud() -> void:
	if label_money:
		label_money.text = "💰 %s ₩" % format_money(GameState.money)
	if label_income:
		label_income.text = "+%d ₩/초" % int(GameState.get_total_income_rate())
	if label_rep:
		label_rep.text = "⭐ %.1f / 5.0" % GameState.reputation
	if label_capacity:
		label_capacity.text = "👥 %d / %d 명" % [GameState.active_customers.size(), GameState.get_max_capacity()]
	if label_time:
		var hrs = int(GameState.game_time)
		var mins = int(fmod(GameState.game_time * 60.0, 60.0))
		label_time.text = "DAY %d  %02d:%02d" % [GameState.day_count, hrs, mins]
	if label_temp:
		label_temp.text = "🌡️ %.1f°C" % GameState.temperature
		if GameState.temperature >= 22.0 and GameState.temperature <= 26.0:
			label_temp.add_theme_color_override("font_color", Color(0.1, 0.8, 0.4))
		else:
			label_temp.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

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
