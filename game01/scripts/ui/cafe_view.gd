extends Control

# cafe_view.gd - Renderer with High-Res Textures, Day/Night Ambient Lighting & Grid Decorating Mode

var bg_texture: Texture2D
var coffee_bar_texture: Texture2D

var floating_texts: Array = []
var steam_time: float = 0.0

var view_offset: Vector2 = Vector2.ZERO
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(800, 520)
	
	if ResourceLoader.exists("res://assets/cafe_bg.png"):
		bg_texture = load("res://assets/cafe_bg.png")
	elif FileAccess.file_exists("res://assets/cafe_bg.png"):
		var img = Image.load_from_file("res://assets/cafe_bg.png")
		if img != null:
			bg_texture = ImageTexture.create_from_image(img)
			
	if ResourceLoader.exists("res://assets/coffee_bar.png"):
		coffee_bar_texture = load("res://assets/coffee_bar.png")
	elif FileAccess.file_exists("res://assets/coffee_bar.png"):
		var img_bar = Image.load_from_file("res://assets/coffee_bar.png")
		if img_bar != null:
			coffee_bar_texture = ImageTexture.create_from_image(img_bar)
		
	GameState.zone_changed.connect(func(_z): queue_redraw())
	GameState.upgrade_purchased.connect(func(_cat, _lvl): queue_redraw())
	GameState.customer_arrived.connect(func(_c): queue_redraw())
	GameState.customer_left.connect(_on_customer_left)
	GameState.order_created.connect(func(_cid, _type): queue_redraw())
	GameState.order_served.connect(_on_order_served)
	GameState.villain_appeared.connect(func(_cid, _vtype): queue_redraw())
	GameState.villain_resolved.connect(_on_villain_resolved)
	GameState.seat_dirty.connect(func(_sidx): queue_redraw())
	GameState.seat_cleaned.connect(_on_seat_cleaned)
	GameState.time_of_day_changed.connect(func(_tod): queue_redraw())
	GameState.decor_mode_changed.connect(func(_active): queue_redraw())

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
	var pos = c.get("pos", Vector2(1150, 70))
	floating_texts.append({
		"text": "+%d ₩ (이용료)" % int(earnings),
		"pos": pos + Vector2(0, -30),
		"alpha": 1.0,
		"color": Color(0.96, 0.62, 0.07)
	})

func _on_order_served(customer_id: int, tip: float) -> void:
	var c = get_customer_by_id(customer_id)
	if not c.is_empty():
		var pos = c["pos"]
		floating_texts.append({
			"text": "+%d ₩ (음료 서빙!) ☕" % int(tip),
			"pos": pos + Vector2(0, -45),
			"alpha": 1.0,
			"color": Color(0.1, 0.8, 0.4)
		})

func _on_villain_resolved(customer_id: int) -> void:
	var c = get_customer_by_id(customer_id)
	if not c.is_empty():
		var pos = c["pos"]
		floating_texts.append({
			"text": "경고 조치 완료! ⭐+0.1",
			"pos": pos + Vector2(0, -45),
			"alpha": 1.0,
			"color": Color(0.3, 0.7, 1.0)
		})

func _on_seat_cleaned(seat_index: int) -> void:
	var pos = GameState.get_seat_position(seat_index)
	floating_texts.append({
		"text": "🧹 쓱싹 청소 완료! +80₩ ✨",
		"pos": pos + Vector2(0, -30),
		"alpha": 1.0,
		"color": Color(0.9, 0.9, 0.4)
	})

