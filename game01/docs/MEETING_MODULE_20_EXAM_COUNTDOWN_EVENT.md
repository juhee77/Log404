# 📋 Log404 Studio 회의록 - 모듈 20: 수능 & 국가고시 D-Day 카운트다운 이벤트

**일시**: 2026-08-06  
**참석자**: 이벤트 기획자, 시나리오 라이터, 클라이언트 개발자, QA 엔지니어  
**안건**: 스터디 카페 수험생/공시생들의 몰입 의지를 북돋는 수능 D-Day 카운트다운(`exam_d_day`) 연동  

---

## 💬 팀 논의 핵심 내용

1. **수능/공시 D-Day 카운트다운 시스템**:
   - 매 인게임 24시간 도달 시 `exam_d_day`가 차감되며, 스터디 카페 유저 리뷰 및 상단 탭에 **"🎓 수능 D-Day 몰입 열공 시즌"** 이벤트가 발동합니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `exam_d_day` 카운트다운 및 리뷰 연동

---

## 🧪 QA 검증 결과

- Godot 4 D-Day 차감 및 리뷰 로깅 정상 동작 확인
