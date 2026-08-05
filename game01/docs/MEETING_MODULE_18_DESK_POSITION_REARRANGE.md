# 📋 Log404 Studio 회의록 - 모듈 18: 독서실 책상 위치 자유 이동 & 재배치 모드

**일시**: 2026-08-06  
**참석자**: 레벨 디자인 리드, UI 개발자, 렌더링 엔지니어, QA 엔지니어  
**안건**: 스터디 카페 독서실 책상의 자유로운 좌표 이동(`seat_custom_offsets`) 및 오프셋 기반 재배치 시스템 연동  

---

## 💬 팀 논의 핵심 내용

1. **책상 위치 커스텀 오프셋 재배치 (Custom Desk Position Offset)**:
   - 기존의 고정 레이아웃 구조를 탈피하고, `get_seat_position()`에서 `seat_custom_offsets` 뷰포트 상대 좌표 오프셋을 통합 정산하여 유저가 원하는 구도와 간격으로 책상 위치를 배치할 수 있도록 확장했습니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `seat_custom_offsets`, `set_seat_offset()`, `get_seat_position()` 구현

---

## 🧪 QA 검증 결과

- Godot 4 책상 오프셋 좌표 정산 및 세이브/로드 정상 동작 확인
