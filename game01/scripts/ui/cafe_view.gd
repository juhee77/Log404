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
var drag_grab_offset: Vector2 = Vector2.ZERO
var hover_cell: Vector2i = Vector2i(-1, -1)

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
	if path == "":
		return null
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img != null:
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
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
		view_offset.y = clamp(view_offset.y, -400.0, 50.0)
		queue_redraw()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position - view_offset
		if event.pressed:
			# HIGHEST PRIORITY: If a seat is ALREADY selected to be moved, move to ANY clicked tile (Blue or Brown floor!)
			if selected_drag_seat != -1 and not is_dragging:
				var other_seat = pick_seat_at(click_pos)
				if other_seat != -1 and other_seat != selected_drag_seat:
					selected_drag_seat = other_seat
					floating_texts.append({
						"text": "🧩 책상 #%d 선택됨! 이동할 타일을 클릭하세요" % [other_seat + 1],
						"pos": GameState.get_seat_position(other_seat) + Vector2(0, -70),
						"alpha": 1.0,
						"color": Color(0.2, 0.9, 0.5)
					})
					queue_redraw()
					return
				
				if other_seat == -1:
					# Move the selected desk onto the isometric tile that was clicked.
					var result = GameState.place_seat_at_world(selected_drag_seat, click_pos)
					floating_texts.append({
						"text": result["msg"],
						"pos": result["pos"] + Vector2(0, -70),
						"alpha": 1.0,
						"color": Color(0.96, 0.62, 0.07) if not result["relocated"] else Color(1.0, 0.75, 0.3)
					})
					selected_drag_seat = -1
					is_dragging = false
					hover_cell = Vector2i(-1, -1)
					queue_redraw()
					return

			# 0. Check Clean Top Right Control Buttons Click
			var screen_click = event.position
			if GameState.is_decorating_mode:
				if decorate_reset_rect().has_point(screen_click):
					var n = GameState.reset_seat_layout()
					floating_texts.append({
						"text": "↺ 책상 %d개를 기본 배치로 되돌렸습니다" % n,
						"pos": Vector2(420, 480),
						"alpha": 1.0,
						"color": Color(1.0, 0.7, 0.5)
					})
					selected_drag_seat = -1
					is_dragging = false
					queue_redraw()
					return
			var btn_x = 706.0
			var h_btn_rect = Rect2(btn_x, 50, 160, 36)
			if h_btn_rect.has_point(screen_click):
				GameState.toggle_heatmap_mode()
				queue_redraw()
				return
				
			var tech_btn_x = btn_x
			var tech_btn_rect = Rect2(tech_btn_x, 8, 210, 36)
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

			# 2. Check Coffee Bar Click (Updated to Room 2 position!)
			var bar_rect = Rect2(1000, 75, 230, 100)
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
			
			# 3. Check Seat Selection & Drag Start (front-most desk wins)
			var hit_seat = pick_seat_at(click_pos)
			if hit_seat != -1:
				if GameState.dirty_seats.has(hit_seat):
					GameState.clean_seat(hit_seat)
					return
				
				var seat_pos = GameState.get_seat_position(hit_seat)
				selected_drag_seat = hit_seat
				is_dragging = false
				drag_grab_offset = click_pos - seat_pos
				drag_start_mouse_pos = event.position
				hover_cell = GameState.get_seat_cell(hit_seat)
				floating_texts.append({
					"text": "🧩 책상 선택됨! 원하는 타일을 클릭하거나 끌어서 이동하세요",
					"pos": seat_pos + Vector2(0, -70),
					"alpha": 1.0,
					"color": Color(0.2, 0.9, 0.5)
				})
				queue_redraw()
				return
		else:
			if is_dragging and selected_drag_seat != -1:
				is_dragging = false
				var drop_pos = event.position - view_offset - drag_grab_offset
				var result = GameState.place_seat_at_world(selected_drag_seat, drop_pos)
				floating_texts.append({
					"text": result["msg"],
					"pos": result["pos"] + Vector2(0, -70),
					"alpha": 1.0,
					"color": Color(0.96, 0.62, 0.07) if not result["relocated"] else Color(1.0, 0.75, 0.3)
				})
				selected_drag_seat = -1
				hover_cell = Vector2i(-1, -1)
				queue_redraw()
				return

	if event is InputEventMouseMotion:
		var motion_world = event.position - view_offset
		if selected_drag_seat != -1 and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if drag_start_mouse_pos.distance_to(event.position) > 4.0:
				is_dragging = true
			if is_dragging:
				# Live-preview the snap target; the move is committed on release.
				hover_cell = GameState.clamp_iso_cell(GameState.screen_to_iso(motion_world - drag_grab_offset))
				queue_redraw()
		elif GameState.is_decorating_mode or selected_drag_seat != -1:
			var new_hover = GameState.clamp_iso_cell(GameState.screen_to_iso(motion_world))
			if new_hover != hover_cell:
				hover_cell = new_hover
				queue_redraw()

func _draw() -> void:
	if GameState == null: return
	var rect = get_rect()
	var w = max(rect.size.x, 1280.0)
	var h = max(rect.size.y, 600.0)
	
	# 1. Architecture for the CURRENT floor. 1F is a warm wood study room, 2F a
	# dark carpeted booth floor, 3F an open-air rooftop deck under the sky.
	var th = theme()
	var horizon = 220.0 + view_offset.y
	var style = th["style"]

	if style == "deck":
		draw_rooftop_sky(w, horizon)
		draw_rooftop_railing(w, horizon)
	else:
		draw_rect(Rect2(0, 0, w, h), th["wall"], true)
		var slat_w = 40.0 if style == "wood" else 96.0
		for sx in range(int(w / slat_w) + 2):
			var x_pos = sx * slat_w
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, horizon), Color(th["wall_line"], 0.4), 1.2)
			draw_line(Vector2(x_pos + 1, 0), Vector2(x_pos + 1, horizon), Color(th["wall_hi"], 0.2), 1.0)
		if style == "carpet":
			# panelled wainscot with a gold picture rail
			draw_rect(Rect2(0, horizon - 74, w, 74), Color(0.17, 0.11, 0.17, 0.75), true)
			draw_line(Vector2(0, horizon - 74), Vector2(w, horizon - 74), Color(th["accent"], 0.7), 2.0)
			for px in range(int(w / 96.0) + 1):
				var fx = px * 96.0 + 14
				draw_rect(Rect2(fx, horizon - 62, 68, 48), Color(0.22, 0.15, 0.22, 0.6), false, 1.2)

		# Indirect ceiling cove, tinted to the floor's accent
		draw_rect(Rect2(0, 0, w, 18), Color(th["wall_line"], 1.0), true)
		draw_line(Vector2(0, 18), Vector2(w, 18), Color(th["accent"], 0.85), 2.5)
		draw_rect(Rect2(0, 18, w, 24), Color(th["accent"], 0.08), true)
		draw_line(Vector2(0, horizon - 2), Vector2(w, horizon - 2), Color(th["wall_hi"], 0.9), 4.0)

		# Window view (indoor floors only)
		var window_rect = Rect2(484 + view_offset.x, 60 + view_offset.y, 310, 240)
		if GameState.time_of_day == "DUSK":
			draw_rect(window_rect, Color(1.0, 0.45, 0.12, 0.32))
		elif GameState.time_of_day == "NIGHT":
			draw_rect(window_rect, Color(0.04, 0.06, 0.28, 0.48))
		else:
			draw_rect(window_rect, Color(0.2, 0.6, 1.0, 0.12))

	# 2. Floor surface: planks, carpet weave or decking
	draw_rect(Rect2(0, horizon, w, h), th["floor"])
	var plank_h = 32.0 if style != "carpet" else 26.0
	for py in range(int((h - 220) / plank_h) + 2):
		var y_pos = horizon + py * plank_h
		draw_line(Vector2(0, y_pos), Vector2(w, y_pos), Color(th["floor_line"], 0.4), 1.5)
		draw_line(Vector2(0, y_pos + 1), Vector2(w, y_pos + 1), Color(th["wall_hi"], 0.18), 1.0)
		if style == "carpet":
			# woven pile reads as short cross hatching, not long plank seams
			for cx in range(int(w / 22.0) + 1):
				draw_line(Vector2(cx * 22.0, y_pos + 6), Vector2(cx * 22.0 + 9, y_pos + plank_h - 6),
					Color(th["wall_hi"], 0.10), 1.0)
		else:
			var seam = 150.0 if style == "wood" else 210.0
			var x_offset = fmod(py * seam * 0.5, seam)
			for px in range(int(w / seam) + 2):
				var x_pos = px * seam + x_offset
				draw_line(Vector2(x_pos, y_pos), Vector2(x_pos, y_pos + plank_h), Color(th["floor_line"], 0.35), 1.2)

	# 3. Draw Full 2.5D Isometric Diamond Grid Pattern & Banner across Floor
	draw_full_isometric_floor_grid(w, h)
	
	# 4. Draw Custom Placed Furniture/Decorations
	for dec in GameState.custom_decorations:
		var d_pos = dec["pos"]
		draw_circle(d_pos, 16.0, Color(0.1, 0.8, 0.4, 0.3))
		draw_string(ThemeDB.fallback_font, d_pos + Vector2(-10, 6), "🪴", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		
	# 5. Draw Zone Based View Content
	# 5. Draw Multi-Room Integrated Architectural Layout
	draw_integrated_multi_room_layout(w, h)

	# 5b. Decorating HUD, drawn LAST so the room panels cannot paint over it, and
	# along the empty bottom of the study room so it clears the room banners.
	if GameState.is_decorating_mode:
		var banner_rect = Rect2(40, 508, 690, 34)
		draw_rect(banner_rect, Color(0.12, 0.1, 0.08, 0.96), true)
		draw_rect(banner_rect, Color(0.96, 0.62, 0.07), false, 2.0)
		draw_string(ThemeDB.fallback_font, banner_rect.position + Vector2(14, 23),
			"🔨 책상 옮기기: 책상을 클릭해 잡은 뒤, 원하는 칸을 클릭하거나 끌어서 놓으세요",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.96, 0.62, 0.07))

		var reset_rect = decorate_reset_rect()
		draw_rect(reset_rect, Color(0.32, 0.14, 0.14, 0.96), true)
		draw_rect(reset_rect, Color(0.95, 0.45, 0.35), false, 2.0)
		draw_string(ThemeDB.fallback_font, reset_rect.position + Vector2(16, 23), "↺ 배치 초기화",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.8, 0.75))
		
	# 6. Draw Floating Action Texts
	for ft in floating_texts:
		var c = ft["color"]
		c.a = ft["alpha"]
		draw_string(ThemeDB.fallback_font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 15, c)

