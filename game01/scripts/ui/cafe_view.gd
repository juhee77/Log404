extends Control

# cafe_view.gd - Renderer with High-Res Textures, Day/Night Ambient Lighting & Grid Decorating Mode

var bg_texture: Texture2D
var coffee_bar_texture: Texture2D

var floating_texts: Array = []
var steam_time: float = 0.0

var view_offset: Vector2 = Vector2.ZERO
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO

var student_texture: Texture2D
var developer_texture: Texture2D

var selected_drag_seat: int = -1
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO

var desk_booth_texture: Texture2D
var desk_open_texture: Texture2D

func _ready() -> void:
	custom_minimum_size = Vector2(800, 520)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if FileAccess.file_exists("res://assets/cafe_bg.png"):
		var img = Image.load_from_file("res://assets/cafe_bg.png")
		if img != null:
			bg_texture = ImageTexture.create_from_image(img)
			
	if FileAccess.file_exists("res://assets/coffee_bar.png"):
		var img_bar = Image.load_from_file("res://assets/coffee_bar.png")
		if img_bar != null:
			coffee_bar_texture = ImageTexture.create_from_image(img_bar)
			
	if FileAccess.file_exists("res://assets/customer_student.png"):
		var img_s = Image.load_from_file("res://assets/customer_student.png")
		if img_s != null:
			student_texture = ImageTexture.create_from_image(img_s)
			
	if FileAccess.file_exists("res://assets/customer_developer.png"):
		var img_d = Image.load_from_file("res://assets/customer_developer.png")
		if img_d != null:
			developer_texture = ImageTexture.create_from_image(img_d)

	if FileAccess.file_exists("res://assets/desk_booth_1p.png"):
		var img_b = Image.load_from_file("res://assets/desk_booth_1p.png")
		if img_b != null:
			desk_booth_texture = ImageTexture.create_from_image(img_b)

	if FileAccess.file_exists("res://assets/desk_open_cafe.png"):
		var img_o = Image.load_from_file("res://assets/desk_open_cafe.png")
		if img_o != null:
			desk_open_texture = ImageTexture.create_from_image(img_o)
		
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

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			view_offset.y = max(view_offset.y - 40.0, -400.0)
			queue_redraw()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			view_offset.y = min(view_offset.y + 40.0, 50.0)
			queue_redraw()
			return
			
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = true
			pan_start_pos = event.position - view_offset
	elif event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = false
				
	if event is InputEventMouseMotion and is_panning:
		view_offset = event.position - pan_start_pos
		view_offset.x = clamp(view_offset.x, -400.0, 200.0)
		view_offset.y = clamp(view_offset.y, -400.0, 200.0)
		queue_redraw()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position - view_offset
		if event.pressed:
			# 1. Check Mascot Cat Click
			if click_pos.distance_to(GameState.cat_pos) < 35.0:
				GameState.pet_cat()
				floating_texts.append({
					"text": "🐱 야옹~! 힐링 골골송! (⭐+0.05)",
					"pos": GameState.cat_pos + Vector2(0, -35),
					"alpha": 1.0,
					"color": Color(1.0, 0.6, 0.8)
				})
				return

			# 2. Check Coffee Bar Click
			var bar_rect = Rect2(30, 30, 220, 150)
			if bar_rect.has_point(click_pos):
				if GameState.active_orders.size() > 0:
					var first_cid = GameState.active_orders.keys()[0]
					GameState.serve_order(first_cid)
				return
				
			# 3. Check Seat Selection & Drag Start
			var capacity = GameState.get_max_capacity()
			for i in range(capacity):
				var seat_pos = GameState.get_seat_position(i)
				if click_pos.distance_to(seat_pos) < 80.0:
					if GameState.dirty_seats.has(i):
						GameState.clean_seat(i)
						return
						
					selected_drag_seat = i
					is_dragging = true
					drag_start_mouse_pos = event.position
					floating_texts.append({
						"text": "🧲 책상 드래그 시작! 마우스로 이동하세요",
						"pos": seat_pos + Vector2(0, -35),
						"alpha": 1.0,
						"color": Color(0.2, 0.9, 0.5)
					})
					queue_redraw()
					return
		else:
			if is_dragging and selected_drag_seat != -1:
				is_dragging = false
				var final_pos = GameState.get_seat_position(selected_drag_seat)
				floating_texts.append({
					"text": "📍 책상 마그네틱 배치 완료!",
					"pos": final_pos + Vector2(0, -35),
					"alpha": 1.0,
					"color": Color(0.96, 0.62, 0.07)
				})
				selected_drag_seat = -1
				GameState.save_game()
				queue_redraw()
				return

	if event is InputEventMouseMotion and is_dragging and selected_drag_seat != -1:
		var target_pos = event.position - view_offset
		var base_pos = GameState.get_base_seat_position(selected_drag_seat)
		var raw_offset = target_pos - base_pos
		GameState.set_seat_custom_offset_snapped(selected_drag_seat, raw_offset)
		queue_redraw()

