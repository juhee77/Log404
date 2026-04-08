#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

try:
    from game.engine import Document, GameEngine
except ModuleNotFoundError:  # direct script execution
    from engine import Document, GameEngine


WEB_DIR = Path(__file__).resolve().parent.parent / "web"


class GameSession:
    def __init__(self) -> None:
        self.engine = GameEngine()
        self.active_doc_id: str | None = None
        self.lock = threading.Lock()
        self.last_message = "사건 파일을 펼쳤습니다. 좌측 문서를 열어 모순부터 확인하세요."
        self.last_report_message = "최종 보고서는 아직 작성되지 않았습니다."
        self.activity_log = ["사건 파일을 펼쳤습니다. 좌측 문서를 열어 모순부터 확인하세요."]

    def _serialize_document(self, doc: Document) -> dict:
        return {
            "doc_id": doc.doc_id,
            "source_type": doc.source_type,
            "title": doc.title,
            "chapter": doc.chapter,
            "opened": doc.doc_id in self.engine.state.opened_documents,
            "bookmarked": doc.doc_id in self.engine.state.bookmarks,
        }

    def _record_activity(self, message: str) -> None:
        headline = message.strip().splitlines()[0] if message.strip() else "알 수 없는 작업"
        entry = f"챕터 {min(self.engine.state.current_chapter, 3)} · {headline}"
        self.activity_log = [entry, *self.activity_log[:6]]

    def _serialize_clue(self, clue) -> dict:
        opened_required = sum(
            1 for doc_id in clue.required_documents if doc_id in self.engine.state.opened_documents
        )
        missing_documents = [
            doc_id for doc_id in clue.required_documents if doc_id not in self.engine.state.opened_documents
        ]
        return {
            "clue_id": clue.clue_id,
            "name": clue.name,
            "description": clue.description,
            "chapter": clue.chapter,
            "solved": clue.clue_id in self.engine.state.discovered_clues,
            "required_count": len(clue.required_documents),
            "opened_required_count": opened_required,
            "missing_documents": missing_documents,
            "ready_to_infer": not missing_documents and clue.clue_id not in self.engine.state.discovered_clues,
        }

    def _suspect_board(self) -> list[dict]:
        discovered = self.engine.state.discovered_clues
        return [
            {
                "name": "Alice Han",
                "role": "플레이어 조력자 / 운영 접근권 보유",
                "status": (
                    "핵심 조작자"
                    if "clue_alice_tampered_truth" in discovered
                    else "조력자인 척하는 고위험 인물"
                ),
                "score": 5 if "clue_alice_tampered_truth" in discovered else 3,
                "note": (
                    "도움의 말투와 별개로 DM 열람 기록과 재작성 흔적이 겹친다."
                    if "clue_alice_tampered_truth" in discovered
                    else "존의 기록에 먼저 접근할 수 있었던 인물인지 계속 확인해야 한다."
                ),
            },
            {
                "name": "Jones",
                "role": "거친 동료 / 초반 용의선상",
                "status": (
                    "희생양에 가까움"
                    if "clue_jones_false_face" in discovered
                    else "표면상 가장 수상함"
                ),
                "score": 1 if "clue_jones_false_face" in discovered else 4,
                "note": (
                    "사적인 기록을 보면 존을 버린 인물보다 뒤늦게 수습하려 한 인물에 가깝다."
                    if "clue_jones_false_face" in discovered
                    else "거친 발언과 실제 행동 사이에 간극이 있는지 확인이 필요하다."
                ),
            },
            {
                "name": "John Kim",
                "role": "실종자 / 피해자",
                "status": (
                    "강요된 퇴사 서사"
                    if "clue_empty_resignation" in discovered
                    else "자발적 퇴사처럼 위장됨"
                ),
                "score": 0,
                "note": (
                    "미전송 초안의 감정과 공식 퇴사 공지의 문체가 너무 다르다."
                    if "clue_empty_resignation" in discovered
                    else "퇴사 서사가 지나치게 깔끔하다. 공백 자체가 단서일 수 있다."
                ),
            },
        ]

    def _report_presets(self) -> list[dict]:
        if not self.engine.can_submit():
            return []
        return [
            {"field": "culprit", "label": "범인 힌트", "value": "앨리스"},
            {"field": "motive", "label": "동기 힌트", "value": "존을 보호하려던 은폐와 죄책감"},
            {"field": "method", "label": "방법 힌트", "value": "로그 조작과 시간축 재작성"},
        ]

    def snapshot(self, source_type: str = "all", search_keyword: str = "") -> dict:
        documents = [
            self._serialize_document(doc)
            for doc in self.engine.list_documents(source_type=source_type, search_keyword=search_keyword)
        ]
        bookmarks = [self._serialize_document(doc) for doc in self.engine.list_bookmarks()]
        clues = [self._serialize_clue(clue) for clue in self.engine.list_clues()]

        active_doc = None
        if self.active_doc_id and self.active_doc_id in self.engine.documents and self.active_doc_id in self.engine.state.unlocked_documents:
            doc = self.engine.documents[self.active_doc_id]
            active_doc = self._serialize_document(doc)
            active_doc["content"] = self.engine.open_document(self.active_doc_id)

        return {
            "case_title": self.engine.state.case_title,
            "objective": self.engine.state.objective,
            "chapter": min(self.engine.state.current_chapter, 3),
            "story_brief": self.engine.story_brief(),
            "opened_count": len(self.engine.state.opened_documents),
            "clue_count": len(self.engine.state.discovered_clues),
            "total_clue_count": self.engine.total_clue_count(),
            "bookmark_count": len(self.engine.state.bookmarks),
            "can_submit": self.engine.can_submit(),
            "stage_label": self.engine.investigation_stage(),
            "next_step": self.engine.next_step(),
            "report_guidance": self.engine.report_guidance(),
            "source_types": self.engine.list_source_types(),
            "last_message": self.last_message,
            "last_report_message": self.last_report_message,
            "activity_log": self.activity_log,
            "suspects": self._suspect_board(),
            "report_presets": self._report_presets(),
            "documents": documents,
            "bookmarks": bookmarks,
            "clues": clues,
            "active_document": active_doc,
        }


