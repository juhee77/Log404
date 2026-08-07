extends PanelContainer

# leaderboard_panel.gd - National Study Cafe TOP 10 League Leaderboard UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	refresh_leaderboard()

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
	
	var header = HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title = Label.new()
	title.text = "🏆 전국 스터디 카페 TOP 10 랭킹"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.custom_minimum_size = Vector2(80, 32)
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header.add_child(btn_close)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)

func refresh_leaderboard() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var top10_branches = [
		{"rank": 1, "name": "🏆 Log404 강남 1호점 (본점)", "score": "99,850 점", "rep": "⭐ 5.0", "daily": "50,000 ₩/일"},
		{"rank": 2, "name": "🏢 Log404 판교 2호점 (직영)", "score": "95,400 점", "rep": "⭐ 4.9", "daily": "42,000 ₩/일"},
		{"rank": 3, "name": "🌟 Log404 신촌 3호점 (대학가)", "score": "91,200 점", "rep": "⭐ 4.9", "daily": "38,000 ₩/일"},
		{"rank": 4, "name": "💼 Log404 여의도 4호점 (금융가)", "score": "88,900 점", "rep": "⭐ 4.8", "daily": "35,000 ₩/일"},
		{"rank": 5, "name": "🎓 Log404 대치 5호점 (수험가)", "score": "86,500 점", "rep": "⭐ 4.8", "daily": "32,000 ₩/일"},
		{"rank": 6, "name": "🏙 스터디 킹덤 송파점", "score": "78,200 점", "rep": "⭐ 4.6", "daily": "25,000 ₩/일"},
		{"rank": 7, "name": "☕ 몰입 타이쿤 분당점", "score": "74,100 점", "rep": "⭐ 4.5", "daily": "22,000 ₩/일"},
		{"rank": 8, "name": "📖 24H 르네상스 마포점", "score": "69,800 점", "rep": "⭐ 4.4", "daily": "19,000 ₩/일"},
		{"rank": 9, "name": "🎧 노이즈 제로 광화문점", "score": "65,300 점", "rep": "⭐ 4.3", "daily": "16,000 ₩/일"},
		{"rank": 10, "name": "🌿 초록 바이오월 목동점", "score": "61,000 점", "rep": "⭐ 4.2", "daily": "14,000 ₩/일"}
	]
	
	for branch in top10_branches:
		var card = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(margin)
		
		var hbox = HBoxContainer.new()
		margin.add_child(hbox)
		
		var rank_lbl = Label.new()
		rank_lbl.text = " #%d " % branch["rank"]
		rank_lbl.custom_minimum_size = Vector2(40, 0)
		rank_lbl.add_theme_font_size_override("font_size", 16)
		rank_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
		hbox.add_child(rank_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = branch["name"]
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.text = "점수: %s | 평점: %s | 일매출: %s" % [branch["score"], branch["rep"], branch["daily"]]
		sub_lbl.add_theme_font_size_override("font_size", 12)
		sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(sub_lbl)
		
		list_container.add_child(card)
