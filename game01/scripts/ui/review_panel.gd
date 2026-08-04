extends PanelContainer

# review_panel.gd - Real-time Customer Reviews Interface for Study Cafe Tycoon

signal closed

@onready var container_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ListContainer
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose

func _ready() -> void:
	if btn_close:
		btn_close.pressed.connect(func(): hide(); closed.emit())
	GameState.review_added.connect(func(_r): refresh_reviews())
	refresh_reviews()

func refresh_reviews() -> void:
	if not container_list: return
	
	for child in container_list.get_children():
		child.queue_free()
		
	if GameState.reviews_log.size() == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "아직 작성된 손님 리뷰가 없습니다."
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		container_list.add_child(empty_lbl)
		return
		
	for rev in GameState.reviews_log:
		var card = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)
		
		var vbox = VBoxContainer.new()
		margin.add_child(vbox)
		
		var header_hbox = HBoxContainer.new()
		vbox.add_child(header_hbox)
		
		var author_lbl = Label.new()
		author_lbl.text = "%s [%s]" % [rev["author"], rev["time"]]
		author_lbl.add_theme_color_override("font_color", Color(0.06, 0.72, 0.5))
		author_lbl.add_theme_font_size_override("font_size", 13)
		author_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(author_lbl)
		
		var rating_lbl = Label.new()
		rating_lbl.text = "⭐ %.1f" % rev["rating"]
		rating_lbl.add_theme_color_override("font_color", Color(0.96, 0.62, 0.07))
		rating_lbl.add_theme_font_size_override("font_size", 13)
		header_hbox.add_child(rating_lbl)
		
		var text_lbl = Label.new()
		text_lbl.text = rev["text"]
		text_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
		text_lbl.add_theme_font_size_override("font_size", 14)
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(text_lbl)
		
		container_list.add_child(card)
