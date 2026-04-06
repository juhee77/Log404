from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Set


ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
SAVE_PATH = ROOT_DIR / "runtime" / "reports" / "savegame.json"


@dataclass
class Document:
    doc_id: str
    source_type: str
    title: str
    chapter: int
    content: str


@dataclass
class Clue:
    clue_id: str
    chapter: int
    source_type: str
    name: str
    description: str
    required_documents: List[str]


@dataclass
class GameState:
    case_id: str
    case_title: str
    objective: str
    current_chapter: int = 1
    unlocked_documents: Set[str] = field(default_factory=set)
    opened_documents: Set[str] = field(default_factory=set)
    bookmarks: Set[str] = field(default_factory=set)
    discovered_clues: Set[str] = field(default_factory=set)


class GameEngine:
    def __init__(self, data_dir: Path = DATA_DIR):
        self.data_dir = data_dir
        self.case_data = self._load_json("cases/case_001.json")
        self.clues_data = self._load_json("clues.json")
        self.gates_data = self._load_json("chapter_gates.json")
        self.documents_data = self._load_json("documents.json")

        self.documents: Dict[str, Document] = {
            row["id"]: Document(
                doc_id=row["id"],
                source_type=row["source_type"],
                title=row["title"],
                chapter=row["chapter"],
                content=row["content"],
            )
            for row in self.documents_data
        }
        self.clues: Dict[str, Clue] = {
            row["clue_id"]: Clue(
                clue_id=row["clue_id"],
                chapter=row["chapter"],
                source_type=row["source_type"],
                name=row["name"],
                description=row["description"],
                required_documents=row["required_documents"],
            )
            for row in self.clues_data
        }

        self.state = GameState(
            case_id=self.case_data["case_id"],
            case_title=self.case_data["title"],
            objective=self.case_data["objective"],
            unlocked_documents=set(self.case_data["documents_unlocked"]),
        )

    def _load_json(self, relative_path: str):
        with (self.data_dir / relative_path).open("r", encoding="utf-8") as f:
            return json.load(f)

    def list_source_types(self) -> List[str]:
        return sorted({doc.source_type for doc in self.documents.values()})

    def list_documents(
        self,
        source_type: str | None = None,
        search_keyword: str | None = None,
        bookmarks_only: bool = False,
    ) -> List[Document]:
        doc_ids = self.state.bookmarks if bookmarks_only else self.state.unlocked_documents
        docs = [self.documents[d] for d in doc_ids if d in self.documents]

        if source_type and source_type != "all":
            docs = [doc for doc in docs if doc.source_type == source_type]

        if search_keyword:
            keyword = search_keyword.lower().strip()
            if keyword:
                docs = [doc for doc in docs if keyword in f"{doc.title}\n{doc.content}".lower()]

        return sorted(docs, key=lambda doc: (doc.chapter, doc.doc_id))

    def list_clues(self) -> List[Clue]:
        return sorted(self.clues.values(), key=lambda clue: (clue.chapter, clue.clue_id))

    def list_bookmarks(self) -> List[Document]:
        return self.list_documents(bookmarks_only=True)

    def open_document(self, doc_id: str) -> str:
        if doc_id not in self.state.unlocked_documents:
            return f"잠겨 있는 문서입니다: {doc_id}"
        doc = self.documents.get(doc_id)
        if not doc:
            return f"문서를 찾을 수 없습니다: {doc_id}"
        self.state.opened_documents.add(doc_id)
        return f"[{doc.doc_id}] {doc.title}\n(source: {doc.source_type})\n\n{doc.content}"

    def search_documents(self, keyword: str) -> List[Document]:
        return self.list_documents(search_keyword=keyword)

    def toggle_bookmark(self, doc_id: str) -> str:
        if doc_id not in self.state.unlocked_documents:
            return f"잠겨 있는 문서는 북마크할 수 없습니다: {doc_id}"
        if doc_id in self.state.bookmarks:
            self.state.bookmarks.remove(doc_id)
            return f"북마크 해제: {doc_id}"
        self.state.bookmarks.add(doc_id)
        return f"북마크 추가: {doc_id}"

    def infer_clue(self, clue_id: str) -> str:
        clue = self.clues.get(clue_id)
        if not clue:
            return f"알 수 없는 단서 ID: {clue_id}"
        if clue.clue_id in self.state.discovered_clues:
            return f"이미 확보한 단서입니다: {clue.name}"

        missing = [doc_id for doc_id in clue.required_documents if doc_id not in self.state.opened_documents]
        if missing:
            missing_str = ", ".join(missing)
            return f"근거 문서 열람이 부족합니다. 먼저 열어야 할 문서: {missing_str}"

        self.state.discovered_clues.add(clue_id)
        unlocked = self._apply_chapter_gates()
        lines = [f"단서 확보: {clue.name}", f"설명: {clue.description}"]
        if unlocked:
            lines.append(f"해금된 문서: {', '.join(unlocked)}")
        return "\n".join(lines)

    def _apply_chapter_gates(self) -> List[str]:
        newly_unlocked: List[str] = []
        progressed = True

        while progressed:
            progressed = False
            for idx, gate in enumerate(self.gates_data, start=1):
                required = set(gate["required_clues"])
                if not required.issubset(self.state.discovered_clues):
                    continue

                target_chapter = idx + 1
                if target_chapter <= self.state.current_chapter:
                    continue

                for doc_id in gate["unlock_targets"]:
                    if doc_id not in self.state.unlocked_documents:
                        self.state.unlocked_documents.add(doc_id)
                        newly_unlocked.append(doc_id)

                self.state.current_chapter = target_chapter
                progressed = True

        return newly_unlocked

    def status_snapshot(self) -> dict:
        return {
            "case_title": self.state.case_title,
            "objective": self.state.objective,
            "current_chapter": min(self.state.current_chapter, 3),
            "opened_documents": len(self.state.opened_documents),
            "discovered_clues": len(self.state.discovered_clues),
            "total_clues": len(self.clues),
            "bookmarks": len(self.state.bookmarks),
            "can_submit": self.can_submit(),
        }

    def status(self) -> str:
        snapshot = self.status_snapshot()
        return (
            f"사건: {snapshot['case_title']}\n"
            f"목표: {snapshot['objective']}\n"
            f"챕터: {snapshot['current_chapter']}/3\n"
            f"열람 문서: {snapshot['opened_documents']}\n"
            f"확보 단서: {snapshot['discovered_clues']}/{snapshot['total_clues']}\n"
            f"북마크: {snapshot['bookmarks']}"
        )

    def ending(self, culprit: str, motive: str, method: str) -> str:
        culprit_ok = culprit.strip().lower() in {
            "alice",
            "alice han",
            "alice.h",
            "앨리스",
            "앨리스 한",
        }
        motive_ok = any(token in motive for token in ["은폐", "보호", "통제", "죄책감", "감추"])
        method_ok = any(
            token in method
            for token in ["로그 조작", "캐시", "타임라인", "재작성", "기록 조작"]
        )

        if culprit_ok and motive_ok and method_ok:
            return (
                "[진실 엔딩]\n"
                "당신은 범인, 동기, 수법을 모두 특정했다.\n"
                "공식 발표는 철회되고 내부 공모 정황이 수사로 이관된다."
            )

        return (
            "[부분 정답 엔딩]\n"
            "핵심 은폐 정황은 밝혔지만 보고서가 완전하지 않다.\n"
            "사건은 재조사로 넘어가며, 일부 관련자는 책임을 피한다."
        )

    def can_submit(self) -> bool:
        return set(self.case_data["solution_conditions"]).issubset(self.state.discovered_clues)

    def submit_report(self, culprit: str, motive: str, method: str) -> str:
        if not self.can_submit():
            return "아직 최종 보고서를 제출할 수 없습니다. 단서를 더 확보하세요."
        if not culprit.strip() or not motive.strip() or not method.strip():
            return "범인 / 동기 / 방법을 모두 입력해야 합니다."
        return self.ending(culprit, motive, method)

    def save(self, path: Path = SAVE_PATH) -> str:
        path.parent.mkdir(parents=True, exist_ok=True)
        payload = {
            "case_id": self.state.case_id,
            "current_chapter": self.state.current_chapter,
            "unlocked_documents": sorted(self.state.unlocked_documents),
            "opened_documents": sorted(self.state.opened_documents),
            "bookmarks": sorted(self.state.bookmarks),
            "discovered_clues": sorted(self.state.discovered_clues),
        }
        with path.open("w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)
        return f"저장 완료: {path}"

    def load(self, path: Path = SAVE_PATH) -> str:
        if not path.exists():
            return f"저장 파일이 없습니다: {path}"
        with path.open("r", encoding="utf-8") as f:
            payload = json.load(f)

        self.state.current_chapter = payload["current_chapter"]
        self.state.unlocked_documents = set(payload["unlocked_documents"])
        self.state.opened_documents = set(payload["opened_documents"])
        self.state.bookmarks = set(payload["bookmarks"])
        self.state.discovered_clues = set(payload["discovered_clues"])
        return f"불러오기 완료: {path}"