func _gui_input(event: InputEvent) -> void:
	var root = get_tree().current_scene
	if root != null:
		var upg_overlay = root.get_node_or_null("UpgradePanelOverlay")
		var rev_overlay = root.get_node_or_null("ReviewPanelOverlay")
		if (upg_overlay and upg_overlay.visible) or (rev_overlay and rev_overlay.visible):
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_pos = event.position - view_offset
			else:
				is_panning = false
				
	if event is InputEventMouseMotion and is_panning:
		view_offset = event.position - pan_start_pos
		view_offset.x = clamp(view_offset.x, -400.0, 200.0)
		view_offset.y = clamp(view_offset.y, -400.0, 200.0)
		queue_redraw()
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position - view_offset
		
		# If Decorating Mode is Active, place custom furniture or partitions
		if GameState.is_decorating_mode:
			var capacity = GameState.get_max_capacity()
			for i in range(capacity):
				var seat_pos = GameState.get_seat_position(i)
				if click_pos.distance_to(seat_pos) < 50.0:
					if GameState.install_partition(i, "curtain"):
						floating_texts.append({
							"text": "🎪 방음 커튼 설치 완료! (⭐+0.1)",
							"pos": seat_pos + Vector2(0, -30),
							"alpha": 1.0,
							"color": Color(0.9, 0.4, 0.8)
						})
					return
					
			if GameState.add_decoration(click_pos, "plant"):
				floating_texts.append({
					"text": "🪴 공기정화 화분 배치! (⭐+0.08)",
					"pos": click_pos + Vector2(0, -30),
					"alpha": 1.0,
					"color": Color(0.1, 0.8, 0.4)
				})
			return
		
		# Check Mascot Cat Click
		if click_pos.distance_to(GameState.cat_pos) < 35.0:
			GameState.pet_cat()
			floating_texts.append({
				"text": "🐱 야옹~! 힐링 골골송! (⭐+0.05)",
				"pos": GameState.cat_pos + Vector2(0, -35),
				"alpha": 1.0,
				"color": Color(1.0, 0.6, 0.8)
			})
			return
		if GameState.current_zone == "lounge" or GameState.current_zone == "study":
			var bar_rect = Rect2(30, 30, 220, 150)
			if bar_rect.has_point(click_pos):
				if GameState.active_orders.size() > 0:
					var first_cid = GameState.active_orders.keys()[0]
					GameState.serve_order(first_cid)
				return
				
		# Check Seats Click
		if GameState.current_zone == "study":
			var capacity = GameState.get_max_capacity()
			for i in range(capacity):
				var seat_pos = GameState.get_seat_position(i)
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
	
	# 1. Draw High-Res Background PNG Texture
	if bg_texture != null:
		draw_texture_rect(bg_texture, Rect2(0, 0, w, h), false)
		draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.04, 0.04, 0.25))
	else:
		draw_rect(Rect2(0, 0, w, h), Color(0.12, 0.11, 0.10))
		
	# 2. Draw Real-Time Time-of-Day Ambient Lighting Overlay
	if GameState.time_of_day == "DUSK":
		draw_rect(Rect2(0, 0, w, h), Color(1.0, 0.65, 0.2, 0.22))
	elif GameState.time_of_day == "NIGHT":
		draw_rect(Rect2(0, 0, w, h), Color(0.1, 0.12, 0.3, 0.42))
		
	# 3. Draw Grid Overlay in Decorating Mode
	if GameState.is_decorating_mode:
		var grid_step = 64.0
		for x in range(0, int(w), int(grid_step)):
			draw_line(Vector2(x, 0), Vector2(x, h), Color(0.96, 0.62, 0.07, 0.3), 1.0)
		for y in range(0, int(h), int(grid_step)):
			draw_line(Vector2(0, y), Vector2(w, y), Color(0.96, 0.62, 0.07, 0.3), 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(w*0.35, 40), "🔨 인테리어 꾸미기 모드: 원하시는 위치를 터치하여 화분(150₩)을 배치하세요!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.96, 0.62, 0.07))
		
	# 4. Draw Custom Placed Furniture/Decorations
	for dec in GameState.custom_decorations:
		var d_pos = dec["pos"]
		draw_circle(d_pos, 16.0, Color(0.1, 0.8, 0.4, 0.3))
		draw_string(ThemeDB.fallback_font, d_pos + Vector2(-10, 6), "🪴", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		
	# 5. Draw Zone Based View Content
	if GameState.current_zone == "study":
		draw_study_zone(w, h)
	elif GameState.current_zone == "lounge":
		draw_lounge_zone(w, h)
	elif GameState.current_zone == "front":
		draw_front_zone(w, h)
		
	# 6. Draw Floating Action Texts
	for ft in floating_texts:
		var c = ft["color"]
		c.a = ft["alpha"]
		draw_string(ThemeDB.fallback_font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 15, c)

func draw_study_zone(w: float, h: float) -> void:
	draw_rect(Rect2(20, 20, 260, 36), Color(0.1, 0.08, 0.07, 0.85), true)
	draw_rect(Rect2(20, 20, 260, 36), Color(0.96, 0.62, 0.07), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(35, 43), "🗺️ 메인 열공 존 (Study Zone)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.96, 0.62, 0.07))
	
	var gate_rect = Rect2(w - 140, 20, 120, 70)
	draw_rect(gate_rect, Color(0.16, 0.13, 0.11, 0.9), true)
	draw_rect(gate_rect, Color(0.06, 0.72, 0.5), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(w - 130, 55), "🚪 입출구 게이트", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.06, 0.72, 0.5))
	
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
		
		var desk_color = Color(0.18, 0.14, 0.12, 0.85) if not is_booth else Color(0.15, 0.12, 0.18, 0.85)
		var border_color = Color(0.96, 0.62, 0.07) if not is_booth else Color(0.8, 0.4, 0.9)
		
		var desk_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		draw_rect(desk_rect, desk_color, true)
		draw_rect(desk_rect, border_color, false, 2.0)
		
		var label = "프라이빗 1인실 #%d" % (i + 1) if is_booth else "오픈 카페석 #%d" % (i + 1)
		draw_string(ThemeDB.fallback_font, seat_pos + Vector2(10, 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.8, 0.75))
		
		# Draw Custom Partition / Curtain Overlays
		if GameState.seat_partitions.has(i):
			var p_type = GameState.seat_partitions[i]
			if p_type == "curtain":
				draw_rect(Rect2(seat_pos.x, seat_pos.y, cell_w, 18), Color(0.8, 0.2, 0.3, 0.85), true)
				draw_string(ThemeDB.fallback_font, seat_pos + Vector2(25, 14), "🎪 방음 커튼 설치됨", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
			else:
				draw_rect(Rect2(seat_pos.x, seat_pos.y, 8, cell_h), Color(0.8, 0.4, 0.9, 0.85), true)
				draw_string(ThemeDB.fallback_font, seat_pos + Vector2(14, 14), "🔮 몰입 칸막이", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		
		# Glowing Desk Lamp Halos
		var lamp_is_on = GameState.lamp_states.get(i, true)
		var lamp_pos = seat_pos + Vector2(cell_w - 22, 22)
		if lamp_is_on:
			var lamp_alpha = 0.75 if GameState.time_of_day == "NIGHT" else (0.45 if GameState.time_of_day == "DUSK" else 0.25)
			draw_circle(lamp_pos, 42.0, Color(1.0, 0.7, 0.2, lamp_alpha * 0.15))
			draw_circle(lamp_pos, 24.0, Color(0.96, 0.62, 0.07, lamp_alpha * 0.35))
			draw_circle(lamp_pos, 6.0, Color(1.0, 0.9, 0.5))
		else:
			draw_circle(lamp_pos, 5.0, Color(0.3, 0.3, 0.35))
		
		if GameState.dirty_seats.has(i):
			draw_rect(desk_rect, Color(0.4, 0.1, 0.1, 0.65), true)
			draw_string(ThemeDB.fallback_font, seat_pos + Vector2(25, cell_h*0.6), "🧹 청소 필요!\n(클릭시 쓱싹!)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.6, 0.6))
		else:
			var customer_at_seat = get_customer_at_seat(i)
			if customer_at_seat.is_empty():
				draw_string(ThemeDB.fallback_font, seat_pos + Vector2(cell_w*0.35, cell_h*0.6), "비어있음", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.5, 0.5, 0.5, 0.6))
				
	for c in GameState.active_customers:
		var cust_pos = c["pos"]
		var bounce_y = sin(steam_time * 10.0 + c["id"]) * 3.0 if c["state"] != "STUDYING" else 0.0
		var render_pos = cust_pos + Vector2(0, bounce_y)
		
		draw_circle(render_pos, 22.0, Color(0.1, 0.1, 0.1))
		draw_circle(render_pos, 18.0, c["color"])
		draw_string(ThemeDB.fallback_font, render_pos + Vector2(-8, 6), c["icon"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		
		if c["state"] == "WALKING_IN":
			draw_string(ThemeDB.fallback_font, render_pos + Vector2(-25, -25), "🚶 입실 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.9, 0.4))
		elif c["state"] == "LEAVING":
			draw_string(ThemeDB.fallback_font, render_pos + Vector2(-25, -25), "👋 퇴실 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.6, 0.4))
		elif c["state"] == "STUDYING":
			var p_ratio = c["study_time"] / c["duration"]
			var bar_rect = Rect2(render_pos.x - 40, render_pos.y + 24, 80, 5)
			draw_rect(bar_rect, Color(0.1, 0.1, 0.1), true)
			draw_rect(Rect2(bar_rect.position.x, bar_rect.position.y, bar_rect.size.x * p_ratio, 5), Color(0.1, 0.8, 0.4), true)
			
			var cid = c["id"]
			if GameState.active_orders.has(cid):
				var order = GameState.active_orders[cid]
				var bubble_rect = Rect2(render_pos.x - 60, render_pos.y - 45, 120, 24)
				draw_rect(bubble_rect, Color(1.0, 0.95, 0.8), true)
				draw_rect(bubble_rect, Color(0.9, 0.5, 0.1), false, 2.0)
				draw_string(ThemeDB.fallback_font, bubble_rect.position + Vector2(6, 16), "👉 " + order["type"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.1, 0.0))
				
			if GameState.active_villains.has(cid):
				var v = GameState.active_villains[cid]
				var v_msg = "📢 시끄러움!"
				if v["type"] == "phone": v_msg = "📱 큰소리 통화!"
				elif v["type"] == "snack": v_msg = "🍿 과자 부스럭!"
				elif v["type"] == "snore": v_msg = "😴 코골이 중!"
				var v_rect = Rect2(render_pos.x - 60, render_pos.y - 45, 120, 24)
				draw_rect(v_rect, Color(1.0, 0.3, 0.3), true)
				draw_rect(v_rect, Color(1.0, 1.0, 1.0), false, 2.0)
				draw_string(ThemeDB.fallback_font, v_rect.position + Vector2(6, 16), "⚠️ " + v_msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
				
	if GameState.upgrades["staff_cleaner"]["level"] > 0:
		var c_pos = GameState.cleaner_pos
		var c_bounce = sin(steam_time * 12.0) * 4.0
		var c_render = c_pos + Vector2(0, c_bounce)
		
		draw_circle(c_render, 24.0, Color(0.2, 0.2, 0.2))
		draw_circle(c_render, 20.0, Color(0.96, 0.62, 0.07))
		draw_string(ThemeDB.fallback_font, c_render + Vector2(-10, 7), "🧹", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		draw_string(ThemeDB.fallback_font, c_render + Vector2(-35, -28), "🤖 청소 알바", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.96, 0.62, 0.07))

func draw_lounge_zone(w: float, h: float) -> void:
	draw_rect(Rect2(20, 20, 300, 36), Color(0.1, 0.08, 0.07, 0.85), true)
	draw_rect(Rect2(20, 20, 300, 36), Color(0.1, 0.8, 0.4), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(35, 43), "☕ 셀프 스낵바 & 휴게실 (Lounge Zone)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.1, 0.8, 0.4))
	
	var bar_rect = Rect2(60, 90, 340, 260)
	if coffee_bar_texture != null:
		draw_texture_rect(coffee_bar_texture, bar_rect, false)
		draw_rect(bar_rect, Color(0.96, 0.62, 0.07), false, 3.0)
	else:
		draw_rect(bar_rect, Color(0.24, 0.20, 0.17), true)
		draw_rect(bar_rect, Color(0.96, 0.62, 0.07), false, 3.0)
		
	var desc_rect = Rect2(430, 90, 320, 260)
	draw_rect(desc_rect, Color(0.15, 0.13, 0.12, 0.85), true)
	draw_rect(desc_rect, Color(0.1, 0.8, 0.4), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(450, 130), "☕ 셀프 캡슐 커피 & 다과 코너", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.96, 0.62, 0.07))
	draw_string(ThemeDB.fallback_font, Vector2(450, 170), "• 캡슐 커피, 헛개차, 에너지바, 무릎담요 제공", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.8, 0.75))
	draw_string(ThemeDB.fallback_font, Vector2(450, 200), "• 스낵바 재고 상태: 100% (자동 충전 중)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.1, 0.8, 0.4))
	draw_string(ThemeDB.fallback_font, Vector2(450, 230), "• 3M 귀마개 & 독서대 대여소 구비 완료", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.8, 0.75))

func draw_front_zone(w: float, h: float) -> void:
	draw_rect(Rect2(20, 20, 320, 36), Color(0.1, 0.08, 0.07, 0.85), true)
	draw_rect(Rect2(20, 20, 320, 36), Color(0.8, 0.4, 0.9), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(35, 43), "🔑 사물함 & 무인 프런트 (Front & Lockers)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.8, 0.4, 0.9))
	
	draw_string(ThemeDB.fallback_font, Vector2(60, 100), "🔑 고정 사물함 대여 구역 (Lockers)", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.4, 0.9))
	for i in range(12):
		var col = i % 6
		var row = i / 6
		var l_rect = Rect2(60 + col * 110, 130 + row * 100, 95, 80)
		draw_rect(l_rect, Color(0.22, 0.18, 0.26, 0.85), true)
		draw_rect(l_rect, Color(0.8, 0.4, 0.9), false, 2.0)
		draw_string(ThemeDB.fallback_font, l_rect.position + Vector2(10, 25), "사물함 #%d" % (i+1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		var is_rented = i < GameState.lockers_rented
		var status_str = "대여중 🔒" if is_rented else "빈 사물함 🔓"
		var status_col = Color(0.1, 0.8, 0.4) if is_rented else Color(0.6, 0.6, 0.6)
		draw_string(ThemeDB.fallback_font, l_rect.position + Vector2(10, 55), status_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, status_col)

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
