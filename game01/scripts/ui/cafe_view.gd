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
var desk_vip_texture: Texture2D
var desk_island_texture: Texture2D
var staff_barista_texture: Texture2D = null
var staff_cleaner_texture: Texture2D = null
var staff_cat_navi_texture: Texture2D = null
var action_laptop_texture: Texture2D = null
var action_book_texture: Texture2D = null

func load_tex_safe(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(global_p)
		if img != null:
			return ImageTexture.create_from_image(img)
	return null

func _ready() -> void:
	custom_minimum_size = Vector2(800, 520)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	bg_texture = load_tex_safe("res://assets/cafe_bg.png")
	coffee_bar_texture = load_tex_safe("res://assets/coffee_bar.png")
	student_texture = load_tex_safe("res://assets/customer_student.png")
	developer_texture = load_tex_safe("res://assets/customer_developer.png")
	desk_booth_texture = load_tex_safe("res://assets/desk_booth_1p.png")
	desk_open_texture = load_tex_safe("res://assets/desk_open_cafe.png")
	desk_vip_texture = load_tex_safe("res://assets/desk_vip_ultrawide.png")
	desk_island_texture = load_tex_safe("res://assets/desk_island_2p.png")
	staff_barista_texture = load_tex_safe("res://assets/staff_barista.png")
	staff_cleaner_texture = load_tex_safe("res://assets/staff_cleaner.png")
	staff_cat_navi_texture = load_tex_safe("res://assets/staff_cat_navi.png")
	action_laptop_texture = load_tex_safe("res://assets/action_laptop.png")
	action_book_texture = load_tex_safe("res://assets/action_book.png")
		
	GameState.zone_changed.connect(func(_z): queue_redraw())
	GameState.floor_changed.connect(func(_f): queue_redraw())
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
	if GameState != null and GameState.has_method("update_navi_wandering"):
		GameState.update_navi_wandering(delta)
	
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
			# 0. Check Clean Top Right Control Buttons Click
			var screen_click = event.position
			var btn_x = max(get_rect().size.x - 170.0, 750.0)
			var h_btn_rect = Rect2(btn_x, 12, 160, 36)
			if h_btn_rect.has_point(screen_click):
				GameState.toggle_heatmap_mode()
				queue_redraw()
				return
				
			var tech_btn_x = btn_x - 220.0
			var tech_btn_rect = Rect2(tech_btn_x, 12, 210, 36)
			if tech_btn_rect.has_point(screen_click):
				GameState.tech_systems_requested.emit()
				queue_redraw()
				return

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
				
			# Click Mascot Cat 'Navi' for Petting & Healing Buff
			if GameState.current_floor == 1 and click_pos.distance_to(GameState.navi_pos) < 50.0:
				var res = GameState.pet_navi()
				floating_texts.append({
					"text": res["text"],
					"pos": GameState.navi_pos + Vector2(0, -35),
					"alpha": 1.0,
					"color": res["color"]
				})
				queue_redraw()
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
	if GameState == null: return
	var rect = get_rect()
	var w = max(rect.size.x, 1280.0)
	var h = max(rect.size.y, 600.0)
	
	# 1. Render Clean 2.5D Vector Interior Architectural Wallpaper (No photographic image clash!)
	# Base Warm Scandinavian Wood Panel Wall
	draw_rect(Rect2(0, 0, w, h), Color(0.15, 0.12, 0.10), true)
	
	# Vertical Wood Slat Wall Paneling
	var slat_w = 40.0
	for sx in range(int(w / slat_w) + 2):
		var x_pos = sx * slat_w
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, 220 + view_offset.y), Color(0.10, 0.08, 0.06, 0.4), 1.2)
		draw_line(Vector2(x_pos + 1, 0), Vector2(x_pos + 1, 220 + view_offset.y), Color(0.24, 0.18, 0.14, 0.2), 1.0)
		
	# Indirect LED Ceiling Lighting Cove Line
	draw_rect(Rect2(0, 0, w, 18), Color(0.12, 0.09, 0.07), true)
	draw_line(Vector2(0, 18), Vector2(w, 18), Color(0.96, 0.62, 0.07, 0.85), 2.5) # Warm Amber LED Strip
	draw_rect(Rect2(0, 18, w, 24), Color(0.96, 0.62, 0.07, 0.08), true) # Ceiling Glow Halo
	
	# Horizontal Wall Skirting / Dado Rail Molding Line
	var dado_y = 218.0 + view_offset.y
	draw_line(Vector2(0, dado_y), Vector2(w, dado_y), Color(0.35, 0.25, 0.18, 0.9), 4.0)
		
	# 2. Window-Only Day/Dusk/Night Sky Tint (Outdoor window view changes, indoor stays constant!)
	var window_rect = Rect2(484 + view_offset.x, 60 + view_offset.y, 310, 240)
	if GameState.time_of_day == "DUSK":
		draw_rect(window_rect, Color(1.0, 0.45, 0.12, 0.32)) # Sunset Dusk Sky
	elif GameState.time_of_day == "NIGHT":
		draw_rect(window_rect, Color(0.04, 0.06, 0.28, 0.48)) # Starry Night Sky
	else:
		draw_rect(window_rect, Color(0.2, 0.6, 1.0, 0.12))  # Sunny Day Sky

	# 3. 2.5D Warm Wooden Hardwood Floor Overlay (마루 바닥 질감)
	var floor_rect = Rect2(0, 220 + view_offset.y, w, h)
	draw_rect(floor_rect, Color(0.22, 0.15, 0.10, 0.38)) # Base Oak Wood Fill
	
	# Draw Isometric Wood Plank Grain Lines
	var plank_h = 32.0
	for py in range(int((h - 220) / plank_h) + 2):
		var y_pos = 220 + py * plank_h + view_offset.y
		draw_line(Vector2(0, y_pos), Vector2(w, y_pos), Color(0.12, 0.08, 0.05, 0.4), 1.5)
		draw_line(Vector2(0, y_pos + 1), Vector2(w, y_pos + 1), Color(0.38, 0.26, 0.18, 0.2), 1.0)
		
		# Offset Vertical Plank Joint Seams for staggered hardwood parquet floor
		var x_offset = fmod(py * 75.0, 150.0)
		for px in range(int(w / 150.0) + 2):
			var x_pos = px * 150.0 + x_offset
			draw_line(Vector2(x_pos, y_pos), Vector2(x_pos, y_pos + plank_h), Color(0.10, 0.06, 0.04, 0.35), 1.2)

	# 3. Draw 2.5D Isometric Diamond Grid Overlay & Banner in Decorating Mode
	if GameState.is_decorating_mode:
		var iso_w = 64.0
		var iso_h = 32.0
		for i in range(-15, int(w / iso_w) + 15):
			var p1 = Vector2(i * iso_w, 0)
			var p2 = p1 + Vector2(h * 2.0, h)
			draw_line(p1, p2, Color(0.96, 0.62, 0.07, 0.22), 1.0)
			
			var p3 = Vector2(i * iso_w, 0)
			var p4 = p3 + Vector2(-h * 2.0, h)
			draw_line(p3, p4, Color(0.96, 0.62, 0.07, 0.22), 1.0)
			
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
	# 5. Draw Multi-Room Integrated Architectural Layout
	draw_integrated_multi_room_layout(w, h)
		
	# 6. Draw Floating Action Texts
	for ft in floating_texts:
		var c = ft["color"]
		c.a = ft["alpha"]
		draw_string(ThemeDB.fallback_font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 15, c)

