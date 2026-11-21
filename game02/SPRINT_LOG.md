# 📋 Pocket Archive (Game02) — 14인 애자일 스쿼드 스프린트 누적 회의록

- **조직 구성**: CEO(1명), 실제 다꾸러·수집러(3명: 소장러 A, 가챠러 B, 미니멀러 C), 기획자(2명: PO, 서비스 기획), UX/UI 디자이너(2명), 개발자(4명), QA 엔지니어(2명)
- **운영 주기**: 20분 주기 자율 스프린트 (`VOC 취합 -> 기획 정리 -> HTML 목업/UI -> 전원 회의 -> Godot 4.6 개발 -> TDD/QA 검증 -> 스크린샷 캡처 & README 업데이트 -> Git Commit & Push`)

---

## 📓 [Sprint 210 Milestone] 3대 뷰 전역 `Ctrl/Cmd+E` 이북·편집·분류 · `Ctrl/Cmd+W` 모달 닫기·스크랩
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "입력창 포커스 중에도 브라우저·에디터처럼 `Ctrl/Cmd+W`로 열린 모달(`DetailModal`/`AddModal`)을 바로 닫고(`MainView`: 웹 스크랩), `Ctrl/Cmd+E`로 이북·단행본 필터(`MainView`)·밑줄 편집 포커스(`DetailModal`)·이북 분류 선택(`AddModal`)을 실행하고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단에 `ctrl_pressed or meta_pressed` + `KEY_E`/`KEY_W` 분기를 추가해 3대 뷰 전역 `Ctrl/Cmd` 워크플로우를 완성한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `Ctrl/Cmd+E`(이북·단행본 필터 / `Shift`: 첫 작품 열기) 및 `Ctrl/Cmd+W`(웹 스크랩 / `Shift`: 첫 작품 열기) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `Ctrl/Cmd+E`(밑줄 편집 포커스 / `Shift`: 샘플 채움) 및 `Ctrl/Cmd+W`(모달 닫기 / `Shift`: 복사+닫기) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `Ctrl/Cmd+E`(이북·만화 분류 선택 / `Shift`: 등록) 및 `Ctrl/Cmd+W`(모달 닫기 / `Shift`: 비우고 닫기) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Ctrl/Cmd+E`, `Ctrl/Cmd+W` 전역 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): 포커스 상태 `Ctrl+E`, `Ctrl+W` 3대 뷰 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 209] 3대 뷰 전역 `Ctrl/Cmd+I` 인포그래픽·잉크·샘플 · `Ctrl/Cmd+G` 가챠·등급·분류
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "입력창 포커스 중에도 `Ctrl/Cmd+I`로 서재 인포그래픽 브리핑(`MainView`)·만년필 잉크 순환(`DetailModal`)·샘플 일기 채움(`AddModal`)을 바로 실행하고, `Ctrl/Cmd+G`로 가챠노트 필터(`MainView`)·상태 등급 순환(`DetailModal`)·가챠 분류 선택(`AddModal`)을 조작하고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단에 `ctrl_pressed or meta_pressed` + `KEY_I`/`KEY_G` 분기를 추가한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `Ctrl/Cmd+I`(인포그래픽 / `Shift`: JSON 백업) 및 `Ctrl/Cmd+G`(가챠노트 필터 / `Shift`: 첫 작품 열기) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `Ctrl/Cmd+I`(잉크 순환) 및 `Ctrl/Cmd+G`(상태 등급 순환) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `Ctrl/Cmd+I`(샘플 채움 / `Shift`: 등록) 및 `Ctrl/Cmd+G`(가챠·굿즈 선택 / `Shift`: 등록) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Ctrl/Cmd+I`, `Ctrl/Cmd+G` 전역 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): 포커스 상태 `Ctrl+G`, `Ctrl+I` 3대 뷰 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 208] 3대 뷰 전역 `Ctrl/Cmd+L` 오늘밑줄·형광펜·초기화 · `Ctrl/Cmd+D` 완독·복수소장
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "입력창 포커스 중에도 `Ctrl/Cmd+L`로 오늘의 밑줄 작품 열기(`MainView`), 형광펜 토글(`DetailModal`), 입력란 비우기(`AddModal`)를 실행하고, `Ctrl/Cmd+D`로 완독작 필터(`MainView`)와 복수 소장 수량 증감(`DetailModal`)을 바로 조작하고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단에 `ctrl_pressed or meta_pressed` + `KEY_L`/`KEY_D` 분기를 추가한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `Ctrl/Cmd+L`(오늘의 밑줄 작품 열기) 및 `Ctrl/Cmd+D`(완독작 필터 / `Shift`: 첫 작품 열기) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `Ctrl/Cmd+L`(형광펜 토글 / `Shift`: 속지 패턴) 및 `Ctrl/Cmd+D`(복수 소장 +1 / `Shift`: -1) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `Ctrl/Cmd+L`(입력란 초기화) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Ctrl/Cmd+L`, `Ctrl/Cmd+D` 전역 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): 포커스 상태 `Ctrl+D`, `Ctrl+L` 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 207] 3대 뷰 전역 `Ctrl/Cmd+R` 랜덤·회독·컬러 · `Ctrl/Cmd+B` 백업·리포트
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`Ctrl/Cmd+S`, `Ctrl/Cmd+N`, `Ctrl/Cmd+K`처럼 입력칸 포커스 중에도 `Ctrl/Cmd+R`로 랜덤 작품 추천(`MainView`)·회독 수 증가(`DetailModal`)·랜덤 표지 컬러(`AddModal`)를 바로 실행하고, `Ctrl/Cmd+B`로 즉시 JSON 백업(`Shift`: 요약 리포트 복사)을 하고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단에 `ctrl_pressed or meta_pressed` + `KEY_R` 분기를 추가하고, `MainView`에 `Ctrl/Cmd+B` 백업/리포트 분기를 추가한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `Ctrl/Cmd+R`(랜덤 추천 / `Shift`: 필터만) 및 `Ctrl/Cmd+B`(즉시 JSON 백업 / `Shift`: 리포트 복사) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `Ctrl/Cmd+R`(회독 수 증가 / `Shift`: 감소) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `Ctrl/Cmd+R`(랜덤 표지 컬러) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Ctrl/Cmd+R`, `Ctrl/Cmd+B` 전역 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): 포커스 상태 `Ctrl+B` 백업 및 3대 뷰 `Ctrl+R` 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 206] 3대 뷰 전역 `F1` 단축키 치트시트(Shift: 복사) · `Ctrl/Cmd+K` 검색창 포커스
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "입력창에 커서가 있을 때도 `F1` 키만 누르면 현재 화면(`MainView`/`DetailModal`/`AddModal`)에 맞는 단축키 치트시트를 바로 띄우고(`Shift+F1`: 복사), 노션·슬랙처럼 `Ctrl/Cmd+K`로 검색창에 즉시 포커스를 주고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단(포커스 체크 이전)에 `KEY_F1` 치트시트 분기를 추가하고, `MainView`의 `is_find` 조건에 `(event.keycode == KEY_K and (event.ctrl_pressed or event.meta_pressed))`를 통합한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `F1`(치트시트 / `Shift+F1`: 복사) 및 `Ctrl/Cmd+K`(검색창 포커스·전체 선택) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `F1`(모달 치트시트 / `Shift+F1`: 복사) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `F1`(새 일기 치트시트 / `Shift+F1`: 복사) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `F1` 3대 뷰 치트시트 및 `Ctrl/Cmd+K` 검색창 포커스 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `Ctrl+K` 및 3대 뷰 `F1` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 205 Milestone] 3대 뷰 전역 `Ctrl/Cmd+S` 저장·백업 · `Ctrl/Cmd+N` 새 일기 (포커스 중에도 동작)
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "검색창이나 일기 입력칸에 커서가 들어가 있는 상태에서도 `Ctrl/Cmd+S`를 누르면 즉시 저장·백업(`MainView`: JSON 백업, `DetailModal`: 밑줄 문장 저장, `AddModal`: 일기 등록 제출)되고, `Ctrl/Cmd+N`으로 새 일기 모달을 바로 띄우고 싶어요!"
  - **PO & UX/UI**: `MainView`, `DetailModal`, `AddModal`의 `_unhandled_input` 최상단(포커스 체크 이전)에 `ctrl_pressed or meta_pressed` + `KEY_S`/`KEY_N` 분기를 배치하여 입력창 포커스 중에도 표준 OS 단축키가 100% 동작하도록 구현한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `Ctrl/Cmd+S`(즉시 JSON 백업), `Ctrl/Cmd+N`(새 일기 모달 / `Shift`: 샘플 채움) 추가.
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `Ctrl/Cmd+S`(밑줄 저장) 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `Ctrl/Cmd+S`(일기 등록 / `Shift`: 샘플 폴백 등록) 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Ctrl/Cmd+S`, `Ctrl/Cmd+N` 전역 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): 포커스 상태 `Ctrl+S` 백업·등록·저장 및 `Ctrl+N` 모달 오픈 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 204] `DetailModal` & `AddModal` `/` 키 즉시 입력칸 포커스 — 3대 뷰 `/` 일관성 완성
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`MainView`에서 `/`를 누르면 검색창으로 바로 포커스가 가는 것처럼, `DetailModal`에서도 `/`를 누르면 한줄 밑줄 편집창(`quote_input`)으로, `AddModal`에서도 `/`를 누르면 제목 입력창(`title_input`)으로 즉시 이동하면 3개 화면 조작감이 100% 통일될 것 같아요!"
  - **PO & UX/UI**: `DetailModal`과 `AddModal` `_unhandled_input`에 `KEY_SLASH and not event.shift_pressed` 분기를 추가하여 각각 `quote_input` / `title_input`에 즉시 포커스하고 전체 선택(`select_all()`)을 수행한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_SLASH`(비Shift) 입력 시 `quote_input.grab_focus()` + `select_all()` 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_SLASH`(비Shift) 입력 시 `title_input.grab_focus()` + `select_all()` 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `/` 밑줄 입력칸 포커스 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `DetailModal` 및 `AddModal` `/` 키 입력 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 203] `DetailModal` `Tab`/`Shift+Tab` 이전·다음 작품 넘김 · 입력창 포커스 해제
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`MainView`와 `AddModal`처럼 `DetailModal`에서도 한줄 밑줄 입력창(`quote_input`) 수정 중 `Tab`을 누르면 포커스가 해제되고, 비포커스 상태에서 `Tab`/`Shift+Tab`으로 이전·다음 일기장을 한 손으로 넘겨보고 싶어요!"
  - **PO & UX/UI**: `DetailModal` `_unhandled_input`에 `KEY_TAB`(`quote_input.has_focus()` 시 `release_focus()`, 비포커스 시 `navigate_requested.emit(-1 if event.shift_pressed else 1)`)을 추가하여 3대 뷰 모두 일관된 `Tab` 내비게이션을 완성한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_TAB` 포커스 해제 및 카드 넘김 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `Tab`/`Shift+Tab` 카드 넘김 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `DetailModal` `Tab`/`Shift+Tab` 카드 넘김 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 202] `MainView` & `AddModal` `Tab`/`Shift+Tab` 필터 탭 순환 · 입력칸 포커스 이동
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "검색창에서 검색어를 치고 난 뒤 `Tab`을 누르면 바로 포커스가 해제되어 서재 단축키를 쓸 수 있고, 서재 메인에서는 `Tab`/`Shift+Tab`으로 5개 필터 탭을 오갈 수 있으면 정말 편하겠어요! `AddModal`에서도 `Tab`/`Shift+Tab`으로 제목·작가·밑줄 입력칸을 깔끔하게 순환하고 싶습니다."
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_TAB`(`search_input.has_focus()` 시 `release_focus()`, 비포커스 시 `_step_filter_tab(±1)`)을 추가하고, `AddModal` `_unhandled_input`에도 `KEY_TAB`으로 `title_input` ↔ `author_input` ↔ `quote_input` ↔ 포커스 해제 순환 로직을 구현한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_TAB` 검색 포커스 해제 및 5대 필터 탭 순환 분기 추가.
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_TAB` 3단 입력칸 포커스 순환 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `MainView` `Tab`/`Shift+Tab` 필터 탭 순환 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `MainView` `Tab`/`Shift+Tab` 탭 순환 및 `AddModal` `Tab` 입력칸 순환 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 201] `AddModal` 숫자키 `6` 바이올렛 컬러 · `7/8` 분류 · `9` 샘플 채움 — 새 일기 모달 `0~9` 완성
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`AddModal` 표지 스와치가 6개(크림슨·코발트·테라코타·로즈·포레스트·바이올렛)인데 `1~5`까지만 숫자키가 있어서 `6`번 바이올렛도 숫자키로 고르고, `7/8`로 이북·가챠 분류 선택, `9`로 샘플 일기 채움(`Shift+9`: 샘플 등록)까지 `0~9` 숫자키를 통일하고 싶어요!"
  - **PO & UX/UI**: `AddModal` `_unhandled_input`에 `KEY_6`(바이올렛 스와치), `KEY_7`/`KEY_8`(이북·만화/가챠·굿즈 선택), `KEY_9`(샘플 채움 / `Shift+9`: 샘플 등록)를 추가해 3대 뷰(`MainView`, `DetailModal`, `AddModal`) 모두 숫자키 `0~9` 100% 커버리지를 달성한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_6` 스와치, `KEY_7`/`KEY_8` 카테고리, `KEY_9` 샘플 채움 분기 추가.
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `_on_add_modal_help_requested()` 치트시트 안내 업데이트.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `6~9` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `6` 바이올렛 스와치, `7/8` 분류, `9` 샘플 채움 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 200 Milestone] `DetailModal` 숫자키 `9` 형광펜 토글(Shift: 복사+닫기) · 모달 `0~9` & 치트시트 100% 완성
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`DetailModal`에서 `1~4`(인장), `5~8`(만년필 잉크 4종), `0`(원문 복원)에 이어 마지막 숫자키 `9`로 형광펜 하이라이트를 즉시 토글(`Shift+9`: 형광펜 토글 후 독서 카드 복사+닫기)하고, `H` 모달 단축키 치트시트에도 `0~9` 및 `Enter`/`Bksp` 안내를 100% 반영해주세요!"
  - **PO & UX/UI**: `DetailModal` `_unhandled_input`에 `KEY_9`(`toggle_quote_highlight()` / `Shift+9`: `copy_book_quote_card(); close()`)를 추가해 메인과 모달 모두 `0~9` 전 숫자키 매핑을 완성한다. `MainView` `_on_modal_help_requested()` 치트시트에도 `[5~8] 잉크 · [9] 형광펜 · [0] 원문복원` 등을 동기화한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_9` 형광펜 토글 및 `Shift+9` 복사+닫기 분기 추가.
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `_on_modal_help_requested()` 모달 치트시트 동기화.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `9` 및 `Shift+9` 형광펜 토글 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `9` 형광펜 토글, `Shift+9` 복사+닫기, 모달 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 199] 메인 숫자키 `6~9` 4대 정렬 모드 즉시 전환(Shift: 첫 작품 열기) — 숫자 `0~9` 완전 매핑
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`0`(초기화)과 `1~5`(5대 필터 탭)에 이어 남은 숫자키 `6~9`로 4가지 정렬 모드(`6`: 기본순, `7`: 다독순, `8`: 최신순, `9`: 가치순)를 한 번에 고르고 `Shift+7~9`로 정렬된 첫 작품까지 바로 펼치면 숫자키 `0~9`가 빈틈없이 완성될 것 같아요!"
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_6`~`KEY_9` 분기를 추가해 `_set_sort_mode(event.keycode - KEY_6)`를 실행(`Shift+6`: `_reset_all_filters()`, `Shift+7~9`: `_open_first_filtered_card()`)하고, `KEY_H` 치트시트에 `[6~9] 정렬`을 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_6`~`KEY_9` 정렬 모드 직접 전환 분기 및 `_show_shortcut_cheatsheet()` 업데이트.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 메인 화면 `6~9` 및 `Shift+6~9` 정렬 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `6`/`7`/`8`/`Shift+9` 정렬 전환 및 `KEY_H` 치트시트 `[6~9] 정렬` 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 198] `DetailModal` 숫자키 `5~8` 만년필 잉크 4종 즉시 선택(Shift: 적용+닫기)
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`DetailModal`에서 `1~4`로 도장 인장을 바로 찍는 것처럼, `5~8` 숫자키로도 만년필 잉크 4종(`5`: 에스프레소, `6`: 버건디, `7`: 세피아, `8`: 포레스트)을 `I` 키로 순환하지 않고 바로 선택(`Shift+5~8`: 잉크 적용 후 닫기)하고 싶어요!"
  - **PO & UX/UI**: `DetailModal` `_unhandled_input`에 `KEY_5`~`KEY_8` 분기를 추가하여 `set_fountain_pen_ink()`를 호출하고 `Shift` 조합 시 `close()`로 이어지도록 구현한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_5`~`KEY_8` 만년필 잉크 4종 직접 선택 및 `Shift` 닫기 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `5~8` 만년필 잉크 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `6`/`7` 잉크 전환 및 `Shift+5` 잉크 적용+닫기 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 197] `DetailModal` 키보드 `↑/↓` 카드 넘김(Shift: 처음·끝) · `0` 문장 원문 복원
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`DetailModal`에서 `←/→`뿐만 아니라 `↑/↓` 방향키로도 이전/다음 일기를 넘기고(`Shift+↑/↓`: 처음·끝 작품 점프), 밑줄 문장을 고치다가 원문으로 되돌리고 싶을 때 `0` 키로 저장된 원문을 복원하고 삭제 무장도 해제(`Shift+0`: 닫기)하고 싶어요!"
  - **PO & UX/UI**: `DetailModal` `_unhandled_input`에 `KEY_UP`/`KEY_DOWN`(`navigate_requested.emit(±1)` / `Shift`: `±9999`) 및 `KEY_0`(`quote_input.text = current_item.memo` 원문 복원 및 `delete_armed` 해제 / `Shift+0`: 닫기)를 추가한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_UP`, `KEY_DOWN`, `KEY_0` 단축키 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `ArrowUp`/`ArrowDown`/`0` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `↑/↓` 카드 넘김 및 `0` 원문 복원 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 196] `DetailModal` 키보드 `Enter` 문장 편집(Shift: 형광펜) · `Backspace` 닫기(Shift: 복사+닫기)
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "펼친 독서노트(`DetailModal`)를 구경하다가 `Enter`만 누르면 한줄 밑줄 입력칸으로 바로 들어가고(`Shift+Enter`: 형광펜 토글), `Backspace`를 누르면 `ESC`처럼 일기장을 덮고(`Shift+Backspace`: 독서 카드 복사 후 닫기) 서재로 돌아가고 싶어요!"
  - **PO & UX/UI**: `DetailModal` `_unhandled_input`에 `KEY_ENTER, KEY_KP_ENTER`(`quote_input.grab_focus()` + `select_all()` / `Shift+Enter`: `toggle_quote_highlight()`)와 `KEY_BACKSPACE`(삭제 무장 해제 또는 `close()` / `Shift+Backspace`: `copy_book_quote_card(); close()`)를 추가한다.
