extends RefCounted
class_name InvestigationState

var current_chapter: int = 1
var unlocked_documents: Array[String] = []
var opened_documents: Array[String] = []
var bookmarks: Array[String] = []
var discovered_clues: Array[String] = []
var active_document_id: String = ""

func to_payload(case_id: String) -> Dictionary:
    return {
        "case_id": case_id,
        "current_chapter": current_chapter,
        "unlocked_documents": unlocked_documents,
        "opened_documents": opened_documents,
        "bookmarks": bookmarks,
        "discovered_clues": discovered_clues,
        "active_document_id": active_document_id,
    }

static func create_initial(case_data: CaseData) -> InvestigationState:
    var state := InvestigationState.new()
    state.current_chapter = 1
    state.unlocked_documents = case_data.documents_unlocked.duplicate()
    return state

static func from_payload(case_data: CaseData, payload: Dictionary) -> InvestigationState:
    var state := InvestigationState.new()
    state.current_chapter = int(payload.get("current_chapter", 1))
    state.unlocked_documents = _coerce_string_array(payload.get("unlocked_documents", case_data.documents_unlocked))
    state.opened_documents = _coerce_string_array(payload.get("opened_documents", []))
    state.bookmarks = _coerce_string_array(payload.get("bookmarks", []))
    state.discovered_clues = _coerce_string_array(payload.get("discovered_clues", []))
    state.active_document_id = str(payload.get("active_document_id", ""))
    return state

static func _coerce_string_array(raw: Variant) -> Array[String]:
    var result: Array[String] = []
    for entry in raw:
        result.append(str(entry))
    return result
