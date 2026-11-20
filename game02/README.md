# 📔 주희의 다꾸 서재 & 소장 일기장 — Pocket Archive (Game02)

Godot 4.6.2 모바일 기반의 **E-Book 리더기 서재(Apple Books · 리디북스 레퍼런스) & 만년필 다꾸 독서노트(굿노트 · 몰스킨 레퍼런스)** 감성 아카이브 앱입니다.
14인 가상 애자일 스쿼드(다꾸러 3인, 기획자 2인, UX/UI 디자이너 2인, 개발자 4인, QA 2인, CEO 1인)가 **20분 주기 스프린트**로 UI 목업(`index.html`)과 실제 Godot 앱(`godot_project`)을 동시에 고도화하며 [SPRINT_LOG.md](SPRINT_LOG.md)에 전 과정을 기록합니다.

---

## 📸 실제 구동 스크린샷 (Godot 4.6 Metal 렌더링 — Sprint 176)

| 📔 메인 E-Book 서재 & 다꾸 일기장 (`main.tscn`) | 🖋️ 펼친 몰스킨 독서노트 상세 모달 (`detail_modal.tscn`) |
| :---: | :---: |
| ![Pocket Archive Main Screen](godot_project/screenshots/godot_app_screen.png) | ![Pocket Archive Detail Modal](godot_project/screenshots/godot_modal_screen.png) |

---

## 🚀 최신 스프린트 업데이트 요약 ([전체 회의록 보기](SPRINT_LOG.md))

### 📓 [Sprint 176] `AddModal` 키보드 `Shift+ESC` 입력 전체 비우기 & `Shift+Enter` 샘플 자동 채움 등록
- **`AddModal` 키보드 `Shift` 파워 단축키 (`add_modal.gd` · `index.html`)**: `Shift+ESC`로 창을 닫지 않고 입력란 3종을 일괄 비우며, `Shift+Enter`로 샘플 자동 채움 후 즉시 등록합니다.

### 🏆 [Sprint 175 Milestone] `DetailModal` 키보드 `Shift+L` 속지 순환 · `Shift+Delete` 삭제 해제 · `Shift+PgUp/PgDn` 처음·끝 점프
- **모달 키보드 `Shift` 파워 액션 완결 (`detail_modal.gd` · `index.html`)**: `Shift+L`로 속지 패턴 순환, `Shift+Delete`/`Backspace`로 삭제 확인 안전 해제, `Shift+PageUp`/`PageDown`으로 처음·끝 작품 점프를 지원합니다.

### 📓 [Sprint 174] `DetailModal` 키보드 `Shift+E` 샘플 밑줄 채움 & `Shift+1~4` 인장 찍고 닫기
- **모달 키보드 `Shift+E`/`Shift+1~4` 확장 (`detail_modal.gd` · `index.html`)**: `Shift+E`로 샘플 밑줄 문장을 즉시 채워 입력창에 포커스하며, `Shift+1~4`로 4종 인장을 찍음과 동시에 모달을 닫습니다.

### 📓 [Sprint 173] `DetailModal` 키보드 `Shift+←/→` 처음·끝 점프 & `Shift++/-` 초판북마크 추가·전권 북마크 토글
- **모달 키보드 `Shift` 파워 액션 확장 (`detail_modal.gd` · `index.html`)**: `Shift+←/→`로 첫 작품·마지막 작품 즉시 점프, `Shift++`로 초판+북마크 권 추가, `Shift+-`로 전권 북마크 일괄 토글을 지원합니다.

### 📓 [Sprint 172] 메인 키보드 `Shift+0` 스튜디오 완전 초기화 · `Shift+C` 오늘의 밑줄 복사 · `Shift+H` 단축키 치트시트 복사
- **키보드 `Shift` 스튜디오 초기화·복사 확장 (`main_view.gd` · `index.html`)**: `Shift+0`으로 필터·정렬·테마를 한 번에 초기화하며, `Shift+C`로 오늘의 밑줄 문장 복사, `Shift+H`로 단축키 치트시트 복사까지 지원합니다.

### 📓 [Sprint 171] 메인 키보드 `Shift+1~5` 탭 필터 후 즉시 열기 · `Shift+N` 샘플 모달 · `Shift+I` 즉시 백업
- **키보드 `Shift` 파워 단축키 확장 (`main_view.gd` · `index.html`)**: `Shift+1~5`로 탭 전환과 동시에 랜덤/첫 작품 일기장을 열며, `Shift+N`으로 샘플 채움 일기 작성 창 열기, `Shift+I`로 즉시 JSON 백업을 실행합니다.

### 🏆 [Sprint 170 Milestone] `TitleLabel` `Shift+좌클릭` 감상 카드 전체 복사 & `StampLbl`/`InkLbl` `Shift+좌클릭` 역순환 완결
- **제목 카드 복사 & 라벨 역순환 완결 (`detail_modal.gd` · `index.html`)**: `TitleLabel` `Shift+좌클릭`으로 감상 카드 전체를 복사하며, `StampLbl`·`InkLbl` `Shift+좌클릭`으로 인장·만년필 잉크 역순환을 실행해 모달 내 모든 트랙패드 파워 액션을 완결했습니다.

### 📓 [Sprint 169] `AddModal` 입력 3종 `Shift+좌클릭` 개별 샘플 채움 & `DetailModal` `CatBadge` `Shift+좌클릭` 전체 서재 복원
- **개별 샘플 채움 & 카테고리 전체 복원 (`add_modal.gd` · `detail_modal.gd` · `index.html`)**: `AddModal` 입력란 3종 `Shift+좌클릭`으로 해당 칸의 샘플을 즉시 채우며, `DetailModal` `CatBadge` `Shift+좌클릭`으로 모달을 닫고 전체 서재를 복원합니다.

### 📓 [Sprint 168] `SearchInput` `Shift+좌클릭` 첫 결과 열기 & `QuoteInput` `Shift+좌클릭` 밑줄 저장+복사
- **입력창 원클릭 숏컷 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `SearchInput` `Shift+좌클릭`으로 첫 검색 결과 일기장을 즉시 열며, `QuoteInput` `Shift+좌클릭`으로 작성 중인 밑줄·감상평을 저장과 동시에 클립보드에 복사합니다.

### 📓 [Sprint 167] `AddModal` `Dimmer` `Shift+좌클릭` 입력 비우기 & `TitleLabel` `Shift+좌클릭` 샘플 즉시 등록
- **`AddModal` 배경 비우기 & 헤더 즉시 등록 (`add_modal.gd` · `index.html`)**: `AddModal` 배경 `Shift+좌클릭`으로 창을 닫지 않고 입력란만 비우며, 모달 제목 `Shift+좌클릭`으로 샘플 일기를 즉시 등록합니다.

### 📓 [Sprint 166] `EmptyStateResetBtn` `Shift+좌클릭` 복원 후 랜덤 일기장 열기 & `DetailModal` `Dimmer` `Shift+좌클릭` 카드 복사+닫기
- **빈 서재 랜덤 열기 & 배경 카드 복사+닫기 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `EmptyStateResetBtn` `Shift+좌클릭`으로 전체 서재 복원 후 랜덤 일기장을 즉시 열며, `DetailModal` `Dimmer` `Shift+좌클릭`으로 감상 카드 복사 후 모달을 닫습니다.

### 🏆 [Sprint 165 Milestone] `AddModal` 스와치 5종·`CatOption`·`CloseBtn`·`SubmitBtn` `Shift+좌클릭` 파워 액션 완결
- **`AddModal` 트랙패드 파워 액션 완결 (`add_modal.gd` · `index.html`)**: 표지 컬러 스와치 5종·`SubmitBtn` `Shift+좌클릭`으로 즉시 샘플 등록, `CatOption` `Shift+좌클릭`으로 이북↔가챠 전환, `CloseBtn` `Shift+좌클릭`으로 입력란 비우기를 모두 지원합니다.

### 📓 [Sprint 164] `StampRow`·`InkRow` 17종 데코레이터 순환 버튼 `Shift+좌클릭` 역순환 일괄 지원
- **17종 데코레이터 역순환 완결 (`detail_modal.gd` · `index.html`)**: 띠지·테이프·스티커·레어도·속지·보관위치·입수경로·기분·소장상태·펜촉·서명·태그·최애캐릭터·컨디션·마감·날씨·장소 17종 순환 버튼에 `Shift+좌클릭` 역순환(`-1`)을 일괄 적용했습니다.

### 📓 [Sprint 163] `RereadBtn`/`DuplicateBtn`/`ValueBtn` `Shift+좌클릭` -1·-5,000원 역감소 지원
- **수치 3종 역감소 통일 (`detail_modal.gd` · `index.html`)**: `RereadBtn`, `DuplicateBtn`, `ValueBtn` `Shift+좌클릭`으로 각각 재독 횟수 `-1`, 복수 소장 수량 `-1`, 추정 소장 가치 `-5,000원`을 즉시 감소시킵니다.

### 📓 [Sprint 162] `DateStampBtn` `Shift+좌클릭` 구매일+전권 오늘 날짜 동기화 & `DeleteBtn` `Shift+좌클릭` 삭제 확인 해제
- **구매일·전권 날짜 동기화 & 안전 삭제 해제 (`detail_modal.gd` · `index.html`)**: `DateStampBtn` `Shift+좌클릭`으로 구매·기념일과 전권 날짜를 오늘 날짜로 일괄 동기화하며, `DeleteBtn` `Shift+좌클릭`으로 삭제 확인 대기(`delete_armed`)를 안전하게 해제합니다.

### 📓 [Sprint 161] 권별 `vol_lbl` `Shift+좌클릭` 초판+북마크+★5 풀스탬프 & `quote_lbl` `Shift+좌클릭` 밑줄 복사+북마크
- **최애권 풀스탬프 & 밑줄 복사+북마크 (`detail_modal.gd` · `index.html`)**: 권별 `N권` 라벨 `Shift+좌클릭`으로 `초판특전+북마크+★5`를 한 번에 지정하며, 밑줄 문장 라벨 `Shift+좌클릭`으로 클립보드 복사와 북마크 ON을 동시에 실행합니다.

### 🏆 [Sprint 160 Milestone] `RemoveVolBtn` `Shift+좌클릭` 전권 북마크 일괄 토글 & `ShareCardBtn` `Shift+좌클릭` 전체 서재 리포트 복사
- **전권 북마크 일괄 토글 & 리포트 원클릭 복사 (`detail_modal.gd` · `index.html`)**: `- 권 삭제` 버튼 `Shift+좌클릭`으로 전권 북마크를 일괄 온·오프하며, `💌 공유` 버튼 `Shift+좌클릭`으로 전체 서재 리포트를 즉시 클립보드에 복사합니다.

### 📓 [Sprint 159] 권별 `date_btn` `Shift+좌클릭` 전권 오늘 날짜 일괄 스탬프 & `PrevItemBtn`/`NextItemBtn` `Shift+좌클릭` 처음·끝 작품 점프
- **전권 날짜 일괄 스탬프 & 모달 처음·끝 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 권별 날짜 스탬프 버튼 `Shift+좌클릭`으로 전권 `date`를 오늘 날짜(`YYYY.MM.DD`)로 일괄 갱신하며, 모달 상단 `◀`/`▶` 버튼 `Shift+좌클릭`으로 첫 작품·마지막 작품으로 즉시 점프합니다.

### 📓 [Sprint 158] `DiyBtn` `Shift+좌클릭` 샘플 채움 모달 열기 & 권별 `StatusBtn` `Shift+좌클릭` 전권 초판·소장 일괄 전환
- **샘플 일괄 채움 & 전권 초판 전환 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `DiyBtn` `Shift+좌클릭`으로 샘플 채움 모달을 열며, 권별 `StatusBtn` `Shift+좌클릭`으로 전권 초판·소장 상태를 일괄 전환합니다.

### 📓 [Sprint 157] `WebBtn`/`CamBtn` `Shift+좌클릭` 스크랩·촬영 후 즉시 열기 & 권별 `BmBtn` `Shift+좌클릭` 초판+북마크
- **등록 후 즉시 열기 & 초판 북마크 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `WebBtn`/`CamBtn` `Shift+좌클릭`으로 스크랩·촬영 후 모달을 즉시 열며, 권별 `BmBtn` `Shift+좌클릭`으로 `초판+북마크`를 동시 적용합니다.

### 📓 [Sprint 156] `StatVols`/`StatFirsts` `Shift+좌클릭` 첫 작품·초판 가치순 & 권별 `StarBtn` `Shift+좌클릭` ★5+북마크
- **통계 완결 & 최애권 원클릭 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `StatVols`/`StatFirsts` `Shift+좌클릭`으로 이북 첫 작품 열기 및 초판 가치순 정렬을 실행하며, 권별 `StarBtn` `Shift+좌클릭`으로 `★5+북마크`를 즉시 적용합니다.

### 🏆 [Sprint 155] 마일스톤 155: 필터 탭 5종 `Shift+좌클릭` 첫 작품·랜덤 즉시 열기 & 인장 4종 `Shift+좌클릭` 찍고 닫기
- **원클릭 탐색·도장 마감 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: 필터 탭 5종 `Shift+좌클릭`으로 랜덤/첫 작품을 즉시 열며, 인장 4종 `Shift+좌클릭`으로 인장 적용과 동시에 모달을 닫습니다.

