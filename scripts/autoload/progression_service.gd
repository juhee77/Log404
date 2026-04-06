extends Node

func create_initial_state(case_data: CaseData) -> InvestigationState:
    return InvestigationState.create_initial(case_data)

func documents_for_view(
    state: InvestigationState,
    documents: Dictionary,
    source_type: String = "",
    search_keyword: String = "",
    bookmarks_only: bool = false,
) -> Array[Dictionary]:
    var ordered_ids: Array[String] = state.bookmarks if bookmarks_only else state.unlocked_documents
    var entries: Array[Dictionary] = []
    var needle := search_keyword.strip_edges().to_lower()

    for doc_id in ordered_ids:
        if not documents.has(doc_id):
            continue
        var document: DocumentData = documents[doc_id]
        if source_type != "" and source_type != "전체" and source_type != document.source_type:
            continue
        if needle != "":
            var haystack := "%s\n%s" % [document.title, document.content]
            if needle not in haystack.to_lower():
                continue
        entries.append({
            "id": document.doc_id,
            "title": document.title,
            "source_type": document.source_type,
            "chapter": document.chapter,
            "opened": state.opened_documents.has(document.doc_id),
            "bookmarked": state.bookmarks.has(document.doc_id),
        })

    entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        if int(a["chapter"]) == int(b["chapter"]):
            return String(a["id"]) < String(b["id"])
        return int(a["chapter"]) < int(b["chapter"])
    )
    return entries

func clues_for_view(state: InvestigationState, clues: Dictionary) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for clue in clues.values():
        entries.append({
            "clue_id": clue.clue_id,
            "chapter": clue.chapter,
            "source_type": clue.source_type,
            "name": clue.name,
            "description": clue.description,
            "required_documents": clue.required_documents,
            "discovered": state.discovered_clues.has(clue.clue_id),
        })
    entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        if int(a["chapter"]) == int(b["chapter"]):
            return String(a["clue_id"]) < String(b["clue_id"])
        return int(a["chapter"]) < int(b["chapter"])
    )
    return entries

func open_document(state: InvestigationState, documents: Dictionary, doc_id: String) -> Dictionary:
    if not state.unlocked_documents.has(doc_id):
        return {"ok": false, "message": "잠겨 있는 문서입니다: %s" % doc_id}
    if not documents.has(doc_id):
        return {"ok": false, "message": "문서를 찾을 수 없습니다: %s" % doc_id}

    _append_unique(state.opened_documents, doc_id)
    state.active_document_id = doc_id
    var document: DocumentData = documents[doc_id]
    return {
        "ok": true,
        "message": "문서 열람: %s" % doc_id,
        "document": {
            "id": document.doc_id,
            "title": "%s (%s)" % [document.title, document.doc_id],
            "meta": "source: %s · chapter: %d" % [document.source_type, document.chapter],
            "content": "[%s] %s\n(source: %s)\n\n%s" % [document.doc_id, document.title, document.source_type, document.content],
        },
    }

func toggle_bookmark(state: InvestigationState, doc_id: String) -> String:
    if not state.unlocked_documents.has(doc_id):
        return "잠겨 있는 문서는 북마크할 수 없습니다: %s" % doc_id
    if state.bookmarks.has(doc_id):
        state.bookmarks.erase(doc_id)
        return "북마크 해제: %s" % doc_id
    state.bookmarks.append(doc_id)
    return "북마크 추가: %s" % doc_id

