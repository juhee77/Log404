extends PanelContainer

# desk_shop_panel.gd - Interactive Desk Purchase & Catalog Overlay Panel

var title_label: Label
var money_label: Label
var desk_list_vbox: VBoxContainer
var close_btn: Button

func _ready() -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.07, 0.06, 0.98)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.96, 0.62, 0.07)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	add_theme_stylebox_override("panel", sb)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	add_child(main_vbox)

	# Header Bar
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	title_label = Label.new()
	title_label.text = "🛒 스터디 카페 책상 가구 상점 (Desk Shop)"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_label)

	close_btn = Button.new()
	close_btn.text = " ✖ 닫기 "
	close_btn.custom_minimum_size = Vector2(80, 36)
	close_btn.pressed.connect(func(): hide())
	header_hbox.add_child(close_btn)

	# Subtitle / Current Money Status
	money_label = Label.new()
	money_label.text = "💰 보유 자산: %s ₩  |  🪑 현재 보유 책상: %d 개" % [format_money(GameState.money), GameState.get_max_capacity()]
	money_label.add_theme_font_size_override("font_size", 14)
	money_label.add_theme_color_override("font_color", Color(0.1, 0.9, 0.5))
	main_vbox.add_child(money_label)

	# Scroll Container for Desk Catalog
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(630, 380)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)

	desk_list_vbox = VBoxContainer.new()
	desk_list_vbox.add_theme_constant_override("separation", 10)
	desk_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(desk_list_vbox)

	refresh_catalog()

func format_money(val: float) -> String:
	var n = int(val)
	var s = str(n)
	var res = ""
	var cnt = 0
	for i in range(s.length() - 1, -1, -1):
		if cnt > 0 and cnt % 3 == 0:
			res = "," + res
		res = s[i] + res
		cnt += 1
	return res

func refresh_catalog() -> void:
	if money_label != null:
		money_label.text = "💰 보유 자산: %s ₩  |  🪑 현재 보유 책상: %d 개" % [format_money(GameState.money), GameState.get_max_capacity()]

	for c in desk_list_vbox.get_children():
		c.queue_free()

	var catalog = GameState.desk_catalog
	for key in catalog.keys():
		var item = catalog[key]
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(600, 75)
		
		var sb_card = StyleBoxFlat.new()
		sb_card.bg_color = Color(0.14, 0.12, 0.10, 0.9)
		sb_card.set_border_width_all(2)
		sb_card.border_color = Color(0.3, 0.25, 0.2)
		sb_card.set_corner_radius_all(8)
		sb_card.content_margin_left = 14
		sb_card.content_margin_right = 14
		sb_card.content_margin_top = 10
		sb_card.content_margin_bottom = 10
		card.add_theme_stylebox_override("panel", sb_card)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		card.add_child(hbox)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var title_lbl = Label.new()
		title_lbl.text = item["name"]
		title_lbl.add_theme_font_size_override("font_size", 15)
		title_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
		info_vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = item["desc"]
		desc_lbl.add_theme_font_size_override("font_size", 12)
		desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.7))
		info_vbox.add_child(desc_lbl)

		var cost = item["cost"]
		var buy_btn = Button.new()
		buy_btn.text = " ₩ %s 구매 " % format_money(cost)
		buy_btn.custom_minimum_size = Vector2(140, 38)
		
		if GameState.can_afford(cost):
			buy_btn.disabled = false
			buy_btn.pressed.connect(func():
				if GameState.buy_new_desk(key):
					refresh_catalog()
					var root = get_tree().current_scene
					if root != null:
						var c_view = root.get_node_or_null("VBoxContainer/CafeView")
						if c_view != null:
							c_view.queue_redraw()
			)
		else:
			buy_btn.disabled = true
			buy_btn.text = " 🔒 자금 부족 "

		hbox.add_child(buy_btn)
		desk_list_vbox.add_child(card)
