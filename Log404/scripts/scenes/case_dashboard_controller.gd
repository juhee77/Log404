extends Control
class_name CaseDashboardController

@onready var case_title: Label = $Margin/MainVBox/HeaderBox/CaseTitle
@onready var objective: Label = $Margin/MainVBox/HeaderBox/Objective
@onready var progress: Label = $Margin/MainVBox/HeaderBox/Progress
@onready var status_message: Label = $Margin/MainVBox/StatusMessage
@onready var workspace: Control = $Margin/MainVBox/Tabs/DocumentWorkspace
@onready var evidence_board: Control = $Margin/MainVBox/Tabs/EvidenceBoard
@onready var final_report: Control = $Margin/MainVBox/Tabs/FinalReport

func _ready() -> void:
    AppState.state_changed.connect(_refresh_header)
    AppState.message_emitted.connect(_show_message)
    _refresh_header()

func prepare_session() -> void:
    AppState.ensure_bootstrapped()
    _refresh_header()
    workspace.refresh_from_app_state()
    evidence_board.refresh_from_app_state()
    final_report.refresh_from_app_state()

func _refresh_header() -> void:
    if not is_inside_tree():
        return
    var snapshot := AppState.get_status_snapshot()
    case_title.text = str(snapshot.get("case_title", "LOG:404"))
    objective.text = str(snapshot.get("objective", ""))
    progress.text = "챕터 %d/3 · 열람 문서 %d · 확보 단서 %d/%d · 북마크 %d" % [
        int(snapshot.get("current_chapter", 1)),
        int(snapshot.get("opened_documents", 0)),
        int(snapshot.get("discovered_clues", 0)),
        int(snapshot.get("total_clues", 0)),
        int(snapshot.get("bookmarks", 0)),
    ]

func _show_message(message: String, _level: String) -> void:
    status_message.text = message