### 📓 [Sprint 154] 통계 카드(`StatItems`/`StatGacha`) `Shift+좌클릭` 정렬 초기화·가치순 & 만년필 잉크 4종 `Shift+좌클릭` 적용+입력창 이동
- **통계·잉크 원클릭 워크플로우 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `StatItems`/`StatGacha` `Shift+좌클릭`으로 전체+기본순 복원 및 가챠 가치순 정렬을 실행하며, 만년필 잉크 4종 `Shift+좌클릭`으로 잉크 적용과 동시에 입력창으로 이동합니다.

### 📓 [Sprint 153] `ThemeBtn` `Shift+좌클릭` 기본 속지 테마 복원 & `CloseBtn` `Shift+좌클릭` 감상 카드 복사+닫기
- **테마 초기화 & 복사+닫기 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `ThemeBtn` `Shift+좌클릭`으로 기본 속지 테마를 복원하며, `CloseBtn` `Shift+좌클릭`으로 감상 카드를 복사한 뒤 모달을 닫습니다.

### 📓 [Sprint 152] `AddBtn` `Shift+좌클릭` 샘플 채움 모달 열기 & `AddVolBtn` `Shift+좌클릭` 초판+북마크 즉시 추가
- **원클릭 샘플·초판 추가 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `AddBtn` `Shift+좌클릭`으로 샘플이 채워진 일기 작성 창을 열며, `AddVolBtn` `Shift+좌클릭`으로 `초판특전+북마크`가 적용된 새 권을 즉시 추가합니다.

### 📓 [Sprint 151] `RandomPickBtn` `Shift+좌클릭` 서재 필터 & `SaveQuoteBtn`/`HighlightBtn` `Shift+좌클릭`(저장+복사/속지 순환)
- **랜덤 필터·저장+복사 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `RandomPickBtn` `Shift+좌클릭`으로 랜덤 추천 작품만 서재에 띄우며, `SaveQuoteBtn` `Shift+좌클릭`으로 저장+복사, `HighlightBtn` `Shift+좌클릭`으로 속지 패턴을 순환합니다.

### 🏆 [Sprint 150] 마일스톤 150: `StatusToast` `Shift+좌/우클릭`(서재 브리핑/복사) & `MemoLabel` `Shift+좌클릭` 감상평 복사
- **하단 브리핑·감상평 복사 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `StatusToast` `Shift+좌/우클릭`으로 서재 인포그래픽 브리핑 및 메시지 복사를 실행하며, `MemoLabel` `Shift+좌클릭`으로 감상평 원문을 복사합니다.

### 📓 [Sprint 149] `SortBtn` `Shift+좌클릭` 기본순 정렬 복원 & `TagLabel` `Shift+좌클릭` 태그·띠지 문구 클립보드 복사
- **정렬 초기화 & 태그 복사 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `SortBtn` `Shift+좌클릭`으로 `↕ 기본순` 정렬로 즉시 복원하며, `TagLabel` `Shift+좌클릭`으로 태그·띠지 문구를 클립보드에 복사합니다.

### 📓 [Sprint 148] `AmbientBtn` `Shift+좌클릭` 즉시 음소거 & `AuthorLabel` `Shift+좌클릭` 작가명 클립보드 복사
- **원클릭 음소거 & 작가 복사 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `AmbientBtn` `Shift+좌클릭`으로 백색소음을 즉시 무음 처리하며, `AuthorLabel` `Shift+좌클릭`으로 작가·시리즈명을 클립보드에 복사합니다.

### 📓 [Sprint 147] `SubTitle` `Shift+좌/우클릭`(즉시 백업/단축키 치트시트) & `PageBadgeLabel` `Shift+좌/우클릭`(처음·끝 이동)
- **상단 요약·페이지 배지 점프 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `SubTitle` `Shift+좌/우클릭`으로 즉시 JSON 백업·단축키 치트시트를 호출하며, `PageBadgeLabel` `Shift+좌/우클릭`으로 처음·끝 작품으로 즉시 이동합니다.

### 📓 [Sprint 146] `AppTitle` `Shift+좌클릭` 새 일기 쓰기 & `ModalWashiTape` `Shift+좌/우클릭` 스티커·속지 순환
- **타이틀·테이프 다꾸 제스처 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `AppTitle` `Shift+좌클릭` 시 새 일기 작성 모달을 즉시 열며, `ModalWashiTape` `Shift+좌/우클릭` 시 데코 스티커와 속지 패턴을 순환합니다.

### 🏆 [Sprint 145] 마일스톤 145: `TodayQuoteLabel` `Shift+좌클릭` 밑줄 즉시 복사 & `CoverRect` `Shift+좌/우클릭` 마감·상태등급 전환
- **배너 복사 & 표지 촉각 제스처 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: `TodayQuoteLabel` `Shift+좌클릭`으로 오늘의 밑줄 문장을 즉시 복사하며, 모달 `CoverRect` `Shift+좌/우클릭`으로 표지 마감과 상태등급을 전환합니다.

### 📓 [Sprint 144] `VolHeader` `Shift+좌클릭` 전권 북마크 일괄 토글 & `NextQuoteBtn` `Shift+좌클릭` 해당 작품 열기
- **일괄 북마크 & 명대사 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `VolHeader` `Shift+좌클릭` 시 전권 북마크를 일괄 토글하며, `NextQuoteBtn` `Shift+좌클릭` 시 현재 오늘의 밑줄 작품 일기장을 바로 엽니다.

### 📓 [Sprint 143] 서재 카드 `Shift+좌클릭` 작가·시리즈 즉시 검색 & 책등 선반(`SpineShelf`) `Shift+좌/우클릭` 필터·복사
- **카드·책등 Shift 단축 제스처 (`card_item.gd` · `main_view.gd` · `index.html`)**: 서재 카드 `Shift+좌클릭` 시 작가·시리즈명으로 즉시 검색하며, 미니 책등 선반 `Shift+좌/우클릭` 시 작품 필터링 및 감상 요약 복사를 지원합니다.

### 📓 [Sprint 142] `AddModal` 헤더 `TitleLabel` 좌·우클릭(샘플 일괄 채움/비우기) & `Ctrl/Cmd+Enter` 즉시 등록
- **새 일기 작성 가속화 (`add_modal.gd` · `index.html`)**: `AddModal` 상단 `TitleLabel` 좌·우클릭으로 샘플 일기 일괄 채움 및 비우기가 가능하며, `Ctrl/Cmd+Enter` 단축키로 즉시 등록합니다.

### 📓 [Sprint 141] `DetailModal` `StampLbl`·`InkLbl` 라벨 좌·우클릭 양방향 인장/잉크 순환
- **인장·잉크 헤더 라벨 순환 (`detail_modal.gd` · `index.html`)**: `💮 인장:`(`StampLbl`) 및 `🖋️ 잉크:`(`InkLbl`) 라벨 좌·우클릭 시 4종 인장 프리셋과 4종 만년필 잉크를 양방향으로 순환합니다.

### 🏆 [Sprint 140] 마일스톤 140: `DetailModal` `TitleLabel` 우클릭 감상 카드 복사 & `CatBadge` 우클릭 전체 서재 복원
- **모달 헤더 배지·제목 우클릭 완성 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `TitleLabel` 우클릭 시 감상 카드 전체를 클립보드에 복사하며, `CatBadge` 우클릭 시 모달을 닫고 전체 서재로 즉시 복원합니다.

### 📓 [Sprint 139] `SearchInput` 우클릭 검색어 비우기·오늘의 밑줄 작품 검색 & `AddModal` 입력창 우클릭 비우기·샘플 채움
- **입력창 우클릭 제스처 (`main_view.gd` · `add_modal.gd` · `index.html`)**: `SearchInput` 우클릭 시 검색어 비우기 ↔ 오늘의 밑줄 작품 검색이 토글되며, `AddModal` 3종 입력창 우클릭 시 입력 비우기 ↔ 샘플 채움이 동작합니다.

### 📓 [Sprint 138] `RemoveVolBtn` 우클릭 마지막 권 북마크 토글 & `QuoteInput` 우클릭 입력 비우기·원문 복원
- **모달 우클릭 편의 강화 (`detail_modal.gd` · `index.html`)**: `RemoveVolBtn` 우클릭 시 마지막 권 북마크를 토글하고, `QuoteInput` 우클릭 시 입력 비우기 ↔ 원문 감상평 복원을 전환합니다.

### 📓 [Sprint 137] 권별 리스트 `vol_lbl` 좌·우클릭(편집/북마크) & `quote_lbl` 우클릭 밑줄 문장 즉시 복사
- **권별 행 라벨 인터랙션 (`detail_modal.gd` · `index.html`)**: `1권`/`2권` 라벨(`vol_lbl`) 좌클릭 시 해당 권 밑줄 편집, 우클릭 시 북마크 토글이 동작하며, 밑줄 문장(`quote_lbl`) 우클릭 시 클립보드에 즉시 복사됩니다.

### 📓 [Sprint 136] `DetailModal` 배경 딤머 우클릭 닫기+즉시 JSON 백업 & `AddModal` 배경 딤머 우클릭 입력 비우기
- **모달 배경(`Dimmer`) 우클릭 제스처 (`detail_modal.gd` · `add_modal.gd` · `index.html`)**: `DetailModal` 바깥 배경 우클릭 시 모달을 닫고 즉시 JSON 백업을 저장하며, `AddModal` 바깥 배경 우클릭 시 창을 닫지 않고 입력 내용만 비웁니다.

### 🏆 [Sprint 135] 마일스톤 135: 검색창 `Enter` 첫 결과 즉시 열기 & 빈 결과(`EmptyState`) 우클릭 복원+랜덤 추천 미리보기
- **검색·빈 상태 탐색 완결 (`main_view.gd` · `index.html`)**: 검색창에서 `Enter` 입력 시 첫 번째 필터링 작품 일기장을 즉시 열고(`_open_first_filtered_card`), 검색 결과 0건의 `EmptyStateResetBtn` 우클릭 시 전체 복원 후 랜덤 추천 미리보기를 표시합니다.

### 📓 [Sprint 134] `AddModal` 표지 색상 스와치 우클릭 즉시 등록 & `ESC` 2단계 입력 비우기·닫기 안전장치
- **`AddModal` 스와치 원클릭 등록 & `ESC` 안전장치 (`add_modal.gd` · `index.html`)**: 6종 표지 색상 스와치 우클릭 시 해당 색상으로 즉시 등록(`_submit_with_sample_fallback`)하며, 입력 중 `ESC`는 입력란을 먼저 비운 뒤 빈 상태에서 닫히도록 안전성을 강화했습니다.

### 📓 [Sprint 133] 서재 카드 `Shift+우클릭` 툴팁 동기화 & `AddModal` 카테고리 드롭다운 우클릭 즉시 전환
- **카드 툴팁 & `AddModal` 분류 전환 (`card_item.gd` · `add_modal.gd` · `index.html`)**: 카드 리치 툴팁에 `Shift+우클릭: 감상 요약 복사` 안내를 동기화하고, `AddModal`의 `CatOption` 우클릭 시 이북 ↔ 가챠 분류를 즉시 토글합니다.

### 📓 [Sprint 132] 카드 `Shift+우클릭` 즉시 감상 요약 복사 & `AddModal` 우클릭 입력 초기화·샘플 자동 채움 등록
- **카드 즉시 복사 & `AddModal` 우클릭 파워 액션 (`card_item.gd` · `add_modal.gd` · `index.html`)**: 서재 카드 `Shift+우클릭` 시 모달 미개봉 상태로 감상 요약을 클립보드에 복사하며, `AddModal`에서는 `CloseBtn` 우클릭 입력 초기화(`clear_inputs`) 및 `SubmitBtn` 우클릭 샘플 자동 채움 등록이 동작합니다.

### 📓 [Sprint 131] 메인 `AppTitle` 좌·우클릭(전체 복원/테마 순환) & 하단 `StatusToast` 좌·우클릭(치트시트/랜덤 미리보기)
- **메인 텍스트 라벨 100% 인터랙티브화 (`main_view.gd` · `index.html`)**: 상단 `AppTitle` 좌클릭 시 전체 서재 복원·우클릭 시 속지 테마 순환이 동작하며, 하단 `StatusToast` 좌클릭 시 단축키 치트시트(`_show_shortcut_cheatsheet`)·우클릭 시 랜덤 작품 미리보기가 실행됩니다.

### 🏆 [Sprint 130] 마일스톤 130: 모달 `TagLabel` 좌·우클릭 띠지 순환 & `VolHeader` 좌·우클릭 권 추가·삭제
- **모달 전 영역 100% 인터랙티브화 달성 (`detail_modal.gd` · `index.html`)**: `TagLabel` 좌·우클릭 시 띠지 문구를 양방향 순환하고, `VolHeader` 좌·우클릭 시 권 추가(`+`)·마지막 권 삭제(`-`)를 즉시 실행합니다.

### 📓 [Sprint 129] 모달 `AuthorLabel` 우클릭 가치 증감 & `MemoLabel` 좌클릭(편집 이동)·우클릭(형광펜 토글)
- **본문 감상평 & 작가란 인터랙션 강화 (`detail_modal.gd` · `index.html`)**: `AuthorLabel` 우클릭(`Shift+우클릭`)으로 소장 가치를 즉시 `±5,000원` 조정하고, `MemoLabel` 좌클릭 시 입력창 포커스·우클릭 시 형광펜 하이라이트를 토글합니다.

