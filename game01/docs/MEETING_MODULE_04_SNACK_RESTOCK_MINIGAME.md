# 📋 Log404 Studio 회의록 - 모듈 04: 셀프 스낵바 & 학업 비품 충전 미니게임

**일시**: 2026-08-05  
**참석자**: 콘텐츠 기획자, UI 엔지니어, 사운드 디자이너, QA 엔지니어  
**안건**: 스터디 카페 휴게실 비품(캡슐 커피, 다과, 3M 귀마개, 독서대) 발주 및 충전 미니게임 구축  

---

## 💬 팀 논의 핵심 내용

1. **스터디 카페 비품 충전 미니게임 설계**:
   - 스낵바 재고율(`GameState.snack_stock`)을 도입하여, 유저가 직접 캡슐 커피, 다과, 3M 귀마개를 발주하여 채울 수 있는 미니게임 팝업(`snack_restock_panel.tscn`)을 연동했습니다.

2. **보상 및 평점 메커니즘**:
   - 스낵바 재고를 100% 충전하면 평점(⭐) 보너스가 상승하고 손님들의 팁 수금율이 증가합니다.

---

## ⚙️ 모듈 변경 파일

- **[`scenes/ui/snack_restock_panel.tscn`](file:///Users/juhee/IdeaProjects/Log404/game01/scenes/ui/snack_restock_panel.tscn)**: 스낵바 충전 팝업 UI 씬
- **[`scripts/ui/snack_restock_panel.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/snack_restock_panel.gd)**: 비품 발주 및 재고율 계산 로직

---

## 🧪 QA 검증 결과

- Godot 4 씬 로드 및 비파괴 UI 오버레이 정상 동작 확인
