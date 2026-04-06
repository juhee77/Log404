extends VBoxContainer
class_name DocumentListPanel

signal document_open_requested(doc_id: String)
signal bookmark_toggled(doc_id: String)
signal filter_changed(source_type: String)

@onready var source_filter: OptionButton = $SourceFilter
@onready var documents_list: ItemList = $DocumentsList
@onready var open_button: Button = $ActionRow/OpenButton
@onready var bookmark_button: Button = $ActionRow/BookmarkButton

func _ready() -> void:
    source_filter.item_selected.connect(_on_filter_selected)
    documents_list.item_selected.connect(_on_item_selected)
    documents_list.item_activated.connect(_on_item_activated)
    open_button.pressed.connect(_on_open_pressed)
    bookmark_button.pressed.connect(_on_bookmark_pressed)

func set_source_types(source_types: Array[String], selected_source_type: String) -> void:
    source_filter.clear()
    source_filter.add_item("전체")
    for source_type in source_types:
        source_filter.add_item(source_type)
    var selected_index := 0
    if selected_source_type != "" and selected_source_type != "전체":
        for index in range(source_filter.item_count):
            if source_filter.get_item_text(index) == selected_source_type:
                selected_index = index
                break
    source_filter.select(selected_index)

func set_documents(documents: Array[Dictionary]) -> void:
    documents_list.clear()
    for document in documents:
        var prefix := ""
        if bool(document.get("bookmarked", false)):
            prefix += "★ "
        if bool(document.get("opened", false)):
            prefix += "열람 "
        var label := "Ch%d · %s[%s] %s" % [
            int(document.get("chapter", 1)),
            prefix,
            String(document.get("source_type", "")),
            String(document.get("title", "")),
        ]
        documents_list.add_item(label)
        documents_list.set_item_metadata(documents_list.item_count - 1, String(document.get("id", "")))

func get_selected_document_id() -> String:
    var selected := documents_list.get_selected_items()
    if selected.is_empty():
        return ""
    return str(documents_list.get_item_metadata(selected[0]))

func _on_filter_selected(index: int) -> void:
    filter_changed.emit(source_filter.get_item_text(index))

func _on_item_selected(_index: int) -> void:
    pass

func _on_item_activated(index: int) -> void:
    var doc_id := str(documents_list.get_item_metadata(index))
    document_open_requested.emit(doc_id)

func _on_open_pressed() -> void:
    var doc_id := get_selected_document_id()
    if doc_id != "":
        document_open_requested.emit(doc_id)

func _on_bookmark_pressed() -> void:
    var doc_id := get_selected_document_id()
    if doc_id != "":
        bookmark_toggled.emit(doc_id)