func draw_full_isometric_floor_grid(_w: float, _h: float) -> void:
	var vo = view_offset
	# True 2:1 isometric diamond floor. Tiles are produced by the shared
	# GameState projection, so what is drawn and what a desk snaps to are the
	# same thing - previously the diamonds were only painted on top of a
	# rectangular grid and never actually tiled (they touched at the corners
	# and left diamond-shaped holes between them).
	var is_active_grid = GameState.is_decorating_mode or is_dragging or selected_drag_seat != -1
	var line_alpha = 0.55 if is_active_grid else 0.22
	var line_color = Color(theme()["accent"], line_alpha) if is_active_grid else Color(theme()["grid"], line_alpha)
	
	for gy in range(GameState.ISO_GRID_ROWS):
		for gx in range(GameState.ISO_GRID_COLS):
			var cell = Vector2i(gx, gy)
			var diamond_poly = GameState.get_iso_diamond_polygon(cell)
			for pt_idx in range(diamond_poly.size()):
				diamond_poly[pt_idx] += vo
			
			# Occupancy is only needed while the player is actually placing a desk.
			var occupant = GameState.get_seat_index_at_cell(cell, selected_drag_seat) if is_active_grid else -1
			var is_hovered = is_active_grid and cell == hover_cell
			
			var fill_col = Color(0.2, 0.15, 0.1, 0.03)
			if is_active_grid:
				fill_col = Color(0.96, 0.62, 0.07, 0.08)
				if occupant != -1:
					fill_col = Color(0.9, 0.25, 0.25, 0.18)   # tile already taken
				if is_hovered:
					fill_col = Color(0.9, 0.25, 0.25, 0.38) if occupant != -1 else Color(0.2, 0.95, 0.6, 0.38)
			draw_colored_polygon(diamond_poly, fill_col)
			
			var diamond_loop = diamond_poly.duplicate()
			diamond_loop.append(diamond_poly[0])
			var outline = line_color
			var thickness = 1.4 if is_active_grid else 1.0
			if is_hovered:
				outline = Color(1.0, 0.35, 0.35) if occupant != -1 else Color(0.2, 1.0, 0.6)
				thickness = 3.0
			draw_polyline(diamond_loop, outline, thickness)
			
			if is_active_grid:
				var center = GameState.iso_to_screen(cell) + vo
				draw_circle(center, 2.0, Color(0.2, 0.8, 1.0, 0.45))

