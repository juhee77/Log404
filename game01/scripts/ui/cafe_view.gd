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
	# Controls do not clip by default, so the room's wall peak was drawing up
	# over the floor-tab bar above this view.
	clip_contents = true
	GameState.story_beat.connect(_on_story_beat)
	
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
	update_door(delta)
	if brew_flash > 0.0:
		brew_flash = max(0.0, brew_flash - delta * 1.4)
	if GameState.brew_active:
		queue_redraw()
	update_story_card(delta)
	if not story_card.is_empty():
		queue_redraw()
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

func _unhandled_key_input(event: InputEvent) -> void:
	if GameState.brew_active and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_brew_submit()
			get_viewport().set_input_as_handled()

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
		view_offset.x = clamp(view_offset.x, -180.0, 180.0)
		view_offset.y = clamp(view_offset.y, -140.0, 70.0)
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
			# 추출 중이면 어디를 눌러도 그 클릭이 타이밍 판정이 된다
			if GameState.brew_active:
				_brew_submit()
				return
			var bar_rect = Rect2(zone_center("lounge").x - 120, zone_center("lounge").y - 120, 240, 200)
			if bar_rect.has_point(click_pos):
				if GameState.active_orders.size() > 0:
					var first_cid = GameState.active_orders.keys()[0]
					GameState.start_brew(first_cid)
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
		# Dark void behind the room, then the two isometric wall planes that rise
		# from the back edges of the floor diamond.
		draw_rect(Rect2(0, 0, w, h), shade(th["wall"], 0.45), true)
		var c = room_corners()
		var T = c["T"] + view_offset
		var R = c["R"] + view_offset
		var L = c["L"] + view_offset

		# north-west wall (L -> T), in shade; north-east wall (T -> R), lit
		draw_wall_plane(L, T, th, false)
		draw_wall_plane(T, R, th, true)
		draw_wall_window(L, T, 0.26, 0.52, th)
		draw_wall_window(T, R, 0.16, 0.40, th)
		draw_wall_door(T, R, th)

		# ceiling cove along the top of each wall
		wall_line(L, T, 0.0, 1.0, 1.0, Color(th["accent"], 0.75), 2.5)
		wall_line(T, R, 0.0, 1.0, 1.0, Color(th["accent"], 0.85), 2.5)

	# 2. Floor surface: the diamond itself, not a full-width rectangle
	draw_floor_plan(th)
	var plank_h = 32.0 if style != "carpet" else 26.0
	for py in range(int((h - 220) / plank_h) + 2 if style == "deck" else 0):
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
		var hint = "🔨 책상 옮기기: 책상을 클릭해 잡은 뒤, 원하는 칸을 클릭하거나 끌어서 놓으세요"
		var lvl = GameState.study_area_level
		if lvl < GameState.STUDY_AREA_STAGES.size() - 1:
			hint = "🔨 책상 옮기기  ·  개방 %d칸 (어두운 칸은 [좌석 & 시설 업그레이드]에서 확장)" % GameState.get_study_cell_count()
		draw_string(ThemeDB.fallback_font, banner_rect.position + Vector2(14, 23), hint,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.96, 0.62, 0.07))

		var reset_rect = decorate_reset_rect()
		draw_rect(reset_rect, Color(0.32, 0.14, 0.14, 0.96), true)
		draw_rect(reset_rect, Color(0.95, 0.45, 0.35), false, 2.0)
		draw_string(ThemeDB.fallback_font, reset_rect.position + Vector2(16, 23), "↺ 배치 초기화",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.8, 0.75))
		
	# 6. Brewing mini-game gauge, then the story beat card over everything
	draw_brew_game(w, h)
	draw_story_card(w, h)

	# 7. Draw Floating Action Texts
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
	
	# 아직 사지 않은 칸은 "미개방"으로 어둡게 깔아, 확장이 무엇을 열어주는지
	# 플레이어가 바로 볼 수 있게 한다.
	for gy in range(GameState.STUDY_Y0, GameState.STUDY_Y1 + 1):
		for gx in range(GameState.STUDY_X0, GameState.STUDY_X1 + 1):
			var locked_cell = Vector2i(gx, gy)
			if GameState.is_iso_cell_in_bounds(locked_cell):
				continue
			var lp = GameState.get_iso_diamond_polygon(locked_cell)
			for li in range(lp.size()):
				lp[li] += vo
			draw_colored_polygon(lp, Color(0.05, 0.05, 0.07, 0.55))
			var lloop = lp.duplicate()
			lloop.append(lp[0])
			draw_polyline(lloop, Color(0.35, 0.33, 0.30, 0.35), 1.0)

	var area = GameState.get_study_rect()
	for gy in range(area.position.y, area.position.y + area.size.y):
		for gx in range(area.position.x, area.position.x + area.size.x):
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
	var th2 = theme()

	# ── Partition walls between the three zones, with doorways ──
	# study | lounge+front  (runs along the x = 5|6 boundary)
	var div1 = rect_corners(6, 0, 6, GameState.FLOOR_ROWS - 1)
	draw_partition(div1["T"] + vo, div1["L"] + vo, th2, 68.0, 0.44, 0.62)
	# lounge | front  (runs along the y = 3|4 boundary)
	var div2 = rect_corners(6, 4, GameState.FLOOR_COLS - 1, 4)
	draw_partition(div2["T"] + vo, div2["R"] + vo, th2, 62.0, 0.28, 0.50)

	# ── Zone names as flat floor decals, so nothing sits in front of furniture ──
	for z in ZONES:
		if z["name"] == "":
			continue
		var c = zone_center(z["id"]) + vo
		draw_string(ThemeDB.fallback_font, Vector2(c.x - 110, c.y + 6), zone_label(z, th2),
			HORIZONTAL_ALIGNMENT_CENTER, 220, 11, Color(th2["accent"], 0.30))

	# ── Zone legend, parked in the empty top-left margin ──
	var lg_y = 24.0
	for z in ZONES:
		if z["name"] == "":
			continue
		draw_rect(Rect2(14, lg_y, 12, 12), z["tint"], true)
		draw_rect(Rect2(14, lg_y, 12, 12), Color(th2["accent"], 0.6), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(32, lg_y + 11), zone_label(z, th2),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.82, 0.80, 0.76))
		lg_y += 18.0

	# ── LOUNGE ZONE fixtures, standing on their own cells ──
	draw_lounge_bar()
	var barista_at = GameState.iso_to_screen(Vector2i(6, 1)) + vo
	if staff_barista_texture != null:
		draw_character_shadow(barista_at, 34.0)
		draw_character(staff_barista_texture, "staff_barista", barista_at, 62.0)
		draw_string(ThemeDB.fallback_font, barista_at + Vector2(-42, -70), "☕ 바리스타 민서",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.1, 0.8, 0.4))

	# chalkboard menu + lounge seating
	var board_base = GameState.iso_to_screen(Vector2i(9, 1)) + vo
	draw_prop("menu_board", board_base, 0.95)
	var board_r = menu_board_rect(board_base, 0.95)
	var c_cnt = GameState.bakery_stock.get("cheesecake", 0)
	var r_cnt = GameState.bakery_stock.get("croissant", 0)
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(7, 15), th2["menu_title"],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.88, 0.70))
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(7, 29), "🍰 x%d" % c_cnt,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.85, 0.9))
	draw_string(ThemeDB.fallback_font, board_r.position + Vector2(7, 41), "🥐 x%d" % r_cnt,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.90, 0.78))
	draw_prop("round_table", GameState.iso_to_screen(Vector2i(8, 3)) + vo, 0.62)
	draw_prop("plant", GameState.iso_to_screen(Vector2i(9, 3)) + vo, 0.55)

	if GameState.is_qte_mini_game_active:
		var qte_rect = Rect2(zone_center("lounge").x - 120 + vo.x, zone_center("lounge").y + 60 + vo.y, 240, 42)
		draw_rect(qte_rect, Color(0.08, 0.06, 0.12, 0.95), true)
		draw_rect(qte_rect, Color(1.0, 0.8, 0.2), false, 2.0)
		var target_x = qte_rect.position.x + qte_rect.size.x * 0.85
		draw_rect(Rect2(target_x - 15, qte_rect.position.y + 4, 30, qte_rect.size.y - 8), Color(0.2, 0.9, 0.5, 0.7), true)
		draw_string(ThemeDB.fallback_font, qte_rect.position + Vector2(8, 26), "🍰 핫타임 QTE! PERFECT 존 타격!", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.85, 0.3))

	# ── FRONT ZONE fixtures ──
	var front_style = th2["front_style"]
	if front_style == "garden":
		draw_prop("planter", GameState.iso_to_screen(Vector2i(6, 5)) + vo, 0.72)
		draw_prop("parasol", GameState.iso_to_screen(Vector2i(8, 5)) + vo, 0.68)
		draw_prop("planter", GameState.iso_to_screen(Vector2i(7, 7)) + vo, 0.72)
		draw_prop("sofa", GameState.iso_to_screen(Vector2i(9, 6)) + vo, 0.60)
	else:
		_prop_locker_bank(GameState.iso_to_screen(Vector2i(6, 5)) + vo, 0.82, 1)
		_prop_locker_bank(GameState.iso_to_screen(Vector2i(7, 5)) + vo, 0.82, 5)
		draw_prop("umbrella_stand", GameState.iso_to_screen(Vector2i(6, 6)) + vo, 0.75)
		draw_string(ThemeDB.fallback_font, Vector2(32, 96),
			"🔑 사물함 %d/%d칸 대여   +%d₩/초" % [GameState.lockers_rented,
			max(GameState.get_locker_capacity(), 8), int(GameState.get_locker_rent_rate())],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, th2["accent"])

	if front_style == "front":
		draw_prop("reception", GameState.iso_to_screen(Vector2i(8, 5)) + vo, 0.78)
		draw_prop("speed_gate", GameState.iso_to_screen(GameState.ENTRANCE_CELL) + vo + Vector2(-14, -26), 0.8)
	elif front_style == "vip":
		draw_prop("sofa", GameState.iso_to_screen(Vector2i(8, 5)) + vo, 0.66)
		draw_prop("floor_lamp", GameState.iso_to_screen(Vector2i(9, 5)) + vo, 0.66)

	# ----------------------------------------------------
	# Draw Desks & Booths inside the STUDY zone
	# ----------------------------------------------------
	draw_floor_rug(Vector2i(1, 3), Vector2i(4, 6), Color(0.26, 0.18, 0.13, 0.40))
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
		var drawn_tex = draw_desk_art(i, is_booth, tile_center, sprite_size.y)

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
		
		# Sprite per type. "examinee" and "worker" used to silently fall back to
		# the student sprite with nothing to tell them apart; each type now gets
		# its own tint, and each customer a small stable variation so two of the
		# same type are not identical.
		var sprite_key = "customer_student"
		var char_tex = student_texture
		for t in GameState.CUSTOMER_TYPES:
			if t["type"] == c_type and t["sprite"] == "developer":
				char_tex = developer_texture if developer_texture else student_texture
				sprite_key = "customer_developer" if developer_texture else "customer_student"
				break

		if char_tex != null:
			var tint = Color.WHITE.lerp(c["color"], 0.22)
			var v = int(c.get("variant", 0))
			tint = tint.lerp(Color(1.0, 1.0, 1.0), 0.06 * float(v))
			tint.v = clampf(tint.v * (0.92 + 0.05 * float(v)), 0.0, 1.0)
			draw_character_shadow(draw_pos, 34.0)
			draw_customer_accessory(c_type, draw_pos, 62.0)
			var body = draw_character(char_tex, sprite_key, draw_pos, 62.0, tint)
			# regulars carry a name tag, so the player recognises who came back
			if String(c.get("regular_key", "")) != "":
				var tag = "⭐ %s" % c["name"]
				draw_string(ThemeDB.fallback_font, Vector2(draw_pos.x - 40, body.position.y - 6), tag,
					HORIZONTAL_ALIGNMENT_CENTER, 80, 11, Color(1.0, 0.82, 0.42))
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
			
			# Weather chatter, but only from a few customers at a time - one
			# bubble per occupied seat turned the room into a wall of text.
			var w_type = GameState.current_weather_type
			var chatty = (int(c["id"]) % 5 == 0)
			if not chatty:
				pass
			elif w_type == "rainy":
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
# ── What each customer carries ────────────────────────────────
# Four customer types share two character sprites, so until now the only thing
# telling a 공시생 from a 재택 직장인 was a faint colour tint. Each type now
# carries something of its own, drawn beside the sprite in the same isometric
# solids as the furniture.
func draw_customer_accessory(c_type: String, feet: Vector2, body_h: float) -> void:
	var s = body_h / 62.0
	match c_type:
		"student":
			# 교복 백팩 - 발 옆에 세워둔 책가방
			var b = feet + Vector2(-15 * s, -1 * s)
			draw_prop_shadow(b, 8 * s, 4 * s)
			draw_iso_prism(b, 7.5 * s, 3.8 * s, 15 * s, Color(0.24, 0.32, 0.55), Color(0.30, 0.40, 0.66))
			draw_face_quad(b, 7.5 * s, 3.8 * s, 15 * s, 0.18, 0.82, 0.16, 0.52, Color(0.86, 0.72, 0.28))
			draw_line(b + Vector2(-2 * s, -15 * s), b + Vector2(3 * s, -19 * s), Color(0.18, 0.24, 0.42), 2.0 * s)
		"examinee":
			# 공시생 - 쌓아둔 수험서와 텀블러
			var st = feet + Vector2(15 * s, 1 * s)
			draw_prop_shadow(st, 9 * s, 4.5 * s)
			var cols = [Color(0.72, 0.30, 0.26), Color(0.82, 0.68, 0.32), Color(0.28, 0.44, 0.62)]
			for k in range(3):
				draw_iso_prism(st + Vector2(0, -k * 4.4 * s), 8.5 * s, 4.2 * s, 4.2 * s, cols[k])
			draw_iso_cylinder(st + Vector2(-11 * s, -2 * s), 3.2 * s, 1.7 * s, 11 * s, Color(0.55, 0.60, 0.64))
		"developer":
			# 개발자 - 노트북 슬리브와 헤드폰
			var lp = feet + Vector2(16 * s, 0)
			draw_prop_shadow(lp, 9 * s, 4.5 * s)
			draw_iso_prism(lp, 9 * s, 4.5 * s, 13 * s, Color(0.22, 0.24, 0.28), Color(0.32, 0.34, 0.38))
			draw_face_quad(lp, 9 * s, 4.5 * s, 13 * s, 0.1, 0.9, 0.55, 0.72, Color(0.35, 0.72, 0.80))
			fill_ellipse(feet + Vector2(-14 * s, -9 * s), 5 * s, 3 * s, Color(0.20, 0.22, 0.26))
			draw_line(feet + Vector2(-17 * s, -11 * s), feet + Vector2(-11 * s, -11 * s), Color(0.55, 0.58, 0.62), 1.8 * s)
		"worker":
			# 재택 직장인 - 텀블러와 서류 트레이
			var tr = feet + Vector2(-16 * s, 0)
			draw_prop_shadow(tr, 9 * s, 4.5 * s)
			draw_iso_prism(tr, 9 * s, 4.5 * s, 5 * s, Color(0.42, 0.34, 0.50), Color(0.52, 0.43, 0.60))
			draw_iso_prism(tr + Vector2(0, -5 * s), 8 * s, 4 * s, 3 * s, Color(0.88, 0.86, 0.80))
			draw_iso_cylinder(feet + Vector2(15 * s, 1 * s), 3.8 * s, 2.0 * s, 14 * s, Color(0.76, 0.42, 0.34))
			fill_ellipse(feet + Vector2(15 * s, -14 * s), 3.8 * s, 2.0 * s, Color(0.30, 0.22, 0.20))

