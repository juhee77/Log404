class_name CardItem
extends PanelContainer

signal clicked(item)

@onready var cover_rect: ColorRect = $VBox/CoverContainer/CoverRect
@onready var spine_strip: ColorRect = $VBox/CoverContainer/SpineStrip
@onready var cover_icon: Label = $VBox/CoverContainer/CoverIcon
@onready var cat_badge: Label = $VBox/CoverContainer/CatBadge
@onready var vol_badge: Label = $VBox/CoverContainer/VolBadge
@onready var sticker_badge: Label = $VBox/CoverContainer/StickerBadge
@onready var obi_panel: PanelContainer = $VBox/CoverContainer/ObiPanel
@onready var obi_label: Label = $VBox/CoverContainer/ObiPanel/ObiLabel
@onready var title_label: Label = $VBox/InfoMargin/InfoContainer/TitleLabel
@onready var author_label: Label = $VBox/InfoMargin/InfoContainer/AuthorLabel
@onready var status_label: Label = $VBox/InfoMargin/InfoContainer/StatusLabel

var current_item = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(current_item)

func setup(item) -> void:
	current_item = item
	title_label.text = item.title
	author_label.text = item.author_or_series if item.author_or_series != "" else "시리즈 미상"
	
	# 스티커 뱃지
	if item.status_tag != "":
		sticker_badge.visible = true
		sticker_badge.text = " " + item.status_tag + " "
	else:
		sticker_badge.visible = false

	# 표지 배경색 & 아이콘
	var base_col = Color.from_string(item.cover_color, Color(0.25, 0.3, 0.55))
	cover_rect.color = base_col
	spine_strip.color = base_col.darkened(0.28)
	cover_icon.text = item.icon_emoji if item.icon_emoji != "" else ("📖" if item.category == 0 else "🔮")

	# 하단 띠지 (Obi Band)
	if item.obi_text != "":
		obi_panel.visible = true
		obi_label.text = item.obi_text
	else:
		obi_panel.visible = false

	if item.category == 0: # MANGA
		cat_badge.text = " 만화 "
		var vols = item.volumes.size()
		vol_badge.visible = true
		vol_badge.text = str(vols) + "권 소장 "
		status_label.text = "📖 단행본 " + str(vols) + "권 기록중"
	else: # GACHA
		cat_badge.text = " 가챠 "
		vol_badge.visible = false
		status_label.text = "🔮 아크릴 쇼케이스"