### 📓 [Sprint 128] 모달 `CatBadge` 클릭(이북/가챠 카테고리 모아보기) & `AuthorLabel` 클릭(작가·시리즈 즉시 검색)
- **모달 탐색 동선 연결 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달 헤더 `[이북·단행본 일기]`/`[가챠·소장 노트]` 배지 클릭 시 해당 카테고리 서재만 모아보고, `작가 · ...` 줄 클릭 시 해당 작가·시리즈명으로 서재 검색을 즉시 실행합니다.

### 📓 [Sprint 127] 모달 `📅 기념일` 우클릭 기본값 초기화 & 모달 제목(`TitleLabel`) 클릭 클립보드 복사
- **기념일 초기화 & 제목 클립보드 복사 (`detail_modal.gd` · `index.html`)**: `DateStampBtn` 우클릭 시 구매·기념일 스탬프를 `"📅 기념일"`로 초기화하고, 모달 제목(`TitleLabel`) 클릭 시 작품 제목을 클립보드에 복사합니다.

### 📓 [Sprint 126] 모달 `✕` 닫기 우클릭(닫기+즉시 JSON 백업) & 권별 `📅` 날짜 버튼 우클릭(해당 권 대사 복사)
- **모달 `CloseBtn` 백업 & 권별 대사 복사 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달 `✕` 버튼 우클릭 시 일기장을 닫고 즉시 JSON 백업을 저장하며, 권별 `📅` 날짜 버튼 우클릭 시 해당 권의 밑줄 대사를 클립보드에 복사합니다.

### 🏆 [Sprint 125] 마일스톤 125: 모달 4대 인장 우클릭(인장+감상카드 복사) & 권별 초판 배지 우클릭(초판+북마크 동시 토글)
- **인장·초판 배지 우클릭 콤보 액션 (`detail_modal.gd` · `index.html`)**: 4대 인장 버튼 우클릭 시 인장 적용과 동시에 감상 카드를 클립보드에 복사하며, 권별 `🔖초판특전`/`✓소장완료` 배지 우클릭 시 초판 상태와 북마크 리본을 동시에 토글합니다.

### 📓 [Sprint 124] 모달 4대 잉크 스와치 우클릭(잉크+형광펜 동시 토글) & 권별 북마크 리본 우클릭 밑줄 편집
- **잉크 스와치 & 북마크 리본 우클릭 파워 액션 (`detail_modal.gd` · `index.html`)**: `InkRow` 4대 잉크 스와치 우클릭 시 잉크 적용과 함께 형광펜을 토글하고, 권별 북마크 리본(`🏷️`/`🔖`) 우클릭 시 해당 권의 밑줄 문장 편집 모드로 즉시 진입합니다.

### 📓 [Sprint 123] 모달 `AddVolBtn` 우클릭 권 추가+즉시 밑줄 편집 & `DeleteBtn` 우클릭 삭제 무장 안전 해제
- **모달 `BtnRow` 우클릭 동선 & 안전성 강화 (`detail_modal.gd` · `index.html`)**: `AddVolBtn` 우클릭 시 새 권 추가 후 즉시 마지막 권 밑줄 편집 모드로 진입하고, `DeleteBtn` 우클릭 시 `delete_armed` 삭제 확인 상태를 안전하게 해제합니다.

### 📓 [Sprint 122] 모달 `밑줄 저장` 우클릭 원문 복원 & `형광펜` 우클릭 잉크색 순환
- **`QuoteEditRow` 우클릭 보조 액션 (`detail_modal.gd` · `index.html`)**: `SaveQuoteBtn` 우클릭 시 입력창을 저장된 원문(`current_item.memo`)으로 즉시 복원하고, `HighlightBtn` 우클릭 시 만년필 잉크 색상을 순환합니다.

### 📓 [Sprint 121] 상단 5대 필터 탭 우클릭 가치순 보기 & 전체 초기화(`TabAll`) 원클릭 복원
- **5대 필터 탭 우클릭 파워 액션 (`main_view.gd` · `index.html`)**: `TabAll` 우클릭 시 검색·필터·정렬을 기본값으로 완전 복원하고, `TabManga`·`TabGacha`·`TabComplete`·`TabFav` 우클릭 시 해당 탭 필터와 함께 `↕ 가치순` 정렬을 즉시 적용합니다.

### 🏆 [Sprint 120] 마일스톤 120: 상단 4대 통계 카드 우클릭 파워 액션 & 모달 `[Shift+C] 리포트` 치트시트 동기화
- **상단 4대 통계 카드 우클릭 파워 액션 (`main_view.gd` · `index.html`)**: `StatItems`(리포트 복사), `StatVols`(이북 가치순 정렬), `StatFirsts`(인포그래픽 요약), `StatGacha`(즉시 JSON 백업) 우클릭 액션을 연결하고 모달 `H` 도움말에 `Shift+C: 리포트`를 동기화했습니다.

### 📓 [Sprint 119] 모달 `💌 공유` 우클릭·`Shift+C` 전체 서재 리포트 복사 & 상단 마스킹 테이프 우클릭 역순환
- **모달 `💌 공유` 전체 서재 복사 & 마테 역순환 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `ShareCardBtn` 우클릭 또는 `Shift+C` 시 전체 서재 요약 리포트가 즉시 클립보드에 복사되며, `ModalWashiTape` 우클릭 시 이전 마스킹 테이프 색으로 되돌아갑니다.

### 📓 [Sprint 118] 메인·모달 `H` 단축키 치트시트 & 표지 커버 `Shift+Q/X` 툴팁 동기화
- **도움말 치트시트 & 툴팁 동기화 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: 메인·모달 `H` 단축키 안내와 `CoverRect` 툴팁에 `[Space] 책장`, `[Shift+순환키] 역순환`, `[우클릭] 역순환·백업` 힌트를 최신 스펙으로 동기화했습니다.

### 📓 [Sprint 117] 모달 `Shift+I`/`Shift+Q`/`Shift+X` 역순환 추가 (모달 내 19/19 전 순환 단축키 양방향 완성)
- **19/19 전 순환 단축키 양방향 완성 (`detail_modal.gd` · `index.html`)**: `Shift+I`(잉크색), `Shift+Q`(표지색), `Shift+X`(표지아이콘)까지 `step_cyclers` 테이블에 통합해 모달 내 모든 순환 단축키가 `Shift+키` 역순환을 지원합니다.

### 📓 [Sprint 116] 모달 내 16종 순환 단축키 `Shift+키` 역순환(`-1`) 통합 & 웹 목업 동기화
- **모달 `Shift+키` 16종 역순환 통합 (`detail_modal.gd` · `index.html`)**: 모달 내 `W/P/S/R/O/M/G/T/F/A/N/B/K/U/J/Z` 16개 단축키에 `Shift` 조합 시 `-1` 역순환을 지원합니다.

### 🏆 [Sprint 115] 마일스톤 115: 모달 `InkRow` 8종 순환 버튼 우클릭 역순환 완성 (`StampRow`+`InkRow` 전 버튼 양방향화)
- **`InkRow` 8종 우클릭 역순환 완성 (`collection_item.gd` · `detail_modal.gd`)**: `NibBtn`, `SignatureBtn`, `CustomTagBtn`, `FavCharBtn`, `ConditionBtn`, `FinishBtn`, `WeatherBtn`, `SpotBtn` 우클릭 시 이전 프리셋으로 즉시 되돌아갑니다.

### 📓 [Sprint 114] `StampRow` 보관위치·입수경로·기분·소장상태 4종 우클릭 역순환 완성
- **`StampRow` 양방향 조작 완성 (`collection_item.gd` · `detail_modal.gd` · `index.html`)**: `StorageBtn`, `SourceBtn`, `MoodBtn`, `PossessionBtn` 우클릭 시 이전 프리셋으로 즉시 되돌아가며 툴팁에 `· 우클릭: 이전` 안내를 추가했습니다.

### 📓 [Sprint 113] 모달 다꾸 꾸미기 5대 버튼(`띠지`/`마테`/`스티커`/`레어도`/`속지`) 우클릭 역순환 & 툴팁 동기화
- **모달 꾸미기 5종 우클릭 역순환 (`collection_item.gd` · `detail_modal.gd` · `index.html`)**: `ObiCycleBtn`, `TapeCycleBtn`, `DecoStickerBtn`, `RarityBtn`, `PaperBtn` 우클릭 시 이전 프리셋으로 즉시 되돌아가며 툴팁에도 `· 우클릭: 이전` 안내를 추가했습니다.

### 📓 [Sprint 112] 하단 독 바(`WebBtn`/`CamBtn`/`DiyBtn`) 우클릭 파워 액션 & 즉시 JSON 백업 헬퍼 통합
- **하단 독 바 4버튼 우클릭 완성 (`main_view.gd` · `index.html`)**: `WebBtn` 우클릭 시 이북·단행본 필터, `CamBtn` 우클릭 시 가챠노트 필터, `DiyBtn` 우클릭 시 즉시 JSON 백업 저장(`_trigger_instant_json_backup`), `ThemeBtn` 우클릭 시 속지 테마 역순환이 동작합니다.

### 📓 [Sprint 111] 전체 초기화(`0`) KRW 자산 요약 토스트 통일 & `+ 일기 쓰기` 우클릭 즉시 JSON 백업 저장
- **전체 초기화 KRW 요약 통일 (`main_view.gd`)**: `_reset_all_filters()` 실행 시에도 `"📚 전체 서재가 복원되었습니다. (N종 · ₩총액)"` 형태로 다른 탭·검색 토스트와 동일한 자산 요약 피드백을 제공합니다.
- **`+ 일기 쓰기` 우클릭 즉시 JSON 백업 (`main_view.gd` · `index.html`)**: 상단 `TitleRow/AddBtn` 우클릭 시 즉시 `archive_state.save_to_file()`을 수행하고 `💾 로컬 JSON 서재 백업 저장 완료` 토스트와 ₩ 자산 요약을 표시합니다.

### 🏆 [Sprint 110] 마일스톤 110: 모달 `◀`/`▶` 우클릭 첫·끝 페이지 즉시 점프 & 양방향 툴팁 동기화
- **모달 `◀`/`▶` 우클릭 첫·끝 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: `◀` 우클릭으로 첫 페이지(`1/N`), `▶` 우클릭으로 마지막 페이지(`N/N`)로 마우스만으로 즉시 점프합니다.
- **양방향 툴팁 동기화 (`main_view.gd` · `index.html`)**: 모달 헤더 버튼 툴팁에 `(← · 우클릭: 처음)` / `(→ · 우클릭: 끝)` 안내를 추가했습니다.

### [Sprint 109] `TodayQuoteLabel` 우클릭 다음·이전 밑줄 전환 & `AddModal` 작가란 `Enter` 즉시 등록
- **오늘의 밑줄 우클릭 순환 (`main_view.gd` · `index.html`)**: 상단 오늘의 밑줄 문장 라벨을 좌클릭하면 해당 일기장이 열리고, 우클릭(`Shift+우클릭`: 이전)하면 바로 다음 문장으로 넘어갑니다.
- **`AddModal` 작가란 `Enter` 즉시 등록 (`add_modal.gd`)**: 새 일기 추가 모달에서 작가명 입력 후 `Enter`를 누르면 즉시 서재에 등록됩니다.

### [Sprint 108] 책등(Spine) 우클릭 상세 미리보기 & 상단 요약줄(`SubTitle`) 우클릭 클립보드 복사
- **책등 우클릭 상세 미리보기 (`main_view.gd`)**: 상단 책등 배너 우클릭 시 모달을 열지 않고 권수·완독률·소장 가치(`₩`)를 토스트로 바로 미리 볼 수 있습니다.
- **상단 요약줄 우클릭 클립보드 복사 (`main_view.gd` · `index.html`)**: `SubTitle` 좌클릭으로 인포그래픽을 확인하고, 우클릭으로 전체 서재 리포트를 클립보드에 즉시 복사할 수 있습니다.

### [Sprint 107] `Shift+R`·우클릭 랜덤 추천 모달 미개봉 미리보기(`엿보기`) & 메인 치트시트 동기화
- **랜덤 추천 미리보기 (`main_view.gd` · `index.html`)**: `🎲 추천` 버튼 우클릭 및 `Shift+R` 키로 모달을 열지 않고 추천 작품의 제목·날씨·장소·가치(`₩`)를 토스트로 가볍게 미리 볼 수 있습니다.
- **메인 치트시트 동기화 (`main_view.gd`)**: `H` 단축키 안내에 `Shift` 역순환(`S/T/M/Q`)과 `Shift+R` 추천 미리보기를 반영했습니다.

### [Sprint 106] 메인 서재 정렬(`S`)·테마(`T`)·백색소음(`M`) `Shift`·우클릭 양방향 역순환 완성
- **양방향 서재 도구 순환 (`main_view.gd` · `index.html`)**: 정렬(`SortBtn`), 속지 테마(`ThemeBtn`), 백색소음(`AmbientBtn`) 모두 우클릭 및 `Shift+S`/`Shift+T`/`Shift+M`으로 이전 프리셋으로 즉시 되돌아갈 수 있습니다.

### [Sprint 105] `Shift+Q`·우클릭 이전 밑줄 문장 되돌리기 & 권 추가·삭제 KRW 가치 토스트
- **양방향 오늘의 밑줄 탐색 (`main_view.gd` · `index.html`)**: `↻ 문장` 버튼 우클릭 및 `Shift+Q` 키로 이전 밑줄 문장으로 즉시 되돌아갈 수 있습니다.
- **권 추가·삭제 KRW 가치 토스트 (`main_view.gd`)**: 권 추가(`_on_volume_added`) 및 삭제(`_on_volume_removed`) 시 업데이트된 권수와 원화 가치(`₩`)를 토스트로 안내합니다.