- **구현 내역**:
  - [`detail_modal.gd`](godot_project/scripts/detail_modal.gd): `KEY_BACKSPACE`, `KEY_ENTER, KEY_KP_ENTER` 단축키 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `DetailModal` `Enter`/`Backspace` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `Shift+Enter` 형광펜 토글, `Backspace` 닫기, `Shift+Backspace` 카드 복사 후 닫기 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 195 Milestone] `AddModal` `H/?` 단축키 치트시트(Shift: 복사) · 단독 `Enter` 등록 제출
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`AddModal`에도 `MainView`나 `DetailModal`처럼 `H` 또는 `?`를 눌렀을 때 새 일기 모달 전용 단축키 치트시트가 토스트로 뜨면 좋겠어요(`Shift+H`: 클립보드 복사). 그리고 입력칸 밖에서 `Enter`만 눌러도 바로 등록되도록 해주세요!"
  - **PO & UX/UI**: `AddModal`에 `help_requested(copy_to_clipboard)` 시그널과 `KEY_H`/`Shift+KEY_SLASH`/`KEY_ENTER` 분기를 추가하고, `MainView`에 `_on_add_modal_help_requested()` 핸들러를 연결해 새 일기 단축키 전체 가이드를 안내한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `help_requested` 시그널 및 `KEY_ENTER`, `KEY_H`, `Shift+KEY_SLASH` 분기 추가.
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `add_modal.help_requested` 연결 및 `_on_add_modal_help_requested()` 핸들러 구현.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `H`/`?`/`Enter` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `AddModal` `H` 치트시트 토스트 및 비포커스 `Enter` 등록 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 194] `AddModal` 키보드 `0` 기본값 리셋 · `Home/End` 첫·끝 컬러 점프 · `Backspace` 초기화
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`AddModal`에서 작성 중이던 내용과 카테고리·컬러를 한 번에 처음 기본값으로 되돌리는 `0` 키(`Shift+0`: 리셋 후 닫기), 표지 스와치 맨 앞/끝으로 점프하는 `Home`/`End`, 그리고 입력칸 밖에서 `Backspace`로 비우기(`Shift+Backspace`: 비우고 닫기)가 있으면 좋겠어요!"
  - **PO & UX/UI**: `AddModal` `_unhandled_input`에 `KEY_0`(입력·카테고리·컬러 기본값 초기화 / `Shift+0`: 닫기), `KEY_HOME`/`KEY_END`(첫 번째/마지막 스와치 점프), `KEY_BACKSPACE`(`clear_inputs()` / `Shift+Backspace`: `close()`)를 추가한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_0`, `KEY_HOME`, `KEY_END`, `KEY_BACKSPACE` 단축키 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `0`/`Home`/`End`/`Backspace` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `Home`/`End` 스와치 점프, `0` 모달 기본값 리셋, `Shift+Backspace` 비우고 닫기 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 193] `AddModal` 키보드 `A/Q` 작가·밑줄 포커스 · `Space` 컬러 순환 · `R` 랜덤 표지 컬러
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`AddModal`에서 `T`로 제목칸에 포커스를 주는 것처럼 `A`(작가/브랜드)와 `Q`(한줄 밑줄) 입력칸에도 바로 이동하고, `Space`로 표지 컬러를 한 칸씩 넘기거나(`Shift+Space`: 역순) `R`로 랜덤 표지 컬러를 뽑아보고 싶어요(`Shift+R`: 랜덤 컬러+샘플 등록)!"
  - **PO & UX/UI**: `AddModal` `_unhandled_input`에 `KEY_A`(`author_input.grab_focus()`), `KEY_Q`(`quote_input.grab_focus()`), `KEY_SPACE`(`_step_color(±1)`), `KEY_R`(랜덤 표지 스와치 선택 / `Shift+R`: 샘플 폴백 등록)를 추가한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_A`, `KEY_Q`, `KEY_SPACE`, `KEY_R` 단축키 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `A`/`Q`/`Space`/`R` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `Space` 표지 순환, `R` 랜덤 컬러, `Shift+A` 작가 입력 초기화 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 192] `AddModal` 키보드 `E/G` 카테고리 직접 선택 · `T` 제목 포커스 · `S` 등록 제출
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`AddModal`에서 `C`로 카테고리를 토글하는 것도 좋지만 `E`(이북·만화), `G`(가챠·굿즈)로 바로 고르고, `T`로 제목 입력칸에 포커스를 주거나, `S`(Submit)로 바로 등록(`Shift+S`: 샘플 폴백 등록)할 수 있으면 완벽할 것 같아요!"
  - **PO & UX/UI**: `AddModal` `_unhandled_input`에 `KEY_E`(`cat_option.select(0)`), `KEY_G`(`cat_option.select(1)`), `KEY_T`(`title_input.grab_focus()` / `Shift+T`: 비우고 포커스), `KEY_S`(`_on_submit_btn_pressed()` / `Shift+S`: `_submit_with_sample_fallback()`)를 연결한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `KEY_S`, `KEY_E`, `KEY_G`, `KEY_T` 단축키 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `S`/`E`/`G`/`T` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_G`, `KEY_E`, `Shift+S` 샘플 폴백 등록 및 모달 닫힘 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 191] `AddModal` 키보드 `F` 샘플 채움 · `X` 입력 초기화(Shift: 닫기) · `←/→` 표지 컬러 순환
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "새 일기 쓰기(`AddModal`) 모달에서 입력창에 포커스가 없을 때 `1~5` 숫자키 대신 `←/→` 방향키로 표지 컬러를 부드럽게 넘기고, `F`(Fill)로 샘플 일기를 채워보거나 `X`로 입력란을 한 번에 비우고(`Shift+X`: 모달 닫기) 싶어요!"
  - **PO & UX/UI**: `AddModal`에 `fill_sample_inputs()`와 `_step_color(delta)` 헬퍼를 추가하고 `_unhandled_input`에 `KEY_F`(`fill_sample_inputs()` / `Shift+F`: `_submit_with_sample_fallback()`), `KEY_X`(`clear_inputs()` / `Shift+X`: `close()`), `KEY_LEFT`/`KEY_RIGHT`(`_step_color(±1)`)를 연결한다.
- **구현 내역**:
  - [`add_modal.gd`](godot_project/scripts/add_modal.gd): `fill_sample_inputs()`, `_step_color(delta)`, 및 `KEY_F`/`KEY_X`/`KEY_LEFT`/`KEY_RIGHT` 분기 추가.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `AddModal` `F`/`X`/`ArrowLeft`/`ArrowRight` 단축키 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `AddModal` `←/→` 컬러 순환, `F` 샘플 채움, `X` 비우기, `Shift+X` 닫기 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 190 Milestone] 메인 키보드 `Enter` 열기(Shift: 새 일기 모달) · `Backspace` 초기화(Shift: 스튜디오 리셋)
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "검색창이 아닌 서재 화면에서 `Enter`만 누르면 첫 번째 일기 모달이 바로 열리고(`Shift+Enter`: 새 일기 쓰기 모달 열기), `Backspace`를 누르면 뒤로가듯 검색과 필터가 초기화(`Shift+Backspace`: 정렬·테마까지 스튜디오 리셋)되면 키보드 조작이 완벽히 자연스러울 것 같아요!"
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_ENTER, KEY_KP_ENTER`(`_open_first_filtered_card()` / `Shift`: `_on_add_btn_pressed()`)와 `KEY_BACKSPACE`(`_reset_all_filters()` / `Shift`: `_set_sort_mode(0)` + `_reset_theme()`)를 추가하고 `KEY_H` 치트시트에 `[Enter] 열기 · [Bksp] 초기화`를 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_ENTER, KEY_KP_ENTER`, `KEY_BACKSPACE` 분기 및 `_show_shortcut_cheatsheet()` 업데이트.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `Enter`/`Backspace` 및 `Shift` 조합 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `Enter`, `Shift+Enter`, `Backspace`, `Shift+Backspace`, `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 189] 메인 키보드 `↑/↓` 정렬·사운드 순환 · `PageUp/PageDown` 필터 탭 순환
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`←/→`로 문장과 테마를 넘길 수 있게 되니, 상하 방향키 `↑/↓`로 정렬 기준(`기본·다독·최신·가치순`)이나 앰비언트 사운드(`Shift+↑/↓`)를 넘기고 `PageUp/PageDown`으로 `전체·이북·가챠·완독·인생작` 탭을 순서대로 순환하고 싶어요!"
  - **PO & UX/UI**: `MainView`에 `_step_filter_tab(delta)` 헬퍼를 추가하고, `KEY_UP`/`KEY_DOWN`(`_step_sort(±1)` / `Shift`: `cycle_ambient_sound(±1)`)과 `KEY_PAGEUP`/`KEY_PAGEDOWN`(`_step_filter_tab(±1)` / `Shift`: `_open_first_filtered_card()`)를 연결한다. `KEY_H` 치트시트에 `[↑/↓] 정렬·사운드 · [PgUp/Dn] 탭순환`을 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `_step_filter_tab()`, `KEY_UP`/`KEY_DOWN`/`KEY_PAGEUP`/`KEY_PAGEDOWN` 분기 및 `_show_shortcut_cheatsheet()` 업데이트.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `ArrowUp`/`ArrowDown`/`PageUp`/`PageDown` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `↑/↓` 정렬·사운드 순환, `PageUp/PageDown` 탭 순환 및 `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 188] 메인 키보드 `←/→` 오늘의 밑줄·테마 탐색 · `Home/End` 처음·끝 작품 즉시 열기
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "A~Z 26키가 완성된 김에, 서재 메인에서도 모달처럼 방향키 `←/→`로 오늘의 밑줄 배너를 넘기고(`Shift+←/→`로 속지 테마 변경), `Home/End` 키로 첫 작품·마지막 작품을 바로 펼쳐보고 싶어요!"
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_LEFT`/`KEY_RIGHT`(`_step_today_quote(±1)` / `Shift`: `_step_theme(±1)`)와 `KEY_HOME`/`KEY_END`(`_open_first_filtered_card()` / `_open_last_filtered_card()`, `Shift`: `_reset_all_filters()` 선행)를 추가하고 `KEY_H` 치트시트에 `[←/→] 문장·테마 · [Home/End] 처음·끝`을 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_LEFT`, `KEY_RIGHT`, `KEY_HOME`, `KEY_END` 분기 및 `_show_shortcut_cheatsheet()` 업데이트.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `ArrowLeft`/`ArrowRight`/`Home`/`End` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `←/→` 문장·테마 순환, `Home/End` 처음·끝 작품 모달 오픈 및 `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 187] 메인 키보드 `J` 마지막 작품 열기(Shift: 첫 작품) · `Y` 앰비언트 음소거 토글 — A~Z 26/26 완전 매핑
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "방금 추가한 최신 일기나 서재 맨 끝 작품을 바로 펼쳐보는 `J`(Jump to End) 키와, `M` 키로 배경음을 여러 번 넘기지 않고 원탭으로 음소거/재생을 전환하는 `Y` 키가 있으면 알파벳 A~Z 26키가 빈틈없이 완성될 것 같아요!"
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_J`(`_open_last_filtered_card()` / `Shift+J`: `_open_first_filtered_card()`)와 `KEY_Y`(`ambient_sound_index` 0↔1 음소거/재생 토글 / `Shift+Y`: 역순환)를 추가해 A~Z 26개 알파벳 단축키 100% 커버리지를 달성한다. `KEY_H` 치트시트에 `[J/Y] 끝열기·음소거`를 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `_open_last_filtered_card()` 헬퍼 및 `KEY_J`/`KEY_Y` 분기 추가, `_show_shortcut_cheatsheet()`에 `[J/Y] 끝열기·음소거` 반영.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `J`/`Y` 및 `Shift+J`/`Shift+Y` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_J`, `Shift+J`, `KEY_Y` 음소거 토글 및 `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 186] 메인 키보드 `K` 다독순 · `Z` 최신순 정렬 토글(Shift: 기본순 복귀) · 치트시트 Sync
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`V` 키로 가치순 정렬을 바로 전환하는 게 정말 편한데, 권수가 많은 `다독순`(`K`)과 최근에 기록한 `최신순`(`Z`)도 `S` 키로 여러 번 순환하지 않고 원키로 바로 토글되면 좋겠어요!"
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_K`(`sort_mode = 1` 다독순 토글)와 `KEY_Z`(`sort_mode = 2` 최신순 토글)를 추가하고, 재입력 또는 `Shift` 조합 시 `sort_mode = 0`(기본 등록순)으로 복귀하도록 설계한다. `KEY_H` 치트시트에 `[K/Z] 다독·최신순`을 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_K`, `KEY_Z` 정렬 토글 분기 추가 및 `_show_shortcut_cheatsheet()`에 `[K/Z] 다독·최신순` 반영.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `K`/`Z` 및 `Shift+K`/`Shift+Z` 정렬 피드백 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_K`, `KEY_Z`, `Shift+Z` 정렬 전환/복귀 및 `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 185 Milestone] 메인 키보드 `O` 즉시 열기(Shift: 랜덤 오픈) · `X` 초기화(Shift: 스튜디오 리셋)
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`Space` 외에도 알파벳 `O`(Open) 키로 필터링된 첫 작품을 바로 펼치고 `Shift+O`로 랜덤 추천 일기를 모달로 열어보고 싶어요. 또 검색/필터가 걸렸을 때 `X`로 한 번에 비우고 `Shift+X`로 정렬과 테마까지 기본 스튜디오 상태로 초기화하고 싶습니다."
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_O`(`_open_first_filtered_card()` / `Shift`: `pick_random_item(true)`) 및 `KEY_X`(`_reset_all_filters()` / `Shift`: `_set_sort_mode(0)` + `_reset_theme()`)를 추가하고, `KEY_H` 치트시트에 `[O/X] 열기·초기화`를 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_O`, `KEY_X` 분기 추가 및 `_show_shortcut_cheatsheet()`에 `[O/X] 열기·초기화` 반영.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `O`/`X` 및 `Shift+O`/`Shift+X` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_O`, `Shift+O`, `KEY_X`, `Shift+X`, `KEY_H` 치트시트 `[O/X] 열기·초기화` 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 184] 메인 키보드 `A` 전체일기 · `U` 초판특전 필터(Shift: 첫 작품 열기) · 치트시트 Sync
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "`E/G/D`·`F`로 분류를 보다가 다시 `전체일기`로 돌아오거나(`A`: All), `초판 스탬프 보유 작품`(`U`: Unique/초판특전)만 빠르게 필터링하고 `Shift` 조합으로 첫 작품 모달까지 한 번에 열고 싶어요."
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 `KEY_A`(`_on_tab_all_pressed()`)와 `KEY_U`(`_on_stat_firsts_clicked()`)를 추가하고 `Shift` 시 `_open_first_filtered_card()`를 연결한다. `KEY_H` 치트시트에도 `[A/U] 전체·초판` 안내를 동기화한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_A`, `KEY_U` 분기 및 `Shift+A`/`Shift+U` 즉시 모달 오픈 추가, `_show_shortcut_cheatsheet()`에 `[A/U] 전체·초판` 반영.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 `A`/`U` 및 `Shift+A`/`Shift+U` 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_A`, `KEY_U`, `Shift+A`, `Shift+U`, `KEY_H` 치트시트 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 183] 메인 키보드 `E/G/D` 분류 필터(Shift: 첫 작품 열기) · 치트시트 Sync
- **일시**: 2026-11-21
- **14인 가상 애자일 스쿼드 회의록**:
  - **다꾸러 VOC (지민·수빈·하연)**: "서재에서 `1~5` 숫자키 외에도 손이 자주 가는 왼손 알파벳 영역에서 이북/만화(`E`), 가챠(`G`), 완독(`D`) 탭을 바로 전환하고, `Shift`와 함께 누르면 해당 카테고리의 첫 번째 작품을 즉시 펼쳐보고 싶어요."
  - **PO & UX/UI**: `MainView` `_unhandled_input`에 직관적인 이니셜 니모닉 키(`E`: E-Book/만화, `G`: Gacha/굿즈, `D`: Done/완독)를 배치하고 `Shift+E/G/D` 시 `_open_first_filtered_card()`로 모달까지 한 번에 연결한다. `KEY_H` 단축키 치트시트(`_show_shortcut_cheatsheet`)에도 `[E/G/D] 분류`를 동기화하며 기존 `[우클릭] 역순환·백업` 안내를 복원한다.
- **구현 내역**:
  - [`main_view.gd`](godot_project/scripts/main_view.gd): `KEY_E`, `KEY_G`, `KEY_D` 분기 추가(`_on_tab_manga_pressed()`, `_on_tab_gacha_pressed()`, `_on_tab_complete_pressed()` 및 `Shift` 시 `_open_first_filtered_card()`), `_show_shortcut_cheatsheet()`에 `[E/G/D] 분류` 및 `[우클릭] 역순환·백업` 포함.
  - [`index.html`](index.html): 웹 인터랙티브 목업에 메인 화면 `E/G/D` 및 `Shift+E/G/D` 키보드 단축키 동기화.
  - [`test_main_integration.gd`](godot_project/tests/test_main_integration.gd): `KEY_E`, `KEY_G`, `KEY_D` 필터 전환, `Shift+E/G/D` 첫 작품 모달 오픈, `KEY_H` 치트시트 `[E/G/D] 분류` 검증 추가.
- **검증**: `test_archive.gd`, `test_persistence.gd`, `test_main_integration.gd` 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 갱신 완료.

---

## 📓 [Sprint 182] 메인 키보드 `B` 즉시 백업(Shift: 리포트 복사) · `F` 인생작 필터(Shift: 첫 작품 열기)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (안심 백업러):** "메인 서재에서 `B` 키만 누르면 바로 JSON 로컬 백업이 저장되고, `Shift+B`를 누르면 서재 요약 리포트가 클립보드에 복사되면 정말 안심될 것 같아요!"
- **가챠러 B (최애작 탐색러):** "검색 단축키는 `Ctrl/Cmd+F`니까, 단독 `F` 키를 누르면 `★ 인생작` 탭으로 바로 필터링되고 `Shift+F`를 누르면 첫 인생작 모달이 즉시 열리면 손이 편하겠어요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 전역 키보드 리스너에도 `B`/`Shift+B`와 `F`/`Shift+F`를 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `B` & `F` (`main_view.gd`)**:
     - `B`: `_trigger_instant_json_backup()` 실행(`Shift+B`: `copy_summary_to_clipboard()` 실행).
     - `F` (단독): `_on_tab_fav_pressed()` 실행(`Shift+F`: 필터링 후 `_open_first_filtered_card()` 실행).
     - `_show_shortcut_cheatsheet()` 안내에 `[F] 인생작 · [B] 백업` 추가.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 리스너에 `B`/`Shift+B`, `F`/`Shift+F`를 연결하고 `test_main_integration.gd`에 Sprint 182 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 181] 메인 키보드 `V` 가치순 정렬 토글(Shift: 기본순) · `L` 오늘의 밑줄 작품 열기(Shift: 작품 필터)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (자산 수집러):** "메인 서재에서 `V` 키 한 번만 누르면 `💎 가치순` 정렬로 바로 바뀌고, 다시 `V`나 `Shift+V`를 누르면 기본순으로 돌아오면 소장 가치 TOP 작품을 순식간에 확인할 수 있겠어요!"
- **가챠러 B (밑줄 탐색러):** "배너의 오늘의 밑줄을 보다가 `L` 키를 누르면 그 작품의 일기장이 바로 열리고, `Shift+L`을 누르면 그 작품명으로 서재가 필터링되면 정말 직관적일 것 같아요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 전역 키보드 리스너에도 `V`/`Shift+V`와 `L`/`Shift+L`을 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `V` & `L` (`main_view.gd`)**:
     - `V`: 가치순(`sort_mode = 3`) 토글(`Shift+V` 또는 이미 가치순일 때 기본순 `0` 복원).
     - `L`: `open_current_quote_item()` 실행(`Shift+L`: 현재 오늘의 밑줄 작품명으로 `search_input` 필터링).
     - `_show_shortcut_cheatsheet()` 안내에 `[V] 가치순 · [L] 오늘밑줄` 추가.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 리스너에 `V`/`Shift+V`, `L`/`Shift+L`을 연결하고 `test_main_integration.gd`에 Sprint 181 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 🏆 [Sprint 180 Milestone] 메인 키보드 `W` 웹표지 스크랩 · `P` 폴라로이드 촬영(Shift: 등록 후 즉시 열기)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "180회 마일스톤 스프린트! 하단 도크의 `웹표지 스크랩`(`WebBtn`)과 `폴라로이드 촬영`(`CamBtn`)도 키보드에서 `W`와 `P` 키 한 번으로 바로 등록할 수 있으면 마우스를 아래까지 내릴 필요가 없겠어요!"
- **가챠러 B (원키 등록+열기):** "`Shift+W`, `Shift+P`를 누르면 스크랩·촬영 등록과 동시에 방금 만든 일기장 모달을 곧바로 열어줘서 바로 다꾸를 시작할 수 있으면 완벽해요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 전역 키보드 리스너에도 `W`/`P`와 `Shift+W`/`Shift+P`를 동일하게 연결해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `W` & `P` (`main_view.gd`)**:
     - `W`: `_on_web_scrape_btn_pressed()` 실행(`Shift+W`: 등록 후 `items[0]` 모달 즉시 열기).
     - `P`: `_on_camera_snap_btn_pressed()` 실행(`Shift+P`: 등록 후 `items[0]` 모달 즉시 열기).
     - `_show_shortcut_cheatsheet()` 안내에 `[W/P] 스크랩·촬영` 추가.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 리스너에 `W`/`P` 및 `Shift+W`/`Shift+P`를 동기화하고 `test_main_integration.gd`에 Sprint 180 마일스톤 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 179] `AddModal` 키보드 `1~5` 표지 스와치(Shift: 즉시 등록) & `C` 분류 전환(Shift: 즉시 등록)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 다꾸러):** "새 일기 작성 모달(`AddModal`)에서 입력창 포커스를 푼 뒤 `1~5` 키로 표지 스와치 5종을 고르고, `Shift+1~5`를 누르면 그 색 표지로 샘플을 즉시 등록할 수 있으면 정말 편할 것 같아요!"
- **가챠러 B (빠른 분류 전환):** "`AddModal`에서도 `C` 키를 누르면 이북·단행본 ↔ 가챠·굿즈 분류가 전환되고, `Shift+C`를 누르면 분류 전환과 동시에 샘플을 즉시 등록해주면 마우스 없이도 모든 등록 흐름이 완결되겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 메인 서재에서도 `Shift+W`(웹 스크랩)와 `Shift+P`(폴라로이드 촬영) 단축키를 지원해 빠른 등록을 맞춰주세요."
- **PO & UX/UI 확정:**
  1. **`AddModal` `_unhandled_input` `1~5` & `C` (`add_modal.gd`)**:
     - 입력란 비포커스 시 `1~5`: `COVER_SWATCHES[0..4]` 표지색 선택(`Shift+1~5`: 선택 후 `_submit_with_sample_fallback()` 즉시 등록).
     - 입력란 비포커스 시 `C`: `cat_option` 이북 ↔ 가챠 전환(`Shift+C`: 전환 후 `_submit_with_sample_fallback()` 즉시 등록).
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 메인 서재 `Shift+W`/`Shift+P` 빠른 등록 단축키를 연결하고 `test_main_integration.gd`에 Sprint 179 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 178] `DetailModal` 키보드 `Shift+ESC` 카드 복사+닫기 · `Shift+H` 치트시트 복사 · `Shift+/`(`?`) 도움말

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "일기장 모달을 닫을 때 `Shift+ESC`를 누르면 `CloseBtn`/`Dimmer` `Shift+좌클릭`처럼 감상 카드를 클립보드에 복사하면서 바로 닫아주면 마우스 없이도 완벽할 거예요!"
- **가챠러 B (단축키 레퍼런스):** "일기장 모달 안에서도 메인 서재처럼 `?` (`Shift+/`) 키로 단축키 도움말을 띄우고, `Shift+H` 키를 누르면 모달 단축키 치트시트 문자열까지 클립보드에 복사되면 좋겠어요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#journal-modal` 열린 상태에서도 `Shift+ESC` 카드 복사+닫기와 `Shift+H` 치트시트 복사를 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `_unhandled_input` `Shift+ESC` · `Shift+H` · `Shift+/` (`detail_modal.gd`)**:
     - `Shift+ESC`: `copy_book_quote_card()` 실행 후 `close()` 즉시 호출.
     - `Shift+/` (`?`): `help_requested.emit()` 발행.
     - `Shift+H`: `help_requested.emit()` 발행과 함께 모달 단축키 치트시트 텍스트를 클립보드에 복사.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#journal-modal` `Shift+Escape` 및 `Shift+H`를 동기화하고 `test_main_integration.gd`에 Sprint 178 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 177] 메인 키보드 `Shift+/`(`?`) 단축키 치트시트 · `Shift+ESC` 필터 초기화 · `Space`/`Shift+Space` 서재·랜덤 열기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "메인 서재에서 `?` (`Shift+/`) 키를 눌렀을 때 검색창으로 포커스가 이동하는 대신 단축키 치트시트가 바로 뜨면 직관적일 것 같아요!"
- **가챠러 B (원키 서재 탐색):** "검색창에 포커스가 없을 때 `Space`를 누르면 첫 번째 서재 카드를, `Shift+Space`를 누르면 랜덤 일기장을 열어주고, `Shift+ESC`를 누르면 검색어·필터를 전체 초기화해주면 키보드 탐색이 완벽해질 거예요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 전역 키보드 리스너에도 `Space`/`Shift+Space`와 `Shift+ESC`를 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `Shift+/` · `Shift+ESC` · `Space`/`Shift+Space` (`main_view.gd`)**:
     - `Shift+/` (`?`): `_show_shortcut_cheatsheet()` 표시.
     - `Shift+ESC` (또는 검색어 존재 시 `ESC`): `_reset_all_filters()` 실행.
     - `Space` / `Shift+Space`: `_open_first_filtered_card()` / `pick_random_item(true)` 실행.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 핸들러에 `Space`/`Shift+Space`와 `Shift+Escape`를 추가하고 `test_main_integration.gd`에 Sprint 177 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 176] `AddModal` 키보드 `Shift+ESC` 입력 전체 비우기 & `Shift+Enter` 샘플 자동 채움 등록

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 다꾸러):** "새 일기 작성 모달(`AddModal`)에서 `ESC`를 누르면 창이 닫히거나 포커스된 칸 하나만 지워지는데, `Shift+ESC`를 누르면 창을 닫지 않고 제목·작가·밑줄 3칸을 모두 한꺼번에 비워주면 좋겠어요."
- **가챠러 B (원키 등록러):** "`Ctrl/Cmd+Enter`는 제목이 비어있으면 경고가 뜨는데, `Shift+Enter`를 누르면 `SubmitBtn` `Shift+좌클릭`처럼 빈 제목일 때도 샘플을 자동 채워서 즉시 등록까지 완료되면 정말 빠를 거예요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#diary-quote-input`에서도 `Shift+Enter` 시 저장+복사, `Shift+ESC` 시 입력란 초기화를 동기화해주세요."
- **PO & UX/UI 확정:**
  1. **`AddModal` `_unhandled_input` `Shift+ESC` & `Shift+Enter` (`add_modal.gd`)**:
     - `Shift+ESC`: `clear_inputs()` 호출로 모달을 닫지 않고 입력란 3종을 일괄 비웁니다.
     - `Shift+Enter`: `_submit_with_sample_fallback()` 호출로 빈 제목 시 샘플 자동 채움 후 즉시 서재에 등록합니다.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#diary-quote-input`에 `Shift+Enter` 저장+복사 및 `Shift+Escape` 초기화를 연결하고 `test_main_integration.gd`에 Sprint 176 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 🏆 [Sprint 175 Milestone] `DetailModal` 키보드 `Shift+L` 속지 순환 · `Shift+Delete` 삭제 해제 · `Shift+PgUp/PgDn` 처음·끝 점프

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 다꾸러):** "175회 마일스톤 스프린트! `L` 키로 형광펜을 토글할 때 `Shift+L`을 누르면 `HighlightBtn` `Shift+좌클릭`처럼 일기장 속지 패턴을 순환해주면 손이 정말 편할 것 같아요!"
- **가챠러 B (안전 UX 유저):** "실수로 `Delete`나 `Backspace`를 눌러 삭제 확인 상태(`delete_armed`)가 되었을 때 `Shift+Delete`/`Shift+Backspace`로 즉시 삭제 확인을 해제할 수 있고, `Shift+PageUp`/`PageDown`으로도 첫 작품·마지막 작품에 점프할 수 있으면 완벽해요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 모달 키보드 리스너에도 `Shift+L`, `Shift+Delete`/`Backspace`, `Shift+PageUp`/`PageDown`을 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `_unhandled_input` `Shift+L` / `Shift+Delete` / `Shift+PgUp/PgDn` (`detail_modal.gd`)**:
     - `Shift+L`: `cycle_paper_pattern(1)` 실행.
     - `Shift+Delete` / `Shift+Backspace`: `delete_armed = false` 및 `_apply_delete_btn_style(false)`로 안전 해제.
     - `Shift+PageUp` / `Shift+PageDown`: `navigate_requested.emit(-9999)` / `navigate_requested.emit(9999)` 발행.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 동일한 키보드 단축키를 `index.html`에 연결하고 `test_main_integration.gd`에 Sprint 175 마일스톤 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 174] `DetailModal` 키보드 `Shift+E` 샘플 밑줄 채움 & `Shift+1~4` 인장 찍고 닫기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 다꾸러):** "일기장 모달에서 `E` 키를 누르면 밑줄 입력창으로 포커스가 가는데, `Shift+E`를 누르면 샘플 밑줄 문장을 자동으로 채운 뒤 포커스를 맞춰주면 빠르게 기록을 남길 때 좋겠어요!"
- **가챠러 B (스탬프 퀵액션):** "`1~4` 키로 4종 인장을 찍을 때 `Shift+1~4`를 누르면 인장 버튼 `Shift+좌클릭`처럼 인장을 찍으면서 동시에 일기장 모달을 닫아주면 마우스 없이도 완결되겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 모달 열린 상태 키보드 리스너에도 `Shift+E`와 `Shift+1~4`를 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `_unhandled_input` `Shift+E` & `Shift+1~4` (`detail_modal.gd`)**:
     - `Shift+E`: `quote_input.text`에 샘플 밑줄 `"오늘도 한 페이지의 여운을 남겼다."`를 채운 뒤 포커스 이동.
     - `Shift+1~4`: 해당 인장 프리셋(`전권완결`/`초판특전`/`인생최애`/`위시리스트`) 적용 후 `close()` 즉시 실행.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#journal-modal` 열린 상태 키보드 리스너에 `Shift+E` 및 `Shift+1~4`를 연결하고 `test_main_integration.gd`에 Sprint 174 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 173] `DetailModal` 키보드 `Shift+←/→` 처음·끝 점프 & `Shift++/-` 초판북마크 추가·전권 북마크 토글

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "일기장 모달에서 `←`/`→` 키로 페이지를 넘길 때 `Shift+←`/`Shift+→`를 누르면 `Home`/`End` 키까지 손가락을 뻗지 않아도 첫 작품·마지막 작품으로 즉시 점프하면 좋겠어요!"
- **가챠러 B (권별 빠른 기록러):** "모달에서 `+` 키로 새 권을 추가할 때 `Shift++`를 누르면 `초판특전+북마크 ON` 상태로 바로 추가되고, `Shift+-`를 누르면 마지막 권을 지우는 대신 전권 북마크를 일괄 토글해주면 키보드만으로 모든 권별 작업이 가능하겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `ArrowLeft`/`ArrowRight` 키 리스너에도 `Shift+←/→` 처음·끝 작품 점프를 동일하게 반영해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `_unhandled_input` `Shift+←/→` & `Shift++/-` (`detail_modal.gd`)**:
     - `Shift+←` / `Shift+→`: `navigate_requested.emit(-9999)` / `navigate_requested.emit(9999)` 발행.
     - `Shift++` (`KEY_EQUAL`/`KEY_PLUS`/`KEY_KP_ADD`): 새 권 추가 후 즉시 `status = "first"`, `bookmarked = true` 적용.
     - `Shift+-` (`KEY_MINUS`/`KEY_KP_SUBTRACT`): 전권 북마크 일괄 온·오프 토글.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `ArrowLeft`/`ArrowRight` 키 핸들러에 `e.shiftKey` 처음·끝 작품 점프를 연결하고 `test_main_integration.gd`에 Sprint 173 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 172] 메인 키보드 `Shift+0` 스튜디오 완전 초기화 · `Shift+C` 오늘의 밑줄 복사 · `Shift+H` 단축키 치트시트 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "`0` 키를 누르면 검색·필터가 초기화되는데, `Shift+0`을 누르면 정렬 기준과 속지 테마까지 한꺼번에 기본값으로 되돌리는 완전 초기화가 되면 좋겠어요!"