# ── 핸드드립 추출 게이지 ───────────────────────────────────────
# 커피바 위에 떠서, 좌우로 오가는 바늘을 초록 구간에 맞춰 멈추는 화면.
var brew_flash: float = 0.0
var brew_flash_hit: bool = false

func _on_brew_step(_info: Dictionary) -> void:
	brew_flash = 0.35

func draw_brew_game(w: float, _h: float) -> void:
	if not GameState.brew_active:
		return
	var info = GameState.get_brew_info()
	var th = theme()

	var bw = 420.0
	var bh = 112.0
	var r = Rect2((w - bw) * 0.5, 84.0, bw, bh)
	draw_rect(r, Color(0.07, 0.06, 0.05, 0.96), true)
	draw_rect(r, Color(th["accent"], 0.9), false, 2.0)

	draw_string(ThemeDB.fallback_font, r.position + Vector2(14, 22),
		"☕ 핸드드립 — %s  (%d/%d)" % [info["phase_name"], info["phase"] + 1, info["total"]],
		HORIZONTAL_ALIGNMENT_LEFT, bw - 28, 14, th["accent"])
	draw_string(ThemeDB.fallback_font, r.position + Vector2(14, 40), info["desc"],
		HORIZONTAL_ALIGNMENT_LEFT, bw - 28, 11, Color(0.74, 0.72, 0.68))

	# 게이지 트랙
	var track = Rect2(r.position.x + 16, r.position.y + 54, bw - 32, 20)
	draw_rect(track, Color(0.13, 0.12, 0.11), true)
	draw_rect(track, Color(0.30, 0.27, 0.24), false, 1.0)

	# 목표 구간
	var band_w = track.size.x * float(info["band"])
	var band_x = track.position.x + track.size.x * float(info["target"]) - band_w * 0.5
	draw_rect(Rect2(band_x, track.position.y, band_w, track.size.y), Color(0.18, 0.78, 0.45, 0.55), true)
	draw_rect(Rect2(band_x, track.position.y, band_w, track.size.y), Color(0.25, 0.95, 0.60), false, 1.5)
	# 한가운데 퍼펙트 선
	var mid_x = band_x + band_w * 0.5
	draw_line(Vector2(mid_x, track.position.y), Vector2(mid_x, track.position.y + track.size.y),
		Color(0.85, 1.0, 0.9, 0.7), 1.0)

	# 바늘
	var nx = track.position.x + track.size.x * float(info["pos"])
	draw_rect(Rect2(nx - 2, track.position.y - 5, 4, track.size.y + 10), Color(1.0, 0.92, 0.55), true)

	# 단계별 성공 표시
	for k in range(int(info["total"])):
		var dot = Vector2(r.position.x + 18 + k * 16, r.position.y + bh - 16)
		draw_circle(dot, 5.0, Color(0.25, 0.95, 0.60) if k < int(info["hits"]) else Color(0.28, 0.26, 0.24))

	draw_string(ThemeDB.fallback_font, Vector2(r.position.x + 90, r.position.y + bh - 11),
		"클릭 또는 Space 로 멈추기", HORIZONTAL_ALIGNMENT_LEFT, bw - 100, 11, Color(0.62, 0.60, 0.57))

	# 판정 플래시
	if brew_flash > 0.0:
		var col = Color(0.25, 0.95, 0.60, brew_flash) if brew_flash_hit else Color(0.95, 0.35, 0.30, brew_flash)
		draw_rect(r, col, false, 4.0)

