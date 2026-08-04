extends RefCounted
class_name ChapterGate

var chapter_id: String = ""
var required_clues: Array[String] = []
var unlock_targets: Array[String] = []

static func from_dict(payload: Dictionary) -> ChapterGate:
    var value := ChapterGate.new()
    value.chapter_id = str(payload.get("chapter_id", ""))
    for clue_id in payload.get("required_clues", []):
        value.required_clues.append(str(clue_id))
    for doc_id in payload.get("unlock_targets", []):
        value.unlock_targets.append(str(doc_id))
    return value