- **가챠러 B (밑줄 공유러):** "메인 서재에서 `C` 키는 전체 서재 요약을 복사하는데, `Shift+C`를 누르면 배너에 떠 있는 오늘의 밑줄 문장만 깔끔하게 복사할 수 있으면 편리할 것 같아요."
- **미니멀러 C (단축키 레퍼런스):** "`H` 키로 단축키 치트시트를 띄울 때 `Shift+H`를 누르면 치트시트 텍스트까지 클립보드에 함께 복사해주고 웹 목업(`index.html`)에도 동일하게 동기화해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `Shift+0` / `Shift+C` / `Shift+H` (`main_view.gd`)**:
     - `Shift+0`: `_reset_all_filters()` + `_set_sort_mode(0)` + `_reset_theme()` 실행.
     - `Shift+C`: `today_quote_label.text`를 클립보드에 복사하고 토스트 안내 표시.
     - `Shift+H`: `_show_shortcut_cheatsheet()` 실행 후 `status_toast.text`를 클립보드에 복사.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 리스너에 `Shift+0`, `Shift+C`, `Shift+H`를 추가하고 `test_main_integration.gd`에 Sprint 172 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 171] 메인 키보드 `Shift+1~5` 탭 필터 후 즉시 열기 · `Shift+N` 샘플 모달 · `Shift+I` 즉시 백업

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (키보드 파워 유저):** "메인 서재에서 `1~5` 키로 탭을 바꿀 수 있는데, 탭 버튼의 `Shift+좌클릭`처럼 키보드에서도 `Shift+1~5`를 누르면 탭 전환과 동시에 랜덤·첫 번째 작품 일기장이 바로 열리면 좋겠어요!"
- **가챠러 B (빠른 입력 유저):** "`N` 키로 새 일기 창을 열 때 `Shift+N`을 누르면 샘플 제목·작가·문장이 미리 채워진 상태로 열리고, `Shift+I`를 누르면 인포그래픽 대신 즉시 JSON 백업이 실행되면 키보드만으로도 모든 파워 액션을 쓸 수 있겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 전역 키보드 리스너에도 `Shift+1~5`, `Shift+N`, `Shift+I` 단축키를 동일하게 추가해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `_unhandled_input` `Shift+1~5` / `Shift+N` / `Shift+I` (`main_view.gd`)**:
     - `Shift+1`: 전체 탭 복원 후 `pick_random_item(true)` 즉시 열기.
     - `Shift+2~5`: 해당 카테고리/필터 전환 후 `_open_first_filtered_card()` 실행.
     - `Shift+N`: `AddModal` 열기 + 샘플 텍스트 3종 자동 채움.
     - `Shift+I`: `_trigger_instant_json_backup()` 즉시 백업 실행.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 전역 `keydown` 핸들러에 동일한 `Shift+1~5`, `Shift+N`, `Shift+I`를 연결하고 `test_main_integration.gd`에 Sprint 171 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 🏆 [Sprint 170 Milestone] `TitleLabel` `Shift+좌클릭` 감상 카드 전체 복사 & `StampLbl`/`InkLbl` `Shift+좌클릭` 역순환 완결

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "170회 마일스톤 스프린트! 일기장 모달의 작품 제목(`TitleLabel`)을 우클릭하면 감상 카드 전체가 복사되는데, 트랙패드에서 `Shift+좌클릭`으로도 똑같이 감상 카드를 복사할 수 있으면 좋겠어요."
- **가챠러 B (잉크·인장 다꾸):** "`StampRow`의 `💮 인장:` 라벨(`StampLbl`)과 `InkRow`의 `🖋️ 잉크:` 라벨(`InkLbl`)도 우클릭 역순환뿐 아니라 `Shift+좌클릭`으로 이전 인장·이전 잉크색으로 돌아가면 모달 내 모든 라벨·버튼이 100% 통일되겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#diary-title` 제목 클릭에도 `Shift+좌클릭` 시 감상 카드 전체 복사를 연결해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `TitleLabel` `Shift+좌클릭` 감상 카드 전체 복사 (`detail_modal.gd`)**: `TitleLabel` `gui_input`과 `open()` 툴팁에 `Shift+좌클릭` 시 `accept_event()` 및 `card_copied.emit(current_item)`을 연결했습니다.
  2. **`DetailModal` `StampLbl`/`InkLbl` `Shift+좌클릭` 역순환 (`detail_modal.gd`)**: `StampLbl`과 `InkLbl` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 각각 이전 인장 프리셋(`-1`)과 이전 만년필 잉크(`cycle_fountain_pen_ink(-1)`)로 역순환합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#diary-title`에 `Shift+좌클릭` 감상 카드 복사를 동기화하고 `test_main_integration.gd`에 Sprint 170 마일스톤 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 169] `AddModal` 입력 3종 `Shift+좌클릭` 개별 샘플 채움 & `DetailModal` `CatBadge` `Shift+좌클릭` 전체 서재 복원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "`AddModal`의 제목·작가·첫 밑줄 입력란 3곳에서 우클릭하면 비우기/샘플 전환이 되는데, `Shift+좌클릭`하면 언제든 해당 입력란에 기본 샘플 문장을 깔끔하게 채워주면 좋겠어요."
- **가챠러 B (필터 복원러):** "`DetailModal` 왼쪽 표지 위 카테고리 배지(`CatBadge`)를 우클릭하면 전체 서재로 돌아가는데, 트랙패드에서 `Shift+좌클릭`으로도 모달을 닫으며 전체 서재를 복원할 수 있으면 편리하겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#diary-cover-cat` 배지에도 `Shift+좌클릭` 시 전체 서재 복원 후 모달 닫기를 동기화해주세요."
- **PO & UX/UI 확정:**
  1. **`AddModal` 입력란 3종 `Shift+좌클릭` 샘플 채움 (`add_modal.gd`)**: `TitleInput`, `AuthorInput`, `QuoteInput`의 `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 해당 필드의 샘플 텍스트를 즉시 채웁니다.
  2. **`DetailModal` `CatBadge` `Shift+좌클릭` 전체 서재 복원 (`detail_modal.gd`)**: `CatBadge` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `close()` 및 `filter_category_requested.emit(-1)`을 발행해 전체 서재로 복원합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#diary-cover-cat`에 `Shift+좌클릭` 전체 서재 복원을 동기화하고 `test_main_integration.gd`에 Sprint 169 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 168] `SearchInput` `Shift+좌클릭` 첫 결과 열기 & `QuoteInput` `Shift+좌클릭` 밑줄 저장+복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "통합 검색창(`SearchInput`)에 검색어를 입력한 뒤 마우스로 `Shift+좌클릭`만 해도 엔터 키처럼 첫 번째 필터링된 작품 일기장이 바로 열리면 한 손 마우스 조작이 훨씬 편할 것 같아요."
- **가챠러 B (대사 입력러):** "`DetailModal` 밑줄 입력창(`QuoteInput`)에 감상평을 적은 뒤, 저장 버튼까지 마우스를 옮기지 않고 입력창 자체에서 `Shift+좌클릭`만 해도 저장과 동시에 클립보드 복사가 완료되면 좋겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#search-box`와 `#diary-quote-input`에도 동일한 `Shift+좌클릭` 동작을 연결해주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `SearchInput` `Shift+좌클릭` 첫 결과 열기 (`main_view.gd`)**: `SearchInput` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `_open_first_filtered_card()`를 호출해 첫 번째 필터링 카드를 즉시 엽니다.
  2. **`DetailModal` `QuoteInput` `Shift+좌클릭` 저장+복사 (`detail_modal.gd`)**: `QuoteInput` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `_on_save_quote_btn_pressed()`로 저장하고 입력 텍스트를 클립보드에 복사합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#search-box`와 `#diary-quote-input`에 `Shift+좌클릭` 핸들러를 추가하고 `test_main_integration.gd`에 Sprint 168 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 167] `AddModal` `Dimmer` `Shift+좌클릭` 입력 비우기 & `TitleLabel` `Shift+좌클릭` 샘플 즉시 등록

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "새 일기 작성 모달(`AddModal`)에서 어두운 배경(`Dimmer`)을 우클릭하면 창을 닫지 않고 입력 내용만 비우는데, 트랙패드에서 `Shift+좌클릭`으로도 똑같이 입력 내용만 깔끔히 비울 수 있으면 좋겠어요."
- **가챠러 B (원클릭 등록):** "`AddModal` 상단 제목(`TitleLabel`)을 좌클릭하면 샘플 일기를 채워주는데, `Shift+좌클릭`하면 샘플을 채우면서 동시에 바로 서재에 등록까지 끝낼 수 있으면 테스트나 빠른 스크랩 시 최고일 거예요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 모달 노트 헤더(`🖋️ 나만의 독서 노트 & 권별 밑줄`)에서도 `Shift+좌클릭` 시 샘플 밑줄을 채우면서 바로 저장되도록 맞춰주세요."
- **PO & UX/UI 확정:**
  1. **`AddModal` `Dimmer` `Shift+좌클릭` 입력 내용만 비우기 (`add_modal.gd`)**: `Dimmer` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `clear_inputs()`를 호출해 모달을 닫지 않고 입력란을 초기화합니다.
  2. **`AddModal` `TitleLabel` `Shift+좌클릭` 샘플 즉시 등록 (`add_modal.gd`)**: 상단 제목 라벨 `Shift+좌클릭` 시 `accept_event()` 처리 후 `_submit_with_sample_fallback()`를 실행해 샘플 일기를 즉시 서재에 등록합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 모달 노트 헤더에 `Shift+좌클릭` 샘플 밑줄 채움+저장을 연결하고 `test_main_integration.gd`에 Sprint 167 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 166] `EmptyStateResetBtn` `Shift+좌클릭` 복원 후 랜덤 일기장 열기 & `DetailModal` `Dimmer` `Shift+좌클릭` 카드 복사+닫기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "검색 결과가 없을 때 나오는 `🔄 전체 서재 보기`(`EmptyStateResetBtn`) 버튼에서 우클릭하면 복원 후 미리보기 토스트가 뜨는데, `Shift+좌클릭`으로 누르면 전체 서재를 복원하면서 곧바로 랜덤 일기장 모달을 열어주면 좋겠어요!"
- **가챠러 B (모달 퀵액션):** "`DetailModal` 바깥 어두운 배경(`Dimmer`)을 `Shift+좌클릭`했을 때도 `CloseBtn`처럼 감상 카드를 클립보드에 복사하면서 일기장을 닫아주면 마우스를 모달 밖으로 빼는 손맛이 딱 맞을 거예요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 빈 상태 복원 버튼과 `#journal-modal` 배경 클릭 핸들러에도 동일한 `Shift+좌클릭` 동작을 넣어주세요."
- **PO & UX/UI 확정:**
  1. **`MainView` `EmptyStateResetBtn` `Shift+좌클릭` 복원 후 랜덤 열기 (`main_view.gd`)**: `Shift+좌클릭` 시 `accept_event()` 처리 후 `_reset_all_filters()`와 `pick_random_item(true)`를 연속 호출해 전체 서재 복원과 동시에 랜덤 일기장 모달을 엽니다.
  2. **`DetailModal` `Dimmer` `Shift+좌클릭` 카드 복사+닫기 (`detail_modal.gd`)**: `Dimmer` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()`, `copy_book_quote_card()`, `close()`를 순차 실행합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 빈 상태 복원 버튼과 `#journal-modal` 배경 클릭에 `Shift+좌클릭` 랜덤 열기·카드 복사+닫기를 동기화했습니다. `test_main_integration.gd`에 Sprint 166 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 🏆 [Sprint 165 Milestone] `AddModal` 스와치 5종·`CatOption`·`CloseBtn`·`SubmitBtn` `Shift+좌클릭` 파워 액션 완결

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "165회 마일스톤 스프린트! `AddModal`의 표지 컬러 스와치 5종을 우클릭하면 그 색으로 즉시 샘플 등록이 되는데, 트랙패드에서 `Shift+좌클릭`으로도 똑같이 그 색 표지로 즉시 등록할 수 있으면 좋겠어요."
- **가챠러 B (빠른 등록러):** "`AddModal`의 작품 분류(`CatOption`) 이북↔가챠 전환, `CloseBtn` 입력란 비우기, `SubmitBtn` 빈 제목 시 샘플 자동 채움 등록도 `Shift+좌클릭`을 모두 지원하면 `DetailModal`과 `AddModal` 전체가 완벽한 트랙패드 친화 UX로 통일되겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`) 상단 `+ 새 일기 쓰기` 버튼에서도 `Shift+좌클릭` 시 프롬프트 없이 샘플 일기가 즉시 등록되도록 맞춰주세요."
- **PO & UX/UI 확정:**
  1. **`AddModal` 표지 스와치 5종 `Shift+좌클릭` 즉시 등록 (`add_modal.gd`)**: `_build_color_swatches` 내 각 스와치 버튼 `gui_input`에서 `Shift+좌클릭` 시 `accept_event()`, `select_color(hex_val)`, `_submit_with_sample_fallback()`를 실행합니다.
  2. **`AddModal` `CatOption`/`CloseBtn`/`SubmitBtn` `Shift+좌클릭` (`add_modal.gd`)**: `CatOption` `Shift+좌클릭`으로 이북↔가챠 즉시 전환, `CloseBtn` `Shift+좌클릭`으로 입력란 비우기(`clear_inputs()`), `SubmitBtn` `Shift+좌클릭`으로 샘플 자동 채움 등록(`_submit_with_sample_fallback()`)을 연결하고 툴팁에 안내를 병기했습니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `openNewDiaryModal(instantSample)`을 확장해 `+ 새 일기 쓰기` 버튼 `Shift+좌클릭` 시 샘플 즉시 등록을 지원하고, `test_main_integration.gd`에 Sprint 165 마일스톤 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 164] `StampRow`·`InkRow` 17종 데코레이터 순환 버튼 `Shift+좌클릭` 역순환 일괄 지원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "`StampRow`와 `InkRow`에 있는 띠지·테이프·스티커·레어도·속지·보관위치·입수경로·기분·소장상태·펜촉·서명·태그·최애캐릭터·컨디션·마감·날씨·장소 등 17종 순환 버튼이 우클릭 역순환은 되는데, 트랙패드에서 `Shift+좌클릭`으로도 똑같이 이전 프리셋으로 돌아가면 좋겠어요!"
- **가챠러 B (원버튼 유저):** "이제 모달 내 수치 버튼과 네비게이션이 전부 `Shift+좌클릭`을 지원하는데, 17종 데코레이터 버튼만 `Shift+좌클릭` 시 앞으로 넘어가서 일관성이 완성되면 좋겠어요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`) 상단 데코레이터 버튼(`#tape-cycle-btn`, `#deco-sticker-btn`, `#rarity-cycle-btn`, `#source-cycle-btn`, `#mood-cycle-btn`)도 `Shift+좌클릭`으로 역순환되도록 맞춰주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `deco_rclick_map` 17종 데코레이터 `Shift+좌클릭` 역순환 (`detail_modal.gd`)**: `DateStampBtn`을 제외한 17종 순환 버튼(`ObiCycleBtn`~`SpotBtn`)의 `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리와 함께 `-1` 역순환 콜백을 실행하고, 기존 `"우클릭: 이전"` 툴팁 문자열을 유지한 채 `"· Shift+좌클릭: 이전"`을 병기했습니다.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** 웹 목업 데코레이터 5종 버튼에 `event && event.shiftKey ? -1 : 1` 역순환을 연결하고 `test_main_integration.gd`에 Sprint 164 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 163] `RereadBtn`/`DuplicateBtn`/`ValueBtn` `Shift+좌클릭` -1·-5,000원 역감소 지원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "일기장 모달의 `🔁 1회독`(`RereadBtn`) 버튼에서 우클릭이나 `Shift+Y`로 회독을 -1 줄일 수 있는데, 트랙패드에서 `Shift+좌클릭`으로도 바로 -1 줄일 수 있으면 훨씬 손에 익을 것 같아요."
- **가챠러 B (중복·자산 관리):** "`👯 ×1`(`DuplicateBtn`) 복수 소장 수량과 `💎 +5천원`(`ValueBtn`) 추정 소장 가치 버튼도 `Shift+좌클릭` 시 각각 -1, -5,000원 감소가 동작하면 수치 조정 3종 세트가 완벽하게 통일되겠어요!"
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 `#reread-cycle-btn` 버튼에도 `Shift+좌클릭` 시 `-1회독`이 동작하도록 동기화해주세요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `RereadBtn`/`DuplicateBtn`/`ValueBtn` `Shift+좌클릭` 역감소 (`detail_modal.gd`)**: 세 버튼의 `gui_input`에서 `Shift+좌클릭` 감지 시 `accept_event()` 처리 후 각각 `decrement_reread_count()`, `decrement_duplicate_count()`, `reduce_estimated_value()`를 호출하고 툴팁에 `· Shift+좌클릭: -1` / `· Shift+좌클릭: -5,000원` 안내를 추가했습니다.
  2. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `#reread-cycle-btn`에 `Shift+좌클릭` 시 `decrementRereadCount()`를 연결하고 `test_main_integration.gd`에 Sprint 163 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 162] `DateStampBtn` `Shift+좌클릭` 구매일+전권 오늘 날짜 동기화 & `DeleteBtn` `Shift+좌클릭` 삭제 확인 해제

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "새 작품을 사서 한꺼번에 읽은 날에는 `InkRow`의 `📅 기념일`(`DateStampBtn`)과 각 권의 날짜 스탬프를 모두 오늘 날짜로 맞추고 싶어요. `DateStampBtn`을 `Shift+좌클릭`하면 구매일과 전권 날짜가 한 번에 오늘로 동기화되면 정말 편리하겠어요!"
- **가챠러 B (안전 UX 유저):** "실수로 `일기 삭제`(`DeleteBtn`)를 한 번 눌러서 빨간 확인 대기 상태가 되었을 때, 우클릭뿐 아니라 트랙패드에서 `Shift+좌클릭`으로도 안전하게 삭제 확인 상태를 해제할 수 있으면 좋겠어요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 기록 시작일(`#diary-purchase-date`)과 `이 일기 삭제` 버튼에도 동일한 `Shift+좌클릭` 동작을 넣어주면 좋겠어요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `DateStampBtn` `Shift+좌클릭` 구매일+전권 날짜 동기화 (`detail_modal.gd`)**: `DateStampBtn` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `stamp_purchase_date()`와 `stamp_all_volumes_date()`를 함께 호출해 구매·기념일 및 모든 권의 읽은 날을 오늘 날짜로 동기화합니다.
  2. **`DetailModal` `DeleteBtn` `Shift+좌클릭` 삭제 확인 해제 (`detail_modal.gd`)**: `DeleteBtn` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `delete_armed = false` 및 `_apply_delete_btn_style(false)`를 적용합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `index.html`에 `#diary-purchase-date` 인터랙션 및 `#delete-diary-btn` `Shift+좌클릭` 삭제 확인 해제를 동기화했습니다. `test_main_integration.gd`에 Sprint 162 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 161] 권별 `vol_lbl` `Shift+좌클릭` 초판+북마크+★5 풀스탬프 & `quote_lbl` `Shift+좌클릭` 밑줄 복사+북마크

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "권별 리스트의 `1권`·`2권` 라벨(`vol_lbl`)을 `Shift+좌클릭`했을 때 해당 권을 단번에 `초판특전 + 북마크 ON + ★5` 최애권 풀스탬프로 지정할 수 있으면 정주행 마무리가 훨씬 상쾌할 것 같아요!"
- **가챠러 B (대사 수집러):** "권별 밑줄 문장 라벨(`quote_lbl`)도 우클릭은 단순 복사지만, `Shift+좌클릭`하면 대사를 클립보드에 복사하면서 동시에 해당 권 북마크까지 자동으로 켜지면 좋겠어요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`)의 권 번호 스팬과 대사 스팬에도 동일한 `Shift+좌클릭` 콤보를 넣어주면 Godot 앱과 100% 일치하겠어요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` 권별 `vol_lbl` `Shift+좌클릭` 초판+북마크+★5 (`detail_modal.gd`)**: `vol_lbl.gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 해당 권의 `status = "first"`, `bookmarked = true`, `rating = 5`를 일괄 적용하고 `_render_volumes()`, `_refresh_vol_header()`, `_refresh_author_label()`, `diary_updated` 시그널을 발행합니다.
  2. **`DetailModal` 권별 `quote_lbl` `Shift+좌클릭` 복사+북마크 (`detail_modal.gd`)**: `quote_lbl.gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 `"제목 N권: \"밑줄\""`을 클립보드에 복사하고 `bookmarked = true`를 함께 설정합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `renderDiaryVolumes` 내 권 번호 및 대사 스팬에 동일한 `Shift+좌클릭` 동작 및 툴팁을 동기화했습니다. `test_main_integration.gd`에 Sprint 161 통합 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 🏆 [Sprint 160 Milestone] `RemoveVolBtn` `Shift+좌클릭` 전권 북마크 일괄 토글 & `ShareCardBtn` `Shift+좌클릭` 전체 서재 리포트 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "160회 마일스톤 스프린트! 일기장 상단 `- 권 삭제`(`RemoveVolBtn`) 우클릭으로 마지막 권 북마크를 토글할 수 있는데, `Shift+좌클릭`으로는 전권 북마크를 한 번에 켜거나 끌 수 있으면 `AddVolBtn`과 짝이 딱 맞을 것 같아요."
- **가챠러 B (리포트 공유):** "감상 카드 `💌 공유`(`ShareCardBtn`) 버튼도 우클릭 외에 `Shift+좌클릭`만으로 전체 서재 리포트를 클립보드에 바로 복사할 수 있으면 트랙패드에서도 훨씬 편할 거예요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`) 권별 헤더 옆에도 `- 권 삭제` 버튼이 함께 배치되어 동일한 `Shift+좌클릭` 전권 북마크 토글·우클릭 마지막 권 토글을 지원하면 좋겠어요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` `RemoveVolBtn` `Shift+좌클릭` 전권 북마크 일괄 토글 (`detail_modal.gd`)**: `RemoveVolBtn` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()` 처리 후 미북마크 권이 있으면 전권 `bookmarked = true`, 모두 북마크되어 있으면 전권 `bookmarked = false`로 일괄 토글하고 `_render_volumes()`, `_refresh_vol_header()`, `diary_updated` 시그널을 발행합니다.
  2. **`DetailModal` `ShareCardBtn` `Shift+좌클릭` 전체 서재 리포트 복사 (`detail_modal.gd`)**: `ShareCardBtn` `gui_input`에서 `Shift+좌클릭` 시 `accept_event()`와 함께 `summary_copy_requested.emit()`를 실행하고, 툴팁에 `"· Shift+좌클릭: 전체 서재 리포트 복사"`를 추가했습니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `index.html`의 공유 버튼 `Shift+좌클릭` 전체 서재 리포트 복사 및 `- 권 삭제` 버튼(좌클릭: 마지막 권 삭제, 우클릭: 마지막 권 북마크 토글, `Shift+좌클릭`: 전권 북마크 일괄 토글)을 동기화했습니다. `test_main_integration.gd`에 Sprint 160 마일스톤 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 159] 권별 `date_btn` `Shift+좌클릭` 전권 오늘 날짜 일괄 스탬프 & `PrevItemBtn`/`NextItemBtn` `Shift+좌클릭` 처음·끝 작품 점프

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A (다꾸러):** "시리즈 전권을 하루에 몰아 읽었을 때 권별 `📅` 날짜 스탬프를 매 권마다 눌러 갱신하는 게 번거로워요. `Shift+좌클릭` 한 번으로 전권 날짜를 오늘 날짜로 맞춰줄 수 있으면 좋겠어요."
- **가챠러 B (모달 네비게이션):** "일기장 모달 상단 `◀`/`▶` 버튼에서 우클릭으로 처음·끝 작품으로 이동할 수 있는데, 트랙패드나 원버튼 환경에서도 `Shift+좌클릭`으로 똑같이 첫 작품·마지막 작품으로 점프할 수 있으면 직관적일 것 같아요."
- **미니멀러 C (웹 동기화):** "웹 목업(`index.html`) 권별 리스트에도 날짜 스탬프 버튼이 함께 표시되어 `Shift+좌클릭` 일괄 날짜 스탬프가 동작하면 Godot 앱과 동일한 손맛이 날 거예요."
- **PO & UX/UI 확정:**
  1. **`DetailModal` 권별 `date_btn` `Shift+좌클릭` 전권 오늘 날짜 일괄 스탬프 (`detail_modal.gd`)**: `stamp_all_volumes_date()` 헬퍼를 추가해 `current_item.volumes` 전권 `date`를 오늘 날짜(`YYYY.MM.DD`)로 일괄 갱신하고 `_render_volumes()` 및 `diary_updated` 시그널을 발행합니다. `date_btn.gui_input`에서 `Shift+좌클릭` 시 `accept_event()`와 함께 호출합니다.
  2. **`DetailModal` `PrevItemBtn`/`NextItemBtn` `Shift+좌클릭` 처음·끝 점프 (`detail_modal.gd` · `main_view.gd`)**: `PrevItemBtn`/`NextItemBtn` `gui_input`에서 `Shift+좌클릭` 시 각각 `navigate_requested.emit(-9999)` / `navigate_requested.emit(9999)`를 발행(`accept_event()` 포함)하고, `main_view.gd` 동적 툴팁에 기존 `"우클릭: 처음/끝"`과 함께 `"· Shift+좌클릭: 처음/끝"`을 병기합니다.
  3. **웹 목업(`index.html`) 동기화 & TDD/QA 검증:** `renderDiaryVolumes`에 권별 `📅` 날짜 스탬프 버튼(클릭: 오늘 날짜, 우클릭: 대사 복사, `Shift+좌클릭`: 전권 오늘 날짜 일괄 스탬프)을 추가하고 `#prev-page-btn`/`#next-page-btn`에 `Shift+좌클릭` 처음·끝 점프를 동기화했습니다. `test_main_integration.gd`에 Sprint 159 통합 검증을 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷을 갱신했습니다.

---