func _brew_submit() -> void:
	var step = GameState.submit_brew()
	if not step.get("ok", false):
		return
	brew_flash = 0.35
	brew_flash_hit = step["hit"]
	floating_texts.append({
		"text": ("✅ %s 성공!" % step["phase_name"]) if step["hit"] else ("💧 %s 빗나감" % step["phase_name"]),
		"pos": Vector2(get_rect().size.x * 0.5, 210),
		"alpha": 1.0,
		"color": Color(0.25, 0.95, 0.6) if step["hit"] else Color(0.95, 0.5, 0.4)
	})
	if step.get("finished", false):
		var res = step["result"]
		floating_texts.append({
			"text": res["msg"],
			"pos": Vector2(get_rect().size.x * 0.5, 240),
			"alpha": 1.0,
			"color": Color(1.0, 0.85, 0.4)
		})
	queue_redraw()

# ── Story beat card ───────────────────────────────────────────
# An act change used to pass in total silence - the header inside the quest
# panel changed and nothing else. Now the beat is staged over the cafe: the
# room dims, a card fades in with the act title, its opening lines and the
# person who walks through the door, then it fades back out.
var story_card: Dictionary = {}
var story_card_t: float = 0.0

func _on_story_beat(beat: Dictionary) -> void:
	story_card = beat
	story_card_t = 0.0
	if SoundManager and SoundManager.has_method("play_chime_sfx"):
		SoundManager.play_chime_sfx()