func infer_clue(state: InvestigationState, clues: Dictionary, chapter_gates: Array[ChapterGate], clue_id: String) -> Dictionary:
    if not clues.has(clue_id):
        return {"message": "알 수 없는 단서 ID: %s" % clue_id, "level": "error"}

    var clue: ClueData = clues[clue_id]
    if state.discovered_clues.has(clue.clue_id):
        return {"message": "이미 확보한 단서입니다: %s" % clue.name, "level": "warning"}

    var missing: Array[String] = []
    for doc_id in clue.required_documents:
        if not state.opened_documents.has(doc_id):
            missing.append(doc_id)
    if not missing.is_empty():
        return {
            "message": "근거 문서 열람이 부족합니다. 먼저 열어야 할 문서: %s" % ", ".join(missing),
            "level": "warning",
        }

    state.discovered_clues.append(clue_id)
    var unlocked := _apply_chapter_gates(state, chapter_gates)
    var message := "단서 확보: %s\n설명: %s" % [clue.name, clue.description]
    if not unlocked.is_empty():
        message += "\n해금된 문서: %s" % ", ".join(unlocked)
    return {"message": message, "level": "success"}

func can_submit(state: InvestigationState, case_data: CaseData) -> bool:
    return _contains_all(state.discovered_clues, case_data.solution_conditions)

func submit_report(state: InvestigationState, case_data: CaseData, culprit: String, motive: String, method: String) -> String:
    if not can_submit(state, case_data):
        return "아직 최종 보고서를 제출할 수 없습니다. 단서를 더 확보하세요."
    if culprit.strip_edges() == "" or motive.strip_edges() == "" or method.strip_edges() == "":
        return "범인 / 동기 / 방법을 모두 입력해야 합니다."
    return ending(culprit, motive, method)

func ending(culprit: String, motive: String, method: String) -> String:
    var culprit_key := culprit.strip_edges().to_lower()
    var culprit_ok := culprit_key in ["yoon", "admin_yoon", "윤", "윤 팀장"]
    var motive_ok := motive.find("은폐") != -1 or motive.find("조작") != -1 or motive.find("퇴사 공지") != -1 or motive.find("책임 회피") != -1
    var method_ok := (method.find("삭제") != -1 and method.find("배포") != -1) or (method.find("로그") != -1 and method.find("조작") != -1)

    if culprit_ok and motive_ok and method_ok:
        return "[진실 엔딩]\n당신은 범인, 동기, 수법을 모두 특정했다.\n공식 발표는 철회되고 내부 공모 정황이 수사로 이관된다."
    return "[부분 정답 엔딩]\n핵심 은폐 정황은 밝혔지만 보고서가 완전하지 않다.\n사건은 재조사로 넘어가며, 일부 관련자는 책임을 피한다."

func status_snapshot(state: InvestigationState, case_data: CaseData, clues: Dictionary) -> Dictionary:
    return {
        "case_title": case_data.title,
        "objective": case_data.objective,
        "current_chapter": mini(state.current_chapter, 3),
        "opened_documents": state.opened_documents.size(),
        "discovered_clues": state.discovered_clues.size(),
        "total_clues": clues.size(),
        "bookmarks": state.bookmarks.size(),
        "can_submit": can_submit(state, case_data),
    }

func serialize_state(case_id: String, state: InvestigationState) -> Dictionary:
    return state.to_payload(case_id)

func hydrate_state(case_data: CaseData, payload: Dictionary) -> InvestigationState:
    return InvestigationState.from_payload(case_data, payload)

func _apply_chapter_gates(state: InvestigationState, chapter_gates: Array[ChapterGate]) -> Array[String]:
    var newly_unlocked: Array[String] = []
    var progressed := true
    while progressed:
        progressed = false
        for index in range(chapter_gates.size()):
            var gate := chapter_gates[index]
            if not _contains_all(state.discovered_clues, gate.required_clues):
                continue
            var target_chapter := index + 2
            if target_chapter <= state.current_chapter:
                continue
            for doc_id in gate.unlock_targets:
                if not state.unlocked_documents.has(doc_id):
                    state.unlocked_documents.append(doc_id)
                    newly_unlocked.append(doc_id)
            state.current_chapter = target_chapter
            progressed = true
    return newly_unlocked

func _contains_all(source: Array[String], required: Array[String]) -> bool:
    for entry in required:
        if not source.has(entry):
            return false
    return true

func _append_unique(values: Array[String], entry: String) -> void:
    if not values.has(entry):
        values.append(entry)