## 📓 [Sprint 158] `DiyBtn` `Shift+좌클릭` 샘플 채움 모달 열기 & 권별 `StatusBtn` `Shift+좌클릭` 전권 초판·소장 일괄 전환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "하단 `새 일기 쓰기`(`DiyBtn`) 버튼도 상단 `AddBtn`처럼 `Shift+좌클릭`했을 때 샘플 제목·작가·문장이 미리 채워진 상태로 열리면 어느 곳에서든 똑같이 빠르게 쓸 수 있을 것 같아요!"
- **가챠러 B**: "권별 리스트의 `🔖초판특전` / `✓소장완료` 버튼(`StatusBtn`)을 `Shift+좌클릭`하면 해당 작품의 모든 권을 한 번에 초판특전 또는 소장완료로 일괄 전환할 수 있으면 전권 초판 세트 정리가 정말 빠르겠어요."
- **기획자 (PO)**: "`main_view.gd` `DiyBtn` `Shift+좌클릭` 샘플 채움 모달 열기와 `detail_modal.gd` 권별 `StatusBtn` `Shift+좌클릭` 전권 일괄 전환을 구현하고 `index.html` 권별 상태 버튼과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `NavRow` `DiyBtn` `Shift+좌클릭` 시 `add_modal.open()` 후 샘플 제목·작가·문장을 미리 채워 열어주도록 연결하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - 권별 `status_btn` `Shift+좌클릭` 시 전권 `volumes`의 `status`를 `"first"` 또는 `"owned"`로 일괄 전환하고 UI·헤더·시그널을 동기화했습니다.
- `game02/index.html`:
  - `renderDiaryVolumes()` 내 상태 버튼 `onclick`에 `event.shiftKey` 시 전권 상태 일괄 전환 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `DiyBtn` `Shift+좌클릭` 샘플 모달 열기와 권별 `StatusBtn` `Shift+좌클릭` 전권 일괄 전환을 검증하는 Sprint 158 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 157] `WebBtn`/`CamBtn` `Shift+좌클릭` 스크랩·촬영 후 즉시 열기 & 권별 `BmBtn` `Shift+좌클릭` 초판+북마크

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "하단 `웹표지 스크랩`(`WebBtn`)이나 `폴라로이드 촬영`(`CamBtn`)을 `Shift+좌클릭`하면 새 작품을 추가함과 동시에 그 일기장 모달이 바로 펼쳐져 곧바로 감상평을 적을 수 있으면 좋겠어요!"
- **가챠러 B**: "권별 리스트의 북마크 아이콘(`🏷️`/`🔖`, `BmBtn`)도 `Shift+좌클릭` 한 번으로 `🔖초판특전`과 `🔖북마크`를 동시에 켜주면 초판 찜하기가 훨씬 빨라지겠어요."
- **기획자 (PO)**: "`main_view.gd` `WebBtn`/`CamBtn` `Shift+좌클릭` 스크랩·촬영 후 즉시 열기와 `detail_modal.gd` 권별 `BmBtn` `Shift+좌클릭` 초판+북마크를 구현하고 `index.html` 권별 북마크 버튼과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `NavRow`의 `WebBtn` 및 `CamBtn` `Shift+좌클릭` 시 `_on_web_scrape_btn_pressed()` / `_on_camera_snap_btn_pressed()` 실행 후 새로 추가된 `items[0]` 일기장 모달을 즉시 열도록 연결하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - 권별 `bm_btn` `Shift+좌클릭` 시 `status = "first"` 및 `bookmarked = true`를 즉시 적용하고 UI·헤더·시그널을 동기화했습니다.
- `game02/index.html`:
  - `renderDiaryVolumes()` 내 북마크 버튼 `onclick`에 `event.shiftKey` 시 `초판+북마크` 동시 적용 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `WebBtn`/`CamBtn` `Shift+좌클릭` 즉시 열기와 권별 `BmBtn` `Shift+좌클릭` `초판+북마크`를 검증하는 Sprint 157 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 156] `StatVols`/`StatFirsts` `Shift+좌클릭` 첫 작품·초판 가치순 & 권별 `StarBtn` `Shift+좌클릭` ★5+북마크

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 `단행본 기록`(`StatVols`)을 `Shift+좌클릭`하면 이북·단행본 첫 작품 일기장이 바로 열리고, `초판 스탬프`(`StatFirsts`)를 `Shift+좌클릭`하면 초판 보유작만 가치순으로 정렬되면 통계 카드 4종이 전부 완벽한 원클릭 단축키가 될 것 같아요!"
- **가챠러 B**: "권별 리스트의 별점(`★★★★★`, `StarBtn`)을 `Shift+좌클릭`했을 때 별점 5점(`★5`)과 북마크를 한 번에 켜줄 수 있으면 최애 권을 표시할 때 정말 빠르겠어요."
- **기획자 (PO)**: "`main_view.gd` `StatVols`/`StatFirsts` `Shift+좌클릭`과 `detail_modal.gd` 권별 `StarBtn` `Shift+좌클릭` `★5+북마크`를 구현하고 `index.html` 권별 별점 버튼과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `StatVols` `Shift+좌클릭` 시 `_on_tab_manga_pressed(); _open_first_filtered_card()`를, `StatFirsts` `Shift+좌클릭` 시 `_on_stat_firsts_clicked(); _set_sort_mode(3)`을 실행하고 `_update_stats()` 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - 권별 `star_btn` `Shift+좌클릭` 시 `rating = 5` 및 `bookmarked = true`를 즉시 적용하고 UI·헤더·시그널을 동기화했습니다.
- `game02/index.html`:
  - `renderDiaryVolumes()` 내 별점 버튼 `onclick`에 `event.shiftKey` 시 `★5+북마크` 동시 적용 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StatVols`/`StatFirsts` `Shift+좌클릭`과 권별 `StarBtn` `Shift+좌클릭` `★5+북마크`를 검증하는 Sprint 156 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 155] 마일스톤 155: 필터 탭 5종 `Shift+좌클릭` 첫 작품·랜덤 즉시 열기 & 인장 4종 `Shift+좌클릭` 찍고 닫기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 필터 탭(`이북·단행본`·`가챠노트`·`완독작`·`인생작`)을 `Shift+좌클릭`하면 필터링과 동시에 첫 번째 작품 일기장이 바로 펼쳐지고, `전체일기`를 `Shift+좌클릭`하면 랜덤 작품이 열리면 탐색 속도가 엄청 빨라질 것 같아요!"
- **가챠러 B**: "`DetailModal` 인장 4종(`전권완결`·`초판특전`·`인생최애`·`위시`)을 `Shift+좌클릭`하면 인장을 찍자마자 일기장 모달이 깔끔하게 닫히면 도장만 빠르게 찍고 나올 때 정말 편하겠어요."
- **기획자 (PO)**: "`main_view.gd` 필터 탭 5종 `Shift+좌클릭` 즉시 열기와 `detail_modal.gd` 인장 4종 `Shift+좌클릭` 찍고 닫기를 구현하고 `index.html` 인장 버튼들과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `tab_all` `Shift+좌클릭` 시 `_reset_all_filters(); pick_random_item(true)`를, `tab_manga`/`tab_gacha`/`tab_complete`/`tab_fav` `Shift+좌클릭` 시 필터 적용 후 `_open_first_filtered_card()`를 실행하고 `_update_stats()` 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `STAMP_PRESET_MAP` 4종 인장 버튼 `Shift+좌클릭` 시 `apply_stamp(st_name)` 실행 후 `close()`를 호출하도록 연결하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - 4종 인장 버튼 `onclick`에 `event.shiftKey` 시 `closeJournalModal()` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 필터 탭 5종 `Shift+좌클릭` 즉시 열기와 인장 버튼 `Shift+좌클릭` 찍고 닫기를 검증하는 Sprint 155 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 154] 통계 카드(`StatItems`/`StatGacha`) `Shift+좌클릭` 정렬 초기화·가치순 & 만년필 잉크 4종 `Shift+좌클릭` 적용+입력창 이동

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 `서재 작품`(`StatItems`) 카드를 `Shift+좌클릭`하면 검색어와 정렬까지 전부 기본 상태로 돌아가고, `가챠 스크랩`(`StatGacha`)을 `Shift+좌클릭`하면 가챠 노트만 가치순으로 바로 정렬되면 좋겠어요!"
- **가챠러 B**: "`DetailModal` 속 만년필 잉크 4종(`☕에스프레소`·`🍷버건디`·`🍂세피아`·`🌲포레스트`)을 `Shift+좌클릭`하면 잉크색이 바뀜과 동시에 커서가 바로 밑줄 입력창으로 이동해 곧바로 글을 쓸 수 있으면 자연스러울 것 같아요."
- **기획자 (PO)**: "`main_view.gd` `StatItems`/`StatGacha` `Shift+좌클릭` 파워 액션과 `detail_modal.gd` 잉크 스와치 4종 `Shift+좌클릭` 잉크 적용+입력창 포커스를 구현하고 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `StatItems` `Shift+좌클릭` 시 `_reset_all_filters(); _set_sort_mode(0)`를, `StatGacha` `Shift+좌클릭` 시 `_on_tab_gacha_pressed(); _set_sort_mode(3)`을 실행하고 `_update_stats()` 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `INK_SWATCH_MAP` 4종 잉크 버튼 `Shift+좌클릭` 시 `set_fountain_pen_ink(sw_hex)` 적용 후 `quote_input.grab_focus()`로 즉시 이동하도록 연결했습니다.
- `game02/index.html`:
  - 상단 전체 통계 카드 및 만년필 잉크 4종 버튼 `onclick`에 `event.shiftKey` 분기 동작과 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StatItems`/`StatGacha` `Shift+좌클릭`과 `InkBurgundy` `Shift+좌클릭` 잉크 적용을 검증하는 Sprint 154 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 153] `ThemeBtn` `Shift+좌클릭` 기본 속지 테마 복원 & `CloseBtn` `Shift+좌클릭` 감상 카드 복사+닫기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "하단 `속지 테마`(`ThemeBtn`) 버튼으로 여러 배경 테마를 구경하다가 기본 미색 노트로 돌아오고 싶을 때 `Shift+좌클릭` 한 번으로 기본 테마가 복원되면 좋겠어요!"
- **가챠러 B**: "일기장 모달을 닫을 때 `✕`(`CloseBtn`)를 `Shift+좌클릭`하면 감상 카드를 클립보드에 복사하면서 동시에 모달이 닫히면 공유 후 바로 서재로 돌아갈 수 있어 편하겠어요."
- **기획자 (PO)**: "`main_view.gd` `ThemeBtn` `Shift+좌클릭` 기본 테마 복원과 `detail_modal.gd` `CloseBtn` `Shift+좌클릭` 복사+닫기를 구현하고 `index.html` 닫기 버튼과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `_reset_theme()`를 추가해 `ThemeBtn` `Shift+좌클릭` 시 기본 속지 테마(`theme_cursor = 0`)로 즉시 복원하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `CloseBtn` `Shift+좌클릭` 시 `copy_book_quote_card()` 실행 후 `close()`를 호출하도록 연결하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - 일기장 닫기 버튼 `onclick`에 `event.shiftKey` 시 `copyBookQuoteCard(); closeJournalModal();` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `ThemeBtn` `Shift+좌클릭` 기본 테마 복원과 `CloseBtn` `Shift+좌클릭` 복사+닫기를 검증하는 Sprint 153 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 152] `AddBtn` `Shift+좌클릭` 샘플 채움 모달 열기 & `AddVolBtn` `Shift+좌클릭` 초판+북마크 즉시 추가

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 `+ 일기 쓰기`(`AddBtn`) 버튼을 `Shift+좌클릭`하면 빈 창이 아니라 제목·작가·문장이 미리 채워진 템플릿 상태로 열리면 1초 만에 수정해서 등록할 수 있을 것 같아요!"
- **가챠러 B**: "일기장 안의 `+ 다음 권 일기 추가`(`AddVolBtn`) 버튼을 `Shift+좌클릭`하면 새 권이 추가됨과 동시에 `🔖초판특전` 스탬프와 `🔖 북마크`가 한 번에 켜져서 초판 수집 기록이 훨씬 빠르겠어요."
- **기획자 (PO)**: "`main_view.gd` `AddBtn` `Shift+좌클릭` 샘플 채움 모달 열기와 `detail_modal.gd` `AddVolBtn` `Shift+좌클릭` 초판+북마크 추가를 구현하고 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `AddBtn` `Shift+좌클릭` 시 `add_modal.open()` 후 샘플 제목·작가·문장을 미리 채워 열어주도록 연결하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `AddVolBtn` `Shift+좌클릭` 시 새 권을 추가한 뒤 `status = "first"` 및 `bookmarked = true`를 즉시 적용해 렌더링·시그널을 동기화했습니다.
- `game02/index.html`:
  - `+ 다음 권 기록 추가` 버튼 `onclick`에 `event.shiftKey` 시 초판+북마크 동시 추가 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AddBtn` `Shift+좌클릭` 샘플 모달 열기와 `AddVolBtn` `Shift+좌클릭` 초판+북마크 추가를 검증하는 Sprint 152 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 151] `RandomPickBtn` `Shift+좌클릭` 서재 필터 & `SaveQuoteBtn`/`HighlightBtn` `Shift+좌클릭`(저장+복사/속지 순환)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`🎲 추천`(`RandomPickBtn`) 버튼을 `Shift+좌클릭`하면 모달을 띄우지 않고 서재 선반에 랜덤 추천 작품 카드 1장만 딱 띄워서 집중 감상할 수 있으면 좋겠어요!"
- **가챠러 B**: "`🖋️ 밑줄 저장` 버튼을 `Shift+좌클릭`하면 저장과 동시에 문장이 클립보드에 복사되고, `🖍️ 형광펜` 버튼을 `Shift+좌클릭`하면 바로 옆 속지 패턴(노말/모눈/줄노트 등)을 함께 전환할 수 있으면 다꾸가 더 즐거워지겠어요."
- **기획자 (PO)**: "`main_view.gd` `RandomPickBtn` `Shift+좌클릭` 서재 필터와 `detail_modal.gd` `SaveQuoteBtn`/`HighlightBtn` `Shift+좌클릭` 저장+복사·속지 순환을 구현하고 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `RandomPickBtn` `Shift+좌클릭` 시 랜덤 작품을 뽑아 `search_input.text`에 설정하고 서재를 해당 작품 1건으로 필터링하도록 구현했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `SaveQuoteBtn` `Shift+좌클릭` 시 밑줄·감상평 저장과 동시에 클립보드에 복사하고 툴팁 피드백(`✅ 저장·복사됨`)을 표시하도록 연결했습니다.
  - `HighlightBtn` `Shift+좌클릭` 시 `cycle_paper_pattern(1)`을 호출해 속지 패턴을 순환하도록 연결했습니다.
- `game02/index.html`:
  - 랜덤 추천 버튼 및 `🖋️ 밑줄 저장` 버튼 `onclick`에 `event.shiftKey` 분기 동작과 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `RandomPickBtn` `Shift+좌클릭` 서재 필터와 `SaveQuoteBtn`/`HighlightBtn` `Shift+좌클릭` 저장+복사·속지 순환을 검증하는 Sprint 151 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 150] 마일스톤 150: `StatusToast` `Shift+좌/우클릭`(서재 브리핑/복사) & `MemoLabel` `Shift+좌클릭` 감상평 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "하단 상태바(`StatusToast`)를 `Shift+좌클릭`하면 서재 전체 자산·완독률 인포그래픽 브리핑이 뜨고, `Shift+우클릭`하면 지금 뜬 상태 메시지가 바로 복사되면 정말 실용적일 것 같아요!"
- **가챠러 B**: "`DetailModal` 속 한 줄 감상평(`MemoLabel`)을 `Shift+좌클릭`하면 편집 입력창으로 가지 않고 원문 감상평만 깔끔하게 클립보드에 복사되면 리뷰 공유할 때 편하겠어요."
- **기획자 (PO)**: "`main_view.gd` `StatusToast` `Shift+좌/우클릭` 브리핑·복사와 `detail_modal.gd` `MemoLabel` `Shift+좌클릭` 감상평 복사를 구현하고 `index.html` `#diary-memo`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `StatusToast` `Shift+좌클릭` 시 `show_library_infographic()`를, `Shift+우클릭` 시 `status_toast.text` 클립보드 복사 및 토스트(`📋 상태 메시지 복사 완료!`)를 표시하도록 구현했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `MemoLabel` `Shift+좌클릭` 시 `current_item.memo`를 클립보드에 복사하고 툴팁 피드백(`✅ 감상평 복사됨`)을 표시하며 `open()` 시 기본 툴팁으로 복원하도록 구현했습니다.
- `game02/index.html`:
  - `#diary-memo` `onclick`에서 `event.shiftKey` 시 감상평 텍스트를 클립보드에 복사하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StatusToast` `Shift+좌/우클릭` 브리핑·복사와 `MemoLabel` `Shift+좌클릭` 감상평 복사를 검증하는 Sprint 150 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 149] `SortBtn` `Shift+좌클릭` 기본순 정렬 복원 & `TagLabel` `Shift+좌클릭` 태그·띠지 문구 클립보드 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "가치순이나 다독순으로 정렬해보다가 다시 원래대로 돌리고 싶을 때 `SortBtn`을 `Shift+좌클릭`하면 한 번에 `↕ 기본순`으로 복원되면 정말 편할 것 같아요!"
- **가챠러 B**: "`DetailModal` 속 태그·기분·띠지 요약 줄(`TagLabel`)을 `Shift+좌클릭`했을 때 그 작품의 전체 상태·띠지 태그 문구가 클립보드에 복사되면 기록 공유에 유용하겠어요."
- **기획자 (PO)**: "`main_view.gd` `SortBtn` `Shift+좌클릭` 기본순 복원과 `detail_modal.gd` `TagLabel` `Shift+좌클릭` 태그 복사를 구현하고 `index.html` `#diary-stamp`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `SortBtn` `Shift+좌클릭` 시 `_set_sort_mode(0)`(`↕ 기본순`)으로 즉시 복원하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `TagLabel` `Shift+좌클릭` 시 `tag_label.text`를 클립보드에 복사하고 툴팁 피드백(`✅ 태그 복사됨`)을 표시하며 `open()` 시 기본 툴팁으로 복원하도록 구현했습니다.
- `game02/index.html`:
  - `#diary-stamp` `onclick`에서 `event.shiftKey` 시 스탬프·태그 텍스트를 복사하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `SortBtn` `Shift+좌클릭` 기본순 복원과 `TagLabel` `Shift+좌클릭` 태그 복사를 검증하는 Sprint 149 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 148] `AmbientBtn` `Shift+좌클릭` 즉시 음소거 & `AuthorLabel` `Shift+좌클릭` 작가명 클립보드 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "백색소음(`AmbientBtn`)을 켜고 독서하다가 전화가 오거나 조용히 해야 할 때, 여러 소리를 계속 눌러서 넘기지 않고 `Shift+좌클릭` 한 번으로 즉시 `🔕 무음`으로 돌아가면 좋겠어요!"
- **가챠러 B**: "`DetailModal` 속 작가·시리즈 라벨(`AuthorLabel`)을 `Shift+좌클릭`하면 검색으로 이동하지 않고 작가명만 깔끔하게 클립보드에 복사되면 외부 검색이나 메모할 때 편하겠어요."
- **기획자 (PO)**: "`main_view.gd` `AmbientBtn` `Shift+좌클릭` 즉시 음소거와 `detail_modal.gd` `AuthorLabel` `Shift+좌클릭` 작가명 복사를 구현하고 `index.html` `#ambient-sound-btn`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `AmbientBtn` `Shift+좌클릭` 시 `ambient_sound_index = 0`(`🔕 무음`)으로 즉시 전환하고 토스트(`🔕 백색소음 음소거 완료`)를 표시하며 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `AuthorLabel` `Shift+좌클릭` 시 `current_item.author_or_series`를 클립보드에 복사하고 툴팁 피드백(`✅ 작가 복사됨`)을 표시하며 `open()` 시 기본 툴팁으로 복원하도록 구현했습니다.
- `game02/index.html`:
  - `#ambient-sound-btn` `onclick`에서 `event.shiftKey` 시 즉시 무음 전환 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AmbientBtn` `Shift+좌클릭` 즉시 음소거와 `AuthorLabel` `Shift+좌클릭` 작가명 복사를 검증하는 Sprint 148 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 147] `SubTitle` `Shift+좌/우클릭`(즉시 백업/단축키 치트시트) & `PageBadgeLabel` `Shift+좌/우클릭`(처음·끝 이동)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 날짜·KPI 요약 줄(`SubTitle`)을 `Shift+좌클릭`하면 즉시 JSON 백업이 저장되고, `Shift+우클릭`하면 단축키 치트시트(`H`)가 뜨면 상단 바만으로도 핵심 유틸을 바로 쓸 수 있겠어요!"
- **가챠러 B**: "모달 헤더의 페이지 배지(`1/6`, `PageBadgeLabel`)를 `Shift+좌클릭`하면 첫 번째 작품으로, `Shift+우클릭`하면 마지막 작품으로 바로 점프하면 긴 서재도 순식간에 탐색할 수 있을 것 같아요."
- **기획자 (PO)**: "`main_view.gd` `SubTitle` `Shift+좌/우클릭` 백업·치트시트와 `detail_modal.gd` `PageBadgeLabel` `Shift+좌/우클릭` 처음·끝 이동을 구현하고 `index.html` 상단 서브타이틀과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `SubTitle` `Shift+좌클릭` 시 `_trigger_instant_json_backup()`, `Shift+우클릭` 시 `_show_shortcut_cheatsheet()`를 호출하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `PageBadgeLabel` `Shift+좌클릭` 시 `navigate_requested(-9999)`(처음), `Shift+우클릭` 시 `navigate_requested(9999)`(끝)를 발행하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - 상단 날짜·저널 서브타이틀 바에 `Shift+좌클릭` 즉시 백업 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `SubTitle` `Shift+좌/우클릭` 백업·치트시트와 `PageBadgeLabel` `Shift+좌/우클릭` 처음·끝 이동을 검증하는 Sprint 147 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 146] `AppTitle` `Shift+좌클릭` 새 일기 쓰기 & `ModalWashiTape` `Shift+좌/우클릭` 스티커·속지 순환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "메인 타이틀(`주희의 다꾸 서재 & 소장 일기장`)을 `Shift+좌클릭`하면 바로 `AddModal` 새 일기 작성 창이 열리면 상단 버튼을 누르지 않아도 1초 만에 일기를 쓸 수 있을 것 같아요!"
- **가챠러 B**: "`DetailModal` 책 표지 위의 마스킹 테이프(`ModalWashiTape`)를 `Shift+좌클릭`하면 데코 스티커가 바뀌고, `Shift+우클릭`하면 속지 패턴(노말/모눈/줄노트 등)이 바뀌면 다꾸 꾸미기 손맛이 한층 더 살아나겠어요."
- **기획자 (PO)**: "`main_view.gd` `AppTitle` `Shift+좌클릭` `AddModal` 열기와 `detail_modal.gd` `ModalWashiTape` `Shift+좌/우클릭` 스티커·속지 순환을 구현하고 `index.html` 타이틀과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `AppTitle` `Shift+좌클릭` 시 `add_modal.open()`을 호출해 새 일기 작성 모달을 즉시 열도록 연결하고 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `ModalWashiTape` `Shift+좌클릭` 시 `cycle_deco_sticker(1)`, `Shift+우클릭` 시 `cycle_paper_pattern(1)`을 호출하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - 상단 `<h1>` 타이틀 `onclick`에서 `event.shiftKey` 시 `openNewDiaryModal()`을 호출하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AppTitle` `Shift+좌클릭` 새 일기 모달 열기와 `ModalWashiTape` `Shift+좌/우클릭` 스티커·속지 순환을 검증하는 Sprint 146 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 145] 마일스톤 145: `TodayQuoteLabel` `Shift+좌클릭` 밑줄 즉시 복사 & `CoverRect` `Shift+좌/우클릭` 마감·상태등급 전환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "메인 상단 배너의 `TodayQuoteLabel`을 `Shift+좌클릭`하면 모달을 열지 않고도 지금 뜬 오늘의 밑줄 문장을 그대로 클립보드에 복사할 수 있으면 좋겠어요!"
- **가챠러 B**: "`DetailModal` 속 책 표지(`CoverRect`)를 `Shift+좌클릭`하면 표지 마감(무광 매트/유광 코팅/홀로그램 등)이 바뀌고, `Shift+우클릭`하면 소장 상태등급(S급/A급 등)이 바뀌면 책 표지를 만지는 손맛이 훨씬 살아나겠어요."
- **기획자 (PO)**: "`main_view.gd` `TodayQuoteLabel` `Shift+좌클릭` 복사와 `detail_modal.gd` `CoverRect` `Shift+좌/우클릭` 마감·상태등급 순환을 구현하고 `index.html` `#today-quote-banner`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `TodayQuoteLabel` `Shift+좌클릭` 시 `DisplayServer.clipboard_set(today_quote_label.text)`로 복사하고 토스트 피드백(`📋 오늘의 밑줄 복사 완료`)을 표시하며 툴팁을 동기화했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `CoverRect` `Shift+좌클릭` 시 `cycle_cover_finish(1)`, `Shift+우클릭` 시 `cycle_condition_grade(1)`을 호출하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - `#today-quote-banner` `onclick`에서 `event.shiftKey` 시 클립보드 복사 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `TodayQuoteLabel` `Shift+좌클릭` 복사와 `CoverRect` `Shift+좌/우클릭` 마감·상태등급 전환을 검증하는 Sprint 145 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 144] `VolHeader` `Shift+좌클릭` 전권 북마크 일괄 토글 & `NextQuoteBtn` `Shift+좌클릭` 해당 작품 열기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "권별 밑줄 노트 헤더(`VolHeader`)를 `Shift+좌클릭`하면 해당 작품의 모든 권에 북마크를 한 번에 켜거나 한 번에 해제할 수 있으면 시리즈 전체 소장 정리가 훨씬 빨라질 것 같아요!"
- **가챠러 B**: "`↻ 문장`(`NextQuoteBtn`) 버튼도 `Shift+좌클릭`하면 지금 배너에 표시된 명대사의 작품 일기장으로 바로 들어가면 문장 넘기다가 꽂힌 책을 즉시 열어볼 수 있겠어요."
- **기획자 (PO)**: "`detail_modal.gd` `VolHeader` `Shift+좌클릭` 전권 북마크 일괄 토글과 `main_view.gd` `NextQuoteBtn` `Shift+좌클릭` 작품 열기를 구현하고 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `VolHeader` `Shift+좌클릭` 시 전권 `bookmarked` 상태를 일괄 토글(모두 북마크됨이면 전체 해제, 아니면 전체 북마크)하고 UI 및 시그널을 동기화했습니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `NextQuoteBtn` `Shift+좌클릭` 시 `open_current_quote_item()`을 호출해 현재 오늘의 밑줄 작품 일기장을 열도록 연결했습니다.
- `game02/index.html`:
  - `#next-quote-btn` 및 `📌 권별 소장 스탬프 & 좋아하는 대사` 헤더에 동일한 `Shift+좌클릭` 동작과 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `NextQuoteBtn` `Shift+좌클릭` 작품 열기와 `VolHeader` `Shift+좌클릭` 전권 북마크 일괄 토글을 검증하는 Sprint 144 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 143] 서재 카드 `Shift+좌클릭` 작가·시리즈 즉시 검색 & 책등 선반(`SpineShelf`) `Shift+좌/우클릭` 필터·복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "서재 카드를 `Shift+좌클릭`하면 상세 모달을 열지 않고도 그 카드의 작가나 시리즈명으로 바로 서재 검색이 걸리면 같은 작가 작품들을 1초 만에 모아볼 수 있을 것 같아요!"
- **가챠러 B**: "상단 미니 책등 선반(`SpineShelf`)에서도 `Shift+좌클릭`으로 해당 작품만 필터링하거나 `Shift+우클릭`으로 감상 요약 카드를 바로 복사하면 미니 서재가 훨씬 실용적이겠어요."
- **기획자 (PO)**: "`card_item.gd` `author_filter_requested` 시그널과 `main_view.gd` 작가 검색·책등 `Shift+클릭` 핸들러를 구현하고 `index.html` 카드 클릭 이벤트와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/card_item.gd`:
  - `author_filter_requested(item)` 시그널을 신설하고 `Shift+좌클릭` 시 발행하며 카드 리치 툴팁에 안내를 추가했습니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `_on_card_author_filter_requested()`로 카드 `Shift+좌클릭` 시 해당 작가·시리즈명으로 즉시 검색을 적용했습니다.
  - `_render_spine_shelf()`의 책등(`ColorRect`)에 `Shift+좌클릭` 작품 필터링 및 `Shift+우클릭` 감상 요약 복사를 추가했습니다.