func update_story_card(delta: float) -> void:
	if story_card.is_empty():
		return
	story_card_t += delta
	if story_card_t > 9.0:
		story_card = {}

func story_card_alpha() -> float:
	if story_card.is_empty():
		return 0.0
	if story_card_t < 0.6:
		return story_card_t / 0.6
	if story_card_t > 8.0:
		return max(0.0, (9.0 - story_card_t) / 1.0)
	return 1.0

func draw_story_card(w: float, h: float) -> void:
	if story_card.is_empty():
		return
	var a = story_card_alpha()
	if a <= 0.01:
		return
	var th = theme()

	# dim the cafe behind the card
	draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.02, 0.03, 0.62 * a), true)

	var cw = 560.0
	var ch = 190.0
	var card = Rect2((w - cw) * 0.5, (h - ch) * 0.5 - 20.0, cw, ch)
	draw_rect(card, Color(0.09, 0.08, 0.07, 0.97 * a), true)
	draw_rect(card, Color(th["accent"], 0.85 * a), false, 2.0)
	# a warm bar down the hinge side, like light under a door
	draw_rect(Rect2(card.position.x, card.position.y, 4, ch), Color(th["accent"], 0.9 * a), true)

	draw_string(ThemeDB.fallback_font, card.position + Vector2(22, 36), story_card["title"],
		HORIZONTAL_ALIGNMENT_LEFT, cw - 44, 17, Color(th["accent"], a))

	var y = 66.0
	for line in String(story_card["body"]).split("\n"):
		draw_string(ThemeDB.fallback_font, card.position + Vector2(22, y), line,
			HORIZONTAL_ALIGNMENT_LEFT, cw - 44, 12, Color(0.84, 0.82, 0.78, a))
		y += 19.0

	var speaker = String(story_card.get("speaker", ""))
	if speaker != "":
		draw_string(ThemeDB.fallback_font, card.position + Vector2(22, ch - 20), speaker,
			HORIZONTAL_ALIGNMENT_LEFT, cw - 44, 12, Color(0.98, 0.78, 0.42, a))

# ══════════════════════════════════════════════════════════════
# 🗺️ FLOOR PLAN
# One continuous isometric floor. The lounge and the front desk used to be flat
# rectangular panels bolted to the side of the screen; they are now zones of the
# same floor, separated by isometric partition walls with doorways in them.
# ══════════════════════════════════════════════════════════════

const ZONES: Array = [
	{"id": "study",  "x0": 0, "y0": 2, "x1": 5, "y1": 7,
	 "name": "📖 메인 집중 열공 방", "tint": Color(0.36, 0.25, 0.16)},
	{"id": "lounge", "x0": 6, "y0": 0, "x1": 9, "y1": 3,
	 "name": "☕ 힐링 라운지 & 커피바", "tint": Color(0.22, 0.27, 0.22)},
	{"id": "front",  "x0": 6, "y0": 4, "x1": 9, "y1": 7,
	 "name": "🔑 프런트 & 스마트 사물함", "tint": Color(0.25, 0.21, 0.32)},
	{"id": "hall",   "x0": 0, "y0": 0, "x1": 5, "y1": 1,
	 "name": "", "tint": Color(0.17, 0.15, 0.13)}
]