### [Sprint 104] 웹 스크랩·카메라 촬영·삭제 KRW 요약 토스트 & `↻ 문장` 버튼 `(n/N)` 툴팁 동기화
- **추가·삭제 전 흐름 KRW 요약 토스트 (`main_view.gd`)**: 웹 표지 스크랩, 폴라로이드 촬영, 일기 삭제 직후에도 갱신된 서재의 `N종 · ₩총액` 요약을 토스트로 즉시 안내합니다.
- **`NextQuoteBtn` `(n/N)` 툴팁 동기화 (`main_view.gd` · `index.html`)**: `↻ 문장` 버튼 툴팁에 `[Q]` 단축키 힌트와 현재 밑줄 순번 `(%d/%d)`을 실시간 표시합니다.

### [Sprint 103] 오늘의 밑줄 순번(`(n/N)`) 툴팁 & 새 일기 등록·우클릭 빠른 기록 KRW 요약 토스트
- **오늘의 밑줄 `(n/N)` 툴팁 (`main_view.gd` · `index.html`)**: 상단 오늘의 밑줄 문장에 마우스를 올리면 작품명과 함께 현재 몇 번째 밑줄인지 `(1/N)` 순번이 표시됩니다.
- **새 일기 등록 & 우클릭 빠른 기록 KRW 요약 (`main_view.gd`)**: 새 일기 등록 시 전체 서재 `N종 · ₩총액`을, 카드 우클릭 `+1권 빠른 기록` 시 해당 작품의 갱신된 가치(`₩`)를 토스트로 즉시 안내합니다.

### [Sprint 102] E-Book `Space`/`PageUp`/`PageDown` 책장 넘김 & 검색창 `ESC` 초기화 요약 토스트
- **E-Book `Space`/`PageUp`/`PageDown` 책장 넘김 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `Space`·`PageDown`으로 다음 일기장, `Shift+Space`·`PageUp`으로 이전 일기장을 바로 넘길 수 있습니다.
- **검색창 `ESC` 초기화 요약 토스트 (`main_view.gd`)**: 검색창에서 `ESC`로 검색어를 지울 때도 현재 서재의 `N종 · ₩총액` 요약을 토스트로 안내합니다.

### [Sprint 101] 모달 내 `X` 키 표지 이모지 아이콘 순환 & `Delete`/`Backspace` 2단계 삭제 안전 트리거
- **모달 내 `X` 표지 아이콘 & `Delete` 2단계 삭제 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `X` 키로 표지 이모지 아이콘을 즉시 순환하고, `Delete`/`Backspace` 키로 2단계 안전 삭제 확인(`ESC` 해제 가능)을 실행할 수 있습니다.
- **툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `CoverRect` 툴팁과 `H` 치트시트에 `[X] 아이콘 · [Del] 삭제`를 추가했습니다.

### 🏆 [Sprint 100] 대망의 마일스톤 100: 모달 `Q`/`Y`/`Z` 키보드 완결 & 단축키 디스패치 테이블 리팩토링
- **모달 `Q` 표지색 · `Y` 회독 · `Z` 소장 상태 순환 (`detail_modal.gd` · `index.html`)**: `Q`(표지 색상), `Y`/`Shift+Y`(재독 ±1), `Z`(소장 상태)를 추가해 모달 내 모든 버튼 100% 키보드 조작을 달성했습니다.
- **23종 단축키 디스패치 테이블 리팩토링 (`detail_modal.gd` · `main_view.gd`)**: `_unhandled_input` 분기문을 `simple_actions`/`shift_pairs` 테이블로 통합하고 버튼 툴팁과 `H` 치트시트를 완성했습니다.

### [Sprint 99] 모달 내 `U` 키 독서 날씨 스탬프 순환 & `J` 키 독서 장소 스탬프 순환
- **모달 내 `U` 날씨 & `J` 장소 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `U` 키로 독서 날씨 스탬프를, `J` 키로 독서 장소 스탬프를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `WeatherBtn` `(U)`, `SpotBtn` `(J)` 툴팁과 `H` 단축키 안내를 동기화했습니다.

### [Sprint 98] 모달 내 `D`/`Shift+D` 복수 소장 ±1 & `K` 키 최애 캐릭터 태그 순환
- **모달 내 `D` 복수 소장 & `K` 최애캐 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `D`(`Shift+D`: -1) 키로 복수 소장 수량을, `K` 키로 최애 캐릭터 태그를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `DuplicateBtn` `(D / Shift+D)`, `FavCharBtn` `(K)` 툴팁과 `H` 단축키 안내를 동기화했습니다.

### [Sprint 97] 모달 내 `N` 키 만년필 펜촉 굵기 순환 & `B` 키 실물 보관 위치 순환
- **모달 내 `N` 펜촉 & `B` 보관 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `N` 키로 만년필 펜촉 굵기(`EF·M·B`)를, `B` 키로 실물 보관 위치를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `NibBtn` `(N)`, `StorageBtn` `(B)` 툴팁과 `H` 단축키 안내를 동기화했습니다.

### [Sprint 96] 모달 내 `F` 키 표지 코팅 마감 순환 & `A` 키 소장·입수 경로 순환
- **모달 내 `F` 마감 & `A` 경로 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `F` 키로 표지 코팅 마감(`무광·유광·홀로그램·양장`)을, `A` 키로 소장·입수 경로를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `FinishBtn` `(F)`, `SourceBtn` `(A)` 툴팁과 `H` 단축키 안내를 동기화했습니다.

### [Sprint 95] 모달 내 `G` 키 실물 컨디션 등급 순환 & `T` 키 커스텀 해시태그 순환
- **모달 내 `G` 등급 & `T` 태그 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `G` 키로 실물 컨디션 등급(`S급`~`개봉전시`)을, `T` 키로 커스텀 해시태그(`#소장각` 등)를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `ConditionBtn` `(G)`, `CustomTagBtn` `(T)`, `ValueBtn` `(V / Shift+V)` 툴팁과 `H` 단축키 안내를 동기화했습니다.

### [Sprint 94] 모달 내 `O` 키 띠지 문구 순환 & `M` 키 독서 기분 태그 순환
- **모달 내 `O` 띠지 & `M` 기분 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `O` 키로 표지 띠지 문구 프리셋을, `M` 키로 독서·수집 기분 태그를 즉시 순환할 수 있습니다.
- **버튼 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `ObiCycleBtn` `(O)`, `MoodBtn` `(M)` 툴팁 힌트와 `H` 단축키 안내를 동기화했습니다.

### [Sprint 93] 모달 내 `S` 키 데코 스티커 순환 & `R` 키 수집 레어도 순환 + 단축키 툴팁
- **모달 내 `S` 스티커 & `R` 레어도 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `S` 키로 데코 스티커 팩을, `R` 키로 수집 레어도 등급(노말~시크릿)을 즉시 순환할 수 있습니다.
- **다꾸 버튼 단축키 툴팁 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: 마테 `(W)`, 스티커 `(S)`, 레어도 `(R)`, 속지 `(P)` 버튼 툴팁 힌트와 `H` 치트시트를 동기화했습니다.

### [Sprint 92] 모달 내 `W` 키 마스킹 테이프 순환 & `P` 키 속지 패턴 순환
- **모달 내 `W` 마테 & `P` 속지 단축키 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `W` 키로 상단 와시테이프 컬러를, `P` 키로 종이 속지 패턴(줄노트·모눈·도트·무지)을 즉시 순환할 수 있습니다.
- **모달 치트시트 동기화 (`main_view.gd`)**: `H` 단축키 안내에 `[W] 마테 · [P] 속지`를 추가했습니다.

### [Sprint 91] 모달 내 `I` 키 만년필 잉크 4종 순환 & `V`/`Shift+V` 소장 가치 ±5,000원 조정
- **모달 내 `I` 키 만년필 잉크 순환 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `I` 키를 눌러 `에스프레소`·`버건디`·`세피아`·`포레스트` 4종 잉크 컬러를 즉시 순환할 수 있습니다.
- **모달 내 `V`/`Shift+V` 소장 가치 조정 (`detail_modal.gd` · `main_view.gd`)**: `V`로 `+5,000원`, `Shift+V`로 `-5,000원` 시세를 빠르게 조정하며 `H` 단축키 안내에도 `[I] 잉크`, `[V] 가치`를 추가했습니다.

### 🏆 [Sprint 90] 마일스톤 90: 모달 내 `1~4` 키 인장 원클릭 찍기 & 단축키 툴팁 힌트 동기화
- **모달 내 `1~4` 키 인장 원클릭 찍기 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 숫자키 `1`~`4`로 `전권완결`·`초판특전`·`인생최애`·`위시리스트` 인장을 즉시 찍을 수 있습니다.
- **버튼 단축키 툴팁 힌트 & 치트시트 동기화 (`detail_modal.gd` · `main_view.gd`)**: `AddVolBtn` `(+)`, `RemVolBtn` `(-)`, `HighlighterBtn` `(L)` 툴팁과 `H` 치트시트(`[1~4] 인장`)를 완성했습니다.

### [Sprint 89] 모달 `ESC` 3단계 안전 해제(`quote_input` 포커스 보호) & `L` 키 형광펜 토글
- **모달 `ESC` 3단계 안전 해제 (`detail_modal.gd` · `index.html`)**: 밑줄 입력창 포커스 중 `ESC`를 누르면 모달이 닫히지 않고 입력창 포커스만 안전하게 해제됩니다.
- **모달 내 `L` 키 형광펜 토글 (`detail_modal.gd` · `main_view.gd`)**: 모달 열람 중 `L` 키로 형광펜 효과를 즉시 켜고 끌 수 있으며 `H` 단축키 안내에도 `[L] 형광펜`을 추가했습니다.

### [Sprint 88] 모달 내 `E` 키 밑줄 문장 즉시 편집 포커스 & 단축키 치트시트 동기화
- **모달 내 `E` 키 밑줄 문장 포커스 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `E` 키를 누르면 즉시 밑줄 입력창 끝으로 커서가 이동해 마우스 없이 바로 문장을 기록할 수 있습니다.
- **모달 단축키 안내 동기화 (`main_view.gd` · `index.html`)**: `H` 단축키 치트시트에 `[E] 문장 편집` 안내를 추가했습니다.

### [Sprint 87] 모달 내 `+`/`-` 키 권 빠른 추가·삭제 & `H` 모달 전용 단축키 안내
- **모달 내 `+`/`-` 권 빠른 추가·삭제 (`detail_modal.gd`)**: 모달 열람 중 `=`/`+` 키로 다음 권을 즉시 추가하고 `-` 키로 마지막 권을 삭제할 수 있습니다.
- **모달 내 `H` 단축키 치트시트 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달 열람 중 `H` 키를 누르면 모달 전용 단축키(`←/→`, `Home/End`, `+/-`, `C`, `ESC`) 안내가 즉시 표시됩니다.

### [Sprint 86] 모달 `PageBadgeLabel` 클릭/우클릭 책장 넘김 & 모달 내 `C` 키 감상 카드 복사
- **클릭 가능한 `PageBadgeLabel` (`detail_modal.gd` · `index.html`)**: 모달 상단 `1/6` 배지 좌클릭(다음)·우클릭(이전)으로 바로 책장을 넘길 수 있습니다.
- **모달 내 `C` 키 감상 카드 복사 (`detail_modal.gd` · `index.html`)**: 모달 열람 중 `C` 키를 누르면 현재 작품의 독서 감상 카드를 클립보드에 즉시 복사합니다.

### [Sprint 85] 모달 `Home`/`End` 첫·끝 일기장 점프 & 초판·스마트 태그 건수·자산 요약 토스트
- **모달 `Home`/`End` 첫·끝 페이지 점프 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달을 연 상태에서 `Home` 키를 누르면 첫 작품(`1/N`), `End` 키를 누르면 마지막 작품(`N/N`)으로 즉시 이동합니다.
- **초판 KPI & 스마트 태그 요약 토스트 (`main_view.gd`)**: 상단 `초판 스탬프` 카드 및 스마트 태그 필터 시에도 `N종 · ₩총액` 요약을 토스트로 안내합니다.

### [Sprint 84] 모달 열기 단일 헬퍼(`_open_detail_modal`) 전 경로 통합 & 정렬 기준 건수·자산 요약 토스트
- **모달 열기 단일 헬퍼 통합 (`main_view.gd`)**: 책등 클릭, 오늘의 밑줄 점프, 카드 클릭, 랜덤 추천, 책장 넘김 5개 모달 진입 경로를 `_open_detail_modal()`로 통합해 언제든 헤더 `n/N` 페이지 배지와 `◀` `▶` 동적 툴팁이 정확히 동기화됩니다.
- **정렬 시 건수·자산 요약 토스트 (`main_view.gd`)**: `↕ 정렬` 순환 시에도 현재 필터 기준 `N종 · ₩총액` 요약을 토스트로 함께 표시합니다.

### [Sprint 83] 실시간 검색 결과 건수·자산 요약 토스트 & 모달 헤더 `PageBadgeLabel` (`n/N`)
- **모달 헤더 페이지 배지 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 모달 상단 `◀` `▶` 버튼 사이에 현재 작품 순번(`1/6`~`6/6`)을 실시간 표시합니다.
- **실시간 검색 결과 요약 토스트 (`main_view.gd`)**: 검색어 입력 시 검색된 작품 수(`N종`)와 원화 총액(`₩`)을 토스트로 즉시 안내합니다.

