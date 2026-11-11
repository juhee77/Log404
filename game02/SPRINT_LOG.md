# 📋 Pocket Archive (Game02) — 14인 애자일 스쿼드 스프린트 누적 회의록

- **조직 구성**: CEO(1명), 실제 다꾸러·수집러(3명: 소장러 A, 가챠러 B, 미니멀러 C), 기획자(2명: PO, 서비스 기획), UX/UI 디자이너(2명), 개발자(4명), QA 엔지니어(2명)
- **운영 주기**: 20분 주기 자율 스프린트 (`VOC 취합 -> 기획 정리 -> HTML 목업/UI -> 전원 회의 -> Godot 4.6 개발 -> TDD/QA 검증 -> 스크린샷 캡처 & README 업데이트 -> Git Commit & Push`)

---

## 🚀 [Sprint 17] 모달 내 북커버 색상 순환(`cycle_cover_color`) · 미니 책등 금박 책갈피 팁(`Spine Ribbon`) · 서재 요약 클립보드 복사(`copy_summary_to_clipboard`)
- **시각**: 2026-11-12 07:45 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"펼친 독서노트 모달(`detail_modal.gd`) 안에서도 북커버 색상(`cover_color`)을 7종 컬러 팔레트로 즉시 바꿀 수 있게 해주세요!"*
  - **가챠 수집러 B**: *"상단 미니 책등 진열대(`SpineShelfRow`)의 각 책등 상단에 작은 금박 책갈피 리본 팁(`ribbon`) 디테일을 추가해 주세요!"*
  - **미니멀 수집러 C**: *"서재 요약 리포트를 시스템 클립보드에 바로 복사하는 `copy_summary_to_clipboard()` 기능을 추가해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **모달 내 북커버 컬러 순환(`cycle_cover_color`)**: `detail_modal.gd`에 7종 북커버 컬러 프리셋(`COLOR_PRESETS`) 및 색상 순환·저장 로직 구현
  - **미니 책등 금박 책갈피 팁**: `_render_spine_shelf()`의 각 책등 상단에 골드 크림 책갈피 헤더 바(`Color(0.96, 0.85, 0.55)`) 추가
  - **클립보드 요약 복사(`copy_summary_to_clipboard`)**: `DisplayServer.clipboard_set()` 연동 및 완료 토스트 알림 구현
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `cycle_cover_color()` 및 `copy_summary_to_clipboard()` 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 16] 오늘의 밑줄 문장 터치 바로가기(`open_current_quote_item`) & 모달 표지 다꾸 스티커 이모지 변경(`cycle_cover_icon`)
- **시각**: 2026-11-12 07:27 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"상단 오늘의 밑줄 문장 배너(`TodayQuoteLabel`)를 터치하면 바로 그 문장이 적힌 작품의 독서노트 모달이 열리면 리디북스 하이라이트 노트처럼 정말 편리할 것 같아요!"*
  - **가챠 수집러 B**: *"펼친 독서노트 모달(`detail_modal.gd`)에서 좌측 표지(`CoverRect`)를 클릭하면 표지 중앙의 다꾸 스티커 이모지(`📖`, `📕`, `✨`, `🎀`, `🏆`, `🔮` 등 12종)를 원터치로 바꿀 수 있게 해주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **오늘의 밑줄 문장 바로가기(`open_current_quote_item`)**: `_collect_all_quotes()`가 문장과 원본 아이템 참조를 함께 반환하도록 고도화하고, `today_quote_label` 클릭 시 즉시 해당 작품 일기장 모달 오픈
  - **표지 다꾸 이모지 변경(`cycle_cover_icon`)**: `detail_modal.gd`에 12종 다꾸 이모지 프리셋(`ICON_PRESETS`) 및 표지 클릭 시 이모지 순환·저장 로직 구현
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `cycle_cover_icon()` 및 `open_current_quote_item()` 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 15] 모달 내 표지 스크랩 마스킹 테이프(`ModalWashiTape`) · 책등 제본선(`ModalSpineStrip`) · 마지막 권 삭제(`remove_last_volume`)
- **시각**: 2026-11-12 07:10 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"펼친 독서노트 모달(`detail_modal.tscn`) 좌측의 표지(`CoverRect`)에도 실제 스크랩북처럼 상단 마스킹 테이프(`ModalWashiTape`)와 좌측 책등 제본선(`ModalSpineStrip`) 디테일을 넣어 주세요!"*
  - **가챠 수집러 B**: *"모달에서 실수로 권을 더 추가했을 때 바로 지울 수 있는 `- 권 삭제`(`remove_last_volume`) 버튼을 `+ 다음 권 추가` 옆에 배치해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **모달 표지 다꾸 디테일(`ModalWashiTape` & `ModalSpineStrip`)**: `detail_modal.tscn` 표지 상단에 반투명 마스킹 테이프와 좌측 책등 음영 스트립 추가
  - **마지막 권 삭제(`RemoveVolBtn` / `remove_last_volume`)**: `detail_modal.gd`에 마지막 권 제거 및 통계·JSON 즉시 동기화 구현
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `remove_last_volume()` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 14] 메인 서재 카드 평균 별점(`★5.0`) 배지 · 단행본 띠지 원터치 변경(`🏷️띠지`) · 독서 일기장 요약 리포트(`export_diary_summary`)
- **시각**: 2026-11-12 06:11 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"메인 서재 카드(`card_item.gd`)의 작가명 옆에 해당 작품의 평균 별점(`★5.0`)이 함께 찍혀 있으면 일기장을 펼치기 전에도 내 애정도를 한눈에 볼 수 있어요!"*
  - **가챠 수집러 B**: *"펼친 독서노트 모달(`detail_modal.tscn`)의 스탬프 줄 우측에 `🏷️띠지` 버튼을 넣어 원터치로 단행본 띠지 문구를 바꿀 수 있게 해주세요!"*
  - **미니멀 수집러 C**: *"내 서재 기록을 텍스트로 공유·백업할 수 있는 `export_diary_summary()` 요약 리포트 생성 기능을 추가해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **카드 평균 별점 표시(`card_item.gd`)**: 권별 별점 평균을 계산해 작가명 우측에 `· ★5.0` 형태로 표시
  - **모달 내 `🏷️띠지` 버튼(`ObiCycleBtn`)**: `detail_modal.tscn` 스탬프 바에 `🏷️띠지` 버튼을 배치하고 `cycle_obi_preset()` 시그널 연결
  - **독서 일기장 요약 리포트(`export_diary_summary`)**: `archive_state.gd`에서 전체 소장 종수·권수·초판 수 및 작품별 스탬프/띠지 목록을 마크다운 리스트로 반환
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `export_diary_summary()` 및 카드 `★` 별점 표시 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 13] 상단 통계 북마크 원터치 필터(`_on_stat_firsts_clicked`) & 단행본 띠지 프리셋 순환(`cycle_obi_preset`)
- **시각**: 2026-11-12 05:20 KST
- **1. 다꾸러 3인 VOC**: 상단 4개 통계 박스(`서재 작품`, `단행본 기록`, `초판 스탬프`, `가챠 스크랩`)를 클릭하면 즉시 해당 조건(특히 `초판 스탬프 보유작`)으로 필터링되는 인터랙티브 북마크 기능 요청.
- **2. 개발 및 QA 검증**: `main_view.gd`에 `filter_firsts_only` 및 4개 통계 카드 클릭 핸들러, `detail_modal.gd`에 `OBI_PRESETS` 순환 로직 구현 및 헤드리스 통합 테스트 100% 통과.