func zone_label(z: Dictionary, th: Dictionary) -> String:
	match z["id"]:
		"study": return th["room_name"]
		"lounge": return th["lounge_name"]
		"front": return th["front_name"]
	return z["name"]

func zone_of(cell: Vector2i) -> Dictionary:
	for z in ZONES:
		if cell.x >= z["x0"] and cell.x <= z["x1"] and cell.y >= z["y0"] and cell.y <= z["y1"]:
			return z
	return {}

func zone_by_id(zid: String) -> Dictionary:
	for z in ZONES:
		if z["id"] == zid:
			return z
	return {}

# Screen position of a zone's centre, for labels and fixture placement.
func zone_center(zid: String) -> Vector2:
	var z = zone_by_id(zid)
	if z.is_empty():
		return Vector2.ZERO
	return (GameState.iso_to_screen(Vector2i(z["x0"], z["y0"]))
		+ GameState.iso_to_screen(Vector2i(z["x1"], z["y1"]))) * 0.5

# The four outer corners of a cell rectangle, in world space.
func rect_corners(x0: int, y0: int, x1: int, y1: int) -> Dictionary:
	var hw = GameState.ISO_TILE_WIDTH * 0.5
	var hh = GameState.ISO_TILE_HEIGHT * 0.5
	return {
		"T": GameState.iso_to_screen(Vector2i(x0, y0)) + Vector2(0, -hh),
		"R": GameState.iso_to_screen(Vector2i(x1, y0)) + Vector2(hw, 0),
		"B": GameState.iso_to_screen(Vector2i(x1, y1)) + Vector2(0, hh),
		"L": GameState.iso_to_screen(Vector2i(x0, y1)) + Vector2(-hw, 0)
	}

# Paint every zone's floor, tinted so the areas read as separate rooms.
func draw_floor_plan(th: Dictionary) -> void:
	var vo = view_offset
	for z in ZONES:
		var c = rect_corners(z["x0"], z["y0"], z["x1"], z["y1"])
		var tint: Color = z["tint"]
		if th["style"] == "carpet":
			tint = tint.lerp(Color(0.26, 0.14, 0.19), 0.6)
		elif th["style"] == "deck":
			tint = tint.lerp(Color(0.30, 0.21, 0.13), 0.5)
		draw_colored_polygon(PackedVector2Array([
			c["T"] + vo, c["R"] + vo, c["B"] + vo, c["L"] + vo
		]), tint)

# A partition wall standing along one edge of the plan, with an optional
# doorway left open in it.
func draw_partition(a: Vector2, b: Vector2, th: Dictionary, height: float,
		gap0: float = -1.0, gap1: float = -1.0) -> void:
	var col = shade(th["wall_face"], 1.05)
	var segs: Array = []
	if gap0 < 0.0:
		segs.append([0.0, 1.0])
	else:
		segs.append([0.0, gap0])
		segs.append([gap1, 1.0])
	for seg in segs:
		var u0 = seg[0]
		var u1 = seg[1]
		if u1 - u0 < 0.001:
			continue
		draw_colored_polygon(PackedVector2Array([
			a.lerp(b, u0), a.lerp(b, u1),
			a.lerp(b, u1) + Vector2(0, -height), a.lerp(b, u0) + Vector2(0, -height)
		]), col)
		# capping strip along the top so the wall reads as having thickness
		draw_line(a.lerp(b, u0) + Vector2(0, -height), a.lerp(b, u1) + Vector2(0, -height),
			shade(col, 1.45), 3.0)
		draw_line(a.lerp(b, u0), a.lerp(b, u1), shade(col, 0.55), 2.0)
	# the reveal on each side of the doorway
	if gap0 >= 0.0:
		for u in [gap0, gap1]:
			draw_line(a.lerp(b, u), a.lerp(b, u) + Vector2(0, -height), shade(col, 1.3), 2.0)

# ══════════════════════════════════════════════════════════════
# 🧱 ISOMETRIC ROOM SHELL
# The room used to be a flat 2D backdrop - a full-width rectangle of "wall"
# across the top, a horizon line, and a rectangle of "floor" below it - with an
# isometric diamond pasted into the middle. Nothing but the floor was actually
# isometric. The shell is now built from the floor's own corners: two wall
# planes rise from the back edges of the diamond, and everything on them
# (skirting, rails, window, door) is drawn in wall coordinates so it shares the
# floor's projection.
# ══════════════════════════════════════════════════════════════

const WALL_HEIGHT: float = 118.0

# The four corners of the floor diamond, in world space.
# T is the far corner, R/L the side corners, B the near corner.
func room_corners() -> Dictionary:
	return rect_corners(0, 0, GameState.FLOOR_COLS - 1, GameState.FLOOR_ROWS - 1)

# A point on a wall plane. u runs along the base from `a` to `b`, v runs up it.
func wall_pt(a: Vector2, b: Vector2, u: float, v: float) -> Vector2:
	return a.lerp(b, u) + Vector2(0, -WALL_HEIGHT * v)

func wall_quad(a: Vector2, b: Vector2, u0: float, u1: float, v0: float, v1: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		wall_pt(a, b, u0, v0), wall_pt(a, b, u1, v0),
		wall_pt(a, b, u1, v1), wall_pt(a, b, u0, v1)
	]), col)

func wall_line(a: Vector2, b: Vector2, u0: float, u1: float, v: float, col: Color, width: float = 1.5) -> void:
	draw_line(wall_pt(a, b, u0, v), wall_pt(a, b, u1, v), col, width)

