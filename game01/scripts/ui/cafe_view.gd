extends Control

# cafe_view.gd - Asset Rendering & Interactive Gameplay View for Study Cafe Tycoon

var bg_texture: Texture2D
var coffee_bar_texture: Texture2D

var floating_texts: Array = []
var steam_time: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(800, 520)
	
	if ResourceLoader.exists("res://assets/cafe_bg.png"):
		bg_texture = ResourceLoader.load("res://assets/cafe_bg.png")
	if ResourceLoader.exists("res://assets/coffee_bar.png"):
		coffee_bar_texture = ResourceLoader.load("res://assets/coffee_bar.png")
		
	# Connect Signals to Redraw IMMEDIATELY when upgrades are bought!
	GameState.upgrade_purchased.connect(func(_cat, _lvl): queue_redraw())
	GameState.customer_arrived.connect(func(_c): queue_redraw())
	GameState.customer_left.connect(_on_customer_left)
	GameState.order_created.connect(func(_cid, _type): queue_redraw())
	GameState.order_served.connect(_on_order_served)
	GameState.villain_appeared.connect(func(_cid, _vtype): queue_redraw())
	GameState.villain_resolved.connect(_on_villain_resolved)
	GameState.seat_dirty.connect(func(_sidx): queue_redraw())
	GameState.seat_cleaned.connect(_on_seat_cleaned)

func _process(delta: float) -> void:
	steam_time += delta
	
	var to_remove = []
	for ft in floating_texts:
		ft["pos"].y -= delta * 30.0
		ft["alpha"] -= delta * 1.2
		if ft["alpha"] <= 0.0:
			to_remove.append(ft)
			
	for ft in to_remove:
		floating_texts.erase(ft)
		
	queue_redraw()

func _on_customer_left(c: Dictionary, earnings: float) -> void:
	var pos = get_seat_position(c["seat_index"])
	floating_texts.append({
		"text": "+%d ₩ (이용료)" % int(earnings),
		"pos": pos + Vector2(0, -30),
		"alpha": 1.0,
		"color": Color(0.96, 0.62, 0.07)
	})

func _on_order_served(customer_id: int, tip: float) -> void:
	var c = get_customer_by_id(customer_id)
	if not c.is_empty():
		var pos = get_seat_position(c["seat_index"])
		floating_texts.append({
			"text": "+%d ₩ (음료 서빙!) ☕" % int(tip),
			"pos": pos + Vector2(0, -45),
			"alpha": 1.0,
			"color": Color(0.1, 0.8, 0.4)
		})

func _on_villain_resolved(customer_id: int) -> void:
	var c = get_customer_by_id(customer_id)
	if not c.is_empty():
		var pos = get_seat_position(c["seat_index"])
		floating_texts.append({
			"text": "경고 조치 완료! ⭐+0.1",
			"pos": pos + Vector2(0, -45),
			"alpha": 1.0,
			"color": Color(0.3, 0.7, 1.0)
		})

func _on_seat_cleaned(seat_index: int) -> void:
	var pos = get_seat_position(seat_index)
	floating_texts.append({
		"text": "쓱싹 청소 완료! +80₩ ✨",
		"pos": pos + Vector2(0, -30),
		"alpha": 1.0,
		"color": Color(0.9, 0.9, 0.4)
	})

func _gui_input(event: InputEvent) -> void:
	# Ignore input if any overlay panel is open!
	var root = get_tree().current_scene
	if root != null:
		var upg_overlay = root.get_node_or_null("UpgradePanelOverlay")
		var rev_overlay = root.get_node_or_null("ReviewPanelOverlay")
		var rep_overlay = root.get_node_or_null("DailyReportPanelOverlay")
		if (upg_overlay and upg_overlay.visible) or (rev_overlay and rev_overlay.visible) or (rep_overlay and rep_overlay.visible):
			return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		
		# 1. Click Coffee Bar -> Serve available orders!
		var bar_rect = Rect2(30, 30, 220, 110)
		if bar_rect.has_point(click_pos):
			if GameState.active_orders.size() > 0:
				var first_cid = GameState.active_orders.keys()[0]
				GameState.serve_order(first_cid)
			return
			
		# 2. Click Customer Seats (Order, Villain, Study Tip, or Dirty Seat)
		var capacity = GameState.get_max_capacity()
		for i in range(capacity):
			var seat_pos = get_seat_position(i)
			if click_pos.distance_to(seat_pos) < 45.0:
				if GameState.dirty_seats.has(i):
					GameState.clean_seat(i)
					return
					
				var customer = get_customer_at_seat(i)
				if not customer.is_empty():
					var cid = customer["id"]
					if GameState.active_orders.has(cid):
						GameState.serve_order(cid)
						return
						
					if GameState.active_villains.has(cid):
						GameState.warn_villain(cid)
						return
						
					var tip = 50.0 * customer["pay_rate"]
					GameState.add_money(tip)
					floating_texts.append({
						"text": "+%d ₩ (열공 팁!)" % int(tip),
						"pos": seat_pos + Vector2(0, -40),
						"alpha": 1.0,
						"color": Color(0.06, 0.72, 0.5)
					})
					return