---

## 🚀 [Sprint 12] 권별 밑줄 대사 개별 편집(`update_volume_quote`) & 가챠·굿즈 스크랩북 체크리스트(`Gacha Checklist`) 탑재
- **시각**: 2026-11-12 03:30 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"전체 감상평뿐만 아니라 특정 권(`1권`, `2권`, `3권`...)의 밑줄 명대사도 수정·저장(`update_volume_quote`)할 수 있게 해주세요!"*
  - **가챠 수집러 B**: *"가챠·굿즈 카드(`category == 1`)를 열었을 때 하단 영역이 숨겨지지 않고, `🔮 가챠·굿즈 소장 파츠 & 전시 체크리스트 (캡슐 미니북 보증서 보관 완료 / 아크릴 케이스 방진 전시 완료)`와 파츠 추가 버튼이 보이도록 채워주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **권별 밑줄 문장 개별 수정(`update_volume_quote`)**: `detail_modal.gd`에 `editing_vol_index` 및 `update_volume_quote(vol_idx, new_quote)`를 구현하여 권별 명대사를 직접 편집·저장 가능
  - **가챠·굿즈 스크랩북 체크리스트**: 가챠 아이템 오픈 시에도 하단 노트 섹션을 활성화하고 캡슐 미니북·아크릴 전시 체크리스트 및 `🔮 + 파츠·보증서 기록 추가` 버튼 제공
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `update_volume_quote(0, "왼손은 거들 뿐!")` 및 가챠 모달 체크리스트 표시 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 11] 카드별 맞춤 파스텔 와시 테이프(`MaskingTape`) · 명대사 전문(Full-Text) 검색 · 권별 별점 원터치 변경(`cycle_volume_rating`)
- **시각**: 2026-11-12 03:09 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 권별 별점(`★★★★★`)도 터치 한 번으로 바꿀 수 있으면 좋겠어요!"*
  - **가챠 수집러 B**: *"카드 상단의 마스킹 테이프(`MaskingTape`) 색상이 작품 표지 컬러에 맞춘 파스텔 와시 테이프 톤으로 각각 다르게 붙어 있으면 훨씬 다꾸 다이어리 같을 거예요!"*
  - **미니멀 수집러 C**: *"상단 검색창에서 작품명뿐만 아니라 내가 밑줄 친 명대사(`농구`, `봉인해제`)나 스탬프(`인생최애`, `초판특전`)로도 검색되게 해주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **작품별 파스텔 와시 테이프(`card_item.gd`)**: 각 카드의 `cover_color`에서 파생된 부드러운 파스텔 톤(`lightened(0.62)`)을 `MaskingTape`에 적용
  - **명대사·스탬프 전문 검색(`archive_state.gd`)**: `get_filtered_items()`가 제목·작가뿐 아니라 `memo`, `status_tag`, 각 권의 `quote`까지 통합 검색하도록 확장
  - **권별 별점 원터치 순환(`cycle_volume_rating`)**: `detail_modal.gd` 및 `index.html`에서 별점 버튼을 누르면 `★★★` ~ `★★★★★` 별점이 즉시 순환 및 저장됨
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 명대사 검색(`"농구"`) 및 `cycle_volume_rating(0)` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 10] 권별 초판·소장 스탬프 원터치 토글(`toggle_volume_status`) & 책등 터치 바로가기 + 다독순 정렬(`SortBtn`)
- **시각**: 2026-11-12 03:01 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **다꾸러 A**: *"상단 미니 책등 진열대(`SpineShelfRow`)의 책등을 직접 클릭하면 바로 해당 작품의 펼친 일기장 모달이 열리면 리디북스·북적북적 책장처럼 훨씬 편하고 재미있을 것 같아요!"*
  - **수집러 B**: *"일기장 모달에서 각 권의 `🔖초판특전` / `✓소장완료` 배지를 눌렀을 때 초판 여부를 원터치로 토글할 수 있게 해주세요!"*
  - **미니멀러 C**: *"메인 서재 필터바에 `↕ 기본순 / 다독순` 정렬 토글 버튼을 넣어 다권 소장 시리즈부터 정렬해 볼 수 있게 해주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **권별 초판 스탬프 토글(`toggle_volume_status`)**: `detail_modal.gd` 및 `index.html`에서 각 권의 `🔖초판특전` / `✓소장완료` 우표 버튼을 누르면 즉시 상태가 전환되며 상단 `초판 스탬프` 통계 및 로컬 JSON이 실시간 갱신됨
  - **미니 책등 터치 바로가기(`SpineShelfRow` 클릭 이벤트)**: 상단 미니 책등 진열대의 개별 책등을 클릭하면 해당 작품의 독서노트 모달이 즉시 오픈됨
  - **다독순/기본순 정렬(`SortBtn`)**: 필터바 우측에 `↕ 기본순` ↔ `↕ 다독순` 토글 버튼 탑재
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `toggle_volume_status(1)` 및 `_on_sort_btn_pressed()` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 9] 미니 책등 진열대(`SpineShelf`) & 오늘의 만년필 밑줄 배너(`TodayQuote`) + 새 일기 쓰기 모달(`AddModal`) 전면 개편
- **시각**: 2026-11-12 02:35 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **북적북적·이북 유저 A**: *"내 서재에 꽂힌 책들의 책등(Spine)이 권수 두께에 비례해 알록달록하게 나란히 꽂혀 있는 '미니 책등 진열대'와 '오늘의 밑줄 문장' 배너가 상단에 있으면 이북 서재 + 독서노트 감성이 훨씬 깊어질 것 같아요!"*
  - **다꾸러 B**: *"`+ 일기 쓰기` 버튼을 눌렀을 때 나오는 `AddModal`도 만년필 일기장 톤앤매너로 바꾸고, 표지 북커버 색상 6종(`크림슨`, `코발트`, `테라코타`, `로즈`, `포레스트`, `바이올렛`)과 첫 밑줄 명대사를 직접 적을 수 있게 해주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **미니 책등 진열대(`SpineShelfRow`)**: 보유 작품들의 고유 컬러와 소장 권수 두께를 반영한 미니 책등 바를 상단 배너 좌측에 동적 렌더링 (`main.tscn`, `main_view.gd`, `index.html`)
  - **오늘의 밑줄 문장 순환기(`TodayQuoteLabel` & `NextQuoteBtn`)**: 내 일기장에 기록된 모든 명대사·감상평을 `"↻ 문장"` 버튼으로 순환 감상 가능
  - **새 독서·다꾸 일기장 모달(`add_modal.tscn` & `add_modal.gd`)**: 6종 북커버 컬러 스와치 선택기(`select_color`) 및 첫 페이지 밑줄 명대사 입력창(`QuoteInput`) 탑재
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `spine_shelf_row`, `_on_next_quote_btn_pressed()`, `add_modal.select_color("#15803d")` 통합 검증 추가 → 3개 테스트 스위트 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 8] 일기장 내 고무 인장 스탬프 피커(`💮인장`) & 만년필 밑줄 문장 편집기(`🖋️밑줄 저장`) 탑재
- **시각**: 2026-11-12 00:31 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달을 열었을 때 도장(`💮전권완결`, `🔖초판특전`, `♥인생최애`, `✨위시`)을 직접 찍어서 바꾸고, 오늘의 명대사/감상평도 일기장 안에서 바로 고쳐 쓸 수 있으면 진짜 내 일기장 같을 것 같아요!"*
  - **미니멀 수집러 C**: *"모달 안의 버튼들도 기본 회색 버튼 대신 크림색 종이와 만년필 잉크 버튼으로 통일해 주세요. 그리고 권별 노트 헤더에 `소장 권수 · 초판 권수` 요약이 보이면 좋겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **고무 인장 스탬프 피커(`StampRow`)**: 펼친 일기장 모달(`detail_modal.tscn` & `index.html`) 내부에 `💮전권완결`, `🔖초판특전`, `♥인생최애`, `✨위시` 원터치 스탬프 버튼 4종 탑재 → 클릭 즉시 모달과 메인 서재 카드의 스탬프가 동기화되고 JSON(`user://archive_data_v2.json`)에 영구 저장됨
  - **만년필 밑줄 문장 편집기(`QuoteEditRow`)**: `QuoteInput` + `🖋️ 밑줄 저장` 버튼을 통해 작품의 한 줄 일기(`memo`)를 즉시 수정·저장 가능
  - **4종 다꾸 속지 테마(`ROOM_THEMES`)**: `만년필 미색 노트 (Warm Ivory)`, `빈티지 크라프트 다꾸지 (Kraft)`, `리디 이북 세피아 리더 (Sepia)`, `보타니컬 세이지 일기장 (Sage)` 속지 전환 지원
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `apply_stamp("인생최애")` 및 `_on_save_quote_btn_pressed()` 자동화 검증 추가 → 3개 테스트 스위트 전수 100% PASS
  - Metal 렌더러로 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 7] UI/UX팀 레퍼런스 벤치마킹 대개편 — 리디북스·Apple Books(이북 서재) + 굿노트·몰스킨(다꾸 일기장) 감성 적용
