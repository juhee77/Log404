class_name AddModal
extends Control

signal item_submitted(title: String, category: int, author: String)

@onready var title_input: LineEdit = $Panel/VBox/Body/TitleInput
@onready var author_input: LineEdit = $Panel/VBox/Body/AuthorInput
@onready var cat_option: OptionButton = $Panel/VBox/Body/CatOption

func _ready() -> void:
	visible = false
	cat_option.clear()
	cat_option.add_item("📖 만화 단행본", 0)
	cat_option.add_item("🔮 가챠·피규어", 1)

func open() -> void:
	title_input.text = ""
	author_input.text = ""
	cat_option.selected = 0
	visible = true

func close() -> void:
	visible = false

func _on_close_btn_pressed() -> void:
	close()

func _on_submit_btn_pressed() -> void:
	var t = title_input.text.strip_edges()
	if t.is_empty():
		return
	var cat = cat_option.selected
	var a = author_input.text.strip_edges()
	item_submitted.emit(t, cat, a)
	close()