func draw_integrated_multi_room_layout(w: float, h: float) -> void:
	var vo = view_offset
	# ----------------------------------------------------
	# ROOM 1: 📖 메인 집중 열공 방 (Main Focus Study Room)
	# ----------------------------------------------------
	var th2 = theme()
	var room1_rect = Rect2(30 + vo.x, 20 + vo.y, 930, h - 40)
	draw_rect(room1_rect, th2["panel"], true)
	
	# Room 1 Header Banner
	var r1_banner = Rect2(40 + vo.x, 30 + vo.y, 290, 32)
	draw_rect(r1_banner, Color(th2["wall"], 0.95), true)
	draw_rect(r1_banner, Color(th2["accent"], 0.5), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(52 + vo.x, 52 + vo.y), th2["room_name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, th2["accent"])

	# Render 2.5D Atmospheric Weather Banner & Ambient Window Lighting
	var weather_info = GameState.get_weather_info()
	var w_banner = Rect2(320 + vo.x, 30 + vo.y, 380, 32)
	draw_rect(w_banner, Color(0.10, 0.12, 0.18, 0.95), true)
	draw_rect(w_banner, weather_info["ambient_color"], false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(330 + vo.x, 52 + vo.y), "%s (+%d%% 매출/몰입)" % [weather_info["weather_name"], int(weather_info["coffee_craving_bonus"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, weather_info["ambient_color"])

	# ----------------------------------------------------
	# ROOM 2: ☕ 카페테리아 & 힐링 라운지 방 (Lounge & Coffee Bar)
	# ----------------------------------------------------
	var room2_rect = Rect2(980 + vo.x, 20 + vo.y, w - 1000, 240)
	draw_rect(room2_rect, th2["panel"], true)
	
	# Room 2 Header Banner
	var r2_banner = Rect2(990 + vo.x, 30 + vo.y, 250, 32)
	draw_rect(r2_banner, Color(th2["wall"], 0.95), true)
	draw_rect(r2_banner, Color(th2["accent"], 0.5), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(1002 + vo.x, 52 + vo.y), th2["lounge_name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.1, 0.8, 0.4))
	
	# Render the Coffee Bar as actual furniture (counter run, espresso machine,
	# pastry case, stools, back shelf) instead of one flat pasted photo.
	draw_lounge_bar()
	draw_string(ThemeDB.fallback_font, Vector2(992 + vo.x, 160 + vo.y), th2["bar_label"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.80, 0.72))

	# Today's bakery stock on an A-frame chalkboard rather than a flat strip.
	var board_base = Vector2(1035, 248) + vo
	draw_prop("menu_board", board_base, 1.15)
	var board_r = menu_board_rect(board_base, 1.15)
	var c_cnt = GameState.bakery_stock.get("cheesecake", 0)
	var r_cnt = GameState.bakery_stock.get("croissant", 0)
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(8, 17), th2["menu_title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.95, 0.88, 0.70))
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(8, 33), "🍰 치즈케이크 x%d" % c_cnt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.85, 0.9))
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(8, 47), "🥐 크로와상 x%d" % r_cnt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.90, 0.78))

	# Render 2.5D QTE Restock Timing Meter Overlay if active
	if GameState.is_qte_mini_game_active:
		var qte_rect = Rect2(995 + vo.x, 206 + vo.y, 240, 42)
		draw_rect(qte_rect, Color(0.08, 0.06, 0.12, 0.95), true)
		draw_rect(qte_rect, Color(1.0, 0.8, 0.2), false, 2.0)
		
		# Sweet-spot target zone
		var target_x = qte_rect.position.x + qte_rect.size.x * 0.85
		draw_rect(Rect2(target_x - 15, qte_rect.position.y + 4, 30, qte_rect.size.y - 8), Color(0.2, 0.9, 0.5, 0.7), true)
		draw_string(ThemeDB.fallback_font, qte_rect.position + Vector2(8, 26), "🍰 핫타임 QTE! PERFECT 존 타격!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.85, 0.3))

	# Two lounge tables, built as furniture rather than emoji on a circle.
	draw_prop("round_table", Vector2(1163, 222) + vo, 0.55)
	draw_prop("plant", Vector2(1243, 238) + vo, 0.46)

	# Render Human Barista Staff Sprite in Room 2 Lounge
	if staff_barista_texture != null:
		draw_character_shadow(Vector2(1036, 146) + vo, 34.0)
		draw_character(staff_barista_texture, "staff_barista", Vector2(1036, 146) + vo, 66.0)
		draw_string(ThemeDB.fallback_font, Vector2(992 + vo.x, 92 + vo.y), "☕ 바리스타 민서", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.1, 0.8, 0.4))

	# ----------------------------------------------------
	# ROOM 3: 🔑 프런트 & 스마트 사물함 방 (Front & Lockers)
	# ----------------------------------------------------
	var room3_rect = Rect2(980 + vo.x, 275 + vo.y, w - 1000, h - 295)
	draw_rect(room3_rect, th2["panel"], true)
	
	# Room 3 Header Banner
	var r3_banner = Rect2(990 + vo.x, 285 + vo.y, 250, 32)
	draw_rect(r3_banner, Color(th2["wall"], 0.95), true)
	draw_rect(r3_banner, Color(th2["accent"], 0.5), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(1002 + vo.x, 307 + vo.y), th2["front_name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.8, 0.4, 0.9))

	# Two isometric locker banks standing against the wall, numbered 1-8, with
	# keypad LEDs and one door left open - not a grid of flat boxes.
	var front_style = th2["front_style"]
	if front_style == "garden":
		# A rooftop has no front desk or lockers - it has planting beds.
		draw_prop("planter", Vector2(1048, 392) + vo, 0.78)
		draw_prop("parasol", Vector2(1160, 418) + vo, 0.70)
		draw_prop("planter", Vector2(1078, 470) + vo, 0.78)
		draw_prop("plant", Vector2(1218, 388) + vo, 0.62)
		draw_prop("sofa", Vector2(1180, 506) + vo, 0.62)
		draw_prop("bin", Vector2(1250, 478) + vo, 0.66)
	else:
		_prop_locker_bank(Vector2(1040, 398) + vo, 0.95, 1)
		_prop_locker_bank(Vector2(1118, 437) + vo, 0.95, 5)
		draw_string(ThemeDB.fallback_font, Vector2(998 + vo.x, 350 + vo.y),
			"🔑 대여중 %d / %d칸   임대수익 +%d₩/초" % [GameState.lockers_rented,
			max(GameState.get_locker_capacity(), 8), int(GameState.get_locker_rent_rate())],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, th2["accent"])
		draw_prop("umbrella_stand", Vector2(1218, 388) + vo, 0.85)
		draw_prop("plant", Vector2(1008, 462) + vo, 0.60)

	# Glass Door Archways Connecting Rooms
	draw_rect(Rect2(960 + vo.x, 110 + vo.y, 20, 60), Color(0.2, 0.8, 1.0, 0.8), true)
	draw_string(ThemeDB.fallback_font, Vector2(962 + vo.x, 145 + vo.y), "🚪", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	draw_rect(Rect2(960 + vo.x, 360 + vo.y, 20, 60), Color(0.2, 0.8, 1.0, 0.8), true)
	draw_string(ThemeDB.fallback_font, Vector2(962 + vo.x, 395 + vo.y), "🚪", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Reception counter and the entry speed gates
	# Everything stays above y=555: the CafeView is only 566px tall, so anything
	# lower disappears behind the bottom action bar.
	if front_style == "front":
		draw_prop("reception", Vector2(1050, 500) + vo, 0.85)
		draw_string(ThemeDB.fallback_font, Vector2(998 + vo.x, 526 + vo.y), "🛎️ 무인 프런트 키오스크", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.4, 0.9))
		draw_prop("speed_gate", GameState.ENTRANCE_POS + Vector2(-16, -30) + vo, 0.9)
		draw_string(ThemeDB.fallback_font, Vector2(1136 + vo.x, 522 + vo.y), "🚪 스마트 출입 게이트", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.06, 0.72, 0.5))
	elif front_style == "vip":
		draw_prop("sofa", Vector2(1070, 500) + vo, 0.72)
		draw_prop("floor_lamp", Vector2(1168, 480) + vo, 0.72)
		draw_string(ThemeDB.fallback_font, Vector2(998 + vo.x, 536 + vo.y), "🥂 회원 전용 라운지 좌석", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, th2["accent"])
	else:
		draw_string(ThemeDB.fallback_font, Vector2(998 + vo.x, 548 + vo.y), "🌿 야외 화단 & 테라스 벤치", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, th2["accent"])

	# ----------------------------------------------------
	# Draw Desks & Booths inside ROOM 1 (Main Focus Study Room)
	# ----------------------------------------------------
	# Rug first, then the back wall fixtures, then the desks, then the fixtures
	# that stand in front of them - one consistent painter's order for the room.
	draw_floor_rug(Vector2i(1, 1), Vector2i(4, 4), Color(0.26, 0.18, 0.13, 0.40))
	draw_room1_props(true)

	# Painter's algorithm over the isometric diagonal (back tiles first)
	var seat_indices = get_seats_in_depth_order()
	
	# Ghost preview of where the dragged desk will land
	if is_dragging and selected_drag_seat != -1 and GameState.is_iso_cell_in_bounds(hover_cell):
		var ghost_size = get_desk_sprite_size(selected_drag_seat)
		var ghost_center = GameState.iso_to_screen(hover_cell) + vo
		var ghost_bottom = ghost_center.y + GameState.ISO_TILE_HEIGHT * 0.5 + ghost_size.y * 0.09
		var ghost_rect = Rect2(Vector2(ghost_center.x - ghost_size.x * 0.5, ghost_bottom - ghost_size.y), ghost_size)
		var ghost_blocked = GameState.get_seat_index_at_cell(hover_cell, selected_drag_seat) != -1
		var ghost_col = Color(0.9, 0.25, 0.25, 0.25) if ghost_blocked else Color(0.2, 0.95, 0.6, 0.25)
		draw_rect(ghost_rect, ghost_col, true)
		draw_rect(ghost_rect, Color(1.0, 0.4, 0.4, 0.9) if ghost_blocked else Color(0.2, 1.0, 0.6, 0.9), false, 2.0)
	
	for i in seat_indices:
		var iso_cell = GameState.get_seat_cell(i)
		var tile_center = GameState.iso_to_screen(iso_cell) + vo
		var is_booth = i >= GameState.upgrades["open_seats"]["level"] * 3
		var sprite_size = get_desk_sprite_size(i)
		var cell_w = sprite_size.x
		var cell_h = sprite_size.y
		
		# Desk art anchored bottom-centre on its isometric floor tile
		var seat_pos = get_desk_rect(i).position + vo
		
		var desk_color = Color(0.18, 0.14, 0.12, 0.85) if not is_booth else Color(0.15, 0.12, 0.18, 0.85)
		var border_color = Color(0.96, 0.62, 0.07) if not is_booth else Color(0.8, 0.4, 0.9)
		
		var desk_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		# Ground shadow sits on the isometric tile centre, not on the sprite rect
		var shadow_center = tile_center
		var shadow_radius_x = GameState.ISO_TILE_WIDTH * 0.5
		var shadow_radius_y = GameState.ISO_TILE_HEIGHT * 0.5
		
		# Ground Shadow Base Ellipse Polygon (부드러운 지면 그림자 영역)
		var shadow_points = PackedVector2Array()
		var shadow_num_pts = 16
		for pt_idx in range(shadow_num_pts):
			var angle = (float(pt_idx) / shadow_num_pts) * TAU
			var pt = shadow_center + Vector2(cos(angle) * (shadow_radius_x * 0.9), sin(angle) * (shadow_radius_y * 0.9))
			shadow_points.append(pt)
		
		# Draw ambient ground contact shadow (soft ambient shadow underneath desk base)
		draw_colored_polygon(shadow_points, Color(0.02, 0.015, 0.01, 0.42))
		
		# 2.5D Isometric Ground Tile Footprint Polygon (바닥 배치 가이드 영역)
		var footprint_poly = GameState.get_iso_diamond_polygon(iso_cell)
		for fp_idx in range(footprint_poly.size()):
			footprint_poly[fp_idx] += vo
		
		if GameState.is_decorating_mode or i == selected_drag_seat:
			# Highlight active ground footprint zone in decorating/drag mode
			var fp_color = Color(0.2, 0.9, 0.5, 0.32) if i == selected_drag_seat else Color(0.96, 0.62, 0.07, 0.22)
			var fp_outline = Color(0.2, 1.0, 0.5, 0.9) if i == selected_drag_seat else Color(0.96, 0.62, 0.07, 0.75)
			draw_colored_polygon(footprint_poly, fp_color)
			var fp_loop = footprint_poly.duplicate()
			fp_loop.append(footprint_poly[0])
			draw_polyline(fp_loop, fp_outline, 2.0)
			
			# Draw ground footprint crosshairs/guide lines
			draw_line(shadow_center + Vector2(-shadow_radius_x, 0), shadow_center + Vector2(shadow_radius_x, 0), fp_outline * Color(1,1,1,0.5), 1.0)
			draw_line(shadow_center + Vector2(0, -shadow_radius_y), shadow_center + Vector2(0, shadow_radius_y), fp_outline * Color(1,1,1,0.5), 1.0)
		else:
			# Subtle ambient footprint outline on floor tile
			var ambient_outline = Color(0.35, 0.28, 0.20, 0.30)
			var fp_loop = footprint_poly.duplicate()
			fp_loop.append(footprint_poly[0])
			draw_polyline(fp_loop, ambient_outline, 1.2)

		# 2.5D Seamless Connected Desk Tops & Continuous Partitions (Smart Autotiling)
		var conn_mask = GameState.get_seat_connectivity_mask(i)
		if conn_mask["right"]:
			# Draw smooth wooden bridge connecting right neighbor (Seamless continuous desk top)
			var bridge_top = Rect2(seat_pos.x + cell_w - 6, seat_pos.y + 12, 16, cell_h - 24)
			draw_rect(bridge_top, Color(0.38, 0.28, 0.20, 0.95), true)
			draw_rect(bridge_top, Color(0.96, 0.62, 0.07, 0.4), false, 1.0)
			var part_bridge = Rect2(seat_pos.x + cell_w - 6, seat_pos.y, 16, 14)
			draw_rect(part_bridge, Color(0.26, 0.20, 0.16, 0.98), true)
			draw_rect(part_bridge, border_color, false, 1.0)
		if conn_mask["bottom"]:
			var v_bridge = Rect2(seat_pos.x + 8, seat_pos.y + cell_h - 4, cell_w - 16, 10)
			draw_rect(v_bridge, Color(0.24, 0.18, 0.14, 0.92), true)
			draw_rect(v_bridge, border_color * Color(1,1,1,0.5), false, 1.0)

		# 1. Render Each Seat with its Original 2.5D Desk Art Asset (Clean Grid Order, No Image Swapping!)
		var drawn_tex = false
		var tex_draw_rect = Rect2(seat_pos.x, seat_pos.y, cell_w, cell_h)
		
		if is_booth and desk_booth_texture != null:
			draw_texture_rect(desk_booth_texture, tex_draw_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true
		elif not is_booth and desk_vip_texture != null and i % 2 == 1:
			draw_texture_rect(desk_vip_texture, tex_draw_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true
		elif not is_booth and desk_open_texture != null:
			draw_texture_rect(desk_open_texture, tex_draw_rect, false, Color(1, 1, 1, 0.98))
			drawn_tex = true

		if not drawn_tex:
			# High-Quality 2.5D Vector Fallback with 3D Bevel Depth
			draw_rect(desk_rect, Color(0.32, 0.22, 0.16, 0.95), true)
			draw_rect(desk_rect, border_color, false, 2.5)
			var mat_rect = Rect2(desk_rect.position.x + 10, desk_rect.position.y + 10, cell_w - 20, cell_h - 20)
			draw_rect(mat_rect, Color(0.18, 0.14, 0.12, 0.9), true)
			draw_rect(mat_rect, Color(0.4, 0.3, 0.2), false, 1.0)
			var part_rect = Rect2(desk_rect.position.x, desk_rect.position.y, cell_w, 14)
			draw_rect(part_rect, Color(0.24, 0.18, 0.14), true)
			draw_rect(part_rect, border_color, false, 1.0)
			var study_icon = "💻" if not is_booth else "🖥️"
			draw_string(ThemeDB.fallback_font, desk_rect.position + Vector2(cell_w * 0.4, cell_h * 0.58), study_icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
			var chair_rect = Rect2(desk_rect.position.x + cell_w * 0.3, desk_rect.position.y + cell_h + 2, cell_w * 0.4, 16)
			draw_rect(chair_rect, Color(0.15, 0.12, 0.18, 0.95), true)
			draw_rect(chair_rect, border_color, false, 1.5)
			draw_string(ThemeDB.fallback_font, chair_rect.position + Vector2(cell_w * 0.1, 12), "🪑", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)

		if i == selected_drag_seat:
			draw_rect(desk_rect, Color(0.2, 0.9, 0.5, 0.35), true)
			draw_rect(desk_rect, Color(0.2, 1.0, 0.5), false, 3.0)
		
		# Short tag above the desk; full names overlapped every desk behind them
		# once the desks were packed onto real isometric tiles.
		var label = "🔒#%d" % (i + 1) if is_booth else "#%d" % (i + 1)
		draw_string(ThemeDB.fallback_font, Vector2(tile_center.x - 30, seat_pos.y - 6), label, HORIZONTAL_ALIGNMENT_CENTER, 60, 12, Color(0.8, 0.8, 0.75))
		
		# Draw Desk Drag Handle & Rotation Controls in Decorating Mode
		if GameState.is_decorating_mode:
			var tag_rect = Rect2(tile_center.x - 30, tile_center.y - 9, 60, 18)
			draw_rect(tag_rect, Color(0.2, 0.8, 0.4, 0.9) if i == selected_drag_seat else Color(0.1, 0.6, 0.9, 0.85), true)
			var tag_text = "🧩 이동중" if i == selected_drag_seat else "◇%d,%d" % [iso_cell.x, iso_cell.y]
			draw_string(ThemeDB.fallback_font, tag_rect.position + Vector2(0, 13), tag_text, HORIZONTAL_ALIGNMENT_CENTER, 60, 11, Color.WHITE)
		
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

	# Fixtures standing in front of / beside the desk block
	draw_room1_props(false)

	for c in GameState.active_customers:
		var raw_pos = c["pos"]
		var draw_pos = raw_pos + view_offset
		var c_type = c["type"]
		
		# Render high-res 2D PNG Character Sprites
		var char_tex = student_texture
		if c_type == "developer":
			char_tex = developer_texture if developer_texture else student_texture
			
		if char_tex != null:
			draw_character_shadow(draw_pos, 34.0)
			draw_character(char_tex, "customer_developer" if c_type == "developer" else "customer_student",
				draw_pos, 62.0)
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
			
			# Render 2.5D Student Mentoring Diagnosis Badge if active
			if GameState.student_mentoring_records.has(c["id"]):
				var m_rec = GameState.student_mentoring_records[c["id"]]
				draw_string(ThemeDB.fallback_font, draw_pos + Vector2(-45, -82), "🎓 1:1 멘토링: %s" % m_rec["rank_title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.2))
			
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
		var c_state = mgr.get("state", "IDLE")
		var c_bounce = sin(steam_time * 12.0) * (4.0 if c_state == "WALKING" else 1.5)
		var c_render = c_pos + Vector2(0, c_bounce)
		
		# Modern Store Manager character visuals (apron, tablet & smart badge)
		if staff_cleaner_texture != null:
			draw_character_shadow(c_render, 36.0)
			draw_character(staff_cleaner_texture, "staff_cleaner", c_render, 66.0)
		else:
			# Modern Store Manager Vector Drawing
			draw_circle(c_render + Vector2(0, -32), 14.0, Color(0.96, 0.82, 0.72)) # Face
			draw_rect(Rect2(c_render.x - 14, c_render.y - 18, 28, 24), Color(0.12, 0.22, 0.38), true) # Navy Uniform
			draw_rect(Rect2(c_render.x - 10, c_render.y - 14, 20, 20), Color(0.96, 0.62, 0.07, 0.9), true) # Smart Apron
			draw_string(ThemeDB.fallback_font, c_render + Vector2(-6, -26), "📱", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE) # Smart Tablet
			
		var mgr_label = "✨ " + mgr["name"]
		draw_string(ThemeDB.fallback_font, c_render + Vector2(-48, -48), mgr_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.96, 0.62, 0.07))
		
		# Action status bubbles above Store Manager
		if c_state == "CLEANING":
			var bubble_r = Rect2(c_render.x - 65, c_render.y - 75, 130, 22)
			draw_rect(bubble_r, Color(0.1, 0.12, 0.18, 0.95), true)
			draw_rect(bubble_r, Color(0.2, 0.9, 0.5), false, 1.5)
			draw_string(ThemeDB.fallback_font, bubble_r.position + Vector2(8, 15), "✨ 쓱싹 소독 정돈 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.95, 0.6))
			
			# Sparkling cleaning particles on target desk
			var t_seat = mgr.get("clean_target_seat", -1)
			if t_seat != -1:
				var s_pos = GameState.get_seat_position(t_seat)
				draw_circle(s_pos + Vector2(50, 40), 12.0 + sin(steam_time * 20.0) * 4.0, Color(0.2, 0.9, 0.5, 0.4))
				draw_string(ThemeDB.fallback_font, s_pos + Vector2(30, 45), "✨🧼✨", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		elif c_state == "WALKING":
			var bubble_r = Rect2(c_render.x - 65, c_render.y - 75, 130, 22)
			draw_rect(bubble_r, Color(0.1, 0.12, 0.18, 0.95), true)
			draw_rect(bubble_r, Color(0.96, 0.62, 0.07), false, 1.5)
			draw_string(ThemeDB.fallback_font, bubble_r.position + Vector2(8, 15), "🚶 소독동선 이동 중...", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.96, 0.62, 0.07))

	# Render Mascot Cat 'Navi' wandering in Room 1 (1F Only)
	if GameState.current_floor == 1:
		var n_pos = GameState.navi_pos
		var n_bounce = abs(sin(steam_time * 8.0)) * 6.0
		var n_render = n_pos + Vector2(0, -n_bounce)
		
		if staff_cat_navi_texture != null:
			draw_character_shadow(n_render, 40.0)
			draw_character(staff_cat_navi_texture, "staff_cat_navi", n_render, 52.0)
		else:
			var n_bg = Rect2(n_render.x - 22, n_render.y - 20, 44, 40)
			draw_rect(n_bg, Color(0.12, 0.1, 0.08, 0.85), true)
			draw_rect(n_bg, Color(1.0, 0.6, 0.8), false, 1.5)
			draw_string(ThemeDB.fallback_font, n_render + Vector2(-12, 8), "🐱", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
		var cat_label = "🐱 나비 (마스코트)" if not GameState.is_cat_buff_active() else "🐱 나비 (❤️ 집중+20%)"
		draw_string(ThemeDB.fallback_font, n_render + Vector2(-45, -32), cat_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.6, 0.8))

	# Render Clean Top Right Control Buttons
	var btn_x = 706.0
	var heatmap_btn_rect = Rect2(btn_x, 50, 160, 36)
	var btn_bg = Color(0.95, 0.4, 0.1, 0.95) if GameState.is_heatmap_mode else Color(0.15, 0.18, 0.22, 0.9)
	draw_rect(heatmap_btn_rect, btn_bg, true)
	draw_rect(heatmap_btn_rect, Color(1.0, 0.7, 0.2), false, 2.0)
	var btn_label = "🔥 히트맵 ON" if GameState.is_heatmap_mode else "🔥 히트맵 분석"
	draw_string(ThemeDB.fallback_font, heatmap_btn_rect.position + Vector2(24, 24), btn_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

	var tech_btn_x = btn_x
	var tech_btn_rect = Rect2(tech_btn_x, 8, 210, 36)
	draw_rect(tech_btn_rect, Color(0.1, 0.7, 0.75, 0.95), true)
	draw_rect(tech_btn_rect, Color(0.2, 0.95, 0.85), false, 2.0)
	draw_string(ThemeDB.fallback_font, tech_btn_rect.position + Vector2(15, 24), "🛠️ 매장 설비 관제실", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
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
		var hud_rect = Rect2(btn_x, 92, 200, 105)
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


# ----------------------------------------------------
# 2.5D Isometric Desk Placement Helpers
# ----------------------------------------------------

# The desk art is square 1024x1024 isometric pixel art, so it is drawn into a
# square rect - the old non-square rect stretched every desk out of proportion.
# 1.2 x tile width makes the furniture's own footprint cover roughly one tile.
# ══════════════════════════════════════════════════════════════
# 🧍 CHARACTER SPRITES
# The character art is full-body, roughly 1:2 tall, sitting inside a 1024²
# canvas with 30-60% empty padding. It was being blitted as the whole square
# texture into a square 48x48 rect, which squashed every character to half
# height and shrank them to a blob inside their own padding. These are the
# measured opaque bounds of each file; the sprite is drawn from that region at
# its true aspect and anchored at the feet.
# ══════════════════════════════════════════════════════════════

const CHAR_CONTENT: Dictionary = {
	"customer_student":   Rect2(317, 65, 399, 922),
	"customer_developer": Rect2(217, 63, 544, 940),
	"staff_barista":      Rect2(275, 87, 396, 863),
	"staff_cleaner":      Rect2(255, 52, 488, 919),
	"staff_cat_navi":     Rect2(210, 157, 692, 780)
}

# Draws a character standing on `feet`, `height` pixels tall, keeping the art's
# own proportions. Returns the rect actually drawn so callers can hang labels.
func draw_character(tex: Texture2D, key: String, feet: Vector2, height: float, tint: Color = Color.WHITE) -> Rect2:
	if tex == null:
		return Rect2(feet, Vector2.ZERO)
	var src: Rect2 = CHAR_CONTENT.get(key, Rect2(Vector2.ZERO, tex.get_size()))
	var aspect = src.size.x / src.size.y
	var size = Vector2(height * aspect, height)
	var dest = Rect2(feet - Vector2(size.x * 0.5, size.y), size)
	draw_texture_rect_region(tex, dest, src, tint)
	return dest

# Soft contact shadow so a character reads as standing on the floor.
func draw_character_shadow(feet: Vector2, width: float) -> void:
	fill_ellipse(feet, width * 0.42, width * 0.18, Color(0.02, 0.015, 0.01, 0.34))

# ══════════════════════════════════════════════════════════════
# 🏢 FLOOR THEMES
# Every floor used to draw the exact same room - same walls, same floor, same
# desks, same side panels - so 1F/2F/3F were indistinguishable. Each floor now
# owns its palette, its architecture and its own set of desks.
# ══════════════════════════════════════════════════════════════

const FLOOR_THEMES: Dictionary = {
	1: {
		"room_name": "📖 메인 집중 열공 방 (Focus Room)",
		"accent": Color(0.96, 0.62, 0.07),
		"wall": Color(0.15, 0.12, 0.10),
		"wall_line": Color(0.10, 0.08, 0.06),
		"wall_hi": Color(0.24, 0.18, 0.14),
		"floor": Color(0.22, 0.15, 0.10, 0.38),
		"floor_line": Color(0.12, 0.08, 0.05),
		"grid": Color(0.55, 0.42, 0.30),
		"panel": Color(0.12, 0.10, 0.08, 0.45),
		"style": "wood",
		"lounge_name": "☕ 힐링 라운지 & 커피바 (Lounge)",
		"bar_label": "☕ 에스프레소 & 로스팅 바",
		"menu_title": "☕ TODAY'S BAKE",
		"front_name": "🔑 프런트 & 스마트 사물함 (Front)",
		"front_style": "front"
	},
	2: {
		"room_name": "🔑 노블리스 프라이빗 부스 (Noble Booth)",
		"accent": Color(0.85, 0.70, 0.36),
		"wall": Color(0.13, 0.09, 0.13),
		"wall_line": Color(0.08, 0.05, 0.09),
		"wall_hi": Color(0.32, 0.22, 0.30),
		"floor": Color(0.20, 0.10, 0.14, 0.52),
		"floor_line": Color(0.12, 0.06, 0.09),
		"grid": Color(0.66, 0.50, 0.62),
		"panel": Color(0.14, 0.09, 0.14, 0.5),
		"style": "carpet",
		"lounge_name": "🍵 티 라운지 & 북 큐레이션 (Tea)",
		"bar_label": "🍵 핸드드립 & 티 스테이션",
		"menu_title": "🍵 TODAY'S TEA",
		"front_name": "🔒 회원 전용 사물함 & 라운지 (VIP)",
		"front_style": "vip"
	},
	3: {
		"room_name": "🌇 루프탑 테라스 라운지 (Rooftop)",
		"accent": Color(0.35, 0.85, 0.72),
		"wall": Color(0.10, 0.14, 0.20),
		"wall_line": Color(0.08, 0.10, 0.15),
		"wall_hi": Color(0.30, 0.40, 0.48),
		"floor": Color(0.30, 0.21, 0.13, 0.55),
		"floor_line": Color(0.16, 0.10, 0.06),
		"grid": Color(0.60, 0.54, 0.38),
		"panel": Color(0.09, 0.13, 0.15, 0.45),
		"style": "deck",
		"lounge_name": "🍹 루프탑 가든 바 (Rooftop Bar)",
		"bar_label": "🍹 콜드브루 & 에이드 바",
		"menu_title": "🍹 TODAY'S COLD",
		"front_name": "🌿 테라스 가든 (Terrace Garden)",
		"front_style": "garden"
	}
}

func theme() -> Dictionary:
	return FLOOR_THEMES.get(GameState.current_floor, FLOOR_THEMES[1])

# Sky behind the rooftop: the upper band is open air, not a wall.
func draw_rooftop_sky(w: float, horizon: float) -> void:
	var top = Color(0.10, 0.18, 0.34)
	var bottom = Color(0.38, 0.50, 0.62)
	if GameState.time_of_day == "DUSK":
		top = Color(0.22, 0.12, 0.30); bottom = Color(0.95, 0.48, 0.24)
	elif GameState.time_of_day == "NIGHT":
		top = Color(0.03, 0.04, 0.14); bottom = Color(0.10, 0.12, 0.30)
	else:
		top = Color(0.26, 0.52, 0.82); bottom = Color(0.68, 0.82, 0.92)
	var bands = 18
	for b in range(bands):
		var t = float(b) / bands
		draw_rect(Rect2(0, horizon * t, w, horizon / bands + 1.0), top.lerp(bottom, t), true)

	if GameState.time_of_day == "NIGHT":
		for st in range(40):
			var sx = fmod(st * 137.0, w)
			var sy = fmod(st * 61.0, horizon * 0.7)
			draw_circle(Vector2(sx, sy), 1.2, Color(1, 1, 1, 0.5 + 0.4 * sin(steam_time + st)))

	# City skyline silhouette along the horizon
	var sky_col = Color(0.06, 0.08, 0.14, 0.85)
	var bx = 0.0
	var i = 0
	while bx < w:
		var bw = 38.0 + fmod(i * 47.0, 54.0)
		var bh = 40.0 + fmod(i * 89.0, 96.0)
		draw_rect(Rect2(bx, horizon - bh, bw - 5.0, bh), sky_col, true)
		for wy in range(int(bh / 18.0)):
			for wx in range(int(bw / 16.0)):
				if fmod((i + wx * 3 + wy * 7) * 13.0, 5.0) < 2.0:
					draw_rect(Rect2(bx + 5 + wx * 16, horizon - bh + 8 + wy * 18, 5, 7),
						Color(1.0, 0.85, 0.45, 0.5), true)
		bx += bw
		i += 1

# Glass balustrade around the rooftop deck, plus a run of festoon lights.
func draw_rooftop_railing(w: float, horizon: float) -> void:
	draw_rect(Rect2(0, horizon - 54, w, 54), Color(0.55, 0.78, 0.82, 0.13), true)
	draw_line(Vector2(0, horizon - 54), Vector2(w, horizon - 54), Color(0.75, 0.88, 0.90, 0.75), 3.0)
	draw_line(Vector2(0, horizon), Vector2(w, horizon), Color(0.30, 0.34, 0.36, 0.9), 4.0)
	for px in range(int(w / 78.0) + 1):
		var x = px * 78.0
		draw_line(Vector2(x, horizon - 54), Vector2(x, horizon), Color(0.72, 0.84, 0.86, 0.55), 2.0)

	# festoon lights strung above the deck
	var span = 96.0
	for k in range(int(w / span) + 1):
		var x0 = k * span
		var x1 = x0 + span
		var sag = 26.0
		var prev = Vector2(x0, 26)
		for seg in range(1, 9):
			var t = float(seg) / 8.0
			var pt = Vector2(lerp(x0, x1, t), 26 + sin(t * PI) * sag)
			draw_line(prev, pt, Color(0.25, 0.22, 0.18, 0.9), 1.6)
			prev = pt
		for bulb in range(1, 4):
			var tb = float(bulb) / 4.0
			var bp = Vector2(lerp(x0, x1, tb), 26 + sin(tb * PI) * sag + 5)
			draw_circle(bp, 3.6, Color(1.0, 0.86, 0.50, 0.95))
			draw_circle(bp, 8.0, Color(1.0, 0.82, 0.40, 0.10))

# ══════════════════════════════════════════════════════════════
# 🪑 ISOMETRIC PROP KIT
# Every fixture in the cafe is built from these solids instead of being pasted
# in as a flat rectangle or one big photo, so props share the floor's 2:1
# projection and a single light direction (top brightest, left lit, right in
# shade). That is what makes the room read as a place rather than a collage.
# ══════════════════════════════════════════════════════════════

const FACE_LEFT_SHADE: float = 0.74
const FACE_RIGHT_SHADE: float = 0.52

func shade(col: Color, f: float) -> Color:
	return Color(col.r * f, col.g * f, col.b * f, col.a)

func iso_diamond(center: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -hh), center + Vector2(hw, 0),
		center + Vector2(0, hh), center + Vector2(-hw, 0)
	])

func stroke_poly(poly: PackedVector2Array, col: Color, width: float = 1.0) -> void:
	var loop = poly.duplicate()
	loop.append(poly[0])
	draw_polyline(loop, col, width)

# A box standing on the floor: footprint diamond extruded upward.
func draw_iso_prism(base: Vector2, hw: float, hh: float, height: float, col: Color, top_col: Color = Color(0, 0, 0, 0)) -> void:
	var up = Vector2(0, -height)
	var b = base + Vector2(0, hh)
	var l = base + Vector2(-hw, 0)
	var r = base + Vector2(hw, 0)
	draw_colored_polygon(PackedVector2Array([l + up, b + up, b, l]), shade(col, FACE_LEFT_SHADE))
	draw_colored_polygon(PackedVector2Array([b + up, r + up, r, b]), shade(col, FACE_RIGHT_SHADE))
	var top = iso_diamond(base + up, hw, hh)
	draw_colored_polygon(top, top_col if top_col.a > 0.0 else col)
	stroke_poly(top, shade(col, 0.4), 1.0)
	draw_line(b + up, b, shade(col, 0.35), 1.0)

func fill_ellipse(center: Vector2, rx: float, ry: float, col: Color, segments: int = 18) -> void:
	var pts = PackedVector2Array()
	for i in range(segments):
		var a = (float(i) / segments) * TAU
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)

# An upright cylinder: bins, stools, pots, table pedestals.
func draw_iso_cylinder(base: Vector2, rx: float, ry: float, height: float, col: Color) -> void:
	fill_ellipse(base, rx, ry, shade(col, 0.55))
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-rx, 0), base + Vector2(-rx, -height),
		base + Vector2(rx, -height), base + Vector2(rx, 0)
	]), shade(col, FACE_RIGHT_SHADE))
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-rx, 0), base + Vector2(-rx, -height),
		base + Vector2(-rx * 0.25, -height), base + Vector2(-rx * 0.25, 0)
	]), shade(col, FACE_LEFT_SHADE))
	fill_ellipse(base + Vector2(0, -height), rx, ry, col)

# Soft contact shadow so a prop looks planted on the floor instead of floating.
func draw_prop_shadow(base: Vector2, hw: float, hh: float) -> void:
	fill_ellipse(base, hw * 0.92, hh * 0.92, Color(0.02, 0.015, 0.01, 0.35))

# ── The furniture catalogue ───────────────────────────────────
# `s` scales a prop to the tile it stands on, so the same piece works on the
# big study-room tiles and the smaller lounge tiles.

func draw_prop(kind: String, base: Vector2, s: float = 1.0) -> void:
	match kind:
		"counter": _prop_counter(base, s)
		"counter_end": _prop_counter(base, s, true)
		"espresso": _prop_espresso(base, s)
		"display_case": _prop_display_case(base, s)
		"back_shelf": _prop_back_shelf(base, s)
		"stool": _prop_stool(base, s)
		"round_table": _prop_round_table(base, s)
		"bookshelf": _prop_bookshelf(base, s)
		"plant": _prop_plant(base, s)
		"water": _prop_water_cooler(base, s)
		"bin": _prop_bin(base, s)
		"floor_lamp": _prop_floor_lamp(base, s)
		"sofa": _prop_sofa(base, s)
		"printer": _prop_printer(base, s)
		"locker_bank": _prop_locker_bank(base, s)
		"reception": _prop_reception(base, s)
		"speed_gate": _prop_speed_gate(base, s)
		"menu_board": _prop_menu_board(base, s)
		"umbrella_stand": _prop_umbrella_stand(base, s)
		"parasol": _prop_parasol(base, s)
		"planter": _prop_planter(base, s)
		"patio_heater": _prop_patio_heater(base, s)

func _prop_counter(base: Vector2, s: float, is_end: bool = false) -> void:
	var hw = 36.0 * s
	var hh = 18.0 * s
	draw_prop_shadow(base, hw, hh)
	# Cabinet body with a lighter stone worktop on it.
	draw_iso_prism(base, hw, hh, 34.0 * s, Color(0.30, 0.21, 0.15), Color(0.44, 0.33, 0.25))
	var top = base + Vector2(0, -34.0 * s)
	draw_iso_prism(top, hw, hh, 4.0 * s, Color(0.16, 0.15, 0.16), Color(0.26, 0.25, 0.27))
	# Front panel grooves - a plain slab reads as a cardboard box.
	for g in range(2):
		var gy = -10.0 * s - g * 11.0 * s
		draw_line(base + Vector2(-hw * 0.8, gy + hh * 0.4), base + Vector2(0, gy + hh), Color(0.20, 0.14, 0.10, 0.8), 1.0)
		draw_line(base + Vector2(0, gy + hh), base + Vector2(hw * 0.8, gy + hh * 0.4), Color(0.14, 0.10, 0.07, 0.8), 1.0)
	if is_end:
		# Till + tip jar on the end section.
		var t = top + Vector2(0, -4.0 * s)
		draw_iso_prism(t + Vector2(-8 * s, 2 * s), 9 * s, 5 * s, 10 * s, Color(0.20, 0.22, 0.26))
		draw_iso_cylinder(t + Vector2(12 * s, 3 * s), 4 * s, 2 * s, 9 * s, Color(0.75, 0.72, 0.55))

func _prop_espresso(base: Vector2, s: float) -> void:
	# Sits on top of a counter, so no floor shadow.
	var hw = 22.0 * s
	var hh = 11.0 * s
	draw_iso_prism(base, hw, hh, 13.0 * s, Color(0.22, 0.22, 0.24))
	var body = base + Vector2(0, -13.0 * s)
	draw_iso_prism(body, hw * 0.92, hh * 0.92, 20.0 * s, Color(0.52, 0.13, 0.11), Color(0.72, 0.70, 0.68))
	# Group heads, steam wand and a row of warming cups.
	draw_circle(base + Vector2(-7 * s, -9 * s), 3.0 * s, Color(0.16, 0.16, 0.18))
	draw_circle(base + Vector2(6 * s, -6 * s), 3.0 * s, Color(0.16, 0.16, 0.18))
	draw_line(base + Vector2(15 * s, -14 * s), base + Vector2(17 * s, -4 * s), Color(0.80, 0.80, 0.84), 2.0 * s)
	for c in range(3):
		fill_ellipse(base + Vector2((-10 + c * 9) * s, (-34 - c * 2) * s), 3.2 * s, 1.8 * s, Color(0.90, 0.88, 0.85))

func _prop_display_case(base: Vector2, s: float) -> void:
	var hw = 34.0 * s
	var hh = 17.0 * s
	draw_prop_shadow(base, hw, hh)
	draw_iso_prism(base, hw, hh, 26.0 * s, Color(0.26, 0.19, 0.14), Color(0.34, 0.26, 0.20))
	var shelf = base + Vector2(0, -26.0 * s)
	# Cakes on the shelf, then the glass hood over them.
	var cakes = [Color(0.94, 0.80, 0.62), Color(0.86, 0.44, 0.52), Color(0.78, 0.60, 0.38)]
	for ci in range(cakes.size()):
		draw_iso_cylinder(shelf + Vector2((-16 + ci * 16) * s, (4 - ci * 3) * s), 6 * s, 3 * s, 7 * s, cakes[ci])
	draw_iso_prism(shelf, hw * 0.96, hh * 0.96, 22.0 * s, Color(0.62, 0.82, 0.90, 0.26), Color(0.75, 0.90, 0.96, 0.34))

func _prop_back_shelf(base: Vector2, s: float) -> void:
	var hw = 32.0 * s
	var hh = 16.0 * s
	var height = 62.0 * s
	draw_prop_shadow(base, hw * 0.8, hh * 0.8)
	draw_iso_prism(base, hw, hh, height, Color(0.25, 0.18, 0.13), Color(0.33, 0.24, 0.18))

	# three bays: bean sacks, syrup bottles, stacked cups - drawn on the face so
	# they stay inside the cabinet at any scale.
	var goods = [Color(0.55, 0.35, 0.20), Color(0.85, 0.85, 0.82), Color(0.35, 0.55, 0.40),
				 Color(0.72, 0.52, 0.30), Color(0.40, 0.46, 0.66)]
	for lvl in range(3):
		var t0 = 0.08 + lvl * 0.30
		var t1 = t0 + 0.24
		draw_face_quad(base, hw, hh, height, 0.08, 0.92, t0, t1, Color(0.12, 0.08, 0.06))
		for it in range(4):
			var u0 = 0.12 + it * 0.19
			var u1 = u0 + 0.15
			var gh = 0.14 + float((it + lvl) % 3) * 0.025
			var col = goods[(lvl * 2 + it) % goods.size()]
			draw_face_quad(base, hw, hh, height, u0, u1, t0, t0 + gh, col)
			draw_face_quad(base, hw, hh, height, u0 + 0.03, u1 - 0.03,
				t0 + gh * 0.55, t0 + gh * 0.72, shade(col, 1.35))
		draw_face_quad(base, hw, hh, height, 0.08, 0.92, t0 - 0.025, t0, Color(0.36, 0.26, 0.19))

func _prop_stool(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 10 * s, 5 * s)
	draw_iso_cylinder(base, 3.0 * s, 1.6 * s, 22.0 * s, Color(0.30, 0.30, 0.33))
	fill_ellipse(base + Vector2(0, -9 * s), 7.0 * s, 3.4 * s, Color(0.24, 0.24, 0.27))
	draw_iso_cylinder(base + Vector2(0, -22 * s), 11.0 * s, 5.5 * s, 5.0 * s, Color(0.46, 0.28, 0.20))

func _prop_round_table(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 22 * s, 11 * s)
	draw_iso_cylinder(base, 4.0 * s, 2.2 * s, 24.0 * s, Color(0.28, 0.22, 0.18))
	draw_iso_cylinder(base + Vector2(0, -24 * s), 21.0 * s, 10.5 * s, 4.0 * s, Color(0.48, 0.34, 0.24))
	# A drink and a slice actually left on the table.
	draw_iso_cylinder(base + Vector2(-5 * s, -27 * s), 3.5 * s, 1.8 * s, 8 * s, Color(0.92, 0.90, 0.86))
	draw_iso_prism(base + Vector2(7 * s, -26 * s), 5 * s, 2.5 * s, 5 * s, Color(0.88, 0.52, 0.56))
	# Two chairs tucked in either side.
	for side in [-1.0, 1.0]:
		var cp = base + Vector2(26 * s * side, 13 * s * side)
		draw_iso_cylinder(cp, 8.0 * s, 4.0 * s, 16.0 * s, Color(0.32, 0.26, 0.22))
		draw_iso_prism(cp + Vector2(0, -16 * s), 9 * s, 4.5 * s, 14 * s, Color(0.24, 0.24, 0.28))

# Books live ON the cabinet face. They used to be drawn as tiny free-standing
# prisms placed with floor-space offsets, so they floated in front of the shelf,
# spilled past its outline and turned into 2px slivers at play scale.
func _prop_bookshelf(base: Vector2, s: float) -> void:
	var hw = 30.0 * s
	var hh = 15.0 * s
	var height = 74.0 * s
	draw_prop_shadow(base, hw * 0.85, hh * 0.85)
	draw_iso_prism(base, hw, hh, height, Color(0.27, 0.19, 0.14), Color(0.35, 0.25, 0.19))

	var spine = [Color(0.70, 0.28, 0.24), Color(0.24, 0.42, 0.62), Color(0.72, 0.60, 0.28),
				 Color(0.32, 0.52, 0.38), Color(0.56, 0.34, 0.60), Color(0.80, 0.76, 0.68),
				 Color(0.42, 0.34, 0.66), Color(0.76, 0.46, 0.26)]
	var shelves = 4
	for k in range(shelves):
		var t0 = 0.05 + k * 0.235
		var t1 = t0 + 0.20
		# recessed bay
		draw_face_quad(base, hw, hh, height, 0.07, 0.93, t0, t1, Color(0.13, 0.09, 0.07))
		# books standing on the shelf, alternating heights and a leaning one
		var n = 7
		for bk in range(n):
			var u0 = 0.10 + bk * 0.113
			var u1 = u0 + 0.088
			var bh = 0.125 + float((bk * 5 + k * 3) % 4) * 0.018
			var col = spine[(bk + k * 3) % spine.size()]
			draw_face_quad(base, hw, hh, height, u0, u1, t0, t0 + bh, col)
			# a lighter band reads as the title strip on the spine
			draw_face_quad(base, hw, hh, height, u0 + 0.018, u1 - 0.018,
				t0 + bh * 0.62, t0 + bh * 0.74, shade(col, 1.45))
		# shelf board edge
		draw_face_quad(base, hw, hh, height, 0.07, 0.93, t0 - 0.022, t0, Color(0.38, 0.27, 0.19))

	# side stile so the carcass frames the bays
	draw_face_quad(base, hw, hh, height, 0.0, 0.07, 0.0, 1.0, Color(0.31, 0.22, 0.16))
	draw_face_quad(base, hw, hh, height, 0.93, 1.0, 0.0, 1.0, Color(0.24, 0.17, 0.12))

func _prop_plant(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 14 * s, 7 * s)
	draw_iso_cylinder(base, 11.0 * s, 5.5 * s, 18.0 * s, Color(0.62, 0.36, 0.24))
	fill_ellipse(base + Vector2(0, -18 * s), 11.0 * s, 5.5 * s, Color(0.24, 0.17, 0.12))
	# Layered fronds rather than one green blob.
	var leaf = [Vector2(0, -46), Vector2(-13, -34), Vector2(13, -36), Vector2(-7, -52), Vector2(8, -50)]
	var greens = [Color(0.18, 0.46, 0.26), Color(0.22, 0.55, 0.30), Color(0.26, 0.62, 0.34),
				  Color(0.20, 0.50, 0.28), Color(0.28, 0.66, 0.38)]
	for li in range(leaf.size()):
		fill_ellipse(base + leaf[li] * s, 10.0 * s, 7.0 * s, greens[li])
	draw_line(base + Vector2(0, -18 * s), base + Vector2(0, -42 * s), Color(0.20, 0.40, 0.22), 2.0 * s)

func _prop_water_cooler(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 14 * s, 7 * s)
	draw_iso_prism(base, 13.0 * s, 6.5 * s, 42.0 * s, Color(0.82, 0.84, 0.86), Color(0.90, 0.92, 0.94))
	draw_iso_cylinder(base + Vector2(0, -42 * s), 11.0 * s, 5.5 * s, 26.0 * s, Color(0.42, 0.70, 0.86, 0.85))
	draw_iso_prism(base + Vector2(0, -18 * s), 4.0 * s, 2.0 * s, 4.0 * s, Color(0.30, 0.46, 0.56))
	for cup in range(2):
		draw_iso_cylinder(base + Vector2((9 + cup * 5) * s, (-30 - cup * 4) * s), 2.6 * s, 1.3 * s, 5 * s, Color(0.92, 0.92, 0.90))

func _prop_bin(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 11 * s, 5.5 * s)
	draw_iso_cylinder(base, 10.0 * s, 5.0 * s, 24.0 * s, Color(0.26, 0.28, 0.30))
	fill_ellipse(base + Vector2(0, -24 * s), 10.5 * s, 5.2 * s, Color(0.18, 0.20, 0.22))
	fill_ellipse(base + Vector2(0, -25 * s), 6.0 * s, 3.0 * s, Color(0.10, 0.11, 0.12))

func _prop_floor_lamp(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 10 * s, 5 * s)
	fill_ellipse(base, 9.0 * s, 4.5 * s, Color(0.22, 0.20, 0.18))
	draw_line(base, base + Vector2(0, -64 * s), Color(0.34, 0.30, 0.26), 2.5 * s)
	var shade_top = base + Vector2(0, -78 * s)
	draw_colored_polygon(PackedVector2Array([
		shade_top + Vector2(-9 * s, 0), shade_top + Vector2(9 * s, 0),
		shade_top + Vector2(15 * s, 16 * s), shade_top + Vector2(-15 * s, 16 * s)
	]), Color(0.86, 0.72, 0.46))
	fill_ellipse(base + Vector2(0, -60 * s), 20.0 * s, 10.0 * s, Color(1.0, 0.82, 0.45, 0.12))

func _prop_sofa(base: Vector2, s: float) -> void:
	var hw = 34.0 * s
	var hh = 17.0 * s
	draw_prop_shadow(base, hw, hh)
	draw_iso_prism(base, hw, hh, 15.0 * s, Color(0.34, 0.30, 0.40), Color(0.46, 0.41, 0.54))
	draw_iso_prism(base + Vector2(-hw * 0.55, -hh * 0.45), hw * 0.42, hh * 0.42, 30.0 * s, Color(0.38, 0.34, 0.46))
	draw_iso_prism(base + Vector2(hw * 0.55, -hh * 0.45), hw * 0.42, hh * 0.42, 30.0 * s, Color(0.32, 0.28, 0.40))
	for cu in range(2):
		draw_iso_prism(base + Vector2((-12 + cu * 24) * s, (-6 + cu * 6) * s - 15 * s), 10 * s, 5 * s, 6 * s, Color(0.56, 0.48, 0.62))

func _prop_printer(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 16 * s, 8 * s)
	draw_iso_prism(base, 15.0 * s, 7.5 * s, 26.0 * s, Color(0.30, 0.31, 0.34), Color(0.40, 0.41, 0.44))
	draw_iso_prism(base + Vector2(0, -26 * s), 13.0 * s, 6.5 * s, 8.0 * s, Color(0.22, 0.23, 0.26))
	draw_colored_polygon(iso_diamond(base + Vector2(2 * s, -30 * s), 9 * s, 4.5 * s), Color(0.92, 0.92, 0.90))
	draw_circle(base + Vector2(-8 * s, -30 * s), 1.8 * s, Color(0.2, 0.9, 0.4))

# ── Drawing onto the face of a solid ──────────────────────────
# Face coordinates: u runs along the face (0 = front corner, 1 = outer corner),
# t runs up it (0 = floor, 1 = top). Quads drawn this way get the same
# foreshortening as the solid, so locker doors and gate glass sit ON the
# furniture instead of floating over it as flat rectangles.
func face_pt(base: Vector2, hw: float, hh: float, height: float, u: float, t: float, left: bool = false) -> Vector2:
	var b = base + Vector2(0, hh)
	var outer = base + Vector2(-hw, 0) if left else base + Vector2(hw, 0)
	return b.lerp(outer, u) + Vector2(0, -height * t)

func draw_face_quad(base: Vector2, hw: float, hh: float, height: float,
		u0: float, u1: float, t0: float, t1: float, col: Color, left: bool = false) -> void:
	draw_colored_polygon(PackedVector2Array([
		face_pt(base, hw, hh, height, u0, t0, left),
		face_pt(base, hw, hh, height, u1, t0, left),
		face_pt(base, hw, hh, height, u1, t1, left),
		face_pt(base, hw, hh, height, u0, t1, left)
	]), col)

func face_center(base: Vector2, hw: float, hh: float, height: float,
		u0: float, u1: float, t0: float, t1: float, left: bool = false) -> Vector2:
	return (face_pt(base, hw, hh, height, u0, t0, left) + face_pt(base, hw, hh, height, u1, t1, left)) * 0.5

# A bank of four smart lockers. `start_no` numbers the doors for the player.
func _prop_locker_bank(base: Vector2, s: float, start_no: int = 1) -> void:
	var hw = 32.0 * s
	var hh = 16.0 * s
	var height = 66.0 * s
	draw_prop_shadow(base, hw, hh)
	draw_iso_prism(base, hw, hh, height, Color(0.24, 0.21, 0.30), Color(0.32, 0.28, 0.40))
	# Doors stack two high on the right-hand face; each gets a number plate, a
	# handle and a keypad LED so the bank reads as eight real lockers.
	var cols = [[0.05, 0.49], [0.51, 0.95]]
	var rows = [[0.52, 0.95], [0.06, 0.49]]
	var n = start_no
	for r in range(rows.size()):
		for c in range(cols.size()):
			var u0 = cols[c][0]
			var u1 = cols[c][1]
			var t0 = rows[r][0]
			var t1 = rows[r][1]
			var ajar = (n == start_no + 2)   # one door left open - the bank is in use
			draw_face_quad(base, hw, hh, height, u0, u1, t0, t1,
				Color(0.12, 0.10, 0.15) if ajar else Color(0.37, 0.33, 0.47))
			var mid = face_center(base, hw, hh, height, u0, u1, t0, t1)
			if ajar:
				draw_colored_polygon(PackedVector2Array([
					face_pt(base, hw, hh, height, u1, t0), face_pt(base, hw, hh, height, u1, t1),
					face_pt(base, hw, hh, height, u1, t1) + Vector2(14 * s, -6 * s),
					face_pt(base, hw, hh, height, u1, t0) + Vector2(14 * s, -6 * s)
				]), Color(0.44, 0.40, 0.54))
			else:
				draw_line(mid + Vector2(5 * s, -1 * s), mid + Vector2(5 * s, 5 * s), Color(0.82, 0.80, 0.88), 1.6 * s)
				# LED reflects real state: green = rented, dim amber = vacant
				var rented = GameState.is_locker_rented(n)
				draw_circle(mid + Vector2(-7 * s, -5 * s), 1.5 * s,
					Color(0.25, 0.95, 0.55) if rented else Color(0.55, 0.45, 0.25))
			var plate = Rect2(mid.x - 8 * s, mid.y - 9 * s, 16 * s, 11 * s)
			draw_rect(plate, Color(0.08, 0.07, 0.11, 0.85), true)
			draw_string(ThemeDB.fallback_font, Vector2(plate.position.x, plate.position.y + 9 * s), "%d" % n,
				HORIZONTAL_ALIGNMENT_CENTER, 16 * s, int(10 * s), Color(0.90, 0.88, 0.96))
			n += 1

# Reception counter: transaction top, kiosk screen, card reader and a bell.
func _prop_reception(base: Vector2, s: float) -> void:
	var hw = 40.0 * s
	var hh = 20.0 * s
	draw_prop_shadow(base, hw, hh)
	draw_iso_prism(base, hw, hh, 36.0 * s, Color(0.30, 0.22, 0.30), Color(0.46, 0.34, 0.44))
	var top = base + Vector2(0, -36.0 * s)
	draw_iso_prism(top, hw * 1.06, hh * 1.06, 5.0 * s, Color(0.18, 0.16, 0.20), Color(0.30, 0.27, 0.34))
	# front panel inlay
	draw_face_quad(base, hw, hh, 36.0 * s, 0.12, 0.88, 0.15, 0.85, Color(0.24, 0.18, 0.26))
	var deck = top + Vector2(0, -5.0 * s)
	# kiosk monitor, angled toward the customer
	draw_iso_prism(deck + Vector2(-12 * s, 2 * s), 4 * s, 2 * s, 6 * s, Color(0.22, 0.22, 0.26))
	draw_colored_polygon(PackedVector2Array([
		deck + Vector2(-24 * s, -6 * s), deck + Vector2(0 * s, -18 * s),
		deck + Vector2(0 * s, -34 * s), deck + Vector2(-24 * s, -22 * s)
	]), Color(0.16, 0.52, 0.62))
	draw_colored_polygon(PackedVector2Array([
		deck + Vector2(-21 * s, -9 * s), deck + Vector2(-3 * s, -18 * s),
		deck + Vector2(-3 * s, -31 * s), deck + Vector2(-21 * s, -22 * s)
	]), Color(0.35, 0.85, 0.95, 0.85))
	# card reader + call bell
	draw_iso_prism(deck + Vector2(14 * s, 5 * s), 5 * s, 2.5 * s, 7 * s, Color(0.26, 0.27, 0.32))
	fill_ellipse(deck + Vector2(26 * s, 9 * s), 5 * s, 3 * s, Color(0.72, 0.68, 0.35))
	fill_ellipse(deck + Vector2(26 * s, 6 * s), 4.4 * s, 3.4 * s, Color(0.88, 0.82, 0.42))

# Speed gates: two pedestals with glass flaps and a walk-through indicator.
func _prop_speed_gate(base: Vector2, s: float) -> void:
	var span = Vector2(46 * s, 23 * s)   # offset to the second pedestal
	for side in range(2):
		var p = base + span * float(side)
		var hw = 11.0 * s
		var hh = 5.5 * s
		var height = 30.0 * s
		draw_prop_shadow(p, hw, hh)
		draw_iso_prism(p, hw, hh, height, Color(0.20, 0.26, 0.24), Color(0.30, 0.38, 0.35))
		# glass flap folded into the pedestal
		draw_colored_polygon(PackedVector2Array([
			p + Vector2(0, -height), p + Vector2(20 * s, -height + 10 * s),
			p + Vector2(20 * s, -height + 26 * s), p + Vector2(0, -height + 16 * s)
		]), Color(0.35, 0.85, 0.80, 0.32))
		# top status lamp
		fill_ellipse(p + Vector2(0, -height - 1 * s), hw * 0.55, hh * 0.55, Color(0.10, 0.85, 0.55))
	# green go-arrow on the floor between the pedestals
	var mid = base + span * 0.5 + Vector2(10 * s, 14 * s)
	draw_colored_polygon(PackedVector2Array([
		mid + Vector2(-9 * s, -4 * s), mid + Vector2(2 * s, 1 * s),
		mid + Vector2(-9 * s, 6 * s)
	]), Color(0.12, 0.85, 0.55, 0.75))

# A-frame chalkboard. The caller writes the day's menu onto `board_rect`.
func menu_board_rect(base: Vector2, s: float) -> Rect2:
	return Rect2(base.x - 44 * s, base.y - 62 * s, 88 * s, 46 * s)

func _prop_menu_board(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 26 * s, 13 * s)
	draw_line(base + Vector2(-16 * s, 2 * s), base + Vector2(-6 * s, -54 * s), Color(0.38, 0.27, 0.18), 3.5 * s)
	draw_line(base + Vector2(18 * s, 6 * s), base + Vector2(8 * s, -54 * s), Color(0.30, 0.21, 0.14), 3.5 * s)
	var r = menu_board_rect(base, s)
	draw_rect(r.grow(3.0 * s), Color(0.40, 0.28, 0.18), true)
	draw_rect(r, Color(0.13, 0.15, 0.14), true)
	draw_rect(r, Color(0.55, 0.42, 0.28), false, 1.5)
	draw_rect(r.grow(-4.0 * s), Color(0.62, 0.66, 0.60, 0.35), false, 1.0)

func _prop_umbrella_stand(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 9 * s, 4.5 * s)
	draw_iso_cylinder(base, 8.5 * s, 4.2 * s, 20.0 * s, Color(0.28, 0.30, 0.34))
	for u in range(3):
		var top = base + Vector2((-4 + u * 4) * s, (-20 - 16 - u * 3) * s)
		draw_line(base + Vector2((-3 + u * 3) * s, -20 * s), top, [Color(0.72, 0.28, 0.30), Color(0.26, 0.42, 0.68), Color(0.30, 0.54, 0.36)][u], 2.6 * s)

func _prop_parasol(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 30 * s, 15 * s)
	draw_iso_cylinder(base, 13.0 * s, 6.5 * s, 6.0 * s, Color(0.26, 0.26, 0.28))
	draw_line(base + Vector2(0, -4 * s), base + Vector2(0, -96 * s), Color(0.55, 0.42, 0.30), 3.4 * s)
	# canopy: eight alternating gores
	var top = base + Vector2(0, -96 * s)
	var rim_y = -70.0 * s
	var cols = [Color(0.86, 0.84, 0.78), Color(0.42, 0.62, 0.56)]
	for g in range(8):
		var a0 = (float(g) / 8.0) * TAU
		var a1 = (float(g + 1) / 8.0) * TAU
		draw_colored_polygon(PackedVector2Array([
			top,
			base + Vector2(cos(a0) * 44 * s, rim_y + sin(a0) * 20 * s),
			base + Vector2(cos(a1) * 44 * s, rim_y + sin(a1) * 20 * s)
		]), cols[g % 2])
	fill_ellipse(base + Vector2(0, rim_y), 44 * s, 20 * s, Color(0, 0, 0, 0.0))

func _prop_planter(base: Vector2, s: float) -> void:
	var hw = 40.0 * s
	var hh = 20.0 * s
	draw_prop_shadow(base, hw, hh)
	draw_iso_prism(base, hw, hh, 20.0 * s, Color(0.36, 0.26, 0.18), Color(0.28, 0.20, 0.14))
	var soil = base + Vector2(0, -20.0 * s)
	fill_ellipse(soil, hw * 0.82, hh * 0.82, Color(0.16, 0.11, 0.08))
	var greens = [Color(0.20, 0.50, 0.28), Color(0.26, 0.62, 0.34), Color(0.30, 0.70, 0.40)]
	for b in range(6):
		var bx = (-26 + b * 10.5) * s
		var by = -4.0 * s + (b % 2) * 5.0 * s
		fill_ellipse(soil + Vector2(bx, by - 12 * s), 9 * s, 7 * s, greens[b % 3])
		fill_ellipse(soil + Vector2(bx + 4 * s, by - 20 * s), 7 * s, 5.5 * s, greens[(b + 1) % 3])
	for f in range(3):
		draw_circle(soil + Vector2((-18 + f * 18) * s, -22 * s), 2.6 * s, Color(0.94, 0.72, 0.80))

func _prop_patio_heater(base: Vector2, s: float) -> void:
	draw_prop_shadow(base, 13 * s, 6.5 * s)
	draw_iso_cylinder(base, 12.0 * s, 6.0 * s, 8.0 * s, Color(0.30, 0.32, 0.34))
	draw_line(base + Vector2(0, -6 * s), base + Vector2(0, -74 * s), Color(0.62, 0.64, 0.66), 3.0 * s)
	draw_iso_cylinder(base + Vector2(0, -74 * s), 9.0 * s, 4.5 * s, 16.0 * s, Color(0.55, 0.57, 0.60))
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-20 * s, -90 * s), base + Vector2(20 * s, -90 * s),
		base + Vector2(14 * s, -102 * s), base + Vector2(-14 * s, -102 * s)
	]), Color(0.42, 0.44, 0.47))
	fill_ellipse(base + Vector2(0, -80 * s), 26 * s, 12 * s, Color(1.0, 0.55, 0.22, 0.16))

