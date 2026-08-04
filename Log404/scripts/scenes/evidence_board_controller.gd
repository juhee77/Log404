extends Control
class_name EvidenceBoardController

@onready var summary_label: Label = $Margin/VBox/SummaryLabel
@onready var board_content: VBoxContainer = $Margin/VBox/Scroll/BoardContent

func _ready() -> void:
    AppState.state_changed.connect(refresh_from_app_state)
    refresh_from_app_state()

func refresh_from_app_state() -> void:
    var snapshot := AppState.get_status_snapshot()
    summary_label.text = "현재 확보 단서 %d/%d · 챕터 %d/3" % [
        int(snapshot.get("discovered_clues", 0)),
        int(snapshot.get("total_clues", 0)),
        int(snapshot.get("current_chapter", 1)),
    ]

    for child in board_content.get_children():
        child.queue_free()

    var discovered: Array[Dictionary] = []
    for clue in AppState.get_clues():
        if bool(clue.get("discovered", false)):
            discovered.append(clue)

    if discovered.is_empty():
        var empty := Label.new()
        empty.text = "아직 보드에 올릴 단서가 없습니다. 문서를 읽고 추론을 진행하세요."
        empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        board_content.add_child(empty)
        return

    for clue in discovered:
        var panel := PanelContainer.new()
        panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var box := VBoxContainer.new()
        box.add_theme_constant_override("separation", 6)
        panel.add_child(box)

        var title := Label.new()
        title.text = str(clue.get("name", ""))
        title.add_theme_font_size_override("font_size", 18)
        box.add_child(title)

        var meta := Label.new()
        meta.text = "Ch%d · %s" % [int(clue.get("chapter", 1)), String(clue.get("source_type", ""))]
        box.add_child(meta)

        var body := Label.new()
        body.text = str(clue.get("description", ""))
        body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        box.add_child(body)

        board_content.add_child(panel)
