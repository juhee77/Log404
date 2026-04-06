extends Node

const CASE_PATH := "res://data/cases/case_001.json"
const DOCUMENTS_PATH := "res://data/documents.json"
const CLUES_PATH := "res://data/clues.json"
const CHAPTER_GATES_PATH := "res://data/chapter_gates.json"

func load_case() -> CaseData:
    var payload = _load_json(CASE_PATH, {})
    return CaseData.from_dict(payload)

func load_documents_dict() -> Dictionary:
    var rows: Array = _load_json(DOCUMENTS_PATH, [])
    var result := {}
    for row in rows:
        var document := DocumentData.from_dict(row)
        result[document.doc_id] = document
    return result

func load_clues_dict() -> Dictionary:
    var rows: Array = _load_json(CLUES_PATH, [])
    var result := {}
    for row in rows:
        var clue := ClueData.from_dict(row)
        result[clue.clue_id] = clue
    return result

func load_chapter_gates() -> Array[ChapterGate]:
    var rows: Array = _load_json(CHAPTER_GATES_PATH, [])
    var result: Array[ChapterGate] = []
    for row in rows:
        result.append(ChapterGate.from_dict(row))
    return result

func list_source_types(documents: Dictionary) -> Array[String]:
    var source_types := {}
    for document in documents.values():
        source_types[document.source_type] = true
    var result: Array[String] = []
    for source_type in source_types.keys():
        result.append(str(source_type))
    result.sort()
    return result

func _load_json(path: String, fallback: Variant) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("LOG:404 failed to open %s" % path)
        return fallback

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed == null:
        push_error("LOG:404 failed to parse %s" % path)
        return fallback
    return parsed
