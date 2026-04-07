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

    def _serialize_document(self, doc: Document) -> dict:
        return {
            "doc_id": doc.doc_id,
            "source_type": doc.source_type,
            "title": doc.title,
            "chapter": doc.chapter,
            "opened": doc.doc_id in self.engine.state.opened_documents,
            "bookmarked": doc.doc_id in self.engine.state.bookmarks,
        }

    def snapshot(self, source_type: str = "all", search_keyword: str = "") -> dict:
        documents = [
            self._serialize_document(doc)
            for doc in self.engine.list_documents(source_type=source_type, search_keyword=search_keyword)
        ]
        bookmarks = [self._serialize_document(doc) for doc in self.engine.list_bookmarks()]
        clues = [
            {
                "clue_id": clue.clue_id,
                "name": clue.name,
                "description": clue.description,
                "chapter": clue.chapter,
                "solved": clue.clue_id in self.engine.state.discovered_clues,
            }
            for clue in self.engine.list_clues()
        ]

        active_doc = None
        if self.active_doc_id and self.active_doc_id in self.engine.documents and self.active_doc_id in self.engine.state.unlocked_documents:
            doc = self.engine.documents[self.active_doc_id]
            active_doc = self._serialize_document(doc)
            active_doc["content"] = self.engine.open_document(self.active_doc_id)

        return {
            "case_title": self.engine.state.case_title,
            "objective": self.engine.state.objective,
            "chapter": min(self.engine.state.current_chapter, 3),
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
                if doc_id in SESSION.engine.documents and doc_id in SESSION.engine.state.unlocked_documents:
                    SESSION.active_doc_id = doc_id
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/bookmark":
                doc_id = payload.get("doc_id", "")
                message = SESSION.engine.toggle_bookmark(doc_id)
                SESSION.last_message = message
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/infer":
                clue_id = payload.get("clue_id", "")
                message = SESSION.engine.infer_clue(clue_id)
                SESSION.last_message = message
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/save":
                message = SESSION.engine.save()
                SESSION.last_message = message
                response = {"message": message, "state": SESSION.snapshot(source_type, search_keyword)}
                self._send_json(response)
                return

            if parsed.path == "/api/load":
                message = SESSION.engine.load()
                SESSION.last_message = message
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
