from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Set


ROOT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT_DIR / "data"
SAVE_PATH = ROOT_DIR / "runtime" / "reports" / "savegame.json"
REPORT_REVIEW_DOCUMENTS = [
    "chat_alice_late_help",
    "note_john_contingency_map",
    "log_alice_dm_read",
    "mail_alice_unsent_escalation",
]


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
        self.story_bible = self._load_json("story/season_01/story_bible.json")
        self.clues_data = self._load_json("clues.json")
        self.gates_data = self._load_json("chapter_gates.json")
        self.documents_data = self._load_json("documents.json")
        self.chapter_packs = self._load_chapter_packs()
        self.chapter_arc = {
            row["chapter"]: row
            for row in self.story_bible.get("chapter_emotional_arc", [])
        }

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

    def _load_chapter_packs(self) -> Dict[int, dict]:
        story_dir = self.data_dir / "story"
        packs: Dict[int, dict] = {}
        for path in sorted(story_dir.glob("chapter_*/*_content_pack.json")):
            with path.open("r", encoding="utf-8") as f:
                payload = json.load(f)
            chapter_number = self._chapter_number(payload.get("chapter_id", ""))
            if chapter_number is not None:
                packs[chapter_number] = payload
        return packs

    @staticmethod
    def _chapter_number(chapter_id: str) -> int | None:
        if not chapter_id.startswith("chapter_"):
            return None
        try:
            return int(chapter_id.split("_")[-1])
        except ValueError:
            return None

    def story_brief(self) -> dict:
        max_chapter = max(self.chapter_packs.keys(), default=self.state.current_chapter)
        current_chapter = min(self.state.current_chapter, max_chapter)
        current_pack = self.chapter_packs.get(current_chapter, {})
        current_arc = self.chapter_arc.get(current_chapter, {})

        roadmap = []
        for chapter in range(current_chapter + 1, min(current_chapter + 2, max_chapter) + 1):
            pack = self.chapter_packs.get(chapter, {})
            arc = self.chapter_arc.get(chapter, {})
            roadmap.append(
                {
                    "chapter": chapter,
                    "title": pack.get("title") or arc.get("title") or f"챕터 {chapter}",
                    "hook": pack.get("chapter_question") or pack.get("story_goal", ""),
                    "feelings": arc.get("player_feeling", pack.get("emotional_focus", [])),
                }
            )

        return {
            "current": {
                "chapter": current_chapter,
                "title": current_pack.get("title") or current_arc.get("title") or f"챕터 {current_chapter}",
                "story_goal": current_pack.get("story_goal", ""),
                "chapter_question": current_pack.get("chapter_question", ""),
                "emotional_focus": current_pack.get(
                    "emotional_focus", current_arc.get("player_feeling", [])
                ),
                "screen_beats": current_pack.get("screen_beats", []),
            },
            "roadmap": roadmap,
        }

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

    def solved_clue_count(self) -> int:
        return len(self.state.discovered_clues)

    def total_clue_count(self) -> int:
        return len(self.clues)

    def report_review_documents(self) -> List[str]:
        return REPORT_REVIEW_DOCUMENTS.copy()

    def investigation_stage(self) -> str:
        if self.can_submit():
            return "최종 보고 단계"
        if self.state.current_chapter <= 1:
            return "초기 진술 검증 단계"
        if self.state.current_chapter == 2:
            return "용의선상 재정렬 단계"
        return "은폐 구조 재구성 단계"

    def next_step(self) -> str:
        unsolved = [clue for clue in self.list_clues() if clue.clue_id not in self.state.discovered_clues]
        if not unsolved:
            return (
                "세 단서를 모두 확보했습니다. 바로 제출하기보다 "
                f"{', '.join(self.report_review_documents())} 문서를 다시 읽고, "
                "내가 누구의 설명을 빌려 여기까지 왔는지 먼저 정리하세요."
            )

        target = unsolved[0]
        missing_documents = [doc_id for doc_id in target.required_documents if doc_id not in self.state.opened_documents]
        available_documents = [doc_id for doc_id in missing_documents if doc_id in self.state.unlocked_documents]

        if available_documents:
            return (
                f"다음 표적 단서는 '{target.name}' 입니다. "
                f"먼저 {', '.join(available_documents)} 문서를 열람해 근거를 모으세요."
            )

        if not missing_documents:
            return f"'{target.name}' 단서의 필수 문서를 모두 읽었습니다. 우측 단서 카드에서 추론 버튼을 눌러 정리하세요."

        return (
            f"아직 '{target.name}' 단서에 필요한 문서가 잠겨 있습니다. "
            "현재 챕터의 단서를 먼저 확정하면 다음 기록이 열립니다."
        )

    def report_guidance(self) -> str:
        if not self.can_submit():
            remaining = [
                clue.name
                for clue in self.list_clues()
                if clue.clue_id not in self.state.discovered_clues
            ]
            return (
                "최종 보고서는 세 단서를 모두 확보한 뒤 열립니다. "
                f"남은 정리 대상: {', '.join(remaining)}"
            )

        return (
            "지금 필요한 건 새 증거가 아니라, 이미 읽은 기록을 누구의 말 없이 다시 읽는 일입니다. "
            "보고서는 세 줄로 정리하면 됩니다. "
            "범인에는 기록의 방향을 통제한 인물, 동기에는 왜 진실을 비틀었는지, "
            "방법에는 어떤 로그/타임라인 조작이 있었는지를 적으세요. "
            f"추천 재검토: {', '.join(self.report_review_documents())}"
        )

    def _assess_report(self, culprit: str, motive: str, method: str) -> dict:
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
        return {
            "culprit_ok": culprit_ok,
            "motive_ok": motive_ok,
            "method_ok": method_ok,
        }

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
        if self.can_submit():
            lines.append(
                "재검토 권장: "
                + ", ".join(self.report_review_documents())
            )
            lines.append(
                "지금 필요한 건 범인을 급히 적는 일보다, 내가 누구의 설명을 믿고 여기까지 왔는지 다시 읽는 일이다."
            )
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
            "story_brief": self.story_brief(),
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
        assessment = self._assess_report(culprit, motive, method)

        if assessment["culprit_ok"] and assessment["motive_ok"] and assessment["method_ok"]:
            return (
                "[진실 엔딩]\n"
                "당신은 범인, 동기, 수법을 모두 정확히 연결했다.\n"
                "앨리스는 존을 보호하고 자신이 설계한 해석 방향을 유지하려고 기록의 시간축을 비틀었다.\n"
                "공식 발표는 철회되고 내부 공모 정황은 별도 수사로 넘어간다."
            )

        lines = [
            "[부분 정답 엔딩]",
            "사건의 방향은 잡았지만 보고서가 아직 완성되지는 않았습니다.",
            "",
            "재검토 가이드",
            (
                "범인: 적절합니다."
                if assessment["culprit_ok"]
                else "범인: 플레이어를 돕는 척하면서 기록 접근권과 시간축 통제권을 동시에 가진 인물을 다시 보세요."
            ),
            (
                "동기: 적절합니다."
                if assessment["motive_ok"]
                else "동기: 단순한 적대감보다 보호, 은폐, 죄책감이 섞인 이유를 찾아야 합니다."
            ),
            (
            "방법: 적절합니다."
                if assessment["method_ok"]
                else "방법: 출입 기록, 인증 로그, VPN 재작성 흔적처럼 시간축을 비튼 조작 방식을 명시해야 합니다."
            ),
            "",
            "추천 재열람 문서",
            "- chat_alice_late_help",
            "- note_john_contingency_map",
            "- log_alice_dm_read",
            "- mail_alice_unsent_escalation",
            "",
            "사건은 재조사로 넘어가고, 보고서가 모호한 탓에 일부 책임 소재는 흐려집니다.",
        ]
        return "\n".join(lines)

    def can_submit(self) -> bool:
        return set(self.case_data["solution_conditions"]).issubset(self.state.discovered_clues)

    def submit_report(self, culprit: str, motive: str, method: str) -> str:
        if not self.can_submit():
            remaining = [
                clue.name
                for clue in self.list_clues()
                if clue.clue_id not in self.state.discovered_clues
            ]
            return (
                "아직 최종 보고서를 제출할 수 없습니다. "
                f"먼저 남은 단서를 확보하세요: {', '.join(remaining)}"
            )
        if not culprit.strip() or not motive.strip() or not method.strip():
            return (
                "범인 / 동기 / 방법을 모두 입력해야 합니다.\n"
                "범인: 누가 기록의 방향을 통제했는가\n"
                "동기: 왜 진실을 감추거나 비틀었는가\n"
                "방법: 어떤 로그/타임라인 조작이 있었는가"
            )
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