### [Sprint 82] 5대 서재 탭 전체 건수·자산 요약 토스트 통일 & 모달 `◀` `▶` 동적 작품명 툴팁
- **5대 서재 탭 전체 건수·자산 요약 통일 (`main_view.gd` · `index.html`)**: `전체일기`·`이북·단행본`·`가챠·굿즈`·`완독작`·`인생작` 모든 탭 전환 시 필터링된 작품 수(`N종`)와 원화 총액(`₩`)을 토스트 및 웹 배지로 즉시 표시합니다.
- **모달 `◀` `▶` 버튼 동적 툴팁 (`main_view.gd` · `index.html`)**: 모달 상단 이전/다음 책장 버튼에 마우스를 올리면 이동할 작품의 순번(`(n/N)`)과 제목을 미리 확인할 수 있습니다.

### [Sprint 81] 모달 책장 넘김 페이지 인덱스(`(n/N)`) & 완독·최애 탭 필터 건수/자산 요약 토스트
- **모달 책장 넘김 페이지 인덱스 (`main_view.gd` · `index.html`)**: 모달에서 `◀` `▶` 책장을 넘길 때 토스트에 `(2/6)` 형태로 현재 페이지 순번을 표시하며, 웹 목업 하단 `Page n / N` 표시기도 동적으로 동기화됩니다.
- **완독·최애 탭 필터 건수 & 자산 합계 토스트 (`main_view.gd`)**: 완독/최애 탭 전환 시 필터링된 작품 수(`N종`)와 총 소장 가치(`₩`)를 토스트로 즉시 요약합니다.

### [Sprint 80] 마일스톤 80: 북마크된 권별 행 골드 리본 액센트 & 단축키 `0` 전체 서재 초기화
- **북마크 권별 행 골드 리본 액센트 (`detail_modal.gd`)**: 북마크(`🔖`)가 등록된 권 행 왼쪽에 3px 골드 리본 테두리와 따뜻한 크림 배경을 적용해 최애 권을 한눈에 구분할 수 있습니다.
- **키보드 `0` 전체 서재 초기화 (`main_view.gd` · `index.html`)**: 어떤 검색·필터 상태에서도 숫자 `0` 키를 누르면 즉시 전체 서재가 복원됩니다.

### [Sprint 79] 삭제 경고 빨간색 강조 + ESC 해제 & 서재 카드 우클릭 +1권 빠른 기록(`quick_advance`)
- **삭제 경고 스타일 & `ESC` 해제 (`detail_modal.gd` · `index.html`)**: `일기 삭제` 1차 클릭 시 버튼이 빨간 경고 배지로 강조되며, `ESC` 키를 누르면 모달을 닫기 전에 삭제 확인 상태만 안전하게 해제합니다.
- **서재 카드 우클릭 `+1권 빠른 기록` (`card_item.gd`)**: 서재 목록에서 카드를 마우스 우클릭하면 모달을 열지 않고도 즉시 `+1권` 완독 기록이 추가됩니다.

### [Sprint 78] 일기 삭제 2단계 확인 안전장치(`delete_armed`) & 단축키 `H` 키보드 치트시트 토스트
- **일기 삭제 2단계 확인 안전장치 (`detail_modal.gd`)**: `일기 삭제` 첫 클릭 시 `"⚠️ 삭제 확인"` 상태로 전환되고, 두 번째 클릭 시에만 삭제되어 실수로 인한 기록 유실을 방지합니다.
- **키보드 `H` 단축키 치트시트 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 `H` 키를 누르면 모든 키보드 단축키 요약 치트시트가 표시됩니다.

### [Sprint 77] 모달 헤더 `◀`·`▶` 이전/다음 작품 버튼 & 단축키 `C`(서재 요약 클립보드 복사)
- **모달 헤더 `◀`·`▶` 책장 넘김 버튼 (`detail_modal.gd` · `index.html`)**: 상세 일기장 상단 헤더에 `◀`/`▶` 버튼을 추가해 터치·마우스로도 즉시 이전/다음 작품 일기장으로 이동할 수 있습니다.
- **키보드 `C` 서재 요약 복사 (`main_view.gd`)**: 서재 메인 화면에서 `C` 키를 누르면 전체 서재 일기장 요약 리포트가 클립보드에 복사됩니다.

### [Sprint 76] 모달 좌/우 화살표(`←`·`→`) 책장 넘김 내비게이션 & 단축키 `I`(서재 인포그래픽)
- **모달 `←`/`→` 책장 넘김 (`detail_modal.gd` · `main_view.gd` · `index.html`)**: 상세 일기장 모달을 닫지 않고도 키보드 좌/우 화살표 키로 이전·다음 작품의 일기장으로 바로 넘길 수 있습니다.
- **키보드 `I` 인포그래픽 단축키 (`main_view.gd`)**: 서재 메인 화면에서 `I` 키를 누르면 전체 서재 인포그래픽 브리핑이 즉시 표시됩니다.

### [Sprint 75] 마일스톤 75: 모달 표지 우클릭 색상 순환 & 단축키 `M`(백색소음)·`Q`(오늘의 문장)
- **모달 표지 우클릭 색상 순환 (`detail_modal.gd`)**: 상세 일기장 왼쪽 책 표지를 좌클릭하면 아이콘이, 우클릭하면 표지 색상이 순환됩니다.
- **키보드 `M`·`Q` 단축키 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 `M` 키로 백색소음을 전환하고 `Q` 키로 오늘의 밑줄 문장을 넘길 수 있습니다.

### [Sprint 74] 권별 별점 우클릭 역순환(`reverse_cycle_volume_rating`) & 단축키 `N`(새 일기)·`T`(속지 테마)
- **권별 별점 우클릭 역순환 (`detail_modal.gd`)**: 모달 내 권별 `★` 버튼을 마우스 우클릭하면 별점이 5→4→3 역순으로 순환합니다.
- **키보드 `N`·`T` 단축키 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 `N` 키로 새 일기 쓰기 모달을 열고, `T` 키로 속지 테마를 순환할 수 있습니다.

### [Sprint 73] 소장 가치 우클릭 -5,000원 되돌리기(`reduce_estimated_value`) & 단축키 `S`(정렬)·`R`(랜덤 추천)
- **소장 가치 우클릭 -5,000원 되돌리기 (`detail_modal.gd`)**: 모달의 `💎 +5천원` 버튼을 마우스 우클릭하면 추정 소장 가치를 5,000원씩 되돌릴 수 있습니다(최소 0원).
- **키보드 `S`·`R` 단축키 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 `S` 키로 정렬 기준을 순환하고, `R` 키로 오늘의 랜덤 추천을 즉시 열 수 있습니다.

### [Sprint 72] 회독·복수소장 우클릭 -1 되돌리기(`decrement_*`) & 폴라로이드 촬영 시 전체 서재 전환
- **회독·복수 소장 우클릭 -1 되돌리기 (`detail_modal.gd` · `index.html`)**: 모달의 `🔁회독` 및 `👯×수량` 버튼을 마우스 우클릭하면 실수로 올린 카운트를 1씩 되돌릴 수 있습니다(최소 1 유지).
- **폴라로이드 촬영 시 전체 서재 자동 전환 (`main_view.gd`)**: 필터 탭 상태에서도 폴라로이드 촬영 직후 `전체일기` 탭으로 전환되어 새 카드를 바로 확인할 수 있습니다.

### [Sprint 71] 권별 밑줄 편집 토글 해제 & 새 일기 등록/스크랩 시 전체 서재 자동 전환
- **권별 밑줄 편집 토글 해제 (`detail_modal.gd` · `index.html`)**: 편집 중인 권 대사를 한 번 더 클릭하면 권별 편집 모드가 해제되고 전체 감상평 편집으로 복귀합니다.
- **새 일기 등록·스크랩 시 전체 서재 자동 전환 (`main_view.gd`)**: 다른 필터 탭에 머물러 있더라도 새 작품을 추가하면 자동으로 `전체일기` 탭으로 전환해 즉시 확인할 수 있습니다.

### [Sprint 70] 마일스톤 70: 편집 중인 권별 행 하이라이트 & 서재 탭 단축키·실시간 작품수 툴팁
- **편집 중인 권별 행 하이라이트 (`detail_modal.gd`)**: 권별 대사를 클릭해 편집할 때 해당 권 행이 2px 스탬프 테두리와 따뜻한 크림 배경으로 강조됩니다.
- **서재 탭 단축키 & 실시간 종수 툴팁 (`main_view.gd` · `index.html`)**: 5대 필터 탭에 `[1]~[5]` 단축키 안내와 실시간 작품 종수 툴팁을 적용했습니다.

### [Sprint 69] 감상 카드 복사 완료 피드백(`✅ 복사됨!`) & 숫자키 `1~5` 서재 탭 빠른 전환
- **감상 카드 복사 피드백 (`detail_modal.gd` · `main_view.gd`)**: `💌 공유` 클릭 시 버튼이 `✅ 복사됨!`으로 전환되고 클립보드 복사 완료 토스트가 즉시 표시됩니다.
- **숫자키 `1~5` 탭 단축키 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 숫자 `1~5` 키로 5대 필터 탭을 한 번에 전환할 수 있습니다.

### [Sprint 68] 마지막 권 삭제 전용 토스트 피드백(`volume_removed`) & 키보드 검색 단축키(`/` · `Ctrl/Cmd+F`)
- **권 삭제 전용 토스트 (`detail_modal.gd` · `main_view.gd`)**: 모달에서 마지막 권 삭제 시 `volume_removed` 시그널을 통해 남은 권수와 함께 명확한 삭제 토스트 피드백을 제공합니다.
- **키보드 검색 단축키 (`main_view.gd` · `index.html`)**: 서재 메인 화면에서 `/` 또는 `Ctrl/Cmd+F`를 누르면 즉시 통합 검색창으로 포커스가 이동합니다.

### [Sprint 67] 상단 요약줄(`SubTitle`) 원클릭 인포그래픽 브리핑 & 헤더 버튼 툴팁 완성
- **상단 요약줄 원클릭 인포그래픽 (`main_view.gd`)**: 메인 상단 날짜·완독률·자산 요약 줄(`SubTitle`)을 클릭하면 `show_library_infographic()` 전체 서재 요약 리포트가 하단에 표시됩니다.
- **헤더 버튼 툴팁 완성 (`main_view.gd` · `index.html`)**: `+ 일기 쓰기`, `무음` 버튼 툴팁을 추가하고 웹 목업의 `서재 작품` 카드 클릭 필터를 동기화했습니다.

### [Sprint 66] 모달 표지·와시테이프 인터랙티브 툴팁 & 상단 액션 버튼 안전 가이드
- **표지·와시테이프 인터랙티브 툴팁 (`detail_modal.gd` · `index.html`)**: 모달 내 책 표지와 마스킹 테이프에 포인팅 커서와 클릭 변경 안내 툴팁을 추가했습니다.
- **모달 상단/편집 버튼 7종 툴팁 (`detail_modal.gd`)**: 권 추가/삭제, 감상 카드 공유, 일기 삭제, 밑줄 저장, 형광펜, 닫기 버튼에 상세 툴팁 가이드를 적용했습니다.

### [Sprint 65] 모달 스탬프·잉크 21종 풀 툴팁 가이드 & 바깥 배경(`Dimmer`) 클릭 닫기
- **모달 스탬프·잉크 21종 풀 툴팁 (`detail_modal.gd`)**: 상세 일기장 모달 내 `StampRow`·`InkRow` 21종 다꾸/수집 버튼 전체에 기능 안내 툴팁을 적용했습니다.
- **모달 바깥 배경 클릭 닫기 (`detail_modal.gd` · `add_modal.gd` · `index.html`)**: 상세 일기장과 새 일기 쓰기 모달 바깥의 어두운 오버레이(`Dimmer`)를 클릭하면 모달이 자연스럽게 닫힙니다.

### [Sprint 64] 빈 검색 상태 원클릭 `'🔄 전체 서재 보기'` 복원 버튼 & `AddModal` 제목 자동 포커스
- **빈 상태 원클릭 복원 (`main_view.gd` · `index.html`)**: 검색·필터 결과가 0건일 때 안내 문구와 함께 `'🔄 전체 서재 보기'` 버튼을 제공해 검색어와 필터를 한 번에 초기화할 수 있습니다.
- **`AddModal` 제목 자동 포커스 (`add_modal.gd`)**: `+ 일기 쓰기` 모달을 열면 즉시 제목 입력창에 포커스가 맞춰져 바로 입력을 시작할 수 있습니다.

### [Sprint 63] 권별 노트 툴팁·커서 완성 & 검색창 `ESC` 즉시 초기화
- **권별 노트 툴팁 & 커서 완성 (`detail_modal.gd`)**: 모달 내 권별 초판/소장, 날짜 스탬프, 북마크, 별점 버튼 모두에 포인팅 커서와 상세 안내 툴팁을 추가했습니다.
- **검색창 `ESC` 즉시 초기화 (`main_view.gd` · `index.html`)**: 검색창에서 `Escape` 키 입력 시 검색어가 즉시 초기화되고 전체 서재 목록이 복원됩니다.

