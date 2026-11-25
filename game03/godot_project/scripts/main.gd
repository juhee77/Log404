extends Control

@onready var room: Node2D = $RoomLayer/Car5Room
@onready var modal: Control = $UILayer/PuzzleModal

var hover_label: Label
var tick_hint_btn: Button
var speaker_label: Label
var dialogue_label: Label
var inventory_box: HBoxContainer
var item_desc_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()

	room.hotspot_clicked.connect(_on_hotspot_clicked)
	room.hotspot_hovered.connect(_on_hotspot_hovered)

	GameState.inventory_changed.connect(_refresh_inventory)
	GameState.selection_changed.connect(_on_selection_changed)
	GameState.flag_changed.connect(_on_flag_changed)
	GameState.dialogue_requested.connect(_show_dialogue)

	_refresh_inventory(GameState.inventory)
	_show_dialogue("나레이션", "눈을 뜨자 별빛이 흐르는 야간열차의 침대칸이다. 내가 누구인지 기억나지 않는다... 왼쪽에 걸린 코트가 반짝이고 있다.")


func _unhandled_input(event: InputEvent) -> void:
	if modal.visible:
		return
	room.handle_room_input(event)


func _build_hud() -> void:
	var ui_layer := $UILayer

	# 상단 바
	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 20
	top_bar.offset_right = -20
	top_bar.offset_top = 14
	top_bar.offset_bottom = 62
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(top_bar)
	ui_layer.move_child(top_bar, 0)

	var title_badge := PanelContainer.new()
	var tstyle := StyleBoxFlat.new()
	tstyle.bg_color = Color(0.11, 0.08, 0.16, 0.86)
	tstyle.border_color = Color("#D4AF37")
	tstyle.set_border_width_all(2)
	tstyle.set_corner_radius_all(10)
	tstyle.set_content_margin_all(10)
	title_badge.add_theme_stylebox_override("panel", tstyle)
	top_bar.add_child(title_badge)

	var title_lbl := Label.new()
	title_lbl.text = "✦ Ch.1  5호차 — 잠든 침대칸  (04:04)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("#FDE68A"))
	title_badge.add_child(title_lbl)

	hover_label = Label.new()
	hover_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hover_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hover_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hover_label.add_theme_font_size_override("font_size", 18)
	hover_label.add_theme_color_override("font_color", Color("#FFFBEB"))
	hover_label.text = ""
	top_bar.add_child(hover_label)

	tick_hint_btn = Button.new()
	tick_hint_btn.text = "🐦 티크에게 힌트 듣기"
	tick_hint_btn.custom_minimum_size = Vector2(200, 44)
	tick_hint_btn.visible = false
	tick_hint_btn.pressed.connect(_on_tick_hint_pressed)
	top_bar.add_child(tick_hint_btn)

	# 좌/우 객차 탐색 화살표 버튼
	var left_btn := Button.new()
	left_btn.text = "◀"
	left_btn.custom_minimum_size = Vector2(48, 84)
	left_btn.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	left_btn.offset_left = 14
	left_btn.offset_top = -62
	left_btn.offset_bottom = 22
	left_btn.pressed.connect(func(): room.scroll_by(-420.0))
	ui_layer.add_child(left_btn)
	ui_layer.move_child(left_btn, 1)

	var right_btn := Button.new()
	right_btn.text = "▶"
	right_btn.custom_minimum_size = Vector2(48, 84)
	right_btn.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	right_btn.offset_right = -14
	right_btn.offset_left = -62
	right_btn.offset_top = -62
	right_btn.offset_bottom = 22
	right_btn.pressed.connect(func(): room.scroll_by(420.0))
	ui_layer.add_child(right_btn)
	ui_layer.move_child(right_btn, 2)

	# 하단 HUD (대화창 + 인벤토리 바)
	var bottom_panel := PanelContainer.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 18
	bottom_panel.offset_right = -18
	bottom_panel.offset_top = -146
	bottom_panel.offset_bottom = -12
	var bstyle := StyleBoxFlat.new()
	bstyle.bg_color = Color(0.1, 0.08, 0.15, 0.92)
	bstyle.border_color = Color("#C59B43")
	bstyle.set_border_width_all(2)
	bstyle.set_corner_radius_all(12)
	bstyle.set_content_margin_all(14)
	bottom_panel.add_theme_stylebox_override("panel", bstyle)
	ui_layer.add_child(bottom_panel)
	ui_layer.move_child(bottom_panel, 3)

	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 20)
	bottom_panel.add_child(bottom_hbox)

	# 좌측: 대화 영역
	var dlg_vbox := VBoxContainer.new()
	dlg_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dlg_vbox.add_theme_constant_override("separation", 6)
	bottom_hbox.add_child(dlg_vbox)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 16)
	speaker_label.add_theme_color_override("font_color", Color("#FDE68A"))
	dlg_vbox.add_child(speaker_label)

	dialogue_label = Label.new()
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.add_theme_font_size_override("font_size", 17)
	dialogue_label.add_theme_color_override("font_color", Color("#F8FAFC"))
	dlg_vbox.add_child(dialogue_label)

	var vsep := VSeparator.new()
	bottom_hbox.add_child(vsep)

	# 우측: 인벤토리 영역
	var inv_vbox := VBoxContainer.new()
	inv_vbox.custom_minimum_size = Vector2(440, 0)
	inv_vbox.add_theme_constant_override("separation", 6)
	bottom_hbox.add_child(inv_vbox)

	item_desc_label = Label.new()
	item_desc_label.add_theme_font_size_override("font_size", 14)
	item_desc_label.add_theme_color_override("font_color", Color("#CBD5E1"))
	item_desc_label.text = "소지품 (두 조각을 순서대로 눌러 조합할 수 있습니다)"
	inv_vbox.add_child(item_desc_label)

	inventory_box = HBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 8)
	inv_vbox.add_child(inventory_box)


