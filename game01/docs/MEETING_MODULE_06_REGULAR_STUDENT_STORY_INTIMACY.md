# 📋 Log404 Studio 회의록 - 모듈 06: 단골 열공생 스토리 고민 상담 & 친밀도 시스템

**일시**: 2026-08-05  
**참석자**: 콘텐츠 디렉터, 시나리오 작가, UI 엔지니어, QA 엔지니어  
**안건**: 스터디 카페 매일 출석 단골손님(수험생, 공시생, 프리랜서 개발자) 대화 팝업 및 친밀도(❤️ LEVEL) 보상 구축  

---

## 💬 팀 논의 핵심 내용

1. **단골 열공생 스토리 대화 (Intimacy System)**:
   - 고3 수험생(수능 D-100일), 행정직 공시생(사물함 찜), 프리랜서 개발자(서버 폭발) 단골 손님의 독창적인 대화 팝업(`student_dialogue_panel.tscn`)을 제작했습니다.

2. **선택지 및 보상 메커니즘**:
   - 올바른 응원 대화나 학업 비품(3M 귀마개, 독서대, 무릎담요)을 선택하여 제공하면 친밀도(❤️) 상승과 함께 +500₩ 응원 격려금 보너스를 획득합니다.

---

## ⚙️ 모듈 변경 파일

- **[`scenes/ui/student_dialogue_panel.tscn`](file:///Users/juhee/IdeaProjects/Log404/game01/scenes/ui/student_dialogue_panel.tscn)**: 단골 대화 UI 씬
- **[`scripts/ui/student_dialogue_panel.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/student_dialogue_panel.gd)**: 고민 상담 선택지 및 친밀도 정산 로직

---

## 🧪 QA 검증 결과

- Godot 4 비파괴 대화 오버레이 및 정산 시그널 정상 구동 확인
