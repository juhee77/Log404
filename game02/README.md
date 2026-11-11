# 📚 Pocket Archive (Game02) — 만화책 & 가챠 컬렉션 보관함

Godot 4.6.2 모바일 기반의 깔끔하고 직관적인 **단행본 권별 소장 및 가챠 피규어 아카이브 앱**입니다.

---

## 📸 실제 구동 스크린샷 (Godot 4.6 렌더링)

![Pocket Archive Godot Main Screen](godot_project/screenshots/godot_app_screen.png)

---

## ✨ 핵심 기능

1. **상단 컬렉션 대시보드**:
   - 총 소장 작품 종수, 만화 단행본 총 권수, 초판 특전 보유 권수, 가챠 피규어 개수 실시간 집계
2. **원클릭 카테고리 필터 & 실시간 검색**:
   - `전체`, `📖 만화`, `🔮 가챠` 탭 전환
   - 검색창에 단어 입력 시 실시간으로 카드 필터링
3. **2:3 표지 비율 카드 뷰 (`CardItem`)**:
   - 시각적 노이즈를 뺀 화이트 카드, 소장 권수 뱃지 및 카테고리 태그
4. **권별 독서 다이어리 상세 모달 (`DetailModal`)**:
   - 카드를 터치하면 부드럽게 열리는 팝업
   - 1권~N권 소장 여부(`초판특전` / `소장완료`), 별점(★), 명대사 기록 및 `+ 다음 권 추가`
5. **새 소장품 간편 등록 모달 (`AddModal`)**:
   - 제목, 작가/시리즈명, 카테고리를 입력하고 바로 등록

---

## 🛠️ 프로젝트 구조

```
game02/
├── godot_project/                  # 🎮 Godot 4.6.2 정식 엔진 프로젝트
│   ├── project.godot               # 모바일 최적화 (450x800, canvas_items, expand)
│   ├── scenes/
│   │   ├── main.tscn               # 메인 뷰포트 씬 (F5 실행 씬)
│   │   ├── card_item.tscn          # 소장품 카드 컴포넌트
│   │   ├── detail_modal.tscn       # 권별 다이어리 상세 모달
│   │   └── add_modal.tscn          # 신규 등록 모달
│   ├── scripts/
│   │   ├── collection_item.gd      # 도메인 엔티티 (권별 평점/명대사 구조체)
│   │   ├── archive_state.gd        # 상태 관리 (필터링/검색/통계)
│   │   ├── main_view.gd            # 메인 화면 컨트롤러
│   │   ├── card_item.gd            # 카드 바인딩
│   │   ├── detail_modal.gd         # 모달 로직
│   │   └── add_modal.gd            # 등록 로직
│   ├── screenshots/
│   │   └── godot_app_screen.png    # 실제 렌더링 스크린샷
│   └── tests/
│       ├── test_archive.gd         # 도메인 모델 테스트 (100% PASS)
│       └── test_main_integration.gd# 메인 UI 통합 테스트 (100% PASS)
└── README.md
```

---

## 🧪 자동화 테스트 검증 (Headless CI)

Godot Engine CLI를 통해 UI와 도메인 모델에 대한 통합 테스트를 수행합니다:

```bash
godot --headless --path godot_project -s tests/test_main_integration.gd
```

```text
--- Running Main Scene Headless Load & Integration Test ---
✓ Initial 3 cards populated in GridContainer
✓ Filter to Manga verified (2 cards)
✓ Search filter verified (1 card)
✓ Add item flow verified
--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---
```