# ── Where the fixtures stand ──────────────────────────────────
# Study-room props sit on cells just OUTSIDE the placeable 6x4 grid, so they
# dress the walls without ever stealing a tile the player wants for a desk.
const FLOOR_PROPS: Dictionary = {
	2: [
		{"kind": "bookshelf",  "cell": Vector2i(0, -1)},
		{"kind": "floor_lamp", "cell": Vector2i(1, -1)},
		{"kind": "bookshelf",  "cell": Vector2i(2, -1)},
		{"kind": "sofa",       "cell": Vector2i(-1, 0)},
		{"kind": "floor_lamp", "cell": Vector2i(-1, 1)},
		{"kind": "plant",      "cell": Vector2i(-1, 2)},
		{"kind": "sofa",       "cell": Vector2i(-1, 3)},
		{"kind": "water",      "cell": Vector2i(6, 1)},
		{"kind": "bin",        "cell": Vector2i(6, 2)},
		{"kind": "floor_lamp", "cell": Vector2i(3, 6)},
	],
	3: [
		{"kind": "planter",      "cell": Vector2i(0, -1)},
		{"kind": "planter",      "cell": Vector2i(1, -1)},
		{"kind": "patio_heater", "cell": Vector2i(2, -1)},
		{"kind": "parasol",      "cell": Vector2i(-1, 0)},
		{"kind": "planter",      "cell": Vector2i(-1, 1)},
		{"kind": "plant",        "cell": Vector2i(-1, 2)},
		{"kind": "sofa",         "cell": Vector2i(-1, 3)},
		{"kind": "parasol",      "cell": Vector2i(6, 1)},
		{"kind": "bin",          "cell": Vector2i(6, 2)},
		{"kind": "planter",      "cell": Vector2i(3, 6)},
	]
}

