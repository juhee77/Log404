extends Node
class_name SaveService

const SAVE_PATH := "user://savegame.json"

func write_save(payload: Dictionary) -> Dictionary:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return {"ok": false, "message": "저장 파일을 생성할 수 없습니다: %s" % SAVE_PATH}
    file.store_string(JSON.stringify(payload, "	"))
    return {"ok": true, "message": "저장 완료: %s" % SAVE_PATH}

func read_save() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {"ok": false, "message": "저장 파일이 없습니다: %s" % SAVE_PATH}

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return {"ok": false, "message": "저장 파일을 읽을 수 없습니다: %s" % SAVE_PATH}

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed == null:
        return {"ok": false, "message": "저장 파일이 손상되었습니다: %s" % SAVE_PATH}
    return {"ok": true, "message": "불러오기 완료: %s" % SAVE_PATH, "payload": parsed}