- **시각**: 2026-11-12 00:03 KST
- **1. 다꾸러 3인 & 유저 VOC**
  - **핵심 피드백**: *"차가운 남색 대시보드/관리자 화면 같아서 내 일기장이라는 느낌이 안 들어요. 리디북스/애플북스 같은 **이북 서재** 느낌과 굿노트/몰스킨/북적북적 같은 **따뜻한 나만의 독서 일기장(다꾸 노트)** 레퍼런스를 반영해 주세요!"*
- **2. UX/UI 디자이너팀 레퍼런스 분석 및 디자인 시스템 개편**
  - **레퍼런스 1 (Apple Books / 리디북스 / 북적북적)**:
    - 차가운 남색 헤더(`#14192B`)와 회색 배경을 폐기하고, **따뜻한 만년필 미색 종이(`#FAF6F0` / `#F3ECE1`)**와 **에스프레소 잉크 타이포그래피(`#2C221E`)** 채택
    - 단행본 표지 좌측에 실제 이북 단행본 같은 **책등 접힘 음영(`SpineStrip`)**과 하단 **원목 선반 받침대(`WoodLedge`)** 배치
  - **레퍼런스 2 (GoodNotes 다꾸 다이어리 / 몰스킨 독서노트)**:
    - 카드 상단 중앙에 반투명 **마스킹 테이프(`MaskingTape` `#F0D18F`)** 부착
    - 우측 상단 배지를 다꾸 **고무 도장 스탬프(`💮전권완결`, `💮초판특전`, `💮인생최애`)** 테라코타 잉크(`#C85A32`) 스타일로 변경
    - 각 카드 하단에 내가 밑줄 친 **최애 명대사 콜아웃(`🖋️ "농구... 좋아하세요?"`)** 노출
    - 기본 회색 Godot 버튼을 전부 **크림 페이퍼 & 만년필 잉크 스타일박스**로 커스텀 테마화
