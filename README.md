# LOG:404

로그를 읽고 사건을 푸는 싱글플레이 추리 게임 프로젝트입니다.  
현재 저장소는 **기획/설계 문서 체계화**와 **실행 계획 고정** 단계까지 완료된 상태입니다.

![LOG:404 초안 UI 및 구조](./docs/images/log404-draft.png)

## 프로젝트 요약
- 장르: 싱글플레이 추리 퍼즐 / 로그 분석 / 디지털 포렌식 어드벤처
- 코어 판타지: 기술 문서를 읽고 실제 사건의 진실을 추론한다
- 대상 플랫폼: Windows + macOS (Steam)
- 목표 플레이타임: 1.5~3시간

## 저장소 구성
- `docs/`: 제품, 게임플레이, 퍼즐, UI/UX, 기술 스택, 데이터 구조, 플랫폼 노트
- `plan/`: 마스터 로드맵, MVP 실행, 수직 슬라이스, 리스크, 테스트, 출시 체크리스트
- `docs/images/`: 초안 및 참고 이미지
- `review-notes/`: 일일 리뷰 체크리스트

## 먼저 읽을 문서
1. 제품 개요: [docs/01-product-overview.md](./docs/01-product-overview.md)
2. MVP 단일 기준: [docs/08-mvp-scope.md](./docs/08-mvp-scope.md)
3. 마스터 로드맵: [plan/00-master-roadmap.md](./plan/00-master-roadmap.md)
4. Steam/macOS 출시 체크리스트: [plan/06-steam-macos-release-checklist.md](./plan/06-steam-macos-release-checklist.md)

## 즉시 진행할 구현 단계
1. Godot 4 기본 프로젝트 및 씬 골격 구성
2. 로그 뷰어 + 검색/필터/북마크 흐름 구현
3. `CaseData`, `ClueData`, `ChapterGate` JSON 파이프라인 연동
4. 챕터 1 기준 15~20분 수직 슬라이스 구현 및 검증
