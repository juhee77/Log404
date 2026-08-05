# 📋 Log404 Studio 회의록 - 모듈 11: PNG 배경 디스크 로드 수리 & 업그레이드 패널 마우스 스크롤 수리

**일시**: 2026-08-06  
**참석자**: 리드 디렉터, UI/UX 엔지니어, 렌더링 개발자, QA 엔지니어  
**안건**: PNG 배경 미적용 현상 수리(`Image.load_from_file`) 및 업그레이드 패널 마우스 휠 스크롤 이벤트 패스스루 수리  

---

## 💬 팀 논의 핵심 내용

1. **PNG 에셋 디스크 직접 로드 수리 (Bulletproof PNG Loading)**:
   - Godot 4 임포트 텍스처 데이터베이스 캐시 의존성을 없애고 `Image.load_from_file()` 및 `ImageTexture.create_from_image()` 디렉트 로딩 방식을 적용하여 2D 배경 PNG 에셋이 100% 정상 로드되도록 수리했습니다.

2. **업그레이드 패널 마우스 휠 스크롤/드래그 수리**:
   - 상점 UI 카드 컨테이너 요소들의 마우스 필터를 `MOUSE_FILTER_PASS`로 조정하여, 마우스 휠 및 드래그 스크롤 이벤트가 `ScrollContainer`로 전하되도록 완벽하게 수리했습니다.

---

## ⚙️ 모듈 변경 파일

- **[`scripts/ui/cafe_view.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/cafe_view.gd)**: `Image.load_from_file` 디렉트 로더 수리
- **[`scripts/ui/upgrade_panel.gd`](file:///Users/juhee/IdeaProjects/Log404/game01/scripts/ui/upgrade_panel.gd)**: `MOUSE_FILTER_PASS` 마우스 스크롤 이벤트 전달 수리

---

## 🧪 QA 검증 결과

- Godot 4 배경 이미지 100% 정상 표시 및 업그레이드 패널 마우스 스크롤 수리 검증 완료
