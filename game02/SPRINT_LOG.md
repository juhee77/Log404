# 📋 Pocket Archive (Game02) — 14인 애자일 스쿼드 스프린트 누적 회의록

- **조직 구성**: CEO(1명), 실제 다꾸러·수집러(3명: 소장러 A, 가챠러 B, 미니멀러 C), 기획자(2명: PO, 서비스 기획), UX/UI 디자이너(2명), 개발자(4명), QA 엔지니어(2명)
- **운영 주기**: 20분 주기 자율 스프린트 (`VOC 취합 -> 기획 정리 -> HTML 목업/UI -> 전원 회의 -> Godot 4.6 개발 -> TDD/QA 검증 -> 스크린샷 캡처 & README 업데이트 -> Git Commit & Push`)

---

## 🚀 [Sprint 79] 삭제 경고 빨간색 강조 + ESC 해제 & 서재 카드 우클릭 +1권 빠른 기록(`quick_advance`)
- **날짜/시각**: 2026-11-17 05:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `일기 삭제` 버튼을 한 번 눌러 `'⚠️ 삭제 확인'` 상태가 되었을 때 빨간색 경고 배경으로 확 눈에 띄게 강조되고, 이 상태에서 `ESC`를 누르면 모달이 닫히지 않고 삭제 확인만 취소되면 더 안전할 것 같아요!")**: `detail_modal.gd`에 `_apply_delete_btn_style(armed)`를 추가해 경고 시 빨간 배경+흰 글씨로 강조하고, `_unhandled_input()`에서 `delete_armed` 상태일 때 첫 `ESC`로 경고 해제만 수행.
  2. **다꾸러 VOC #2 ("메인 서재 목록에서 카드를 우클릭하면 모달을 열지 않고도 곧바로 `+1권 완독`(`quick_advance()`)이 기록되면 진도 관리가 엄청 빠를 것 같아요!")**: `card_item.gd`의 `_gui_input()` 우클릭(`MOUSE_BUTTON_RIGHT`)을 `quick_advance()`에 연결하고 카드 툴팁에 안내 문구를 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 `deleteSelectedDiary()`에도 2단계 삭제 확인(`deleteArmed`) 안전장치를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_apply_delete_btn_style()` 빨간 경고 스타일 및 `ESC` 1차 삭제 확인 해제 추가.
  - `card_item.gd`: 우클릭 `quick_advance()` 연동 및 툴팁 안내 추가.
  - `game02/index.html`: `deleteSelectedDiary()` 2단계 삭제 확인 안전장치 동기화.
  - `tests/test_main_integration.gd`: Sprint 79 통합 테스트(`Visual Delete Arm + Escape Disarm & Card Right-Click Quick Advance verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 78] 일기 삭제 2단계 확인 안전장치(`delete_armed`) & 단축키 `H` 키보드 치트시트 토스트
- **날짜/시각**: 2026-11-17 05:39 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `일기 삭제` 버튼을 실수로 한 번 눌렀을 때 곧바로 작품이 삭제되지 않고 `'⚠️ 삭제 확인'`으로 1차 경고를 보여준 뒤 두 번째 클릭에서 삭제되면 안심될 것 같아요!")**: `detail_modal.gd`에 `delete_armed` 상태 플래그를 추가해 첫 클릭 시 `"⚠️ 삭제 확인"`으로 전환하고 두 번째 클릭 시 실제 삭제를 수행(모달 재오픈 시 `"일기 삭제"`로 초기화).
  2. **다꾸러 VOC #2 ("서재에서 지원하는 키보드 단축키(`1~5`, `/`, `S`, `R`, `N`, `T`, `M`, `Q`, `I`, `C`)를 한눈에 볼 수 있는 단축키 치트시트(`H` 키)가 있으면 좋겠어요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_H` 단축키를 추가해 전체 단축키 치트시트 토스트를 표시.
  3. **웹 목업 동기화**: `game02/index.html`의 전역 `keydown` 리스너에 `H` / `?` 키 단축키 안내 팝업을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `delete_armed` 2단계 삭제 확인 안전장치 추가 및 `open()` 리셋.
  - `main_view.gd`: `_unhandled_input()` `KEY_H` 단축키 치트시트 토스트 추가.
  - `game02/index.html`: 전역 `H`/`?` 키 단축키 안내 동기화.
  - `tests/test_main_integration.gd`: Sprint 78 통합 테스트(`Two-Step Delete Confirmation Safety & Keyboard H Shortcut Cheatsheet verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 77] 모달 헤더 `◀`·`▶` 이전/다음 작품 버튼 & 단축키 `C`(서재 요약 클립보드 복사)
- **날짜/시각**: 2026-11-17 05:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("상세 일기장 모달 상단 헤더의 닫기(`✕`) 버튼 옆에 `◀` / `▶` 이전·다음 작품 버튼이 있으면 모바일/터치 환경에서도 모달을 닫지 않고 책장을 바로 넘길 수 있을 것 같아요!")**: `detail_modal.gd`의 `_style_diary_controls()`에서 `Header/HBox` 닫기 버튼 왼쪽에 `PrevItemBtn`(`◀`)과 `NextItemBtn`(`▶`)을 배치하고 `navigate_requested` 시그널과 연동.
  2. **다꾸러 VOC #2 ("메인 서재에서 키보드 `C` 키를 누르면 `copy_summary_to_clipboard()` 내 서재 전체 요약 리포트가 클립보드에 바로 복사되면 좋겠어요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_C` 단축키를 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 모달 헤더에도 `◀`/`▶` 이전·다음 작품 넘김 버튼을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: 모달 헤더 `PrevItemBtn`(`◀`), `NextItemBtn`(`▶`) 동적 생성 및 `navigate_requested` 연동.
  - `main_view.gd`: `_unhandled_input()` `KEY_C` 서재 요약 클립보드 복사 단축키 추가.
  - `game02/index.html`: 모달 헤더 `◀`/`▶` 책장 넘김 버튼 동기화.
  - `tests/test_main_integration.gd`: Sprint 77 통합 테스트(`Modal Header Prev/Next Buttons & Keyboard C Summary Copy verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 76] 모달 좌/우 화살표(`←`·`→`) 책장 넘김 내비게이션 & 단축키 `I`(서재 인포그래픽)
- **날짜/시각**: 2026-11-17 04:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("상세 일기장 모달(`DetailModal`)을 열어둔 상태에서 키보드 `←` / `→` 화살표 키로 이전·다음 작품의 일기장으로 책장을 넘기듯 바로 이동할 수 있으면 정말 E-Book·다이어리 같을 것 같아요!")**: `detail_modal.gd`에 `navigate_requested(delta)` 시그널과 `_unhandled_input()` `KEY_LEFT`/`KEY_RIGHT` 핸들러를 추가하고, `main_view.gd`의 `_on_modal_navigate_requested()`에서 서재 내 이전/다음 작품으로 순환 오픈 및 `"📖 책장 넘김: 작품명"` 토스트를 표시.
  2. **다꾸러 VOC #2 ("메인 서재에서 키보드 `I` 키만 누르면 `show_library_infographic()` 전체 서재 인포그래픽 브리핑이 하단 토스트에 바로 뜨면 좋겠어요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_I` 단축키를 추가.
  3. **웹 목업 동기화**: `game02/index.html`에 `navigateJournalModal(delta)`를 추가하고 `#journal-modal` 오픈 상태에서 `ArrowLeft`/`ArrowRight` 키로 이전/다음 일기장을 넘길 수 있도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `navigate_requested(delta)` 시그널 및 `KEY_LEFT`/`KEY_RIGHT` 책장 넘김 핸들러 추가.
  - `main_view.gd`: `_on_modal_navigate_requested()` 및 `_unhandled_input()` `KEY_I` 인포그래픽 단축키 추가.
  - `game02/index.html`: `navigateJournalModal()` 및 전역 `ArrowLeft`/`ArrowRight` 키 동기화.
  - `tests/test_main_integration.gd`: Sprint 76 통합 테스트(`DetailModal Left/Right Page Flip Navigation & Keyboard I Infographic verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 75] 마일스톤 75: 모달 표지 우클릭 색상 순환 & 단축키 `M`(백색소음)·`Q`(오늘의 문장)
- **날짜/시각**: 2026-11-17 04:38 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 왼쪽 책 표지(`CoverRect`)를 좌클릭하면 아이콘이 바뀌고, 우클릭하면 표지 배경 컬러가 바뀌면 모달 안에서도 표지 색을 바로 꾸밀 수 있어 좋을 것 같아요!")**: `detail_modal.gd`의 `_ready()`에서 `cover_rect.gui_input` 우클릭(`MOUSE_BUTTON_RIGHT`) 시 `cycle_cover_color()`가 호출되도록 연결하고 툴팁을 `"좌클릭: 표지 아이콘 변경 · 우클릭: 표지 색상 변경"`으로 갱신.
  2. **다꾸러 VOC #2 ("메인 서재에서 키보드 `M` 키로 백색소음(`AmbientBtn`)을 전환하고 `Q` 키로 `↻ 문장`을 넘기면 서재의 모든 핵심 기능이 키보드 단축키로 완성될 것 같아요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_M`·`KEY_Q` 단축키를 추가하고 `AmbientBtn`·`NextQuoteBtn` 툴팁에 `[M]`·`[Q]` 단축키 안내를 표기.
  3. **웹 목업 동기화**: `game02/index.html`의 `#ambient-sound-btn`에 `[M]` 툴팁 및 전역 `M` 키 백색소음 전환 단축키를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `cover_rect` 우클릭 `cycle_cover_color()` 연동 및 툴팁 갱신.
  - `main_view.gd`: `_unhandled_input()` `KEY_M`/`KEY_Q` 단축키 및 버튼 툴팁 동기화.
  - `game02/index.html`: 전역 `M` 키 백색소음 전환 및 `[M]` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 75 통합 테스트(`Cover Right-Click Color Cycle & Keyboard M/Q Shortcuts verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 74] 권별 별점 우클릭 역순환(`reverse_cycle_volume_rating`) & 단축키 `N`(새 일기)·`T`(속지 테마)
- **날짜/시각**: 2026-11-17 04:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `📌 권별 밑줄 노트`에서 `★★★★★` 별점 버튼을 실수로 한 번 더 눌렀을 때 마우스 우클릭으로 5→4→3 역순환이 되면 편하겠어요!")**: `detail_modal.gd`에 `reverse_cycle_volume_rating(vol_idx)`를 추가하고 `star_btn` 우클릭(`MOUSE_BUTTON_RIGHT`) 및 툴팁 안내와 연동.
  2. **다꾸러 VOC #2 ("메인 서재에서 키보드 `N` 키로 `+ 일기 쓰기`, `T` 키로 `속지 테마`를 바로 전환할 수 있으면 좋겠어요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_N`·`KEY_T` 단축키를 추가하고 `AddBtn`·`NavRow` 테마 버튼 툴팁에 `[N]`·`[T]` 단축키 안내를 표기.
  3. **웹 목업 동기화**: `game02/index.html`의 `+ 새 일기 쓰기` 버튼에 `[N]` 단축키 안내 `title` 툴팁을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `reverse_cycle_volume_rating()` 및 `star_btn` 우클릭 핸들러·툴팁 추가.
  - `main_view.gd`: `_unhandled_input()` `KEY_N`/`KEY_T` 단축키 및 버튼 툴팁 동기화.
  - `game02/index.html`: `+ 새 일기 쓰기` `[N]` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 74 통합 테스트(`Volume Rating Right-Click Reverse Cycle & Keyboard N/T Shortcuts verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 73] 소장 가치 우클릭 -5,000원 되돌리기(`reduce_estimated_value`) & 단축키 `S`(정렬)·`R`(랜덤 추천)
- **날짜/시각**: 2026-11-17 03:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `💎 +5천원` 버튼을 실수로 여러 번 눌렀을 때, 마우스 우클릭으로 `-5,000원`씩 되돌릴 수 있으면 좋겠어요!")**: `detail_modal.gd`에 `reduce_estimated_value()`(최솟값 0원 보장)를 추가하고 `InkRow/ValueBtn` 우클릭(`MOUSE_BUTTON_RIGHT`) 및 툴팁 안내와 연동.
  2. **다꾸러 VOC #2 ("메인 서재에서 키보드 `S` 키로 정렬 순환(`기본순→권수순→최신순→가치순`), `R` 키로 오늘의 랜덤 추천을 바로 열 수 있으면 좋겠어요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_S` 및 `KEY_R` 단축키를 추가하고 버튼 툴팁에 `[S]`·`[R]` 단축키 안내를 표기.
  3. **웹 목업 동기화**: `game02/index.html`의 `↻ 다른 문장`·`🎲 추천` 버튼 툴팁 및 전역 `R` 키 랜덤 추천 단축키를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `reduce_estimated_value()`, `ValueBtn` 우클릭 핸들러 및 툴팁 갱신.
  - `main_view.gd`: `_unhandled_input()` `KEY_S`/`KEY_R` 단축키 및 `SortBtn`/`RandomPickBtn` 툴팁 동기화.
  - `game02/index.html`: 전역 `R` 키 랜덤 추천 단축키 및 상단 버튼 `title` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 73 통합 테스트(`Estimated Value Right-Click Reduce & Keyboard S/R Shortcuts verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 72] 회독·복수소장 우클릭 -1 되돌리기(`decrement_*`) & 폴라로이드 촬영 시 전체 서재 전환
- **날짜/시각**: 2026-11-17 03:39 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `🔁1회독`과 `👯×1` 버튼을 실수로 한 번 더 눌렀을 때, 마우스 우클릭으로 `-1` 되돌리기가 되면 정말 편리할 것 같아요!")**: `detail_modal.gd`에 `decrement_reread_count()`와 `decrement_duplicate_count()`(최솟값 1 보장)를 추가하고 `RereadBtn`/`DuplicateBtn` 우클릭(`MOUSE_BUTTON_RIGHT`) 및 툴팁 안내와 연동.
  2. **다꾸러 VOC #2 ("`폴라로이드 촬영` 버튼을 눌렀을 때도 현재 다른 필터 탭에 머물러 있으면 방금 찍은 실물 인증 카드가 안 보일 수 있으니 `전체일기` 탭으로 자동 전환되면 좋겠어요")**: `main_view.gd`의 `_on_camera_snap_btn_pressed()`에서 `_on_tab_all_pressed()`를 호출하도록 개선.
  3. **웹 목업 동기화**: `game02/index.html`의 `#reread-cycle-btn`에 `oncontextmenu` 우클릭 `decrementRereadCount()`를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `decrement_reread_count()`, `decrement_duplicate_count()`, 우클릭 핸들러 및 툴팁 갱신.
  - `main_view.gd`: `_on_camera_snap_btn_pressed()` 시 전체 서재 탭 자동 전환.
  - `game02/index.html`: `#reread-cycle-btn` 우클릭 `-1` 되돌리기 동기화.
  - `tests/test_main_integration.gd`: Sprint 72 통합 테스트(`Reread/Duplicate Decrement & Camera Snap Auto-Switch to All Tab verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 71] 권별 밑줄 편집 토글 해제 & 새 일기 등록/스크랩 시 전체 서재 자동 전환
- **날짜/시각**: 2026-11-17 03:18 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달에서 특정 권 대사를 클릭해 편집하다가 같은 권을 한 번 더 클릭하면 권별 편집 모드가 취소되고 전체 감상평 편집으로 돌아가면 좋겠어요!")**: `detail_modal.gd`의 `start_editing_volume_quote()`에서 이미 편집 중인 권(`editing_vol_index == vol_idx`)을 다시 클릭하면 `editing_vol_index = -1`로 토글 해제하고 `quote_input`과 `save_quote_btn`을 기본 상태로 복원.
  2. **다꾸러 VOC #2 ("특정 필터 탭(`이북·단행본` 등)을 켜둔 상태에서 새 일기를 등록하거나 웹 스크랩을 추가했을 때, 방금 추가한 작품이 바로 보이도록 자동으로 `전체일기` 탭으로 전환되면 좋겠어요")**: `main_view.gd`의 `_on_item_submitted()`와 `_on_web_scrape_btn_pressed()`에서 `_on_tab_all_pressed()`를 호출해 새로 추가된 작품을 즉시 노출.
  3. **웹 목업 동기화**: `game02/index.html`의 `startEditVolQuote(idx)`에도 같은 권 재클릭 시 편집 모드 토글 해제 동작을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `start_editing_volume_quote()` 재클릭 토글 해제 추가.
  - `main_view.gd`: `_on_item_submitted()` / `_on_web_scrape_btn_pressed()` 시 전체 서재 탭 자동 전환.
  - `game02/index.html`: `startEditVolQuote()` 토글 해제 동기화.
  - `tests/test_main_integration.gd`: Sprint 71 통합 테스트(`Toggle-Off Volume Quote Edit & Auto-Switch to All Tab on Submit verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 70] 마일스톤 70: 편집 중인 권별 행 하이라이트 & 서재 탭 단축키·실시간 작품수 툴팁
- **날짜/시각**: 2026-11-17 03:01 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `📌 권별 밑줄 노트`에서 특정 권의 대사를 클릭해 편집 중일 때, 현재 어느 권 행을 수정 중인지 행 테두리와 따뜻한 크림 하이라이트로 바로 보이면 좋겠어요!")**: `detail_modal.gd`의 `start_editing_volume_quote()`에서 `_render_volumes()`를 재호출하고, `idx == editing_vol_index`인 행에 2px 스탬프 컬러 테두리와 하이라이트 배경을 적용(동시에 `_render_volumes()` 기존 자식 노드 `remove_child` 누락도 개선).
  2. **다꾸러 VOC #2 ("상단 5대 필터 탭(`전체일기`~`인생작`)에 마우스를 올렸을 때 숫자 단축키 `[1]~[5]`와 해당 작품 종수가 툴팁으로 보이면 좋겠어요")**: `main_view.gd`의 `_update_stats()`에서 5개 필터 탭 버튼에 `[1]~[5]` 단축키 및 실시간 종수 `tooltip_text`를 동적으로 설정.
  3. **웹 목업 동기화**: `game02/index.html`의 `#tab-all`에 `[1] 전체 서재 보기` 툴팁을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `start_editing_volume_quote()` 내 `_render_volumes()` 재렌더, 편집 행 2px 테두리 하이라이트 및 `remove_child` 정리 보강.
  - `main_view.gd`: `_update_stats()` 내 5개 필터 탭 단축키/실시간 종수 툴팁 추가.
  - `game02/index.html`: `#tab-all` `[1]` 단축키 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 70 통합 테스트(`Active Editing Volume Row Highlight & Tab Shortcut Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 69] 감상 카드 복사 완료 피드백(`✅ 복사됨!`) & 숫자키 `1~5` 서재 탭 빠른 전환
- **날짜/시각**: 2026-11-17 02:40 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달에서 `💌 공유` 버튼을 눌러 감상 카드를 클립보드에 복사했을 때 버튼 자체가 `✅ 복사됨!`으로 바뀌고 하단 토스트도 함께 뜨면 복사가 확실히 됐는지 바로 알 수 있을 것 같아요!")**: `detail_modal.gd`에 `card_copied(item)` 시그널을 추가해 `copy_book_quote_card()` 실행 시 `ShareCardBtn` 텍스트를 `"✅ 복사됨!"`으로 바꾸고 `main_view.gd`의 `_on_card_copied()`에서 복사 완료 토스트를 표시(모달 재오픈 시 `"💌 공유"`로 초기화).
  2. **다꾸러 VOC #2 ("메인 서재에서 숫자 키 `1~5`만 누르면 `전체일기`, `이북·단행본`, `가챠노트`, `완독작`, `인생작` 탭으로 바로 전환되면 키보드 탐색이 완벽해질 것 같아요")**: `main_view.gd`의 `_unhandled_input()`에서 검색창 포커스 중이 아닐 때 `KEY_1`~`KEY_5` 입력으로 5대 필터 탭을 즉시 전환.
  3. **웹 목업 동기화**: `game02/index.html`의 전역 `keydown` 리스너에도 `1~5` 숫자 키 서재 탭 전환 단축키를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `card_copied(item)` 시그널, `ShareCardBtn` `"✅ 복사됨!"` 피드백 및 `open()` 시 리셋.
  - `main_view.gd`: `_on_card_copied()` 토스트 연동 및 `_unhandled_input()` `KEY_1`~`KEY_5` 탭 전환 단축키 추가.
  - `game02/index.html`: 전역 `1~5` 숫자 키 서재 탭 전환 단축키 동기화.
  - `tests/test_main_integration.gd`: Sprint 69 통합 테스트(`Share Card Copied Feedback & Number Key 1-5 Tab Shortcuts verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 68] 마지막 권 삭제 전용 토스트 피드백(`volume_removed`) & 키보드 검색 단축키(`/` · `Ctrl/Cmd+F`)
- **날짜/시각**: 2026-11-17 02:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달에서 `- 권 삭제`를 눌렀을 때 마지막 권이 삭제되고 현재 몇 권 남았는지 하단 토스트로 명확히 알려주면 좋겠어요!")**: `detail_modal.gd`에 `volume_removed(item)` 시그널을 신설하고 `main_view.gd`의 `_on_volume_removed()`와 연동해 로컬 저장·통계 갱신 후 `"🗑️ 작품명 마지막 권 기록 삭제 (현재 N권)"` 토스트를 표시.
  2. **다꾸러 VOC #2 ("메인 서재에서 `/` 또는 `Cmd+F` / `Ctrl+F` 키를 누르면 바로 통합 검색창으로 포커스가 점프하면 좋겠어요")**: `main_view.gd`에 `_unhandled_input()`을 추가해 모달이 닫혀 있을 때 `/` 또는 `Ctrl/Cmd+F` 입력 시 `search_input.grab_focus()` + `select_all()`을 실행.
  3. **웹 목업 동기화**: `game02/index.html`의 전역 `keydown` 리스너에 `/` 키 검색창 포커스 단축키를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `volume_removed(item)` 시그널 추가 및 `remove_last_volume()` 연동.
  - `main_view.gd`: `_on_volume_removed()` 핸들러 및 `_unhandled_input()` `/` · `Ctrl/Cmd+F` 검색 단축키 추가.
  - `game02/index.html`: 전역 `/` 키 `#search-box` 포커스 단축키 동기화.
  - `tests/test_main_integration.gd`: Sprint 68 통합 테스트(`Volume Removed Toast Feedback & Keyboard Search Shortcut verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 67] 상단 요약줄(`SubTitle`) 원클릭 인포그래픽 브리핑 & 헤더 버튼 툴팁 완성
- **날짜/시각**: 2026-11-17 01:58 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("메인 화면 최상단 요약 줄(`2026. 11. 17 · 완독 81% · ★5.0 · 자산 ₩80,000`)을 클릭했을 때 내 서재 전체 인포그래픽(`show_library_infographic()`) 브리핑이 하단 토스트로 바로 뜨면 좋겠어요!")**: `main_view.gd`의 `_ready()`에서 `sub_title`에 `MOUSE_FILTER_STOP`, `CURSOR_POINTING_HAND`, `tooltip_text`를 적용하고 좌클릭 시 `show_library_infographic()`을 호출하도록 연결.
  2. **다꾸러 VOC #2 ("상단 우측 `+ 일기 쓰기`와 `무음` 버튼에도 마우스 호버 시 상세 툴팁이 나오면 앱 내 모든 버튼의 툴팁 가이드가 100% 완성될 것 같아요")**: `AddBtn`과 `AmbientBtn`에 상세 `tooltip_text`를 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 상단 `서재 작품` KPI 카드 클릭 시 `setFilter('all')`로 전체 서재 복원이 동작하도록 동기화.
- **구현 및 검증 내역**:
  - `main_view.gd`: `sub_title` 클릭 인포그래픽 브리핑 연동 및 `AddBtn`/`AmbientBtn` 툴팁 추가.
  - `game02/index.html`: 상단 `서재 작품` 카드 클릭 필터 동기화.
  - `tests/test_main_integration.gd`: Sprint 67 통합 테스트(`Clickable SubTitle Infographic Briefing & Header Action Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 66] 모달 표지·와시테이프 인터랙티브 툴팁 & 상단 액션 버튼 안전 가이드
- **날짜/시각**: 2026-11-17 01:38 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 왼쪽 책 표지(`CoverRect`)와 상단 와시 테이프(`ModalWashiTape`)를 클릭하면 이모지와 테이프 색상이 바뀐다는 걸 호버 툴팁과 손가락 커서로 바로 알 수 있으면 좋겠어요!")**: `detail_modal.gd`의 `_ready()`에서 `cover_rect`와 `ModalWashiTape`에 `CURSOR_POINTING_HAND` 및 기능 안내 `tooltip_text`를 적용.
  2. **다꾸러 VOC #2 ("모달 상단 버튼(`+ 다음 권 일기 추가`, `- 권 삭제`, `공유`, `일기 삭제`, `밑줄 저장`, `형광펜`, `닫기`)에도 각각 상세 툴팁이 있으면 실수 없이 안전하게 조작할 수 있을 것 같아요")**: `_style_diary_controls()`에서 상단 및 편집 버튼 7종에 상세 `tooltip_text`를 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 모달 상단 마스킹 테이프와 표지 박스에도 클릭 안내 `title` 툴팁을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `cover_rect`/`ModalWashiTape` 커서·툴팁 및 상단/편집 7종 버튼 툴팁 추가.
  - `game02/index.html`: 모달 마스킹 테이프 및 표지 박스 `title` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 66 통합 테스트(`Cover/Washi Interactive Tooltips & Modal Top Action Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 65] 모달 스탬프·잉크 21종 풀 툴팁 가이드 & 바깥 배경(`Dimmer`) 클릭 닫기
- **날짜/시각**: 2026-11-17 01:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `🌸 인장:` 줄과 `🖋️ 잉크:` 줄에 있는 21개 다꾸·수집 버튼마다 마우스를 올렸을 때 어떤 기능인지 한눈에 알 수 있는 툴팁이 나오면 좋겠어요!")**: `detail_modal.gd`의 `_style_diary_controls()`에서 `StampRow` 11종 + `InkRow` 10종 버튼 전체에 직관적인 `tooltip_text` 가이드를 적용.
  2. **다꾸러 VOC #2 ("`DetailModal`이나 `AddModal`을 열었을 때 모달 바깥의 어두운 배경(`Dimmer`)을 클릭해도 모달이 자연스럽게 닫히면 좋겠어요")**: `detail_modal.gd`와 `add_modal.gd`의 `_ready()`에서 `Dimmer.gui_input` 좌클릭 시 `close()`가 호출되도록 연결.
  3. **웹 목업 동기화**: `game02/index.html`의 `#journal-modal` 바깥 오버레이 클릭 시 `closeJournalModal()`이 호출되도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `Dimmer` 클릭 닫기 및 `StampRow`/`InkRow` 21종 버튼 툴팁 추가.
  - `add_modal.gd`: `Dimmer` 클릭 닫기 추가.
  - `game02/index.html`: `#journal-modal` 배경 클릭 닫기 동기화.
  - `tests/test_main_integration.gd`: Sprint 65 통합 테스트(`Modal Stamp/Ink Tooltips & Dimmer Click-Outside Close verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 64] 빈 검색 상태 원클릭 `'🔄 전체 서재 보기'` 복원 버튼 & `AddModal` 제목 자동 포커스
- **날짜/시각**: 2026-11-17 00:58 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("검색·필터 결과가 0건일 때 나오는 빈 상태 안내 아래에 `'🔄 전체 서재 보기'` 버튼을 두어 한 번의 클릭으로 검색어와 필터를 모두 초기화할 수 있으면 좋겠어요!")**: `main_view.gd`에 `_reset_all_filters()`를 추가하고 `_render_cards()`의 빈 상태 컨테이너(`EmptyStateBox`)에 `EmptyStateResetBtn`을 배치.
  2. **다꾸러 VOC #2 ("`+ 일기 쓰기`를 눌러 `AddModal`을 열었을 때 곧바로 제목 입력창에 커서가 깜빡이면 바로 타이핑을 시작할 수 있어 편할 것 같아요")**: `add_modal.gd`의 `open()` 마지막에 `title_input.grab_focus()`를 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 `renderShelf()` 빈 상태 안내 카드에도 `'🔄 전체 서재 보기'` 초기화 버튼을 동일하게 추가.
- **구현 및 검증 내역**:
  - `main_view.gd`: `_reset_all_filters()` 및 `EmptyStateBox/EmptyStateResetBtn` 추가.
  - `add_modal.gd`: `open()` 시 `title_input.grab_focus()` 자동 포커스 추가.
  - `game02/index.html`: 빈 상태 카드 `'🔄 전체 서재 보기'` 버튼 동기화.
  - `tests/test_main_integration.gd`: Sprint 64 통합 테스트(`EmptyState Reset All Filters Button & AddModal Title Auto-Focus verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 63] 권별 노트 툴팁·커서 완성 & 검색창 `ESC` 즉시 초기화
- **날짜/시각**: 2026-11-17 00:38 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 내 `📌 권별 밑줄 노트` 각 권의 `🔖초판특전`/`✓소장완료`, `📅 날짜`, `🔖 북마크`, `★★★★★` 버튼에도 마우스 호버 시 손가락 커서와 안내 툴팁이 나오면 좋겠어요!")**: `detail_modal.gd`의 `_render_volumes()`에서 권별 4종 버튼에 `CURSOR_POINTING_HAND`와 상세 `tooltip_text`를 적용.
  2. **다꾸러 VOC #2 ("검색창(`SearchInput`)에서 검색어를 입력해둔 상태에서 `ESC` 키를 누르면 검색어가 즉시 비워지고 전체 서재가 복원되면 좋겠어요")**: `main_view.gd`에서 `search_input.gui_input`에 `KEY_ESCAPE` 핸들러를 추가해 검색어를 비우고 카드를 즉시 복원하며 토스트를 표시.
  3. **웹 목업 동기화**: `game02/index.html`의 전역 `Escape` 키 리스너에서 모달이 닫혀 있을 때 `#search-box`를 초기화하도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_render_volumes()` 권별 `status_btn`, `date_btn`, `bm_btn`, `star_btn`에 포인팅 커서 및 `tooltip_text` 추가.
  - `main_view.gd`: `search_input` `KEY_ESCAPE` 즉시 초기화 및 토스트 안내 추가.
  - `game02/index.html`: 전역 `Escape` 키 `#search-box` 초기화 동기화.
  - `tests/test_main_integration.gd`: Sprint 63 통합 테스트(`Volume Row Tooltips/Cursors & Search Escape Clear verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 62] 가챠 소장상태 카드 진행률 반영(`전시`/`배송`/`예약`), `AddModal` 지우기 버튼 & 모달 커서 통일
- **날짜/시각**: 2026-11-17 00:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("가챠 카드 하단 진행률 줄에도 `✨ 전시중`, `🚚 배송중`, `🛒 예약중` 상태에 맞춰 `전시 · ₩5,000`, `배송 · ₩5,000`처럼 바로 표시되면 좋겠어요!")**: `card_item.gd`의 `setup()`에서 `category == 1`일 때 `possession_state`에 따라 `전시`/`배송`/`예약`/`진열`/`보관`을 동적으로 표시.
  2. **다꾸러 VOC #2 ("새 일기 쓰기(`AddModal`)의 제목·작가·명대사 입력창에도 `✕` 지우기 버튼이 있고, 상세 모달 스탬프·잉크 버튼에도 모두 손가락 커서가 나오면 좋겠어요")**: `add_modal.gd` 입력창 전체에 `clear_button_enabled = true`를 적용하고 `detail_modal.gd` 및 `add_modal.gd`의 모든 버튼에 `CURSOR_POINTING_HAND`를 적용.
  3. **웹 목업 동기화**: `game02/index.html`의 `renderShelf()`에서 가챠 카드 복수 소장(`🔮×N`) 배지 표기를 동기화.
- **구현 및 검증 내역**:
  - `card_item.gd`: 가챠 `possession_state` 기반 진행률 라벨(`전시`/`배송`/`예약`) 반영.
  - `add_modal.gd`: 모든 `LineEdit`에 `clear_button_enabled = true` 및 액션 버튼 `CURSOR_POINTING_HAND` 적용.
  - `detail_modal.gd`: 스탬프·잉크·액션 버튼 전체 `CURSOR_POINTING_HAND` 적용.
  - `game02/index.html`: 가챠 카드 복수 소장(`🔮×N`) 배지 동기화.
  - `tests/test_main_integration.gd`: Sprint 62 통합 테스트(`Gacha Possession Progress Label, AddModal Clear Buttons & Modal Cursor Affordance verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 61] 검색창·인용 입력창 원탭 지우기(`clear_button_enabled`) & 전체 액션 버튼 커서 통일
- **날짜/시각**: 2026-11-16 23:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("검색창과 모달 밑줄 입력창 오른쪽에 `✕` 원탭 지우기 버튼이 있으면 검색어를 지우거나 새 문장을 쓸 때 훨씬 빠를 것 같아요!")**: `main_view.gd`의 `search_input.clear_button_enabled = true`와 `detail_modal.gd`의 `quote_input.clear_button_enabled = true`를 활성화해 네이티브 `✕` 초기화 버튼을 제공.
  2. **다꾸러 VOC #2 ("상단 필터 탭(`TabAll`~`TabFav`), 정렬·추천·문장 넘기기 버튼에도 마우스를 올렸을 때 손가락 커서(`CURSOR_POINTING_HAND`)가 나오면 좋겠어요")**: `main_view.gd`에서 상단·필터 주요 액션 버튼 전체에 `CURSOR_POINTING_HAND`를 일괄 적용.
  3. **웹 목업 동기화**: `game02/index.html`의 `#search-box`를 `type="search"`로 전환해 브라우저 기본 `✕` 검색어 지우기 버튼을 동기화.
- **구현 및 검증 내역**:
  - `main_view.gd`: `search_input.clear_button_enabled = true` 및 주요 액션/탭 버튼 `CURSOR_POINTING_HAND` 적용.
  - `detail_modal.gd`: `quote_input.clear_button_enabled = true` 적용.
  - `game02/index.html`: `#search-box` `type="search"` 동기화.
  - `tests/test_main_integration.gd`: Sprint 61 통합 테스트(`Search & Quote Clear Buttons + Unified Action Cursor Affordance verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 60] 마일스톤 60: 키보드 Escape 모달 닫기 & 새 일기 쓰기(`AddModal`) 엔터 연속 입력/등록
- **날짜/시각**: 2026-11-16 23:38 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("상세 일기장이나 새 일기 쓰기 창을 열었을 때 `ESC` 키만 누르면 바로 닫히면 맥/PC 앱에서도 훨씬 편할 것 같아요!")**: `detail_modal.gd`와 `add_modal.gd`에 `_unhandled_input()`을 추가해 `KEY_ESCAPE` 입력 시 열려 있는 모달을 즉시 닫고 입력을 소비(`set_input_as_handled()`)하도록 구현.
  2. **다꾸러 VOC #2 ("새 일기 쓰기(`AddModal`)에서 제목 입력 후 Enter 치면 작가 칸으로 넘어가고, 명대사 칸에서 Enter 치면 바로 등록되면 좋겠어요")**: `add_modal.gd`의 `_ready()`에서 `title_input.text_submitted` → `author_input.grab_focus()`, `quote_input.text_submitted` → `_on_submit_btn_pressed()`를 연결.
  3. **웹 목업 동기화**: `game02/index.html`에 전역 `Escape` 키 리스너를 추가해 웹 목업에서도 `ESC`로 다이어리 모달을 닫을 수 있도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_unhandled_input()` `KEY_ESCAPE` 닫기 추가.
  - `add_modal.gd`: `_unhandled_input()` `KEY_ESCAPE` 닫기 및 `title_input`/`quote_input` Enter 키 흐름 연결.
  - `game02/index.html`: 전역 `Escape` 키 모달 닫기 동기화.
  - `tests/test_main_integration.gd`: Sprint 60 통합 테스트(`Keyboard Escape Modal Close & AddModal Enter-to-Submit verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 59] 밑줄 입력창 엔터키 즉시 저장, 가챠 복수소장 배지(`🔮×N`) & macOS/Web 빌드 프리셋 구축
- **날짜/시각**: 2026-11-16 23:19 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 밑줄 입력창에서 대사를 고치고 Enter 키를 누르면 바로 저장되면 편하겠어요!")**: `detail_modal.gd`의 `_ready()`에서 `quote_input.text_submitted` 시그널을 `_on_save_quote_btn_pressed()`에 연결하여 엔터키 즉시 저장을 지원.
  2. **다꾸러 VOC #2 ("가챠도 중복으로 2개 이상 모았을 때 카드 표지 우측 하단 배지에 `🔮×2`처럼 수량이 표시되면 좋겠어요")**: `card_item.gd`에서 `category == 1`일 때 `duplicate_count > 1`이면 `"🔮×N"`을 표시.
  3. **빌드 인프라 & 웹 목업 동기화**: `game02/godot_project/export_presets.cfg`(macOS `.app` & Web HTML5 프리셋)를 구성하여 즉시 앱 빌드가 가능하도록 준비하고, `game02/index.html`의 `#diary-quote-input`에도 Enter 키 저장(`onkeydown`)을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `quote_input.text_submitted` 엔터키 즉시 저장 연동.
  - `card_item.gd`: 가챠 복수 소장 `🔮×N` 배지 표시.
  - `export_presets.cfg`: Godot 4.6.2 macOS / Web 익스포트 프리셋 추가.
  - `game02/index.html`: `#diary-quote-input` Enter 키 저장 동기화.
  - `tests/test_main_integration.gd`: Sprint 59 통합 테스트(`Quote Input Enter-to-Save, Gacha Duplicate Badge & Export Presets Ready verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 58] 권별 밑줄 원클릭 직접 편집(`start_editing_volume_quote`) & 카드 북마크 수 배지
- **날짜/시각**: 2026-11-16 23:00 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `📌 권별 밑줄 노트`에서 각 권의 대사를 클릭하면 바로 위 입력창으로 불러와 수정하고 저장할 수 있으면 좋겠어요!")**: `detail_modal.gd`에 `start_editing_volume_quote()`를 추가해 권별 대사 라벨(`quote_lbl`) 클릭 시 `editing_vol_index`를 설정하고 `quote_input` placeholder(`"🖋️ N권 밑줄 문장 편집 중..."`) 및 `save_quote_btn` 텍스트(`"🖋️ N권 저장"`)를 동적 전환하며, 저장 후 기본 편집 모드로 깔끔히 복귀.
  2. **다꾸러 VOC #2 ("메인 서재 카드 표지 우측 하단 배지에서도 북마크를 몇 권 꽂아뒀는지(`3권 · 🔖1`) 바로 보이고, 카드에 마우스를 올리면 손가락 커서가 나오면 좋겠어요")**: `card_item.gd`에서 `CURSOR_POINTING_HAND`를 적용하고 `bm_cnt > 0`일 때 `vol_badge`에 `"N권 · 🔖M"` 형식으로 표시.
  3. **웹 목업 동기화**: `game02/index.html`의 `renderDiaryVolumes()` 권별 대사 클릭 시 `startEditVolQuote(idx)`가 동작하도록 `saveDiaryQuote()`와 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `start_editing_volume_quote()` 추가, `_render_volumes()` 권별 대사 클릭 핸들러 및 `_on_save_quote_btn_pressed()` 버튼·placeholder 복원.
  - `card_item.gd`: `CURSOR_POINTING_HAND` 및 `vol_badge` 북마크 수(`🔖N`) 표시.
  - `game02/index.html`: `startEditVolQuote()` 및 `saveDiaryQuote()` 동기화.
  - `tests/test_main_integration.gd`: Sprint 58 통합 테스트(`Clickable Volume Quote Edit Mode & Card Bookmark Count Badge verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 57] 새 일기 쓰기(`AddModal`) 표지 스와치 하이라이트, 빈 제목 경고 피드백 & 초판 필터 동기화
- **날짜/시각**: 2026-11-16 22:41 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("새 일기 쓰기(`AddModal`)에서 표지 색상을 눌렀을 때 어떤 색상이 선택됐는지 테두리나 체크표시로 바로 보이면 좋겠어요!")**: `add_modal.gd`에 `_highlight_selected_swatch()`를 추가해 선택된 표지 컬러 버튼에 `✓ ` 체크마크와 2px 크림 테두리를 표시.
  2. **다꾸러 VOC #2 ("제목을 비우고 등록 버튼을 눌렀을 때 아무 반응이 없는 대신 입력창에 안내 문구가 뜨고 포커스가 가면 좋겠어요")**: `add_modal.gd`의 `_on_submit_btn_pressed()`에서 빈 제목일 때 `placeholder_text = "⚠️ 작품 제목을 먼저 입력해주세요!"` 및 `grab_focus()`를 실행.
  3. **다꾸러 VOC #3 ("상단 `초판 스탬프` KPI를 클릭했을 때도 기존 완독작/인생작 필터 상태가 깔끔히 초기화되면 좋겠어요")**: `main_view.gd`의 `_on_stat_firsts_clicked()`에서 `filter_completed_only`/`filter_favorites_only`를 초기화하고 `_highlight_tabs(tab_all)`을 호출. `game02/index.html`의 `초판 스탬프` 클릭 필터(`setFilter('firsts')`)도 동기화.
- **구현 및 검증 내역**:
  - `add_modal.gd`: `_highlight_selected_swatch()` 추가, `open()`/`select_color()` 연동, 빈 제목 경고 포커스 추가.
  - `main_view.gd`: `_on_stat_firsts_clicked()` 필터 플래그 초기화 및 탭 하이라이트 동기화.
  - `game02/index.html`: `초판 스탬프` KPI 카드 클릭 필터(`setFilter('firsts')`) 동기화.
  - `tests/test_main_integration.gd`: Sprint 57 통합 테스트(`AddModal Cover Swatch Highlight, Empty Title Feedback & StatFirsts Filter Sync verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 56] 활성 인장 스탬프 하이라이트 & 형광펜 버튼 ON/OFF 상태 시각화
- **날짜/시각**: 2026-11-16 17:25 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 상단 `💮전권완결`, `🔖초판특전`, `♥인생최애`, `✨위시` 인장 버튼 중 현재 찍혀 있는 도장도 잉크 버튼처럼 2px 테두리로 강조되면 좋겠어요!")**: `detail_modal.gd`에 `_highlight_active_stamp_btn()`을 추가하고 `open()`·`apply_stamp()`에 연동해 현재 `status_tag`와 일치하는 인장 버튼에 2px 스탬프 레드 테두리와 블러시 하이라이트 배경을 적용.
  2. **다꾸러 VOC #2 ("`🖍️ 형광펜` 버튼을 눌렀을 때 형광펜이 켜진 상태인지 버튼 자체에서도 바로 보이면 좋겠어요")**: `_apply_ink_style()`에서 `HighlightBtn`을 `highlight_enabled` 상태에 따라 `"🖍️ 형광펜 ON"`(노란 하이라이트 + 2px 앰버 테두리) ↔ `"🖍️ 형광펜"`(크림 기본 스타일)으로 동적 전환.
  3. **웹 목업 동기화**: `game02/index.html`에 `highlightActiveStampBtn()`을 추가해 `openJournalModal()` 및 `applyDiaryStamp()`에서 활성 인장 버튼 링 강조를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_highlight_active_stamp_btn()` 추가 및 `_apply_ink_style()` 내 `HighlightBtn` ON/OFF 스타일링 추가.
  - `game02/index.html`: `data-stamp-btn` 속성 및 `highlightActiveStampBtn()` 동기화.
  - `tests/test_main_integration.gd`: Sprint 56 통합 테스트(`Active Stamp Highlight & Highlighter Button ON/OFF Visual State verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 55] 활성 만년필 잉크 스와치 하이라이트, 오늘의 밑줄 동적 툴팁 & 검색 빈 상태 가이드
- **날짜/시각**: 2026-11-16 07:38 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달에서 현재 어떤 만년필 잉크를 선택해뒀는지 잉크 버튼 테두리로 한눈에 보이면 좋겠어요!")**: `detail_modal.gd`에 `_highlight_active_ink_btn()`을 추가해 현재 `memo_ink_color`와 일치하는 잉크 버튼(`☕에스프레소`, `🍷버건디`, `🍂세피아`, `🌲포레스트`)에 2px 잉크 컬러 테두리와 크림 하이라이트 배경을 적용.
  2. **다꾸러 VOC #2 ("오늘의 밑줄 배너를 누르면 해당 책 일기장이 열린다는 걸 호버 툴팁과 손가락 커서로 알려주고, 검색 결과가 없을 때도 빈 화면 대신 안내 문구가 나오면 좋겠어요")**: `main_view.gd`에서 `_apply_today_quote()`를 통해 `today_quote_label.tooltip_text`("클릭하여 「작품명」 독서 일기장 펼치기")와 `CURSOR_POINTING_HAND`를 적용하고, `_render_cards()`에서 검색/필터 결과가 비어 있을 때 `EmptyStateLabel` 안내 문구를 표시.
  3. **웹 목업 동기화**: `game02/index.html`의 `renderShelf()` 빈 상태 안내 카드 및 `cycleQuote()` 동적 `title` 툴팁을 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_highlight_active_ink_btn()` 추가 및 `_apply_ink_style()` 연동.
  - `main_view.gd`: `_apply_today_quote()` 헬퍼, 상단 4대 통계 카드 & 밑줄 배너 포인팅 커서, `_render_cards()` `EmptyStateLabel` 추가.
  - `game02/index.html`: `renderShelf()` 빈 상태 안내 및 `today-quote-banner` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 55 통합 테스트(`Active Ink Swatch Highlight, Quote Banner Tooltip & Empty Search State verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 54] 가챠 체크리스트 3줄 메타 요약, 감상 카드 회독·복수소장 연동 & 하단 내비게이션 툴팁 완성
- **날짜/시각**: 2026-11-16 07:18 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("가챠·굿즈 모달의 체크리스트에도 소장 경로·기분·최애 캐릭터가 한 줄 더 보이면 굿즈 일기장 느낌이 확 살 것 같아요!")**: `detail_modal.gd`의 `_render_volumes()`에서 가챠 항목 체크리스트 3번째 줄(`🎁 acquisition_source · reading_mood · favorite_character`)을 추가.
  2. **다꾸러 VOC #2 ("감상 카드 공유(`copy_book_quote_card`)에도 다회독(`🔁2회독`)과 복수 소장(`👯×2`) 기록이 함께 찍히면 좋겠어요")**: `copy_book_quote_card()`에서 `reread_count > 1` 또는 `duplicate_count > 1`일 때 하단 메타 라인에 `🔁N회독`, `👯×N`을 자동 포함.
  3. **UX/UI & 웹 목업 동기화**: `main_view.gd`의 하단 `NavRow` 4개 액션 버튼(웹표지 스크랩·폴라로이드 촬영·새 일기 쓰기·속지 테마)에 가이드 툴팁(`tooltip_text`)을 추가하고, `game02/index.html` 가챠 체크리스트 UI를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: 가챠 체크리스트 3번째 요약 줄 추가 및 `copy_book_quote_card()` 회독·복수소장 연동.
  - `main_view.gd`: 하단 `NavRow` 4개 버튼 툴팁 추가.
  - `game02/index.html`: `renderDiaryVolumes()` 가챠 체크리스트 2단 요약 동기화.
  - `tests/test_main_integration.gd`: Sprint 54 통합 테스트(`Gacha 3rd Checklist Line, Share Card Reread/Dup & Nav Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 53] 가챠 파츠 체크리스트 헤더 실시간 갱신(`_refresh_vol_header`) & 통합 검색창·액션 버튼 파워 툴팁 추가
- **날짜/시각**: 2026-11-16 06:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("가챠·굿즈 모달에서 보관 위치나 컨디션 등급을 바꿨을 때 체크리스트 헤더도 즉시 바뀌면 좋겠어요!")**: `detail_modal.gd`에 `_refresh_vol_header()` 헬퍼를 추출해 `_render_volumes()`, `cycle_storage_location()`, `cycle_condition_grade()`에서 호출하여 가챠 체크리스트 헤더가 실시간 동기화되도록 개선.
  2. **다꾸러 VOC #2 ("검색창에서 날씨·장소·보관위치·소장경로까지 검색된다는 걸 툴팁으로 바로 알 수 있으면 좋겠어요")**: `main_view.gd`에서 `SearchInput`, `NextQuoteBtn`, `RandomPickBtn`, `SortBtn`에 통합 검색 범위 및 정렬 순환 안내 툴팁(`tooltip_text`)을 추가.
  3. **웹 목업 동기화**: `game02/index.html`의 `#search-box` `placeholder`와 `title` 툴팁을 통합 검색 안내로 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_refresh_vol_header()` 추출 및 `cycle_storage_location()`/`cycle_condition_grade()` 연동.
  - `main_view.gd`: `SearchInput`·`NextQuoteBtn`·`RandomPickBtn`·`SortBtn` 파워 기능 툴팁 추가.
  - `game02/index.html`: `#search-box` `placeholder` 및 `title` 동기화.
  - `tests/test_main_integration.gd`: Sprint 53 통합 테스트(`Gacha Checklist Header Live Refresh & Search Power Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 52] 모달 권별 북마크 개수(`🔖 N`) 헤더 표시 & 상단 4대 통계 카드 리치 툴팁(`tooltip_text`) 연동
- **날짜/시각**: 2026-11-16 06:57 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 내 권별 밑줄 노트 헤더에서도 북마크 꽂아둔 권수(`🔖1`)를 바로 보고 싶어요!")**: `detail_modal.gd`의 `_render_volumes()`에서 `get_bookmarked_volumes_count()`를 계산해 북마크가 1권 이상일 때 `📌 권별 밑줄 노트 (소장 3/3권 · 100% · 초판 2권 · 🔖1)`으로 표시.
  2. **다꾸러 VOC #2 ("상단 4대 통계 카드(서재 작품·단행본·초판·가챠)에 마우스를 올리면 세부 KPI가 툴팁으로 보이면 좋겠어요")**: `main_view.gd`의 `_update_stats()`에서 4개 통계 카드에 `평균 ★ / 총 자산`, `서재 완독률`, `초판 비율(%)`, `가챠 굿즈 자산` 툴팁을 동적으로 설정.
  3. **웹 목업 동기화**: `game02/index.html`의 상단 통계 카드 DOM `title` 툴팁 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `vol_header.text`에 북마크 권수(`🔖 N`) 실시간 병기.
  - `main_view.gd`: `_update_stats()` 내 4대 통계 카드 리치 툴팁(`tooltip_text`) 연동.
  - `game02/index.html`: 상단 통계 카드 `title` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 52 통합 테스트(`Modal Bookmark Count Header & Stat Card Tooltips verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 51] 서재 카드 리치 툴팁(`tooltip_text`) 추가 & 일기장 수정 시 '오늘의 밑줄' 배너 실시간 동기화
- **날짜/시각**: 2026-11-16 03:54 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("책장 카드에 마우스를 올리면 모달을 열지 않고도 보관 위치·독서 날씨·장소·표지 질감·컨디션·소장 가치가 툴팁으로 바로 보이면 좋겠어요!")**: `card_item.gd`의 `setup(item)`에서 `tooltip_text`에 작품명, 보관 위치(`storage_location`), 독서 날씨(`reading_weather`), 장소(`reading_spot`), 표지 마감(`cover_finish`), 컨디션(`condition_grade`), 소장 가치(`format_krw`)를 3줄 요약 툴팁으로 구성.
  2. **다꾸러 VOC #2 ("모달에서 밑줄 문장을 수정·저장했을 때 메인 상단 '오늘의 밑줄' 배너에도 즉시 반영되면 좋겠어요")**: `main_view.gd`의 `_on_diary_updated()`에서 `_refresh_today_quote()`를 호출해 문장 변경 시 배너가 즉시 최신화되도록 개선.
  3. **웹 목업 동기화**: `game02/index.html`의 `renderShelf()` 카드 `title` 속성에도 동일한 3줄 리치 툴팁을 동기화.
- **구현 및 검증 내역**:
  - `card_item.gd`: `setup(item)`에 리치 툴팁(`tooltip_text`) 설정.
  - `main_view.gd`: `_on_diary_updated()` 내 `_refresh_today_quote()` 호출 추가.
  - `game02/index.html`: 카드 DOM `title` 툴팁 동기화.
  - `tests/test_main_integration.gd`: Sprint 51 통합 테스트(`Card Rich Tooltip & Today Quote Live Refresh on Diary Update verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🎉 [Sprint 50 — 마일스톤] 가챠 체크리스트 보관·등급 헤더, 랜덤 추천 날씨·장소 연동 & `format_krw` 중복 완전 제거
- **날짜/시각**: 2026-11-16 02:37 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("가챠·굿즈 모달을 열었을 때도 체크리스트 헤더에 보관 위치(`🗄️ 1층 장식장`)와 컨디션 등급(`✨ S급(최상)`)이 바로 보이면 좋겠어요!")**: `detail_modal.gd`의 `_render_volumes()`에서 `category == 1` 가챠 항목일 때 `vol_header.text`에 `storage_location`과 `condition_grade`를 함께 표시.
  2. **다꾸러 VOC #2 ("🎲 추천(`pick_random_item`)으로 작품을 뽑았을 때 토스트에도 독서 날씨·장소 스팟이 함께 뜨면 좋겠어요")**: `main_view.gd`의 `pick_random_item()` 토스트에 `picked.reading_weather`와 `picked.reading_spot`을 연동.
  3. **코드 품질 마일스톤 ("`detail_modal.gd` 내 남은 KRW 수동 콤마 루프도 전부 `ArchiveStateClass.format_krw`로 통합해주세요")**: `copy_book_quote_card()` 및 `_refresh_author_label()`의 수동 콤마 루프를 `ArchiveStateClass.format_krw()`로 대체해 프로젝트 전체 금액 포맷 중복 0건 달성.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `ArchiveStateClass.format_krw()` 통합, 가챠 모달 `vol_header`에 `storage_location`·`condition_grade` 표시.
  - `main_view.gd`: `pick_random_item()` 토스트에 `reading_weather`·`reading_spot` 연동.
  - `game02/index.html`: `renderDiaryVolumes()` 가챠 파츠 체크리스트 헤더 동기화.
  - `tests/test_main_integration.gd`: Sprint 50 마일스톤 테스트(`Sprint 50 Milestone: Gacha Checklist Header, Quote Mood/Weather Toast & Zero-Dup format_krw verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 49] 상단 KPI 평균 별점(`★5.0`) 병기, 모달 권별 목표 달성률 헤더(`3/3권 · 100%`) & `ArchiveState.format_krw` 정적 헬퍼 통일
- **날짜/시각**: 2026-11-16 01:46 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("메인 화면 상단 헤더에도 서재 전체 평균 별점(`★5.0`)이 함께 보이면 좋겠어요!")**: `main_view.gd`의 `_update_stats()` 상단 라벨을 `📔 2026. 11. 16 · 완독 81% · ★5.0 · 자산 ₩80,000` 형태로 고도화하고 `show_library_infographic()` 브리핑에도 `평균 ★`를 추가.
  2. **다꾸러 VOC #2 ("모달 내 권별 밑줄 노트 헤더에서도 목표 권수 대비 진행률(`소장 3/3권 · 100%`)을 바로 보고 싶어요")**: `detail_modal.gd`의 `_render_volumes()`에서 `target_volumes` 기준 달성률을 계산해 `📌 권별 밑줄 노트 (소장 3/3권 · 100% · 초판 2권)`으로 표시.
  3. **코드 품질 개선 ("카드·모달에 흩어진 KRW 천단위 콤마 포맷 중복을 없애주세요")**: `card_item.gd`에서 수동 콤마 루프를 제거하고 `ArchiveStateClass.format_krw()` 정적 헬퍼를 재사용하도록 리팩터링.
- **구현 및 검증 내역**:
  - `main_view.gd`: `_update_stats()` 및 `show_library_infographic()`에 서재 평균 별점(`★`) 연동.
  - `detail_modal.gd`: `vol_header.text`에 `소장/목표 권수 · 달성률(%) · 초판 권수` 표시.
  - `card_item.gd`: `ArchiveStateClass.format_krw()` 호출로 중복 포맷 로직 제거.
  - `tests/test_main_integration.gd`: Sprint 49 통합 테스트(`Header Avg Rating KPI & Modal Vol Progress Header + KRW Helper verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 육안 검증 완료.

---

## 🚀 [Sprint 48] 권별 별점·권수·복수소장 변경 시 모달 상단 실시간 동기화 & 서재 전체 평균 별점(`get_average_library_rating`) 백업 연동
- **날짜/시각**: 2026-11-15 23:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달 안에서 권별 별점이나 권수(`+ 다음 권 추가`/`- 권 삭제`), 복수 소장(`👯×2`)을 바꿀 때마다 상단 평균 별점(`★`)과 소장 가치(`💎 ₩`)가 즉시 반영되어야 해요!")**: `detail_modal.gd`의 `cycle_volume_rating()`, `_on_add_vol_btn_pressed()`, `remove_last_volume()`, `increment_duplicate_count()`에서 `_refresh_author_label()`을 호출해 실시간 갱신되도록 개선.
  2. **다꾸러 VOC #2 ("내 서재 전체 작품의 평균 별점도 백업 요약 헤더에서 한눈에 보고 싶어요")**: `archive_state.gd`에 `get_average_library_rating() -> float`를 신설하고 `export_diary_summary()` 상단 요약 헤더(`평균 ★5.0`)에 연동.
  3. **웹 목업 동기화**: `game02/index.html`에 `refreshDiaryAuthor(item)` 헬퍼를 추가해 모달 오픈, 권별 별점 순환, 권 추가 시 `#diary-author`가 실시간 평균 별점과 가치를 반영하도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `cycle_volume_rating()`, `_on_add_vol_btn_pressed()`, `remove_last_volume()`, `increment_duplicate_count()`에 `_refresh_author_label()` 실시간 호출 연결.
  - `archive_state.gd`: `get_average_library_rating()` 신설 및 `export_diary_summary()` 헤더 연동.
  - `game02/index.html`: `refreshDiaryAuthor(item)` 추출 및 권별 별점/추가 동기화.
  - `tests/test_main_integration.gd`: Sprint 48 통합 테스트(`Live Author Rating/Value Sync on Vol & Duplicate Changes + Library Avg Rating verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 47] 모달 상단 작가·평점·가치 통합 헬퍼(`_refresh_author_label`) & 서재 백업 요약 내 날씨·장소·가치 통합
- **날짜/시각**: 2026-11-15 23:54 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("일기장 모달 상단 작가 라인에서도 평균 별점(`★5.0`)과 소장 가치(`💎 ₩21,000`)를 한 번에 보고 싶어요!")**: `detail_modal.gd` 내 `open()`과 `boost_estimated_value()`에 중복되던 콤마 포맷 로직을 `_refresh_author_label()` 단일 헬퍼로 통합하고 평균 별점(`★5.0`)을 함께 병기, `copy_book_quote_card()` 감상 카드에도 소장 가치(`💎 ₩`)를 포함.
  2. **다꾸러 VOC #2 ("서재 일기장 백업 요약(`export_diary_summary`)에도 독서 날씨·장소 스팟·작품별 가치가 다 남았으면 좋겠어요")**: `archive_state.gd`의 `export_diary_summary()` 각 작품 라인에 `format_krw(it.get_item_value())`, `reading_weather`, `reading_spot`을 포함해 백업 완성도를 강화.
  3. **웹 목업 동기화**: `game02/index.html`의 `openJournalModal()`에서 `#diary-author`에 평균 별점과 소장 가치를 동일 포맷(`작가 · ... · ★5.0 · 💎 ₩...`)으로 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_refresh_author_label()` 추출, `open()`/`boost_estimated_value()`/`copy_book_quote_card()`에 평균 별점 및 포맷된 소장 가치 연동.
  - `archive_state.gd`: `export_diary_summary()`에 작품별 가치·독서 날씨·독서 장소 스팟 포함.
  - `game02/index.html`: `#diary-author` 포맷 동기화.
  - `tests/test_main_integration.gd`: Sprint 47 통합 테스트(`Modal Author Rating Display & Summary Weather/Spot/Value Export verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 육안 검증 완료.

---

## 🚀 [Sprint 46] 모달 스탬프 `_refresh_tag_label()` 단일 경로 통합 & 서재 카드 진행률·소장 가치(`₩21,000`) 병기
- **날짜/시각**: 2026-11-15 23:22 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("기분·등급·보관위치·소장경로 스탬프를 누를 때마다 상단 메타에 있던 날씨·장소 스팟이 사라져요!")**: `detail_modal.gd` 내 `apply_stamp()`, `cycle_rarity_tier()`, `cycle_deco_sticker()`, `cycle_storage_location()`, `cycle_acquisition_source()`, `cycle_reading_mood()`가 각각 다르게 포맷하던 중복 코드를 모두 `_refresh_tag_label()` 단일 헬퍼로 통합.
  2. **다꾸러 VOC #2 ("책장 카드 겉면에서도 작품별 소장 가치(`₩21,000`)가 잘리지 않고 한눈에 보였으면 좋겠어요")**: `card_item.gd`에서 작가명이 길어도 잘리지 않도록 `progress_label` 우측에 `완독 · ₩21,000` / `75% · ₩21,000` / `보관 · ₩5,000` 형태로 소장 가치를 깔끔하게 병기하고 Metal 스크린샷으로 잘림 없음 확인.
  3. **웹 목업 동기화**: `game02/index.html`에 `refreshDiaryStamp(item)` 헬퍼를 도입해 모든 스탬프 순환 버튼이 `#diary-stamp`의 날씨·장소 스팟을 일관되게 유지하도록 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: 6개 스탬프 핸들러를 `_refresh_tag_label()`로 통합하여 메타 표시 중복 및 날씨·장소 누락 제거.
  - `card_item.gd`: `get_item_value()` 기반 천단위 콤마 포맷 소장 가치를 `progress_label`에 병기(`완독 · ₩21,000` 등).
  - `game02/index.html`: `refreshDiaryStamp(item)` 추출 및 스탬프 순환 핸들러 전수 동기화.
  - `tests/test_main_integration.gd`: Sprint 46 통합 테스트(`Unified _refresh_tag_label & Card Value Display verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 육안 검증 완료.

---

## 🚀 [Sprint 45] 모달 메타 라벨(`TagLabel`)·감상 카드 공유 내 독서 날씨·장소 스팟 통합 동기화 & 소장 경로 검색 검증
- **날짜/시각**: 2026-11-15 22:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("감상 카드 공유(`copy_book_quote_card`)에도 독서 장소 스팟(`🛋️ 이불 속`)이 함께 찍히면 좋겠어요!")**: 독서 날씨(`reading_weather`)와 더불어 독서 장소 스팟(`reading_spot`)까지 감상 공유 카드 하단 메타 라인에 포함되도록 동기화.
  2. **다꾸러 VOC #2 ("일기장 모달 상단 메타 요약(`TagLabel`)에서도 지금 설정된 날씨·장소 스탬프를 한눈에 보고 싶어요")**: `detail_modal.gd`에 공통 헬퍼 `_refresh_tag_label()`을 추출해 중복 포맷 로직을 통합하고, `open()`, `cycle_reading_weather()`, `cycle_reading_spot()`, `cycle_obi_preset()` 시 즉시 `[기분 · 등급 · 보관위치 · 날씨 · 장소]`가 상단 메타에 실시간 반영되도록 개선.
  3. **다꾸러 VOC #3 ("구매처/소장 경로(`오프라인 서점` 등) 검색과 웹 목업 메타 배지도 동일하게 동작하나요?")**: `ArchiveState.get_filtered_items()`의 `acquisition_source` 통합 검색을 회귀 테스트로 고정하고 `game02/index.html`의 `#diary-stamp`도 날씨·장소 스팟과 실시간 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `copy_book_quote_card()`에 `reading_spot` 추가, `_refresh_tag_label()` 공통 헬퍼 신설 및 `open()`/`cycle_reading_weather()`/`cycle_reading_spot()`/`cycle_obi_preset()` 연동.
  - `game02/index.html`: `openJournalModal()`, `cycleReadingWeather()`, `cycleReadingSpot()`에서 `#diary-stamp`가 `reading_weather`·`reading_spot`을 실시간 반영하도록 동기화.
  - `tests/test_main_integration.gd`: Sprint 45 통합 테스트(`Modal Meta & Share Card Spot Sync + Acquisition Source Search verified`) 추가 후 3대 헤드리스 테스트(`test_archive`, `test_persistence`, `test_main_integration`) 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처·육안 검증 완료.

---

## 🚀 [Sprint 44] 독서 장소 스팟 스탬프(`🛋️ 이불 속` / `cycle_reading_spot`), 날씨·장소 통합 검색 & 모달 재오픈 시 표지 질감 광택 유지
- **날짜/시각**: 2026-11-15 22:39 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("이 책을 어디서 읽었는지 장소도 스탬프로 남기고 싶어요!")**: 만화책이나 소설을 읽을 때 날씨(`☀️ 맑은 오후`)와 함께 **독서 장소 스팟(`🛋️ 이불 속`, `☕ 북카페`, `🪑 내 방 책상`, `🚃 출퇴근길`)**을 원터치로 순환 기록하고 JSON 영속성까지 보존하도록 `SpotBtn` 및 `reading_spot` 필드를 추가.
  2. **다꾸러 VOC #2 ("날씨나 장소 스탬프로도 내 서재를 바로 검색하고 싶어요")**: `ArchiveState.get_filtered_items()` 검색 쿼리가 `reading_weather`와 `reading_spot`까지 함께 매칭하도록 확장하여 `"북카페"`, `"비 오는 밤"` 같은 감성 키워드 검색을 지원.
  3. **UX/UI 개선 ("모달을 닫았다가 다시 열어도 표지 마감 질감 광택이 그대로 유지되어야 해요")**: `detail_modal.gd`의 `open(item)` 시점에 `_apply_cover_finish_style()`을 명시적으로 호출해 모달 재오픈 시에도 표지 질감(`✨ 유광 라미네이팅`, `📜 매트 질감`, `🌟 홀로그램 코팅`, `🧶 패브릭 린넨`) 광택이 즉시 복원되도록 개선.
- **구현 및 검증 내역**:
  - `collection_item.gd`, `archive_state.gd`: `reading_spot` 필드(`"🛋️ 이불 속"` 기본값), `cycle_reading_spot()`, `to_dict()`/`load_from_file()` JSON 직렬화 및 날씨·장소 통합 검색 필터 구현.
  - `detail_modal.tscn`, `detail_modal.gd`: `InkRow`(`HFlowContainer`) 내 `SpotBtn` 배치, `cycle_reading_spot()` 시그널 연결 및 `open()` 시 `_apply_cover_finish_style()` 호출 적용.
  - `game02/index.html`: `#spot-cycle-btn` / `cycleReadingSpot()` 및 `reading_weather`·`reading_spot` 검색 매칭 동기화.
  - `tests/test_main_integration.gd`: Sprint 44 통합 테스트(`Reading Spot Stamp & Weather/Spot Search Integration verified`) 추가 후 3대 헤드리스 테스트(`test_archive`, `test_persistence`, `test_main_integration`) 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

---

## 🚀 [Sprint 43] 감성 독서 날씨 스탬프(`☀️ 맑은 오후` / `cycle_reading_weather`) & 표지 마감 질감 실시간 2.5D 광택 반영
- **시각**: 2026-11-15 22:19 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 '오늘의 독서 날씨/분위기'(`☀️ 맑은 오후`, `🌧️ 비 오는 밤`, `❄️ 눈 내리는 창가`, `🌙 새벽 감성`)를 원터치 스탬프로 남기면 그날의 독서 감성이 생생히 기록될 것 같아요!"*
  - **가챠 수집러 B**: *"표지 질감(`FinishBtn`)을 `🌟 홀로그램`이나 `🧶 패브릭 양장`으로 바꿨을 때, 모달 좌측 표지 카드(`CoverRect`) 색감/광택이 즉시 달라지면 시각적 손맛이 훨씬 좋아집니다."*
  - **미니멀 수집러 C**: *"감상 카드 공유(`copy_book_quote_card`)에도 표지 마감과 독서 날씨 스탬프가 한 줄에 깔끔하게 포함되면 좋겠어요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **감성 독서 날씨 스탬프(`WeatherBtn` / `cycle_reading_weather`)**: `collection_item.gd`에 `reading_weather` 및 4종 프리셋(`☀️ 맑은 오후`, `🌧️ 비 오는 밤`, `❄️ 눈 내리는 창가`, `🌙 새벽 감성`) 추가, `archive_state.gd` JSON 영구 저장/복원 연동 및 `detail_modal.tscn` `InkRow`에 배치
  - **표지 마감 질감 실시간 2.5D 광택 반영 & 감상 카드 공유 연동(`detail_modal.gd`)**: `_apply_cover_finish_style()`로 홀로그램/유광/패브릭 질감에 따른 `CoverRect` 광택·명암 즉시 반영 및 `copy_book_quote_card()`에 `cover_finish`, `reading_weather` 포함
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#weather-cycle-btn` / `cycleReadingWeather()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 43 독서 날씨 스탬프 및 공유 카드 반영 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 42] 표지·책등 마감 질감 프리셋(`📜 무광 매트` / `cycle_cover_finish`) · 컨디션·마감 통합 검색 · 백업 요약 총 자산 연동
- **시각**: 2026-11-15 22:00 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"소장품의 표지·책등 질감(`📜 무광 매트`, `✨ 유광 코팅`, `🌟 홀로그램`, `🧶 패브릭 양장`)을 일기장 모달에서 원터치로 기록해 두면 애장판·한정판 감성이 더 살아날 것 같아요!"*
  - **가챠 수집러 B**: *"컨디션 등급(`S급`, `미개봉`)이나 표지 마감(`홀로그램`, `유광`) 키워드로도 메인 검색창에서 바로 필터링되면 수집 관리가 한결 편해집니다."*
  - **미니멀 수집러 C**: *"서재 요약 내보내기(`export_diary_summary`)를 눌렀을 때도 총 추정 가치(`총 자산 ₩...`)와 컨디션 등급이 함께 정리되어 나오면 백업용으로 완벽해요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **표지·책등 마감 질감 프리셋(`FinishBtn` / `cycle_cover_finish`)**: `collection_item.gd`에 `cover_finish` 및 4종 프리셋(`📜 무광 매트`, `✨ 유광 코팅`, `🌟 홀로그램`, `🧶 패브릭 양장`) 추가, `archive_state.gd` JSON 영구 저장/복원 연동 및 `detail_modal.tscn` `InkRow`에 배치
  - **컨디션·마감 통합 검색 & 백업 요약 총 자산 연동(`archive_state.gd`)**: `get_filtered_items()` 검색 쿼리에 `condition_grade`, `cover_finish` 매칭 추가 및 `export_diary_summary()`에 `총 자산 ₩...`과 항목별 컨디션 등급 포함
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#finish-cycle-btn` / `cycleCoverFinish()` 및 컨디션·마감 검색 매칭 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 42 표지 마감 프리셋, 통합 검색 및 백업 요약 총 자산 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 41] 소장품 보존 상태·컨디션 등급(`✨ S급(최상)` / `cycle_condition_grade`) & 최애 캐릭터 통합 검색·공유 연동
- **시각**: 2026-11-15 21:47 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 고른 '최애 캐릭터'(`🏀 강백호`, `🧙‍♀️ 프리렌` 등)도 메인 검색창에서 검색할 수 있고 감상 카드 공유에도 함께 들어가면 좋겠어요!"*
  - **가챠 수집러 B**: *"소장품의 보존 상태 등급(`✨ S급(최상)`, `📖 A급(양호)`, `🏷️ B급(사용감)`, `📦 미개봉(새상품)`)을 모달에서 원터치로 기록해 두고 싶습니다."*
  - **미니멀 수집러 C**: *"컨디션 등급도 모달 `InkRow`의 원터치 순환 버튼과 JSON 영구 저장으로 깔끔하게 관리할 수 있게 해주세요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **보존 상태·컨디션 등급 순환(`ConditionBtn` / `cycle_condition_grade`)**: `collection_item.gd`에 `condition_grade` 및 4종 프리셋(`✨ S급(최상)`, `📖 A급(양호)`, `🏷️ B급(사용감)`, `📦 미개봉(새상품)`) 추가, `archive_state.gd` JSON 영구 저장/복원 연동 및 `detail_modal.tscn` `InkRow`에 배치
  - **최애 캐릭터 통합 검색 & 감상 카드 공유 연동**: `archive_state.gd` `get_filtered_items()` 검색 쿼리에 `favorite_character` 매칭 추가 및 `copy_book_quote_card()`에 `condition_grade`, `favorite_character` 반영
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#condition-cycle-btn` / `cycleConditionGrade()` 및 최애 캐릭터 검색 매칭 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 41 컨디션 등급 순환 및 최애 캐릭터 통합 검색 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 40] 4단 정렬 사이클러(`↕ 가치순` 추가) & 최애 캐릭터 스탬프(`🌟 최애 캐릭터` / `cycle_favorite_character`)
- **시각**: 2026-11-15 20:09 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 이 작품의 '최애 캐릭터'(`🏀 강백호`, `🧙‍♀️ 프리렌`, `🐾 치이카와` 등)를 원터치 스탬프로 기록해 두면 덕질 일기 감성이 더 살아날 것 같아요!"*
  - **가챠 수집러 B**: *"상단 정렬 버튼(`↕ 기본순`)에 '고액순(`↕ 가치순`)' 정렬 모드가 추가되어 내 서재에서 가장 가치 있는 보물부터 순서대로 볼 수 있으면 좋겠습니다."*
  - **미니멀 수집러 C**: *"기존 `SortBtn` 하나에서 `기본순 → 다독순 → 최신순 → 가치순` 4단 순환으로 통합하면 UI가 깔끔하게 유지됩니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **4단 정렬 사이클러(`↕ 가치순` / `main_view.gd`)**: `_on_sort_btn_pressed()`를 4단 순환(`기본순 → 다독순 → 최신순 → 가치순`)으로 확장하고 `get_item_value()` 기준 내림차순 정렬 구현
  - **최애 캐릭터 스탬프(`FavCharBtn` / `cycle_favorite_character`)**: `collection_item.gd`에 `favorite_character` 및 6종 프리셋(`🌟 최애 캐릭터`, `🏀 강백호`, `🧙‍♀️ 프리렌`, `🐾 치이카와`, `🏐 히나타`, `🌸 체리`) 추가, `archive_state.gd` JSON 영구 저장/복원 연동 및 `detail_modal.tscn` `InkRow`에 배치
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#favchar-cycle-btn` / `cycleFavoriteCharacter()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 40 4단 가치순 정렬 및 최애 캐릭터 스탬프 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 39] 모달 태그·띠지 줄바꿈 개선(`autowrap_mode = 3`) & 소장품 추정 가치 +₩5,000 원터치 조정(`💎 +5천원`)
- **시각**: 2026-11-15 19:18 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달 상단의 빨간 태그·띠지 문구(`TagLabel`)가 한 줄 말줄임(`...`)으로 잘리는데, 자연스럽게 줄바꿈되어 띠지 문구까지 끝까지 다 읽히면 좋겠어요!"*
  - **가챠 수집러 B**: *"한정판이나 프리미엄 시세가 붙은 소장품의 추정 가치를 모달 안에서 `💎 +5천원` 원터치로 바로 올려서 서재 자산에 반영할 수 있으면 좋겠습니다."*
  - **미니멀 수집러 C**: *"가치를 조정하자마자 모달 상단의 `💎 ₩...`과 메인 헤더의 `자산 ₩...`이 동시에 실시간 갱신되면 직관적입니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **모달 태그·띠지 줄바꿈 개선(`detail_modal.tscn`)**: `TagLabel`의 `text_overrun_behavior = 3`을 `autowrap_mode = 3`(`AUTOWRAP_WORD_SMART`)으로 전환해 띠지 문구 잘림 현상 해소
  - **소장품 추정 가치 +₩5,000 원터치 조정(`ValueBtn` / `boost_estimated_value`)**: `collection_item.gd`에 `boost_estimated_value(5000)` 추가, `detail_modal.tscn` `InkRow`에 `💎 +5천원` 버튼 배치 및 `detail_modal.gd`에서 모달·헤더 총 자산 실시간 동기화
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#value-boost-btn` / `boostEstimatedValue()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 39 `TagLabel autowrap_mode` 및 추정 가치 실시간 업 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 38] 커스텀 태그·보관위치·입수처 통합 검색 · 모달 추정 가치 표시 · 감상 카드 서명·태그 공유
- **시각**: 2026-11-15 18:58 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 고른 커스텀 태그(`#소장각`, `#인생만화`)나 보관위치(`🗄️ 1층 장식장`)로도 메인 검색창에서 바로 필터링되면 좋겠어요!"*
  - **가챠 수집러 B**: *"모달을 열었을 때 작가명 옆에 이 소장품의 추정 가치(`💎 ₩21,000`)가 바로 표시되면 훨씬 직관적입니다."*
  - **미니멀 수집러 C**: *"감상 카드 공유(`💌 공유`)를 눌렀을 때 커스텀 태그와 내 서명(`✍️ 주희의 서재`)이 함께 복사되면 노트에 바로 붙여넣기 좋습니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **커스텀 태그·보관위치·입수처 통합 검색(`archive_state.gd`)**: `get_filtered_items()` 검색 쿼리가 `custom_tag`, `storage_location`, `acquisition_source`까지 매칭하도록 확장
  - **모달 추정 가치 표시 & 감상 카드 서명·태그 공유(`detail_modal.gd`)**: `open(item)`에서 `author_label`에 콤마 포맷 추정 가치(`💎 ₩21,000`)를 노출하고, `copy_book_quote_card()`에 `custom_tag · diary_signature` 라인 추가
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html` 검색 필터에 `custom_tag`, `storage_location`, `acquisition_source` 매칭 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 38 태그 통합 검색, 모달 가치 표시 및 공유 카드 서명 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 37] 원화 천 단위 콤마 포맷터(`format_krw` · `₩80,000`) · 실시간 오늘 날짜 헤더 · 커스텀 키워드 태그(`#소장각` / `cycle_custom_tag`)
- **시각**: 2026-11-15 18:38 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"상단 헤더의 `자산 ₩80000`과 통계 브리핑 금액이 `₩80,000`처럼 천 단위 쉼표(콤마)로 표시되면 훨씬 읽기 편하고 정돈된 느낌일 것 같아요!"*
  - **가챠 수집러 B**: *"소장품마다 `#소장각`, `#인생만화`, `#힐링타임`, `#전시필수`, `#한정특전` 같은 키워드 해시태그를 일기장 모달에서 원터치로 달아둘 수 있으면 좋겠어요."*
  - **미니멀 수집러 C**: *"메인 상단의 날짜도 고정 텍스트 대신 오늘 날짜(`YYYY. MM. DD`)로 자동 갱신되면 진짜 매일 쓰는 나만의 일기장 같아집니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **원화 천 단위 콤마 포맷터(`format_krw`) & 실시간 오늘 날짜 헤더**: `archive_state.gd`에 `format_krw(amount)` 추가 및 `main_view.gd`의 `_update_stats()` / `show_library_infographic()`에 천 단위 콤마 금액(`₩80,000`)과 시스템 오늘 날짜(`YYYY. MM. DD`) 연동
  - **커스텀 키워드 태그 순환(`CustomTagBtn` / `cycle_custom_tag`)**: `collection_item.gd`에 `custom_tag` 추가 및 `archive_state.gd` JSON 영구 저장/복원 연동, `detail_modal.tscn` `InkRow`에 `#소장각` 원터치 순환 버튼 배치
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#tag-cycle-btn` / `cycleCustomTag()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 37 `format_krw` 콤마 포맷, 헤더 실시간 자산 및 커스텀 태그 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 36] 소장·구매 기념일 스탬프(`📅 기념일` / `stamp_purchase_date`) · 배송 상태 카드 배지 · 헤더 실시간 총 자산 요약
- **시각**: 2026-11-15 18:36 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달에서 오늘 날짜로 구매·완독 기념일(`📅 MM.DD`)을 원터치 스탬프로 찍어둘 수 있으면 훗날 서재를 돌아볼 때 추억이 선명할 것 같아요!"*
  - **가챠 수집러 B**: *"소장품이 '🛒 예약중'이나 '🚚 배송중' 상태일 때는 메인 카드에서도 바로 눈에 띄어야 아직 못 받은 택배를 한눈에 구분할 수 있습니다!"*
  - **미니멀 수집러 C**: *"서재 메인 상단 서브타이틀의 '서재 완독률' 옆에 현재 총 소장 자산(`자산 ₩...`)이 실시간으로 보이면 통계 토스트를 누르지 않아도 규모를 바로 파악할 수 있어요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **소장·구매 기념일 스탬프(`DateStampBtn` / `stamp_purchase_date`)**: `collection_item.gd`에 `purchase_date` 및 오늘 날짜(`📅 MM.DD`) 스탬프 메서드 추가, `archive_state.gd` JSON 영구 저장/복원 연동, `detail_modal.tscn` `InkRow`에 `📅 기념일` 원터치 스탬프 버튼 배치
  - **배송·예약 상태 카드 배지 & 헤더 실시간 총 자산(`card_item.gd` · `main_view.gd`)**: `possession_state != "📦 소장중"`일 때 카드 하단에 상태 배지를 노출하고, `main_view.gd` `_update_stats()` 상단 서브타이틀에 `자산 ₩...` 실시간 합산 표시
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#date-stamp-btn` / `stampPurchaseDate()` 및 카드 배송 상태 배지 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 36 기념일 스탬프 및 헤더 실시간 자산 요약 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 35] 메인 `FilterBar` `HFlowContainer` 반응형 줄바꿈 개선 & 소장품 배송·보유 상태 트래커(`📦 소장중` / `cycle_possession_state`)
- **시각**: 2026-11-15 11:08 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"메인 화면 상단의 필터 바(`FilterBar`) 오른쪽 끝 `↕ 기본순` 버튼이 화면 끝에서 살짝 잘려 보였는데, `HFlowContainer`로 깔끔하게 줄바꿈되게 고쳐주세요!"*
  - **가챠 수집러 B**: *"직구나 예약 구매한 가챠·만화책이 현재 '소장중/예약중/배송중/전시중' 중 어떤 상태인지 모달에서 원터치로 기록할 수 있으면 배송 관리가 편할 것 같아요!"*
  - **미니멀 수집러 C**: *"필터 탭과 검색창, 정렬 버튼이 두 줄로 깔끔하게 정돈되면 540px 모바일 화면에서도 여백과 시인성이 훨씬 좋아집니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **메인 `FilterBar` `HFlowContainer` 반응형 줄바꿈(`main.tscn`)**: `FilterBar/HBox`를 `HBoxContainer`에서 `HFlowContainer`(`h_separation=5`, `v_separation=4`)로 전환하고 `SearchInput` 최소 너비(`140px`)를 확보해 `↕ 기본순` 우측 클리핑 완전 해소
  - **소장품 배송·보유 상태 트래커(`PossessionBtn` / `cycle_possession_state`)**: `collection_item.gd`에 `possession_state` 추가 및 `archive_state.gd` JSON 영구 저장/복원 연동, `detail_modal.tscn` `StampRow`에 `📦 소장중` 원터치 순환 버튼(`📦 소장중`, `🛒 예약중`, `🚚 배송중`, `✨ 전시중`) 배치
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#possession-cycle-btn` / `cyclePossessionState()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 35 `FilterBar HFlowContainer` 및 배송·보유 상태 순환 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 34] `InkRow` `HFlowContainer` 반응형 줄바꿈 개선 · 일기장 서명 스탬프(`✍️ 주희의 서재`) · 서재 총 재독 횟수 브리핑(`get_total_rereads`)
- **시각**: 2026-11-14 15:24 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달의 잉크 팔레트(`InkRow`)에서도 오른쪽 끝의 `✒️펜촉` 버튼이 살짝 잘리는데 `StampRow`처럼 `HFlowContainer`로 줄바꿈되게 해주세요! 그리고 내 일기장만의 서명 스탬프(`✍️ 주희의 서재`, `🌙 밤독서 기록` 등)를 남길 수 있으면 좋겠어요."*
  - **가챠 수집러 B**: *"서재 인포그래픽 통계 브리핑에 총 소장 가치와 함께 서재 전체 누적 재독 횟수(`총 재독: N회`)도 한눈에 보이면 수집·감상 기록이 더 풍부해집니다."*
  - **미니멀 수집러 C**: *"서명 스탬프도 복잡한 입력창 대신 원터치 순환 버튼으로 깔끔하게 고를 수 있게 유지해 주세요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **`InkRow` `HFlowContainer` 반응형 줄바꿈(`detail_modal.tscn` · `detail_modal.gd`)**: `InkRow`를 `HBoxContainer`에서 `HFlowContainer`(`h_separation=5`, `v_separation=4`)로 전환해 `✒️펜촉` 버튼 우측 클리핑을 완전 해소
  - **일기장 서명 스탬프(`SignatureBtn` / `cycle_diary_signature`)**: `collection_item.gd`에 `diary_signature` 추가 및 `archive_state.gd` JSON 영구 저장/복원 연동, `InkRow`에 `✍️ 주희의 서재` 원터치 순환 버튼(`✍️ 주희의 서재`, `🌙 밤독서 기록`, `☕ 카페 다꾸`, `🎁 소장 기념`) 배치
  - **서재 총 재독 횟수 브리핑(`get_total_rereads`)**: `archive_state.gd`에 `get_total_rereads()` 추가 및 `main_view.gd` `show_library_infographic()`에 `총 재독: %d회` 실시간 브리핑 연동
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#signature-cycle-btn` / `cycleDiarySignature()` 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 34 `InkRow HFlowContainer`, 서명 스탬프 순환 및 총 재독 브리핑 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료

---

## 🚀 [Sprint 33] 일기장 모달 `HFlowContainer` 반응형 줄바꿈 개선 & 수집품 보유·중복 수량 카운터(`👯×N` / `increment_duplicate_count`)
- **시각**: 2026-11-14 06:39 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 모달(`detail_modal`)을 열었을 때 인장·테이프·무드 버튼들이 한 줄로 길게 늘어서서 모달 창이 좌우로 넘쳐 잘렸었는데, 줄바꿈되는 깔끔한 레이아웃으로 고쳐주세요!"*
  - **가챠 수집러 B**: *"같은 가챠 피규어나 굿즈를 여러 개 뽑았을 때 보유·중복 수량(`👯×2`, `👯×3`)을 기록하고 서재 총 자산 가치 계산에도 자동으로 곱해지면 좋겠어요!"*
  - **미니멀 수집러 C**: *"보유 수량이 1개일 땐 카드가 깔끔하게 유지되고, 2개 이상일 때만 `👯×N` 배지가 보이도록 해주세요."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **일기장 모달 `HFlowContainer` 반응형 줄바꿈(`detail_modal.tscn` · `detail_modal.gd`)**: `StampRow`를 `HBoxContainer`에서 `HFlowContainer`(`h_separation=5`, `v_separation=4`)로 전환하여 모달이 408px 뷰포트 중앙에 완벽히 정렬되도록 레이아웃 수정
  - **수집품 보유·중복 수량 카운터(`DuplicateBtn` / `increment_duplicate_count`)**: `collection_item.gd`에 `duplicate_count` 추가 및 `get_item_value()`에 수량 반영, `archive_state.gd` JSON 영구 저장/복원 연동, `detail_modal.tscn`에 `👯×1` 버튼 추가 및 `card_item.gd`에서 `> 1`일 때 `👯×N` 배지 표시
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#duplicate-cycle-btn` / `incrementDuplicateCount()` 및 카드 `👯 ×N` 배지 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 33 중복 수량 카운터 가치 연동 및 `HFlowContainer` 모달 레이아웃 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS (스크립트 에러 0건)
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처로 모달 중앙 정렬·줄바꿈 시각 검증 완료

---

## 🚀 [Sprint 32] 재독 횟수 카운터(`🔁 N회독` / `increment_reread_count`) & 소장품 추정 가치·서재 총 자산 브리핑(`get_total_collection_value`)
- **시각**: 2026-11-14 06:20 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"인생작을 몇 번이나 다시 읽었는지 일기장에 `🔁 2회독`, `🔁 3회독`처럼 기록하고 카드에서도 한눈에 보면 뿌듯할 것 같아요!"*
  - **가챠 수집러 B**: *"모은 만화책과 가챠 피규어들의 추정 소장 가치를 합산해서 내 서재의 총 자산이 얼마인지 통계 브리핑에서 확인하고 싶어요!"*
  - **미니멀 수집러 C**: *"재독 횟수가 1회독일 땐 깔끔하게 숨기고, 2회독 이상부터만 카드에 `🔁 N회독` 배지가 노출되면 미니멀한 레이아웃이 유지됩니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **재독 횟수 카운터(`RereadBtn` / `increment_reread_count`)**: `collection_item.gd`에 `reread_count` 및 `increment_reread_count()` 추가, `archive_state.gd` JSON 영구 저장/복원 연동, `detail_modal.tscn`에 `RereadBtn`(`🔁1회독`) 추가 및 `card_item.gd`에서 `> 1`일 때 `🔁N회독` 배지 자동 표시
  - **소장품 추정 가치 & 서재 총 자산 브리핑(`get_item_value` / `get_total_collection_value`)**: 권수 및 레어도(`🌟노말`, `💎레어`, `👑한정판`, `✨시크릿`) 기반 추정 가치 산출 및 `main_view.gd` `show_library_infographic()`에 `총 가치: ₩...` 실시간 브리핑 연동
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `#reread-cycle-btn` / `incrementRereadCount()` 및 카드 `🔁 N회독` 배지 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 32 재독 카운터 및 서재 총 자산 브리핑 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 31] 독서 감상 무드 태그(`🥰 힐링` / `cycle_reading_mood`) & 목표 권수 정밀 완독률 트래커(`target_volumes`)
- **시각**: 2026-11-14 06:00 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"책을 읽을 때 '감정 기분 태그(Mood Sticker)'(`🥰 힐링`, `🔥 열혈`, `😭 감동`, `🤯 반전`, `🤣 유쾌`)를 일기장 모달에서 고르면 독서 일기가 훨씬 생생해질 것 같아요!"*
  - **가챠 수집러 B**: *"소장품의 목표 완결 권수(`target_volumes`)를 설정해 두면 완결까지 얼마나 모았는지 정밀하게 파악할 수 있어서 수집 동기부여가 확실해집니다!"*
  - **미니멀 수집러 C**: *"메인 카드의 진행률 바가 목표 권수를 기반으로 정확한 퍼센티지(`get_completion_percentage()`)를 계산해 주면 훨씬 신뢰감 있는 트래커가 됩니다!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **독서 감상 무드 태그 순환(`MoodBtn` / `cycle_reading_mood`)**: `collection_item.gd`에 `reading_mood` 필드 추가 및 `archive_state.gd` JSON 연동. 모달 `StampRow`에 `MoodBtn` 배치하여 5종 무드 프리셋(`🥰 힐링`, `🔥 열혈`, `😭 감동`, `🤯 반전`, `🤣 유쾌`) 원터치 순환
  - **목표 권수 기반 정밀 완독률(`target_volumes` / `get_completion_percentage`)**: `collection_item.gd`에 `target_volumes`와 정밀 퍼센티지 계산 메서드를 구현하고 `card_item.gd` 진행률 바에 실시간 연동
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `cycleReadingMood()` 버튼 및 일기장 메타 라벨 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 31 무드 태그 및 목표 권수 완독률 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 30] 독서 몰입 앰비언트 백색소음(`🎧 앰비언트` / `cycle_ambient_sound`) & 소장품 입수처 트래커(`🏷️ 입수처` / `cycle_acquisition_source`)
- **시각**: 2026-11-14 00:23 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"책을 읽거나 일기를 쓸 때 몰입할 수 있도록 빗소리, 북카페, 책장넘김, 모닥불 등 앰비언트 백색소음(`🎧 앰비언트` / `cycle_ambient_sound`)을 고를 수 있으면 독서 분위기가 완성됩니다!"*
  - **가챠 수집러 B**: *"소장품을 어디서 샀는지(🏪 오프라인 서점, 🇯🇵 직구/해외, 🎁 선물, 🎪 팝업/행사, 📦 온라인 서점)를 기록하는 입수처 태그(`🏷️ 입수처` / `cycle_acquisition_source`)가 있으면 굿즈 아카이빙이 더욱 풍성해져요!"*
  - **미니멀 수집러 C**: *"상단 바의 일기 쓰기 옆에 앰비언트 백색소음 버튼이 배치되어 손쉽게 BGM 무드를 켜고 끌 수 있는 점이 아주 직관적입니다!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **독서 몰입 앰비언트 백색소음 플레이어(`AmbientBtn` / `cycle_ambient_sound`)**: `main_view.gd` 및 `main.tscn` 상단 타이틀 행에 `AmbientBtn`을 배치하고 6종 사운드 프리셋(`🔕 무음`, `🌧️ 빗소리`, `☕ 북카페`, `📖 책장넘김`, `🔥 모닥불`, `🦗 밤귀뚜라미`)을 원터치 순환 및 토스트 안내
  - **소장품 입수처/구매 경로 트래커(`SourceBtn` / `cycle_acquisition_source`)**: `collection_item.gd`에 `acquisition_source` 필드 추가 및 `archive_state.gd` JSON 연동. 5종 입수처 프리셋을 모달에서 순환 선택
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `cycleAmbientSound()` 및 `cycleAcquisitionSource()` 완벽 동기화
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 30 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 29] 일기장 종이 내지 패턴(`📜 종이질감` / `cycle_paper_pattern`) & 실물 보관 위치 트래커(`🗄️ 보관위치` / `cycle_storage_location`)
- **시각**: 2026-11-13 07:47 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장을 펼쳤을 때 종이 내지 스타일(📄 줄노트, 📜 모눈, 📋 무지, 🍂 양장)을 원터치로 변경할 수 있는 `📜 종이질감` 순환 버튼이 있으면 필기 쾌감이 극대화될 것 같아요!"*
  - **가챠 수집러 B**: *"실물 가챠나 아크릴 굿즈를 어디에 뒀는지 잊지 않도록, '보관 위치'(🗄️ 1층 장식장, 📦 아크릴함, 📚 책상 선반, 🎒 외출 파우치)를 등록하고 순환 선택하는 `🗄️ 보관위치` 트래커가 있으면 실물 소장품 정리에 큰 도움이 됩니다!"*
  - **미니멀 수집러 C**: *"상세 일기장 상단 메타 정보에 스탬프, 데코 스티커, 레어도, 보관 위치까지 한눈에 조화롭게 보이도록 다꾸 레이아웃을 고도화해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **일기장 종이 패턴 순환(`PaperBtn` / `cycle_paper_pattern`)**: `collection_item.gd`에 `paper_pattern` 필드 추가 및 `archive_state.gd` JSON 연동. 4종 종이 스타일(`📄줄노트`, `📜모눈`, `📋무지`, `🍂양장`)을 원터치 순환 및 영구 보존
  - **실물 소장품 보관 장소 트래커(`StorageBtn` / `cycle_storage_location`)**: `collection_item.gd`에 `storage_location` 필드 추가 및 `archive_state.gd` 연동. 4종 보관 프리셋(`🗄️ 1층 장식장`, `📦 아크릴함`, `📚 책상 선반`, `🎒 외출 파우치`)을 순환 선택
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `cyclePaperPattern()` 및 `cycleStorageLocation()` 완벽 동기화
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 29 종이 패턴 및 보관 위치 트래커 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 28] 소장품 레어도 등급 순환(`💎 레어도` / `cycle_rarity_tier`) & 스마트 퀵 태그 필터(`filter_by_smart_tag`)
- **시각**: 2026-11-13 07:27 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **가챠 수집러 B**: *"가챠나 굿즈 소장품을 등록할 때 '소장 만족도/레어도'(🌟 노말, 💎 레어, 👑 슈퍼레어, 🔮 시크릿)를 순환 지정할 수 있는 레어도 배지 순환기(`💎 레어도` / `cycle_rarity_tier`)가 있으면 수집 앨범의 묘미가 한층 살아날 것 같아요!"*
  - **미니멀 수집러 C**: *"서재 상단 검색창에서 일일이 텍스트를 입력하지 않고도, `#완독`, `#초판`, `#인생작`, `#가챠` 같은 태그 칩을 누르면 1초 만에 스마트 필터링되는 스마트 퀵 태그 검색(`filter_by_smart_tag`)이 있으면 탐색이 아주 쾌적해집니다!"*
  - **만년필 다꾸러 A**: *"상세 일기장 모달에서 스탬프 도장 정보뿐 아니라 현재 아이템의 레어도 등급까지 1열로 예쁘게 정돈되어 표시되면 다꾸 레이아웃 완성도가 완벽해질 것 같아요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **소장품 레어도/만족도 등급 순환(`RarityBtn` / `cycle_rarity_tier`)**: `collection_item.gd`에 `rarity_tier` 속성을 추가하고 `archive_state.gd` JSON 연동. 모달 `StampRow`에 `💎레어` 버튼을 배치하여 4종 등급(`🌟노말`, `💎레어`, `👑슈퍼레어`, `🔮시크릿`)을 원터치 순환 및 영구 보존. 메인 서재 카드 표지에도 가챠 소장품의 레어도 배지가 즉각 반영
  - **스마트 퀵 태그 원터치 필터링(`filter_by_smart_tag`)**: `main_view.gd`에서 `#전체`, `#만화`, `#가챠`, `#완독`, `#초판`, `#인생작` 등의 스마트 태그를 즉시 선별하고 카드 그리드를 갱신하는 쾌속 필터링 시스템 탑재
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `cycleRarityTier()` 및 가챠 카드 레어도 배지 동기화 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 28 레어도 순환 및 스마트 태그 필터 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 27] 일기장 다꾸 데코 스티커 팩(`✨ 스티커` / `cycle_deco_sticker`) & 1초 퀵 진도 추가(`quick_advance_volume`)
- **시각**: 2026-11-13 07:07 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"독서 일기장 모달에서 감상이나 문장을 기록할 때 감성적인 다꾸 스티커 팩(`✨`, `🌸`, `☕`, `🌙`, `🍀`, `🎧`)을 골라 붙일 수 있는 `✨ 스티커` 순환 버튼이 있으면 좋겠어요!"*
  - **미니멀 수집러 C**: *"단행본을 읽고 바로 다음 권으로 진도를 나갈 수 있도록, 메인 서재 카드의 진행률이나 빠른 진도 액션(`quick_advance_volume()`)으로 1초 만에 권수 추가 및 완독 통계 업데이트가 되면 좋겠어요!"*
  - **가챠 수집러 B**: *"서재 카드 표지의 도장 배지 옆에도 선택된 다꾸 스티커(`💮전권완결 ✨`)가 아기자기하게 함께 표시되어 소장품마다 개성을 나타낼 수 있으면 좋겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **다꾸 데코 스티커 팩 순환(`DecoStickerBtn` / `cycle_deco_sticker`)**: `collection_item.gd`에 `deco_sticker` 필드 추가 및 `archive_state.gd` JSON 연동. 모달 `StampRow`에 `DecoStickerBtn`을 배치하여 6종 데코 스티커(`✨`, `🌸`, `☕`, `🌙`, `🍀`, `🎧`)를 원터치로 변경하고 일기장 상단 및 메인 카드 배지에 실시간 반영
  - **1초 퀵 진도 추가(`quick_advance_volume` / `quick_advanced` 시그널)**: `collection_item.gd`에 `quick_advance_volume()` 함수를 구현하고, `card_item.gd`에서 빠른 진도 갱신 시 `quick_advanced` 시그널을 방출하여 서재 통계와 책등 진열대를 자동 갱신
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `cycleDecoSticker()` 및 스티커 팩 순환 버튼 탑재 완료
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 Sprint 27 데코 스티커 순환 및 퀵 진도 업 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 26] 마스킹 테이프 색상 순환(`🎨 마테` / `cycle_washi_tape`) & 서재 인포그래픽 통계 브리핑(`show_library_infographic`)
- **시각**: 2026-11-13 07:00 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 상단의 마스킹 테이프 색상도 책의 분위기에 맞춰 버터옐로우, 피치핑크, 세이지그린, 스카이블루, 라벤더로 원터치 변경할 수 있는 `🎨 마테` 순환 버튼이 있으면 좋겠어요!"*
  - **미니멀 수집러 C**: *"상단 서재 통계 바(보관 권수, 완독률 등)를 클릭하거나 호출할 때 전체 서재의 통계 브리핑(소장 권수, 완독 권수, 북마크 수, 평균 별점)을 정갈한 인포그래픽 텍스트로 조회할 수 있으면 좋겠어요!"*
  - **가챠 수집러 B**: *"웹 인터랙티브 목업(`game02/index.html`)에서도 마스킹 테이프 5종 파스텔 팔레트 순환 인터랙션이 그대로 동작하도록 동기화해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **다꾸 마스킹 테이프 색상 순환(`TapeCycleBtn` / `cycle_washi_tape`)**: `collection_item.gd`에 `washi_tape_color` 필드 추가 및 `archive_state.gd` JSON 저장/불러오기 연동. 모달 상단 마스킹 테이프 색상을 5종 파스텔 팔레트(`버터옐로우`, `피치핑크`, `세이지그린`, `스카이블루`, `라벤더`)로 원터치 순환 적용 (`_apply_washi_style()`)
  - **서재 통계 인포그래픽 브리핑(`show_library_infographic()`)**: `main_view.gd`에서 서재의 소장 총 권수, 완독률, 북마크 권수, 컬렉션 평점을 종합 브리핑하는 인포그래픽 브리핑 기능 탑재
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 `applyJournalWashiTape` 및 `cycleWashiTape()` 추가하여 Godot과 100% 동일한 비주얼/인터랙션 경험 제공
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `cycle_washi_tape()` 및 `show_library_infographic()` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 25] 만년필 펜촉 두께 순환(`✒️ 펜촉` / `cycle_pen_nib_size`) & 독서 감상 카드 공유(`copy_book_quote_card`)
- **시각**: 2026-11-13 05:06 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"일기장 밑줄 문장의 폰트 크기를 세필(Fine 10px), 중필(Medium 12px), 태필(Broad 14px)로 직접 조절하는 펜촉 두께 버튼(`✒️펜촉`)이 있으면 캘리그래피 감성이 극대화될 것 같아요!"*
  - **미니멀 수집러 C**: *"책 1권의 감상평과 스탬프, 평점을 인스타나 SNS에 예쁘게 복사할 수 있는 '💌 감상 카드 공유' 버튼을 모달에 달아주세요!"*
  - **가챠 수집러 B**: *"메인 서재 카드에서도 가챠·굿즈 아이템은 진행률 바 대신 `🔮가챠` 굿즈 배지가 표시되어 수집 앨범 느낌이 살았으면 좋겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **만년필 펜촉 두께 순환(`NibBtn` / `cycle_pen_nib_size`)**: `collection_item.gd`에 `pen_nib_size`(10, 12, 14) 필드를 탑재하고, `detail_modal.gd`에서 원터치 순환 시 밑줄 라벨 글자 크기 동적 반영 및 영구 보존
  - **독서 감상 카드 클립보드 복사(`ShareCardBtn` / `copy_book_quote_card`)**: 펼친 독서노트 상단에 `💌 공유` 버튼을 배치해 한 줄 감상 카드를 시스템 클립보드에 원터치 복사 지원
  - **가챠 전용 카드 라벨링**: `card_item.gd`에서 `category == 1`일 때 `🔮가챠` 배지와 `진열완료 / 보관중` 맞춤 텍스트 제공
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`에 펜촉 크기 순환(`cycleDiaryNib`) 및 감상 카드 복사(`copyBookQuoteCard`) 탑재
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `cycle_pen_nib_size()` 및 `copy_book_quote_card()` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 24] 권별 골드 북마크 리본(`🔖 북마크` / `toggle_volume_bookmark`) & 서재 카드 북마크 배지 연동
- **시각**: 2026-11-13 05:01 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"독서 일기장 모달에서 특정 권의 대사가 감명 깊을 때 권별로 북마크 리본 스티커(`🔖 북마크`)를 꽂아둘 수 있으면 좋겠어요!"*
  - **미니멀 수집러 C**: *"일기장을 펼치지 않고도 메인 서재 카드 표지에서 북마크가 꽂힌 작품인지 골드 리본 배지(`🔖`)로 바로 보이면 좋겠습니다!"*
  - **가챠 수집러 B**: *"웹 인터랙티브 목업(`game02/index.html`)에서도 권별 리스트에 `🔖/🏷️` 북마크 토글 버튼이 작동하도록 동기화해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **권별 북마크 토글(`toggle_volume_bookmark` / `bm_btn`)**: `detail_modal.gd`의 권별 행에 `🔖/🏷️` 플랫 토글 버튼을 추가하여 원터치로 북마크 상태를 변경하고 `archive_data_v2.json`에 영구 보존
  - **서재 카드 북마크 리본 배지 연동**: `collection_item.gd`에 `get_bookmarked_volumes_count()`를 추가하고, `card_item.gd`에서 북마크된 권수가 있을 경우 권수 배지에 골드 리본(`🔖`)을 함께 표시
  - **HTML 인터랙티브 목업 동기화**: `game02/index.html`의 권별 목록에 북마크 토글 인터랙션(`toggleVolBookmark`) 추가
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `toggle_volume_bookmark()` 및 `get_bookmarked_volumes_count()` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 23] 3단 정렬 사이클러(`↕ 최신순`) & 미니 책등 호버 미리보기 툴팁(`Spine Hover Tooltip`)
- **시각**: 2026-11-13 04:12 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"상단 미니 책등 진열대(`SpineShelfRow`)에서 꽂힌 책등에 마우스를 올리면 어떤 책인지 권수와 제목이 툴팁과 하단 토스트로 바로 보이면 실제 책장에서 책을 쏙 빼보는 느낌이 들 것 같아요!"*
  - **미니멀 수집러 C**: *"기본순과 다독순 외에도 최근에 메모를 쓰거나 권을 추가한 책이 맨 위로 올라오는 '최근 기록순(`↕ 최신순`)' 정렬도 원터치로 순환되면 좋겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **3단 정렬 사이클러(`sort_mode`: 기본순 ↔ 다독순 ↔ 최신순)**: `collection_item.gd`에 `updated_at` 타임스탬프 필드를 탑재하고, `main_view.gd`의 정렬 버튼 클릭 시 3가지 정렬 모드를 매끄럽게 순환하도록 고도화
  - **미니 책등 호버 미리보기 & 툴팁**: `_render_spine_shelf()`에서 각 책등의 `tooltip_text` 및 `mouse_entered` 이벤트를 바인딩하여 호버 시 `📚 책등 엿보기: [제목] ([권수]권)` 토스트 알림 제공
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 3-way `sort_mode` 순환, `tooltip_text`, `updated_at` 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 22] 밑줄 형광펜 하이라이터(`🖍️ 형광펜` / `toggle_quote_highlight`) & 만점 인생작 전용 필터(`★ 인생작`)
- **시각**: 2026-11-13 03:35 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"굿노트처럼 가장 마음에 와닿은 명대사 밑줄에 부드러운 노란색 파스텔 형광펜(`🖍️ 형광펜`) 하이라이트 배경 효과를 온/오프할 수 있으면 일기장이 훨씬 생생해질 것 같아요!"*
  - **가챠 수집러 B**: *"소장품 중에서 평균 별점 5.0 만점이거나 `♥인생최애` 스탬프가 찍힌 명작들만 싹 모아볼 수 있는 `★ 인생작` 필터 탭을 만들어 주세요!"*
  - **미니멀 수집러 C**: *"웹 인터랙티브 목업(`game02/index.html`)에도 잉크 팔레트와 형광펜 토글, 추천 버튼이 완벽히 동기화되어 브라우저에서도 시연 가능했으면 좋겠습니다."*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **밑줄 형광펜 하이라이터(`HighlightBtn` / `toggle_quote_highlight`)**: `detail_modal.tscn`에 `🖍️ 형광펜` 버튼을 탑재하고, `highlight_enabled` 토글 시 따뜻한 파스텔 옐로우 하이라이트 배경(`Color(1.0, 0.94, 0.70, 0.75)`)을 `memo_label`에 부드럽게 적용
  - **만점 인생작 전용 필터 탭(`TabFav` / `_on_tab_fav_pressed`)**: 필터바에 `★ 인생작` 탭을 추가하여 평균 평점 5.0 만점 및 `인생최애` 소장품만 즉시 선별
  - **HTML 인터랙티브 목업 풀 동기화**: `game02/index.html`에 만년필 잉크 팔레트, 형광펜 하이라이터, `🎲 추천`, `★ 인생작` 탭 전체 반영
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `toggle_quote_highlight()` 및 `_on_tab_fav_pressed()` 자동화 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 21] 만년필 잉크 컬러 선택기(`INK_PRESETS` / `set_fountain_pen_ink`) & 감성 서재 룸 테마 연동
- **시각**: 2026-11-13 02:05 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"다꾸 일기장의 백미는 만년필 잉크 색깔(에스프레소, 버건디, 세피아, 포레스트 그린)을 기분에 따라 바꿔 적는 것입니다! 밑줄 문장 기록 시 잉크 컬러를 직접 골라 저장할 수 있게 해주세요!"*
  - **미니멀 수집러 C**: *"서재 배경 테마(`ROOM_THEMES`)와 만년필 잉크 컬러가 자연스럽게 어우러지도록 로컬 JSON 저장 및 모달 UI 색상에 즉시 반영되게 해주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **만년필 잉크 컬러 선택기(`InkRow` / `set_fountain_pen_ink`)**: `detail_modal.tscn`에 4종 빈티지 만년필 잉크 스와치 버튼(`☕에스프레소`, `🍷버건디`, `🍂세피아`, `🌲포레스트`)을 추가하고, 클릭 시 `memo_ink_color` 갱신 및 `_apply_ink_style()`로 밑줄 텍스트 색상 실시간 연동
  - **영구 보존 및 데이터 구조 확장**: `collection_item.gd` 및 `archive_state.gd`의 JSON 직렬화/역직렬화에 `memo_ink_color` 포함
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `set_fountain_pen_ink("#7f1d1d")` 및 테마 순환 검증 추가 → 3개 헤드리스 테스트 스위트 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 20] 권별 독서 날짜 타임스탬프(`📅 11.12` / `stamp_volume_date`) & 서재 전체 완독률 실시간 게이지(`81%`)
- **시각**: 2026-11-12 23:05 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"권별 일기에서 명대사뿐만 아니라 내가 이 권을 언제 읽었는지 날짜 스탬프(`📅 11.12`)를 원터치로 찍을 수 있으면 실제 손때 묻은 독서 일기장 느낌이 물씬 날 것 같아요!"*
  - **미니멀 수집러 C**: *"상단 서재 헤더에 내 전체 서재의 평균 독서 완독률(예: `서재 완독률 81%`)이 실시간으로 계산되어 보이면 좋겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **권별 날짜 스탬프(`stamp_volume_date` / `date_btn`)**: `collection_item.gd`의 권별 딕셔너리에 `date` 필드를 표준 탑재하고, `detail_modal.gd`에서 `📅 11.12` 미니 스탬프 버튼을 클릭 시 오늘 날짜로 즉시 스탬프 저장
  - **서재 전체 완독률 실시간 계산(`get_overall_reading_progress`)**: `main_view.gd`에서 소장 도서 전체의 완독 상태를 종합 계산하여 상단 헤더(`서재 완독률 81%`)에 동적 노출
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `stamp_volume_date(0)` 및 `get_overall_reading_progress()` 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 19] 랜덤 추천 작품 뽑기(`🎲 추천` / `pick_random_item`) & 완독작 전용 필터 탭(`💮 완독작`) 탑재
- **시각**: 2026-11-12 22:45 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **만년필 다꾸러 A**: *"서재에 꽂힌 만화책이 점점 늘어나는데, 오늘 어떤 걸 다시 읽을지 고민될 때 눌러볼 수 있는 '랜덤 책갈피 뽑기(`🎲 추천`)'가 상단에 있으면 너무 재미있을 것 같아요!"*
  - **미니멀 수집러 C**: *"필터바에 전체, 이북, 가챠 외에 `💮 완독작` 탭도 추가해 주시면 완독한 명작들만 싹 모아서 뿌듯하게 볼 수 있겠어요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **랜덤 추천 뽑기(`RandomPickBtn` / `pick_random_item`)**: 상단 책등 배너에 `🎲 추천` 버튼을 배치하고 누르면 서재 소장품 중 무작위 1종을 추첨하여 펼친 독서노트 모달을 열고 추천 토스트 노출
  - **완독작 전용 탭(`TabComplete` / `_on_tab_complete_pressed`)**: 필터바에 `💮 완독작` 탭을 추가하여 완독 100% 도달작만 즉시 선별
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `pick_random_item()` 및 `_on_tab_complete_pressed()` 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

---

## 🚀 [Sprint 18] E-Book 독서 진행률 트래커(`ReadingProgressBar`) & 권별 완독률 퍼센티지(`완독 100%`) 탑재
- **시각**: 2026-11-12 22:29 KST
- **1. 다꾸러 3인 VOC (수집러 A · 가챠러 B · 미니멀러 C)**
  - **이북 다꾸러 A**: *"리디북스나 밀리의 서재처럼 각 단행본 카드에서 내가 얼마나 읽었는지 보여주는 '독서 진행률 프로그레스 바'와 '완독 100% / 75%' 퍼센티지가 카드에 표시되면 독서 기록 동기부여가 200% 될 것 같아요!"*
  - **미니멀 수집러 C**: *"프로그레스 바 색상도 차가운 파란색이 아니라 일기장에 어울리는 테라코타 오렌지와 미색 종이 질감으로 깔끔하게 매치해 주세요!"*
- **2. 기획 & UI/UX & Godot 4.6 개발 내역**
  - **독서 진행률 프로그레스 바(`ProgressBar` & `ProgressRow`)**: `card_item.tscn`에 미색 배경(`StyleBoxFlat_progress_bg`)과 따뜻한 테라코타 잉크 채움(`StyleBoxFlat_progress_fill`) 바 탑재
  - **완독률 자동 계산 로직(`get_reading_progress()`)**: `card_item.gd`에서 `전권완결`/`완독` 태그는 즉시 `완독 100%`, 그 외 소장 권수 기반으로 25%~75% 진행률 자동 산출 및 라벨 표시
- **3. TDD & QA 검증**
  - `tests/test_main_integration.gd`에 `get_reading_progress()` 및 `ProgressBar` 노드 바인딩 자동화 검증 추가 → 전수 100% PASS
  - Metal 렌더러 최신 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 및 GitHub 푸시 완료

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
