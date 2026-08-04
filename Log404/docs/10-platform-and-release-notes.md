# 플랫폼 및 출시 노트

## 문서 메타
- 목적: Steam/Windows/macOS 출시 시 필수 체크 항목을 정리한다.
- 독자: 빌드/릴리스 담당, 프로듀서.
- 입력: 대상 플랫폼 정책, 엔진 export 설정, 스토어 준비물.
- 출력: 플랫폼 요구사항 체크리스트, 릴리스 준비 항목.

## 플랫폼 정책 메모
- Steam은 Windows/macOS 배포를 지원한다.
- macOS 대상 신규 앱은 64비트 및 notarization 요구사항을 충족해야 한다.
- Steamworks SDK는 업로드 파이프라인용으로 사용 가능하며, 인게임 Steam 기능은 선택적으로 연동한다.

## 릴리스 준비 항목
- Windows/macOS 빌드 산출물 검증
- 저장/불러오기 호환성 점검
- 스크린샷/트레일러/스토어 카피 준비
- 최소 사양/권장 사양 문구 확정
- 버전 태깅 및 릴리스 노트 작성

## 운영 옵션 (후순위)
- 업적
- Steam Cloud
- 추가 분석 도구 연동

## 참조
- 상세 실행 순서: [plan/06-steam-macos-release-checklist.md](../plan/06-steam-macos-release-checklist.md)
