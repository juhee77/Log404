extends RefCounted
class_name ClueData

var clue_id: String = ""
var chapter: int = 1
var source_type: String = ""
var name: String = ""
var description: String = ""
var required_documents: Array[String] = []

static func from_dict(payload: Dictionary) -> ClueData:
    var value := ClueData.new()
    value.clue_id = str(payload.get("clue_id", ""))
    value.chapter = int(payload.get("chapter", 1))
    value.source_type = str(payload.get("source_type", ""))
    value.name = str(payload.get("name", ""))
    value.description = str(payload.get("description", ""))
    for doc_id in payload.get("required_documents", []):
        value.required_documents.append(str(doc_id))
    return value
