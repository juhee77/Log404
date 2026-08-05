extends PanelContainer

# upgrade_panel.gd - Stable Non-destructive Upgrade Interface with Smooth Mouse Scroll

signal closed

@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer
@onready var container_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ListContainer
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose

# Map category -> { "card": Node, "title_lbl": Label, "desc_lbl": Label, "btn": Button }
var card_nodes: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if btn_close:
		btn_close.pressed.connect(func(): hide(); closed.emit())
		
	if scroll_container:
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		
	# Build UI cards ONCE at startup
	build_initial_cards()
	
	# Connect state updates
	GameState.money_changed.connect(func(_m, _c): update_card_states())
	GameState.upgrade_purchased.connect(func(_cat, _lvl): update_card_states())
	update_card_states()

func build_initial_cards() -> void:
	if not container_list: return
	
	for child in container_list.get_children():
		child.queue_free()
	card_nodes.clear()
	
	for category in GameState.upgrades:
		var item = GameState.upgrades[category]
		
		var card = PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var margin = MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_PASS
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 10)
		card.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.mouse_filter = Control.MOUSE_FILTER_PASS
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.add_child(hbox)
		
		var vbox = VBoxContainer.new()
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(vbox)
		
		var title_lbl = Label.new()
		title_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		title_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
		title_lbl.add_theme_font_size_override("font_size", 16)
		vbox.add_child(title_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
		desc_lbl.text = item["desc"]
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.75))
		desc_lbl.add_theme_font_size_override("font_size", 12)
		vbox.add_child(desc_lbl)
		
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(150, 44)
		hbox.add_child(buy_btn)
		
		var cat_name = category
		buy_btn.pressed.connect(func():
			_on_buy_clicked(cat_name)
		)
		
		card_nodes[category] = {
			"card": card,
			"title_lbl": title_lbl,
			"desc_lbl": desc_lbl,
			"btn": buy_btn
		}
		
		container_list.add_child(card)

func _on_buy_clicked(category: String) -> void:
	if GameState.buy_upgrade(category):
		update_card_states()

func update_card_states() -> void:
	for category in GameState.upgrades:
		if not card_nodes.has(category): continue
		var item = GameState.upgrades[category]
		var data = card_nodes[category]
		
		var title_lbl: Label = data["title_lbl"]
		var buy_btn: Button = data["btn"]
		
		title_lbl.text = "%s (Lv.%d / %d)" % [item["name"], item["level"], item["max_level"]]
		
		var cost = GameState.get_upgrade_cost(category)
		var is_max = item["level"] >= item["max_level"]
		
		if is_max:
			buy_btn.text = "최대 레벨 완료"
			buy_btn.disabled = true
		else:
			buy_btn.text = "업그레이드\n%s ₩" % format_money(cost)
			buy_btn.disabled = not GameState.can_afford(cost)

func refresh_list() -> void:
	update_card_states()

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