- `game02/index.html`:
  - 서재 카드 `onclick`에서 `ev.shiftKey` 시 `#search-box`에 작가명을 채워 필터링하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 카드 `Shift+좌클릭` 작가 검색과 책등 `Shift+좌클릭` 작품 필터를 검증하는 Sprint 143 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 142] `AddModal` 헤더 `TitleLabel` 좌·우클릭(샘플 일괄 채움/비우기) & `Ctrl/Cmd+Enter` 즉시 등록

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`AddModal` 상단 제목(`🖋️ 새 독서 · 다꾸 일기장 쓰기`)을 좌클릭하면 제목·작가·밑줄 3칸에 샘플 일기가 한 번에 채워지고, 우클릭하면 전부 비워지면 등록 테스트나 빠른 템플릿 작성이 훨씬 편할 것 같아요!"
- **가챠러 B**: "입력창 어디에 포커스가 있든 `Ctrl+Enter`나 `Cmd+Enter`를 누르면 바로 일기가 등록되면 마우스 이동 없이 키보드만으로 작성이 끝나겠어요."
- **기획자 (PO)**: "`add_modal.gd` `TitleLabel` 좌·우클릭 일괄 채움/비우기와 `_unhandled_input()` `Ctrl/Cmd+Enter` 즉시 등록을 구현하고 `index.html` 노트 헤더와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/add_modal.gd`:
  - `Panel/VBox/Header/HBox/TitleLabel` 좌클릭 시 샘플 일기 3종 필드를 일괄 채우고, 우클릭 시 `clear_inputs()`를 호출하도록 연결했습니다.
  - `_unhandled_input()`에 `Ctrl+Enter` / `Cmd+Enter` 입력 시 `_on_submit_btn_pressed()`를 실행하는 단축키를 추가했습니다.
- `game02/index.html`:
  - `🖋️ 나만의 독서 노트 & 권별 밑줄` 헤더 스팬에 좌클릭 샘플 밑줄 채움·우클릭 입력 비우기 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AddModal` `TitleLabel` 좌클릭 샘플 채움·우클릭 비우기와 `Ctrl+Enter` 즉시 등록을 검증하는 Sprint 142 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 141] `DetailModal` `StampLbl`·`InkLbl` 라벨 좌·우클릭 양방향 인장/잉크 순환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`💮 인장:` 라벨(`StampLbl`)을 클릭·우클릭해서 4종 인장 프리셋(`전권완결`·`초판특전`·`인생최애`·`위시`)을 순서대로 또는 역순으로 바로 넘겨볼 수 있으면 좋겠어요!"
- **가챠러 B**: "`🖋️ 잉크:` 라벨(`InkLbl`)도 좌클릭·우클릭으로 만년필 잉크 4종을 양방향으로 순환시킬 수 있으면 작은 버튼을 일일이 고르지 않아도 느낌을 바로 비교할 수 있겠어요."
- **기획자 (PO)**: "`detail_modal.gd` `StampLbl`과 `InkLbl`에 양방향 순환 클릭 핸들러와 툴팁을 추가하고 `index.html` 인장·잉크 라벨 스팬과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `StampLbl` 좌·우클릭 시 `STAMP_PRESET_MAP` 4종 인장 프리셋을 정방향/역방향으로 순환 적용(`apply_stamp`)하도록 연결했습니다.
  - `InkLbl` 좌·우클릭 시 `cycle_fountain_pen_ink(1)` / `cycle_fountain_pen_ink(-1)`을 호출하도록 연결했습니다.
- `game02/index.html`:
  - `💮 인장 찍기:`와 `🖋️ 잉크:` 라벨 스팬에 동일한 좌·우클릭 양방향 순환 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StampLbl`과 `InkLbl`의 좌클릭 정방향 순환 및 우클릭 역방향 복원을 검증하는 Sprint 141 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 140] 마일스톤 140: `DetailModal` `TitleLabel` 우클릭 감상 카드 복사 & `CatBadge` 우클릭 전체 서재 복원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 상단 작품 제목(`TitleLabel`)을 좌클릭하면 제목만 복사되는데, 우클릭하면 바로 감상 카드 전체를 클립보드로 복사해주면 공유하기가 훨씬 편할 것 같아요!"
- **가챠러 B**: "카테고리 배지(`CatBadge`)를 좌클릭해 이북이나 가챠만 모아본 뒤, 우클릭했을 때 모달이 닫히면서 전체 서재(6종)로 바로 복원되면 탐색 동선이 완벽해지겠어요."
- **기획자 (PO)**: "`detail_modal.gd` `TitleLabel` 우클릭 `card_copied` 발행 + `open()` 시 툴팁 초기화 보완, `CatBadge` 우클릭 `filter_category_requested(-1)` 전체 서재 복원을 구현하고 `index.html` `#diary-title`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `TitleLabel` 우클릭 시 `card_copied.emit(current_item)`으로 감상 카드 전체를 복사하며, `open()` 호출 시 제목 툴팁을 기본 안내 문구로 복원하도록 개선했습니다.
  - `CatBadge` 우클릭 시 모달을 닫고 `filter_category_requested.emit(-1)`을 발행해 전체 서재 필터로 복원하도록 구현했습니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `filter_category_requested` 핸들러에서 `cat == -1`일 때 `_on_tab_all_pressed()`를 호출하도록 연결했습니다.
- `game02/index.html`:
  - `#diary-title` `oncontextmenu`에 `copyBookQuoteCard()` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `TitleLabel` 우클릭 감상 카드 복사와 `CatBadge` 우클릭 전체 서재 복원을 검증하는 Sprint 140 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 139] `SearchInput` 우클릭 검색어 비우기·오늘의 밑줄 작품 검색 & `AddModal` 입력창 우클릭 비우기·샘플 채움

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "검색창(`SearchInput`)에 글자가 있을 때 우클릭하면 한 번에 비워지고, 비어 있을 때 우클릭하면 지금 배너에 뜬 '오늘의 밑줄' 작품명으로 바로 검색되면 정말 편리할 것 같아요!"
- **가챠러 B**: "`AddModal`의 제목·작가·문장 입력란도 각각 우클릭으로 비우거나 기본 샘플을 채워 넣을 수 있으면 테스트나 빠른 메모 작성이 훨씬 수월해지겠어요."
- **기획자 (PO)**: "`main_view.gd` `SearchInput` 우클릭 토글(비우기/오늘의 밑줄 검색)과 `add_modal.gd` 3종 입력창 우클릭 비우기/샘플 채움을 구현하고 `index.html` `#search-box`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `SearchInput` 우클릭 시 검색어가 있으면 초기화하고, 비어 있으면 현재 `quote_cursor`에 해당하는 작품 제목으로 즉시 필터링하도록 구현했습니다.
- `game02/godot_project/scripts/add_modal.gd`:
  - `TitleInput`, `AuthorInput`, `QuoteInput` 우클릭 시 입력값이 있으면 비우고, 비어 있으면 각각 샘플 문구를 채우도록 연결했습니다.
- `game02/index.html`:
  - `#search-box` `oncontextmenu`에 검색어 초기화 / `quoteIdx` 작품 제목 검색 토글 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `SearchInput` 우클릭 추천 검색·초기화와 `AddModal` 입력창 우클릭 샘플 채움·비우기 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 138] `RemoveVolBtn` 우클릭 마지막 권 북마크 토글 & `QuoteInput` 우클릭 입력 비우기·원문 복원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`DetailModal`의 `- 권 삭제`(`RemoveVolBtn`) 버튼을 우클릭하면 마지막 권을 삭제하는 대신 마지막 권의 북마크를 바로 토글해 소중한 최신 권을 찜할 수 있으면 좋겠어요!"
- **가챠러 B**: "밑줄·감상평 입력창(`QuoteInput`)을 우클릭했을 때 글이 적혀 있으면 한 번에 비우고, 비어 있을 때 다시 우클릭하면 원문 감상평을 복원해주면 수정하기 훨씬 편할 것 같아요."
- **기획자 (PO)**: "`detail_modal.gd` `RemoveVolBtn` 우클릭 마지막 권 북마크 토글과 `QuoteInput` 우클릭 비우기/원문 복원을 구현하고 `index.html` `#diary-quote-input`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `RemoveVolBtn` 우클릭 시 마지막 권(`volumes.size() - 1`)의 북마크(`toggle_volume_bookmark`)를 토글하고 툴팁을 동기화했습니다.
  - `QuoteInput` 우클릭 시 입력값이 있으면 비우고(`""`), 비어 있으면 원문 `current_item.memo`를 복원하며 툴팁을 추가했습니다.
- `game02/index.html`:
  - `#diary-quote-input` `oncontextmenu`에 입력 비우기/원문 복원 토글 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `RemoveVolBtn` 우클릭 마지막 권 북마크 토글 및 `QuoteInput` 우클릭 비우기·원문 복원 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 137] 권별 리스트 `vol_lbl` 좌·우클릭(편집/북마크) & `quote_lbl` 우클릭 밑줄 문장 즉시 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "권별 일기 리스트에서 `1권`, `2권` 번호 라벨(`vol_lbl`)을 좌클릭하면 바로 그 권의 밑줄 문장 편집으로 들어가고, 우클릭하면 북마크를 바로 켜고 끌 수 있으면 좋겠어요!"
- **가챠러 B**: "권별 밑줄 문장(`quote_lbl`)을 우클릭했을 때 그 권의 명대사만 깔끔하게 클립보드에 복사되면 친구에게 공유할 때 훨씬 빠를 것 같아요."
- **기획자 (PO)**: "`detail_modal.gd` 권별 행의 `vol_lbl`에 좌클릭 편집·우클릭 북마크 토글을, `quote_lbl`에 우클릭 클립보드 복사를 연결하고 `index.html` 권별 리스트와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - 권별 행 `vol_lbl` 좌클릭 시 `start_editing_volume_quote(idx)`, 우클릭 시 `toggle_volume_bookmark(idx)`를 실행하고 커서·툴팁을 추가했습니다.
  - 권별 행 `quote_lbl` 우클릭 시 `"작품명 N권: \"문장\""` 형식으로 클립보드에 복사하고 툴팁 피드백(`✅ 복사됨: ...`)을 표시하도록 구현했습니다.
- `game02/index.html`:
  - `renderDiaryVolumes()` 내 권 번호 라벨 및 밑줄 문장 스팬에 동일한 좌·우클릭 제스처와 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `vol_lbl` 좌클릭 편집·우클릭 북마크 토글과 `quote_lbl` 우클릭 복사를 검증하는 Sprint 137 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 136] `DetailModal` 배경 딤머 우클릭 닫기+즉시 JSON 백업 & `AddModal` 배경 딤머 우클릭 입력 비우기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`DetailModal`을 닫을 때 작은 `X` 버튼까지 마우스를 가져가지 않고 바깥 어두운 배경(`Dimmer`)을 우클릭해도 일기장이 닫히면서 즉시 JSON 백업까지 저장되면 훨씬 편할 것 같아요!"
- **가챠러 B**: "`AddModal`에서도 바깥 어두운 배경(`Dimmer`)을 우클릭하면 창은 닫히지 않은 채 방금 적던 입력 내용만 깔끔하게 비워주면 다시 작성하기 좋을 것 같아요."
- **기획자 (PO)**: "`detail_modal.gd` `Dimmer`에 우클릭 닫기+`close_and_backup_requested` 시그널 발행을, `add_modal.gd` `Dimmer`에 우클릭 `clear_inputs()`를 연결하고 `index.html` `#journal-modal` 배경과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `Dimmer` 우클릭 시 일기장 모달을 닫고 `close_and_backup_requested`를 발행해 즉시 JSON 백업 저장을 실행하며 툴팁을 추가했습니다.
- `game02/godot_project/scripts/add_modal.gd`:
  - `Dimmer` 우클릭 시 창을 유지한 채 `clear_inputs()`로 입력란을 초기화하며 툴팁을 추가했습니다.
- `game02/index.html`:
  - `#journal-modal` 배경 딤머 `oncontextmenu`에 닫기+`instantBackupArchive()` 및 안내 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `DetailModal` `Dimmer` 우클릭 닫기+JSON 백업과 `AddModal` `Dimmer` 우클릭 입력 비우기를 검증하는 Sprint 136 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 135] 마일스톤 135: 검색창 `Enter` 첫 결과 즉시 열기 & 빈 결과(`EmptyState`) 우클릭 복원+랜덤 추천 미리보기

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "검색창(`SearchInput`)에서 작품명을 입력한 뒤 `Enter`를 누르면 마우스로 카드를 클릭하지 않아도 첫 번째 검색 결과 일기장이 바로 열리면 정말 빠를 것 같아요!"
- **가챠러 B**: "검색 결과가 0건일 때 뜨는 `🔄 전체 서재 보기` 버튼(`EmptyStateResetBtn`)을 우클릭하면 전체 서재가 복원됨과 동시에 오늘의 랜덤 추천 작품 미리보기까지 띄워주면 막다른 길 없이 바로 다음 작품을 발견할 수 있겠어요."
- **기획자 (PO)**: "`main_view.gd`에 `_open_first_filtered_card()`를 추가해 `search_input.text_submitted`에 연결하고, `EmptyStateResetBtn` 우클릭 시 `_reset_all_filters()` + `pick_random_item(false)`를 실행하며 `index.html`의 `#search-box` 및 빈 상태 버튼과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `_open_first_filtered_card()`를 신설해 검색창에서 `Enter` 입력 시 필터링된 첫 번째 작품 일기장을 즉시 열어주며 툴팁을 동기화했습니다.
  - `EmptyStateResetBtn` 우클릭 시 전체 필터 초기화 후 랜덤 추천 미리보기(`pick_random_item(false)`)를 실행하도록 연결했습니다.
- `game02/index.html`:
  - `#search-box` `Enter` 첫 결과 모달 열기·`Escape` 초기화와 빈 상태 버튼 우클릭 랜덤 추천 미리보기를 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 검색창 `Enter` 첫 결과 열기와 `EmptyStateResetBtn` 우클릭 복원+랜덤 미리보기를 검증하는 Sprint 135 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 134] `AddModal` 표지 색상 스와치 우클릭 즉시 등록 & `ESC` 2단계 입력 비우기·닫기 안전장치

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`AddModal`의 6개 표지 색상 스와치(`크림슨`, `코발트`, `테라코타`, `로즈`, `포레스트`, `바이올렛`)를 우클릭하면 그 색상을 선택함과 동시에 샘플 자동 채움으로 바로 등록되면 1초 만에 원하는 색 일기장을 만들 수 있을 것 같아요!"
- **가챠러 B**: "`AddModal` 입력란에 글을 적다가 `ESC`를 눌렀을 때 바로 닫히지 않고, 먼저 입력 중인 텍스트를 비우고 빈 상태일 때 `ESC`를 누르면 모달이 닫히면 실수로 글을 날리지 않을 것 같아요."
- **기획자 (PO)**: "`add_modal.gd`에 `_submit_with_sample_fallback()` 공용 헬퍼를 추출해 `SubmitBtn` 우클릭과 6개 스와치 우클릭을 통합하고, `KEY_ESCAPE` 시 포커스 입력란 우선 비우기 후 닫기 안전장치를 구현하며 `index.html` 인용문 입력란 `Escape` 동작도 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/add_modal.gd`:
  - `_submit_with_sample_fallback()` 헬퍼를 추출해 `SubmitBtn` 우클릭과 표지 스와치 6종 우클릭 시 해당 색상으로 즉시 샘플 등록을 수행합니다.
  - `_unhandled_input`에서 `KEY_ESCAPE` 시 포커스된 `LineEdit`에 텍스트가 있으면 먼저 비우고, 비어있을 때 모달을 닫도록 안전장치를 추가했습니다.
- `game02/index.html`:
  - `#diary-quote-input`에서 `Escape` 키 입력 시 작성 중인 텍스트가 있으면 먼저 비우도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AddModal` 스와치 우클릭 즉시 등록과 `ESC` 2단계 비우기/닫기를 검증하는 Sprint 134 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 133] 서재 카드 `Shift+우클릭` 툴팁 동기화 & `AddModal` 카테고리 드롭다운 우클릭 즉시 전환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "서재 카드(`card_item.gd`)에 마우스를 올렸을 때 나오는 리치 툴팁에도 `Shift+우클릭: 감상 요약 복사` 안내가 적혀 있으면 새로운 기능을 바로 발견할 수 있을 것 같아요!"
- **가챠러 B**: "`AddModal`에서 `이북 · 만화 단행본 일기` ↔ `가챠 · 굿즈 스크랩 노트` 드롭다운(`CatOption`)을 우클릭하면 드롭다운을 열지 않고도 즉시 이북 ↔ 가챠가 전환되면 정말 편하겠어요."
- **기획자 (PO)**: "`card_item.gd`와 `index.html` 카드 툴팁에 `Shift+우클릭: 감상 요약 복사` 힌트를 동기화하고, `add_modal.gd`의 `CatOption` 우클릭 시 카테고리 즉시 토글 및 툴팁을 연결합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/card_item.gd`:
  - 리치 툴팁 하단에 `(우클릭: +1권 빠른 기록 · Shift+우클릭: 감상 요약 복사)` 안내를 추가했습니다.
- `game02/godot_project/scripts/add_modal.gd`:
  - `CatOption` 우클릭 시 이북(`0`) ↔ 가챠(`1`) 즉시 전환 및 툴팁을 연결했습니다.
- `game02/index.html`:
  - 서재 카드 `title` 속성에 `Shift+우클릭: 감상 요약 복사` 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 카드 툴팁 동기화와 `AddModal` `CatOption` 우클릭 카테고리 토글을 검증하는 Sprint 133 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 132] 카드 `Shift+우클릭` 즉시 감상 요약 복사 & `AddModal` 우클릭 입력 초기화·샘플 자동 채움 등록

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "서재 그리드에서 카드를 보다가 모달을 열지 않고도 바로 감상 카드를 공유하고 싶을 때가 있어요! 카드를 `Shift+우클릭`하면 해당 작품의 감상 요약이 클립보드에 복사되면 정말 빠를 것 같아요."
- **가챠러 B**: "`AddModal`을 열었을 때 `등록` 버튼을 우클릭하면 빈 제목일 때 오늘의 샘플을 자동 채움해 바로 등록하고, `닫기` 버튼을 우클릭하면 입력란만 모두 비워 재입력할 수 있으면 편리하겠어요!"
- **기획자 (PO)**: "`card_item.gd`에 `quote_copy_requested` 시그널과 `Shift+우클릭` 핸들러를 추가해 `main_view.gd`의 `_on_card_quote_copy_requested`에 연결하고, `add_modal.gd`에 `clear_inputs()` 및 `SubmitBtn` 우클릭 샘플 등록을 구현해 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/card_item.gd` · `main_view.gd`:
  - `Shift+우클릭` 시 모달을 열지 않고 즉시 카드 감상 요약(`📖 「제목」 — "대사"`)을 클립보드에 복사하고 토스트를 출력합니다.
- `game02/godot_project/scripts/add_modal.gd`:
  - `CloseBtn` 우클릭 시 `clear_inputs()`로 모든 입력란을 비우고, `SubmitBtn` 우클릭 시 빈 제목이면 샘플 텍스트를 자동 채움해 등록합니다.
- `game02/index.html`:
  - 카드 `Shift+우클릭`(`oncontextmenu`) 시 감상 요약 클립보드 복사를 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 카드 `Shift+우클릭` 복사와 `AddModal` 우클릭 입력 초기화·샘플 자동 등록을 검증하는 Sprint 132 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 131] 메인 `AppTitle` 좌·우클릭(전체 복원/테마 순환) & 하단 `StatusToast` 좌·우클릭(치트시트/랜덤 미리보기)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "메인 화면 상단 큰 제목(`주희의 다꾸 서재 & 소장 일기장`)을 좌클릭하면 전체 서재가 복원(`0` 키)되고, 우클릭하면 속지 테마(`T` 키)가 순환되면 상단에서도 바로 서재 리셋과 분위기 전환이 가능해질 것 같아요!"
- **미니멀러 C**: "하단 독 바 위의 안내 문구(`StatusToast`)를 좌클릭하면 단축키 치트시트(`H` 키)가 뜨고, 우클릭하면 오늘의 랜덤 작품 추천 미리보기(`Shift+R`)가 뜨면 메인 화면의 모든 텍스트 라벨까지 살아 숨 쉬는 UI가 되겠어요!"
- **기획자 (PO)**: "`main_view.gd`에 `_show_shortcut_cheatsheet()` 공용 헬퍼를 추출해 `KEY_H`와 `status_toast` 좌클릭을 통합하고, `AppTitle`과 `status_toast`의 좌·우클릭 및 툴팁을 연결해 `index.html`의 `<h1>` 제목과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `AppTitle` 좌클릭 시 `_reset_all_filters()`, 우클릭 시 `_step_theme(1 / -1)`이 동작하도록 연결했습니다.
  - `_show_shortcut_cheatsheet()` 헬퍼를 추출해 `KEY_H`와 `StatusToast` 좌클릭을 통합하고, `StatusToast` 우클릭 시 `pick_random_item(false)` 미리보기를 연결했습니다.
- `game02/index.html`:
  - 상단 `<h1>` 제목 클릭 시 전체 서재 복원, 우클릭 시 `toggleJournalTheme()` 테마 순환 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AppTitle` 좌·우클릭(전체 복원/테마 순환)과 `StatusToast` 좌·우클릭(치트시트/랜덤 미리보기)을 검증하는 Sprint 131 통합 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 130] 마일스톤 130: 모달 `TagLabel` 좌·우클릭 띠지 순환 & `VolHeader` 좌·우클릭 권 추가·삭제 (모달 전 영역 100% 인터랙티브화 달성)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달의 요약 태그줄(`TagLabel`)을 좌클릭하면 다음 띠지 문구로, 우클릭하면 이전 띠지 문구로 바뀌면 아래 `띠지` 버튼까지 마우스를 옮기지 않아도 바로 띠지를 갈아끼울 수 있을 것 같아요!"
- **가챠러 B**: "`📌 권별 밑줄 노트 (소장 3/3권 · ...)` 헤더(`VolHeader`)를 좌클릭하면 다음 권 일기 추가(`+`), 우클릭하면 마지막 권 삭제(`-`)가 되면 마일스톤 130 기념으로 모달 내 **모든 텍스트·라벨 영역 100% 인터랙티브화**가 완성되겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`에서 `tag_label` 좌·우클릭(`cycle_obi_preset(1 / -1)`)과 `vol_header` 좌·우클릭(`_on_add_vol_btn_pressed` / `remove_last_volume`)을 연결해 모달 내 모든 영역의 양방향 상호작용을 완성하고 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `TagLabel` 좌클릭(`cycle_obi_preset(1)`) · 우클릭(`cycle_obi_preset(-1)`) 및 툴팁을 연결했습니다.
  - `VolHeader` 좌클릭(`_on_add_vol_btn_pressed()`) · 우클릭(`remove_last_volume()`) 및 툴팁을 연결했습니다.
- `game02/index.html`:
  - `📌 권별 소장 스탬프 & 좋아하는 대사` 헤더 클릭 시 `addVolumeInDiary()`가 동작하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `TagLabel` 좌·우클릭 띠지 순환과 `VolHeader` 좌·우클릭 권 추가/삭제를 검증하는 Sprint 130 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 129] 모달 `AuthorLabel` 우클릭 가치 증감 & `MemoLabel` 좌클릭(편집 이동)·우클릭(형광펜 토글)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 `AuthorLabel`(`작가 · ... · 💎 ₩21,000`)을 우클릭하면 바로 추정 가치를 `+5,000원`(`Shift+우클릭`: `-5,000원`) 조정할 수 있으면 아래쪽 `+5천원` 버튼을 찾지 않아도 되어 정말 편할 것 같아요!"
- **가챠러 B**: "모달 중앙의 큰 감상평 문장(`MemoLabel`)을 좌클릭하면 바로 밑줄 문장 편집 입력창으로 포커스(`E` 키)되고, 우클릭하면 형광펜(`L` 키)이 토글되면 굿노트처럼 직관적이겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`의 `author_label`에 우클릭(`boost_estimated_value` / `Shift`: `reduce_estimated_value`)을, `memo_label`에 좌클릭(`quote_input` 포커스) · 우클릭(`toggle_quote_highlight`)을 연결하고 `index.html`의 `#diary-memo`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `AuthorLabel` 우클릭 시 `boost_estimated_value()` (`Shift+우클릭` 시 `reduce_estimated_value()`) 호출 및 툴팁을 연결했습니다.
  - `MemoLabel` 좌클릭 시 `quote_input`으로 포커스를 이동하고, 우클릭 시 `toggle_quote_highlight()`를 실행하며 툴팁을 추가했습니다.
- `game02/index.html`:
  - `#diary-memo` 클릭 시 `#diary-quote-input` 포커스, 우클릭 시 `toggleDiaryHighlighter()` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AuthorLabel` 우클릭/`Shift+우클릭` 가치 증감 및 `MemoLabel` 우클릭 형광펜 토글을 검증하는 Sprint 129 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 128] 모달 `CatBadge` 클릭(이북/가챠 카테고리 모아보기) & `AuthorLabel` 클릭(작가·시리즈 즉시 검색)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 상단 왼쪽 `[이북·단행본 일기]` / `[가챠·소장 노트]` 배지(`CatBadge`)를 클릭하면 모달이 닫히면서 바로 그 카테고리 탭만 모아볼 수 있으면 탐색 동선이 자연스러울 것 같아요."
- **가챠러 B**: "모달의 `작가 · 이노우에 다케히코 · ★5.0 · 💎 ₩21,000` 줄(`AuthorLabel`)을 클릭하면 바로 그 작가명으로 서재 검색이 실행되어 같은 작가·시리즈의 다른 작품까지 한눈에 찾을 수 있으면 좋겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`에 `filter_category_requested`와 `search_author_requested` 시그널을 신설해 `main_view.gd`의 탭 전환 및 검색 핸들러에 연결하고, `index.html`의 `#diary-cover-cat` 및 `#diary-author`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `CatBadge` 클릭 시 모달을 닫고 `filter_category_requested` 시그널을 발행하며, `AuthorLabel` 클릭 시 모달을 닫고 `search_author_requested` 시그널을 발행하도록 연결했습니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `filter_category_requested` 수신 시 이북(`0`)·가챠(`1`) 탭으로 전환하고, `search_author_requested` 수신 시 `search_input.text`를 설정해 즉시 검색 및 토스트를 출력합니다.
- `game02/index.html`:
  - `#diary-cover-cat` 클릭(`filterModalCategory`)과 `#diary-author` 클릭(`searchModalAuthor`)을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `CatBadge` 클릭 카테고리 필터링과 `AuthorLabel` 클릭 작가 검색을 검증하는 Sprint 128 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 127] 모달 `📅 기념일` 우클릭 기본값 초기화 & 모달 제목(`TitleLabel`) 클릭 클립보드 복사

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 `InkRow`의 `📅 기념일(DateStampBtn)` 버튼을 실수로 눌러 오늘 날짜로 바뀌었을 때, 우클릭 한 번으로 다시 기본값(`📅 기념일`)으로 되돌릴 수 있으면 좋겠어요."
- **미니멀러 C**: "모달 상단의 작품 제목을 클릭하면 바로 클립보드에 작품명이 복사되어 검색이나 기록에 붙여넣기 편하면 좋겠습니다!"
- **기획자 (PO)**: "`detail_modal.gd`에 `reset_purchase_date()`와 `DateStampBtn` 우클릭 초기화를 추가하고, `title_label` 클릭 시 클립보드 복사 및 복사 확인 툴팁 피드백을 `index.html`의 `#diary-title`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `reset_purchase_date()` 메서드를 추가해 `DateStampBtn` 우클릭 시 `purchase_date`를 `"📅 기념일"`로 초기화하고 `diary_updated` 시그널을 발행합니다.
  - `title_label`에 클릭 핸들러를 연결해 좌클릭 시 `current_item.title`을 클립보드에 복사하고 `✅ 복사됨: ...` 툴팁 피드백을 제공합니다.