SESSION = GameSession()


class Log404Handler(BaseHTTPRequestHandler):
    server_version = "LOG404Web/0.1"

    def _read_json(self) -> dict:
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b"{}"
        return json.loads(raw.decode("utf-8")) if raw else {}

    def _send_bytes(self, body: bytes, content_type: str, status: int = HTTPStatus.OK) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_json(self, payload: dict, status: int = HTTPStatus.OK) -> None:
        self._send_bytes(json.dumps(payload, ensure_ascii=False).encode("utf-8"), "application/json; charset=utf-8", status)

    def _serve_static(self, relative_path: str) -> None:
        file_path = WEB_DIR / relative_path
        if not file_path.exists():
            self._send_json({"error": "not_found"}, HTTPStatus.NOT_FOUND)
            return
        content_type = {
            ".html": "text/html; charset=utf-8",
            ".css": "text/css; charset=utf-8",
            ".js": "application/javascript; charset=utf-8",
        }.get(file_path.suffix, "text/plain; charset=utf-8")
        self._send_bytes(file_path.read_bytes(), content_type)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path in {"/", "/index.html"}:
            self._serve_static("index.html")
            return
        if parsed.path == "/styles.css":
            self._serve_static("styles.css")
            return
        if parsed.path == "/app.js":
            self._serve_static("app.js")
            return
        if parsed.path == "/api/state":
            query = parse_qs(parsed.query)
            source_type = query.get("source_type", ["all"])[0]
            search_keyword = query.get("search", [""])[0]
            with SESSION.lock:
                state = SESSION.snapshot(source_type=source_type, search_keyword=search_keyword)
            self._send_json({"message": "상태 조회 완료", "state": state})
            return
        self._send_json({"error": "not_found"}, HTTPStatus.NOT_FOUND)

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        payload = self._read_json()
        source_type = payload.get("source_type", "all")
        search_keyword = payload.get("search", "")

        with SESSION.lock:
            if parsed.path == "/api/open":
                doc_id = payload.get("doc_id", "")
                message = SESSION.engine.open_document(doc_id)
                SESSION.last_message = message
                SESSION._record_activity(f"문서 열람: {doc_id}")
                if doc_id in SESSION.engine.documents and doc_id in SESSION.engine.state.unlocked_documents:
                    SESSION.active_doc_id = doc_id
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/bookmark":
                doc_id = payload.get("doc_id", "")
                message = SESSION.engine.toggle_bookmark(doc_id)
                SESSION.last_message = message
                SESSION._record_activity(message)
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/infer":
                clue_id = payload.get("clue_id", "")
                message = SESSION.engine.infer_clue(clue_id)
                SESSION.last_message = message
                SESSION._record_activity(message)
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/save":
                message = SESSION.engine.save()
                SESSION.last_message = message
                SESSION._record_activity("수사 파일 저장")
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/load":
                message = SESSION.engine.load()
                SESSION.last_message = message
                SESSION._record_activity("저장된 수사 파일 복원")
                if SESSION.active_doc_id and SESSION.active_doc_id not in SESSION.engine.state.unlocked_documents:
                    SESSION.active_doc_id = None
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/submit":
                message = SESSION.engine.submit_report(
                    payload.get("culprit", ""),
                    payload.get("motive", ""),
                    payload.get("method", ""),
                )
                SESSION.last_message = message
                SESSION.last_report_message = message
                SESSION._record_activity("최종 보고서 제출 시도")
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

        self._send_json({"error": "not_found"}, HTTPStatus.NOT_FOUND)

    def log_message(self, format: str, *args) -> None:
        return


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the LOG:404 local web GUI")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()

    server = ThreadingHTTPServer((args.host, args.port), Log404Handler)
    print(f"LOG:404 web GUI running at http://{args.host}:{args.port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
