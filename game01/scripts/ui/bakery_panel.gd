extends PanelContainer

# bakery_panel.gd - Bakery Oven Baking & Dessert Crafting UI

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_panel_ui()
	GameState.oven_updated.connect(func(_idx, _data): refresh_ovens())
	refresh_ovens()

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
	title.text = "🥐 사이드 베이커리 오븐 오더"
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

func refresh_ovens() -> void:
	if not list_container: return
	
	for child in list_container.get_children():
		child.queue_free()
		
	for idx in range(GameState.bakery_ovens.size()):
		var o = GameState.bakery_ovens[idx]
		
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 12)
		card_margin.add_theme_constant_override("margin_top", 10)
		card_margin.add_theme_constant_override("margin_right", 20)
		card_margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(card_margin)
		
		var hbox = HBoxContainer.new()
		card_margin.add_child(hbox)
		
		var icon_lbl = Label.new()
		icon_lbl.text = "🥐" if o["type"] == "croissant" else "🍰"
		icon_lbl.custom_minimum_size = Vector2(40, 0)
		icon_lbl.add_theme_font_size_override("font_size", 24)
		hbox.add_child(icon_lbl)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "베이킹 오븐 #%d : %s" % [idx + 1, o["name"]]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		vbox.add_child(name_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.text = "생산량: %d 개 | 개당 판매가: %d ₩ | 소요시간: %d초" % [o["yield"], int(o["price"]), int(o["max_time"])]
		sub_lbl.add_theme_font_size_override("font_size", 12)
		sub_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		vbox.add_child(sub_lbl)
		
		var action_btn = Button.new()
		action_btn.custom_minimum_size = Vector2(130, 40)
		action_btn.text = "🥐 오븐 베이킹"
		var o_idx = idx
		action_btn.pressed.connect(func():
			GameState.bake_dessert(o["type"], o["yield"])
			GameState.add_money(o["yield"] * o["price"])
			GameState.update_quest_progress(1)
			refresh_ovens()
		)
		hbox.add_child(action_btn)
		
		list_container.add_child(card)