- `game02/index.html`:
  - `#diary-title` 클릭 시 `copyDiaryTitle()` 클립보드 복사 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `DateStampBtn` 우클릭 초기화와 `title_label` 클릭 클립보드 복사를 검증하는 Sprint 127 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 126] 모달 `✕` 닫기 우클릭(닫기+즉시 JSON 백업) & 권별 `📅` 날짜 버튼 우클릭(해당 권 대사 복사)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달에서 여러 권의 밑줄과 스탬프를 수정한 뒤 상단 `✕` 닫기 버튼을 우클릭하면 모달이 닫히면서 동시에 `로컬 JSON 백업 저장`까지 한 번에 완료되면 정말 안심이 될 것 같아요."
- **가챠러 B**: "권별 로우의 `📅` 날짜 버튼을 우클릭했을 때 그 권에 적어둔 밑줄 대사만 클립보드에 한 줄로 복사되면 인용문 공유하기가 훨씬 간편해지겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`에 `close_and_backup_requested` 시그널을 신설해 `main_view.gd`의 `_trigger_instant_json_backup()`에 연결하고, 권별 `date_btn` 우클릭 시 해당 권 대사 클립보드 복사 및 `✅ 복사됨` 피드백을 구현해 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `close_and_backup_requested` 시그널을 추가해 `CloseBtn` 우클릭 시 모달을 닫고 즉시 로컬 JSON 백업 저장을 트리거합니다.
  - 권별 로우 `date_btn` 우클릭 시 해당 권의 밑줄 대사를 클립보드에 복사하고 `✅ 복사됨` 피드백과 툴팁을 제공합니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `detail_modal.close_and_backup_requested` 시그널을 `_trigger_instant_json_backup()`에 연결했습니다.
- `game02/index.html`:
  - 모달 `✕` 닫기 버튼에 `oncontextmenu="event.preventDefault(); closeJournalModal(); instantBackupArchive();"` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 권별 `date_btn` 우클릭 대사 복사와 `CloseBtn` 우클릭 닫기+JSON 백업을 검증하는 Sprint 126 통합 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 125] 마일스톤 125: 모달 4대 인장 우클릭(인장+감상카드 복사) & 권별 초판 배지 우클릭(초판+북마크 동시 토글)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 `StampRow`의 4개 인장 버튼(`전권완결`, `초판특전`, `인생최애`, `위시`)을 우클릭했을 때 인장을 찍는 동시에 감상 카드까지 바로 클립보드에 복사되면 인장 바꾸자마자 공유하기가 정말 편할 것 같아요!"
- **가챠러 B**: "권별 로우의 `🔖초판특전`/`✓소장완료` 배지도 우클릭 한 번으로 초판 여부와 `🔖` 북마크 리본을 동시에 토글하면 핵심 소장 권 표시가 한결 빨라지겠네요."
- **기획자 (PO)**: "`detail_modal.gd`에 `STAMP_PRESET_MAP` 상수를 도입해 인장 매핑 중복을 제거하고 우클릭(인장+감상카드 복사)을 연결하며, 권별 로우 `status_btn` 우클릭(초판+북마크 동시 토글)과 `index.html` 동기화까지 마일스톤 125로 완성합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `STAMP_PRESET_MAP` 상수로 4대 인장 매핑 중복을 제거하고, `StampComplete`, `StampFirst`, `StampFav`, `StampWish` 우클릭 시 `apply_stamp(st_name)` + `copy_book_quote_card()`를 실행하도록 연결했습니다.
  - 권별 로우 `status_btn` 우클릭 시 `toggle_volume_status(capture_idx)` + `toggle_volume_bookmark(capture_idx)` 동시 토글 및 툴팁을 추가했습니다.
- `game02/index.html`:
  - `data-stamp-btn` 4개 버튼 및 권별 초판/소장 배지에 `oncontextmenu` 우클릭 액션 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StampFav` 우클릭 인장+감상카드 복사와 권별 `status_btn` 우클릭 초판+북마크 동시 토글을 검증하는 Sprint 125 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 124] 모달 4대 잉크 스와치 우클릭(잉크+형광펜 동시 토글) & 권별 북마크 리본 우클릭 밑줄 편집

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 `✒️ 잉크:` 줄 앞의 4개 잉크 스와치(`에스프레소`, `버건디`, `세피아`, `포레스트`)를 우클릭했을 때 해당 잉크 색상을 적용하면서 동시에 형광펜 하이라이트까지 한 번에 켜거나 끄면 꾸미기 속도가 두 배는 빨라질 것 같아요."
- **미니멀러 C**: "권별 로우의 `🏷️`/`🔖` 북마크 리본 버튼도 우클릭하면 바로 그 권의 밑줄 문장 편집으로 들어가면 작은 리본에서도 편집 동선이 이어져 좋겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`에 `INK_SWATCH_MAP` 상수를 도입해 잉크 스와치 스타일링과 우클릭(잉크+형광펜 동시 토글)을 통합하고, 권별 로우 `bm_btn` 우클릭 시 `start_editing_volume_quote(capture_idx)`를 연결해 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `INK_SWATCH_MAP` 상수로 `InkEspresso`, `InkBurgundy`, `InkSepia`, `InkForest` 매핑 중복을 제거하고, 우클릭 시 `set_fountain_pen_ink(sw_hex)` + `toggle_quote_highlight()`를 함께 실행하도록 연결했습니다.
  - 권별 로우 `bm_btn`에 우클릭 시 `start_editing_volume_quote(capture_idx)` 호출과 툴팁 안내를 추가했습니다.
- `game02/index.html`:
  - 권별 북마크 리본 버튼에 `oncontextmenu="event.preventDefault(); startEditVolQuote(${idx});"` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `InkSepia` 우클릭 잉크+형광펜 동시 전환 및 권별 북마크 리본 우클릭 밑줄 편집 진입을 검증하는 Sprint 124 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 123] 모달 `AddVolBtn` 우클릭 권 추가+즉시 밑줄 편집 & `DeleteBtn` 우클릭 삭제 무장 안전 해제

### 1. 14인 스쿼드 회의록 & VOC
- **가챠러 B**: "`+ 다음 권 일기 추가` 버튼을 우클릭하면 새 권이 추가되자마자 바로 그 권의 밑줄 문장 편집 모드로 들어가면, 연속 기록할 때 마우스 클릭 수를 한 번 더 줄일 수 있을 것 같아요."
- **소장러 A**: "`일기 삭제` 버튼을 한 번 눌러 `⚠️ 정말 삭제?` 상태가 되었을 때, 우클릭 한 번으로 바로 삭제 확인 상태를 안전하게 해제할 수 있으면 실수 방지에 정말 좋을 것 같아요!"
- **기획자 (PO)**: "`detail_modal.gd`의 `AddVolBtn` 우클릭 시 `_on_add_vol_btn_pressed()` + `start_editing_volume_quote(last)`를, `DeleteBtn` 우클릭 시 `delete_armed = false` 안전 해제를 연결하고 `index.html`의 동일 버튼들에도 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `AddVolBtn` 우클릭 시 새 권 추가 후 즉시 마지막 권의 밑줄 편집 모드로 진입하도록 연결했습니다.
  - `DeleteBtn` 우클릭 시 `delete_armed` 무장 상태를 안전하게 해제하고 툴팁을 동기화했습니다.
- `game02/index.html`:
  - `+ 다음 권 기록 추가` 및 `이 일기 삭제` 버튼에 `oncontextmenu` 우클릭 액션 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `AddVolBtn` 우클릭 권 추가+편집 진입과 `DeleteBtn` 우클릭 무장 해제를 검증하는 Sprint 123 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 122] 모달 `밑줄 저장` 우클릭 원문 복원 & `형광펜` 우클릭 잉크색 순환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달에서 밑줄 문장을 수정하다가 원래 저장된 문장으로 되돌리고 싶을 때, `밑줄 저장` 버튼을 우클릭하면 바로 원문(`current_item.memo`)으로 복구되면 편할 것 같아요."
- **미니멀러 C**: "`형광펜` 버튼도 우클릭 시 만년필 잉크 색상을 바로 다음 색으로 넘겨줄 수 있으면 글 꾸미기 동선이 훨씬 짧아질 거예요!"
- **기획자 (PO)**: "`detail_modal.gd`의 `SaveQuoteBtn` 우클릭 시 `editing_vol_index` 해제 및 원문 복원을, `HighlightBtn` 우클릭 시 `cycle_fountain_pen_ink(1)` 호출과 툴팁 안내를 연결하고 `index.html`에도 `restoreDiaryQuoteInput()`을 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `SaveQuoteBtn` 우클릭 시 `quote_input.text`를 `current_item.memo` 원문으로 복원하고 권별 편집 상태를 해제합니다.
  - `HighlightBtn` 우클릭 시 `cycle_fountain_pen_ink(1)`을 호출해 잉크 색상을 순환하며 툴팁을 동기화했습니다.
- `game02/index.html`:
  - `🖋️ 밑줄 저장` 버튼에 `oncontextmenu` 기반 `restoreDiaryQuoteInput()` 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `SaveQuoteBtn` 우클릭 원문 복원과 `HighlightBtn` 우클릭 잉크색 변경을 검증하는 Sprint 122 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 121] 상단 5대 필터 탭 우클릭 가치순 보기 & 전체 초기화(`TabAll`) 원클릭 복원

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "필터 탭(`이북·단행본`, `가챠노트`, `완독작`, `인생작`)을 우클릭했을 때 해당 탭으로 이동하면서 동시에 소장 가치순(`↕ 가치순`) 정렬까지 한 번에 적용되면 고가 레어템부터 바로 볼 수 있어 정말 편할 것 같아요!"
- **가챠러 B**: "`가챠노트` 탭 우클릭 한 번으로 가챠 필터 + 가치순 정렬이 즉시 적용되니 두 번 클릭할 필요가 없어졌어요."
- **미니멀러 C**: "`전체일기` 탭(`TabAll`) 우클릭은 검색어·필터·정렬을 모두 기본값으로 되돌리는 완전 초기화로 맞추면 완벽하겠어요."
- **기획자 (PO)**: "`main_view.gd`의 5대 필터 탭에 `tab_rclick_map` 우클릭 핸들러(`TabAll` → `_reset_all_filters(); _set_sort_mode(0)`, 나머지 4탭 → 필터 후 `_set_sort_mode(3)`)와 툴팁을 연결하고 `index.html` 탭 버튼에도 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `TabAll` 우클릭 시 검색어·필터·정렬을 모두 기본값(`0`)으로 복원하고, `TabManga`/`TabGacha`/`TabComplete`/`TabFav` 우클릭 시 해당 필터 적용 후 즉시 `↕ 가치순` 정렬(`_set_sort_mode(3)`)을 적용하도록 연결했습니다.
  - 5개 탭 툴팁에 `· 우클릭: 완전 초기화` 및 `· 우클릭: 가치순 보기` 안내를 추가했습니다.
- `game02/index.html`:
  - 상단 5개 필터 탭 버튼에 `oncontextmenu` 우클릭 초기화/정렬 전환 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 5대 필터 탭 우클릭 가치순 정렬·완전 초기화 및 툴팁을 검증하는 Sprint 121 통합 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 120] 마일스톤 120: 상단 4대 통계 카드 우클릭 파워 액션 & 모달 `[Shift+C] 리포트` 치트시트 동기화

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "상단 4개 통계 카드(`서재 작품`, `단행본 기록`, `초판 스탬프`, `가챠 스크랩`)를 좌클릭하면 필터가 바뀌는데, 우클릭했을 때도 바로 전체 서재 리포트 복사, 이북 가치순 정렬, 서재 인포그래픽 브리핑, 즉시 JSON 백업 저장이 실행되면 대시보드가 정말 강력해질 것 같아요!"
- **가챠러 B**: "마일스톤 120 기념으로 모달 `H` 도움말 토스트에도 지난 스프린트에서 추가한 `Shift+C: 리포트` 안내를 함께 넣어주면 완벽하겠네요."
- **기획자 (PO)**: "`main_view.gd`에 `_set_sort_mode()` 공용 헬퍼와 `stat_configs` 매핑 테이블을 도입해 4개 통계 카드의 좌·우클릭 및 툴팁을 일관되게 연결하고, `index.html` 통계 카드 우클릭과 모달 `H` 도움말을 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `StatItems`(우클릭: 서재 리포트 복사), `StatVols`(우클릭: 이북 가치순 정렬 `_set_sort_mode(3)`), `StatFirsts`(우클릭: 서재 인포그래픽 요약), `StatGacha`(우클릭: 즉시 JSON 백업 저장) 4종 우클릭 파워 액션 및 툴팁을 `stat_configs` 테이블로 연결했습니다.
  - `_on_modal_help_requested()` 토스트에 `[C] 복사(Shift+C: 리포트)` 안내를 보강했습니다.
- `game02/index.html`:
  - 상단 `서재 작품`, `소장 단행본`, `초판 스탬프` 통계 카드에 `oncontextmenu` 우클릭 파워 액션 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 4대 통계 카드 우클릭 파워 액션 및 모달 `Shift+C` 도움말을 검증하는 Sprint 120 마일스톤 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 119] 모달 `💌 공유` 우클릭·`Shift+C` 전체 서재 리포트 복사 & 상단 마스킹 테이프 우클릭 역순환

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 안에서 현재 작품 감상 카드를 복사(`💌 공유` 좌클릭)하다가 전체 서재 통계 리포트도 바로 복사하고 싶을 때가 있는데, 모달을 닫지 않고 `💌 공유` 우클릭이나 `Shift+C` 한 번으로 복사되면 정말 편할 것 같아요."
- **가챠러 B**: "모달 표지 위 마스킹 테이프(`ModalWashiTape`)도 좌클릭으로 다음 색이 되니 우클릭으로 이전 색으로 돌아갈 수 있으면 좋겠어요!"
- **기획자 (PO)**: "`detail_modal.gd`에 `summary_copy_requested` 시그널을 신설해 `main_view.gd`의 `copy_summary_to_clipboard()`와 연결하고, `ShareCardBtn` 우클릭·`Shift+C` 및 `ModalWashiTape` 우클릭 역순환(`-1`)을 구현해 `index.html`과 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `summary_copy_requested` 시그널을 추가해 `ShareCardBtn` 우클릭(`MOUSE_BUTTON_RIGHT`) 및 모달 내 `Shift+C` 시 전체 서재 요약 리포트를 복사하도록 연결했습니다.
  - `ModalWashiTape` 우클릭 시 `cycle_washi_tape(-1)` 역순환과 양방향 툴팁을 추가했습니다.
- `game02/godot_project/scripts/main_view.gd`:
  - `detail_modal.summary_copy_requested` 시그널을 `copy_summary_to_clipboard()`에 연결했습니다.
- `game02/index.html`:
  - `💌 감상 카드 공유` 버튼에 `oncontextmenu` 기반 `copyLibrarySummaryReport()` 전체 서재 리포트 복사와 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `ShareCardBtn` 우클릭, `Shift+C`, `ModalWashiTape` 우클릭 역순환을 검증하는 Sprint 119 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 118] 메인·모달 `H` 단축키 치트시트 & 표지 커버 `Shift+Q/X` 툴팁 동기화

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달에서 `H` 키를 눌러 단축키 안내를 띄웠을 때, 지난 스프린트에서 완성된 `[Shift+순환키] 역순환` 규칙이 모달 도움말 토스트에도 함께 보이면 새 사용자도 바로 알 수 있을 것 같아요."
- **가챠러 B**: "모달 표지 커버(`CoverRect`) 툴팁에도 `Shift+X: 이전` / `Shift+Q: 이전` 안내가 함께 적혀 있으면 좋겠어요!"
- **미니멀러 C**: "메인 화면 `H` 키 도움말에도 `[Space] 책장 · [우클릭] 역순환·백업` 안내를 보강하고 `index.html`의 `H` 키 치트시트(`alert`)와 똑같이 맞춰주세요."
- **기획자 (PO)**: "`main_view.gd`의 메인/모달 `H` 치트시트 토스트와 `detail_modal.gd`의 `cover_rect.tooltip_text`, `index.html`의 `H` 키 안내를 모두 최신 양방향 조작 스펙에 맞춰 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - 메인 `KEY_H` 토스트에 `[Space] 책장 · [우클릭] 역순환·백업` 안내를, `_on_modal_help_requested()` 토스트에 `[Shift+순환키] 역순환` 안내를 추가했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `cover_rect.tooltip_text`에 `Shift+X: 이전` / `Shift+Q: 이전` 힌트를 추가했습니다.
- `game02/index.html`:
  - `H` 키 단축키 `alert`에 `[Shift+순환키] 역순환 · [우클릭] 역순환/백업/필터`를 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 메인·모달 `H` 치트시트 및 `CoverRect` 툴팁을 검증하는 Sprint 118 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 117] 모달 `Shift+I`/`Shift+Q`/`Shift+X` 역순환 추가 (모달 내 19/19 전 순환 단축키 양방향 완성)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 내 16종 순환 단축키는 `Shift+키`로 역순환되는데, `I`(만년필 잉크 색), `Q`(표지 색상), `X`(표지 아이콘 이모지) 3가지도 `Shift+I`, `Shift+Q`, `Shift+X`로 바로 이전 색·아이콘으로 돌아가면 좋겠어요!"
- **가챠러 B**: "표지 이모지나 색상이 프리셋이 여러 개라 넘기다 지나칠 때가 많은데, `Shift+Q`와 `Shift+X`로 바로 뒤로 갈 수 있어 정말 편합니다."
- **기획자 (PO)**: "`cycle_fountain_pen_ink(step)`, `cycle_cover_icon(step)`, `cycle_cover_color(step)`을 양방향화하고 `step_cyclers` 테이블(`KEY_I`, `KEY_Q`, `KEY_X`)에 편입해 모달 내 **19종 순환 단축키 전부**를 `Shift+키` 역순환(`-1`)으로 완성합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `cycle_fountain_pen_ink(step)`, `cycle_cover_icon(step)`, `cycle_cover_color(step)`을 양방향(`+1`/`-1`)으로 개선하고 `step_cyclers` 테이블(`KEY_I`, `KEY_Q`, `KEY_X`)로 통합했습니다.
- `game02/index.html`:
  - 모달 단축키 안내(`H` 키)에 `[Shift+순환키] 역순환` 안내를 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `Shift+I`, `Shift+Q`, `Shift+X` 역순환을 검증하는 Sprint 117 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 116] 모달 내 16종 순환 단축키 `Shift+키` 역순환(`-1`) 통합 & 웹 목업 동기화

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 안의 모든 순환 버튼이 마우스 우클릭 역순환을 지원하는데, 키보드로 `W`/`P`/`S`/`R`/`O`/`M`/`G`/`T`/`F`/`A`/`N`/`B`/`K`/`U`/`J`/`Z`를 누를 때도 `Shift+키`로 이전 프리셋으로 돌아갈 수 있으면 키보드·마우스 조작감이 완전히 같아질 것 같아요."
- **미니멀러 C**: "메인 화면과 모달 수치 증감(`Shift+V/D/Y`)처럼 모달 내 모든 순환 단축키에도 `Shift` 역순환 규칙을 통일합시다."
- **기획자 (PO)**: "`detail_modal.gd`의 `_unhandled_input`에 `step_cyclers` 16종 디스패치 테이블을 도입해 `event.shift_pressed` 시 `-1`을 전달하고, `index.html`의 `W`/`S`/`R` 모달 키 핸들러도 `e.shiftKey`와 동기화합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/detail_modal.gd`:
  - `KEY_W`, `KEY_P`, `KEY_S`, `KEY_R`, `KEY_O`, `KEY_M`, `KEY_G`, `KEY_T`, `KEY_F`, `KEY_A`, `KEY_N`, `KEY_B`, `KEY_K`, `KEY_U`, `KEY_J`, `KEY_Z` 16개 단축키를 `step_cyclers` 테이블로 분리해 `Shift` 조합 시 `-1` 역순환이 동작하도록 고도화했습니다.
- `game02/index.html`:
  - 모달 내 `R`/`S`/`W` 키 입력 시 `e.shiftKey ? -1 : 1`을 전달하도록 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `Shift+W`, `Shift+R`, `Shift+M`, `Shift+F`, `Shift+Z` 역순환을 검증하는 Sprint 116 통합 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 115] 마일스톤 115: 모달 `InkRow` 8종 순환 버튼 우클릭 역순환 완성 (`StampRow`+`InkRow` 전 버튼 양방향화 달성)

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "`StampRow`의 버튼들이 전부 우클릭 역순환이 되니 아래쪽 `✒️ 잉크:` 줄(`InkRow`)의 `펜촉`·`서명`·`해시태그`·`최애 캐릭터`·`컨디션`·`코팅`·`날씨`·`장소`도 우클릭으로 뒤로 돌아가면 모달 전체가 완벽하게 통일될 것 같아요!"
- **가챠러 B**: "`S급(최상)` · `무광 매트` · `맑은 오후` · `이불 속`처럼 옵션이 여러 개인 버튼들을 지나쳤을 때 우클릭 한 번으로 바로 되돌릴 수 있어 쾌적합니다."
- **기획자 (PO)**: "`collection_item.gd`의 `_step_preset()` 공용 헬퍼를 재사용해 `InkRow` 7종 프리셋 메서드에 `step: int = 1`을 적용하고, `detail_modal.gd`에서 `cycle_pen_nib_size(step)`까지 포함해 `InkRow` 8개 버튼 전체에 우클릭 역순환(`-1`)과 `· 우클릭: 이전` 툴팁을 완성했습니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/collection_item.gd`:
  - `cycle_diary_signature(step)`, `cycle_custom_tag(step)`, `cycle_favorite_character(step)`, `cycle_condition_grade(step)`, `cycle_cover_finish(step)`, `cycle_reading_weather(step)`, `cycle_reading_spot(step)` 7개 메서드에 `_step_preset()` 기반 `+1`/`-1` 양방향 순환을 적용했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `cycle_pen_nib_size(step)`을 `[10, 12, 14]` 양방향 순환으로 개선하고, `NibBtn`, `SignatureBtn`, `CustomTagBtn`, `FavCharBtn`, `ConditionBtn`, `FinishBtn`, `WeatherBtn`, `SpotBtn` 8개 버튼에 `MOUSE_BUTTON_RIGHT` 역순환(`-1`)과 툴팁을 연결했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `InkRow` 8개 버튼의 우클릭 역순환 및 툴팁을 검증하는 Sprint 115 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 114] `StampRow` 보관위치·입수경로·기분·소장상태 4종 우클릭 역순환 완성

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 `StampRow` 앞쪽 다꾸 5종(`띠지`/`마테`/`스티커`/`레어도`/`속지`)에 이어 나머지 순환 버튼(`보관위치`/`입수경로`/`기분`/`소장상태`)도 우클릭으로 뒤로 돌아가면 조작감이 완벽히 통일될 것 같아요."
- **가챠러 B**: "`소장중 → 예약중 → 배송중 → 전시중`이나 보관 장소를 넘기다 지나쳤을 때 우클릭 한 번으로 바로 되돌릴 수 있으면 편하겠어요."
- **기획자 (PO)**: "`collection_item.gd`의 `_step_preset()` 공용 헬퍼를 재사용해 `cycle_storage_location(step)`, `cycle_acquisition_source(step)`, `cycle_reading_mood(step)`, `cycle_possession_state(step)`를 양방향화하고, `detail_modal.gd`와 `index.html`에 우클릭 역순환 및 툴팁을 연결합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/collection_item.gd`:
  - `cycle_storage_location(step)`, `cycle_acquisition_source(step)`, `cycle_reading_mood(step)`, `cycle_possession_state(step)`에 `_step_preset()` 공용 헬퍼를 적용해 `+1`/`-1` 양방향 순환을 지원했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `StorageBtn`, `SourceBtn`, `MoodBtn`, `PossessionBtn` 4개 버튼에 `MOUSE_BUTTON_RIGHT` 역순환(`-1`)과 `(B)/(A)/(M)/(Z) · 우클릭: 이전` 툴팁을 연결해 `StampRow` 전체 순환 버튼의 양방향 조작을 완성했습니다.
- `game02/index.html`:
  - `source-cycle-btn`, `mood-cycle-btn`에 `step = 1` 지원과 `oncontextmenu` 우클릭 역순환(`-1`) 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `StorageBtn`, `SourceBtn`, `MoodBtn`, `PossessionBtn` 우클릭 역순환 및 툴팁을 검증하는 Sprint 114 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 113] 모달 다꾸 꾸미기 5대 버튼(`띠지`/`마테`/`스티커`/`레어도`/`속지`) 우클릭 역순환 & 툴팁 동기화

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "모달 안에서 `띠지`, `테이프`, `스티커`, `레어도`, `속지` 버튼을 누르다가 원하는 스타일을 지나쳤을 때 우클릭 한 번으로 바로 이전 프리셋으로 되돌아갈 수 있으면 정말 쾌적할 것 같아요."
- **가챠러 B**: "웹 목업(`index.html`)의 마테·스티커·레어도 버튼도 똑같이 우클릭으로 역순환되면 손에 익은 조작감이 그대로 이어질 것 같아요."
- **기획자 (PO)**: "`collection_item.gd`에 `_step_preset()` 공용 헬퍼와 `step: int = 1` 매개변수를 도입해 `cycle_deco_sticker`, `cycle_rarity_tier`, `cycle_paper_pattern`을 양방향화하고, `detail_modal.gd`에서 `ObiCycleBtn`, `TapeCycleBtn`, `DecoStickerBtn`, `RarityBtn`, `PaperBtn` 5개 버튼에 우클릭 역순환(`-1`)과 `(O)/(W)/(S)/(R)/(P) · 우클릭: 이전` 툴팁을 일괄 연결합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/collection_item.gd`:
  - `_step_preset()` 헬퍼를 추가해 `cycle_deco_sticker(step)`, `cycle_rarity_tier(step)`, `cycle_paper_pattern(step)`이 양방향(`+1`/`-1`)으로 동작하도록 개선했습니다.
- `game02/godot_project/scripts/detail_modal.gd`:
  - `cycle_obi_preset(step)`, `cycle_washi_tape(step)`, `cycle_deco_sticker(step)`, `cycle_rarity_tier(step)`, `cycle_paper_pattern(step)`을 양방향화하고, 5개 버튼(`ObiCycleBtn`, `TapeCycleBtn`, `DecoStickerBtn`, `RarityBtn`, `PaperBtn`)에 `MOUSE_BUTTON_RIGHT` 역순환(`-1`) 및 툴팁을 연결했습니다.
