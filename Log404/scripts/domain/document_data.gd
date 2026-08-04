extends RefCounted
class_name DocumentData

var doc_id: String = ""
var source_type: String = ""
var title: String = ""
var chapter: int = 1
var content: String = ""

static func from_dict(payload: Dictionary) -> DocumentData:
    var value := DocumentData.new()
    value.doc_id = str(payload.get("id", ""))
    value.source_type = str(payload.get("source_type", ""))
    value.title = str(payload.get("title", ""))
    value.chapter = int(payload.get("chapter", 1))
    value.content = str(payload.get("content", ""))
    return value
