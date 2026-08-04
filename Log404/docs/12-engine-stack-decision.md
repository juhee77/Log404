# 구현 스택 결정 기록 (2026-04-06)

## 결론
- **본게임 런타임 스택**: **Godot 4.x + GDScript**
- **출시 타깃**: **Steam / Windows + macOS**
- **Steam 연동 방식**:
  - 초기 MVP: **Steamworks 업로드만 사용** (업적/클라우드/오버레이 연동 없음)
  - 출시 직전 또는 필요 시: **GodotSteam 같은 검증된 Godot용 바인딩** 추가 검토
- **Python의 역할**: **런타임 본게임이 아니라 프로토타입 / 데이터 툴 / 콘텐츠 생성 보조용**으로 제한

---

## 질문 1) 스팀 게임을 Python으로 개발해도 되나?

### 짧은 답
- **가능은 하다.**
- 하지만 **이 프로젝트의 본 출시 버전 스택으로는 비추천**이다.

### 이유
1. **Steam 자체는 특정 엔진/언어를 강제하지 않는다.**  
   앱 빌드와 depot을 올려서 배포하면 되므로, 이론적으로 Python 기반 게임도 Steam에 낼 수 있다.

2. **하지만 Steamworks API 공식 중심은 C++다.**  
   Valve 공식 문서 기준, Steamworks API는 기본적으로 C++를 공식 지원하고, 다른 언어나 엔진은 별도 바인딩/서드파티 경로를 본다.

3. **Python은 Steam 생태계에서 ‘가능하지만 1순위’는 아니다.**  
   Steamworks 문서에도 Python은 별도 언어 지원 목록에 있으나, 공식 1급 런타임이라기보다 바인딩 의존 경로다.

4. **예외는 있다.**  
   예를 들어 **Ren'Py**는 Python 스크립팅을 쓰는 엔진이고 실제로 Steam 출시 사례가 많다.  
   다만 Ren'Py는 **비주얼노벨/시뮬레이션 중심**에 매우 강한 엔진이다.

### 이 프로젝트에는 왜 Python 비추천인가
이 프로젝트는 단순 텍스트 표시기가 아니라:
- 데스크톱 조사 UI
- 좌/중/우/하단 복합 레이아웃
- 문서/메일/채팅/로그 뷰어
- 증거 보드
- 저장/불러오기
- 추리 진행 상태와 해금 구조
를 장기적으로 유지해야 한다.

즉, **출시용 런타임 앱**으로는 Python 자체보다 **게임 엔진 + 에디터 + 배포 파이프라인이 있는 스택**이 더 유리하다.

---

## 질문 2) 그럼 어떤 스택으로 가야 하나?

## 최종 추천 스택

### 1. 엔진
- **Godot 4.4+ 또는 현재 안정 버전 4.x**

### 2. 메인 언어
- **GDScript**

### 3. UI 시스템
- **Godot Control 노드 기반 UI**
- 주 사용 노드 예시:
  - `PanelContainer`
  - `HBoxContainer`
  - `VBoxContainer`
  - `SplitContainer`
  - `ScrollContainer`
  - `ItemList` 또는 `Tree`
  - `RichTextLabel`
  - `LineEdit`
  - `TextEdit`
  - `TabContainer`

### 4. 데이터
- **JSON 기반 콘텐츠 드리븐 구조 유지**
- 런타임 소비 데이터:
  - `cases/*.json`
  - `documents/*.json`
  - `clues/*.json`
  - `chapter_gates/*.json`
- 필요 시 Godot 내부 설정/리소스는 `.tres`/`.res`로 분리

### 5. 저장
- **JSON save + Godot `user://` 경로**

### 6. Steam
- **SteamPipe 업로드는 필수**
- **Steamworks API 연동은 선택**
  - 업적/클라우드/오버레이가 필요할 때만 추가

---

## 왜 Godot + GDScript가 맞는가

