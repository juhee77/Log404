# 📋 Log404 Studio 회의록 - 모듈 21: 바리스타 에스프레소 커스텀 음료 메뉴 및 추출 로직

**일시**: 2026-08-06  
**참석자**: 수석 바리스타, 음료 기획자, 클라이언트 개발자, QA 엔지니어  
**안건**: 스터디 카페 캡슐 & 에스프레소 머신 고급 커피 메뉴(아인슈페너, 돌체라떼) 해금 및 팁 보너스 연동  

---

## 💬 팀 논의 핵심 내용

1. **바리스타 커피 메뉴 해금 (Barista Special Drinks)**:
   - 기본 아메리카노 외에도 돌체라떼, 아인슈페너 등 고급 커피 레시피를 추가하여 음료 주문 수금 팁 매출이 **+40% 증가**합니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `coffee_menu_unlocked` 및 음료 정산 logic 구현

---

## 🧪 QA 검증 결과

- Godot 4 바리스타 음료 메뉴 발동 및 팁 매출 가산 정상 작동 확인
