extends VBoxContainer
class_name BookmarkPanel

signal open_requested(doc_id: String)

@onready var bookmark_list: ItemList = $BookmarkList
@onready var open_button: Button = $OpenButton

func _ready() -> void:
    bookmark_list.item_activated.connect(_on_item_activated)
    open_button.pressed.connect(_on_open_pressed)

func set_bookmarks(bookmarks: Array[Dictionary]) -> void:
    bookmark_list.clear()
    for document in bookmarks:
        var label := "%s [%s]" % [String(document.get("title", "")), String(document.get("source_type", ""))]
        bookmark_list.add_item(label)
        bookmark_list.set_item_metadata(bookmark_list.item_count - 1, String(document.get("id", "")))

func _on_item_activated(index: int) -> void:
    open_requested.emit(str(bookmark_list.get_item_metadata(index)))

func _on_open_pressed() -> void:
    var selected := bookmark_list.get_selected_items()
    if selected.is_empty():
        return
    open_requested.emit(str(bookmark_list.get_item_metadata(selected[0])))
