class_name UiTokens
extends RefCounted

const THEMES := {
	"millie": {
		"name": "밀리 화이트",
		"bg": Color("#FFFFFF"),
		"bg_subtle": Color("#F7F7F7"),
		"surface": Color("#FFFFFF"),
		"surface_soft": Color("#F2F2F2"),
		"border": Color("#EAEAEA"),
		"ink": Color("#242424"),
		"ink_sub": Color("#6F6F6F"),
		"ink_muted": Color("#A0A0A0"),
		"millie": Color("#FFEB60"),
		"millie_ink": Color("#242424"),
		"accent": Color("#242424"),
		"accent_soft": Color("#FFF7BD"),
		"sage": Color("#2F7D57"),
		"sage_soft": Color("#EAF6EF"),
		"danger": Color("#C53030"),
		"danger_soft": Color("#FEECEC"),
		"hl_bg": Color("#FFEB60"),
		"hl_ink": Color("#242424"),
		"shadow": Color(0.0, 0.0, 0.0, 0.08)
	},
	"paper": {
		"name": "웜 페이퍼",
		"bg": Color("#FAF7F2"),
		"bg_subtle": Color("#F2ECE3"),
		"surface": Color("#FFFDF9"),
		"surface_soft": Color("#EFE8DD"),
		"border": Color("#E6DDD0"),
		"ink": Color("#26201C"),
		"ink_sub": Color("#74675E"),
		"ink_muted": Color("#A3968B"),
		"millie": Color("#FFE670"),
		"millie_ink": Color("#26201C"),
		"accent": Color("#C85A32"),
		"accent_soft": Color("#FDF1EC"),
		"sage": Color("#3D6B59"),
		"sage_soft": Color("#ECF4F0"),
		"danger": Color("#C53030"),
		"danger_soft": Color("#FEECEC"),
		"hl_bg": Color("#FFE670"),
		"hl_ink": Color("#26201C"),
		"shadow": Color(0.14, 0.11, 0.08, 0.08)
	},
	"dark": {
		"name": "미드나잇",
		"bg": Color("#141414"),
		"bg_subtle": Color("#1D1D1D"),
		"surface": Color("#1F1F1F"),
		"surface_soft": Color("#2A2A2A"),
		"border": Color("#303030"),
		"ink": Color("#F5F5F5"),
		"ink_sub": Color("#A8A8A8"),
		"ink_muted": Color("#757575"),
		"millie": Color("#F5DC4C"),
		"millie_ink": Color("#181818"),
		"accent": Color("#F5DC4C"),
		"accent_soft": Color(0.96, 0.86, 0.30, 0.18),
		"sage": Color("#5AC18E"),
		"sage_soft": Color(0.35, 0.76, 0.56, 0.16),
		"danger": Color("#F87171"),
		"danger_soft": Color(0.97, 0.44, 0.44, 0.16),
		"hl_bg": Color(0.96, 0.86, 0.30, 0.28),
		"hl_ink": Color("#F5DC4C"),
		"shadow": Color(0.0, 0.0, 0.0, 0.36)
	}
}

const SHOWCASE_STYLES := {
	"acrylic": {
		"name": "아크릴 화이트",
		"bg": Color("#F2F5FA"),
		"border": Color("#DCE3EC"),
		"shelf": Color(0.84, 0.89, 0.95, 0.85),
		"pedestal": Color("#E2E7EE"),
		"plaque_bg": Color(1, 1, 1, 0.88),
		"plaque_ink": Color("#242424"),
		"sub_ink": Color("#6B7280")
	},
	"wood": {
		"name": "우드 장식장",
		"bg": Color("#EFE4D4"),
		"border": Color("#D6C1A5"),
		"shelf": Color("#C9AE8B"),
		"pedestal": Color("#DFCCB4"),
		"plaque_bg": Color(1, 0.98, 0.95, 0.9),
		"plaque_ink": Color("#2A2118"),
		"sub_ink": Color("#73604C")
	},
	"museum": {
		"name": "뮤지엄 다크",
		"bg": Color("#1A1B20"),
		"border": Color("#2E3038"),
		"shelf": Color(1, 1, 1, 0.16),
		"pedestal": Color("#2F323B"),
		"plaque_bg": Color(1, 1, 1, 0.10),
		"plaque_ink": Color("#F5F5F5"),
		"sub_ink": Color("#9CA3AF")
	}
}

const COVER_COLORS := [
	"#C82342", "#0077B6", "#D9480F", "#DB2777", "#6D28D9", "#2E5947"
]

const INK_PRESETS := [
	{"name": "에스프레소", "hex": "#2C221E"},
	{"name": "버건디", "hex": "#8C2D3B"},
	{"name": "세피아", "hex": "#7D542E"},
	{"name": "포레스트", "hex": "#2E5947"}
]

const STAMP_PRESETS := ["전권완결", "초판특전", "인생최애", "소장중", "위시"]

static func get_palette(theme_id: String) -> Dictionary:
	if theme_id == "cream":
		return THEMES["millie"]
	if theme_id == "sepia":
		return THEMES["paper"]
	return THEMES.get(theme_id, THEMES["millie"])

static func get_showcase_style(style_id: String) -> Dictionary:
	return SHOWCASE_STYLES.get(style_id, SHOWCASE_STYLES["acrylic"])

