# Steam 데모 패키징 가이드

## 목적
현재 저장소의 Godot 런타임과 프로토타입 산출물을 Steam 데모 업로드 구조로 옮기는 절차를 정리한다.

## 현재 상태
- Godot 프로젝트는 `project.godot` 기준으로 import 가능
- `export_presets.cfg`가 추가되어 Windows / macOS / Web export 타깃을 정의함
- 실제 native export는 export template 및 코드 서명 준비가 필요함
- Steam 업로드 템플릿은 `distribution/steam/templates/` 아래에 예제 VDF로 제공됨

## 로컬 절차
1. Godot에서 프로젝트 import
2. Export Templates 설치 확인
3. `Project > Export`에서 preset 확인
4. 아래 위치로 export
   - Windows: `dist/windows/LOG404.exe`
   - macOS: `dist/macos/LOG404.app`
   - Web: `dist/web/index.html`
5. 패키징
   - `python3 tools/package_demo_release.py --source dist --version 0.1.0-demo`
6. `distribution/steam/content/` 결과 확인
7. SteamPipe VDF 템플릿에 실제 AppID/DepotID 반영 후 업로드

## 주의
- Steam demo는 공식적으로 별도 demo app으로 운영하는 구성을 기본 가정한다.
- macOS 배포에는 코드서명 / notarization 준비가 필요하다.
- 현재 릴리즈 자산은 소스/프로토타입 zip이며, 네이티브 빌드 데모는 아직 아님.

## 공식 참고 문서
- Steam demo app: https://partner.steamgames.com/doc/store/application/demos
- SteamPipe uploading: https://partner.steamgames.com/doc/sdk/uploading
- Godot exporting projects: https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html
- Godot exporting for Windows: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html
- Godot exporting for macOS: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html
