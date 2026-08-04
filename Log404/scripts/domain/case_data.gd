extends RefCounted
class_name CaseData

var case_id: String = ""
var title: String = ""
var objective: String = ""
var documents_unlocked: Array[String] = []
var solution_conditions: Array[String] = []

static func from_dict(payload: Dictionary) -> CaseData:
    var value := CaseData.new()
    value.case_id = str(payload.get("case_id", ""))
    value.title = str(payload.get("title", ""))
    value.objective = str(payload.get("objective", ""))
    value.documents_unlocked = _to_string_array(payload.get("documents_unlocked", []))
    value.solution_conditions = _to_string_array(payload.get("solution_conditions", []))
    return value

static func _to_string_array(raw: Variant) -> Array[String]:
    var result: Array[String] = []
    for entry in raw:
        result.append(str(entry))
    return result
