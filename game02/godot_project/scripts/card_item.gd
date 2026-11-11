class_name CardItem
extends PanelContainer

signal clicked(item)

@onready var cover_rect: ColorRect = $VBox/CoverContainer/CoverRect
@onready var cover_icon: Label = $VBox/CoverContainer/CoverIcon
@onready var cat_badge: Label = $VBox/CoverContainer/CatBadge
@onready var vol_badge: Label = $VBox/CoverContainer/VolBadge
@onready var title_label: Label = $VBox/InfoContainer/TitleLabel
@onready var author_label: Label = $VBox/InfoContainer/AuthorLabel
@onready var status_label: Label = $VBox/InfoContainer/StatusLabel

var current_item = null

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(current_item)

func setup(item) -> void:
	current_item = item
	title_label.text = item.title
	author_label.text = item.author_or_series if item.author_or_series != "" else "시리즈 미상"
	status_label.text = item.status_tag
	
	if item.category == 0: # MANGA
		cat_badge.text = "만화"
		cat_badge.modulate = Color(0.39, 0.4, 0.95) # Indigo
		cover_rect.color = Color(0.2, 0.25, 0.35)
		cover_icon.text = "📖"
		var vols = item.volumes.size()
		vol_badge.visible = true
		vol_badge.text = str(vols) + "권 소장"
	else: # GACHA
		cat_badge.text = "가챠"
		cat_badge.modulate = Color(0.95, 0.3, 0.5) # Rose
		cover_rect.color = Color(0.35, 0.2, 0.3)
		cover_icon.text = "🔮"
		vol_badge.visible = false
