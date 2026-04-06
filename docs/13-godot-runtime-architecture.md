# Godot 런타임 아키텍처

## 목적
LOG:404의 실제 출시용 클라이언트를 Godot 4 + GDScript로 유지보수 가능하게 운영하기 위한 런타임 구조를 고정한다.

## 계층 구조
- `data/`: 케이스/문서/단서/챕터 게이트 canonical JSON
- `scripts/domain/`: 순수 데이터 모델 (`CaseData`, `DocumentData`, `ClueData`, `ChapterGate`, `InvestigationState`)
- `scripts/autoload/`: 앱 전역 서비스
  - `content_repository.gd`: JSON 로드
  - `progression_service.gd`: 진행/해금/판정 규칙
  - `save_service.gd`: 저장/불러오기
  - `app_state.gd`: UI가 참조하는 단일 상태 퍼사드
- `scripts/ui/`: 화면 재사용 패널
- `scripts/scenes/`: 씬 단위 조립/이벤트 연결
- `scenes/`: 실제 Godot 씬 파일

## 원칙
1. UI는 `AppState`만 바라본다.
2. 해금/추론/엔딩 판정은 `ProgressionService`에 둔다.
3. JSON 스키마 변경은 `domain`과 `content_repository`에서 먼저 흡수한다.
4. 저장 포맷은 `InvestigationState` 직렬화 결과를 기준으로 한다.
5. Python 프로토타입은 같은 `data/`를 읽되, 출시용 런타임 규칙과 분리 유지한다.

## 현재 메인 씬
- `res://scenes/app_root.tscn`

## 현재 주요 흐름
1. 메인 메뉴 진입
2. 조사 시작
3. 워크스페이스에서 문서 탐색 / 검색 / 북마크 / 단서 추론
4. 증거 보드에서 확보 단서 시각 정리
5. 최종 보고서 제출