### 유지보수 측면
- UI 중심 게임에 적합한 **Control 노드 체계**가 있다.
- 씬/노드 구조로 **화면 단위 분리**가 쉽다.
- 에디터, UI 시스템, 배포 흐름이 한 묶음이라 **1인 개발 유지보수 비용이 낮다**.
- GDScript는 Godot에 밀착되어 있어 툴링, 자동완성, 타입 힌트, 에디터 연동이 자연스럽다.

### 이 프로젝트와의 적합성
이 게임의 핵심은 액션 연출이 아니라:
- 정보 밀도 높은 데스크톱형 UI
- 문서 탐색
- 상태/해금/추론 흐름
- 데이터 드리븐 콘텐츠 확장
이다.

이건 Godot의 2D/UI 워크플로와 잘 맞는다.

---

## Python은 어디까지 쓸까?

### 유지
- CLI 프로토타입
- 빠른 UX 검증용 브라우저/툴 프로토타입
- 더미 데이터 생성기
- 로그/메일/채팅 콘텐츠 생성 스크립트
- QA용 검증 스크립트

### 사용하지 않음
- **최종 Steam 출시용 게임 클라이언트의 메인 런타임**

즉:
- **프로토타입/도구 = Python 가능**
- **본편 런타임 = Godot**

---

## 유지보수에 유리한 실제 코드 구조 제안

```text
project/
  scenes/
    app_root.tscn
    main_menu.tscn
    case_dashboard.tscn
    document_workspace.tscn
    evidence_board.tscn
    final_report.tscn
  scripts/
    autoload/
      app_state.gd
      save_service.gd
      content_repository.gd
      progression_service.gd
    domain/
      case_data.gd
      document_data.gd
      clue_data.gd
      chapter_gate.gd
    ui/
      document_list_panel.gd
      document_view_panel.gd
      clue_panel.gd
      bookmark_panel.gd
      report_panel.gd
      search_bar.gd
    scenes/
      case_dashboard_controller.gd
      workspace_controller.gd
      evidence_board_controller.gd
  data/
    cases/
    documents/
    clues/
    chapter_gates/
  assets/
    fonts/
    icons/
    theme/
```

### 핵심 원칙
- **씬은 화면 조립만 담당**
- **도메인 모델은 순수 데이터/규칙 담당**
- **서비스는 로드/저장/진행/해금 담당**
- **UI 패널은 재사용 가능한 컴포넌트로 분리**
- **콘텐츠 데이터는 JSON으로 외부화**
- **Steam 연동은 별도 어댑터 레이어로 격리**

---

## 이번 프로젝트의 최종 결정
- 현재 저장소의 **Python 코드는 프로토타입/검증 레이어**로 유지한다.
- **실제 본게임 구현은 Godot 4 + GDScript로 전환**한다.
- 저장소 루트에 `project.godot`, `scenes/`, `scripts/`, `assets/`, `data/` 구조로 Godot 런타임 골격을 둔다.
- 앞으로 “유지보수에 유리하게 모든 코드를 작성”한다는 기준은 아래처럼 해석한다:
  1. UI/도메인/저장/진행 로직 분리  
  2. 데이터 외부화  
  3. 화면 단위 씬 분리  
  4. Steam 연동은 늦게, 얇게 붙이기  
  5. 프로토타입과 본편 런타임을 분리 유지

---

## 확인 근거 (공식 문서)
- Steamworks Getting Started: https://partner.steamgames.com/doc/gettingstarted
- Steamworks SDK: https://partner.steamgames.com/doc/sdk
- Steamworks API Overview: https://partner.steamgames.com/doc/sdk/api
- Godot exporting projects: https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html
- Godot UI docs: https://docs.godotengine.org/en/stable/tutorials/ui/
- Godot GDScript intro: https://docs.godotengine.org/en/stable/getting_started/introduction/learn_to_code_with_gdscript.html
- Godot design philosophy: https://docs.godotengine.org/en/stable/getting_started/introduction/godot_design_philosophy.html
- Ren'Py official site: https://www.renpy.org/index.html
