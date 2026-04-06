# Steam 데모 패키징

## 목적
LOG:404의 데모 빌드를 Steam에 올릴 때 필요한 최소 파일 구조와 스크립트 템플릿을 보관합니다.

## 전제
- Steam 데모는 **별도 AppID**를 사용하는 것을 기본으로 가정합니다.
- 이 저장소에는 실제 AppID/DepotID 대신 템플릿 placeholder만 넣습니다.
- 현재 환경에서는 Godot 네이티브 export를 자동화하지 않고, export 결과를 이 폴더 구조로 모으는 방식입니다.

## 권장 순서
1. Godot에서 `export_presets.cfg` 기준으로 Windows/macOS 데모 빌드 export
2. `python3 tools/package_demo_release.py --source dist --version 0.1.0-demo`
3. `distribution/steam/content/` 아래 산출물 확인
4. `distribution/steam/templates/*.vdf`의 AppID/DepotID를 실제 값으로 치환
5. SteamPipe로 업로드

## 폴더
- `templates/`: SteamPipe VDF 예제
- `content/`: 업로드할 실제 데모 콘텐츠 위치
- `build_output/`: SteamPipe 빌드 로그/캐시 위치

## 참고
- 공식 문서: Steam demo app / SteamPipe uploading
- https://partner.steamgames.com/doc/store/application/demos
- https://partner.steamgames.com/doc/sdk/uploading
