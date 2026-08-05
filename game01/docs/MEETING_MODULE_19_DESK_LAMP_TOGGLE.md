# 📋 Log404 Studio 회의록 - 모듈 19: 개별 독서실 스탠드등 ON/OFF 터치 상호작용

**일시**: 2026-08-06  
**참석자**: 테크니컬 아티스트, 인터랙션 디자이너, 클라이언트 개발자, QA 엔지니어  
**안건**: 스터디 카페 좌석 스탠드등 개별 터치 스위치 켜기/끄기(`lamp_states`) 및 심야 무드등 연출  

---

## 💬 팀 논의 핵심 내용

1. **스탠드등 터치 스위치 상호작용 (Lamp Touch Switch)**:
   - 독서실 스탠드등을 터치하여 켜거나 끌 수 있으며, 켜졌을 때는 따뜻한 앰버 조명이, 꺼졌을 때는 소등된 모던 앰비언트 상태로 전환됩니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `lamp_states` 및 `toggle_seat_lamp()` 연동
- **[`scripts/ui/cafe_view.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/cafe_view.gd)**: 스탠드등 점등/소등 조건부 렌더링

---

## 🧪 QA 검증 결과

- Godot 4 스탠드등 토글 및 시간대별 점등 오버레이 검증 완료