func draw_integrated_multi_room_layout(w: float, h: float) -> void:
	var vo = view_offset
	# ----------------------------------------------------
	# ROOM 1: 📖 메인 집중 열공 방 (Main Focus Study Room)
	# ----------------------------------------------------
	var room1_rect = Rect2(30 + vo.x, 20 + vo.y, 680, h - 40)
	draw_rect(room1_rect, Color(0.12, 0.10, 0.08, 0.45), true)
	
	# Room 1 Header Banner
	var r1_banner = Rect2(40 + vo.x, 30 + vo.y, 260, 32)
	draw_rect(r1_banner, Color(0.18, 0.14, 0.10, 0.95), true)
	draw_string(ThemeDB.fallback_font, Vector2(52 + vo.x, 52 + vo.y), "📖 메인 집중 열공 방 (Focus Room)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.96, 0.62, 0.07))

	# Render 2.5D Atmospheric Weather Banner & Ambient Window Lighting
	var weather_info = GameState.get_weather_info()
	var w_banner = Rect2(320 + vo.x, 30 + vo.y, 380, 32)
	draw_rect(w_banner, Color(0.10, 0.12, 0.18, 0.95), true)
	draw_rect(w_banner, weather_info["ambient_color"], false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(330 + vo.x, 52 + vo.y), "%s (+%d%% 매출/몰입)" % [weather_info["weather_name"], int(weather_info["coffee_craving_bonus"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, weather_info["ambient_color"])

	# ----------------------------------------------------
	# ROOM 2: ☕ 카페테리아 & 힐링 라운지 방 (Lounge & Coffee Bar)
	# ----------------------------------------------------
	var room2_rect = Rect2(730 + vo.x, 20 + vo.y, w - 750, 240)
	draw_rect(room2_rect, Color(0.10, 0.14, 0.12, 0.45), true)
	
	# Room 2 Header Banner
	var r2_banner = Rect2(740 + vo.x, 30 + vo.y, 250, 32)
	draw_rect(r2_banner, Color(0.12, 0.20, 0.15, 0.95), true)
	draw_string(ThemeDB.fallback_font, Vector2(752 + vo.x, 52 + vo.y), "☕ 힐링 라운지 & 커피바 (Lounge)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.1, 0.8, 0.4))
	
	# Render Coffee Bar Counter inside Room 2
	var r2_bar = Rect2(750 + vo.x, 75 + vo.y, 230, 100)
	if coffee_bar_texture != null:
		draw_texture_rect(coffee_bar_texture, r2_bar, false)
	else:
		draw_rect(r2_bar, Color(0.24, 0.18, 0.14), true)
	draw_string(ThemeDB.fallback_font, Vector2(765 + vo.x, 125 + vo.y), "☕ 에스프레소 & 로스팅 바", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

	# Render Cake & Bakery Dessert Showcase Counter in Room 2 Lounge
	var cake_bar = Rect2(750 + vo.x, 165 + vo.y, 230, 32)
	draw_rect(cake_bar, Color(0.22, 0.16, 0.14, 0.95), true)
	var c_cnt = GameState.bakery_stock.get("cheesecake", 0)
	var r_cnt = GameState.bakery_stock.get("croissant", 0)
	var showcase_text = "🍰 치즈케이크 x%d  |  🥐 크로와상 x%d" % [c_cnt, r_cnt]
	draw_string(ThemeDB.fallback_font, Vector2(760 + vo.x, 186 + vo.y), showcase_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.85, 0.9))

	# Render 2 Round Mahogany Cake Tasting Tables in Room 2 Lounge
	var t1_center = Vector2(790, 215) + vo
	draw_circle(t1_center, 16.0, Color(0.28, 0.20, 0.16, 0.95))
	draw_circle(t1_center, 14.0, Color(0.42, 0.30, 0.22))
	draw_string(ThemeDB.fallback_font, t1_center + Vector2(-9, 5), "🍰☕", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	draw_string(ThemeDB.fallback_font, t1_center + Vector2(-26, 4), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	draw_string(ThemeDB.fallback_font, t1_center + Vector2(14, 4), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	
	var t2_center = Vector2(930, 215) + vo
	draw_circle(t2_center, 16.0, Color(0.28, 0.20, 0.16, 0.95))
	draw_circle(t2_center, 14.0, Color(0.42, 0.30, 0.22))
	draw_string(ThemeDB.fallback_font, t2_center + Vector2(-9, 5), "🥐☕", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	draw_string(ThemeDB.fallback_font, t2_center + Vector2(-26, 4), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
	draw_string(ThemeDB.fallback_font, t2_center + Vector2(14, 4), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

	# Render Human Barista Staff Sprite in Room 2 Lounge
	if staff_barista_texture != null:
		draw_texture_rect(staff_barista_texture, Rect2(840 + vo.x, 45 + vo.y, 52, 52), false)
		draw_string(ThemeDB.fallback_font, Vector2(825 + vo.x, 42 + vo.y), "☕ 바리스타 민서", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.1, 0.8, 0.4))

	# ----------------------------------------------------
	# ROOM 3: 🔑 프런트 & 스마트 사물함 방 (Front & Lockers)
	# ----------------------------------------------------
	var room3_rect = Rect2(730 + vo.x, 275 + vo.y, w - 750, h - 295)
	draw_rect(room3_rect, Color(0.14, 0.12, 0.16, 0.45), true)
	
	# Room 3 Header Banner
	var r3_banner = Rect2(740 + vo.x, 285 + vo.y, 250, 32)
	draw_rect(r3_banner, Color(0.18, 0.15, 0.22, 0.95), true)
	draw_string(ThemeDB.fallback_font, Vector2(752 + vo.x, 307 + vo.y), "🔑 프런트 & 스마트 사물함 (Front)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.4, 0.9))

	# Smart Lockers Wall Graphics in Room 3
	var locker_rect = Rect2(750 + vo.x, 330 + vo.y, 230, 100)
	draw_rect(locker_rect, Color(0.2, 0.18, 0.25), true)
	for lx in range(4):
		for ly in range(2):
			var box = Rect2(760 + lx * 52 + vo.x, 340 + ly * 42 + vo.y, 44, 34)
			draw_rect(box, Color(0.28, 0.25, 0.35), true)
			draw_string(ThemeDB.fallback_font, box.position + Vector2(10, 22), "🔒%d" % (lx + ly*4 + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.8, 0.9))

	# ----------------------------------------------------
	# Glass Door Archways Connecting Rooms
	# ----------------------------------------------------
	draw_rect(Rect2(710 + vo.x, 110 + vo.y, 20, 60), Color(0.2, 0.8, 1.0, 0.8), true)
	draw_string(ThemeDB.fallback_font, Vector2(712 + vo.x, 145 + vo.y), "🚪", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	draw_rect(Rect2(710 + vo.x, 360 + vo.y, 20, 60), Color(0.2, 0.8, 1.0, 0.8), true)
	draw_string(ThemeDB.fallback_font, Vector2(712 + vo.x, 395 + vo.y), "🚪", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# ----------------------------------------------------
	# Draw Desks & Booths inside ROOM 1 (Main Focus Study Room)
	# ----------------------------------------------------
	
	var gate_rect = Rect2(w - 140 + vo.x, 20 + vo.y, 120, 70)
	draw_rect(gate_rect, Color(0.16, 0.13, 0.11, 0.9), true)
	draw_rect(gate_rect, Color(0.06, 0.72, 0.5), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(w - 130 + vo.x, 55 + vo.y), "🚪 입출구 게이트", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.06, 0.72, 0.5))
	
	var total_capacity = GameState.get_max_capacity()
	var cols = 4
	var start_x = 60.0
	var start_y = 160.0
	
	# Draw 2.5D Magnetic Placement Grid Overlay when dragging a seat
	if is_dragging and selected_drag_seat != -1:
		var grid_tile_w = 110.0
		var grid_tile_h = 75.0
		for gc in range(5):
			for gr in range(4):
				var g_rect = Rect2(start_x + gc * grid_tile_w + vo.x, start_y + gr * grid_tile_h + vo.y, grid_tile_w - 5, grid_tile_h - 5)
				draw_rect(g_rect, Color(0.2, 0.8, 1.0, 0.12), true)
				draw_rect(g_rect, Color(0.2, 0.8, 1.0, 0.45), false, 1.0)

	# Collect seat indices and sort by Y-position for proper 2.5D depth ordering (Front items rendered ON TOP of Back items)
	var seat_indices = []
	for idx in range(total_capacity):
		seat_indices.append(idx)
		
	seat_indices.sort_custom(func(a, b):
		var pos_a = GameState.get_seat_position(a)
		var pos_b = GameState.get_seat_position(b)
		return pos_a.y < pos_b.y
	)
	
	for i in seat_indices:
		var col = i % cols
		var row = i / cols
		var is_booth = i >= GameState.upgrades["open_seats"]["level"] * 3
		var cell_w = 220.0 if is_booth else 140.0
		var cell_h = 150.0 if is_booth else 90.0
		
		# EVERY SEAT MOVES UNIFIED WITH VIEW_OFFSET!
		var seat_pos = Vector2(start_x + col * (160.0 + 30.0), start_y + row * (100.0 + 30.0)) + vo
		if GameState.seat_custom_offsets.has(i):
			seat_pos += GameState.seat_custom_offsets[i]
		
		var desk_color = Color(0.18, 0.14, 0.12, 0.85) if not is_booth else Color(0.15, 0.12, 0.18, 0.85)
		var border_color = Color(0.96, 0.62, 0.07) if not is_booth else Color(0.8, 0.4, 0.9)
		
		var desk_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		# 2.5D Isometric Diamond Floor Base Pad
		var iso_pad = PackedVector2Array([
			seat_pos + Vector2(cell_w * 0.5, cell_h + 4),
			seat_pos + Vector2(cell_w + 18, cell_h + 16),
			seat_pos + Vector2(cell_w * 0.5, cell_h + 28),
			seat_pos + Vector2(-18, cell_h + 16)
		])
		draw_polygon(iso_pad, PackedColorArray([Color(0.04, 0.03, 0.02, 0.45)]))
		var iso_pad_loop = iso_pad.duplicate()
		iso_pad_loop.append(iso_pad[0])
		draw_polyline(iso_pad_loop, Color(0.96, 0.62, 0.07, 0.35), 1.5)

		# 1. ALWAYS Render the desk PNG texture OR 2.5D Isometric Vector Fallback (No desk ever disappears!)
		var drawn_tex = false
		if is_booth and desk_booth_texture != null:
			draw_texture_rect(desk_booth_texture, desk_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true
		elif not is_booth and desk_vip_texture != null and i % 2 == 1:
			draw_texture_rect(desk_vip_texture, desk_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true
		elif not is_booth and desk_open_texture != null:
			draw_texture_rect(desk_open_texture, desk_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true
			
		if not drawn_tex:
			# ALWAYS Draw High-Quality 2.5D Wood Desk Vector Structure
			draw_rect(desk_rect, Color(0.32, 0.22, 0.16, 0.95), true)
			draw_rect(desk_rect, border_color, false, 2.5)
			# Inner Desk Mat & LED Lamp Pad
			var mat_rect = Rect2(desk_rect.position.x + 10, desk_rect.position.y + 10, cell_w - 20, cell_h - 20)
			draw_rect(mat_rect, Color(0.18, 0.14, 0.12, 0.9), true)
			draw_rect(mat_rect, Color(0.4, 0.3, 0.2), false, 1.0)
			# Desk Partition Barrier
			var part_rect = Rect2(desk_rect.position.x, desk_rect.position.y, cell_w, 14)
			draw_rect(part_rect, Color(0.24, 0.18, 0.14), true)
			draw_rect(part_rect, border_color, false, 1.0)
			# Laptop / Study Icon
			var study_icon = "💻" if not is_booth else "🖥️"
			draw_string(ThemeDB.fallback_font, desk_rect.position + Vector2(cell_w * 0.4, cell_h * 0.58), study_icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
			# Ergonomic Chair
			var chair_rect = Rect2(desk_rect.position.x + cell_w * 0.3, desk_rect.position.y + cell_h + 2, cell_w * 0.4, 16)
			draw_rect(chair_rect, Color(0.15, 0.12, 0.18, 0.95), true)
			draw_rect(chair_rect, border_color, false, 1.5)
			draw_string(ThemeDB.fallback_font, chair_rect.position + Vector2(cell_w * 0.1, 12), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

		# 2. When adjacent desks physically touch, draw a subtle wooden joint panel between them
		for other_idx in range(i + 1, total_capacity):
			if GameState.are_seats_adjacent(i, other_idx):
				var other_pos = GameState.get_seat_position(other_idx)
				var p1 = seat_pos + Vector2(cell_w * 0.5, cell_h * 0.5)
				var p2 = other_pos + Vector2(cell_w * 0.5, cell_h * 0.5)
				if p1.distance_to(p2) < 220.0:
					var mid_pos = (p1 + p2) * 0.5
					draw_line(p1, p2, Color(0.28, 0.20, 0.14, 0.6), 8.0)

		if i == selected_drag_seat:
			draw_rect(desk_rect, Color(0.2, 0.9, 0.5, 0.35), true)
			draw_rect(desk_rect, Color(0.2, 1.0, 0.5), false, 3.0)
		
		var label = "프라이빗 1인실 #%d" % (i + 1) if is_booth else "오픈 카페석 #%d" % (i + 1)
		draw_string(ThemeDB.fallback_font, seat_pos + Vector2(10, 22), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.8, 0.8, 0.75))
		
		# Draw Desk Drag Handle & Rotation Controls in Decorating Mode
		if GameState.is_decorating_mode:
			var tag_rect = Rect2(seat_pos.x + cell_w - 110, seat_pos.y + 6, 104, 22)
			draw_rect(tag_rect, Color(0.2, 0.8, 0.4, 0.9) if i == selected_drag_seat else Color(0.1, 0.6, 0.9, 0.85), true)
			var tag_text = "🧩 스냅 잡음!" if i == selected_drag_seat else "↔️ 40px 스냅"
			draw_string(ThemeDB.fallback_font, tag_rect.position + Vector2(6, 15), tag_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
		
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
		
		# 4. 2.5D Isometric Real-Time Heatmap & Acoustic Focus Overlay
		if GameState.is_heatmap_mode:
			var f_score = GameState.seat_focus_scores.get(i, 80.0)
			var n_level = GameState.seat_noise_levels.get(i, 40.0)
			var aura_color = Color(0.1, 0.95, 0.4, 0.42) # Emerald Green (Focus >= 80)
			if f_score < 50.0:
				aura_color = Color(0.95, 0.25, 0.15, 0.42) # Crimson Coral (Focus < 50)
			elif f_score < 80.0:
				aura_color = Color(0.95, 0.75, 0.1, 0.42) # Amber Gold (50 <= Focus < 80)
				
			var aura_radius = 54.0 + sin(steam_time * 4.0 + float(i)) * 5.0
			draw_circle(seat_pos + Vector2(cell_w * 0.5, cell_h * 0.5), aura_radius, aura_color)
			
			# Focus Badge Pill
			var badge_rect = Rect2(seat_pos.x + 6, seat_pos.y + cell_h - 26, cell_w - 12, 22)
			draw_rect(badge_rect, Color(0.06, 0.07, 0.09, 0.88), true)
			draw_rect(badge_rect, aura_color, false, 1.5)
			var badge_txt = "🎯 몰입도 %d%% | 🔉 %.1fdBA" % [int(f_score), n_level]
			draw_string(ThemeDB.fallback_font, badge_rect.position + Vector2(6, 15), badge_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		
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
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-25, -65), "🚶 라운지 이동", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.9, 0.4))
		elif c["state"] == "EATING_CAKE":
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-45, -65), "🍰 치즈케이크 얌얌! (+450₩)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.7, 0.8))
		elif c["state"] == "WALKING_TO_SEAT":
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-25, -65), "🚶 열공방 이동", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.9, 0.5))
		elif c["state"] == "LEAVING":
			draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-25, -65), "👋 퇴실 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.6, 0.4))
		elif c["state"] == "STUDYING":
			var p_ratio = c["study_time"] / c["duration"]
			var bar_rect = Rect2(draw_pos.x - 40, draw_pos.y + 24, 80, 5)
			draw_rect(bar_rect, Color(0.1, 0.1, 0.1), true)
			draw_rect(Rect2(bar_rect.position.x, bar_rect.position.y, bar_rect.size.x * p_ratio, 5), Color(0.1, 0.8, 0.4), true)
			
			# Render 2.5D Weather Dynamic Reaction Speech Bubbles above head
			var w_type = GameState.current_weather_type
			if w_type == "rainy":
				draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-35, -65), "🌧️ 빗소리 아늑하다 ☕", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.85, 1.0))
			elif w_type == "snowy":
				draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-35, -65), "❄️ 눈 오니 라떼 최고!", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.95, 1.0))
			elif w_type == "cloudy":
				draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-35, -65), "☁️ 아늑해서 몰입 최고 💻", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.9, 0.95))
			else:
				draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-35, -65), "☀️ 햇살 따스하다 📖", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.9, 0.5))
			
			# Render active study action item asset on student desk
			if c_type == "developer" and action_laptop_texture != null:
				draw_texture_rect(action_laptop_texture, Rect2(draw_pos.x + 12, draw_pos.y - 20, 28, 28), false)
			elif action_book_texture != null:
				draw_texture_rect(action_book_texture, Rect2(draw_pos.x + 12, draw_pos.y - 20, 28, 28), false)
			
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

	# Render Customer AI Pathfinding Dotted Trail & Behavior Inspector HUD Card
	if GameState.selected_customer_id != -1:
		var sel_c = GameState.get_customer_by_id(GameState.selected_customer_id)
		if not sel_c.is_empty():
			var ai_data = GameState.calculate_customer_ai_behavior(sel_c)
			var wps = ai_data["waypoints"]
			for w_idx in range(wps.size() - 1):
				var p1 = wps[w_idx] + view_offset
				var p2 = wps[w_idx + 1] + view_offset
				draw_line(p1, p2, Color(0.2, 0.95, 0.5, 0.85), 3.5)
				draw_circle(p1, 6.0, Color(0.2, 0.95, 0.5))
			
			# Render Customer AI Inspector Card (Bottom Left Panel)
			var card_rect = Rect2(20, h - 145, 330, 125)
			draw_rect(card_rect, Color(0.08, 0.09, 0.12, 0.94), true)
			draw_rect(card_rect, Color(0.2, 0.85, 0.5), false, 2.0)
			draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(12, 24), "🧠 손님 AI 비헤이비어 트레이서", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.2, 0.85, 0.5))
			draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(12, 46), "%s %s | 노드: %s" % [ai_data["icon"], ai_data["name"], ai_data["decision_node"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
			draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(12, 66), "⚡ 몰입도: %d%% | ☕ 선호: %s" % [int(ai_data["focus"]), ai_data["drink_pref"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.8, 0.2))
			
			# Stress bar
			var s_val = ai_data["stress"]
			draw_string(ThemeDB.fallback_font, card_rect.position + Vector2(12, 88), "🔥 스트레스 지수: %d%%" % int(s_val), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.4, 0.4) if s_val > 50 else Color(0.4, 0.9, 0.5))
			var s_bar = Rect2(card_rect.position.x + 12, card_rect.position.y + 96, 306, 12)
			draw_rect(s_bar, Color(0.2, 0.2, 0.2), true)
			var fill_color = Color(1.0, 0.3, 0.3) if s_val > 50 else Color(0.2, 0.85, 0.4)
			draw_rect(Rect2(s_bar.position.x, s_bar.position.y, s_bar.size.x * (s_val / 100.0), 12), fill_color, true)
				
	if GameState.upgrades["staff_cleaner"]["level"] > 0:
		var cur_floor = GameState.current_floor
		var mgr = GameState.floor_cleaner_managers.get(cur_floor, GameState.floor_cleaner_managers[1])
		var c_pos = mgr["pos"]
		var c_bounce = sin(steam_time * 12.0) * 4.0
		var c_render = c_pos + Vector2(0, c_bounce)
		
		if staff_cleaner_texture != null:
			draw_texture_rect(staff_cleaner_texture, Rect2(c_render - Vector2(28, 52), Vector2(56, 56)), false)
		else:
			draw_circle(c_render, 20.0, Color(0.96, 0.62, 0.07))
			draw_string(ThemeDB.fallback_font, c_render + Vector2(-10, 7), "🧹", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		draw_string(ThemeDB.fallback_font, c_render + Vector2(-45, -35), "🧹 " + mgr["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.96, 0.62, 0.07))

	# Render Mascot Cat 'Navi' wandering in Room 1 (1F Only)
	if GameState.current_floor == 1:
		var n_pos = GameState.navi_pos
		var n_bounce = abs(sin(steam_time * 8.0)) * 6.0
		var n_render = n_pos + Vector2(0, -n_bounce)
		
		if staff_cat_navi_texture != null:
			draw_texture_rect(staff_cat_navi_texture, Rect2(n_render - Vector2(24, 28), Vector2(52, 52)), false)
		else:
			var n_bg = Rect2(n_render.x - 22, n_render.y - 20, 44, 40)
			draw_rect(n_bg, Color(0.12, 0.1, 0.08, 0.85), true)
			draw_rect(n_bg, Color(1.0, 0.6, 0.8), false, 1.5)
			draw_string(ThemeDB.fallback_font, n_render + Vector2(-12, 8), "🐱", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
		var cat_label = "🐱 나비 (마스코트)" if not GameState.is_cat_buff_active() else "🐱 나비 (❤️ 집중+20%)"
		draw_string(ThemeDB.fallback_font, n_render + Vector2(-45, -32), cat_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.6, 0.8))

	# Render Clean Top Right Control Buttons
	var btn_x = max(w - 170.0, 750.0)
	var heatmap_btn_rect = Rect2(btn_x, 12, 160, 36)
	var btn_bg = Color(0.95, 0.4, 0.1, 0.95) if GameState.is_heatmap_mode else Color(0.15, 0.18, 0.22, 0.9)
	draw_rect(heatmap_btn_rect, btn_bg, true)
	draw_rect(heatmap_btn_rect, Color(1.0, 0.7, 0.2), false, 2.0)
	var btn_label = "🔥 히트맵 ON" if GameState.is_heatmap_mode else "🔥 히트맵 분석"
	draw_string(ThemeDB.fallback_font, heatmap_btn_rect.position + Vector2(24, 24), btn_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

	var tech_btn_x = btn_x - 220.0
	var tech_btn_rect = Rect2(tech_btn_x, 12, 210, 36)
	draw_rect(tech_btn_rect, Color(0.1, 0.7, 0.75, 0.95), true)
	draw_rect(tech_btn_rect, Color(0.2, 0.95, 0.85), false, 2.0)
	draw_string(ThemeDB.fallback_font, tech_btn_rect.position + Vector2(15, 24), "🔬 첨단기술 관제센터", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
	var hud_panel_x = max(w - 280.0, 500.0)
	var eq_btn_x = hud_panel_x
	var pg_btn_x = hud_panel_x
	var aq_btn_x = hud_panel_x
	var net_btn_x = hud_panel_x
	var ergo_btn_x = hud_panel_x
	var bio_btn_x = hud_panel_x
	var q_btn_x = hud_panel_x
	var b_btn_x = hud_panel_x
	var c_btn_x = hud_panel_x
	var pmv_btn_x = hud_panel_x
	var drn_btn_x = hud_panel_x
	var emo_btn_x = hud_panel_x
	var shd_btn_x = hud_panel_x
	var wtr_btn_x = hud_panel_x
	var nro_btn_x = hud_panel_x
	var voi_btn_x = hud_panel_x
	var hlo_btn_x = hud_panel_x
	var piz_btn_x = hud_panel_x
	var rbt_btn_x = hud_panel_x
	var sld_btn_x = hud_panel_x
	var sat_btn_x = hud_panel_x
	var fsn_btn_x = hud_panel_x
	var cur_btn_x = hud_panel_x
	var awg_btn_x = hud_panel_x
	var frm_btn_x = hud_panel_x
	var exo_btn_x = hud_panel_x
	var tp_btn_x = hud_panel_x
	var cry_btn_x = hud_panel_x
	var trs_btn_x = hud_panel_x
	var grv_btn_x = hud_panel_x
	var olf_btn_x = hud_panel_x
	var hrv_btn_x = hud_panel_x
	var tes_btn_x = hud_panel_x
	var tac_btn_x = hud_panel_x
	var tel_btn_x = hud_panel_x
	var ant_btn_x = hud_panel_x
	var sup_btn_x = hud_panel_x

	# Render Holographic Multi-Dimensional Super-Computer AI HUD Panel if ON
	if GameState.is_supercomputer_hud_open:
		var sup_info = GameState.calculate_holographic_supercomputer_metrics()
		var sup_panel_rect = Rect2(sup_btn_x - 40.0, 60, 240, 130)
		draw_rect(sup_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sup_panel_rect, Color(0.2, 0.95, 0.85), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sup_panel_rect.position + Vector2(10, 22), "💻 홀로그램 다차원 슈퍼컴퓨터 AI 연산", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.95, 0.85))
		draw_string(ThemeDB.fallback_font, sup_panel_rect.position + Vector2(10, 42), "💻 슈퍼컴 AI 연산 처리 속도: %.1f PFLOPS" % sup_info["speed_pflops"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sup_panel_rect.position + Vector2(10, 60), "🧠 다차원 신경망 수용 예측 정밀도: %.4f%%" % sup_info["accuracy_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.85))
		draw_string(ThemeDB.fallback_font, sup_panel_rect.position + Vector2(10, 78), "💻 슈퍼컴 AI 등급: %s" % sup_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sup_panel_rect.position + Vector2(10, 96), "💰 지능형 매장 자율 최적화 순이익: +%d%%" % int(sup_info["income_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Quantum Multiverse Dimensional Bifurcation Portal HUD Panel if ON
	if GameState.is_multiverse_hud_open:
		var multi_info = GameState.calculate_multiverse_bifurcation_metrics()
		var multi_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(multi_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(multi_panel_rect, Color(0.6, 0.3, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, multi_panel_rect.position + Vector2(10, 22), "🌌 하위 퀀텀 다중우주 차원분기 포탈", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, multi_panel_rect.position + Vector2(10, 42), "🌌 동시 가동 타임라인 가지: %.0f 개" % multi_info["branches"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, multi_panel_rect.position + Vector2(10, 60), "🧠 다중 위상 양자 정렬 안정성: %.4f%%" % multi_info["stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, multi_panel_rect.position + Vector2(10, 78), "🌌 포탈 상태: %s" % multi_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, multi_panel_rect.position + Vector2(10, 96), "💰 병렬 차원 학습 수확 매출 보너스: +%d%%" % int(multi_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Space Zero-Point Energy Capacitor HUD Panel if ON
	if GameState.is_zero_point_hud_open:
		var zp_info = GameState.calculate_zero_point_energy_metrics()
		var zp_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(zp_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(zp_panel_rect, Color(0.2, 0.9, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, zp_panel_rect.position + Vector2(10, 22), "⚡ 하위 공간 제로포인트 에너지 캡시터", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.9, 0.95))
		draw_string(ThemeDB.fallback_font, zp_panel_rect.position + Vector2(10, 42), "⚡ 진공 추출 에너지 밀도: %.1f GJ" % zp_info["density_gj"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, zp_panel_rect.position + Vector2(10, 60), "🔮 카시미르 진공 진동수: %.1f GHz" % zp_info["casimir_ghz"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.9, 0.95))
		draw_string(ThemeDB.fallback_font, zp_panel_rect.position + Vector2(10, 78), "⚡ 캡시터 상태: %s" % zp_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, zp_panel_rect.position + Vector2(10, 96), "💰 무한 진공 전력 유지비 절감 보너스: +%d%%" % int(zp_info["saving_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Hyper-Dimensional Chrono-Field Resonance Converter HUD Panel if ON
	if GameState.is_chrono_resonance_hud_open:
		var cr_info = GameState.calculate_chrono_resonance_metrics()
		var cr_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(cr_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(cr_panel_rect, Color(0.95, 0.8, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, cr_panel_rect.position + Vector2(10, 22), "⌛ 크로노 필드 양자 공명 변환기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, cr_panel_rect.position + Vector2(10, 42), "⌛ 크로노 공명 진동수: %.3f THz" % cr_info["freq_thz"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, cr_panel_rect.position + Vector2(10, 60), "🔮 시간-에너지 변환 효율: %.1f%%" % cr_info["yield_bonus"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, cr_panel_rect.position + Vector2(10, 78), "⌛ 변환기 상태: %s" % cr_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, cr_panel_rect.position + Vector2(10, 96), "💰 초시공간 학습 수확 보너스: +%d%%" % int(cr_info["yield_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum AI Neural-Synapse Cognitive Accelerator HUD Panel if ON
	if GameState.is_neural_cognitive_hud_open:
		var nc_info = GameState.calculate_neural_cognitive_metrics()
		var nc_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(nc_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(nc_panel_rect, Color(0.4, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, nc_panel_rect.position + Vector2(10, 22), "🧠 양자 AI 신경-시냅스 인지 가속기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, nc_panel_rect.position + Vector2(10, 42), "🧠 신경 시냅스 연산 밀도: %.1f TFLOPS" % nc_info["tflops"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, nc_panel_rect.position + Vector2(10, 60), "🔮 인지 집중 학습 가속율: %.4f%%" % nc_info["efficiency_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, nc_panel_rect.position + Vector2(10, 78), "🧠 인지 가속기 상태: %s" % nc_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, nc_panel_rect.position + Vector2(10, 96), "💰 시험 시즌 성적 수확 보너스: +%d%%" % int(nc_info["exam_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Rhythm Circadian Sleep-Cycle & Neuro-Rest Engine HUD Panel if ON
	if GameState.is_bio_rest_hud_open:
		var br_info = GameState.calculate_bio_rest_metrics()
		var br_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(br_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(br_panel_rect, Color(0.3, 0.95, 0.8), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, br_panel_rect.position + Vector2(10, 22), "💤 자율 서카디안 신경휴식 캡슐", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 0.8))
		draw_string(ThemeDB.fallback_font, br_panel_rect.position + Vector2(10, 42), "💤 멜라토닌 수면 동기화율: %.4f%%" % br_info["melatonin_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, br_panel_rect.position + Vector2(10, 60), "🔮 알파파 뇌파 유도 주파수: %.1f Hz" % br_info["alpha_hz"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.95, 0.8))
		draw_string(ThemeDB.fallback_font, br_panel_rect.position + Vector2(10, 78), "💤 신경휴식 캡슐 상태: %s" % br_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, br_panel_rect.position + Vector2(10, 96), "💰 피로회복 & 피크 집중력 회복: +%d%%" % int(br_info["stamina_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Holographic Spatial-Acoustic Active Resonance Damping Engine HUD Panel if ON
	if GameState.is_acoustic_damping_hud_open:
		var ad_info = GameState.calculate_acoustic_damping_metrics()
		var ad_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(ad_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ad_panel_rect, Color(0.9, 0.4, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ad_panel_rect.position + Vector2(10, 22), "🔇 홀로그램 공간-음향 능동 감쇠기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.4, 0.95))
		draw_string(ThemeDB.fallback_font, ad_panel_rect.position + Vector2(10, 42), "🔇 소음 위상 상쇄 레벨: %.1f dB" % ad_info["damping_db"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ad_panel_rect.position + Vector2(10, 60), "🔮 홀로그램 음장 위상 정렬: %.4f%%" % ad_info["coherence_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.4, 0.95))
		draw_string(ThemeDB.fallback_font, ad_panel_rect.position + Vector2(10, 78), "🔇 감쇠기 상태: %s" % ad_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ad_panel_rect.position + Vector2(10, 96), "💰 무소음 극대 몰입 학습 보너스: +%d%%" % int(ad_info["focus_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Robotic Molecular Nanite Sanitation Engine HUD Panel if ON
	if GameState.is_nanite_sanitation_hud_open:
		var ns_info = GameState.calculate_nanite_sanitation_metrics()
		var ns_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(ns_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ns_panel_rect, Color(0.2, 0.85, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ns_panel_rect.position + Vector2(10, 22), "🤖 분자 나노봇 자율 위생 소독 엔진", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.85, 0.95))
		draw_string(ThemeDB.fallback_font, ns_panel_rect.position + Vector2(10, 42), "🤖 가동 소독 나노봇 스웜 개체: %.0fM 개" % ns_info["count_m"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ns_panel_rect.position + Vector2(10, 60), "🔮 공기/표면 병원체 살균 순도: %.4f%%" % ns_info["sterilization_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.85, 0.95))
		draw_string(ThemeDB.fallback_font, ns_panel_rect.position + Vector2(10, 78), "🤖 나노봇 스웜 상태: %s" % ns_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ns_panel_rect.position + Vector2(10, 96), "💰 초청정 멸균 청결도 신뢰 보너스: +%d%%" % int(ns_info["cleanliness_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Quantum-Entangled Sub-Atmospheric Gravitational Field Stabilizer HUD Panel if ON
	if GameState.is_quantum_gravity_hud_open:
		var qg_info = GameState.calculate_quantum_gravity_metrics()
		var qg_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(qg_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(qg_panel_rect, Color(0.4, 0.6, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, qg_panel_rect.position + Vector2(10, 22), "🌌 양자 얽힘 대기권-하위 중력장 안정기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.6, 1.0))
		draw_string(ThemeDB.fallback_font, qg_panel_rect.position + Vector2(10, 42), "🌌 미세 중력장 궤도 안정율: %.4f%%" % qg_info["stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, qg_panel_rect.position + Vector2(10, 60), "🔮 중력자 입자 진동 플럭스: %.1f MHz" % qg_info["graviton_mhz"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.6, 1.0))
		draw_string(ThemeDB.fallback_font, qg_panel_rect.position + Vector2(10, 78), "🌌 중력장 안정기 상태: %s" % qg_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, qg_panel_rect.position + Vector2(10, 96), "💰 척추 하중 분산 인체공학 보너스: +%d%%" % int(qg_info["ergonomic_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Synaptic Neural-Memory Crystal Knowledge Synthesizer HUD Panel if ON
	if GameState.is_memory_crystal_hud_open:
		var mc_info = GameState.calculate_memory_crystal_metrics()
		var mc_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(mc_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(mc_panel_rect, Color(0.7, 0.4, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, mc_panel_rect.position + Vector2(10, 22), "💎 신경-메모리 결정체 지식 합성기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.4, 0.95))
		draw_string(ThemeDB.fallback_font, mc_panel_rect.position + Vector2(10, 42), "💎 결정체 전송 속도: %.1f Gbps" % mc_info["synthesis_gbps"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, mc_panel_rect.position + Vector2(10, 60), "🔮 장기 시냅스 파동 유지율: %.4f%%" % mc_info["retention_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.4, 0.95))
		draw_string(ThemeDB.fallback_font, mc_panel_rect.position + Vector2(10, 78), "💎 결정체 합성기 상태: %s" % mc_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, mc_panel_rect.position + Vector2(10, 96), "💰 시험 만점 마스터리 성적 보너스: +%d%%" % int(mc_info["mastery_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Super-Conductive Zero-Resistance Power Matrix Grid HUD Panel if ON
	if GameState.is_superconductive_power_hud_open:
		var sp_info = GameState.calculate_superconductive_power_metrics()
		var sp_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(sp_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sp_panel_rect, Color(0.95, 0.9, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sp_panel_rect.position + Vector2(10, 22), "⚡ 초전도 제로-저항 전력 그리드", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.9, 0.2))
		draw_string(ThemeDB.fallback_font, sp_panel_rect.position + Vector2(10, 42), "⚡ 제로-손실 전력 송전 효율: %.4f%%" % sp_info["efficiency_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sp_panel_rect.position + Vector2(10, 60), "🔮 임계 서모 전도 온실: %.2f K" % sp_info["temp_k"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.9, 0.2))
		draw_string(ThemeDB.fallback_font, sp_panel_rect.position + Vector2(10, 78), "⚡ 초전도 전력 그리드 상태: %s" % sp_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sp_panel_rect.position + Vector2(10, 96), "💰 매장 총 전기/유틸리티 유지비 절감: -%d%%" % int(sp_info["cost_saving"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Photonic Quantum Solar-Spectrum Photosynthesis Air-Regenerator HUD Panel if ON
	if GameState.is_biophotonic_air_hud_open:
		var ba_info = GameState.calculate_biophotonic_air_metrics()
		var ba_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(ba_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ba_panel_rect, Color(0.3, 0.95, 0.5), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ba_panel_rect.position + Vector2(10, 22), "🌿 퀀텀 광합성 공기재생기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ba_panel_rect.position + Vector2(10, 42), "🌿 산소 생성 멸균 순도: %.4f%%" % ba_info["oxygen_purity"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ba_panel_rect.position + Vector2(10, 60), "🔮 이산화탄소 집진 포집: -%.1f PPM" % ba_info["co2_scrubbed"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ba_panel_rect.position + Vector2(10, 78), "🌿 공기재생기 상태: %s" % ba_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ba_panel_rect.position + Vector2(10, 96), "💰 뇌 활성화 인지 각성도 보너스: +%d%%" % int(ba_info["alertness_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Sub-Quantum Dark-Matter Zero-Point Gravity Deflection Matrix HUD Panel if ON
	if GameState.is_dark_matter_gravity_hud_open:
		var dm_info = GameState.calculate_dark_matter_gravity_metrics()
		var dm_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(dm_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(dm_panel_rect, Color(0.5, 0.3, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, dm_panel_rect.position + Vector2(10, 22), "🌌 아원자 다크매터 중력편향 엔진", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.5, 0.3, 0.95))
		draw_string(ThemeDB.fallback_font, dm_panel_rect.position + Vector2(10, 42), "🌌 다크매터 입자 집진 밀도: %.4f g/cm³" % dm_info["density_gcm3"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, dm_panel_rect.position + Vector2(10, 60), "🔮 공간 미세 중력 편향 각도: %.4f°" % dm_info["deflection_deg"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.3, 0.95))
		draw_string(ThemeDB.fallback_font, dm_panel_rect.position + Vector2(10, 78), "🌌 중력 편향 엔진 상태: %s" % dm_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, dm_panel_rect.position + Vector2(10, 96), "💰 신체 피로 무중력 제로 부유 보너스: +%d%%" % int(dm_info["levitation_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Quantum-Entangled Sub-Space Temporal Chrono-Dilation Field Stabilizer HUD Panel if ON
	if GameState.is_chrono_dilation_hud_open:
		var chrono_dil_info = GameState.calculate_chrono_dilation_metrics()
		var chrono_dil_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(chrono_dil_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(chrono_dil_panel_rect, Color(0.95, 0.7, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, chrono_dil_panel_rect.position + Vector2(10, 22), "⏳ 퀀텀 시간지연 크로노 필드 안정기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.7, 0.2))
		draw_string(ThemeDB.fallback_font, chrono_dil_panel_rect.position + Vector2(10, 42), "⏳ 서브스페이스 주관적 시간지연 배율: %.2fx" % chrono_dil_info["time_dilation_factor"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, chrono_dil_panel_rect.position + Vector2(10, 60), "🔮 크로논 장 위상 교정 정밀도: %.4f%%" % chrono_dil_info["chronon_stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.7, 0.2))
		draw_string(ThemeDB.fallback_font, chrono_dil_panel_rect.position + Vector2(10, 78), "⏳ 크로노 필드 상태: %s" % chrono_dil_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, chrono_dil_panel_rect.position + Vector2(10, 96), "💰 주관적 학업 집중 체감 효율: +%d%%" % int(chrono_dil_info["efficiency_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Synaptic Neural-Pattern Cognition Memory Crystallizer HUD Panel if ON
	if GameState.is_neural_crystallizer_hud_open:
		var crys_info = GameState.calculate_neural_crystallizer_metrics()
		var crys_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(crys_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(crys_panel_rect, Color(0.4, 0.7, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, crys_panel_rect.position + Vector2(10, 22), "💎 바이오시냅스 신경패턴 결정체화기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.7, 1.0))
		draw_string(ThemeDB.fallback_font, crys_panel_rect.position + Vector2(10, 42), "💎 인지 기억 결정체화 속도: %.1f Mbps" % crys_info["speed_mbps"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, crys_panel_rect.position + Vector2(10, 60), "🔮 시냅스 장기 회상 인지 정밀도: %.4f%%" % crys_info["recall_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.7, 1.0))
		draw_string(ThemeDB.fallback_font, crys_panel_rect.position + Vector2(10, 78), "💎 신경 결정체화기 상태: %s" % crys_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, crys_panel_rect.position + Vector2(10, 96), "💰 시험 만점 암기 정복 보너스: +%d%%" % int(crys_info["mastery_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Super-Conductive Photonic Laser Wireless Power Transmission Network HUD Panel if ON
	if GameState.is_photonic_power_hud_open:
		var photonic_info = GameState.calculate_photonic_power_metrics()
		var photonic_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(photonic_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(photonic_panel_rect, Color(1.0, 0.4, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, photonic_panel_rect.position + Vector2(10, 22), "⚡ 초전도 포토닉 무선전력 전송망", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.4, 0.2))
		draw_string(ThemeDB.fallback_font, photonic_panel_rect.position + Vector2(10, 42), "⚡ 적외선 포토닉 레이저 출력: %.1f kW" % photonic_info["laser_kw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, photonic_panel_rect.position + Vector2(10, 60), "🔮 무선 전력 수신 수송 효율: %.4f%%" % photonic_info["efficiency_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.4, 0.2))
		draw_string(ThemeDB.fallback_font, photonic_panel_rect.position + Vector2(10, 78), "⚡ 무선전력 전송망 상태: %s" % photonic_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, photonic_panel_rect.position + Vector2(10, 96), "💰 케이블 Zero 전력 그리드 절감 보너스: +%d%%" % int(photonic_info["grid_saving_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Sub-Quantum Dark-Matter Dark-Energy Dimensional Energy Converter HUD Panel if ON
	if GameState.is_dark_energy_converter_hud_open:
		var de_info = GameState.calculate_dark_energy_converter_metrics()
		var de_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(de_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(de_panel_rect, Color(0.6, 0.3, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, de_panel_rect.position + Vector2(10, 22), "🌌 아원자 암흑에너지 차원 전환기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.6, 0.3, 0.95))
		draw_string(ThemeDB.fallback_font, de_panel_rect.position + Vector2(10, 42), "🌌 암흑에너지 전환 밀도: %.1e J/m³" % de_info["density_joule"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, de_panel_rect.position + Vector2(10, 60), "🔮 우주 팽창 에너지 수송 효율: %.4f%%" % de_info["expansion_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.6, 0.3, 0.95))
		draw_string(ThemeDB.fallback_font, de_panel_rect.position + Vector2(10, 78), "🌌 차원 전환기 상태: %s" % de_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, de_panel_rect.position + Vector2(10, 96), "💰 무한 공간 에너지 공급 효율: +%d%%" % int(de_info["cosmic_energy_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Super-Conductive Quantum Singularity Event-Horizon Gravity-Well Power-Station HUD Panel if ON
	if GameState.is_singularity_power_hud_open:
		var sing_info = GameState.calculate_singularity_power_metrics()
		var sing_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(sing_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sing_panel_rect, Color(0.9, 0.2, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sing_panel_rect.position + Vector2(10, 22), "🌌 퀀텀 싱귤래리티 중력우물 발전소", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.2, 0.95))
		draw_string(ThemeDB.fallback_font, sing_panel_rect.position + Vector2(10, 42), "🌌 인공 싱귤래리티 질량: %.3e kg" % sing_info["mass_kg"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sing_panel_rect.position + Vector2(10, 60), "🔮 호킹 방사 & 펜로즈 과정 발전: %.1f GW" % sing_info["hawking_gw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.2, 0.95))
		draw_string(ThemeDB.fallback_font, sing_panel_rect.position + Vector2(10, 78), "🌌 중력우물 발전소 상태: %s" % sing_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sing_panel_rect.position + Vector2(10, 96), "💰 무한 중력 에너지 전력망 공급: +%d%%" % int(sing_info["infinite_power_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Photonic Neural-Resonance Memory-Crystal Transmutation Reactor HUD Panel if ON
	if GameState.is_transmutation_reactor_hud_open:
		var trans_info = GameState.calculate_transmutation_reactor_metrics()
		var trans_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(trans_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(trans_panel_rect, Color(0.2, 0.7, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, trans_panel_rect.position + Vector2(10, 22), "⚛️ 기억-결정체 변무테이션 리액터", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.7, 0.95))
		draw_string(ThemeDB.fallback_font, trans_panel_rect.position + Vector2(10, 42), "⚛️ 신경 변무테이션 처리 속도: %.4f Gbps" % trans_info["rate_gbps"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, trans_panel_rect.position + Vector2(10, 60), "🔮 포토닉 공명 격자 정밀도: %.4f%%" % trans_info["purity_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.7, 0.95))
		draw_string(ThemeDB.fallback_font, trans_panel_rect.position + Vector2(10, 78), "⚛️ 리액터 연산 상태: %s" % trans_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, trans_panel_rect.position + Vector2(10, 96), "💰 초고속 학습 수용 & 인지 흡수 보너스: +%d%%" % int(trans_info["absorption_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Global Quantum-Entangled Franchise Franchise-Ledger Node Relay HUD Panel if ON
	if GameState.is_franchise_ledger_hud_open:
		var ledger_info = GameState.calculate_franchise_ledger_metrics()
		var ledger_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(ledger_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ledger_panel_rect, Color(0.2, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ledger_panel_rect.position + Vector2(10, 22), "🌐 퀀텀 프랜차이즈 가맹원장 노드리레이", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, ledger_panel_rect.position + Vector2(10, 42), "🌐 글로벌 얽힘 동기화 동결 지연: %.7f ms" % ledger_info["sync_latency_ms"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ledger_panel_rect.position + Vector2(10, 60), "🔮 전세계 수용 활성 노드 수: %d 개소" % ledger_info["active_nodes"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, ledger_panel_rect.position + Vector2(10, 78), "🌐 가맹원장 리레이 상태: %s" % ledger_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ledger_panel_rect.position + Vector2(10, 96), "💰 가맹 로열티 자동 수수료 지분: +%d%%" % int(ledger_info["royalty_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Dynamic Sub-Molecular Peptide Neuro-Stimulator HUD Panel if ON
	if GameState.is_peptide_stimulator_hud_open:
		var pep_info = GameState.calculate_peptide_stimulator_metrics()
		var pep_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(pep_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(pep_panel_rect, Color(0.2, 0.95, 0.7), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, pep_panel_rect.position + Vector2(10, 22), "🧬 바이오-다이내믹 펩타이드 신경자극기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.95, 0.7))
		draw_string(ThemeDB.fallback_font, pep_panel_rect.position + Vector2(10, 42), "🧬 바이오 펩타이드 농도: %.4f PPM" % pep_info["peptide_ppm"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, pep_panel_rect.position + Vector2(10, 60), "🔮 시냅스 신경 전달 펄스 속도: %.1f m/s" % pep_info["speed_ms"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.7))
		draw_string(ThemeDB.fallback_font, pep_panel_rect.position + Vector2(10, 78), "🧬 신경 자극기 상태: %s" % pep_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, pep_panel_rect.position + Vector2(10, 96), "💰 인지 체력 & 집중 지속 지구력: +%d%%" % int(pep_info["endurance_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Global Quantum-Mesh Franchise Landmark Satellite Network HUD Panel if ON
	if GameState.is_satellite_mesh_hud_open:
		var sat_info = GameState.calculate_satellite_mesh_metrics()
		var sat_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(sat_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sat_panel_rect, Color(0.3, 0.7, 0.95), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 22), "🛰️ 글로벌 퀀텀-메쉬 위성 네트워크", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.7, 0.95))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 42), "🛰️ 궤도 중계 퀀텀 대역폭: %.1f Tbps" % sat_info["bandwidth_tbps"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 60), "🔮 전 지구 랜드마크 레이턴시: %.4f ms" % sat_info["latency_ms"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.7, 0.95))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 78), "🛰️ 위성 네트워크 상태: %s" % sat_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 96), "💰 글로벌 로열티 재정 수익율: +%d%%" % int(sat_info["royalty_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Cryogenic Quantum-Infused Nitrogen Roast Energy Synthesizer HUD Panel if ON
	if GameState.is_cryo_roaster_hud_open:
		var cryo_info = GameState.calculate_cryo_roaster_metrics()
		var cryo_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(cryo_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(cryo_panel_rect, Color(0.4, 0.85, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, cryo_panel_rect.position + Vector2(10, 22), "❄️ 극저온 퀀텀 액체질소 영하로스팅", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, cryo_panel_rect.position + Vector2(10, 42), "❄️ 영하 로스팅 추출 온도: %.1f °C" % cryo_info["temp_celsius"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, cryo_panel_rect.position + Vector2(10, 60), "🔮 항산화 풍미 분자 보존율: %.4f%%" % cryo_info["retention_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, cryo_panel_rect.position + Vector2(10, 78), "❄️ 영하 로스팅 합성기 상태: %s" % cryo_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, cryo_panel_rect.position + Vector2(10, 96), "💰 프리미엄 음료 만족 재방문율: +%d%%" % int(cryo_info["satisfaction_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Bio-Robotic Kinetic Exoskeleton Posture Corrector HUD Panel if ON
	if GameState.is_exoskeleton_corrector_hud_open:
		var exo_corr_info = GameState.calculate_exoskeleton_corrector_metrics()
		var exo_corr_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(exo_corr_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(exo_corr_panel_rect, Color(0.95, 0.6, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, exo_corr_panel_rect.position + Vector2(10, 22), "🦾 생체역학 외골격 체형교정기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.6, 0.2))
		draw_string(ThemeDB.fallback_font, exo_corr_panel_rect.position + Vector2(10, 42), "🦾 척추 배열 자율 정밀도: %.4f%%" % exo_corr_info["alignment_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, exo_corr_panel_rect.position + Vector2(10, 60), "🔮 미세진동 근육 피로 감쇄율: %.1f%%" % exo_corr_info["fatigue_red_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.6, 0.2))
		draw_string(ThemeDB.fallback_font, exo_corr_panel_rect.position + Vector2(10, 78), "🦾 체형 교정기 상태: %s" % exo_corr_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, exo_corr_panel_rect.position + Vector2(10, 96), "💰 마라톤 몰입 학업 집중 보너스: +%d%%" % int(exo_corr_info["focus_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Atmospheric Vapor-Harvesting Pure Water Generator HUD Panel if ON
	if GameState.is_nano_atmospheric_water_hud_open:
		var water_harvest_info = GameState.calculate_nano_atmospheric_water_metrics()
		var water_harvest_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(water_harvest_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(water_harvest_panel_rect, Color(0.2, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, water_harvest_panel_rect.position + Vector2(10, 22), "💧 자율 대기 수자원 응축 순수 생성기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, water_harvest_panel_rect.position + Vector2(10, 42), "💧 대기 수증기 응축 생성량: %.1f L/일" % water_harvest_info["extraction_rate_l_day"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, water_harvest_panel_rect.position + Vector2(10, 60), "🔮 자외선 멸균 수질 순도율: %.4f%%" % water_harvest_info["water_purity_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, water_harvest_panel_rect.position + Vector2(10, 78), "💧 수자원 생성기 상태: %s" % water_harvest_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, water_harvest_panel_rect.position + Vector2(10, 96), "💰 수도 세금 절감 & 음료 신선도 보너스: +%d%%" % int(water_harvest_info["utility_saving_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Aeroponic Vertical Botanical Nutrient-Mist Injector HUD Panel if ON
	if GameState.is_aeroponic_botanical_hud_open:
		var aero_info = GameState.calculate_aeroponic_botanical_metrics()
		var aero_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(aero_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(aero_panel_rect, Color(0.3, 0.95, 0.5), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, aero_panel_rect.position + Vector2(10, 22), "🌿 에어로포닉 수직식물원 영양안개분사", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, aero_panel_rect.position + Vector2(10, 42), "🌿 초음파 미세안개 입자 직경: %.1f µm" % aero_info["mist_micron"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, aero_panel_rect.position + Vector2(10, 60), "🔮 식물 증산 작용 생체산소 증대율: %.4f%%" % aero_info["oxygen_boost_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, aero_panel_rect.position + Vector2(10, 78), "🌿 영양안개 분사기 상태: %s" % aero_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, aero_panel_rect.position + Vector2(10, 96), "💰 피톤치드 심신 안정 뇌피로 해소: +%d%%" % int(aero_info["restoration_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Super-Conductive Magnetic Quantum Levitation Floor Matrix HUD Panel if ON
	if GameState.is_maglev_floor_hud_open:
		var maglev_info = GameState.calculate_maglev_floor_metrics()
		var maglev_panel_rect = Rect2(hud_panel_x - 40.0, 60, 240, 130)
		draw_rect(maglev_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(maglev_panel_rect, Color(0.95, 0.8, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, maglev_panel_rect.position + Vector2(10, 22), "🧲 초전도 자기장 양자부유 바닥매트릭스", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, maglev_panel_rect.position + Vector2(10, 42), "🧲 초전도 자속 밀도: %.1f Tesla" % maglev_info["flux_tesla"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, maglev_panel_rect.position + Vector2(10, 60), "🔮 마이스너 효과 부유 안정성: %.4f%%" % maglev_info["stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, maglev_panel_rect.position + Vector2(10, 78), "🧲 양자 부유 바닥 상태: %s" % maglev_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, maglev_panel_rect.position + Vector2(10, 96), "💰 미세진동 Zero 음향 부유 차음: +%d%%" % int(maglev_info["isolation_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Entanglement Antimatter Energy HUD Panel if ON
	if GameState.is_antimatter_hud_open:
		var ant_info = GameState.calculate_antimatter_energy_metrics()
		var ant_panel_rect = Rect2(ant_btn_x - 40.0, 60, 240, 130)
		draw_rect(ant_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ant_panel_rect, Color(0.85, 0.3, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ant_panel_rect.position + Vector2(10, 22), "⚛️ 양자 얽힘 반물질 초청정 에너지", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.3, 1.0))
		draw_string(ThemeDB.fallback_font, ant_panel_rect.position + Vector2(10, 42), "⚛️ 반물질 가둠 자기장 안정율: %.4f%%" % ant_info["stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ant_panel_rect.position + Vector2(10, 60), "🔋 양자 얽힘 전력 발전 출력: %.1f MW" % ant_info["output_mw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.3, 1.0))
		draw_string(ThemeDB.fallback_font, ant_panel_rect.position + Vector2(10, 78), "⚛️ 초청정 에너지 발전 등급: %s" % ant_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ant_panel_rect.position + Vector2(10, 96), "💰 탄소배출 Zero 글로벌 ESG 마진: +%d%%" % int(ant_info["margin_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Conscious Neural Synapse Telepathic Memory Download HUD Panel if ON
	if GameState.is_telepathic_hud_open:
		var tel_info = GameState.calculate_neural_telepathic_metrics()
		var tel_panel_rect = Rect2(tel_btn_x - 40.0, 60, 240, 130)
		draw_rect(tel_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(tel_panel_rect, Color(0.95, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, tel_panel_rect.position + Vector2(10, 22), "🧠 텔레파시 신경 시냅스 지식 다운로드", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, tel_panel_rect.position + Vector2(10, 42), "🧠 신경 시냅스 전송 속도: %.3f TB/s" % tel_info["speed_tbs"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, tel_panel_rect.position + Vector2(10, 60), "🧠 잠재의식 장기 기억 고정율: %.3f%%" % tel_info["retention_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, tel_panel_rect.position + Vector2(10, 78), "🧠 시냅스 텔레파시 등급: %s" % tel_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, tel_panel_rect.position + Vector2(10, 96), "💰 초지능 수험생 프리미엄 멤버십: +%d%%" % int(tel_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Tachyon Chrono Temporal Acceleration HUD Panel if ON
	if GameState.is_tachyon_hud_open:
		var tac_info = GameState.calculate_tachyon_chrono_metrics()
		var tac_panel_rect = Rect2(tac_btn_x - 40.0, 60, 240, 130)
		draw_rect(tac_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(tac_panel_rect, Color(1.0, 0.75, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, tac_panel_rect.position + Vector2(10, 22), "⏳ 타키온 초시공간 시간 왜곡 가속기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.75, 0.2))
		draw_string(ThemeDB.fallback_font, tac_panel_rect.position + Vector2(10, 42), "⏳ 학습 시간 왜곡 가속 배율: %.1fx" % tac_info["dilation_mult"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, tac_panel_rect.position + Vector2(10, 60), "🌌 시공간 엔트로피 안점감: %.3f%%" % tac_info["stability_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.75, 0.2))
		draw_string(ThemeDB.fallback_font, tac_panel_rect.position + Vector2(10, 78), "⏳ 시공간 시간 가속 등급: %s" % tac_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, tac_panel_rect.position + Vector2(10, 96), "💰 초단기 합격률 VIP 정기권 수익: +%d%%" % int(tac_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Space Wormhole Tesseract Spatial Storage Expansion HUD Panel if ON
	if GameState.is_tesseract_hud_open:
		var tes_info = GameState.calculate_tesseract_expansion_metrics()
		var tes_panel_rect = Rect2(tes_btn_x - 40.0, 60, 240, 130)
		draw_rect(tes_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(tes_panel_rect, Color(0.4, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, tes_panel_rect.position + Vector2(10, 22), "🌀 4차원 테서랙트 웜홀 공간 왜곡 확장", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, tes_panel_rect.position + Vector2(10, 42), "🌀 체적 공간 접힘 압축율: %.3f%%" % tes_info["compress_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, tes_panel_rect.position + Vector2(10, 60), "🌌 수용 인원 가상 멀티플라이어: %.1fx" % tes_info["capacity_mult"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, tes_panel_rect.position + Vector2(10, 78), "🌀 공간 확장 영토 등급: %s" % tes_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, tes_panel_rect.position + Vector2(10, 96), "💰 임대료 $0 무한 수용 확장 수익: +%d%%" % int(tes_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Atomic Particle Kinetic Energy Harvesting HUD Panel if ON
	if GameState.is_harvesting_hud_open:
		var hrv_info = GameState.calculate_electromagnetic_harvesting_metrics()
		var hrv_panel_rect = Rect2(hrv_btn_x - 40.0, 60, 240, 130)
		draw_rect(hrv_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(hrv_panel_rect, Color(1.0, 0.85, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, hrv_panel_rect.position + Vector2(10, 22), "⚡ 무선 운동 전자기장 하베스팅", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.85, 0.2))
		draw_string(ThemeDB.fallback_font, hrv_panel_rect.position + Vector2(10, 42), "⚡ 전자기 포집 에너지 전환율: %.2f%%" % hrv_info["convert_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, hrv_panel_rect.position + Vector2(10, 60), "🔋 아원자 발전 전력 출력: %.1f kW" % hrv_info["power_kw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.85, 0.2))
		draw_string(ThemeDB.fallback_font, hrv_panel_rect.position + Vector2(10, 78), "⚡ 하베스팅 전력 등급: %s" % hrv_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, hrv_panel_rect.position + Vector2(10, 96), "💰 자가발전 매장 영업 순이익률: +%d%%" % int(hrv_info["margin_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Spatial Olfactory Aromatherapy Synthesizer HUD Panel if ON
	if GameState.is_olfactory_hud_open:
		var olf_info = GameState.calculate_olfactory_synthesizer_metrics()
		var olf_panel_rect = Rect2(olf_btn_x - 40.0, 60, 240, 130)
		draw_rect(olf_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(olf_panel_rect, Color(0.3, 0.9, 0.5), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, olf_panel_rect.position + Vector2(10, 22), "🌿 피톤치드 공간 후각 디퓨저 합성기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.9, 0.5))
		draw_string(ThemeDB.fallback_font, olf_panel_rect.position + Vector2(10, 42), "🌿 공기 피톤치드 향미 순도: %.2f%%" % olf_info["purity_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, olf_panel_rect.position + Vector2(10, 60), "🧠 뇌파 아로마 릴렉싱 스트레스: %.2f PPM" % olf_info["stress_ppm"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.9, 0.5))
		draw_string(ThemeDB.fallback_font, olf_panel_rect.position + Vector2(10, 78), "🌿 아로마 디퓨징 등급: %s" % olf_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, olf_panel_rect.position + Vector2(10, 96), "💰 집중력 피로 회복 단골 친밀도 수익: +%d%%" % int(olf_info["refresh_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Gravitational Wave Noise Cancellation Acoustic HUD Panel if ON
	if GameState.is_grav_acoustic_hud_open:
		var grv_info = GameState.calculate_gravitational_acoustic_metrics()
		var grv_panel_rect = Rect2(grv_btn_x - 40.0, 60, 240, 130)
		draw_rect(grv_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(grv_panel_rect, Color(0.8, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, grv_panel_rect.position + Vector2(10, 22), "🌌 중력파 위상 상쇄 무소음 아쿠스틱", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, grv_panel_rect.position + Vector2(10, 42), "🔊 음향 파형 상쇄 소음 상쇄율: %.3f%%" % grv_info["cancel_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, grv_panel_rect.position + Vector2(10, 60), "🌌 정적 존 배경 노이즈 플로어: %.3f dB" % grv_info["noise_floor_db"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, grv_panel_rect.position + Vector2(10, 78), "🌌 아쿠스틱 차음 등급: %s" % grv_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, grv_panel_rect.position + Vector2(10, 96), "💰 수험생 몰입 마라톤 이용권 수익: +%d%%" % int(grv_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Zero-Trust Quantum Cryptographic Blockchain Treasury HUD Panel if ON
	if GameState.is_treasury_hud_open:
		var trs_info = GameState.calculate_quantum_treasury_metrics()
		var trs_panel_rect = Rect2(trs_btn_x - 40.0, 60, 240, 130)
		draw_rect(trs_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(trs_panel_rect, Color(0.3, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, trs_panel_rect.position + Vector2(10, 22), "💎 zk-SNARKs 양자 탈중앙화 결제 지불망", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, trs_panel_rect.position + Vector2(10, 42), "⚡ 초고속 마이크로 정산: %.4f s" % trs_info["settle_speed"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, trs_panel_rect.position + Vector2(10, 60), "🔐 양자 암호 무결성 보안율: %.1f%%" % trs_info["security"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, trs_panel_rect.position + Vector2(10, 78), "💎 탈중앙화 금고 등급: %s" % trs_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, trs_panel_rect.position + Vector2(10, 96), "💰 결제 수수료 $0 가맹점 배당 순이익: +%d%%" % int(trs_info["dividend_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Sub-Zero Nitrogen Cryogenic Preservation HUD Panel if ON
	if GameState.is_cryo_hud_open:
		var cry_info = GameState.calculate_cryogenic_roaster_metrics()
		var cry_panel_rect = Rect2(cry_btn_x - 40.0, 60, 240, 130)
		draw_rect(cry_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(cry_panel_rect, Color(0.3, 0.85, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, cry_panel_rect.position + Vector2(10, 22), "❄️ -196℃ 액체질소 분자 급속냉동 보존", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, cry_panel_rect.position + Vector2(10, 42), "🌡️ 원두 창고 보존 온도: %.1f ℃" % cry_info["temp_c"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, cry_panel_rect.position + Vector2(10, 60), "☕ 휘발성 아로마 향미 보존율: %.2f%%" % cry_info["aroma_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, cry_panel_rect.position + Vector2(10, 78), "❄️ 극저온 보존 등급: %s" % cry_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, cry_panel_rect.position + Vector2(10, 96), "💰 프리미엄 스페셜티 커피 잔당 단가: +%d%%" % int(cry_info["price_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Entanglement Instant Teleportation HUD Panel if ON
	if GameState.is_teleport_hud_open:
		var tp_info = GameState.calculate_quantum_teleportation_metrics()
		var tp_panel_rect = Rect2(tp_btn_x - 40.0, 60, 240, 130)
		draw_rect(tp_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(tp_panel_rect, Color(0.7, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, tp_panel_rect.position + Vector2(10, 22), "🌌 양자 얽힘 섭스페이스 순간이동 배송", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, tp_panel_rect.position + Vector2(10, 42), "⚡ 순간 전송 속도: %.3f s" % tp_info["latency"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, tp_panel_rect.position + Vector2(10, 60), "🔮 물질화 노드 안정성: %.3f%%" % tp_info["stability"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, tp_panel_rect.position + Vector2(10, 78), "🌌 양자 순간이동 등급: %s" % tp_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, tp_panel_rect.position + Vector2(10, 96), "🍹 무소음 즉시 배송 스낵 주문 매출 보너스: +%d%%" % int(tp_info["order_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Exoskeleton Ergonomic Posture HUD Panel if ON
	if GameState.is_exo_hud_open:
		var exo_info = GameState.calculate_exoskeleton_posture_metrics()
		var exo_panel_rect = Rect2(exo_btn_x - 40.0, 60, 240, 130)
		draw_rect(exo_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(exo_panel_rect, Color(1.0, 0.75, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, exo_panel_rect.position + Vector2(10, 22), "🦾 자율 능동 척추 외골격 & 자세 보정", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.75, 0.2))
		draw_string(ThemeDB.fallback_font, exo_panel_rect.position + Vector2(10, 42), "🏋️ 요추 반발 지지력: %.1f N" % exo_info["support_force"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, exo_panel_rect.position + Vector2(10, 60), "⚡ 척추 경추 피로도 감소율: %.1f%%" % exo_info["fatigue_reduction"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, exo_panel_rect.position + Vector2(10, 78), "🦾 능동 보조 시스템 등급: %s" % exo_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, exo_panel_rect.position + Vector2(10, 96), "⏱️ 무피로 마라톤 공부 이용시간 보너스: +%d%%" % int(exo_info["session_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Hydroponic Vertical Farm HUD Panel if ON
	if GameState.is_farm_hud_open:
		var frm_info = GameState.calculate_hydroponic_farm_metrics()
		var frm_panel_rect = Rect2(frm_btn_x - 40.0, 60, 240, 130)
		draw_rect(frm_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(frm_panel_rect, Color(0.3, 0.95, 0.4), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, frm_panel_rect.position + Vector2(10, 22), "🥗 무균 수경재배 수직농장 & 스무디 바", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 0.4))
		draw_string(ThemeDB.fallback_font, frm_panel_rect.position + Vector2(10, 42), "🥬 일일 수경재배 작물 수확량: %.0f kg/day" % frm_info["yield_kg"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, frm_panel_rect.position + Vector2(10, 60), "🧬 바이오 영양소 체내 흡수율: %.1f%%" % frm_info["absorption"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, frm_panel_rect.position + Vector2(10, 78), "🥗 스마트 바이오 농장 등급: %s" % frm_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, frm_panel_rect.position + Vector2(10, 96), "🍹 신선 수퍼푸드 스무디 바 매출 보너스: +%d%%" % int(frm_info["profit_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Atmospheric Water Generator HUD Panel if ON
	if GameState.is_awg_hud_open:
		var awg_info = GameState.calculate_atmospheric_water_metrics()
		var awg_panel_rect = Rect2(awg_btn_x - 40.0, 60, 240, 130)
		draw_rect(awg_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(awg_panel_rect, Color(0.3, 0.9, 0.9), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, awg_panel_rect.position + Vector2(10, 22), "🌊 태양광 대기 집수 & 미네랄 전해질 바", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.9, 0.9))
		draw_string(ThemeDB.fallback_font, awg_panel_rect.position + Vector2(10, 42), "💧 일일 공기 집수 생산량: %.0f L/day" % awg_info["output_l"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, awg_panel_rect.position + Vector2(10, 60), "🧂 미네랄 음이온 전해질 밸런스: %.0f mg/L" % awg_info["mineral_mg"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, awg_panel_rect.position + Vector2(10, 78), "🌊 대기 집수 시스템 등급: %s" % awg_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, awg_panel_rect.position + Vector2(10, 96), "🧠 장시간 체력 유지 & 이용시간 보너스: +%d%%" % int(awg_info["vitality_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Supercomputer AI Curriculum HUD Panel if ON
	if GameState.is_curriculum_hud_open:
		var cur_info = GameState.calculate_quantum_curriculum_metrics()
		var cur_panel_rect = Rect2(cur_btn_x - 40.0, 60, 240, 130)
		draw_rect(cur_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(cur_panel_rect, Color(0.9, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, cur_panel_rect.position + Vector2(10, 22), "💻 양자 AI 커리큘럼 & 출제 예측기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, cur_panel_rect.position + Vector2(10, 42), "⚡ 양자 연산 성능: %.1f PetaFLOPS" % cur_info["pflops"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, cur_panel_rect.position + Vector2(10, 60), "🎯 신경망 출제 경향 예측 정밀도: %.1f%%" % cur_info["precision"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, cur_panel_rect.position + Vector2(10, 78), "💻 AI 튜터링 예측 등급: %s" % cur_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, cur_panel_rect.position + Vector2(10, 96), "🏆 프리미엄 몰입 좌석 점유율 및 수입: +%d%%" % int(cur_info["seat_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Fusion Nuclear Micro-Reactor HUD Panel if ON
	if GameState.is_fusion_hud_open:
		var fsn_info = GameState.calculate_fusion_reactor_metrics()
		var fsn_panel_rect = Rect2(fsn_btn_x - 40.0, 60, 240, 130)
		draw_rect(fsn_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(fsn_panel_rect, Color(1.0, 0.6, 0.2), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, fsn_panel_rect.position + Vector2(10, 22), "⚛️ SMR 용융염 핵융합 & 무선 공진 전력", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.6, 0.2))
		draw_string(ThemeDB.fallback_font, fsn_panel_rect.position + Vector2(10, 42), "⚡ 초소형 원자로 출력: %.1f MW" % fsn_info["power_mw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, fsn_panel_rect.position + Vector2(10, 60), "📶 무선 자기공진 전력 효율: %.1f%%" % fsn_info["wireless_eff"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, fsn_panel_rect.position + Vector2(10, 78), "⚛️ 핵융합 주권 등급: %s" % fsn_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, fsn_panel_rect.position + Vector2(10, 96), "💰 전기세 $0 무한 청정에너지 영업이익률: +%d%%" % int(fsn_info["profit_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Satellite Network HUD Panel if ON
	if GameState.is_satellite_hud_open:
		var sat_info = GameState.calculate_satellite_relay_metrics()
		var sat_panel_rect = Rect2(sat_btn_x - 40.0, 60, 240, 130)
		draw_rect(sat_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sat_panel_rect, Color(1.0, 0.8, 0.3), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 22), "📡 저궤도 위성 & 드론 리레이 통신망", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.8, 0.3))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 42), "🛰️ 위성 대역폭: %.0f Gbps (응답 지연 %.1fms)" % [sat_info["bandwidth"], sat_info["latency"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 60), "📡 위성 네트워크 상태: %s" % sat_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 78), "🌐 양자 빔포밍 연결: %s" % ("🟢 LEO 저궤도 100G" if sat_info["is_sat_unlocked"] else "⚪ 표준 5G"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sat_panel_rect.position + Vector2(10, 96), "👑 글로벌 제국 가맹점 백업 매출 보너스: +%d%%" % int(sat_info["empire_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Security Shield HUD Panel if ON
	if GameState.is_shield_hud_open:
		var sld_info = GameState.calculate_quantum_security_shield_metrics()
		var sld_panel_rect = Rect2(sld_btn_x - 40.0, 60, 240, 130)
		draw_rect(sld_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(sld_panel_rect, Color(0.4, 0.7, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, sld_panel_rect.position + Vector2(10, 22), "🛡️ 양자 암호화 & 생체 보안 쉴드", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.7, 1.0))
		draw_string(ThemeDB.fallback_font, sld_panel_rect.position + Vector2(10, 42), "🔑 QKD 양자 키 갱신 주기: %.3f sec" % sld_info["qkd_refresh"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, sld_panel_rect.position + Vector2(10, 60), "🛡️ 해킹 차단 및 침입 방지율: %.3f%%" % sld_info["defense_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, sld_panel_rect.position + Vector2(10, 78), "🔒 보안 쉴드 상태: %s" % sld_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, sld_panel_rect.position + Vector2(10, 96), "💼 VIP 단체 및 신뢰도 브랜드 보너스: +%d%%" % int(sld_info["trust_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous Delivery Robot HUD Panel if ON
	if GameState.is_robot_hud_open:
		var rbt_info = GameState.calculate_delivery_robot_metrics()
		var rbt_panel_rect = Rect2(rbt_btn_x - 40.0, 60, 240, 130)
		draw_rect(rbt_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(rbt_panel_rect, Color(0.3, 0.8, 0.9), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, rbt_panel_rect.position + Vector2(10, 22), "🤖 자율주행 라스트마일 서빙 로봇", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.8, 0.9))
		draw_string(ThemeDB.fallback_font, rbt_panel_rect.position + Vector2(10, 42), "🤖 가동중인 서빙 로봇: %d 대 (LiDAR SLAM)" % rbt_info["robots_count"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, rbt_panel_rect.position + Vector2(10, 60), "⏱️ 평균 테이블 배달 지연: %.1f sec" % rbt_info["latency"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, rbt_panel_rect.position + Vector2(10, 78), "🤖 서빙 플릿 상태: %s" % rbt_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, rbt_panel_rect.position + Vector2(10, 96), "🍩 스낵바 및 음료 추가 매출 보너스: +%d%%" % int(rbt_info["snack_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Piezoelectric Floor Power HUD Panel if ON
	if GameState.is_piezo_hud_open:
		var piz_info = GameState.calculate_piezoelectric_energy_metrics()
		var piz_panel_rect = Rect2(piz_btn_x - 40.0, 60, 240, 130)
		draw_rect(piz_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(piz_panel_rect, Color(0.3, 0.9, 0.5), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, piz_panel_rect.position + Vector2(10, 22), "⚡ 압전 바닥 보행 자가발전 시스템", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.9, 0.5))
		draw_string(ThemeDB.fallback_font, piz_panel_rect.position + Vector2(10, 42), "🔋 바닥 보행 에너제틱 발전량: %.2f kW" % piz_info["power_kw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, piz_panel_rect.position + Vector2(10, 60), "🌿 탄소 배출 저감 효과: %.1f kg CO2" % piz_info["carbon_offset"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, piz_panel_rect.position + Vector2(10, 78), "⚡ 자가발전 그리드 등급: %s" % piz_info["rating"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, piz_panel_rect.position + Vector2(10, 96), "🌱 ESG 친환경 매장 브랜드 보너스: +%d%%" % int(piz_info["eco_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Holographic AI Tutor HUD Panel if ON
	if GameState.is_hologram_hud_open:
		var hlo_info = GameState.calculate_holographic_tutor_metrics()
		var hlo_panel_rect = Rect2(hlo_btn_x - 40.0, 60, 240, 130)
		draw_rect(hlo_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(hlo_panel_rect, Color(0.8, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, hlo_panel_rect.position + Vector2(10, 22), "🔮 3D 홀로그램 AI 튜터 & 입체 강의", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, hlo_panel_rect.position + Vector2(10, 42), "🎥 투사 프레임 레이트: %.0f FPS (%s)" % [hlo_info["fps"], hlo_info["resolution"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, hlo_panel_rect.position + Vector2(10, 60), "🔮 홀로그램 AI 등급: %s" % hlo_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, hlo_panel_rect.position + Vector2(10, 78), "📐 3D 시각화 학습 효과: %s" % ("🟢 8K 볼륨 메쉬 투사" if hlo_info["is_holo_unlocked"] else "⚪ 4K 표준"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, hlo_panel_rect.position + Vector2(10, 96), "🎓 시험 합격률 & VIP 만족 보너스: +%d%%" % int(hlo_info["exam_pass_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Voice Command AI Butler HUD Panel if ON
	if GameState.is_voice_ai_hud_open:
		var voi_info = GameState.calculate_voice_ai_butler_metrics()
		var voi_panel_rect = Rect2(voi_btn_x - 40.0, 60, 240, 130)
		draw_rect(voi_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(voi_panel_rect, Color(0.3, 0.9, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, voi_panel_rect.position + Vector2(10, 22), "🗣️ 음성 AI 튜터 & 오디오 키오스크", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.9, 1.0))
		draw_string(ThemeDB.fallback_font, voi_panel_rect.position + Vector2(10, 42), "🎯 NLP 음성 인식 정밀도: %.1f%% (%s)" % [voi_info["accuracy"], voi_info["rating"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, voi_panel_rect.position + Vector2(10, 60), "⚡ AI 대화 응답 지연: %.2f sec" % voi_info["latency"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, voi_panel_rect.position + Vector2(10, 78), "🎙️ 음성 지원 모드: %s" % ("🟢 24시간 AI 집사" if voi_info["is_voice_unlocked"] else "⚪ 대기중"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, voi_panel_rect.position + Vector2(10, 96), "💰 무인 키오스크 회전율 매출 보너스: +%d%%" % int(voi_info["revenue_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Neuro-Feedback Soundscape HUD Panel if ON
	if GameState.is_neuro_hud_open:
		var nro_info = GameState.calculate_neuro_feedback_metrics()
		var nro_panel_rect = Rect2(nro_btn_x - 40.0, 60, 240, 130)
		draw_rect(nro_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(nro_panel_rect, Color(0.8, 0.5, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, nro_panel_rect.position + Vector2(10, 22), "🧠 뇌파 EEG & 뉴로피드백 사운드", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.5, 1.0))
		draw_string(ThemeDB.fallback_font, nro_panel_rect.position + Vector2(10, 42), "🧘 알파파 점유율 (α): %.1f%% (%s)" % [nro_info["alpha_pct"], nro_info["state"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, nro_panel_rect.position + Vector2(10, 60), "⚡ 베타파 각성율 (β): %.1f%%" % nro_info["beta_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, nro_panel_rect.position + Vector2(10, 78), "🎧 바이노럴 음파 합성: %s" % ("🟢 432Hz 핑크노이즈" if nro_info["is_neuro_unlocked"] else "⚪ 표준 사운드"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, nro_panel_rect.position + Vector2(10, 96), "🧠 시냅스 기억 및 문제해결 보너스: +%d%%" % int(nro_info["synapse_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Smart Water Quality HUD Panel if ON
	if GameState.is_water_hud_open:
		var wtr_info = GameState.calculate_water_quality_metrics()
		var wtr_panel_rect = Rect2(wtr_btn_x - 40.0, 60, 240, 130)
		draw_rect(wtr_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(wtr_panel_rect, Color(0.3, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, wtr_panel_rect.position + Vector2(10, 22), "💧 나노 정수 & 전해질 수소수 바", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, wtr_panel_rect.position + Vector2(10, 42), "🧪 수질 Purity TDS: %.1f ppm" % wtr_info["tds"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, wtr_panel_rect.position + Vector2(10, 60), "💎 활성 수소 농도: %.2f ppm (H2 Ion)" % wtr_info["hydrogen"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, wtr_panel_rect.position + Vector2(10, 78), "🏆 수질 등급: %s" % wtr_info["rating"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, wtr_panel_rect.position + Vector2(10, 96), "🧠 뇌 수분 보충 지속 집중력: +%d%%" % int(wtr_info["brain_stamina_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Solar Sun-Tracking Shading HUD Panel if ON
	if GameState.is_shading_hud_open:
		var shd_info = GameState.calculate_solar_shading_metrics()
		var shd_panel_rect = Rect2(shd_btn_x - 40.0, 60, 240, 130)
		draw_rect(shd_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(shd_panel_rect, Color(1.0, 0.7, 0.3), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, shd_panel_rect.position + Vector2(10, 22), "🪟 태양 고도 추적 전동 블라인드", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.7, 0.3))
		draw_string(ThemeDB.fallback_font, shd_panel_rect.position + Vector2(10, 42), "☀️ 실시간 태양 고도: %.1f°" % shd_info["solar_altitude"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, shd_panel_rect.position + Vector2(10, 60), "📐 전동 슬랫 차열 각도: %.0f%% (Motorized)" % shd_info["blind_angle"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, shd_panel_rect.position + Vector2(10, 78), "😎 차양 상태: %s" % shd_info["status"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, shd_panel_rect.position + Vector2(10, 96), "🧠 모니터 반사 방지 시야 보너스: +%d%%" % int(shd_info["visibility_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Customer Micro-Expression Emotion HUD Panel if ON
	if GameState.is_emotion_hud_open:
		var emo_info = GameState.calculate_customer_emotion_metrics()
		var emo_panel_rect = Rect2(emo_btn_x - 40.0, 60, 240, 130)
		draw_rect(emo_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(emo_panel_rect, Color(1.0, 0.6, 0.8), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, emo_panel_rect.position + Vector2(10, 22), "😊 고객 미세 표정 감정 AI 분석기", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.6, 0.8))
		draw_string(ThemeDB.fallback_font, emo_panel_rect.position + Vector2(10, 42), "💖 고객 긍정 행복도: %.1f%% (%s)" % [emo_info["happiness"], emo_info["mood"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, emo_panel_rect.position + Vector2(10, 60), "⚡ 피로 및 스트레스 수치: %.1f%%" % emo_info["stress"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, emo_panel_rect.position + Vector2(10, 78), "🎯 AI 환경 케어 반응: %s" % ("🟢 케어 가동중" if emo_info["is_emotion_ai_unlocked"] else "⚪ 대기중"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, emo_panel_rect.position + Vector2(10, 96), "🧠 장시간 이용 재방문율 보너스: +%d%%" % int(emo_info["retention_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Autonomous AI Cleaning Drone HUD Panel if ON
	if GameState.is_cleaning_drone_hud_open:
		var drn_info = GameState.calculate_cleaning_drone_metrics()
		var drn_panel_rect = Rect2(drn_btn_x - 40.0, 60, 240, 130)
		draw_rect(drn_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(drn_panel_rect, Color(0.3, 0.85, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, drn_panel_rect.position + Vector2(10, 22), "🤖 자율주행 AI 청소 드론 & UV-C 살균", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, drn_panel_rect.position + Vector2(10, 42), "✨ 매장 종합 청결도: %.1f%% (%s)" % [drn_info["hygiene_pct"], drn_info["rating"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, drn_panel_rect.position + Vector2(10, 60), "🔮 UV-C 자외선 살균 강도: %.0f mW/cm²" % drn_info["uvc_mw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, drn_panel_rect.position + Vector2(10, 78), "🔋 드론 배터리 잔량: %.1f%% (Auto-Dock)" % drn_info["battery_pct"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, drn_panel_rect.position + Vector2(10, 96), "👑 브랜드 청결 신뢰도 명성 보너스: +%d%%" % int(drn_info["reputation_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render PMV Thermal Comfort HUD Panel if ON
	if GameState.is_pmv_hud_open:
		var pmv_info = GameState.calculate_pmv_thermal_comfort_metrics()
		var pmv_panel_rect = Rect2(pmv_btn_x - 40.0, 60, 240, 130)
		draw_rect(pmv_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(pmv_panel_rect, Color(1.0, 0.5, 0.6), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, pmv_panel_rect.position + Vector2(10, 22), "🌡️ PMV 열쾌적성 & 복사 바닥 냉난방", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.5, 0.6))
		draw_string(ThemeDB.fallback_font, pmv_panel_rect.position + Vector2(10, 42), "📊 PMV 열쾌적 지수: %.2f (%s)" % [pmv_info["pmv"], pmv_info["status"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, pmv_panel_rect.position + Vector2(10, 60), "🦶 복사 바닥 표면 온도: %.1f °C" % pmv_info["floor_temp"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, pmv_panel_rect.position + Vector2(10, 78), "⚠️ PPD 예상 불만족 비율: %.1f%%" % pmv_info["ppd"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, pmv_panel_rect.position + Vector2(10, 96), "🧠 열적 중립 장시간 몰입 보너스: +%d%%" % int(pmv_info["neutrality_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Circadian Lighting HUD Panel if ON
	if GameState.is_circadian_hud_open:
		var c_info = GameState.calculate_circadian_spectrum_metrics()
		var c_panel_rect = Rect2(c_btn_x - 40.0, 60, 240, 130)
		draw_rect(c_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(c_panel_rect, Color(1.0, 0.8, 0.3), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, c_panel_rect.position + Vector2(10, 22), "💡 써카디안 생체주기 CCT 조명", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.8, 0.3))
		draw_string(ThemeDB.fallback_font, c_panel_rect.position + Vector2(10, 42), "🌡️ 색온도 Kelvin: %.0f K" % c_info["kelvin"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, c_panel_rect.position + Vector2(10, 60), "🌅 생체 리듬 단계: %s" % c_info["phase"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, c_panel_rect.position + Vector2(10, 78), "🕶️ 유해 블루라이트 차단율: %d%%" % int(c_info["bluelight_cut"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, c_panel_rect.position + Vector2(10, 96), "🧠 심야 수험생 학습 지속 보너스: +%d%%" % int(c_info["endurance_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Botanical Bio-Wall HUD Panel if ON
	if GameState.is_botanical_hud_open:
		var b_info = GameState.calculate_botanical_humidity_metrics()
		var b_panel_rect = Rect2(b_btn_x - 40.0, 60, 240, 130)
		draw_rect(b_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(b_panel_rect, Color(0.3, 0.9, 0.4), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, b_panel_rect.position + Vector2(10, 22), "🌿 미세 수목 식물벽 증산 온습도", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.9, 0.4))
		draw_string(ThemeDB.fallback_font, b_panel_rect.position + Vector2(10, 42), "💧 상대 습도: %.1f%% RH (%s)" % [b_info["humidity_rh"], b_info["comfort_status"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, b_panel_rect.position + Vector2(10, 60), "🪴 식물벽 증산 방출량: %.1f L/hr" % b_info["transpiration_rate"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, b_panel_rect.position + Vector2(10, 78), "👀 안구 건조 피로 완화: %s" % ("🟢 쾌적 유지" if b_info["humidity_rh"] >= 45.0 else "🟧 건조 주의"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, b_panel_rect.position + Vector2(10, 96), "🧠 수험생 쾌적 학습 보너스: +%d%%" % int(b_info["eye_relief_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Quantum Security HUD Panel if ON
	if GameState.is_quantum_hud_open:
		var q_info = GameState.calculate_quantum_security_metrics()
		var q_panel_rect = Rect2(q_btn_x - 40.0, 60, 240, 130)
		draw_rect(q_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(q_panel_rect, Color(0.2, 0.95, 0.7), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, q_panel_rect.position + Vector2(10, 22), "🔐 양자 암호화 QKD 출입 게이트", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.95, 0.7))
		draw_string(ThemeDB.fallback_font, q_panel_rect.position + Vector2(10, 42), "🛡️ 보안 등급: %s" % q_info["rating"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, q_panel_rect.position + Vector2(10, 60), "🔑 QKD 암호 엔트로피: %.1f%%" % q_info["entropy"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, q_panel_rect.position + Vector2(10, 78), "⚡ 게이트 태그 지연시간: %.1f sec" % q_info["latency"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, q_panel_rect.position + Vector2(10, 96), "💰 단골 안심 신뢰 보너스: +%d%%" % int(q_info["trust_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Biometric Pulse HUD Panel if ON
	if GameState.is_biometric_hud_open:
		var bio_info = GameState.calculate_biometric_pulse_metrics()
		var bio_panel_rect = Rect2(bio_btn_x - 40.0, 60, 240, 130)
		draw_rect(bio_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(bio_panel_rect, Color(1.0, 0.4, 0.6), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, bio_panel_rect.position + Vector2(10, 22), "🫀 손님 생체 맥박 & 릴렉세이션", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.4, 0.6))
		draw_string(ThemeDB.fallback_font, bio_panel_rect.position + Vector2(10, 42), "💓 평균 심박수: %.1f BPM (%s)" % [bio_info["bpm"], bio_info["heart_state"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, bio_panel_rect.position + Vector2(10, 60), "🎧 자동 사운드스케이프: %s" % bio_info["soundscape"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, bio_panel_rect.position + Vector2(10, 78), "⚠️ 스트레스 지수: %d%%" % int(bio_info["stress"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.5, 0.3))
		draw_string(ThemeDB.fallback_font, bio_panel_rect.position + Vector2(10, 96), "🧠 자율신경 안온 집중 보너스: +%d%%" % int(bio_info["stability_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))

	# Render Ergonomic Posture HUD Panel if ON
	if GameState.is_ergonomic_hud_open:
		var ergo_info = GameState.calculate_ergonomic_posture_metrics()
		var ergo_panel_rect = Rect2(ergo_btn_x - 40.0, 60, 240, 130)
		draw_rect(ergo_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(ergo_panel_rect, Color(1.0, 0.6, 0.3), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, ergo_panel_rect.position + Vector2(10, 22), "🪑 스마트 모션데스크 자세 센서", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.6, 0.3))
		draw_string(ThemeDB.fallback_font, ergo_panel_rect.position + Vector2(10, 42), "📏 데스크 높이: %.0f cm (%s)" % [ergo_info["desk_height"], ("스탠딩 모드" if ergo_info["is_standing"] else "좌식 모드")], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, ergo_panel_rect.position + Vector2(10, 60), "🧘 바른 자세 점수: %d점 / 100점" % ergo_info["posture_score"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, ergo_panel_rect.position + Vector2(10, 78), "⚠️ 착석 피로도: %d%% (%s)" % [int(ergo_info["fatigue"]), ("🔴 거북목 경보!" if ergo_info["turtle_neck_alert"] else "💚 쾌적")], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.4, 0.4) if ergo_info["turtle_neck_alert"] else Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, ergo_panel_rect.position + Vector2(10, 96), "⚡ 척추 체력 회복 속도: +%d%%" % int(ergo_info["recovery_pct"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Network HUD Panel if ON
	if GameState.is_network_hud_open:
		var net_info = GameState.calculate_network_bandwidth_metrics()
		var net_panel_rect = Rect2(net_btn_x - 40.0, 60, 240, 130)
		draw_rect(net_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(net_panel_rect, Color(0.8, 0.4, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, net_panel_rect.position + Vector2(10, 22), "📶 초고속 Wi-Fi 7 기가비트 트래픽", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.4, 1.0))
		draw_string(ThemeDB.fallback_font, net_panel_rect.position + Vector2(10, 42), "⚡ 실시간 부하: %.1f Mbps" % net_info["load_mbps"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, net_panel_rect.position + Vector2(10, 60), "⏱️ 핑 지연시간: %.1f ms (MLO)" % net_info["ping_ms"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, net_panel_rect.position + Vector2(10, 78), "📡 채널 분배: 6G(%d%%) / 5G(%d%%) / 2.4G(%d%%)" % [int(net_info["band_6g"]), int(net_info["band_5g"]), int(net_info["band_2g"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, net_panel_rect.position + Vector2(10, 96), "👨‍💻 개발자 몰입 코딩 보너스: +%d%%" % int(net_info["dev_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))

	# Render Air Quality HUD Panel if ON
	if GameState.is_air_quality_hud_open:
		var aq_info = GameState.calculate_indoor_air_quality_metrics()
		var aq_panel_rect = Rect2(aq_btn_x - 40.0, 60, 240, 125)
		draw_rect(aq_panel_rect, Color(0.06, 0.08, 0.1, 0.95), true)
		draw_rect(aq_panel_rect, Color(0.3, 0.8, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, aq_panel_rect.position + Vector2(10, 22), "🍃 실내 PM2.5 & CO2 바이오 공기질", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, aq_panel_rect.position + Vector2(10, 42), "📊 AQI 통합 지수: %d (%s)" % [aq_info["aqi"], aq_info["status"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, aq_panel_rect.position + Vector2(10, 60), "💨 초미세먼지 PM2.5: %.1f ug/m³" % aq_info["pm25_ug"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.9, 0.5))
		draw_string(ThemeDB.fallback_font, aq_panel_rect.position + Vector2(10, 78), "🫧 이산화탄소 CO2: %d ppm" % int(aq_info["co2_ppm"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, aq_panel_rect.position + Vector2(10, 96), "🧠 산소 보충 집중 보너스: +%d%%" % int(aq_info["focus_bonus"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.95, 0.6))

	# Render Power Grid HUD Panel if ON
	if GameState.is_power_grid_hud_open:
		var p_status = GameState.calculate_power_grid_energy_status()
		var pg_panel_rect = Rect2(pg_btn_x - 40.0, 60, 240, 135)
		draw_rect(pg_panel_rect, Color(0.06, 0.08, 0.1, 0.95), true)
		draw_rect(pg_panel_rect, Color(0.2, 0.95, 0.5), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 22), "⚡ 스마트 태양광 & ESS 전력망", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 42), "💡 총 실시간 부하: %.1f kW" % p_status["load_kw"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 60), "☀️ 태양광 발전량: %.1f kW (%s)" % [p_status["solar_kw"], GameState.time_of_day], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 78), "🔋 ESS 배터리 잔량: %d%%" % int(p_status["ess_battery_pct"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.8, 1.0))
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 96), "🌱 탄소 감축량: %.2f kg CO2" % p_status["co2_reduced_kg"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.9, 0.4))
		draw_string(ThemeDB.fallback_font, pg_panel_rect.position + Vector2(10, 114), "💰 전기요금 절감률: %d%%" % int(p_status["savings_pct"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.7, 0.1))

	# Render 16-Band Acoustic Frequency Spectrum HUD Panel if ON
	if GameState.is_equalizer_hud_open:
		var eq_spec = GameState.calculate_acoustic_equalizer_spectrum()
		var eq_panel_rect = Rect2(eq_btn_x - 50.0, 60, 230, 130)
		draw_rect(eq_panel_rect, Color(0.06, 0.08, 0.12, 0.95), true)
		draw_rect(eq_panel_rect, Color(0.3, 0.7, 1.0), false, 2.0)
		
		draw_string(ThemeDB.fallback_font, eq_panel_rect.position + Vector2(10, 22), "🎧 16-밴드 실시간 음향 EQ & ANC", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.7, 1.0))
		draw_string(ThemeDB.fallback_font, eq_panel_rect.position + Vector2(10, 40), "🔊 저음: %.1fdB | 중음: %.1fdB | 고음: %.1fdB" % [eq_spec["bass_db"], eq_spec["mid_db"], eq_spec["treble_db"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		draw_string(ThemeDB.fallback_font, eq_panel_rect.position + Vector2(10, 56), "🛡️ ANC 노이즈 차단율: %d%%" % int(eq_spec["anc_suppression"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.9, 0.5))
		
		# Draw 16 Spectrum Bars
		var bands_arr = eq_spec["bands"]
		var bar_w = 10.0
		var start_bx = eq_panel_rect.position.x + 12
		var base_by = eq_panel_rect.position.y + 118
		
		for b_idx in range(min(16, bands_arr.size())):
			var b_h = bands_arr[b_idx] * 48.0
			var b_rect = Rect2(start_bx + b_idx * (bar_w + 3), base_by - b_h, bar_w, b_h)
			var b_color = Color(0.2, 0.8, 1.0) if b_idx < 4 else (Color(0.2, 0.9, 0.5) if b_idx < 12 else Color(0.95, 0.6, 0.2))
			draw_rect(b_rect, b_color, true)

	# Render Heatmap HUD Legend Panel (Top Right below button) if ON
	if GameState.is_heatmap_mode:
		var hud_rect = Rect2(btn_x - 40.0, 60, 200, 105)
		draw_rect(hud_rect, Color(0.08, 0.09, 0.12, 0.92), true)
		draw_rect(hud_rect, Color(0.95, 0.6, 0.1), false, 2.0)
		draw_string(ThemeDB.fallback_font, hud_rect.position + Vector2(10, 22), "📊 2.5D 몰입도 & 소음 히트맵", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.7, 0.1))
		draw_string(ThemeDB.fallback_font, hud_rect.position + Vector2(10, 42), "🟢 초집중 존 (80~100%)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.95, 0.5))
		draw_string(ThemeDB.fallback_font, hud_rect.position + Vector2(10, 62), "🟡 쾌적 학습 (50~79%)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.8, 0.2))
		draw_string(ThemeDB.fallback_font, hud_rect.position + Vector2(10, 82), "🔴 소음 주의 (50% 미만)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.3, 0.2))

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

func spawn_floating_text(pos: Vector2, text: String, color: Color = Color.WHITE) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.position = pos
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", color)
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "position", pos + Vector2(0, -35), 1.2)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.2)
	tw.tween_callback(lbl.queue_free)