# One wall plane with its panelling. `door` and `window` are u-ranges to leave
# open; the caller fills them in.
func draw_wall_plane(a: Vector2, b: Vector2, th: Dictionary, lit: bool) -> void:
	var base: Color = th["wall_face"]
	var face = base if lit else shade(base, 0.68)
	wall_quad(a, b, 0.0, 1.0, 0.0, 1.0, face)

	# vertical studs
	var studs = 9
	for i in range(1, studs):
		wall_line(a, b, float(i) / studs, float(i) / studs, 0.0, shade(face, 0.72), 1.4)
		# the highlight edge of each stud
		draw_line(wall_pt(a, b, float(i) / studs, 0.0) + Vector2(1.6, 0),
			wall_pt(a, b, float(i) / studs, 1.0) + Vector2(1.6, 0), shade(face, 1.22), 1.0)

	# wainscot panelling on the lower third
	wall_quad(a, b, 0.0, 1.0, 0.0, 0.34, shade(face, 0.80))
	for pnl in range(8):
		var pu0 = 0.03 + pnl * 0.12
		wall_quad(a, b, pu0, pu0 + 0.085, 0.09, 0.29, shade(face, 0.88))
	wall_line(a, b, 0.0, 1.0, 0.34, Color(th["accent"], 0.55), 2.2)
	# skirting board
	wall_quad(a, b, 0.0, 1.0, 0.0, 0.055, shade(face, 0.58))
	# picture rail near the ceiling
	wall_line(a, b, 0.0, 1.0, 0.88, shade(face, 1.3), 2.0)
	# ceiling cove glow spilling down the wall
	wall_quad(a, b, 0.0, 1.0, 0.92, 1.0, Color(th["accent"], 0.10))

func sky_tint() -> Color:
	if GameState.time_of_day == "DUSK":
		return Color(0.98, 0.52, 0.22)
	elif GameState.time_of_day == "NIGHT":
		return Color(0.08, 0.10, 0.30)
	return Color(0.46, 0.72, 0.95)

# A window punched through a wall plane, with a frame and a sill.
func draw_wall_window(a: Vector2, b: Vector2, u0: float, u1: float, th: Dictionary) -> void:
	var v0 = 0.42
	var v1 = 0.84
	wall_quad(a, b, u0, u1, v0, v1, sky_tint())
	# glazing bars
	var um = (u0 + u1) * 0.5
	var vm = (v0 + v1) * 0.5
	wall_line(a, b, um, um, v0, Color(0.20, 0.16, 0.13, 0.9), 2.0)
	draw_line(wall_pt(a, b, u0, vm), wall_pt(a, b, u1, vm), Color(0.20, 0.16, 0.13, 0.9), 2.0)
	# reflection wedge on the glass
	draw_colored_polygon(PackedVector2Array([
		wall_pt(a, b, u0, v1), wall_pt(a, b, um, v1), wall_pt(a, b, u0, vm)
	]), Color(1, 1, 1, 0.10))
	# frame + sill
	var frame = shade(th["wall_face"], 1.35)
	draw_polyline(PackedVector2Array([
		wall_pt(a, b, u0, v0), wall_pt(a, b, u1, v0),
		wall_pt(a, b, u1, v1), wall_pt(a, b, u0, v1), wall_pt(a, b, u0, v0)
	]), frame, 2.5)
	wall_quad(a, b, u0 - 0.012, u1 + 0.012, v0 - 0.035, v0, shade(th["wall_face"], 1.15))

# ── A door that actually opens ────────────────────────────────
# The old "doors" were flat blue rectangles with a 🚪 glyph stuck on top. This
# one is a real leaf hinged in the wall plane: at 0 it lies flat in the wall, at
# 1 it has swung into the room along the perpendicular isometric axis, so it
# sweeps through the floor plane exactly like a door seen from this angle.
var door_open: float = 0.0        # 0 = shut, 1 = fully open
var door_target: float = 0.0
var door_chime_played: bool = false

const DOOR_U0: float = 0.70       # hinge position along the NE wall
const DOOR_W: float = 0.155       # leaf width in wall-u units
const DOOR_V: float = 0.62        # leaf height in wall-v units

func update_door(delta: float) -> void:
	if GameState == null or GameState.active_customers == null:
		return
	# Open while anyone is walking in or out; shut again once they are seated.
	var wants_open = false
	for c in GameState.active_customers:
		var st = c.get("state", "")
		if st == "WALKING_IN" or st == "WALKING_TO_SEAT" or st == "LEAVING":
			wants_open = true
			break
	door_target = 1.0 if wants_open else 0.0
	var speed = 2.6 if door_target > door_open else 1.7
	door_open = move_toward(door_open, door_target, delta * speed)
	if door_open > 0.05 and not door_chime_played:
		door_chime_played = true
	elif door_open < 0.02:
		door_chime_played = false

