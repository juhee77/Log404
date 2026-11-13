# 📋 Pocket Archive (Game02) — 14인 애자일 스쿼드 스프린트 누적 회의록

- **조직 구성**: CEO(1명), 실제 다꾸러·수집러(3명: 소장러 A, 가챠러 B, 미니멀러 C), 기획자(2명: PO, 서비스 기획), UX/UI 디자이너(2명), 개발자(4명), QA 엔지니어(2명)
- **운영 주기**: 20분 주기 자율 스프린트 (`VOC 취합 -> 기획 정리 -> HTML 목업/UI -> 전원 회의 -> Godot 4.6 개발 -> TDD/QA 검증 -> 스크린샷 캡처 & README 업데이트 -> Git Commit & Push`)

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