func _on_hotspot_hovered(label_text: String) -> void:
	hover_label.text = label_text


func _on_flag_changed(flag_name: String, value: bool) -> void:
	if flag_name == "tick_joined":
		tick_hint_btn.visible = value


func _on_tick_hint_pressed() -> void:
	var hint := GameState.get_tick_hint()
	if hint != "":
		_show_dialogue("티크 (힌트)", hint)


func _show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = "【 %s 】" % speaker
	dialogue_label.text = text


func _refresh_inventory(items: Array[String]) -> void:
	for child in inventory_box.get_children():
		child.queue_free()

	if items.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "(아직 가진 물건이 없습니다)"
		empty_lbl.add_theme_color_override("font_color", Color("#64748B"))
		inventory_box.add_child(empty_lbl)
		return

	for item_id in items:
		var info := GameState.get_item_info(item_id)
		var btn := Button.new()
		btn.text = "%s %s" % [str(info.get("symbol", "")), str(info.get("name", item_id))]
		btn.custom_minimum_size = Vector2(130, 48)
		btn.toggle_mode = true
		btn.button_pressed = (GameState.selected_item_id == item_id)
		btn.pressed.connect(func(): GameState.select_item(item_id))
		inventory_box.add_child(btn)


func _on_selection_changed(selected_id: String) -> void:
	_refresh_inventory(GameState.inventory)
	if selected_id == "":
		item_desc_label.text = "소지품 (아이템을 선택해 장치에 사용하거나 서로 조합하세요)"
	else:
		var info := GameState.get_item_info(selected_id)
		item_desc_label.text = "선택됨: %s — %s" % [str(info.get("name", "")), str(info.get("desc", ""))]


func _on_hotspot_clicked(hotspot_id: String) -> void:
	match hotspot_id:
		"coat":
			if not GameState.has_flag("coat_searched"):
				GameState.set_flag("coat_searched", true)
				GameState.set_flag("tick_joined", true)
				GameState.add_item("ticket_left")
				_show_dialogue("티크", "짹! 드디어 깨어났구나! 나는 태엽 참새 티크야. 주머니에서 [찢어진 승차권 (좌)]을 찾았어! 막히면 오른쪽 위 내 버튼을 눌러줘!")
			else:
				_show_dialogue("나레이션", "내 몸보다 조금 큰 오래된 남색 코트다. 주머니는 이제 비어 있다.")
		"window":
			modal.open_window_view()
		"table":
			modal.open_table_view()
		"mirror":
			modal.open_mirror_view()
		"suitcase":
			modal.open_suitcase_view()
		"validator":
			_handle_validator_click()
		"door":
			if GameState.has_flag("door_unlocked"):
				GameState.set_flag("chapter_cleared", true)
				modal.open_chapter_clear_view()
			else:
				_show_dialogue("부엉이 차장 (방송)", "\"표에 목적지가 없는 승객은 내릴 수 없습니다. 먼저 옆의 황동 검표기에 승차권을 확인받으세요.\"")


func _handle_validator_click() -> void:
	if GameState.has_flag("door_unlocked"):
		_show_dialogue("티크", "검표기 불빛이 초록색으로 켜졌어! 이제 오른쪽 문으로 나가자!")
		return

	if not GameState.has_flag("validator_wound"):
		if GameState.selected_item_id == "brass_key":
			GameState.remove_item("brass_key")
			GameState.set_flag("validator_wound", true)
			_show_dialogue("티크", "끼릭끼릭—! 태엽이 감기면서 부엉이 검표기 눈에 노란 불이 들어왔어! 이제 복원된 승차권을 넣어보자!")
		else:
			_show_dialogue("나레이션", "황동 부엉이 모양의 검표기다. 태엽이 풀려 있어 움직이지 않는다. 아래에 작은 열쇠 구멍이 보인다.")
		return

	if GameState.selected_item_id == "ticket_full":
		GameState.remove_item("ticket_full")
		GameState.set_flag("door_unlocked", true)
		_show_dialogue("티크", "찰칵—! 승차권에 별 모양 구멍이 뚫리면서 5호차 문이 열렸어! 해냈어!")
	else:
		_show_dialogue("티크", "검표기가 승차권을 기다리고 있어! 인벤토리에서 [복원된 승차권]을 선택해 넣어보자.")