- **3. 산출물 및 QA 검증**
  - HTML 목업 업데이트: `game02/index.html` (이북 서재 & 2페이지 펼침 독서 일기장 뷰)
  - Godot 4.6 네이티브 적용: `main.tscn`, `card_item.tscn`, `detail_modal.tscn`, `main_view.gd`, `card_item.gd`, `detail_modal.gd`
  - 버그 픽스: JSON 로드 시 권수가 `1.0권`으로 표시되던 부동소수점 포맷을 `int` 캐스팅하여 `1권`, `2권`, `3권`으로 깔끔하게 수정
  - 테스트 검증: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 전수 100% PASS
  - 스크린샷 갱신: `godot_app_screen.png` & `godot_modal_screen.png`

---

## 🚀 [Sprint 6] Godot 4.6 카드 컬러/띠지(Obi) 디자인, 여백(Margin) 개편 & 하단 4탭 툴바 통합
- **시각**: 2026-11-11 23:35 KST
- **핵심 내용**: 작품별 고유 표지 컬러, 하단 단행본 띠지(Obi), 상단 한글 라벨 통계 카드, 하단 4버튼 액션바 구현 완료.

---

## 🚀 [Sprint 5] 로컬 JSON 영구 세이브/로드 (`user://archive_data_v2.json`)
- **시각**: 2026-11-11 23:02 KST
- **핵심 내용**: 앱 종료 후 재실행 시에도 모든 단행본 권별 기록과 신규 추가 소장품이 유지되도록 JSON 직렬화/역직렬화 엔진 및 `test_persistence.gd` 검증 완료.

---

## 🚀 [Sprint 1 ~ 4] 클린 아키텍처, 웹 스크래퍼 모듈 & Godot 4.6 네이티브 기반 구축
- **핵심 내용**: 가독성을 해치던 홀로그램 오버레이 제거, `WebCoverLoader` 및 Godot 4.6 모바일 프로젝트(`450x800`, `canvas_items`, `expand`) 기반 확립.