const ROOM1_PROPS: Array = [
	{"kind": "bookshelf",  "cell": Vector2i(0, -1)},
	{"kind": "bookshelf",  "cell": Vector2i(1, -1)},
	{"kind": "printer",    "cell": Vector2i(2, -1)},
	{"kind": "plant",      "cell": Vector2i(-1, 0)},
	{"kind": "water",      "cell": Vector2i(-1, 1)},
	{"kind": "sofa",       "cell": Vector2i(-1, 2)},
	{"kind": "floor_lamp", "cell": Vector2i(-1, 3)},
	{"kind": "plant",      "cell": Vector2i(6, 1)},
	{"kind": "bin",        "cell": Vector2i(6, 2)},
	{"kind": "plant",      "cell": Vector2i(3, 6)},
]

# The coffee bar has its own smaller isometric frame inside the lounge panel:
# a real counter run with a machine, a pastry case, stools and a back shelf,
# replacing the single flat coffee_bar.png that used to be pasted here.
const LOUNGE_ORIGIN: Vector2 = Vector2(1080.0, 118.0)
const LOUNGE_TILE_W: float = 76.0
const LOUNGE_TILE_H: float = 38.0
const LOUNGE_SCALE: float = 0.5
# Three isometric rows - back bar, counter run, stools - is what fits in the
# lounge panel without colliding with its banner or the bakery stock strip.
const LOUNGE_PROPS: Array = [
	{"kind": "back_shelf",   "cell": Vector2i(0, -1)},
	{"kind": "back_shelf",   "cell": Vector2i(1, -1)},
	{"kind": "counter",      "cell": Vector2i(0, 0)},
	{"kind": "espresso",     "cell": Vector2i(0, 0), "lift": 20.0},
	{"kind": "counter",      "cell": Vector2i(1, 0)},
	{"kind": "counter_end",  "cell": Vector2i(2, 0)},
	{"kind": "display_case", "cell": Vector2i(2, 0), "lift": 20.0},
	{"kind": "stool",        "cell": Vector2i(0, 1)},
	{"kind": "stool",        "cell": Vector2i(1, 1)},
]

