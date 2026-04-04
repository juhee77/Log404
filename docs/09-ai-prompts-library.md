# AI 프롬프트 라이브러리

## 문서 메타
- 목적: 반복 업무(기획/퍼즐/UI/데이터 생성)를 위한 재사용 프롬프트를 표준화한다.
- 독자: 기획자, 디자이너, 개발자.
- 입력: 프로젝트 요구사항, 콘텐츠 제작 목표.
- 출력: 카테고리별 프롬프트 템플릿.

## 사용 원칙
- 프로젝트 고정 조건(플랫폼, 플레이타임, 난이도 대상)을 프롬프트에 항상 포함
- 결과물은 그대로 사용하지 않고 문맥 검수 후 반영
- 기술 과잉 설명은 삭제하고 플레이어 가독성 우선

## 1) 게임 기획 확장
```text
You are a narrative puzzle game designer.
Design a single-player log-analysis mystery game for Steam.
Requirements:
- Windows + macOS
- solo-dev realistic scope
- playtime 1.5~3h
- strong deduction, UI-heavy, minimal animation
Please provide:
1) core loop 2) 5 chapters 3) 10 puzzles 4) 3 endings
5) key UI screens 6) MVP scope 7) cut list
```

## 2) 퍼즐 생성
```text
Generate puzzle ideas using auth logs, deployment logs, DB queries, chat, email, and access records.
Constraints:
- understandable for non-developers
- technical vibe but readable
- clear deduction path
- no real coding required
- gradual difficulty
Output per puzzle:
- premise, clue sources, player notice, deduction, unlock reward
```

## 3) UI 디자인
```text
Design a realistic dark investigation UI for a PC detective game.
Include:
- case folders sidebar
- central log/document panel
- evidence/suspect side panel
- search/filter/timeline
Style:
- dark, subtle teal/cyan, monospace for logs, clean desktop app feel
Explain layout, components, colors, typography, interaction patterns.
```

## 4) 이미지 생성
```text
A realistic dark-mode investigation dashboard for a cyber detective indie game.
Left: case folders.
Center: server logs with suspicious highlights.
Right: evidence cards and suspect profiles.
Bottom: command/search bar.
Subtle teal/cyan accents, clean monospace typography, believable internal security tool.
```

## 5) Godot 구조 설계
```text
Help structure a Godot 4 project for a UI-heavy detective game.
Features:
- case selection, log/mail/chat viewer, evidence board, save/load, clue progression.
Provide:
- scene tree, autoloads, JSON data model, save design, UI communication patterns, anti-spaghetti guidelines.
```

## 6) 로그 데이터 생성
```text
Create fictional but believable server logs for a mystery game.
Requirements:
- readable to general players
- timestamps, user IDs, IPs, actions, errors
- one hidden suspicious pattern
Output:
- raw log text
- suspicious clue explanation
- expected player inference
```