static func make_box(bg: Color, radius: int = 14, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0, pad_x: int = 12, pad_y: int = 8, shadow_col: Color = Color(0, 0, 0, 0), shadow_sz: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	if border_w > 0:
		sb.border_width_left = border_w
		sb.border_width_top = border_w
		sb.border_width_right = border_w
		sb.border_width_bottom = border_w
		sb.border_color = border_col
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	if shadow_sz > 0:
		sb.shadow_color = shadow_col
		sb.shadow_size = shadow_sz
		sb.shadow_offset = Vector2(0, 3)
	return sb

static func make_cover_box(base_color: Color, r_left: int = 5, r_right: int = 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = base_color
	sb.corner_radius_top_left = r_left
	sb.corner_radius_bottom_left = r_left
	sb.corner_radius_top_right = r_right
	sb.corner_radius_bottom_right = r_right
	sb.border_width_left = 7
	sb.border_color = base_color.darkened(0.28)
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.16)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	return sb

static func make_dome_box(base_color: Color, border_col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = base_color
	sb.corner_radius_top_left = 54
	sb.corner_radius_top_right = 54
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = border_col
	sb.shadow_color = Color(0.0, 0.0, 0.0, 0.14)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 4)
	return sb

static func make_sheet_box(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = 26
	sb.corner_radius_top_right = 26
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.shadow_color = Color(0, 0, 0, 0.24)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, -4)
	return sb

static func style_button(btn: Button, bg: Color, fg: Color, radius: int = 12, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0, pad_x: int = 12, pad_y: int = 6) -> void:
	if btn == null:
		return
	var normal_sb := make_box(bg, radius, border_col, border_w, pad_x, pad_y)
	var hover_sb := make_box(bg.lightened(0.05) if bg.v < 0.5 else bg.darkened(0.04), radius, border_col, border_w, pad_x, pad_y)
	var pressed_sb := make_box(bg.darkened(0.08), radius, border_col, border_w, pad_x, pad_y)
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", fg)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

static func style_line_edit(le: LineEdit, p: Dictionary, bg_override: Color = Color(0, 0, 0, 0)) -> void:
	if le == null:
		return
	var bg: Color = p["surface"] if bg_override.a == 0.0 else bg_override
	var normal_sb := make_box(bg, 12, p["border"], 1, 12, 8)
	var focus_sb := make_box(bg, 12, p["ink"], 1, 12, 8)
	le.add_theme_stylebox_override("normal", normal_sb)
	le.add_theme_stylebox_override("focus", focus_sb)
	le.add_theme_color_override("font_color", p["ink"])
	le.add_theme_color_override("font_placeholder_color", p["ink_muted"])
	le.add_theme_color_override("caret_color", p["ink"])

static func style_text_edit(te: TextEdit, p: Dictionary) -> void:
	if te == null:
		return
	var normal_sb := make_box(p["surface"], 12, p["border"], 1, 12, 10)
	var focus_sb := make_box(p["surface"], 12, p["ink"], 1, 12, 10)
	te.add_theme_stylebox_override("normal", normal_sb)
	te.add_theme_stylebox_override("focus", focus_sb)
	te.add_theme_color_override("font_color", p["ink"])
	te.add_theme_color_override("font_placeholder_color", p["ink_muted"])
	te.add_theme_color_override("caret_color", p["ink"])

static func import_cover_image(src_path: String) -> String:
	if src_path.strip_edges().is_empty():
		return ""
	var img := Image.new()
	var err := img.load(src_path)
	if err != OK or img.is_empty():
		return ""
	var max_dim := 900
	var w := img.get_width()
	var h := img.get_height()
	if w > max_dim or h > max_dim:
		var scale := float(max_dim) / float(maxi(w, h))
		img.resize(maxi(1, int(round(w * scale))), maxi(1, int(round(h * scale))), Image.INTERPOLATE_LANCZOS)
	DirAccess.make_dir_recursive_absolute("user://covers")
	var dest_path := "user://covers/cover_%d_%d.png" % [Time.get_unix_time_from_system(), randi() % 10000]
	if img.save_png(dest_path) != OK:
		return ""
	return dest_path

static func load_cover_texture(cover_path: String) -> ImageTexture:
	var clean := cover_path.strip_edges()
	if clean.is_empty():
		return null
	var real_path := ProjectSettings.globalize_path(clean) if clean.begins_with("user://") or clean.begins_with("res://") else clean
	if not FileAccess.file_exists(clean) and not FileAccess.file_exists(real_path):
		return null
	var img := Image.new()
	var err := img.load(real_path)
	if err != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)

static func open_image_picker(owner: Node, on_selected: Callable) -> void:
	if owner == null:
		return
	var fd := FileDialog.new()
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.use_native_dialog = true
	fd.title = "표지 사진 선택"
	fd.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; 이미지 파일"])
	fd.file_selected.connect(func(path: String):
		var saved := import_cover_image(path)
		if on_selected.is_valid():
			on_selected.call(saved, path.get_file())
		fd.queue_free()
	)
	fd.canceled.connect(func(): fd.queue_free())
	owner.add_child(fd)
	fd.popup_centered_ratio(0.6)

static func theme_ds_tree(root: Node, p: Dictionary) -> void:
	if root == null:
		return
	for ch in root.get_children():
		if ch.is_in_group("ds_component") and ch.has_method("apply_theme"):
			ch.apply_theme(p)
		theme_ds_tree(ch, p)