func lounge_to_screen(cell: Vector2i) -> Vector2:
	return LOUNGE_ORIGIN + Vector2(
		float(cell.x - cell.y) * LOUNGE_TILE_W * 0.5,
		float(cell.x + cell.y) * LOUNGE_TILE_H * 0.5
	)

# A woven rug under the study block. Drawn straight onto the floor diamonds so
# it follows the same projection as everything standing on it.
func draw_floor_rug(from_cell: Vector2i, to_cell: Vector2i, col: Color) -> void:
	var vo = view_offset
	var a = GameState.iso_to_screen(Vector2i(from_cell.x, from_cell.y)) + vo
	var b = GameState.iso_to_screen(Vector2i(to_cell.x, from_cell.y)) + vo
	var c = GameState.iso_to_screen(Vector2i(to_cell.x, to_cell.y)) + vo
	var d = GameState.iso_to_screen(Vector2i(from_cell.x, to_cell.y)) + vo
	var hw = GameState.ISO_TILE_WIDTH * 0.5
	var hh = GameState.ISO_TILE_HEIGHT * 0.5
	var poly = PackedVector2Array([
		a + Vector2(0, -hh), b + Vector2(hw, 0), c + Vector2(0, hh), d + Vector2(-hw, 0)
	])
	draw_colored_polygon(poly, col)
	stroke_poly(poly, shade(col, 1.6), 2.0)
	var inner = PackedVector2Array()
	for pt in poly:
		inner.append(pt.lerp((a + c) * 0.5, 0.12))
	stroke_poly(inner, shade(col, 1.35), 1.2)

