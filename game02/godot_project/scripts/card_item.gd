class_name CardItem
extends PanelContainer

signal clicked(item)

@onready var masking_tape: ColorRect = $VBox/TopTapeRow/MaskingTape
@onready var cover_rect: ColorRect = $VBox/CardMargin/InnerVBox/CoverContainer/CoverRect
@onready var spine_strip: ColorRect = $VBox/CardMargin/InnerVBox/CoverContainer/SpineStrip
@onready var cover_icon: Label = $VBox/CardMargin/InnerVBox/CoverContainer/CoverIcon
@onready var cat_badge: Label = $VBox/CardMargin/InnerVBox/CoverContainer/CatBadge
@onready var vol_badge: Label = $VBox/CardMargin/InnerVBox/CoverContainer/VolBadge
@onready var sticker_badge: Label = $VBox/CardMargin/InnerVBox/CoverContainer/StickerBadge
@onready var obi_panel: PanelContainer = $VBox/CardMargin/InnerVBox/CoverContainer/ObiPanel
@onready var obi_label: Label = $VBox/CardMargin/InnerVBox/CoverContainer/ObiPanel/ObiLabel
@onready var title_label: Label = $VBox/CardMargin/InnerVBox/InfoContainer/TitleLabel
@onready var author_label: Label = $VBox/CardMargin/InnerVBox/InfoContainer/AuthorLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = $VBox/CardMargin/InnerVBox/InfoContainer/ProgressRow/ProgressLabel
@onready var status_label: Label = $VBox/CardMargin/InnerVBox/InfoContainer/QuotePanel/StatusLabel

var current_item = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(current_item)

func get_reading_progress() -> float:
	if current_item == null:
		return 0.0
	if current_item.status_tag == "전권완결" or current_item.status_tag == "완독":
		return 100.0
	if current_item.volumes.size() == 0:
		return 30.0
	var vols = current_item.volumes.size()
	return clampf(float(vols) * 25.0, 20.0, 100.0)

func setup(item) -> void:
	current_item = item
	title_label.text = item.title
	var base_author = item.author_or_series if item.author_or_series != "" else "작가 미상"
	var avg_r = 5.0
	if item.volumes.size() > 0:
		var sum_r = 0.0
		for v in item.volumes:
			sum_r += float(v.get("rating", 5))
		avg_r = sum_r / float(item.volumes.size())
	author_label.text = base_author + " · ★" + String.num(avg_r, 1)

	# 독서 진행률 (E-Book 리더기 & 굿노트 독서트래커 감성)
	var prog = get_reading_progress()
	if progress_bar != null:
		progress_bar.value = prog
	if progress_label != null:
		if prog >= 100.0:
			progress_label.text = "완독 100%"
		else:
			progress_label.text = str(int(prog)) + "%"
	
	# 다꾸 도장 스탬프 (💮 전권완결, 초판특전 등)
	if item.status_tag != "":
		sticker_badge.visible = true
		sticker_badge.text = " 💮" + item.status_tag + " "
	else:
		sticker_badge.visible = false

	# 이북 표지 컬러 & 책등 접힘선 & 파스텔 와시 테이프
	var base_col = Color.from_string(item.cover_color, Color(0.65, 0.25, 0.2))
	cover_rect.color = base_col
	spine_strip.color = base_col.darkened(0.32)
	if masking_tape != null:
		var washi = base_col.lightened(0.62)
		washi.a = 0.85
		masking_tape.color = washi
	cover_icon.text = item.icon_emoji if item.icon_emoji != "" else ("📖" if item.category == 0 else "🔮")

	# 하단 띠지 (Obi Band)
	if item.obi_text != "":
		obi_panel.visible = true
		obi_label.text = item.obi_text
	else:
		obi_panel.visible = false

	# 일기장 밑줄 문장 (첫 권 명대사 또는 메모)
	var first_quote = ""
	if item.volumes.size() > 0:
		first_quote = item.volumes[0].get("quote", "")
	if first_quote == "":
		first_quote = item.memo if item.memo != "" else "나만의 소장 기록 일기"

	if item.category == 0: # MANGA
		cat_badge.text = " E-BOOK "
		var vols = item.volumes.size()
		vol_badge.visible = true
		vol_badge.text = str(vols) + "권 "
		status_label.text = "🖋️ \"" + first_quote + "\""
	else: # GACHA
		cat_badge.text = " DIARY "
		vol_badge.visible = false
		status_label.text = "🖋️ " + first_quote