func _draw() -> void:
	var rect = get_rect()
	var w = rect.size.x
	var h = rect.size.y
	
	# 1. Draw Background Image or Fallback Floor
	if bg_texture != null:
		draw_texture_rect(bg_texture, Rect2(0, 0, w, h), false)
		draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.04, 0.04, 0.35))
	else:
		draw_rect(Rect2(0, 0, w, h), Color(0.12, 0.11, 0.10))
		var floor_margin = 16.0
		var floor_rect = Rect2(floor_margin, floor_margin, w - floor_margin*2, h - floor_margin*2)
		draw_rect(floor_rect, Color(0.24, 0.20, 0.17))
		
	# 2. Draw Coffee Bar Asset Counter (Top Left)
	var bar_rect = Rect2(30, 30, 220, 110)
	if coffee_bar_texture != null:
		draw_texture_rect(coffee_bar_texture, bar_rect, false)
		draw_rect(bar_rect, Color(0.96, 0.62, 0.07), false, 2.5)
	else:
		draw_rect(bar_rect, Color(0.16, 0.13, 0.11), true)
		draw_rect(bar_rect, Color(0.8, 0.55, 0.22), false, 3.0)
		
	var coffee_level = GameState.upgrades["coffee_bar"]["level"]
	draw_string(ThemeDB.fallback_font, Vector2(40, 50), "☕ 스낵 & 머신 Lv.%d" % coffee_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.96, 0.62, 0.07))
	
	if GameState.active_orders.size() > 0:
		var order_count_str = "🔔 주문 대기 %d건 (터치 서빙!)" % GameState.active_orders.size()
		draw_string(ThemeDB.fallback_font, Vector2(40, 125), order_count_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.4, 0.4))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(40, 125), "스낵바 준비 완료", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.8, 0.75))
		
	# 3. Entrance & Reception Counter (Top Right)
	var counter_rect = Rect2(w - 230, 30, 200, 90)
	draw_rect(counter_rect, Color(0.16, 0.13, 0.11, 0.9), true)
	draw_rect(counter_rect, Color(0.06, 0.72, 0.5), false, 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(w - 215, 60), "🛎️ 카운터 & 무인 정산", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.06, 0.72, 0.5))
	var staff_level = GameState.upgrades["staff_counter"]["level"]
	var staff_str = "매니저 자동 정산 Lv.%d" % staff_level if staff_level > 0 else "무인 정산기 활성"
	draw_string(ThemeDB.fallback_font, Vector2(w - 215, 85), staff_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.8, 0.75))
	
	# 4. Render Study Desks & Interactive Seats Layout
	var total_capacity = GameState.get_max_capacity()
	var cols = 4
	var start_x = 60.0
	var start_y = 160.0
	var cell_w = 160.0
	var cell_h = 100.0
	
	for i in range(total_capacity):
		var col = i % cols
		var row = i / cols
		var seat_pos = Vector2(start_x + col * (cell_w + 30.0), start_y + row * (cell_h + 30.0))
		var is_booth = i >= GameState.upgrades["open_seats"]["level"] * 3
		
		var desk_color = Color(0.18, 0.14, 0.12, 0.9) if not is_booth else Color(0.15, 0.12, 0.18, 0.9)
		var border_color = Color(0.96, 0.62, 0.07) if not is_booth else Color(0.8, 0.4, 0.9)
		
		# Desk Base
		var desk_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		draw_rect(desk_rect, desk_color, true)
		draw_rect(desk_rect, border_color, false, 2.0)
		
		# Desk Title Label
		var label = "몰입 1인석 #%d" % (i + 1) if is_booth else "오픈석 #%d" % (i + 1)
		draw_string(ThemeDB.fallback_font, seat_pos + Vector2(10, 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.8, 0.75))
		
		# Warm Desk Lamp Aura
		var lamp_pos = seat_pos + Vector2(cell_w - 22, 22)
		draw_circle(lamp_pos, 16.0, Color(0.96, 0.62, 0.07, 0.25))
		draw_circle(lamp_pos, 5.0, Color(1.0, 0.85, 0.4))
		
		# Check if Seat is Dirty
		if GameState.dirty_seats.has(i):
			draw_rect(desk_rect, Color(0.4, 0.1, 0.1, 0.6), true)
			draw_string(ThemeDB.fallback_font, seat_pos + Vector2(25, cell_h*0.6), "🧹 청소 필요!\n(클릭시 쓱싹!)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.6, 0.6))
			continue
			
		# Check Customer at Seat
		var customer = get_customer_at_seat(i)
		if not customer.is_empty():
			var cid = customer["id"]
			var cust_center = seat_pos + Vector2(cell_w * 0.5, cell_h * 0.55)
			
			draw_circle(cust_center, 22.0, Color(0.1, 0.1, 0.1))
			draw_circle(cust_center, 18.0, customer["color"])
			draw_string(ThemeDB.fallback_font, cust_center + Vector2(-8, 6), customer["icon"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
			
			var p_ratio = customer["study_time"] / customer["duration"]
			var progress_bar_rect = Rect2(seat_pos.x + 15, seat_pos.y + cell_h - 14, cell_w - 30, 6)
			draw_rect(progress_bar_rect, Color(0.1, 0.1, 0.1), true)
			draw_rect(Rect2(progress_bar_rect.position.x, progress_bar_rect.position.y, progress_bar_rect.size.x * p_ratio, 6), Color(0.1, 0.8, 0.4), true)
			
			if GameState.active_orders.has(cid):
				var order = GameState.active_orders[cid]
				var bubble_rect = Rect2(seat_pos.x + 10, seat_pos.y - 25, cell_w - 20, 24)
				draw_rect(bubble_rect, Color(1.0, 0.95, 0.8), true)
				draw_rect(bubble_rect, Color(0.9, 0.5, 0.1), false, 2.0)
				draw_string(ThemeDB.fallback_font, bubble_rect.position + Vector2(8, 16), "👉 " + order["type"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.1, 0.0))
				
			if GameState.active_villains.has(cid):
				var v = GameState.active_villains[cid]
				var v_msg = "📢 시끄러움!"
				if v["type"] == "phone": v_msg = "📱 큰소리 통화 중!"
				elif v["type"] == "snack": v_msg = "🍿 과자 부스럭!"
				elif v["type"] == "snore": v_msg = "😴 코골이 중!"
				
				var v_rect = Rect2(seat_pos.x + 5, seat_pos.y - 26, cell_w - 10, 24)
				draw_rect(v_rect, Color(1.0, 0.3, 0.3), true)
				draw_rect(v_rect, Color(1.0, 1.0, 1.0), false, 2.0)
				draw_string(ThemeDB.fallback_font, v_rect.position + Vector2(6, 16), "⚠️ " + v_msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		else:
			draw_string(ThemeDB.fallback_font, seat_pos + Vector2(cell_w*0.35, cell_h*0.6), "비어있음", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.5, 0.5, 0.5, 0.6))
			
	# 5. Draw Floating Cash & Action Texts
	for ft in floating_texts:
		var c = ft["color"]
		c.a = ft["alpha"]
		draw_string(ThemeDB.fallback_font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 15, c)

func get_customer_at_seat(seat_idx: int) -> Dictionary:
	for c in GameState.active_customers:
		if c["seat_index"] == seat_idx:
			return c
	return {}

func get_customer_by_id(cid: int) -> Dictionary:
	for c in GameState.active_customers:
		if c["id"] == cid:
			return c
	return {}

func get_seat_position(index: int) -> Vector2:
	var cols = 4
	var start_x = 60.0
	var start_y = 160.0
	var cell_w = 160.0
	var cell_h = 100.0
	var col = index % cols
	var row = index / cols
	return Vector2(start_x + col * (cell_w + 30.0) + cell_w*0.5, start_y + row * (cell_h + 30.0) + cell_h*0.5)
