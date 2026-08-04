#!/usr/bin/env python3
"""LOG:404 CLI vertical-slice prototype.

Docs-aligned MVP:
- 1 case
- 3 chapters
- clue/chapter unlocking via JSON data
- 2 endings (truth / partial)
"""

from __future__ import annotations

try:
    from game.engine import GameEngine
except ModuleNotFoundError:  # direct script execution
    from engine import GameEngine


def print_help() -> None:
    print(
        """
명령어:
  help                         도움말
  status                       현재 진행 상태
  list [source_type]           해금 문서 목록 (예: list mail)
  open <doc_id>                문서 열람
  search <keyword>             해금 문서 내 검색
  bookmark <doc_id>            북마크 토글
  bookmarks                    북마크 목록
  clues                        추론 가능한 단서 목록
  infer <clue_id>              단서 추론 시도
  submit                       최종 보고서 제출
  save                         저장
  load                         불러오기
  quit                         종료
""".strip()
    )


def main() -> None:
    game = GameEngine()

    print("=" * 60)
    print("LOG:404 - 삭제된 사건 기록 (CLI Prototype)")
    print("=" * 60)
    print(game.status())
    print("\n힌트: 먼저 `list` -> `open <doc_id>` -> `infer <clue_id>` 순서로 진행해 보세요.")

    while True:
        try:
            raw = input("\nlog404> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n종료합니다.")
            break

        if not raw:
            continue

        parts = raw.split()
        cmd = parts[0].lower()
        args = parts[1:]

        if cmd in {"quit", "exit"}:
            print("수사 세션을 종료합니다.")
            break

        if cmd == "help":
            print_help()
            continue

        if cmd == "status":
            print(game.status())
            continue

        if cmd == "list":
            source_type = args[0] if args else None
            docs = game.list_documents(source_type=source_type)
            if not docs:
                print("표시할 문서가 없습니다.")
                continue
            for doc in docs:
                mark = "*" if doc.doc_id in game.state.bookmarks else " "
                opened = "(read)" if doc.doc_id in game.state.opened_documents else ""
                print(f"{mark} {doc.doc_id:<16} [{doc.source_type:<11}] {doc.title} {opened}")
            continue

        if cmd == "open":
            if not args:
                print("사용법: open <doc_id>")
                continue
            print(game.open_document(args[0]))
            continue

        if cmd == "search":
            if not args:
                print("사용법: search <keyword>")
                continue
            keyword = " ".join(args)
            hits = game.search_documents(keyword)
            if not hits:
                print("검색 결과가 없습니다.")
                continue
            for doc in hits:
                print(f"- {doc.doc_id}: {doc.title}")
            continue

        if cmd == "bookmark":
            if not args:
                print("사용법: bookmark <doc_id>")
                continue
            print(game.toggle_bookmark(args[0]))
            continue

        if cmd == "bookmarks":
            docs = game.list_bookmarks()
            if not docs:
                print("북마크된 문서가 없습니다.")
                continue
            for doc in docs:
                print(f"- {doc.doc_id}: {doc.title}")
            continue

        if cmd == "clues":
            for clue in game.list_clues():
                state = "완료" if clue.clue_id in game.state.discovered_clues else "미완료"
                print(f"- {clue.clue_id}: {clue.name} [{state}]")
            continue

        if cmd == "infer":
            if not args:
                print("사용법: infer <clue_id>")
                continue
            print(game.infer_clue(args[0]))
            continue

        if cmd == "save":
            print(game.save())
            continue

        if cmd == "load":
            print(game.load())
            continue

        if cmd == "submit":
            if not game.can_submit():
                print("아직 최종 보고서를 제출할 수 없습니다. 단서를 더 확보하세요.")
                continue

            culprit = input("범인 입력: ").strip()
            motive = input("동기 입력: ").strip()
            method = input("방법 입력: ").strip()
            print(game.submit_report(culprit, motive, method))
            continue

        print(f"알 수 없는 명령어: {cmd}. `help`를 입력하세요.")


if __name__ == "__main__":
    main()
