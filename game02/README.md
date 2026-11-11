# 📔 주희의 다꾸 서재 & 소장 일기장 — Pocket Archive (Game02)

Godot 4.6.2 모바일 기반의 **E-Book 리더기 서재(Apple Books · 리디북스 레퍼런스) & 만년필 다꾸 독서노트(굿노트 · 몰스킨 레퍼런스)** 감성 아카이브 앱입니다.
14인 가상 애자일 스쿼드(다꾸러 3인, 기획자 2인, UX/UI 디자이너 2인, 개발자 4인, QA 2인, CEO 1인)가 **20분 주기 스프린트**로 UI 목업(`index.html`)과 실제 Godot 앱(`godot_project`)을 동시에 고도화하며 [SPRINT_LOG.md](SPRINT_LOG.md)에 전 과정을 기록합니다.

---

## 📸 실제 구동 스크린샷 (Godot 4.6 Metal 렌더링 — Sprint 8)

| 📔 메인 E-Book 서재 & 다꾸 일기장 (`main.tscn`) | 🖋️ 펼친 몰스킨 독서노트 상세 모달 (`detail_modal.tscn`) |
| :---: | :---: |
| ![Pocket Archive Main Screen](godot_project/screenshots/godot_app_screen.png) | ![Pocket Archive Detail Modal](godot_project/screenshots/godot_modal_screen.png) |

---

## 🚀 최신 스프린트 업데이트 요약 ([전체 회의록 보기](SPRINT_LOG.md))

### [Sprint 8] 일기장 내 고무 인장 스탬프 피커(`💮인장`) & 만년필 밑줄 문장 편집기(`🖋️밑줄 저장`) 탑재
- **인장 스탬프 원터치 변경(`StampRow`)**: 펼친 몰스킨 독서 일기장 모달에서 `💮전권완결`, `🔖초판특전`, `♥인생최애`, `✨위시` 인장을 직접 찍어 메인 서재 카드와 로컬 JSON에 즉시 반영
- **만년필 밑줄 문장 편집(`QuoteEditRow`)**: 일기장 안에서 오늘 밑줄 친 명대사·감상평을 바로 수정·저장할 수 있는 입력창 및 `🖋️ 밑줄 저장` 버튼 추가
- **4종 다꾸 속지 테마(`ROOM_THEMES`)**: `만년필 미색 노트`, `빈티지 크라프트 다꾸지`, `리디 이북 세피아 리더`, `보타니컬 세이지 일기장` 테마 지원

### [Sprint 7] E-Book 서재(Apple Books/리디북스) & 만년필 다꾸 일기장(굿노트/몰스킨) 전면 리디자인
- **레퍼런스 벤치마킹 & UI 팀 전면 개편 (`index.html` 목업 & Godot 4.6 동기화)**:
  - 차가운 대시보드 느낌을 완전히 걷어내고 **따뜻한 만년필 미색 종이(`#FAF6F0`, `#F3ECE1`) + 에스프레소 잉크(`#2C221E`)** 톤앤매너 적용
  - **마스킹 테이프(`MaskingTape`) + 인장 스탬프(`💮전권완결`, `💮초판특전`) + 원목 책장 선반(`WoodLedge`) + 밑줄 친 오늘의 명대사(`QuotePanel`)** 카드 디자인 구현
  - 펼친 몰스킨 독서노트 스타일의 상세 모달(`detail_modal.tscn`) 리디자인 및 권수 소수점(`1.0권` → `1권`) 포맷 버그 수정

### [Sprint 6] 작품별 컬러 표지·띠지(Obi) 디자인, 여백(Margin) 개편 & 하단 4탭 액션바 통합
- 단행본 고유 표지 컬러, 좌측 책등 바인딩 라인, 하단 단행본 띠지(Obi Band), 4버튼 액션바 탑재

### [Sprint 5] 로컬 JSON 영구 세이브/로드 (`user://archive_data_v2.json`)
- 앱 재시작 시에도 모든 권별 기록·별점·신규 소장품을 100% 보존하는 자동 직렬화 엔진 및 `test_persistence.gd` 검증 완료

---

## 🧪 자동화 테스트 검증 (Headless CI — 100% PASS)

```bash
godot --headless --path godot_project -s tests/test_archive.gd
godot --headless --path godot_project -s tests/test_persistence.gd
godot --headless --path godot_project -s tests/test_main_integration.gd
```
