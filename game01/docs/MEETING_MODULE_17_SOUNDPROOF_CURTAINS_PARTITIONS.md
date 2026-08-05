# 📋 Log404 Studio 회의록 - 모듈 17: 방음 커튼 & 몰입 칸막이 독서실 자유 설치 모드

**일시**: 2026-08-06  
**참석자**: 레벨 아키텍트, 인테리어 디자이너, 클라이언트 개발자, QA 엔지니어  
**안건**: 메인 열공존 개별 독서실 좌석 방음 커튼(🎪) 및 1인 몰입 칸막이(🔮) 자유 설치 기능 연동  

---

## 💬 팀 논의 핵심 내용

1. **독서실 좌석 커버 튜닝 모드 (Seat Customization)**:
   - `[🔨 인테리어 꾸미기]` 모드 상태에서 개별 독서실 좌석을 터치하면 **방음 커튼(🎪)**과 **몰입 칸막이(🔮)**가 자유롭게 추가 설치됩니다.

2. **소음 방지 및 평점 가산**:
   - 방음 커튼이 설치된 좌석은 빌런 손님의 소음 방출을 차단하여 평점(⭐+0.1) 상승 보너스가 적용됩니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/autoload/game_state.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/autoload/game_state.gd)**: `seat_partitions` 및 `install_partition()` 연동
- **[`scripts/ui/cafe_view.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/cafe_view.gd)**: 방음 커튼 및 몰입 칸막이 그래픽 오버레이 렌더링

---

## 🧪 QA 검증 결과

- Godot 4 좌석 선택 칸막이/커튼 설치 및 오버레이 렌더링 정상 동작 확인