func draw_wall_door(a: Vector2, b: Vector2, th: Dictionary) -> void:
	var u0 = DOOR_U0
	var u1 = DOOR_U0 + DOOR_W
	var v1 = DOOR_V

	# Opening: the dark corridor beyond, and a wedge of light on the floor when
	# the door is open.
	wall_quad(a, b, u0, u1, 0.0, v1, Color(0.05, 0.045, 0.06))
	if door_open > 0.02:
		var lip0 = wall_pt(a, b, u0, 0.0)
		var lip1 = wall_pt(a, b, u1, 0.0)
		var into = (perp_axis(a, b)) * (58.0 * door_open)
		draw_colored_polygon(PackedVector2Array([lip0, lip1, lip1 + into, lip0 + into]),
			Color(1.0, 0.88, 0.60, 0.13 * door_open))

	# Frame
	var frame = shade(th["door_col"], 0.62)
	wall_quad(a, b, u0 - 0.018, u0, 0.0, v1 + 0.03, frame)
	wall_quad(a, b, u1, u1 + 0.018, 0.0, v1 + 0.03, frame)
	wall_quad(a, b, u0 - 0.018, u1 + 0.018, v1, v1 + 0.03, frame)

	# The leaf. Hinged at u0; its free edge swings from along-the-wall to
	# into-the-room as `door_open` goes 0 -> 1.
	var hinge_bottom = wall_pt(a, b, u0, 0.0)
	var hinge_top = wall_pt(a, b, u0, v1)
	var along = wall_pt(a, b, u1, 0.0) - hinge_bottom
	var leaf_len = along.length()
	var swing = (PI * 0.46) * door_open
	var dir = along.normalized() * cos(swing) + perp_axis(a, b) * sin(swing)
	var free_bottom = hinge_bottom + dir * leaf_len
	var free_top = free_bottom + (hinge_top - hinge_bottom)

	var leaf_col = shade(th["door_col"], 1.0 - 0.28 * door_open)
	draw_colored_polygon(PackedVector2Array([hinge_bottom, free_bottom, free_top, hinge_top]), leaf_col)
	draw_polyline(PackedVector2Array([hinge_bottom, free_bottom, free_top, hinge_top, hinge_bottom]),
		shade(leaf_col, 0.55), 1.8)
	# recessed panel + glazed light in the leaf
	var inset_b = hinge_bottom.lerp(free_bottom, 0.16)
	var inset_f = hinge_bottom.lerp(free_bottom, 0.84)
	var up = (hinge_top - hinge_bottom)
	draw_colored_polygon(PackedVector2Array([
		inset_b + up * 0.10, inset_f + up * 0.10, inset_f + up * 0.46, inset_b + up * 0.46
	]), shade(leaf_col, 0.82))
	draw_colored_polygon(PackedVector2Array([
		inset_b + up * 0.56, inset_f + up * 0.56, inset_f + up * 0.88, inset_b + up * 0.88
	]), Color(0.55, 0.78, 0.86, 0.5))
	# handle on the free edge
	draw_circle(hinge_bottom.lerp(free_bottom, 0.82) + up * 0.48, 2.6, Color(0.88, 0.82, 0.52))

# The floor axis perpendicular to a wall, pointing into the room.
func perp_axis(a: Vector2, b: Vector2) -> Vector2:
	var d = (b - a).normalized()
	# In a 2:1 projection the two floor axes are (±w/2, h/2); the perpendicular
	# of one is the other with its x mirrored.
	return Vector2(-d.x, d.y).normalized()

# ══════════════════════════════════════════════════════════════
# 🧍 CHARACTER SPRITES
# The character art is full-body, roughly 1:2 tall, sitting inside a 1024²
# canvas with 30-60% empty padding. It was being blitted as the whole square
# texture into a square 48x48 rect, which squashed every character to half
# height and shrank them to a blob inside their own padding. These are the
# measured opaque bounds of each file; the sprite is drawn from that region at
# its true aspect and anchored at the feet.
# ══════════════════════════════════════════════════════════════

# Desk art has the same defect the characters had: pieces inside a 1024² canvas
# blitted as the whole square into a square rect. Their real content ranges from
# 0.79 (tall booth) to 1.37 (wide island), so the booth was squashed and the
# island stretched. Measured opaque bounds:
const DESK_CONTENT: Dictionary = {
	"open":   Rect2(102, 107, 856, 841),
	"vip":    Rect2(117, 72, 802, 878),
	"booth":  Rect2(128, 30, 768, 967),
	"island": Rect2(53, 222, 918, 669)
}

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
		"floor": Color(0.30, 0.21, 0.14, 0.92),
		"floor_line": Color(0.12, 0.08, 0.05),
		"grid": Color(0.55, 0.42, 0.30),
		"panel": Color(0.12, 0.10, 0.08, 0.45),
		"wall_face": Color(0.40, 0.30, 0.22),
		"door_col": Color(0.55, 0.38, 0.24),
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
		"floor": Color(0.26, 0.14, 0.19, 0.92),
		"floor_line": Color(0.12, 0.06, 0.09),
		"grid": Color(0.66, 0.50, 0.62),
		"panel": Color(0.14, 0.09, 0.14, 0.5),
		"wall_face": Color(0.33, 0.20, 0.30),
		"door_col": Color(0.46, 0.30, 0.42),
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
		"wall_face": Color(0.26, 0.34, 0.38),
		"door_col": Color(0.38, 0.48, 0.50),
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

# An outdoor terrace table: the rooftop was showing indoor partition booths,
# which made no sense on an open-air deck. Drawn procedurally rather than from
# the indoor desk art.
func draw_terrace_table(tile_center: Vector2, s: float, seat_index: int) -> void:
	draw_prop_shadow(tile_center, 30 * s, 15 * s)
	# slatted round table top on a cross base
	draw_iso_cylinder(tile_center, 5.0 * s, 2.6 * s, 26.0 * s, Color(0.30, 0.24, 0.19))
	var top = tile_center + Vector2(0, -26 * s)
	draw_iso_cylinder(top, 26.0 * s, 13.0 * s, 4.5 * s, Color(0.52, 0.37, 0.25))
	for sl in range(4):
		var off = (-16 + sl * 10.5) * s
		draw_line(top + Vector2(off, -9 * s), top + Vector2(off, 9 * s), Color(0.38, 0.27, 0.18, 0.7), 1.4 * s)

	# laptop and a cold drink actually on the table
	draw_colored_polygon(PackedVector2Array([
		top + Vector2(-13 * s, -7 * s), top + Vector2(1 * s, -1 * s),
		top + Vector2(1 * s, -16 * s), top + Vector2(-13 * s, -22 * s)
	]), Color(0.72, 0.78, 0.84))
	draw_iso_prism(top + Vector2(-6 * s, 3 * s), 9 * s, 4.5 * s, 2 * s, Color(0.26, 0.27, 0.30))
	draw_iso_cylinder(top + Vector2(13 * s, 2 * s), 3.6 * s, 1.9 * s, 10 * s, Color(0.66, 0.84, 0.72, 0.9))

	# two woven chairs, and a parasol on every other table
	for side in [-1.0, 1.0]:
		var cp = tile_center + Vector2(31 * s * side, 15 * s * side)
		draw_iso_cylinder(cp, 9.0 * s, 4.5 * s, 15.0 * s, Color(0.44, 0.34, 0.24))
		draw_iso_prism(cp + Vector2(0, -15 * s), 10 * s, 5 * s, 15 * s, Color(0.36, 0.30, 0.24))
	if seat_index % 2 == 0:
		draw_prop("parasol", tile_center + Vector2(0, -2 * s), s * 0.62)

