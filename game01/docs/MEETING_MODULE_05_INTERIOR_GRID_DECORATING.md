# 📋 Log404 Studio 회의록 - 모듈 05: 격자 기반 인테리어 꾸미기 모드 (Grid Decorating System)

**일시**: 2026-08-05  
**참석자**: 레벨 디자이너, UI 엔지니어, 그래픽 셰이더 개발자, QA 엔지니어  
**안건**: 64x64px 타일 격자 기반 가구(공기정화 화분, 앤티크 스탠드 조명, 원목 서가) 배치 모드 구축  

---

## 💬 팀 논의 핵심 내용

1. **타일 격자(Grid) 가구 배치 로직 구축**:
   - `[🔨 인테리어 꾸미기]` 버튼 클릭 시 64x64px 그리드 라인 오버레이가 활성화됩니다.
   - 맵 위의 원하는 위치를 터치/클릭하면 **공기정화 화분(🪴)**이 즉시 배치되며 평점(⭐+0.08) 보너스가 부여됩니다.

2. **확장성 및 데이터 포맷**:
   - `GameState.custom_decorations` 가구 배치 배열 데이터를 통해 추후 다양한 추가 가구 및 회전 기능 확장이 가능하도록 구조를 설계했습니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `toggle_decorating_mode()`, `add_decoration()` 구현
- **[`scripts/ui/cafe_view.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/cafe_view.gd)**: 격자 타일 라인 및 커스텀 배치 가구 오버레이 렌더링
- **[`scenes/main_scene.tscn`](file:///Users/juhee/IdeaProjects/Log404/game01/scenes/main_scene.tscn)**: `BtnDecorate` 꾸미기 토글 버튼 추가

---

## 🧪 QA 검증 결과

- Godot 4 그리드 라인 렌더링 및 터치 배치 정상 구동 확인