# Wall fixtures split into the two depth bands around the desk block: the back
# wall run is painted before the desks, the front/right pieces after, so nothing
# floats in front of furniture it is standing behind.
func draw_room1_props(back_band: bool) -> void:
	var vo = view_offset
	var picked = []
	for prop in FLOOR_PROPS.get(GameState.current_floor, ROOM1_PROPS):
		var c = prop["cell"]
		var is_back = c.x < 0 or c.y < 0
		if is_back == back_band:
			picked.append(prop)
	picked.sort_custom(func(a, b): return (a["cell"].x + a["cell"].y) < (b["cell"].x + b["cell"].y))
	for prop in picked:
		draw_prop(prop["kind"], GameState.iso_to_screen(prop["cell"]) + vo, 0.72)

# The lounge, built piece by piece and depth-sorted like the study room.
func draw_lounge_bar() -> void:
	var vo = view_offset
	var order = LOUNGE_PROPS.duplicate()
	order.sort_custom(func(a, b):
		var ca = a["cell"]
		var cb = b["cell"]
		var da = ca.x + ca.y
		var db = cb.x + cb.y
		if da == db:
			return a.get("lift", 0.0) < b.get("lift", 0.0)
		return da < db
	)
	for prop in order:
		var pos = lounge_to_screen(prop["cell"]) + vo - Vector2(0, prop.get("lift", 0.0))
		draw_prop(prop["kind"], pos, LOUNGE_SCALE)