- `game02/index.html`:
  - `tape-cycle-btn`, `deco-sticker-btn`, `rarity-cycle-btn`에 `step = 1` 지원과 `oncontextmenu` 우클릭 역순환(`-1`) 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - 모달 다꾸 꾸미기 5개 버튼 우클릭 역순환 및 툴팁을 검증하는 Sprint 113 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 112] 하단 독 바(`WebBtn`/`CamBtn`/`DiyBtn`) 우클릭 파워 액션 & 즉시 JSON 백업 헬퍼 통합

### 1. 14인 스쿼드 회의록 & VOC
- **소장러 A**: "하단 `📔 속지 테마` 버튼은 이미 우클릭으로 역순환(`Shift+T`)이 되는데, `🖋️ 새 일기 쓰기` 버튼(`DiyBtn`)도 상단 `+ 일기 쓰기`처럼 우클릭 시 즉시 JSON 백업 저장이 되도록 통일하면 편하겠어요."
- **가챠러 B**: "하단 `🌐 웹표지 스크랩`(`WebBtn`) 우클릭 시 이북·단행본 필터로, `📷 폴라로이드 촬영`(`CamBtn`) 우클릭 시 가챠노트 필터로 바로 이동하면 방금 찍은 아이템들을 모아보기 정말 좋을 것 같아요."
- **기획자 (PO)**: "상단과 하단 `AddBtn`/`DiyBtn`의 백업 로직을 `_trigger_instant_json_backup()` 공용 헬퍼로 추출해 중복을 제거하고, 하단 `NavRow` 4개 버튼(`WebBtn`, `CamBtn`, `DiyBtn`, `ThemeBtn`) 모두에 좌클릭 생성/전환 + 우클릭 파워 액션(이북 필터·가챠 필터·즉시 JSON 백업·테마 역순환)과 툴팁을 완성합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `_trigger_instant_json_backup()` 공용 헬퍼를 신설해 상단 `TitleRow/AddBtn`과 하단 `NavRow/DiyBtn` 우클릭 시 동일하게 `archive_state.save_to_file()` 및 `💾 로컬 JSON 서재 백업 저장 완료 (N종 · ₩총액)` 토스트를 출력합니다.
  - 하단 `NavRow` 4개 버튼에 우클릭 콜백 테이블(`_on_tab_manga_pressed`, `_on_tab_gacha_pressed`, `_trigger_instant_json_backup`, `_step_theme(-1)`)과 상세 툴팁을 연결했습니다.
- `game02/index.html`:
  - 상단 `웹 표지 찾기` / `표지/가챠 찍기` 버튼에 `oncontextmenu` 기반 `setFilter('manga')` / `setFilter('gacha')` 우클릭 필터 점프 및 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `WebBtn`, `CamBtn`, `DiyBtn` 우클릭 시 필터 전환(`0`/`1`)과 JSON 백업 저장 토스트 및 툴팁을 검증하는 Sprint 112 통합 테스트를 추가해 100% 통과했습니다.

---

## 📓 [Sprint 111] 전체 초기화(`0`) KRW 자산 요약 토스트 통일 & `+ 일기 쓰기` 우클릭 즉시 JSON 백업 저장

### 1. 14인 스쿼드 회의록 & VOC
- **다꾸러 A**: "필터 전체 초기화(`0` 키나 초기화 버튼)를 눌렀을 때만 다른 탭들처럼 총 권수와 ₩ 자산 합계가 같이 안 떠서 살짝 아쉬웠어요."
- **수집러 B**: "새 일기 쓰기 버튼 옆에 따로 저장 버튼은 없지만, 가끔 대량 기록 후 우클릭 한 번으로 즉시 로컬 JSON 백업이 저장되었다는 확신을 얻고 싶어요."
- **기획자 (PO)**: "`_reset_all_filters()` 토스트에 `_get_filtered_cards_summary()`를 결합해 KRW 요약을 통일하고, 상단 `TitleRow/AddBtn`에 `MOUSE_BUTTON_RIGHT` 즉시 `save_to_file()` + ₩ 요약 토스트와 툴팁 힌트를 부여합니다."

### 2. 핵심 구현 및 변경 내역
- `game02/godot_project/scripts/main_view.gd`:
  - `_reset_all_filters()` 토스트를 `"📚 전체 서재가 복원되었습니다. (%s)" % _get_filtered_cards_summary()`로 업데이트해 모든 탭·검색·초기화 피드백의 ₩ 자산 요약 포맷을 통일했습니다.
  - `TitleRow/AddBtn`에 `MOUSE_BUTTON_RIGHT` 이벤트를 연결해 우클릭 시 `archive_state.save_to_file()`을 즉시 호출하고 `"💾 로컬 JSON 서재 백업 저장 완료 (%s)" % _get_filtered_cards_summary()` 토스트를 출력하며, 툴팁에 `(우클릭: 즉시 JSON 저장)` 안내를 추가했습니다.
- `game02/index.html`:
  - 상단 `+ 새 일기 쓰기` 버튼에 `oncontextmenu` 기반 `instantBackupArchive()` 즉시 로컬 백업 피드백 및 동일 툴팁을 동기화했습니다.
- `game02/godot_project/tests/test_main_integration.gd`:
  - `_reset_all_filters()` 토스트 `₩` 포함 여부와 `TitleRow/AddBtn` 우클릭 시 JSON 백업 저장 토스트·툴팁을 검증하는 Sprint 111 통합 테스트를 추가해 100% 통과했습니다.

---

## 🏆 [Sprint 110] 마일스톤 110: 모달 `◀`/`▶` 우클릭 첫·끝 페이지 즉시 점프 & 양방향 툴팁 동기화
- **날짜/시각**: 2026-11-18 12:57 (자동 스프린트 #110)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 상단 `◀` `▶` 버튼을 좌클릭하면 한 권씩 넘어가는데, 우클릭했을 때 바로 첫 번째 일기장(`◀`)이나 마지막 일기장(`▶`)으로 한 번에 점프할 수 있으면 마우스만으로도 `Home`/`End`처럼 빠르게 이동할 수 있을 것 같아요."*
  - **가챠러 B**: *"모달 상단 `◀` `▶` 버튼 툴팁에도 `(우클릭: 처음)` / `(우클릭: 끝)` 안내가 함께 표시되면 마우스 조작성을 바로 알 수 있을 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 상단 `◀` `▶` 버튼 우클릭(`oncontextmenu`) 시 첫 번째·마지막 작품으로 즉시 점프하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 `◀`/`▶` 우클릭 첫·끝 페이지 즉시 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `PrevItemBtn` 우클릭 시 `navigate_requested.emit(-9999)`(첫 페이지), `NextItemBtn` 우클릭 시 `navigate_requested.emit(9999)`(마지막 페이지) 실행(웹 목업 포함).
  2. **동적 내비게이션 툴팁 동기화 (`main_view.gd` · `index.html`)**: `_update_modal_nav_tooltips()`에서 `◀`/`▶` 툴팁에 `(← · 우클릭: 처음)`, `(→ · 우클릭: 끝)` 안내 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Sprint 110 Milestone: Right-Click PrevItemBtn/NextItemBtn First/Last Page Jump` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 109] `TodayQuoteLabel` 우클릭 다음·이전 밑줄 전환 & `AddModal` 작가란 `Enter` 즉시 등록
- **날짜/시각**: 2026-11-18 07:29 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"상단 `오늘의 밑줄` 문장 텍스트를 우클릭했을 때도 바로 다음 밑줄 문장(`Shift+우클릭` 시 이전 문장)으로 넘어가면 마우스를 `↻ 문장` 버튼까지 안 옮겨도 돼서 훨씬 편할 것 같아요."*
  - **가챠러 B**: *"`+ 일기 쓰기` 모달에서 제목 입력 후 `Enter`로 작가란으로 넘어간 뒤, 작가만 입력하고 바로 `Enter`를 쳐도 새 일기가 즉시 등록되면 1초 기록이 가능할 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)의 `#today-quote-banner` 툴팁에도 `우클릭: 다음 밑줄` 안내가 함께 표시되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **`TodayQuoteLabel` 우클릭·`Shift+우클릭` 문장 순환 (`main_view.gd` · `index.html`)**: 오늘의 밑줄 라벨 좌클릭(일기장 펼치기) + 우클릭(`_step_today_quote(1)`, `Shift+우클릭` 시 `-1`) 지원 및 툴팁 동기화.
  2. **`AddModal` 작가 입력란 `Enter` 즉시 등록 (`add_modal.gd`)**: `author_input.text_submitted` 시 `_on_submit_btn_pressed()`를 연결해 제목+작가 입력만으로 즉시 등록 가능.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Right-Click TodayQuoteLabel Step & AddModal Author Enter-to-Submit` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 108] 책등(Spine) 우클릭 상세 미리보기 & 상단 요약줄(`SubTitle`) 우클릭 클립보드 복사
- **날짜/시각**: 2026-11-18 07:09 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"상단 책등(Spine) 배너에서 책등을 우클릭했을 때 모달을 열지 않고도 해당 작품의 권수·완독률·소장 가치(`₩`)를 토스트로 바로 미리보기할 수 있으면 책등 훑어보기가 더 재미있을 것 같아요."*
  - **가챠러 B**: *"상단 요약줄(`SubTitle`)을 좌클릭하면 인포그래픽이 뜨는데, 우클릭하면 바로 전체 서재 요약 리포트가 클립보드에 복사되면 마우스 한 번으로 통계 확인과 공유 복사를 모두 할 수 있을 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 상단 오늘의 밑줄 배너 우클릭 시 다음 문장으로 빠르게 전환되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **책등(Spine) 우클릭 상세 미리보기 (`main_view.gd`)**: `_render_spine_shelf()`에서 책등 우클릭 시 모달을 열지 않고 `"📚 책등 상세 미리보기: 「제목」 · N권 · N% · ₩가치"` 토스트 표시.
  2. **상단 `SubTitle` 우클릭 클립보드 복사 (`main_view.gd` · `index.html`)**: `SubTitle` 좌클릭(인포그래픽) + 우클릭(`copy_summary_to_clipboard()`) 양방향 인터랙션 지원 및 웹 목업 `#today-quote-banner` 우클릭 문장 전환 동기화.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Right-Click Spine Peek & Right-Click SubTitle Clipboard Copy` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 107] `Shift+R`·우클릭 랜덤 추천 모달 미개봉 미리보기(`엿보기`) & 메인 치트시트 동기화
- **날짜/시각**: 2026-11-18 06:49 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"메인 화면에서 `🎲 추천` 버튼을 눌렀을 때 바로 모달을 열기 전에, 우클릭이나 `Shift+R`로 추천 작품의 제목·날씨·장소·소장 가치(`₩`)만 하단 토스트로 가볍게 미리보기할 수 있으면 오늘 뭐 읽을지 고를 때 훨씬 부담 없을 것 같아요."*
  - **가챠러 B**: *"메인 화면 `H` 단축키 치트시트에도 최근 추가된 `[S/T/M/Q] 순환(Shift+역순)`과 `[R] 추천(Shift+미리보기)`이 한눈에 정리되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 `🎲 랜덤 추천` 우클릭(`oncontextmenu`) 및 `Shift+R` 시 상단 배너에 추천 미리보기가 표시되고 `Shift+M`으로 이전 백색소음으로 돌아가도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **`Shift+R` & `🎲 추천` 우클릭 미리보기 (`main_view.gd` · `index.html`)**: `pick_random_item(open_modal: bool = true)`를 확장해 `Shift+R`·우클릭 시 모달을 열지 않고 추천 작품 제목·날씨·장소·`₩` 가치를 토스트로 안내(웹 목업 `peekRandomItem()` 동기화 포함).
  2. **메인 단축키 `H` 치트시트 & 툴팁 동기화 (`main_view.gd`)**: `RandomPickBtn` 툴팁에 `(우클릭·Shift+R: 미리보기)` 추가 및 `H` 치트시트에 `Shift` 역순환·미리보기 안내 반영.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Shift+R / Right-Click Random Pick Peek Without Opening Modal` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 106] 메인 서재 정렬(`S`)·테마(`T`)·백색소음(`M`) `Shift`·우클릭 양방향 역순환 완성
- **날짜/시각**: 2026-11-18 06:30 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"메인 화면에서 `🎨 속지 테마`나 `🔇 무음(백색소음)` 버튼을 넘기다가 방금 전 테마나 사운드로 되돌아가고 싶을 때, 우클릭이나 `Shift+T`·`Shift+M`으로 바로 이전 프리셋으로 돌아갈 수 있으면 좋겠어요."*
  - **가챠러 B**: *"정렬 버튼(`↕ 기본순`)도 우클릭이나 `Shift+S` 키로 역순환할 수 있으면 4가지 정렬 모드를 오갈 때 훨씬 편할 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 상단 백색소음 버튼 우클릭(`oncontextmenu`) 시 이전 소음 프리셋으로 되돌아가도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **메인 서재 정렬·테마·백색소음 양방향 순환 (`main_view.gd` · `index.html`)**: `_step_sort(delta)`, `_step_theme(delta)`, `cycle_ambient_sound(delta)` 공용 헬퍼를 도입해 `SortBtn`, `ThemeBtn`, `AmbientBtn` 우클릭 및 `Shift+S`/`Shift+T`/`Shift+M` 역순환 지원(웹 목업 포함).
  2. **버튼 툴팁 힌트 동기화 (`main_view.gd` · `index.html`)**: `SortBtn`, `AmbientBtn`, `ThemeBtn` 툴팁에 `(우클릭·Shift+키: 이전)` 안내 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Shift+S/T/M & Right-Click Reverse Cycle for Sort, Theme & Ambient Sound` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 105] `Shift+Q`·우클릭 이전 밑줄 문장 되돌리기 & 권 추가·삭제 KRW 가치 토스트
- **날짜/시각**: 2026-11-18 06:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"상단 `↻ 문장` 버튼을 누르다가 방금 지나친 명대사를 다시 보고 싶을 때, `Shift+Q`나 버튼 우클릭으로 바로 이전 밑줄 문장으로 되돌아갈 수 있으면 정말 편할 것 같아요."*
  - **가챠러 B**: *"모달에서 `+ 다음 권 일기 추가`나 `- 권 삭제`를 눌렀을 때도 토스트에 해당 작품의 업데이트된 권수와 소장 가치(`₩`)가 함께 표시되면 자산 변화를 체감하기 쉬울 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)의 `↻ 다른 문장` 버튼에서도 우클릭(`oncontextmenu`) 시 이전 밑줄 문장으로 되돌아가도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **`Shift+Q` & `↻ 문장` 우클릭 이전 밑줄 문장 되돌리기 (`main_view.gd` · `index.html`)**: `_step_today_quote(delta)` 공용 헬퍼를 추가해 `Q`/좌클릭(+1)과 `Shift+Q`/우클릭(-1) 양방향 문장 탐색 지원(웹 목업 포함).
  2. **권 추가·삭제 KRW 가치 요약 토스트 (`main_view.gd`)**: `_on_volume_added()` 및 `_on_volume_removed()` 토스트에 작품의 권수와 원화 가치(`₩`)를 함께 안내.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Shift+Q / Right-Click Prev Quote & Vol Add/Remove KRW Toasts` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 104] 웹 스크랩·카메라 촬영·삭제 KRW 서재 요약 토스트 & `↻ 문장` 버튼 `(n/N)` 툴팁 동기화
- **날짜/시각**: 2026-11-18 05:48 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"메인 화면에서 `웹표지 스크랩`, `폴라로이드 촬영`, 그리고 `일기 삭제` 직후 토스트에도 현재 갱신된 전체 서재의 `N종 · ₩총액` 요약이 함께 표시되면 모든 추가·삭제 동작의 피드백 포맷이 통일될 것 같아요."*
  - **가챠러 B**: *"상단 `↻ 문장` 버튼(`NextQuoteBtn`)에 마우스를 올렸을 때도 현재 몇 번째 밑줄 문장인지 `(1/N)` 순번이 함께 보이면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)의 `↻ 다른 문장` 버튼 툴팁에도 `[Q]` 단축키 안내와 `(n/N)` 순번이 실시간으로 동기화되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **웹 스크랩·카메라 촬영·삭제 KRW 요약 토스트 통일 (`main_view.gd`)**: `_on_web_scrape_btn_pressed()`, `_on_camera_snap_btn_pressed()`, `_on_item_deleted()` 호출 시 `_get_filtered_cards_summary()`를 활용해 `N종 · ₩총액` 요약을 토스트로 안내.
  2. **`NextQuoteBtn` `(n/N)` 순번 툴팁 동기화 (`main_view.gd` · `index.html`)**: `_apply_today_quote()` 및 `cycleTodayQuote()`에서 `next_quote_btn` 툴팁에 `[Q]` 힌트와 현재 문장 순번 `(%d/%d)` 실시간 표시.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Web Scrape / Camera Snap / Delete Library Summary Toasts & NextQuoteBtn Index Tooltip` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 103] 오늘의 밑줄 순번(`(n/N)`) 툴팁 & 새 일기 등록·우클릭 빠른 기록 KRW 요약 토스트
- **날짜/시각**: 2026-11-18 05:29 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"상단 `오늘의 밑줄` 문장에 마우스를 올렸을 때 현재 몇 번째 명대사인지 `(1/12)`처럼 툴팁에 함께 보이면 문장 순환 버튼을 누를 때 현재 위치가 잘 보일 것 같아요."*
  - **가챠러 B**: *"서재 카드 우클릭 `+1권 빠른 기록`이나 새 일기 등록(`+ 일기 쓰기`) 완료 직후 토스트에도 해당 작품 가치나 업데이트된 전체 서재 `N종 · ₩총액`이 같이 뜨면 수집 현황 파악이 훨씬 쉬울 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)의 오늘의 밑줄 배너 툴팁에도 동일하게 `(n/N)` 순번이 표시되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **오늘의 밑줄 `(n/N)` 툴팁 동기화 (`main_view.gd` · `index.html`)**: `_apply_today_quote(entry, total_count)`에서 `today_quote_label.tooltip_text`에 `(%d/%d)` 순번 표시(웹 목업 포함).
  2. **새 일기 등록 & 우클릭 빠른 기록 KRW 요약 토스트 (`main_view.gd`)**: `_on_item_submitted()` 토스트에 서재 총합(`N종 · ₩총액`) 추가 및 `_on_card_quick_advanced()` 토스트에 작품 소장 가치(`₩`) 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Quote Index Tooltip, Quick-Advance KRW Toast & Submit Library Summary Toast` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 102] E-Book `Space`/`PageUp`/`PageDown` 책장 넘김 & 검색창 `ESC` 초기화 건수·자산 요약 토스트
- **날짜/시각**: 2026-11-18 05:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달을 열었을 때 실제 E-Book 리더기(리디북스·Apple Books)처럼 `Space` / `PageDown` 키로 다음 책장, `Shift+Space` / `PageUp` 키로 이전 책장을 넘길 수 있으면 한 손으로 넘기기가 훨씬 편할 것 같아요."*
  - **가챠러 B**: *"검색창에서 `ESC` 키로 검색어를 지웠을 때도 다른 필터 탭처럼 전체 서재의 `N종 · ₩총액` 요약을 토스트로 보여주면 통일감이 완성될 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `Space` / `PageUp` / `PageDown` 책장 넘김이 배경 스크롤 없이 매끄럽게 동작하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **E-Book `Space`/`PageUp`/`PageDown` 책장 넘김 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `quote_input` 비포커스 상태에서 `Space`/`PageDown` 입력 시 다음 페이지, `Shift+Space`/`PageUp` 입력 시 이전 페이지로 이동(웹 목업 배경 스크롤 방지 포함).
  2. **검색창 `ESC` 초기화 건수·자산 요약 토스트 (`main_view.gd`)**: 검색창에서 `ESC` 초기화 시 `_get_filtered_cards_summary()`를 활용해 `"🔍 검색어 초기화 (N종 · ₩총액)"` 토스트 출력.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `E-Book Space/PageUp/PageDown Navigation & Search Escape Value Summary` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 101] 모달 내 `X` 키 표지 이모지 아이콘 순환 & `Delete`/`Backspace` 2단계 삭제 안전 트리거
- **날짜/시각**: 2026-11-18 04:49 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `Q` 키로 표지 색상을 바꾸는 것처럼 `X` 키로 표지 이모지 아이콘(`🏀`, `🪄`, `🐱`, `🏐`, `🌸`, `🌙` 등)도 바로 순환할 수 있으면 표지 커스터마이징이 완전히 키보드 지원될 것 같아요."*
  - **가챠러 B**: *"`Delete`나 `Backspace` 키를 눌렀을 때도 마우스 클릭과 동일하게 1차 `⚠️ 삭제 확인` → `ESC` 안전 해제 또는 2차 삭제 확정이 되면 일기장 정리할 때 편리할 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `X` 키를 누르면 표지 아이콘이 순환되고 서재 카드에도 즉시 반영되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `X` 표지 아이콘 순환 & `Delete`/`Backspace` 2단계 삭제 (`detail_modal.gd` · `index.html`)**: `simple_actions` 디스패치 테이블에 `KEY_X: cycle_cover_icon`, `KEY_DELETE`/`KEY_BACKSPACE: _on_delete_btn_pressed` 추가(웹 목업 `X` 동기화 포함).
  2. **툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `CoverRect` 툴팁에 `좌클릭·X` / `우클릭·Q` 힌트 반영 및 `H` 치트시트 토스트에 `[X] 아이콘 · [Del] 삭제` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard X Cover Icon & Delete Key Two-Step Safety` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🏆 [Sprint 100] 대망의 마일스톤 100: 모달 `Q`/`Y`/`Z` 키보드 완결 & 23종 단축키 디스패치 테이블 리팩토링
- **날짜/시각**: 2026-11-18 04:29 (자동 스프린트 #100)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"100회 스프린트를 맞아 모달 안의 남은 요소인 `표지 색상(Q)`, `재독 횟수(Y / Shift+Y)`, `소장 상태(Z)`까지 키보드 단축키로 완성하면 모달 내 모든 버튼 100% 키보드 조작이 달성될 것 같아요!"*
  - **가챠러 B**: *"`RereadBtn`과 `PossessionBtn` 툴팁에도 `(Y / Shift+Y)`, `(Z)` 단축키 힌트가 보이고 `H` 치트시트에서 한눈에 확인하고 싶어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `Q`(표지 색상), `Y`(회독 ±1), `Z`(소장 상태)가 동일하게 동작하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 `Q` 표지 색상 · `Y`/`Shift+Y` 재독 ±1 · `Z` 소장 상태 순환 (`detail_modal.gd` · `index.html`)**: 모달 내 모든 다꾸·수집 메타데이터 버튼 100% 키보드 단축키 지원 완성(웹 목업 포함).
  2. **단일 딕셔너리 디스패치 테이블 리팩토링 (`detail_modal.gd`)**: 85줄에 달하던 `_unhandled_input` 분기문을 `simple_actions` 및 `shift_pairs` 디스패치 테이블로 통합해 중복을 제거하고 유지보수성을 극대화.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Sprint 100 Milestone: In-Modal Keyboard Q/Y/Z & Dispatch Table Refactor` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 99] 모달 내 `U` 키 독서 날씨 스탬프 순환 & `J` 키 독서 장소 스탬프 순환
- **날짜/시각**: 2026-11-18 04:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `U` 키로 독서·수집 날씨(`맑은 오후`·`비 오는 밤` 등)를 바꾸고 `J` 키로 독서 장소(`이불 속`·`카페 창가` 등)를 순환할 수 있으면 다꾸 스탬프 풀세트가 100% 키보드로 완성될 것 같아요."*
  - **가챠러 B**: *"`WeatherBtn`과 `SpotBtn` 툴팁에도 각각 `(U)`, `(J)` 단축키 힌트가 보이고 `H` 치트시트에 함께 안내되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `U`와 `J` 키 입력 시 날씨·장소 스탬프가 순환되도록 동기화해주세요."*
- **주요 개선 사항**:
  1. **모달 내 `U` 독서 날씨 & `J` 독서 장소 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `U` 입력 시 `cycle_reading_weather()`, `J` 입력 시 `cycle_reading_spot()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `WeatherBtn` `(U)`, `SpotBtn` `(J)` 툴팁 반영 및 `H` 치트시트 토스트에 `[U] 날씨 · [J] 장소` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard U Reading Weather & J Reading Spot Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 98] 모달 내 `D`/`Shift+D` 복수 소장 ±1 & `K` 키 최애 캐릭터 태그 순환
- **날짜/시각**: 2026-11-18 03:48 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `D` 키로 복수 소장 수량을 +1 (`Shift+D`로 -1) 올리고 내릴 수 있으면 소장용/열람용 세트를 키보드만으로 바로 기록할 수 있어서 정말 편할 것 같아요."*
  - **가챠러 B**: *"최애 캐릭터 태그(`FavCharBtn`)도 `K` 키로 즉시 순환할 수 있고 버튼 툴팁에도 `(D)` / `(K)` 힌트가 함께 표시되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `D`/`Shift+D` 복수 소장 수량 조정과 `K` 최애 캐릭터 순환이 동일하게 동작하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `D`/`Shift+D` 복수 소장 & `K` 최애캐 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `D` 입력 시 `increment_duplicate_count()`(`Shift+D`는 `decrement_duplicate_count()`), `K` 입력 시 `cycle_favorite_character()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `DuplicateBtn` `(D / Shift+D)`, `FavCharBtn` `(K)` 툴팁 반영 및 `H` 치트시트 토스트에 `[D] 복수 · [K] 최애캐` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard D/Shift+D Duplicate & K Favorite Character Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 97] 모달 내 `N` 키 만년필 펜촉 굵기 순환 & `B` 키 실물 보관 위치 순환
- **날짜/시각**: 2026-11-18 03:28 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `N` 키로 만년필 펜촉 굵기(`EF·M·B`)를 바꾸고 `B` 키로 실물 보관 위치(`1층 장식장` 등)를 순환할 수 있으면 필기감과 서재 위치 정리까지 키보드만으로 완성될 것 같아요."*
  - **가챠러 B**: *"`NibBtn`과 `StorageBtn` 툴팁에도 각각 `(N)`, `(B)` 단축키 힌트가 보이고 `H` 치트시트에 함께 안내되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `N`과 `B` 키 입력 시 펜촉 크기·보관 위치가 순환되도록 동기화해주세요."*
