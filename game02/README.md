# 📚 Pocket Archive (Game02) — 주희의 만화책 & 가챠 보물창고

Godot 4.6.2 모바일 기반의 깔끔하고 직관적인 **단행본 권별 소장 및 가챠 피규어 아카이브 앱**입니다.
14인 가상 애자일 스쿼드(다꾸러 3인, 기획자 2인, 디자이너 2인, 개발자 4인, QA 2인, CEO 1인)가 **20분 주기 스프린트**로 지속 개선하며 [SPRINT_LOG.md](SPRINT_LOG.md)에 전 과정을 기록합니다.

---

## 📸 실제 구동 스크린샷 (Godot 4.6 Metal 렌더링 — Sprint 6)

| 📚 메인 6종 컬렉션 진열장 (`main.tscn`) | 📖 권별 다이어리 상세 모달 (`detail_modal.tscn`) |
| :---: | :---: |
| ![Pocket Archive Main Screen](godot_project/screenshots/godot_app_screen.png) | ![Pocket Archive Detail Modal](godot_project/screenshots/godot_modal_screen.png) |

---

## 🚀 최신 스프린트 업데이트 요약 ([전체 회의록 보기](SPRINT_LOG.md))

### [Sprint 6] 작품별 컬러 표지·띠지(Obi) 디자인, 여백(Margin) 개편 & 하단 4탭 액션바 통합
- **다꾸러 VOC 반영**:
  - 상단 통계 카드에 명확한 한글 라벨(`총 소장 작품`, `단행본 권수`, `초판 특전`, `가챠·피규어`) 부여 및 빈 여백 제거
  - 단행본마다 고유 표지 컬러(`#e11d48` 슬램덩크, `#0284c7` 프리렌, `#ea580c` 하이큐, `#f43f5e` 카드캡터 체리), 좌측 책등 바인딩 라인, 하단 **단행본 띠지(Obi Band)** 적용
  - 하단 4버튼 네비게이션 바(`🌐 웹표지 스크랩`, `📸 카메라 촬영`, `🎨 나만의책 공방`, `🌸 테마 변경`) 탑재

### [Sprint 5] 로컬 JSON 영구 세이브/로드 (`user://archive_data_v2.json`)
- 앱 재시작 시에도 모든 권별 기록·별점·신규 소장품을 100% 보존하는 자동 직렬화 엔진 및 `test_persistence.gd` 검증 완료

### [Sprint 4] 다꾸 스티커 뱃지(`StickerBadge`) & 웹 표지 로더(`WebCoverLoader`)
- 우측 상단 골드 옐로 스티커 뱃지(`전권완결`, `초판특전`, `시크릿`, `인생최애`, `SSR한정`) 적용

---

## 🧪 자동화 테스트 검증 (Headless CI — 100% PASS)

```bash
godot --headless --path godot_project -s tests/test_archive.gd
godot --headless --path godot_project -s tests/test_persistence.gd
godot --headless --path godot_project -s tests/test_main_integration.gd
```
