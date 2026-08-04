extends Control
class_name WorkspaceController

var _selected_source_type := ""
var _search_keyword := ""

@onready var workspace_title: Label = $Margin/MainVBox/WorkspaceHeader/WorkspaceTitle
@onready var workspace_objective: Label = $Margin/MainVBox/WorkspaceHeader/WorkspaceObjective
@onready var document_list_panel: DocumentListPanel = $Margin/MainVBox/WorkspaceSplit/DocumentListPanel
@onready var document_view_panel: DocumentViewPanel = $Margin/MainVBox/WorkspaceSplit/DocumentViewPanel
@onready var clue_panel: CluePanel = $Margin/MainVBox/WorkspaceSplit/RightColumn/CluePanel
@onready var bookmark_panel: BookmarkPanel = $Margin/MainVBox/WorkspaceSplit/RightColumn/BookmarkPanel
@onready var report_panel: ReportPanel = $Margin/MainVBox/WorkspaceSplit/RightColumn/ReportPanel
@onready var search_bar: SearchBar = $Margin/MainVBox/SearchBar

func _ready() -> void:
    document_list_panel.document_open_requested.connect(_on_document_open_requested)
    document_list_panel.bookmark_toggled.connect(_on_bookmark_toggled)
    document_list_panel.filter_changed.connect(_on_filter_changed)
    clue_panel.infer_requested.connect(_on_infer_requested)
    bookmark_panel.open_requested.connect(_on_bookmark_open_requested)
    report_panel.submit_requested.connect(_on_submit_requested)
    search_bar.search_requested.connect(_on_search_requested)
    search_bar.reset_requested.connect(_on_reset_requested)
    search_bar.save_requested.connect(func() -> void: AppState.save_game())
    search_bar.load_requested.connect(func() -> void: AppState.load_game())
    AppState.state_changed.connect(refresh_from_app_state)
    AppState.message_emitted.connect(_show_message)
    refresh_from_app_state()

func refresh_from_app_state() -> void:
    var snapshot := AppState.get_status_snapshot()
    workspace_title.text = str(snapshot.get("case_title", "사건 조사"))
    workspace_objective.text = str(snapshot.get("objective", ""))
    document_list_panel.set_source_types(AppState.get_source_types(), _selected_source_type)
    document_list_panel.set_documents(AppState.get_documents(_selected_source_type, _search_keyword))
    document_view_panel.show_document(AppState.get_active_document_payload())
    clue_panel.set_clues(AppState.get_clues())
    bookmark_panel.set_bookmarks(AppState.get_bookmarks())
    report_panel.set_submit_enabled(AppState.can_submit_report())
    report_panel.set_status_text(AppState.get_last_report_result())

func _show_message(message: String, _level: String) -> void:
    search_bar.set_status(message)
    if message.begins_with("[") or message.find("입력") != -1 or message.find("제출") != -1:
        report_panel.set_status_text(message)

func _on_document_open_requested(doc_id: String) -> void:
    AppState.open_document(doc_id)

func _on_bookmark_toggled(doc_id: String) -> void:
    AppState.toggle_bookmark(doc_id)

func _on_filter_changed(source_type: String) -> void:
    _selected_source_type = "" if source_type == "전체" else source_type
    refresh_from_app_state()

func _on_infer_requested(clue_id: String) -> void:
    AppState.infer_clue(clue_id)

func _on_bookmark_open_requested(doc_id: String) -> void:
    AppState.open_document(doc_id)

func _on_search_requested(keyword: String) -> void:
    _search_keyword = keyword.strip_edges()
    refresh_from_app_state()
    if _search_keyword == "":
        search_bar.set_status("검색어를 입력하세요.")
    else:
        search_bar.set_status("검색 적용: %s" % _search_keyword)

func _on_reset_requested() -> void:
    _search_keyword = ""
    search_bar.clear_search()
    refresh_from_app_state()
    search_bar.set_status("검색을 초기화했습니다.")

func _on_submit_requested(culprit: String, motive: String, method: String) -> void:
    AppState.submit_report(culprit, motive, method)
