extends VBoxContainer
class_name CluePanel

signal infer_requested(clue_id: String)

@onready var clue_list: ItemList = $ClueList
@onready var detail_text: RichTextLabel = $DetailText
@onready var infer_button: Button = $InferButton

var _clues: Array[Dictionary] = []

func _ready() -> void:
    clue_list.item_selected.connect(_on_clue_selected)
    clue_list.item_activated.connect(_on_clue_activated)
    infer_button.pressed.connect(_on_infer_pressed)

func set_clues(clues: Array[Dictionary]) -> void:
    _clues = clues
    clue_list.clear()
    for clue in clues:
        var label := "Ch%d · %s [%s]" % [
            int(clue.get("chapter", 1)),
            String(clue.get("name", "")),
            "완료" if bool(clue.get("discovered", false)) else "미완료",
        ]
        clue_list.add_item(label)
        clue_list.set_item_metadata(clue_list.item_count - 1, String(clue.get("clue_id", "")))
    if clues.is_empty():
        detail_text.text = "단서가 없습니다."
    elif clue_list.item_count > 0 and clue_list.get_selected_items().is_empty():
        clue_list.select(0)
        _update_detail(0)

func _on_clue_selected(index: int) -> void:
    _update_detail(index)

func _on_clue_activated(index: int) -> void:
    var clue_id := str(clue_list.get_item_metadata(index))
    infer_requested.emit(clue_id)

func _on_infer_pressed() -> void:
    var selected := clue_list.get_selected_items()
    if selected.is_empty():
        return
    var clue_id := str(clue_list.get_item_metadata(selected[0]))
    infer_requested.emit(clue_id)

func _update_detail(index: int) -> void:
    if index < 0 or index >= _clues.size():
        detail_text.text = "단서를 선택하면 설명이 표시됩니다."
        return
    var clue := _clues[index]
    detail_text.text = "이름: %s\n상태: %s\n출처: %s\n설명: %s\n\n요구 문서: %s" % [
        String(clue.get("name", "")),
        "완료" if bool(clue.get("discovered", false)) else "미완료",
        String(clue.get("source_type", "")),
        String(clue.get("description", "")),
        ", ".join(clue.get("required_documents", [])),
    ]
