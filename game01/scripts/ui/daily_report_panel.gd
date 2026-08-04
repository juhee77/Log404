extends PanelContainer

# daily_report_panel.gd - Daily Operating Settlement Report for Study Cafe Tycoon

signal next_day_started

@onready var label_title: Label = $MarginContainer/VBoxContainer/Header/Title
@onready var label_seat: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelSeatValue
@onready var label_drink: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelDrinkValue
@onready var label_clean: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelCleanValue
@onready var label_total: Label = $MarginContainer/VBoxContainer/TotalBox/LabelTotalValue
@onready var label_visitors: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelVisitorValue
@onready var label_rating: Label = $MarginContainer/VBoxContainer/StatsGrid/LabelRatingValue

@onready var btn_next_day: Button = $MarginContainer/VBoxContainer/BtnNextDay

func _ready() -> void:
	GameState.day_ended.connect(_on_day_ended)
	if btn_next_day:
		btn_next_day.pressed.connect(func():
			hide()
			GameState.start_next_day()
			next_day_started.emit()
		)

func _on_day_ended(summary: Dictionary) -> void:
	if label_title:
		label_title.text = "📊 DAY %d 영업 매출 결산" % summary["day"]
	if label_seat:
		label_seat.text = "+%s ₩" % format_money(summary["seat_rev"])
	if label_drink:
		label_drink.text = "+%s ₩" % format_money(summary["drink_rev"])
	if label_clean:
		label_clean.text = "+%s ₩" % format_money(summary["clean_rev"])
	if label_total:
		label_total.text = "+%s ₩" % format_money(summary["total_rev"])
	if label_visitors:
		label_visitors.text = "%d 명" % summary["visitors"]
	if label_rating:
		label_rating.text = "⭐ %.1f / 5.0" % summary["rating"]
		
	show()

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