### [Sprint 62] 가챠 소장상태 카드 진행률 반영(`전시`/`배송`/`예약`), `AddModal` 지우기 버튼 & 모달 커서 통일
- **가챠 소장 상태 카드 연동 (`card_item.gd` · `index.html`)**: 가챠 카드의 진행률 줄에 `possession_state`에 따른 `전시`·`배송`·`예약` 상태가 반영되며, 웹 목업에도 `🔮×N` 배지가 동기화되었습니다.
- **`AddModal` 지우기 버튼 & 모달 커서 통일 (`add_modal.gd` · `detail_modal.gd`)**: 새 일기 쓰기 입력창 3종에 `✕` 원탭 지우기 버튼을 활성화하고, 양쪽 모달의 모든 스탬프·잉크·액션 버튼에 포인팅 커서를 적용했습니다.

### [Sprint 61] 검색창·인용 입력창 원탭 지우기(`clear_button_enabled`) & 전체 액션 버튼 커서 통일
- **원탭 `✕` 지우기 버튼 (`main_view.gd` · `detail_modal.gd` · `index.html`)**: 서재 통합 검색창과 모달 밑줄 입력창에 네이티브 `✕` 초기화 버튼을 활성화해 한 번에 입력 내용을 지울 수 있습니다.
- **액션 버튼 커서 통일 (`main_view.gd`)**: 상단 `+ 일기 쓰기`, `무음`, `문장`, `추천`, `정렬` 및 필터 탭 버튼 전체에 손가락 포인팅 커서를 적용했습니다.

### [Sprint 60] 마일스톤 60: 키보드 Escape 모달 닫기 & 새 일기 쓰기(`AddModal`) 엔터 연속 입력/등록
- **키보드 `ESC` 모달 닫기 (`detail_modal.gd` · `add_modal.gd` · `index.html`)**: 상세 일기장 및 새 일기 쓰기 모달이 열린 상태에서 `Escape` 키로 즉시 닫을 수 있습니다.
- **새 일기 쓰기 엔터 연속 흐름 (`add_modal.gd`)**: 제목 입력 후 Enter 시 작가 입력창으로 포커스가 이동하고, 감상평 입력 후 Enter 시 즉시 일기가 등록됩니다.

### [Sprint 59] 밑줄 입력창 엔터키 즉시 저장, 가챠 복수소장 배지(`🔮×N`) & macOS/Web 빌드 프리셋 구축
- **엔터키 즉시 저장 & 가챠 복수 소장 배지 (`detail_modal.gd` · `card_item.gd` · `index.html`)**: 모달 밑줄 입력창에서 Enter 키로 즉시 저장할 수 있으며, 가챠 카드 복수 소장 시 우측 하단 배지에 `🔮×N`이 표시됩니다.
- **앱 빌드 프리셋 구축 (`export_presets.cfg`)**: Godot 4.6.2 macOS(`.app`) 및 Web(HTML5) 익스포트 프리셋을 추가해 즉시 빌드가 가능합니다.

### [Sprint 58] 권별 밑줄 원클릭 직접 편집(`start_editing_volume_quote`) & 카드 북마크 수 배지
- **권별 밑줄 원클릭 편집 (`detail_modal.gd` · `index.html`)**: 모달 내 각 권의 대사 라벨을 클릭하면 입력창과 저장 버튼이 해당 권 편집 모드(`"🖋️ N권 저장"`)로 전환되며, 저장 후 기본 상태로 복귀합니다.
- **서재 카드 북마크 수 배지 & 커서 (`card_item.gd`)**: 북마크가 등록된 작품 카드의 우측 하단 배지에 `N권 · 🔖M`을 표시하고 포인팅 커서를 적용했습니다.

### [Sprint 57] 새 일기 쓰기(`AddModal`) 표지 스와치 하이라이트, 빈 제목 경고 피드백 & 초판 필터 동기화
- **표지 스와치 하이라이트 & 빈 제목 가이드 (`add_modal.gd`)**: 새 일기 쓰기 모달에서 선택된 표지 컬러 버튼에 `✓` 체크마크와 2px 테두리를 표시하고, 제목 미입력 시 경고 안내 문구와 자동 포커스를 제공합니다.
- **초판 스탬프 필터 동기화 (`main_view.gd` · `index.html`)**: 상단 `초판 스탬프` 카드 클릭 시 이전 필터 상태를 초기화하고 탭 하이라이트를 정확히 동기화합니다.

### [Sprint 56] 활성 인장 스탬프 하이라이트 & 형광펜 버튼 ON/OFF 상태 시각화
- **활성 인장 스탬프 강조 (`detail_modal.gd` · `index.html`)**: 현재 선택된 인장(`💮전권완결`, `🔖초판특전`, `♥인생최애`, `✨위시`) 버튼에 2px 스탬프 레드 테두리와 블러시 배경을 적용해 선택 상태를 한눈에 구분합니다.
- **형광펜 ON/OFF 버튼 시각화 (`detail_modal.gd`)**: `🖍️ 형광펜` 활성화 시 버튼 텍스트가 `"🖍️ 형광펜 ON"`으로 바뀌며 노란 하이라이트 배경과 2px 앰버 테두리가 표시됩니다.

### [Sprint 55] 활성 만년필 잉크 스와치 하이라이트, 오늘의 밑줄 동적 툴팁 & 검색 빈 상태 가이드
- **활성 만년필 잉크 스와치 강조 (`detail_modal.gd`)**: 현재 선택된 만년필 잉크(`☕에스프레소`, `🍷버건디`, `🍂세피아`, `🌲포레스트`) 버튼에 2px 잉크 컬러 테두리와 하이라이트 배경을 표시해 선택 상태를 직관적으로 보여줍니다.
- **오늘의 밑줄 동적 툴팁 & 빈 검색 상태 안내 (`main_view.gd` · `index.html`)**: 오늘의 밑줄 배너와 상단 통계 카드에 손가락 포인팅 커서 및 동적 책 열기 툴팁을 추가하고, 검색 결과가 없을 때 `EmptyStateLabel` 안내 메시지를 표시합니다.

### [Sprint 54] 가챠 체크리스트 3줄 메타 요약, 감상 카드 회독·복수소장 연동 & 하단 내비게이션 툴팁
- **가챠 체크리스트 & 감상 공유 카드 강화 (`detail_modal.gd`)**: 가챠·굿즈 체크리스트에 소장 경로·기분·최애 요약을 추가하고, `copy_book_quote_card()` 공유 카드에 회독수(`🔁`)와 복수 소장(`👯×`)을 함께 기록합니다.
- **하단 내비게이션 툴팁 완성 (`main_view.gd`)**: 하단 4대 액션 버튼(웹표지 스크랩·폴라로이드 촬영·새 일기 쓰기·속지 테마)에 직관적인 툴팁 가이드를 추가했습니다.

### [Sprint 53] 가챠 파츠 체크리스트 헤더 실시간 갱신(`_refresh_vol_header`) & 통합 검색창·액션 버튼 파워 툴팁
- **가챠 체크리스트 헤더 실시간 동기화 (`detail_modal.gd`)**: 가챠·굿즈 모달에서 보관 위치나 컨디션 등급을 변경하면 체크리스트 헤더(`🔮 가챠 · 굿즈 파츠 체크리스트`)도 즉시 실시간 갱신됩니다.
- **통합 검색창·액션 버튼 파워 툴팁 (`main_view.gd`)**: 검색창과 `↻ 문장`, `🎲 추천`, `↕ 정렬` 버튼에 통합 검색 필드(작품·작가·대사·태그·위치·날씨·장소·소장경로) 및 순환 안내 툴팁을 추가했습니다.

### [Sprint 52] 모달 권별 북마크 개수(`🔖 N`) 헤더 표시 & 상단 4대 통계 카드 리치 툴팁 연동
- **모달 권별 북마크 카운트 (`detail_modal.gd`)**: 권별 밑줄 노트 헤더에 북마크가 꽂힌 권수(`· 🔖1` 등)를 실시간으로 함께 표시합니다.
- **상단 4대 통계 카드 리치 툴팁 (`main_view.gd`)**: 상단 통계 카드(서재 작품·단행본·초판·가챠) 호버 시 평균 별점·총 자산·완독률·초판 비율·굿즈 자산 세부 지표를 툴팁으로 안내합니다.

### [Sprint 51] 서재 카드 리치 툴팁(`tooltip_text`) & 일기장 수정 시 '오늘의 밑줄' 배너 실시간 동기화
- **서재 카드 리치 툴팁 (`card_item.gd`)**: 카드에 마우스를 올리면 보관 위치, 독서 날씨·장소, 표지 질감, 컨디션 등급, 소장 가치가 요약 툴팁으로 즉시 표시됩니다.
- **'오늘의 밑줄' 배너 실시간 동기화 (`main_view.gd`)**: 모달에서 밑줄 문장이나 메모를 수정·저장하면 메인 상단 '오늘의 밑줄' 배너도 즉시 최신 문장으로 갱신됩니다.

### [Sprint 50 — 마일스톤] 가챠 체크리스트 보관·등급 헤더, 랜덤 추천 날씨·장소 연동 & `format_krw` 중복 제거
- **가챠 파츠 체크리스트 헤더 고도화 (`detail_modal.gd`)**: 가챠·굿즈 모달의 체크리스트 헤더에 보관 위치(`🗄️ 1층 장식장`)와 컨디션 등급(`✨ S급(최상)`)을 함께 표시합니다.
- **랜덤 추천 감성 토스트 & 금액 포맷 단일화 (`main_view.gd`, `detail_modal.gd`)**: `🎲 추천` 시 추천 작품의 독서 날씨·장소 스팟을 안내하며, 모든 금액 포맷을 `ArchiveState.format_krw()` 단일 헬퍼로 통일했습니다.

### [Sprint 49] 상단 KPI 평균 별점(`★5.0`) 병기, 모달 권별 목표 달성률(`3/3권 · 100%`) & `format_krw` 헬퍼 통일
- **상단 KPI & 인포그래픽 브리핑 고도화 (`main_view.gd`)**: 메인 헤더(`📔 2026. 11. 16 · 완독 81% · ★5.0 · 자산 ₩80,000`)와 서재 인포그래픽 브리핑에 전체 서재 평균 별점(`★5.0`)을 함께 표시합니다.
- **모달 권별 목표 달성률 & 정적 헬퍼 통일 (`detail_modal.gd`, `card_item.gd`)**: 권별 밑줄 노트 헤더에 `소장 3/3권 · 100% · 초판 2권` 진행률을 표시하고 `ArchiveState.format_krw()` 정적 헬퍼로 금액 포맷을 통일했습니다.

### [Sprint 48] 권별 별점·권수·복수소장 변경 시 모달 상단 실시간 동기화 & 서재 전체 평균 별점(`get_average_library_rating`) 연동
- **모달 상단 별점·가치 실시간 동기화 (`detail_modal.gd`)**: 권별 별점(`cycle_volume_rating`), 권 추가/삭제, 복수 소장(`increment_duplicate_count`) 시 모달 상단 `AuthorLabel`의 평균 별점(`★`)과 소장 가치(`💎 ₩`)가 즉시 갱신됩니다.
- **서재 전체 평균 별점 백업 연동 (`archive_state.gd`)**: `get_average_library_rating()`을 추가해 `export_diary_summary()` 상단 헤더에 서재 전체 평균 별점(`평균 ★5.0`)을 함께 기록합니다.

### [Sprint 47] 모달 상단 작가·평점·가치 통합(`_refresh_author_label`) & 서재 백업 요약 내 날씨·장소·가치 통합
- **모달 상단 작가·별점·소장 가치 통합 (`_refresh_author_label`)**: 일기장 모달 상단과 감상 카드 공유 텍스트에 평균 별점(`★5.0`)과 포맷된 소장 가치(`💎 ₩21,000`)를 함께 표시합니다.
- **서재 백업 요약 고도화 (`export_diary_summary`)**: 텍스트 백업 요약의 각 작품 항목에 작품별 소장 가치(`₩`), 독서 날씨(`☀️ 맑은 오후`), 독서 장소(`🛋️ 이불 속`)가 모두 기록됩니다.

### [Sprint 46] 모달 스탬프 `_refresh_tag_label()` 단일 경로 통합 & 서재 카드 진행률·소장 가치(`₩21,000`) 병기
- **모달 상단 메타 단일 경로 통합 (`_refresh_tag_label`)**: 기분·등급·보관위치·소장경로·날씨·장소 중 어떤 스탬프를 눌러도 상단 메타가 `[기분 · 등급 · 보관위치 · 날씨 · 장소]` 형식으로 일관되게 유지됩니다.
- **서재 카드 진행률·소장 가치 병기 (`card_item.gd`)**: 카드 하단 진행률 바 우측에 `완독 · ₩21,000` / `75% · ₩21,000` / `보관 · ₩5,000` 형태로 작품별 소장 가치를 잘림 없이 표시합니다.

### [Sprint 45] 모달 메타 라벨·감상 카드 공유 내 독서 날씨·장소 스팟 통합 동기화 & 소장 경로 검색 검증
- **모달 상단 메타 & 감상 카드 공유 통합 (`_refresh_tag_label` / `copy_book_quote_card`)**: 일기장 모달 상단 메타 요약(`TagLabel`)과 감상 카드 공유 텍스트에 `reading_weather`와 `reading_spot`이 모두 실시간 반영됩니다.
- **소장 경로(`acquisition_source`) 통합 검색 & 웹 목업 동기화**: 검색창에서 구매처·소장 경로(`오프라인 서점` 등) 키워드 매칭을 통합 테스트로 검증하고 `game02/index.html` 메타 배지를 동기화했습니다.

