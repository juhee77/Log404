extends PanelContainer

# quest_panel.gd - Dynamic Story Quest UI without node path dependency

signal closed

var list_container: VBoxContainer
var btn_close: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Opaque backing: the panel had no stylebox, so the cafe showed straight
	# through the story text and made it unreadable.
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.08, 0.07, 0.98)
	sb.border_color = Color(0.96, 0.62, 0.07, 0.8)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(4)
	add_theme_stylebox_override("panel", sb)
	build_panel_ui()
	GameState.quest_updated.connect(func(_q): refresh_quest())
	refresh_quest()

func build_panel_ui() -> void:
	for child in get_children():
		child.queue_free()
		
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(main_vbox)
	
	var header = HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title = Label.new()
	title.text = "📜 메인 스토리 「등대 독서실」"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.custom_minimum_size = Vector2(80, 32)
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header.add_child(btn_close)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll)
	
	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)

func refresh_quest() -> void:
	if not list_container: return

	for child in list_container.get_children():
		child.queue_free()

	var idx = GameState.current_quest_index - 1
	if idx >= GameState.quests_data.size():
		var done = Label.new()
		done.text = "🕯️ 「등대 독서실」 완결.\n\n시험이 끝난 날, 한 아이가 문을 열고 들어와 말했다.\n\"여기 불 켜져 있어서 버텼어요.\"\n등대는, 원래 그런 일을 하는 곳이다."
		done.add_theme_font_size_override("font_size", 15)
		done.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
		list_container.add_child(done)
		return

	var q = GameState.quests_data[idx]
	var act = GameState.get_act_info(q.get("act", 1))

	# ── Act header: the chapter this quest belongs to ──────────
	if not act.is_empty():
		var act_lbl = Label.new()
		act_lbl.text = act["title"]
		act_lbl.add_theme_font_size_override("font_size", 16)
		act_lbl.add_theme_color_override("font_color", Color(0.2, 0.85, 0.55))
		list_container.add_child(act_lbl)

		var intro = Label.new()
		intro.text = act["intro"]
		intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		intro.custom_minimum_size = Vector2(430, 0)
		intro.add_theme_font_size_override("font_size", 12)
		intro.add_theme_color_override("font_color", Color(0.72, 0.70, 0.66))
		list_container.add_child(intro)
		list_container.add_child(HSeparator.new())

	# ── Current objective ─────────────────────────────────────
	var card = PanelContainer.new()
	var card_margin = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		card_margin.add_theme_constant_override("margin_" + side, 12)
	card.add_child(card_margin)

	var vbox = VBoxContainer.new()
	card_margin.add_child(vbox)

	var title_lbl = Label.new()
	title_lbl.text = "📜 %d/%d  %s" % [q["id"], GameState.quests_data.size(), q["title"]]
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
	vbox.add_child(title_lbl)

	if q.has("story"):
		var story_lbl = Label.new()
		story_lbl.text = q["story"]
		story_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		story_lbl.custom_minimum_size = Vector2(400, 0)
		story_lbl.add_theme_font_size_override("font_size", 12)
		story_lbl.add_theme_color_override("font_color", Color(0.80, 0.78, 0.72))
		vbox.add_child(story_lbl)

	var bar = ProgressBar.new()
	bar.max_value = float(q["target"])
	bar.value = float(q["current"])
	bar.custom_minimum_size = Vector2(0, 16)
	bar.show_percentage = false
	vbox.add_child(bar)

	var sub_lbl = Label.new()
	sub_lbl.text = "%s  |  진행 %s / %s  |  보상 💰 %s ₩, ✨ %d XP" % [
		_kind_hint(q), _fmt(q["current"]), _fmt(q["target"]),
		GameState.format_money(q["reward_money"]), int(q["reward_xp"])]
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.78, 0.78, 0.74))
	vbox.add_child(sub_lbl)

	list_container.add_child(card)

	# ── What is coming next, so the chain reads as a story ────
	var upcoming = []
	for n in range(idx + 1, min(idx + 4, GameState.quests_data.size())):
		upcoming.append(GameState.quests_data[n])
	if upcoming.size() > 0:
		var next_hdr = Label.new()
		next_hdr.text = "다음 이야기"
		next_hdr.add_theme_font_size_override("font_size", 12)
		next_hdr.add_theme_color_override("font_color", Color(0.55, 0.54, 0.52))
		list_container.add_child(next_hdr)
		for nq in upcoming:
			var nl = Label.new()
			nl.text = "   %d.  %s" % [nq["id"], nq["title"]]
			nl.add_theme_font_size_override("font_size", 12)
			nl.add_theme_color_override("font_color", Color(0.46, 0.45, 0.44))
			list_container.add_child(nl)

func _fmt(v) -> String:
	var f = float(v)
	return str(int(f)) if abs(f - round(f)) < 0.001 else "%.1f" % f

# Tells the player which action actually moves this quest.
func _kind_hint(q: Dictionary) -> String:
	match q.get("kind", ""):
		"roast": return "☕ 로스팅"
		"bake": return "🥐 베이킹"
		"serve": return "🫖 음료 서빙"
		"clean": return "🧹 자리 청소"
		"cast": return "🚶 길거리 캐스팅"
		"expand": return "🪑 좌석 확장"
		"decorate": return "🪴 소품 배치"
		"partition": return "🔇 칸막이 설치"
		"pet": return "🐱 나비 쓰다듬기"
		"arrange": return "🔨 책상 재배치"
		"stat": return "📈 누적 지표"
	return "진행"
