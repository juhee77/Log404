extends Node
class_name AppState

signal state_changed
signal message_emitted(message: String, level: String)
signal report_submitted(result: String)

var case_data: CaseData
var documents: Dictionary = {}
var clues: Dictionary = {}
var chapter_gates: Array[ChapterGate] = []
var state: InvestigationState
var last_report_result: String = ""
var _bootstrapped := false

func _ready() -> void:
    ensure_bootstrapped()

func ensure_bootstrapped() -> void:
    if _bootstrapped:
        return
    case_data = ContentRepository.load_case()
    documents = ContentRepository.load_documents_dict()
    clues = ContentRepository.load_clues_dict()
    chapter_gates = ContentRepository.load_chapter_gates()
    state = ProgressionService.create_initial_state(case_data)
    _bootstrapped = true
    state_changed.emit()

func get_source_types() -> Array[String]:
    ensure_bootstrapped()
    return ContentRepository.list_source_types(documents)

func get_documents(source_type: String = "", search_keyword: String = "") -> Array[Dictionary]:
    ensure_bootstrapped()
    return ProgressionService.documents_for_view(state, documents, source_type, search_keyword)

func get_bookmarks() -> Array[Dictionary]:
    ensure_bootstrapped()
    return ProgressionService.documents_for_view(state, documents, "", "", true)

func get_clues() -> Array[Dictionary]:
    ensure_bootstrapped()
    return ProgressionService.clues_for_view(state, clues)

func get_active_document_payload() -> Dictionary:
    ensure_bootstrapped()
    if state.active_document_id == "":
        return {}
    var result := ProgressionService.open_document(state, documents, state.active_document_id)
    if result.get("ok", false):
        return result.get("document", {})
    return {}

func get_status_snapshot() -> Dictionary:
    ensure_bootstrapped()
    return ProgressionService.status_snapshot(state, case_data, clues)

func can_submit_report() -> bool:
    ensure_bootstrapped()
    return ProgressionService.can_submit(state, case_data)

func get_last_report_result() -> String:
    return last_report_result

func open_document(doc_id: String) -> String:
    ensure_bootstrapped()
    var result := ProgressionService.open_document(state, documents, doc_id)
    var message := str(result.get("message", ""))
    var level := "success" if bool(result.get("ok", false)) else "warning"
    _emit_state_message(message, level)
    return message

func toggle_bookmark(doc_id: String) -> String:
    ensure_bootstrapped()
    var message := ProgressionService.toggle_bookmark(state, doc_id)
    _emit_state_message(message, "info")
    return message

func infer_clue(clue_id: String) -> String:
    ensure_bootstrapped()
    var result := ProgressionService.infer_clue(state, clues, chapter_gates, clue_id)
    _emit_state_message(result.get("message", ""), result.get("level", "info"))
    return str(result.get("message", ""))

func submit_report(culprit: String, motive: String, method: String) -> String:
    ensure_bootstrapped()
    last_report_result = ProgressionService.submit_report(state, case_data, culprit, motive, method)
    var level := "success" if last_report_result.begins_with("[") else "warning"
    _emit_state_message(last_report_result, level)
    if level == "success":
        report_submitted.emit(last_report_result)
    return last_report_result

func save_game() -> String:
    ensure_bootstrapped()
    var payload := ProgressionService.serialize_state(case_data.case_id, state)
    var result := SaveService.write_save(payload)
    _emit_state_message(result.get("message", ""), "success" if result.get("ok", false) else "error")
    return str(result.get("message", ""))

func load_game() -> String:
    ensure_bootstrapped()
    var result := SaveService.read_save()
    if result.get("ok", false):
        state = ProgressionService.hydrate_state(case_data, result.get("payload", {}))
        last_report_result = ""
    _emit_state_message(result.get("message", ""), "success" if result.get("ok", false) else "warning")
    return str(result.get("message", ""))

func reset_game() -> void:
    ensure_bootstrapped()
    state = ProgressionService.create_initial_state(case_data)
    last_report_result = ""
    _emit_state_message("조사 세션을 초기화했습니다.", "info")

func _emit_state_message(message: String, level: String) -> void:
    state_changed.emit()
    message_emitted.emit(message, level)