### [Sprint 44] 독서 장소 스팟 스탬프(`🛋️ 이불 속`), 날씨·장소 통합 검색 & 표지 질감 광택 유지
- **독서 장소 스팟 스탬프 (`SpotBtn` / `cycle_reading_spot`)**: 다이어리 모달 `InkRow`에서 `🛋️ 이불 속 → ☕ 북카페 → 🪑 내 방 책상 → 🚃 출퇴근길` 4단계 독서 장소를 원터치로 기록하고 JSON으로 영속 저장합니다.
- **독서 날씨·장소 통합 검색 & 표지 광택 복원**: 검색바에서 `reading_weather`와 `reading_spot` 키워드까지 즉시 필터링되며, 모달 재오픈 시에도 `cover_finish`에 따른 2.5D 표지 질감 광택이 일관되게 유지됩니다.

### [Sprint 43] 감성 독서 날씨 스탬프(`☀️ 맑은 오후`) & 표지 마감 질감 실시간 2.5D 광택 반영
- **감성 독서 날씨 스탬프(`cycle_reading_weather`)**: `☀️ 맑은 오후`, `🌧️ 비 오는 밤`, `❄️ 눈 내리는 창가`, `🌙 새벽 감성` 4종 날씨 스탬프를 모달에서 원터치 순환 및 감상 카드 공유 연동
- **표지 마감 질감 실시간 2.5D 광택 반영**: `_apply_cover_finish_style()`로 홀로그램/유광/패브릭 선택 시 모달 표지 광택·명암 즉시 변경 (`game02/index.html` 동기화)

### [Sprint 42] 표지·책등 마감 질감(`📜 무광 매트`) · 컨디션·마감 통합 검색 · 백업 요약 총 자산 연동
- **표지·책등 마감 질감(`cycle_cover_finish`)**: `📜 무광 매트`, `✨ 유광 코팅`, `🌟 홀로그램`, `🧶 패브릭 양장` 4종 표지 질감을 모달에서 원터치 순환 및 JSON 영구 보존
- **컨디션·마감 통합 검색 & 요약 내보내기 고도화**: `get_filtered_items()`에서 컨디션·마감 키워드 검색 지원 및 `export_diary_summary()`에 `총 자산 ₩...` 포함 (`game02/index.html` 동기화)

### [Sprint 41] 보존 상태·컨디션 등급(`✨ S급(최상)`) & 최애 캐릭터 통합 검색·공유 연동
- **보존 상태·컨디션 등급(`cycle_condition_grade`)**: `✨ S급(최상)`, `📖 A급(양호)`, `🏷️ B급(사용감)`, `📦 미개봉(새상품)` 4종 컨디션 등급을 모달에서 원터치 순환 및 JSON 영구 보존
- **최애 캐릭터 통합 검색 & 공유 카드 연동**: `get_filtered_items()` 및 `index.html` 검색창에서 최애 캐릭터명으로 즉시 필터링하고 감상 카드 공유에 컨디션·캐릭터 정보 포함

### [Sprint 40] 4단 정렬 사이클러(`↕ 가치순` 추가) & 최애 캐릭터 스탬프(`🌟 최애 캐릭터`)
- **4단 정렬 사이클러(`SortBtn`)**: `↕ 기본순` → `↕ 다독순` → `↕ 최신순` → `↕ 가치순` 4단 순환으로 추정 가치 높은 소장품부터 정렬
- **최애 캐릭터 스탬프(`cycle_favorite_character`)**: `🏀 강백호`, `🧙‍♀️ 프리렌`, `🐾 치이카와`, `🏐 히나타`, `🌸 체리` 등 최애 캐릭터 스탬프 원터치 순환 (`game02/index.html` 동기화)

### [Sprint 39] 모달 태그·띠지 줄바꿈 개선(`autowrap_mode = 3`) & 추정 가치 +₩5,000 원터치 조정
- **모달 태그·띠지 줄바꿈(`TagLabel`)**: `autowrap_mode = 3` 적용으로 긴 띠지·무드·보관위치 문구가 말줄임 없이 깔끔하게 줄바꿈 표시
- **추정 가치 +₩5,000 원터치 조정(`boost_estimated_value`)**: 모달 `💎 +5천원` 버튼으로 프리미엄/한정판 시세를 즉시 반영하고 헤더 총 자산까지 실시간 갱신 (`game02/index.html` 동기화)

### [Sprint 38] 커스텀 태그·보관위치 통합 검색 · 모달 추정 가치 표시 · 감상 카드 서명 공유
- **커스텀 태그·보관위치·입수처 통합 검색**: `archive_state.gd` `get_filtered_items()` 및 `index.html` 검색창에서 `#소장각`, `1층 장식장`, `오프라인 서점` 등으로 즉시 필터링
- **모달 추정 가치 & 감상 카드 서명 공유**: 모달 상단에 `💎 ₩21,000` 추정 가치를 표시하고 `copy_book_quote_card()` 복사본에 커스텀 태그와 일기장 서명(`✍️ 주희의 서재`)을 포함

### [Sprint 37] 원화 천 단위 콤마 포맷터(`format_krw`) · 실시간 오늘 날짜 헤더 · 커스텀 키워드 태그(`#소장각`)
- **원화 천 단위 콤마 & 실시간 날짜 헤더**: `archive_state.gd` `format_krw()`로 `₩80,000` 콤마 포맷을 적용하고 메인 상단 날짜를 오늘 날짜(`YYYY. MM. DD`)로 자동 갱신
- **커스텀 키워드 태그(`cycle_custom_tag`)**: `#소장각`, `#인생만화`, `#힐링타임`, `#전시필수`, `#한정특전` 5종 해시태그를 모달에서 원터치 순환 및 JSON 영구 보존
- **웹 목업 동기화**: `game02/index.html`에 `cycleCustomTag()` 버튼 완벽 연동

### [Sprint 36] 소장·구매 기념일 스탬프(`📅 기념일`) · 배송 상태 카드 배지 · 헤더 실시간 총 자산 요약
- **소장·구매 기념일 스탬프(`stamp_purchase_date`)**: 모달 `InkRow`의 `📅 기념일` 버튼으로 오늘 날짜(`📅 MM.DD`)를 원터치 스탬프하고 JSON 영구 보존
- **배송·예약 상태 카드 배지**: `🛒 예약중`, `🚚 배송중`, `✨ 전시중` 상태일 때 메인 카드 하단에 상태 배지를 자동 표시
- **헤더 실시간 총 자산 요약**: 서재 상단 서브타이틀에 `서재 완독률 · 자산 ₩...` 실시간 표시 및 `game02/index.html` 동기화

### [Sprint 35] 메인 `FilterBar` `HFlowContainer` 줄바꿈 개선 & 소장품 배송·보유 상태 트래커(`📦 소장중` / `cycle_possession_state`)
- **메인 `FilterBar` `HFlowContainer` 줄바꿈**: `main.tscn`의 `FilterBar/HBox`를 `HFlowContainer`로 전환해 `↕ 기본순` 버튼 우측 클리핑을 해소하고 필터·검색·정렬 UI를 깔끔히 정렬
- **소장품 배송·보유 상태 트래커(`cycle_possession_state`)**: `📦 소장중`, `🛒 예약중`, `🚚 배송중`, `✨ 전시중` 4종 배송·전시 상태를 모달에서 원터치 순환
- **웹 목업 동기화**: `game02/index.html`에 `cyclePossessionState()` 버튼 완벽 연동

### [Sprint 34] `InkRow` `HFlowContainer` 줄바꿈 개선 · 일기장 서명 스탬프(`✍️ 주희의 서재`) · 서재 총 재독 브리핑(`get_total_rereads`)
- **`InkRow` `HFlowContainer` 줄바꿈**: `detail_modal.tscn`의 `InkRow`를 `HFlowContainer`로 전환해 `✒️펜촉` 버튼 우측 클리핑을 해소하고 모달 내부에 깔끔히 정렬
- **일기장 서명 스탬프(`cycle_diary_signature`)**: `✍️ 주희의 서재`, `🌙 밤독서 기록`, `☕ 카페 다꾸`, `🎁 소장 기념` 4종 서명 스탬프 원터치 순환
- **서재 총 재독 브리핑(`get_total_rereads`)**: `show_library_infographic()` 통계 토스트에 `총 재독: N회` 실시간 합산 표시 및 `game02/index.html` 동기화

### [Sprint 33] 일기장 모달 `HFlowContainer` 반응형 줄바꿈 개선 & 수집품 보유·중복 수량 카운터(`👯×N`)
- **일기장 모달 `HFlowContainer` 줄바꿈**: `detail_modal.tscn`의 `StampRow`를 `HFlowContainer`로 전환해 13종 이상의 인장·다꾸 버튼이 408px 모달 안에 깔끔하게 줄바꿈 정렬되도록 개선
- **수집품 보유·중복 수량 카운터(`increment_duplicate_count`)**: 모달 `👯×1` 버튼으로 중복 보유 수량을 기록하고, 추정 가치 합산 반영 및 2개 이상일 때 카드에 `👯×N` 배지 표시
- **웹 목업 동기화**: `game02/index.html`에 `incrementDuplicateCount()` 버튼 및 카드 `👯 ×N` 배지 완벽 연동

### [Sprint 32] 재독 횟수 카운터(`🔁 N회독` / `increment_reread_count`) & 소장품 추정 가치·서재 총 자산 브리핑(`get_total_collection_value`)
- **재독 횟수 카운터(`increment_reread_count`)**: 모달 `StampRow`의 `🔁1회독` 버튼으로 재독 횟수를 누적 기록하고, 2회독 이상부터 메인 카드에 `🔁N회독` 배지 표시
- **소장품 추정 가치 & 총 자산 브리핑(`get_total_collection_value`)**: 권수와 레어도 등급을 반영한 서재 총 소장 가치를 계산하여 `show_library_infographic()` 통계 토스트로 실시간 브리핑
- **웹 목업 동기화**: `game02/index.html`에 `incrementRereadCount()` 버튼 및 카드 `🔁 N회독` 배지 완벽 연동

### [Sprint 31] 독서 감상 무드 태그(`🥰 힐링` / `cycle_reading_mood`) & 목표 권수 정밀 완독률 트래커(`target_volumes`)
- **독서 감상 무드 태그(`cycle_reading_mood`)**: `🥰 힐링`, `🔥 열혈`, `😭 감동`, `🤯 반전`, `🤣 유쾌` 5종 무드 스티커 원터치 순환
- **목표 권수 기반 정밀 완독률(`get_completion_percentage`)**: 소장 목표 권수 대비 정확한 완독 퍼센티지 계산 및 카드 진행률 바 연동
- **웹 목업 동기화**: `game02/index.html`에 `cycleReadingMood()` 버튼 완벽 연동

### [Sprint 30] 독서 몰입 앰비언트 백색소음(`🎧 앰비언트` / `cycle_ambient_sound`) & 소장품 입수처 트래커(`🏷️ 입수처` / `cycle_acquisition_source`)
- **독서 몰입 앰비언트 백색소음(`cycle_ambient_sound`)**: 메인 상단에서 6종 백색소음(`🔕무음`, `🌧️빗소리`, `☕북카페`, `📖책장넘김`, `🔥모닥불`, `🦗밤귀뚜라미`)을 원터치 순환 및 재생
- **소장품 입수처 트래커(`cycle_acquisition_source`)**: `🏪 오프라인 서점`, `🇯🇵 직구/해외`, `🎁 선물`, `🎪 팝업/행사`, `📦 온라인 서점` 5종 입수 경로 관리
- **웹 목업 동기화**: `game02/index.html`에 앰비언트 백색소음 및 입수처 트래커 완벽 연동

### [Sprint 29] 일기장 종이 내지 패턴(`📜 종이질감` / `cycle_paper_pattern`) & 실물 보관 위치 트래커(`🗄️ 보관위치` / `cycle_storage_location`)
- **일기장 종이 패턴 순환(`cycle_paper_pattern`)**: `📄줄노트`, `📜모눈`, `📋무지`, `🍂양장` 4종 종이 스타일을 원터치 순환하여 아날로그 몰스킨 감성 극대화
- **실물 소장품 보관 위치 트래커(`cycle_storage_location`)**: `🗄️ 1층 장식장`, `📦 아크릴함`, `📚 책상 선반`, `🎒 외출 파우치` 등 실물 굿즈 위치 관리
- **웹 목업 동기화**: `game02/index.html`에 종이 질감 순환 및 보관 위치 트래커 완벽 연동

### [Sprint 28] 소장품 레어도 등급 순환(`💎 레어도` / `cycle_rarity_tier`) & 스마트 퀵 태그 필터(`filter_by_smart_tag`)
- **소장품 레어도 등급 순환(`cycle_rarity_tier`)**: 모달 내 `💎레어` 버튼으로 4종 등급(`🌟노말`, `💎레어`, `👑슈퍼레어`, `🔮시크릿`)을 원터치 순환 및 메인 가챠 카드 배지에 실시간 반영
- **스마트 퀵 태그 필터링(`filter_by_smart_tag`)**: `#완독`, `#초판`, `#인생작`, `#가챠`, `#만화` 등 핵심 카테고리/속성을 1초 만에 스마트 필터링
- **웹 목업 동기화**: `game02/index.html`에 `cycleRarityTier()` 및 가챠 카드 레어도 배지 완벽 연동