# ── Where the fixtures stand ──────────────────────────────────
# Study-room props sit on cells just OUTSIDE the placeable 6x4 grid, so they
# dress the walls without ever stealing a tile the player wants for a desk.
const FLOOR_PROPS: Dictionary = {
	2: [
		{"kind": "bookshelf",  "cell": Vector2i(0, 1)},
		{"kind": "floor_lamp", "cell": Vector2i(1, 1)},
		{"kind": "bookshelf",  "cell": Vector2i(2, 1)},
		{"kind": "floor_lamp", "cell": Vector2i(4, 1)},
		{"kind": "sofa",       "cell": Vector2i(0, 8)},
		{"kind": "floor_lamp", "cell": Vector2i(2, 8)},
		{"kind": "plant",      "cell": Vector2i(4, 8)},
		{"kind": "bin",        "cell": Vector2i(5, 8)},
	],
	3: [
		{"kind": "planter",      "cell": Vector2i(0, 1)},
		{"kind": "planter",      "cell": Vector2i(1, 1)},
		{"kind": "patio_heater", "cell": Vector2i(2, 1)},
		{"kind": "parasol",      "cell": Vector2i(4, 1)},
		{"kind": "planter",      "cell": Vector2i(0, 8)},
		{"kind": "parasol",      "cell": Vector2i(2, 8)},
		{"kind": "planter",      "cell": Vector2i(4, 8)},
		{"kind": "bin",          "cell": Vector2i(5, 8)},
	]
}

const ROOM1_PROPS: Array = [
	{"kind": "bookshelf",  "cell": Vector2i(0, 1)},
	{"kind": "bookshelf",  "cell": Vector2i(1, 1)},
	{"kind": "printer",    "cell": Vector2i(2, 1)},
	{"kind": "water",      "cell": Vector2i(3, 1)},
	{"kind": "plant",      "cell": Vector2i(4, 1)},
	{"kind": "sofa",       "cell": Vector2i(0, 8)},
	{"kind": "floor_lamp", "cell": Vector2i(2, 8)},
	{"kind": "plant",      "cell": Vector2i(4, 8)},
	{"kind": "bin",        "cell": Vector2i(5, 8)},
]

# The coffee bar has its own smaller isometric frame inside the lounge panel:
# a real counter run with a machine, a pastry case, stools and a back shelf,
# replacing the single flat coffee_bar.png that used to be pasted here.
const LOUNGE_ANCHOR_CELL: Vector2i = Vector2i(7, 0)
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
	return GameState.iso_to_screen(LOUNGE_ANCHOR_CELL) + Vector2(
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
		var is_back = c.y < GameState.STUDY_Y0
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

# Four desk variants instead of two - desk_island_2p.png was being loaded and
# then never drawn. The variant is stable per seat so a desk keeps its shape
# when the player moves it.
func desk_variant(seat_index: int, is_booth: bool) -> String:
	if is_booth:
		return "booth"
	match seat_index % 3:
		0: return "open"
		1: return "vip"
	return "island"

func desk_texture_for(key: String) -> Texture2D:
	match key:
		"booth": return desk_booth_texture
		"vip": return desk_vip_texture
		"island": return desk_island_texture
	return desk_open_texture

# Draws a desk from its content region, at the art's own aspect, standing on the
# centre of its isometric tile.
func draw_desk_art(seat_index: int, is_booth: bool, tile_center: Vector2, target_h: float) -> bool:
	# The rooftop gets terrace furniture, not indoor partition booths.
	if GameState.current_floor == 3:
		draw_terrace_table(tile_center, target_h / 96.0, seat_index)
		return true
	var key = desk_variant(seat_index, is_booth)
	var tex = desk_texture_for(key)
	if tex == null:
		return false
	var src: Rect2 = DESK_CONTENT[key]
	var size = Vector2(target_h * (src.size.x / src.size.y), target_h)
	var bottom = tile_center.y + GameState.ISO_TILE_HEIGHT * 0.5 + target_h * 0.06
	draw_texture_rect_region(tex, Rect2(Vector2(tile_center.x - size.x * 0.5, bottom - size.y), size),
		src, Color(1, 1, 1, 0.98))
	return true

func get_desk_sprite_size(seat_index: int) -> Vector2:
	var is_booth = seat_index >= GameState.upgrades["open_seats"]["level"] * 3
	var side = GameState.ISO_TILE_WIDTH * (1.18 if is_booth else 1.05)
	return Vector2(side, side)

# Desk art is anchored bottom-centre on the isometric tile it stands on, which is
# what makes a sprite read as "sitting on" a diamond floor tile. The extra sink
# accounts for the transparent padding under the furniture in the source art.
func get_desk_rect(seat_index: int) -> Rect2:
	var tile_center = GameState.get_seat_position(seat_index)
	if GameState.current_floor == 3:
		var r = GameState.ISO_TILE_WIDTH * 0.62
		return Rect2(tile_center - Vector2(r, r * 0.9), Vector2(r * 2.0, r * 1.5))
	var is_booth = seat_index >= GameState.upgrades["open_seats"]["level"] * 3
	var target_h = get_desk_sprite_size(seat_index).y
	var src: Rect2 = DESK_CONTENT[desk_variant(seat_index, is_booth)]
	var size = Vector2(target_h * (src.size.x / src.size.y), target_h)
	var bottom_y = tile_center.y + GameState.ISO_TILE_HEIGHT * 0.5 + target_h * 0.06
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
