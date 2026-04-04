# 데이터 아키텍처

## 문서 메타
- 목적: 씬/스크립트/콘텐츠 데이터를 분리한 구조를 표준화한다.
- 독자: 클라이언트 개발자, 콘텐츠 저작 담당.
- 입력: 게임 루프, 챕터 구조, 데이터 소스 유형.
- 출력: 폴더 구조, 표준 타입, 콘텐츠 추가 절차.

## 권장 폴더 구조
```text
project/
  scenes/
    main_menu.tscn
    dashboard.tscn
    log_viewer.tscn
    evidence_board.tscn
  scripts/
    game_state.gd
    clue_manager.gd
    log_parser.gd
    ui_controller.gd
  data/
    cases/
      case_001.json
    logs/
    mails/
    chats/
  assets/
    fonts/
    sfx/
    icons/
```

## 표준 데이터 인터페이스
### CaseData
```json
{
  "case_id": "case_001",
  "title": "Missing Employee",
  "objective": "Find who accessed the deployment server after midnight",
  "documents_unlocked": ["mail_001", "auth_log_001"],
  "solution_conditions": ["clue_auth_mismatch", "clue_deleted_deploy"]
}
```

### ClueData
```json
{
  "clue_id": "clue_auth_mismatch",
  "source_type": "auth_log",
  "trigger_condition": "auth_time != badge_time",
  "unlock_effect": "unlock_document:deploy_log_002"
}
```

### ChapterGate
```json
{
  "chapter_id": "chapter_02",
  "required_clues": ["clue_auth_mismatch", "clue_deleted_deploy"],
  "unlock_targets": ["mail_thread_03", "room_devops_archive"]
}
```

## 콘텐츠 추가 워크플로우
1. `cases`에 사건 메타 추가
2. `logs/mails/chats`에 원천 데이터 추가
3. `ClueData`와 `ChapterGate`로 해금 조건 연결
4. 씬/스크립트는 데이터 키를 소비만 하도록 유지

## 파일 간 참조 규칙
- 수량/범위 기준은 [docs/08-mvp-scope.md](./08-mvp-scope.md) 단일 참조
- 일정/마일스톤은 [plan/00-master-roadmap.md](../plan/00-master-roadmap.md) 단일 참조
