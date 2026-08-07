extends PanelContainer

# quest_panel.gd - Dynamic Story Quest UI without node path dependency

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	GameState.quest_updated.connect(func(_q): refresh_quest())
	refresh_quest()

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
	title.text = "📜 50단계 메인 스토리 퀘스트"
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

func refresh_quest() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	var idx = GameState.current_quest_index - 1
	if idx >= GameState.quests_data.size():
		var done_lbl = Label.new()
		done_lbl.text = "🎉 모든 스토리 퀘스트 완수!"
		done_lbl.add_theme_font_size_override("font_size", 16)
		done_lbl.add_theme_color_override("font_color", Color(0.1, 0.8, 0.4))
		list_container.add_child(done_lbl)
		return
		
	var q = GameState.quests_data[idx]
	
	var card = PanelContainer.new()
	var card_margin = MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 12)
	card_margin.add_theme_constant_override("margin_top", 10)
	card_margin.add_theme_constant_override("margin_right", 12)
	card_margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(card_margin)
	
	var vbox = VBoxContainer.new()
	card_margin.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = "📜 퀘스트 #%d: %s" % [q["id"], q["title"]]
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	vbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "진행률: (%d / %d) | 보상: 💰 %d ₩, 🌟 +%d XP" % [q["current"], q["target"], int(q["reward_money"]), int(q["reward_xp"])]
	sub_lbl.add_theme_font_size_override("font_size", 13)
	sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
	vbox.add_child(sub_lbl)
	
	list_container.add_child(card)