- **주요 개선 사항**:
  1. **모달 내 `N` 펜촉 굵기 & `B` 보관 위치 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `N` 입력 시 `cycle_pen_nib_size()`, `B` 입력 시 `cycle_storage_location()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `NibBtn` `(N)`, `StorageBtn` `(B)` 툴팁 반영 및 `H` 치트시트 토스트에 `[N] 펜촉 · [B] 보관` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard N Pen Nib & B Storage Location Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 96] 모달 내 `F` 키 표지 코팅 마감 순환 & `A` 키 소장·입수 경로 순환
- **날짜/시각**: 2026-11-18 03:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `F` 키로 표지 코팅 마감(`무광·유광·홀로그램·양장`)을 바꾸고 `A` 키로 소장·입수 경로(`오프라인 서점·온라인·가챠샵` 등)를 순환할 수 있으면 책 질감과 입수 경로까지 키보드로 완성할 수 있을 것 같아요."*
  - **가챠러 B**: *"`FinishBtn`과 `SourceBtn` 툴팁에도 각각 `(F)`, `(A)` 단축키 힌트가 보이고 `H` 치트시트에 함께 안내되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `F`와 `A` 키 입력 시 표지 마감·입수 경로가 순환되도록 동기화해주세요."*
- **주요 개선 사항**:
  1. **모달 내 `F` 표지 마감 & `A` 입수 경로 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `F` 입력 시 `cycle_cover_finish()`, `A` 입력 시 `cycle_acquisition_source()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `FinishBtn` `(F)`, `SourceBtn` `(A)` 툴팁 반영 및 `H` 치트시트 토스트에 `[F] 마감 · [A] 경로` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard F Cover Finish & A Acquisition Source Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 95] 모달 내 `G` 키 실물 컨디션 등급 순환 & `T` 키 커스텀 해시태그 순환
- **날짜/시각**: 2026-11-18 02:48 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `G` 키로 실물 컨디션 등급(`S급`~`개봉전시`)을 바꾸고 `T` 키로 커스텀 해시태그(`#소장각` 등)를 바꿀 수 있으면 수집품 메타데이터까지 키보드로 한 번에 정리할 수 있을 것 같아요."*
  - **가챠러 B**: *"`CustomTagBtn`, `ConditionBtn`, `ValueBtn` 툴팁에도 각각 `(T)`, `(G)`, `(V / Shift+V)` 단축키 힌트가 함께 표시되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `G`와 `T` 키 입력 시 등급·태그가 순환되고 하단에 즉시 반영되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `G` 등급 & `T` 커스텀 태그 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `G` 입력 시 `cycle_condition_grade()`, `T` 입력 시 `cycle_custom_tag()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `CustomTagBtn` `(T)`, `ConditionBtn` `(G)`, `ValueBtn` `(V / Shift+V)` 툴팁 반영 및 `H` 치트시트 토스트에 `[G] 등급 · [T] 태그` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard G Condition Grade & T Custom Tag Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 94] 모달 내 `O` 키 띠지 문구 순환 & `M` 키 독서 기분 태그 순환
- **날짜/시각**: 2026-11-18 02:28 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `O` 키를 눌러 책 표지 띠지 문구(Obi band)를 바꾸고 `M` 키로 독서·수집 기분 태그를 바꿀 수 있으면 다꾸 스탬프·스티커·띠지·기분까지 전부 키보드로 완주할 수 있을 것 같아요."*
  - **가챠러 B**: *"띠지와 기분 버튼 툴팁에도 `(O)`, `(M)` 단축키 힌트가 표시되고 `H` 치트시트에 함께 안내되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `M`(기분 태그)과 `O`(띠지 문구)가 동일하게 동작하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `O` 띠지 문구 & `M` 기분 태그 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `O` 입력 시 `cycle_obi_preset()`, `M` 입력 시 `cycle_reading_mood()` 실행(웹 목업 포함).
  2. **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `ObiCycleBtn` `(O)`, `MoodBtn` `(M)` 툴팁 반영 및 `H` 치트시트 토스트에 `[O] 띠지 · [M] 기분` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard O Obi Band & M Mood Tag Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 93] 모달 내 `S` 키 데코 스티커 순환 & `R` 키 수집 레어도 순환 + 다꾸 버튼 단축키 툴팁
- **날짜/시각**: 2026-11-18 02:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `W`(마테)와 `P`(속지)처럼 `S` 키로 데코 스티커, `R` 키로 수집 레어도 등급도 키보드로 바로 순환할 수 있으면 다꾸 커스터마이징 풀세트가 키보드만으로 완성될 것 같아요."*
  - **가챠러 B**: *"가챠·굿즈 소장 기록할 때 `R` 키로 `노말→레어→SR→SSR→시크릿` 레어도를 한 번에 올릴 수 있으면 정말 편할 것 같아요. 그리고 `TapeCycleBtn` 등 4종 버튼 툴팁에도 `(W)`, `(S)`, `(R)`, `(P)` 힌트가 보이면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달이 열려 있을 때 `S`와 `R` 키가 각각 스티커·레어도 순환으로 문맥 전환되면 완벽할 것 같아요."*
- **주요 개선 사항**:
  1. **모달 내 `S` 스티커 & `R` 레어도 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `S` 입력 시 `cycle_deco_sticker()`, `R` 입력 시 `cycle_rarity_tier()` 실행(웹 목업 포함).
  2. **다꾸 버튼 4종 단축키 툴팁 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `TapeCycleBtn` `(W)`, `DecoStickerBtn` `(S)`, `RarityBtn` `(R)`, `PaperBtn` `(P)` 툴팁 반영 및 `H` 치트시트 토스트에 `[S] 스티커 · [R] 레어도` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard S Sticker & R Rarity Cyclers + Tooltip Hints` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 92] 모달 내 `W` 키 마스킹 테이프 순환 & `P` 키 속지 패턴 순환
- **날짜/시각**: 2026-11-18 01:48 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `I` 키로 만년필 잉크를 바꾸는 것처럼 `W` 키로 상단 마스킹 테이프(와시테이프) 컬러도 키보드로 바로 바꿀 수 있으면 다꾸 조합 테스트가 엄청 빨라질 것 같아요."*
  - **가챠러 B**: *"`P` 키로 종이 속지 패턴(줄노트·모눈·도트·무지)도 즉시 순환하고 `H` 치트시트에 `[W] 마테 · [P] 속지`가 함께 안내되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `W`와 `P` 키가 동일하게 마테와 속지 패턴을 바꾸도록 동기화해주세요."*
- **주요 개선 사항**:
  1. **모달 내 `W` 마테 & `P` 속지 패턴 순환 (`detail_modal.gd` · `index.html`)**: `quote_input` 비포커스 상태에서 `W` 키 입력 시 `cycle_washi_tape()`, `P` 키 입력 시 `cycle_paper_pattern()` 실행(웹 목업 포함).
  2. **모달 단축키 치트시트 동기화 (`main_view.gd`)**: `H` 치트시트 토스트에 `[W] 마테 · [P] 속지` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard W Washi Tape & P Paper Pattern Cyclers` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 91] 모달 내 `I` 키 만년필 잉크 4종 순환 & `V`/`Shift+V` 소장 가치 ±5,000원 조정
- **날짜/시각**: 2026-11-18 01:28 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `1~4` 키로 도장을 찍는 것처럼 `I` 키를 눌러 만년필 잉크 4종(`에스프레소`·`버건디`·`세피아`·`포레스트`)도 키보드로 바로 순환해볼 수 있으면 좋겠어요."*
  - **가챠러 B**: *"모달 열람 중 `V` 키로 소장 가치 `+5,000원`, `Shift+V`로 `-5,000원`을 빠르게 조정할 수 있으면 시세 기록할 때 훨씬 편할 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `I` 키 입력 시 만년필 잉크 4종이 동일하게 순환되도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `I` 키 만년필 잉크 4종 순환 (`detail_modal.gd` · `index.html`)**: `cycle_fountain_pen_ink()` 헬퍼를 추가해 모달 열람 중 `I` 키로 4대 잉크 컬러를 순환 적용(웹 목업 포함).
  2. **모달 내 `V`/`Shift+V` 소장 가치 조정 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `KEY_V` 입력 시 `+5,000원`(`Shift+V`는 `-5,000원`) 조정 및 `H` 단축키 치트시트에 `[I] 잉크`, `[V] 가치` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard I Ink Cycle & V/Shift+V Value Adjust` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🏆 [Sprint 90] 마일스톤 90: 모달 내 `1~4` 키 인장 원클릭 찍기 & 단축키 툴팁 힌트 동기화
- **날짜/시각**: 2026-11-18 01:09 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `1` `2` `3` `4` 숫자키를 누르면 `전권완결`·`초판특전`·`인생최애`·`위시리스트` 고무인장이 바로 찍히면 키보드만으로 다꾸 스탬프까지 완성할 수 있을 것 같아요."*
  - **가챠러 B**: *"`+ 다음 권 일기 추가`, `- 권 삭제`, `형광펜` 버튼에 마우스를 올렸을 때 툴팁에 `(+)`, `(-)`, `(L)` 단축키 힌트가 같이 보이면 사용자가 자연스럽게 단축키를 익힐 수 있을 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달이 열려 있을 때 `1~4` 키가 4대 고무인장(`applyDiaryStamp`)으로 자연스럽게 문맥 전환되면 완벽할 것 같아요."*
- **주요 개선 사항**:
  1. **모달 내 `1~4` 키 인장 원클릭 찍기 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `quote_input` 비포커스 상태에서 `1`(`전권완결`), `2`(`초판특전`), `3`(`인생최애`), `4`(`위시리스트`) 인장 즉시 적용 및 웹 목업 동기화.
  2. **모달 액션 버튼 단축키 툴팁 힌트 & `H` 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `AddVolBtn` `(+)`, `RemVolBtn` `(-)`, `HighlighterBtn` `(L)` 툴팁 반영 및 `H` 치트시트 토스트에 `[1~4] 인장` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Sprint 90 Milestone: In-Modal Keyboard 1-4 Quick Stamp & Shortcut Tooltip Hints` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 89] 모달 `ESC` 3단계 안전 해제(`quote_input` 포커스 보호) & `L` 키 형광펜 토글
- **날짜/시각**: 2026-11-18 00:49 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 안에서 `E` 키로 밑줄 입력창(`quote_input`)에 커서를 넣은 뒤 `ESC`를 눌렀을 때 모달 전체가 닫히지 않고 먼저 입력창 포커스만 해제되면 실수로 일기장을 닫는 일이 없을 것 같아요."*
  - **가챠러 B**: *"모달 열람 중 `L` 키로 형광펜 효과를 바로 켜고 끌 수 있으면 문장 꾸미기가 훨씬 빨라질 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 `#diary-quote-input`에 포커스가 있을 때 `Escape` 키가 포커스만 먼저 해제하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 `ESC` 3단계 안전 해제 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `ESC` 입력 시 1순위 `quote_input` 포커스 해제(`open()` 시 초기 포커스 해제 포함), 2순위 삭제 경고(`delete_armed`) 해제, 3순위 모달 닫기 순으로 안전하게 처리.
  2. **모달 내 `L` 키 형광펜 토글 (`detail_modal.gd` · `main_view.gd`)**: `KEY_L` 입력 시 `toggle_quote_highlight()` 실행 및 `H` 치트시트 토스트에 `[L] 형광펜` 안내 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard L Highlighter Toggle & Updated Cheatsheet` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 88] 모달 내 `E` 키 밑줄 문장 즉시 편집 포커스 & 단축키 치트시트 동기화
- **날짜/시각**: 2026-11-18 00:27 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달을 열고 `+` 키로 권을 추가한 뒤 마우스로 입력창을 클릭하지 않고도 `E` 키 한 번으로 바로 밑줄 문장 입력창에 커서가 들어가면 키보드만으로 다꾸 기록이 완성될 것 같아요."*
  - **가챠러 B**: *"`H` 키 모달 단축키 안내 토스트에도 `[E] 문장 편집`이 함께 안내되면 처음 쓰는 사람도 바로 익힐 수 있을 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `E` 키를 누르면 `#diary-quote-input`으로 바로 포커스가 이동하도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `E` 키 밑줄 문장 즉시 포커스 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `quote_input` 비포커스 상태에서 `E` 키 입력 시 즉시 `quote_input.grab_focus()` 및 커서 끝 위치 이동(`caret_column = text.length()`) 실행.
  2. **모달 단축키 치트시트 동기화 (`main_view.gd` · `index.html`)**: `H` 치트시트 토스트 및 웹 목업 하단 안내에 `[E] 문장 편집` 추가.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard E Quote Focus & Updated H Cheatsheet` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 87] 모달 내 `+`/`-` 키 권 빠른 추가·삭제 & `H` 모달 전용 단축키 안내
- **날짜/시각**: 2026-11-18 00:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달을 열어두고 만화책 여러 권을 연속 기록할 때 `+`/`=` 키로 바로 다음 권을 추가하고 `-` 키로 마지막 권을 되돌릴 수 있으면 마우스를 안 움직여도 돼서 편할 것 같아요."*
  - **가챠러 B**: *"모달이 열려 있을 때 `H` 키를 누르면 모달 전용 단축키(`←/→`, `Home/End`, `+/-`, `C`, `ESC`) 안내가 바로 뜨면 기능 활용도가 훨씬 올라갈 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `H`/`?` 키를 누르면 모달 하단에 모달 단축키 안내가 뜨도록 맞춰주세요."*
- **주요 개선 사항**:
  1. **모달 내 `+`/`-` 키 권 빠른 추가·삭제 (`detail_modal.gd`)**: 모달 열람 중 `quote_input` 비포커스 상태에서 `=`/`+` 입력 시 `_on_add_vol_btn_pressed()`, `-` 입력 시 `remove_last_volume()` 실행.
  2. **모달 내 `H` 단축키 치트시트 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `help_requested` 시그널과 `_on_modal_help_requested()`를 연결해 모달 전용 단축키 토스트 출력(웹 목업 포함).
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `In-Modal Keyboard +/- Volume Control & H Modal Shortcut Help` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 86] 모달 `PageBadgeLabel` 클릭/우클릭 책장 넘김 & 모달 내 `C` 키 현재 작품 감상 카드 복사
- **날짜/시각**: 2026-11-17 23:48 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 상단 `1/6` 페이지 배지 자체를 클릭하거나 우클릭해도 다음/이전 책장으로 넘어가면 작은 `◀` `▶` 버튼 사이를 눌러도 자연스럽게 동작해서 편할 것 같아요."*
  - **가챠러 B**: *"메인 화면에서 `C` 키를 누르면 전체 서재 요약이 복사되는데, 모달을 열고 있을 때 `C` 키를 누르면 지금 보고 있는 작품의 독서 감상 카드가 바로 복사되면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 `#header-page-badge` 클릭 이동과 모달 내 `C` 키 감상 카드 복사가 똑같이 동작하면 완벽할 것 같아요."*
- **주요 개선 사항**:
  1. **클릭 가능한 `PageBadgeLabel` (`detail_modal.gd` · `index.html`)**: 모달 헤더의 `1/6` 페이지 배지에 포인터 커서 및 좌클릭(다음 일기장)·우클릭(이전 일기장) 책장 넘김 이벤트를 연결.
  2. **모달 내 단축키 `C` 감상 카드 복사 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `quote_input` 포커스가 없을 때 `C` 키 입력 시 `copy_book_quote_card()`를 호출해 현재 작품 감상 카드를 클립보드에 복사(웹 목업 포함).
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Clickable PageBadgeLabel & In-Modal Keyboard C Share Card Copy` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 85] 모달 `Home`/`End` 첫·끝 일기장 점프 & 초판·스마트 태그 건수·자산 요약 토스트
- **날짜/시각**: 2026-11-17 23:28 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달을 열었을 때 `←` `→`로 한 권씩 넘기는 것 외에, `Home` / `End` 키로 첫 번째(`1/6`)와 마지막(`6/6`) 일기장으로 한 번에 이동할 수 있으면 E-Book 목차 점프처럼 편할 것 같아요."*
  - **가챠러 B**: *"상단 `초판 스탬프` KPI 카드를 클릭하거나 `#만화`·`#가챠` 같은 스마트 태그를 눌렀을 때도 다른 탭처럼 `N종 · ₩총액` 요약을 토스트로 보여주면 통일감이 완성될 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`)에서도 모달 열람 중 `Home` / `End` 키가 동일하게 첫/끝 일기장으로 점프하면 좋겠어요."*
- **주요 개선 사항**:
  1. **모달 `Home`/`End` 첫·끝 페이지 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달 열람 중 `Home` 키 입력 시 첫 번째 작품(`1/N`), `End` 키 입력 시 마지막 작품(`N/N`)으로 즉시 이동하고 `PageBadgeLabel` 및 동적 툴팁을 갱신.
  2. **초판 KPI & 스마트 태그 건수·자산 요약 토스트 (`main_view.gd`)**: `_on_stat_firsts_clicked()` 및 `filter_by_smart_tag()` 호출 시 `_get_filtered_cards_summary()`로 `N종 · ₩총액` 요약을 토스트에 출력.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Modal Home/End Direct Jump & Firsts/Smart-Tag Value Summary Toasts` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 84] 모달 열기 단일 헬퍼(`_open_detail_modal`) 전 경로 통합 & 정렬 기준 건수·자산 요약 토스트
- **날짜/시각**: 2026-11-17 23:08 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"상단 책등(Spine) 배너 클릭이나 `오늘의 밑줄` 점프, `🎲 추천` 버튼으로 모달을 열 때도 헤더의 `1/6` 페이지 배지와 `◀` `▶` 툴팁이 항상 정확히 동기화되면 좋겠어요."*
  - **가챠러 B**: *"정렬 버튼(`↕ 기본순` → `다독순` → `최신순` → `가치순`)을 누를 때도 현재 필터링된 작품 수와 총 소장 가치가 토스트에 함께 보이면 일관성이 완벽할 것 같아요."*
  - **미니멀러 C**: *"어느 경로로 일기장 모달을 열어도 동일한 페이지 인디케이터와 툴팁 경험을 유지하고 싶어요."*
- **주요 개선 사항**:
  1. **모달 열기 단일 헬퍼 `_open_detail_modal(item)` 통합 (`main_view.gd`)**: 책등 엿보기 클릭, 오늘의 문장 점프, 서재 카드 클릭, 랜덤 추천, 모달 책장 넘김 5개 진입점을 `_open_detail_modal()`로 단일화하여 항상 `PageBadgeLabel`(`n/N`)과 `PrevItemBtn`/`NextItemBtn` 동적 툴팁이 동기화되도록 개선.
  2. **정렬 기준 변경 시 건수·자산 요약 토스트 (`main_view.gd`)**: `_on_sort_btn_pressed()`에서 정렬 기준과 함께 `(%s)` (`_get_filtered_cards_summary()`)를 표시해 5대 탭·검색·정렬 전체 토스트 포맷을 통일.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Unified _open_detail_modal Sync & Sort Summary Toast` 테스트를 추가해 오늘의 문장 점프·랜덤 추천 후 `PageBadgeLabel` 동기화 및 정렬 토스트 `₩` 표기를 검증하고 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 83] 실시간 검색 결과 건수·자산 요약 토스트 & 모달 헤더 `PageBadgeLabel`(`n/N`)
- **날짜/시각**: 2026-11-17 23:02 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달 상단 `◀` `▶` 버튼 사이에 현재 몇 번째 일기장인지 `1/6`처럼 숫자가 바로 보이면 E-Book 리더기 느낌이 더 살아날 것 같아요."*
  - **가챠러 B**: *"검색창에 작품명이나 대사를 입력할 때도 몇 종이 검색됐고 총 소장 가치가 얼마인지 하단 토스트로 즉시 알려주면 좋겠어요."*
  - **미니멀러 C**: *"웹 목업(`index.html`) 모달 상단 `◀` `▶` 사이에도 `1/6` 페이지 배지가 동기화되면 일관성이 완벽해질 것 같아요."*
- **주요 개선 사항**:
  1. **모달 헤더 실시간 페이지 배지 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 헤더 `PrevItemBtn`과 `NextItemBtn` 사이에 `PageBadgeLabel`(`1/6`~`6/6`)을 배치해 모달 열람 및 책장 넘김 시 현재 순번을 실시간 표시.
  2. **실시간 검색 결과 건수·자산 요약 토스트 (`main_view.gd`)**: `_on_search_text_changed()`에서 검색어 입력 시 `"🔍 '검색어' 검색 결과 (N종 · ₩총액)"` 토스트를, 검색어 비움 시 전체 서재 복원 요약 토스트를 출력.
  3. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `Live Search Summary Toast & Modal Header Page Badge` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 82] 5대 서재 탭 전체 건수·자산 요약 토스트 통일 & 모달 `◀` `▶` 동적 작품명 툴팁
- **날짜/시각**: 2026-11-17 06:59 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"완독·최애 탭뿐만 아니라 `전체일기`, `이북·단행본`, `가챠·굿즈` 탭을 눌렀을 때도 몇 종이고 총 소장 가치가 얼마인지 하단 토스트로 바로 보여주면 서재 현황 파악이 훨씬 쉬워질 것 같아요."*
  - **가챠러 B**: *"모달 상단 `◀` `▶` 버튼에 마우스를 올렸을 때 다음에 열릴 작품 제목과 페이지 순번(`2/6`)이 툴팁으로 보이면 책장 넘기기 전에 미리 알 수 있어서 편할 것 같아요."*
  - **미니멀러 C**: *"웹 목업(`index.html`) 필터 바에도 현재 선택된 탭·검색 결과의 `N종 · ₩총액` 배지가 실시간으로 표시되면 좋겠어요."*
- **주요 개선 사항**:
  1. **5대 서재 탭 전체 건수·자산 요약 토스트 통일 (`main_view.gd`)**: `_on_tab_all_pressed()`, `_on_tab_manga_pressed()`, `_on_tab_gacha_pressed()`에도 `_get_filtered_cards_summary()`를 적용해 모든 탭 전환 시 필터링된 작품 수(`N종`)와 원화 총액(`₩`)을 토스트로 안내.
  2. **모달 `◀` `▶` 버튼 동적 툴팁 (`main_view.gd` · `index.html`)**: `_update_modal_nav_tooltips(item)`을 추가해 모달을 열거나 페이지를 넘길 때 `PrevItemBtn`·`NextItemBtn` 툴팁에 이전/다음 작품 순번(`(n/N)`)과 제목을 실시간 반영.
  3. **웹 목업 필터 요약 배지 동기화 (`index.html`)**: `#filter-summary-badge`를 추가해 탭·검색어 변경 시 `N종 · ₩XX,000`을 즉시 표시.
  4. **TDD 통합 테스트 확장 (`tests/test_main_integration.gd`)**: `All-5-Tab Value Summary Toasts & Dynamic Modal Nav Tooltips` 테스트를 추가해 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 81] 모달 책장 넘김 페이지 인덱스(`(n/N)`) & 완독·최애 탭 필터 건수/자산 요약 토스트
- **날짜/시각**: 2026-11-17 06:41 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **다꾸러·수집러 VOC**:
  - **소장러 A**: *"모달에서 `◀` `▶` 버튼이나 방향키로 책장을 넘길 때 지금 전체 몇 권 중 몇 번째 책장인지 바로 보이면 E-Book 리더기 느낌이 더 살아날 것 같아요."*
  - **가챠러 B**: *"완독 탭이나 최애 탭을 눌렀을 때 몇 종이 필터링되었고 소장 가치가 얼마인지 토스트로 바로 요약해주면 서재 정리하는 재미가 배가 될 것 같아요."*
  - **미니멀러 C**: *"웹 목업에서도 모달 하단이 항상 `Page 1 of 1`로 고정되어 있는데, 실제 현재 보고 있는 작품 순서(`Page 2 / 6`)로 바뀌면 좋겠어요."*
- **주요 개선 사항**:
  1. **모달 책장 넘김 페이지 인덱스 표기 (`main_view.gd` · `index.html`)**: `_on_modal_navigate_requested()` 토스트에 `"(%d/%d)"` 형식으로 현재 책장 순번(`📖 책장 넘김 (2/6): 제목`)을 표시하고, 웹 목업(`index.html`) 모달 하단 `#journal-page-indicator`도 `Page ${idx + 1} / ${ITEMS.length} · 주희의 다꾸 일기장`으로 동적 동기화.
  2. **완독·최애 탭 필터 건수 & KRW 자산 합계 토스트 (`main_view.gd`)**: `_get_filtered_cards_summary()` 공용 헬퍼를 추가해 `_on_tab_complete_pressed()`와 `_on_tab_fav_pressed()` 호출 시 필터링된 작품 수(`N종`)와 원화(`₩`) 총액을 즉시 요약.
  3. **TDD 통합 테스트 추가 (`tests/test_main_integration.gd`)**: `Modal Page Index Toast & Filtered Value Summary Toast` 테스트로 `"(2/6)"` 표기 및 최애 탭 건수·`₩` 토스트를 검증하고 3종 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷 갱신.

---

## 🚀 [Sprint 80] 마일스톤 80: 북마크된 권별 행 골드 리본 액센트 & 단축키 `0` 전체 서재 초기화
- **날짜/시각**: 2026-11-17 06:18 (자동 스프린트)
- **참여 스쿼드**: 14인 애자일 스쿼드 전원 (다꾸러 3인, PO/기획 2인, UX/UI 2인, 개발 4인, QA 2인, CEO 1인)
- **핵심 VOC 및 기획 확정**:
  1. **다꾸러 VOC #1 ("모달의 `📌 권별 밑줄 노트`에서 북마크 리본(`🔖`)을 꽂아둔 권은 행 자체 왼쪽에도 금빛 리본 라인과 따뜻한 배경이 들어가면 최애 권이 한눈에 확 들어올 것 같아요!")**: `detail_modal.gd`의 `_render_volumes()`에서 `bookmarked == true`인 권 행에 3px 골드 좌측 보더와 웜 크림 배경을 적용.
  2. **다꾸러 VOC #2 ("메인 서재에서 어떤 검색어나 필터가 걸려 있든 숫자 `0` 키만 누르면 한 번에 전체 서재 초기화(`_reset_all_filters()`)가 되면 키보드 탐색이 완벽해질 것 같아요")**: `main_view.gd`의 `_unhandled_input()`에 `KEY_0` 전체 초기화 단축키를 추가하고 `KEY_H` 치트시트 토스트에 `[0] 초기화`를 반영.
  3. **웹 목업 동기화**: `game02/index.html`의 전역 `keydown` 리스너에 `0` 키 전체 서재 초기화 단축키를 동기화.
- **구현 및 검증 내역**:
  - `detail_modal.gd`: `_render_volumes()` 북마크 권 행 3px 골드 좌측 리본 액센트 추가.
  - `main_view.gd`: `_unhandled_input()` `KEY_0` 전체 초기화 및 `KEY_H` 치트시트 갱신.
  - `game02/index.html`: 전역 `0` 키 검색·필터 초기화 단축키 동기화.
  - `tests/test_main_integration.gd`: Sprint 80 통합 테스트(`Bookmarked Volume Row Gold Accent & Keyboard 0 Reset All Filters verified`) 추가 후 3대 헤드리스 테스트 100% 통과 및 Metal 4.0 스크린샷(`godot_app_screen.png`, `godot_modal_screen.png`) 캡처 완료.

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