### [Sprint 27] 일기장 다꾸 데코 스티커 팩(`✨ 스티커` / `cycle_deco_sticker`) & 1초 퀵 진도 추가(`quick_advance_volume`)
- **다꾸 데코 스티커 팩(`DecoStickerBtn` / `cycle_deco_sticker`)**: 일기장 모달에서 6종 데코 스티커(`✨`, `🌸`, `☕`, `🌙`, `🍀`, `🎧`)를 원터치로 변경하고 일기장 상단 및 메인 카드 배지에 실시간 반영
- **1초 퀵 진도 추가(`quick_advance_volume`)**: 다음 권 독서 완료 시 1초 만에 권수 추가 및 서재 통계 자동 갱신
- **웹 목업 동기화**: `game02/index.html`에 `cycleDecoSticker()` 스티커 팩 순환 버튼 완벽 연동

### [Sprint 26] 마스킹 테이프 색상 순환(`🎨 마테` / `cycle_washi_tape`) & 서재 인포그래픽 통계 브리핑(`show_library_infographic`)
- **다꾸 마스킹 테이프 색상 순환(`TapeCycleBtn` / `cycle_washi_tape`)**: 일기장 모달 상단 마스킹 테이프를 5종 파스텔 팔레트(`버터옐로우`, `피치핑크`, `세이지그린`, `스카이블루`, `라벤더`)로 원터치 변경하고 상태를 영구 보존
- **서재 통계 인포그래픽 브리핑(`show_library_infographic`)**: 서재 전체의 소장 총 권수, 완독 권수, 북마크 권수, 평균 평점을 정갈한 요약 브리핑 카드로 출력
- **웹 목업 동기화**: `game02/index.html`에 `applyJournalWashiTape` 및 `cycleWashiTape()` 완벽 동기화

### [Sprint 25] 만년필 펜촉 두께 순환(`✒️ 펜촉` / `cycle_pen_nib_size`) & 독서 감상 카드 공유(`copy_book_quote_card`)
- **만년필 펜촉 두께 순환(`cycle_pen_nib_size`)**: 일기장 모달에서 10px(세필), 12px(중필), 14px(태필) 폰트 크기를 순환 선택하여 캘리그래피 손글씨 감성 구현
- **독서 감상 카드 클립보드 복사(`copy_book_quote_card`)**: 모달 내 `💌 공유` 버튼으로 작품명, 스탬프, 평점, 밑줄 문장이 담긴 감상 카드를 시스템 클립보드에 원터치 복사
- **가챠 굿즈 전용 배지 라벨링**: `card_item.gd`에서 가챠 소장품에 `🔮가챠` 배지와 전시 여부 텍스트 제공
- **웹 목업 동기화**: `game02/index.html`에 펜촉 크기 순환 및 감상 카드 복사 기능 반영

### [Sprint 24] 권별 골드 북마크 리본(`🔖 북마크` / `toggle_volume_bookmark`) & 서재 카드 북마크 배지 연동
- **권별 북마크 토글(`toggle_volume_bookmark`)**: 펼친 독서노트 모달에서 각 권의 밑줄 명대사에 북마크 리본(`🔖/🏷️`)을 꽂아 특별히 소중한 권을 마킹
- **서재 카드 북마크 연동**: 북마크된 권수가 있는 도서는 메인 화면 표지 권수 배지에 골드 북마크 리본(`🔖`)이 동적 표시
- **웹 목업 동기화**: `game02/index.html`에 권별 북마크 토글 인터랙션(`toggleVolBookmark`) 완벽 반영

### [Sprint 23] 3단 정렬 사이클러(`↕ 최신순`) & 미니 책등 호버 미리보기 툴팁(`Spine Hover Tooltip`)
- **3단 정렬 사이클러(`SortBtn`)**: 단행본 정렬을 `↕ 기본순` ↔ `↕ 다독순` ↔ `↕ 최신순`으로 3단계 순환하여 최근 메모한 작품을 한눈에 우선 배치
- **미니 책등 호버 미리보기**: 상단 미니 책등 선반에 마우스를 올리면 작품명과 소장 권수가 툴팁 및 하단 토스트로 즉각 안내

### [Sprint 22] 밑줄 형광펜 하이라이터(`🖍️ 형광펜` / `toggle_quote_highlight`) & 만점 인생작 전용 필터(`★ 인생작`)
- **밑줄 형광펜 하이라이터(`HighlightBtn`)**: 일기장 속 가장 마음에 와닿은 명대사에 부드러운 파스텔 옐로우 하이라이트 배경 띠를 온/오프 토글 가능
- **만점 인생작 필터 탭(`TabFav`)**: 평균 평점 5.0 만점작 및 `♥인생최애` 스탬프 소장품만 원터치로 선별해 모아보기
- **웹 목업 풀 동기화**: `game02/index.html`에 만년필 잉크 팔레트, 형광펜 토글, 랜덤 추천 기능 완벽 반영

### [Sprint 21] 만년필 잉크 컬러 선택기(`INK_PRESETS` / `set_fountain_pen_ink`) & 감성 서재 룸 테마 연동
- **만년필 잉크 컬러 선택기(`InkRow` / `set_fountain_pen_ink`)**: 펼친 독서노트 모달에서 4종 만년필 잉크(`☕에스프레소`, `🍷버건디`, `🍂세피아`, `🌲포레스트`) 스와치를 원터치로 선택하여 명대사 밑줄 텍스트 색상을 실시간으로 변경 및 로컬 JSON에 영구 보존
- **서재 테마와의 조화**: 4대 룸 테마(`미색 노트`, `크라프트지`, `세피아 리더`, `세이지 일기장`) 배경과 잉크 톤이 완벽하게 어우러지는 아날로그 만년필 필기 감성 구현

### [Sprint 20] 권별 독서 날짜 타임스탬프(`📅 11.12`) & 서재 전체 완독률 실시간 게이지(`81%`)
- **권별 독서 날짜 타임스탬프**: 펼친 독서노트 모달에서 각 권의 `📅 11.12` 날짜 스탬프를 클릭하여 언제 읽었는지 기록하고 영구 보존
- **서재 전체 완독률 실시간 게이지**: 소장 도서의 진행률을 종합하여 상단 서재 헤더에 `서재 완독률 81%`를 실시간으로 노출

### [Sprint 19] 랜덤 추천 작품 뽑기(`🎲 추천` / `pick_random_item`) & 완독작 전용 필터 탭(`💮 완독작`) 탑재
- **랜덤 오늘의 추천작 뽑기(`🎲 추천`)**: 상단 배너에서 원터치로 소장품 중 1종을 무작위 추첨하여 독서노트 모달을 열어주는 랜덤 책갈피 기능
- **완독작 전용 필터 탭(`💮 완독작`)**: 필터바에 완독작 탭을 추가해 완독 100% 도달한 인생 명작들만 한눈에 모아보기 지원

### [Sprint 18] E-Book 독서 진행률 트래커(`ReadingProgressBar`) & 권별 완독률 퍼센티지(`완독 100%`) 탑재
- **독서 진행률 프로그레스 바**: 리디북스·밀리의 서재 레퍼런스를 반영해 각 카드마다 미색 종이 질감과 테라코타 잉크로 채워지는 미니 독서 진행률 바 및 `완독 100%`, `75%` 퍼센티지 표시
- **완독 상태 자동 연동**: `💮전권완결` 도장이 찍힌 작품은 즉시 완독 100%로 도달하며 소장 권수에 비례한 독서 트래킹 제공

### [Sprint 17] 모달 내 북커버 색상 순환(`cycle_cover_color`) · 미니 책등 금박 책갈피 팁 · 서재 요약 클립보드 복사(`copy_summary_to_clipboard`)
- **모달 내 북커버 컬러 순환(`cycle_cover_color`)**: 펼친 독서 일기장 모달에서 7종 북커버 색상을 즉시 변경·저장
- **미니 책등 금박 책갈피 팁**: 상단 미니 책등 진열대(`SpineShelfRow`) 상단에 골드 책갈피 리본 디테일 적용
- **클립보드 요약 리포트 복사(`copy_summary_to_clipboard`)**: 전체 독서 일기장 요약 리포트를 시스템 클립보드에 즉시 복사

### [Sprint 16] 오늘의 밑줄 문장 터치 바로가기(`open_current_quote_item`) & 모달 표지 다꾸 스티커 이모지 변경(`cycle_cover_icon`)
- **오늘의 밑줄 문장 터치 바로가기**: 상단 배너의 오늘의 밑줄 문장을 클릭하면 해당 명대사가 수록된 작품의 독서 일기장이 즉시 펼쳐짐
- **모달 표지 다꾸 이모지 변경(`cycle_cover_icon`)**: 펼친 독서 일기장 좌측 표지를 클릭해 12종 다꾸 스티커 이모지(`📖`, `📕`, `✨`, `🎀`, `🏆`, `🔮` 등)를 원터치 변경

### [Sprint 15] 모달 내 표지 스크랩 마스킹 테이프(`ModalWashiTape`) · 책등 제본선(`ModalSpineStrip`) · 마지막 권 삭제(`remove_last_volume`)
- **모달 표지 다꾸 디테일**: 펼친 독서노트 모달 좌측 표지에 반투명 마스킹 테이프(`ModalWashiTape`)와 좌측 책등 제본선(`ModalSpineStrip`) 적용
- **마지막 권 삭제(`- 권 삭제` / `remove_last_volume`)**: 실수로 추가한 권 기록을 원터치로 되돌리고 통계·JSON에 즉시 반영

### [Sprint 13 ~ 14] 상단 통계 북마크 원터치 필터 · 카드 평균 별점(`★5.0`) · 단행본 띠지 원터치 변경(`🏷️띠지`) · 요약 리포트(`export_diary_summary`)
- **인터랙티브 통계 북마크**: 상단 `서재 작품`, `단행본 기록`, `초판 스탬프`, `가챠 스크랩` 카드를 클릭하면 해당 조건(초판 보유작 등)으로 서재를 즉시 필터링
- **카드 평균 별점(`· ★5.0`) & 모달 내 `🏷️띠지` 원터치 변경**: 서재 카드에 권별 평균 별점을 표시하고, 일기장 모달에서 `🏷️띠지` 버튼으로 단행본 띠지 문구를 즉시 교체
- **독서 일기장 요약 리포트(`export_diary_summary`)**: 전체 소장 현황 및 작품별 스탬프·띠지 목록을 텍스트 리포트로 생성

### [Sprint 12] 권별 밑줄 대사 개별 편집(`update_volume_quote`) & 가챠·굿즈 스크랩북 체크리스트 탑재
- **권별 밑줄 문장 개별 편집**: 작품 전체 메모뿐 아니라 특정 권(`1권`, `2권`, `3권`...)의 밑줄 명대사를 직접 수정·저장(`update_volume_quote`)
- **가챠·굿즈 스크랩북 체크리스트**: 가챠 카드 오픈 시 캡슐 미니북 보증서·아크릴 케이스 전시 체크리스트 및 파츠 추가(`🔮 + 파츠·보증서 기록 추가`) 지원

### [Sprint 11] 카드별 맞춤 파스텔 와시 테이프(`MaskingTape`) · 명대사 전문(Full-Text) 검색 · 권별 별점 원터치 변경(`cycle_volume_rating`)
- **작품별 파스텔 와시 테이프**: 카드 상단의 마스킹 테이프가 표지 컬러와 어울리는 파스텔 와시 테이프 색상으로 자동 배색
- **명대사·스탬프 전문 검색**: 검색창에서 작품명/작가명뿐만 아니라 밑줄 친 명대사(`농구`, `봉인해제`)나 인장 스탬프(`인생최애`, `초판특전`)로도 즉시 필터링
- **권별 별점 원터치 순환(`cycle_volume_rating`)**: 일기장 모달에서 각 권의 `★★★★★` 별점을 터치해 별점을 즉시 변경 및 저장

### [Sprint 10] 권별 초판·소장 스탬프 원터치 토글(`toggle_volume_status`) & 책등 터치 바로가기 + 다독순 정렬(`SortBtn`)
- **권별 초판 스탬프 원터치 토글**: 펼친 독서 일기장 모달에서 각 권의 `🔖초판특전` / `✓소장완료` 버튼을 클릭해 초판 여부를 즉시 변경하고 전체 초판 통계를 실시간 갱신
- **미니 책등 터치 바로가기**: 상단 미니 책등 진열대(`SpineShelfRow`)의 개별 책등을 클릭하면 해당 작품의 일기장이 바로 펼쳐짐
- **다독순 정렬(`↕ 기본순` ↔ `↕ 다독순`)**: 소장 권수가 많은 단행본 시리즈부터 정렬해 볼 수 있는 필터바 정렬 토글 추가

### [Sprint 9] 미니 책등 진열대(`SpineShelf`) & 오늘의 만년필 밑줄 배너(`TodayQuote`) + 새 일기 쓰기 모달(`AddModal`) 전면 개편
- **미니 책등 진열대(`SpineShelfRow`)**: 북적북적·이북 서재 레퍼런스를 반영해 소장 작품들의 고유 컬러와 권수 두께가 반영된 미니 책등 선반을 상단에 동적 표시
- **오늘의 밑줄 문장 순환 배너(`TodayQuoteLabel` + `↻ 문장`)**: 일기장 속 명대사들을 상단 배너에서 한 줄씩 순환 감상
- **새 일기장 쓰기 모달(`add_modal.tscn`) 리디자인**: 6종 북커버 컬러 스와치(`크림슨`, `코발트`, `테라코타`, `로즈`, `포레스트`, `바이올렛`) 선택 및 첫 페이지 밑줄 명대사 등록 지원

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