func _draw() -> void:
	var rect = get_rect()
	var w = rect.size.x
	var h = rect.size.y
	
	# 1. Draw Background PNG Texture with Cozy Ambient Tint
	if bg_texture != null:
		draw_texture_rect(bg_texture, Rect2(0, 0, w, h), false)
		draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.05, 0.04, 0.52))
	else:
		draw_rect(Rect2(0, 0, w, h), Color(0.12, 0.11, 0.10))
		
	# 2. Draw Real-Time Time-of-Day Ambient Lighting Overlay
	if GameState.time_of_day == "DUSK":
		draw_rect(Rect2(0, 0, w, h), Color(1.0, 0.65, 0.2, 0.22))
	elif GameState.time_of_day == "NIGHT":
		draw_rect(Rect2(0, 0, w, h), Color(0.1, 0.12, 0.3, 0.42))
	
	# Render Rain Weather Glass Waterdrops
	if GameState.weather == "RAINY":
		var t_time = Time.get_ticks_msec() * 0.002
		for r in range(16):
			var rx = 100 + r * 45
			var ry = fmod(r * 30 + t_time * 60, 240.0) + 60
			draw_circle(Vector2(rx, ry) + view_offset, 3.5, Color(0.7, 0.85, 1.0, 0.55))
			draw_line(Vector2(rx, ry - 12) + view_offset, Vector2(rx, ry) + view_offset, Color(0.7, 0.85, 1.0, 0.35), 1.5)

	# 3. Draw Grid Overlay & Banner in Decorating Mode
	if GameState.is_decorating_mode:
		var grid_step = 64.0
		for x in range(0, int(w), int(grid_step)):
			draw_line(Vector2(x, 0), Vector2(x, h), Color(0.96, 0.62, 0.07, 0.25), 1.0)
		for y in range(0, int(h), int(grid_step)):
			draw_line(Vector2(0, y), Vector2(w, y), Color(0.96, 0.62, 0.07, 0.25), 1.0)
			
		var banner_rect = Rect2(60, 20, w - 120, 36)
		draw_rect(banner_rect, Color(0.12, 0.1, 0.08, 0.95), true)
		draw_rect(banner_rect, Color(0.96, 0.62, 0.07), false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(75, 43), "🔨 책상 자리 옮기기 모드: 책상을 클릭하여 잡은 후, 원하시는 위치를 클릭해 재배치하세요!", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.96, 0.62, 0.07))
		
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
	
	for i in range(total_capacity):
		var col = i % cols
		var row = i / cols
		var is_booth = i >= GameState.upgrades["open_seats"]["level"] * 3
		var cell_w = 220.0 if is_booth else 140.0
		var cell_h = 150.0 if is_booth else 90.0
		
		var seat_pos = Vector2(start_x + col * (160.0 + 30.0), start_y + row * (100.0 + 30.0))
		if GameState.seat_custom_offsets.has(i):
			seat_pos += GameState.seat_custom_offsets[i]
		
		var desk_color = Color(0.18, 0.14, 0.12, 0.85) if not is_booth else Color(0.15, 0.12, 0.18, 0.85)
		var border_color = Color(0.96, 0.62, 0.07) if not is_booth else Color(0.8, 0.4, 0.9)
		
		var desk_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		# 3D Isometric Floor Shadow
		var shadow_poly = PackedVector2Array([
			Vector2(seat_pos.x + 8, seat_pos.y + cell_h + 14),
			Vector2(seat_pos.x + cell_w + 14, seat_pos.y + cell_h + 14),
			Vector2(seat_pos.x + cell_w + 22, seat_pos.y + cell_h + 22),
			Vector2(seat_pos.x + 16, seat_pos.y + cell_h + 22)
		])
		draw_polygon(shadow_poly, PackedColorArray([Color(0.02, 0.02, 0.02, 0.4)]))

		# 3D Desk Front Extrusion Face
		var front_face = PackedVector2Array([
			Vector2(seat_pos.x, seat_pos.y + cell_h),
			Vector2(seat_pos.x + cell_w, seat_pos.y + cell_h),
			Vector2(seat_pos.x + cell_w, seat_pos.y + cell_h + 12),
			Vector2(seat_pos.x, seat_pos.y + cell_h + 12)
		])
		draw_polygon(front_face, PackedColorArray([Color(0.12, 0.09, 0.07, 0.95)]))

		# 3D Desk Side Extrusion Face
		var side_face = PackedVector2Array([
			Vector2(seat_pos.x + cell_w, seat_pos.y),
			Vector2(seat_pos.x + cell_w + 12, seat_pos.y + 12),
			Vector2(seat_pos.x + cell_w + 12, seat_pos.y + cell_h + 12),
			Vector2(seat_pos.x + cell_w, seat_pos.y + cell_h)
		])
		draw_polygon(side_face, PackedColorArray([Color(0.09, 0.07, 0.05, 0.95)]))

		# 3D Desk Surface Top
		draw_rect(desk_rect, desk_color, true)
		draw_rect(desk_rect, border_color, false, 2.0)
		
		if is_booth and desk_booth_texture != null:
			draw_texture_rect(desk_booth_texture, desk_rect, false, Color(1, 1, 1, 0.9))
		elif not is_booth and desk_open_texture != null:
			draw_texture_rect(desk_open_texture, desk_rect, false, Color(1, 1, 1, 0.9))

		if i == selected_drag_seat:
			draw_rect(desk_rect, Color(0.2, 0.9, 0.5, 0.35), true)
			draw_rect(desk_rect, Color(0.2, 1.0, 0.5), false, 4.0)
		
		var label = "프라이빗 1인실 #%d" % (i + 1) if is_booth else "오픈 카페석 #%d" % (i + 1)
		draw_string(ThemeDB.fallback_font, seat_pos + Vector2(10, 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.8, 0.75))
		
		# Draw Desk Drag Handle & Rotation Controls in Decorating Mode
		if GameState.is_decorating_mode:
			var tag_rect = Rect2(seat_pos.x + cell_w - 110, seat_pos.y + 6, 104, 22)
			draw_rect(tag_rect, Color(0.2, 0.8, 0.4, 0.9) if i == selected_drag_seat else Color(0.1, 0.6, 0.9, 0.85), true)
			var tag_text = "🧩 스냅 잡음!" if i == selected_drag_seat else "↔️ 40px 스냅"
			draw_string(ThemeDB.fallback_font, tag_rect.position + Vector2(6, 15), tag_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

		# Detect adjacent connected desks & draw island connection bridge
		for other_idx in range(i + 1, total_capacity):
			if GameState.are_seats_adjacent(i, other_idx):
				var other_pos = GameState.get_seat_position(other_idx) - Vector2(cell_w*0.5, cell_h*0.5)
				var mid_pos = (seat_pos + other_pos) * 0.5 + Vector2(cell_w*0.5, cell_h*0.5)
				draw_line(seat_pos + Vector2(cell_w*0.5, cell_h*0.5), other_pos + Vector2(cell_w*0.5, cell_h*0.5), Color(0.2, 0.9, 0.5, 0.85), 3.0)
				draw_rect(Rect2(mid_pos.x - 55, mid_pos.y - 12, 110, 24), Color(0.1, 0.12, 0.1, 0.9), true)
				draw_rect(Rect2(mid_pos.x - 55, mid_pos.y - 12, 110, 24), Color(0.2, 0.9, 0.5), false, 1.5)
				draw_string(ThemeDB.fallback_font, Vector2(mid_pos.x - 50, mid_pos.y + 4), "🔗 2인 몰입 섬", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.9, 0.5))
		
		# Draw Custom Partition / Curtain Overlays
		if GameState.seat_partitions.has(i):
			var p_type = GameState.seat_partitions[i]
			if p_type == "curtain":
				draw_rect(Rect2(seat_pos.x, seat_pos.y, cell_w, 18), Color(0.8, 0.2, 0.3, 0.85), true)
				draw_string(ThemeDB.fallback_font, seat_pos + Vector2(25, 14), "🎪 방음 커튼 설치됨", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
			else:
				draw_rect(Rect2(seat_pos.x, seat_pos.y, 8, cell_h), Color(0.8, 0.4, 0.9, 0.85), true)
				draw_string(ThemeDB.fallback_font, seat_pos + Vector2(14, 14), "🔮 몰입 칸막이", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		
		# 3D Volumetric Desk Lamp Cone & Halos
		var lamp_is_on = GameState.lamp_states.get(i, true)
		var lamp_pos = seat_pos + Vector2(cell_w - 22, 22)
		if lamp_is_on:
			var lamp_alpha = 0.75 if GameState.time_of_day == "NIGHT" else (0.45 if GameState.time_of_day == "DUSK" else 0.25)
			
			# Volumetric 3D Light Cone Projection
			var cone_poly = PackedVector2Array([
				lamp_pos,
				Vector2(seat_pos.x + 20, seat_pos.y + cell_h - 10),
				Vector2(seat_pos.x + cell_w - 10, seat_pos.y + cell_h - 10)
			])
			draw_polygon(cone_poly, PackedColorArray([Color(1.0, 0.85, 0.4, lamp_alpha * 0.18)]))

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
		var raw_pos = c["pos"]
		var draw_pos = raw_pos + view_offset
		var c_type = c["type"]
		
		# Render high-res 2D PNG Character Sprites
		var char_tex = student_texture
		if c_type == "developer":
			char_tex = developer_texture if developer_texture else student_texture
			
		if char_tex != null:
			var sprite_size = Vector2(48, 48)
			var sprite_rect = Rect2(draw_pos - Vector2(24, 44), sprite_size)
			draw_texture_rect(char_tex, sprite_rect, false)
		else:
			# Fallback vector character drawing
			var body_rect = Rect2(draw_pos.x - 14, draw_pos.y - 30, 28, 30)
			draw_rect(body_rect, c["color"], true)
			draw_circle(draw_pos + Vector2(0, -36), 12.0, Color(0.95, 0.82, 0.7))
		
		# Draw Customer Emoji Header
		draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-8, -48), c["icon"], HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)
		
		if c["state"] == "WALKING_IN":
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-25, -65), "🚶 입실 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.9, 0.4))
		elif c["state"] == "LEAVING":
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-25, -65), "👋 퇴실 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.6, 0.4))
		elif c["state"] == "STUDYING":
			var p_ratio = c["study_time"] / c["duration"]
			var bar_rect = Rect2(draw_pos.x - 40, draw_pos.y + 24, 80, 5)
			draw_rect(bar_rect, Color(0.1, 0.1, 0.1), true)
			draw_rect(Rect2(bar_rect.position.x, bar_rect.position.y, bar_rect.size.x * p_ratio, 5), Color(0.1, 0.8, 0.4), true)
			
			var cid = c["id"]
			if GameState.active_orders.has(cid):
				var order = GameState.active_orders[cid]
				var bubble_rect = Rect2(draw_pos.x - 60, draw_pos.y - 45, 120, 24)
				draw_rect(bubble_rect, Color(1.0, 0.95, 0.8), true)
				draw_rect(bubble_rect, Color(0.9, 0.5, 0.1), false, 2.0)
				draw_string(ThemeDB.fallback_font, bubble_rect.position + Vector2(6, 16), "👉 " + order["type"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.1, 0.0))
				
			if GameState.active_villains.has(cid):
				var v = GameState.active_villains[cid]
				var v_msg = "📢 시끄러움!"
				if v["type"] == "phone": v_msg = "📱 큰소리 통화!"
				elif v["type"] == "snack": v_msg = "🍿 과자 부스럭!"
				elif v["type"] == "snore": v_msg = "😴 코골이 중!"
				var v_rect = Rect2(draw_pos.x - 60, draw_pos.y - 45, 120, 24)
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
	draw_rect(Rect2(20, 20, 320, 36), Color(0.1, 0.08, 0.07, 0.85), true)
	draw_rect(Rect2(20, 20, 320, 36), Color(0.1, 0.8, 0.4), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(35, 43), "☕ 프리미엄 휴게실 & 스낵바 (Lounge Zone)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.1, 0.8, 0.4))
	
	var bar_rect = Rect2(40, 80, 300, 220)
	if coffee_bar_texture != null:
		draw_texture_rect(coffee_bar_texture, bar_rect, false)
		draw_rect(bar_rect, Color(0.96, 0.62, 0.07), false, 3.0)
	else:
		draw_rect(bar_rect, Color(0.24, 0.20, 0.17), true)
		draw_rect(bar_rect, Color(0.96, 0.62, 0.07), false, 3.0)
		
	# Draw Purchased Amenity Grid Modules in Lounge Zone
	var amenity_items = [
		{"key": "snack_bar", "title": "🍿 프리미엄 셀프 스낵바", "icon": "🍪"},
		{"key": "barista_coffee", "title": "☕ 바리스타 로스팅 음료", "icon": "☕"},
		{"key": "handdrip_coffee", "title": "☕ 싱글오리진 핸드드립 바", "icon": "🏺"},
		{"key": "morning_croissant", "title": "🥐 갓 구운 크로와상 브런치", "icon": "🥐"},
		{"key": "protein_smoothie", "title": "🥤 생과일 프로틴 스무디", "icon": "🥤"},
		{"key": "truffle_buffet", "title": "🍫 벨기에 트러플 초콜릿", "icon": "🍫"},
		{"key": "ice_dispenser", "title": "🍧 대용량 제빙기 에이드", "icon": "🧊"},
		{"key": "herbal_tea", "title": "🍵 유기농 캐모마일 허브티", "icon": "🍵"},
		{"key": "gourmet_dessert", "title": "🍰 갓 구운 크로플 & 디저트", "icon": "🍰"},
		{"key": "dark_chocolate", "title": "🍫 85% 무설탕 다크 초콜릿", "icon": "🍫"},
		{"key": "massage_chair", "title": "🧘 무중력 안마의자 휴식존", "icon": "🛋"},
		{"key": "nap_capsule", "title": "🧘 무중력 파워 냅 수면 캡슐", "icon": "😴"},
		{"key": "recliner_pod", "title": "🛋 1인 리클라이너 소파 포드", "icon": "🛋"},
		{"key": "pixel_arcade", "title": "🎮 레트로 픽셀 미니 게임기", "icon": "🎮"},
		{"key": "cat_tower", "title": "🐱 냥이 매니저 원목 캣타워", "icon": "🐈"}
	]
	
	var grid_x = 360.0
	var grid_y = 80.0
	var module_w = 210.0
	var module_h = 42.0
	var col_count = 2
	
	for idx in range(amenity_items.size()):
		var item = amenity_items[idx]
		var key = item["key"]
		var is_unlocked = GameState.upgrades.has(key) and GameState.upgrades[key]["level"] > 0
		
		var c = idx % col_count
		var r = idx / col_count
		var item_pos = Vector2(grid_x + c * (module_w + 15), grid_y + r * (module_h + 10))
		var item_rect = Rect2(item_pos.x, item_pos.y, module_w, module_h)
		
		if is_unlocked:
			draw_rect(item_rect, Color(0.12, 0.22, 0.18, 0.95), true)
			draw_rect(item_rect, Color(0.1, 0.8, 0.4), false, 2.0)
			draw_string(ThemeDB.fallback_font, item_pos + Vector2(10, 26), item["icon"] + " " + item["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.96, 0.62, 0.07))
		else:
			draw_rect(item_rect, Color(0.12, 0.12, 0.12, 0.6), true)
			draw_rect(item_rect, Color(0.3, 0.3, 0.3), false, 1.0)
			draw_string(ThemeDB.fallback_font, item_pos + Vector2(10, 26), "🔒 미해금: " + item["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.5, 0.5, 0.5))

func draw_front_zone(w: float, h: float) -> void:
	draw_rect(Rect2(20, 20, 320, 36), Color(0.1, 0.08, 0.07, 0.85), true)
	draw_rect(Rect2(20, 20, 320, 36), Color(0.8, 0.4, 0.9), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(35, 43), "🔑 무인 스마트 키오스크 & 입출구 (Front Zone)", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.8, 0.4, 0.9))
	
	var front_modules = [
		{"key": "smart_kiosk", "title": "📱 원격 스마트 키오스크 앱", "icon": "📱"},
		{"key": "parent_sms", "title": "🤖 AI 안심 입출석 알림톡", "icon": "💬"},
		{"key": "smart_lockers", "title": "🎒 비밀번호 스마트 사물함", "icon": "🔑"},
		{"key": "cloud_print", "title": "🖨 무인 클라우드 스캔/프린트", "icon": "🖨"},
		{"key": "rental_station", "title": "🎧 귀마개 & 무소음 비품 대여", "icon": "🎧"},
		{"key": "anc_headphones", "title": "🎧 ANC 노이즈캔슬링 헤드폰", "icon": "🎧"},
		{"key": "fast_charger", "title": "⚡ 100W 초고속 충전 도크", "icon": "⚡"},
		{"key": "phone_booth", "title": "🎙 완전 방음 1인 폰부스", "icon": "📞"},
		{"key": "exam_library", "title": "📚 평가원 모평 기출 족보", "icon": "📚"},
		{"key": "mock_exam_report", "title": "📜 모의고사 성적 진단 부스", "icon": "📜"},
		{"key": "book_share", "title": "📚 합격자 중고 수험서 나눔", "icon": "📖"},
		{"key": "robot_patrol", "title": "🤖 AI 바닥 청소 자율 로봇", "icon": "🧹"},
		{"key": "uv_desk_mat", "title": "🧼 UV-C 무균 살균 소독 매트", "icon": "🧼"},
		{"key": "sns_challenge", "title": "📱 열공 SNS 타임스탬프 포토존", "icon": "📸"},
		{"key": "study_badge_app", "title": "📱 열공 목표 달성 뱃지 앱", "icon": "🏆"}
	]
	
	var grid_x = 40.0
	var grid_y = 80.0
	var module_w = 230.0
	var module_h = 44.0
	var col_count = 3
	
	for idx in range(front_modules.size()):
		var item = front_modules[idx]
		var key = item["key"]
		var is_unlocked = GameState.upgrades.has(key) and GameState.upgrades[key]["level"] > 0
		
		var c = idx % col_count
		var r = idx / col_count
		var item_pos = Vector2(grid_x + c * (module_w + 15), grid_y + r * (module_h + 10))
		var item_rect = Rect2(item_pos.x, item_pos.y, module_w, module_h)
		
		if is_unlocked:
			draw_rect(item_rect, Color(0.18, 0.14, 0.22, 0.95), true)
			draw_rect(item_rect, Color(0.8, 0.4, 0.9), false, 2.0)
			draw_string(ThemeDB.fallback_font, item_pos + Vector2(10, 27), item["icon"] + " " + item["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.4, 0.9))
		else:
			draw_rect(item_rect, Color(0.12, 0.12, 0.12, 0.6), true)
			draw_rect(item_rect, Color(0.3, 0.3, 0.3), false, 1.0)
			draw_string(ThemeDB.fallback_font, item_pos + Vector2(10, 27), "🔒 미해금: " + item["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.5, 0.5, 0.5))

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