func decorate_reset_rect() -> Rect2:
	return Rect2(742, 508, 150, 34)

func get_desk_sprite_size(seat_index: int) -> Vector2:
	var is_booth = seat_index >= GameState.upgrades["open_seats"]["level"] * 3
	var side = GameState.ISO_TILE_WIDTH * (1.18 if is_booth else 1.05)
	return Vector2(side, side)

# Desk art is anchored bottom-centre on the isometric tile it stands on, which is
# what makes a sprite read as "sitting on" a diamond floor tile. The extra sink
# accounts for the transparent padding under the furniture in the source art.
func get_desk_rect(seat_index: int) -> Rect2:
	var tile_center = GameState.get_seat_position(seat_index)
	var size = get_desk_sprite_size(seat_index)
	var bottom_y = tile_center.y + GameState.ISO_TILE_HEIGHT * 0.5 + size.y * 0.09
	return Rect2(Vector2(tile_center.x - size.x * 0.5, bottom_y - size.y), size)

# Back-to-front painter's order for the isometric view: tiles further along the
# (x + y) diagonal are nearer the camera and must be drawn last.
func get_seats_in_depth_order() -> Array:
	# Only the desks that live on the floor the player is looking at.
	var indices = GameState.get_seats_on_floor(GameState.current_floor)
	indices.sort_custom(func(a, b):
		var ca = GameState.get_seat_cell(a)
		var cb = GameState.get_seat_cell(b)
		var da = ca.x + ca.y
		var db = cb.x + cb.y
		if da == db:
			return ca.x < cb.x
		return da < db
	)
	return indices

# Pick the desk under the cursor, testing front-most first so overlapping desks
# resolve to the one the player can actually see.
func pick_seat_at(world_pos: Vector2) -> int:
	var order = get_seats_in_depth_order()
	for k in range(order.size() - 1, -1, -1):
		var i = order[k]
		if get_desk_rect(i).has_point(world_pos):
			return i
		if GameState.is_point_in_iso_tile(world_pos, GameState.get_seat_cell(i)):
			return i
	return -1
