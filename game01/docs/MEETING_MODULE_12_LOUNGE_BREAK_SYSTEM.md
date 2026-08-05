# 📋 Log404 Studio 회의록 - 모듈 12: 스낵바 휴게실 손님 휴식 & 커피 충전 시스템

**일시**: 2026-08-06  
**참석자**: 레벨 디자이너, 클라이언트 개발자, UX 아키텍트, QA 엔지니어  
**안건**: 스터디 카페 휴게실(Lounge Zone) 빈백 소파 및 캡슐 커피바 손님 휴식 상호작용 연동  

---

## 💬 팀 논의 핵심 내용

1. **손님 휴식 상호작용 (Lounge Break Interactions)**:
   - 손님들이 오랜 공부 후 휴게실(Lounge Zone)로 이동하여 빈백 소파나 캡슐 커피바에서 음료를 마시며 휴식을 취하는 자연스러운 동선 AI를 추가했습니다.

2. **휴식 시 팁 정산 보너스**:
   - 휴게실에서 휴식을 취한 손님은 집중도가 회복되어 퇴실 시 팁 보너스가 +15% 가산됩니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: 손님 상태 관리 및 휴게실 정산 로직
- **[`scripts/ui/cafe_view.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/cafe_view.gd)**: 휴게실 손님 모션 드로잉

---

## 🧪 QA 검증 결과

- Godot 4 휴게실 전환 및 손님 동선 이동 정상 작동 확인
