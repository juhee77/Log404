# ☕ 스터디 카페 타이쿤 (Study Cafe Tycoon)

> **Godot 4 기반 2.5D 아소메트릭 방치형/경영 심뮬레이션 멀티플랫폼 타이쿤 게임**  
> 개발: Log404 Studio | 엔진: Godot Engine v4.6+ (GDScript)

---

## 📸 2.5D 비주얼 스크린샷 (Visual Showcase)

| 1층 메인 집중 열공 방 (Focus Room) | 2층 귀족 노블 부스 존 (Noble Booth) |
| :---: | :---: |
| ![1F Main Study Zone](game01/screenshot_1f.png) | ![2F Noble Booth Zone](game01/screenshot_2f.png) |

| 3층 루프탑 테라스 라운지 (Rooftop Terrace) | 2.5D 마그네틱 자석 그리드 배치 모드 |
| :---: | :---: |
| ![3F Rooftop Terrace Zone](game01/screenshot_3f.png) | ![Decorating Mode Grid](game01/screenshot_decorating.png) |

---

## 📖 프로젝트 개요

**스터디 카페 타이쿤**은 수험생과 카공족을 유치하여 나만의 프리미엄 스터디 카페 콤플렉스를 경영하는 **2.5D 아기자기한 이소메트릭 힐링 경영 심뮬레이션**입니다.

실제 사진이나 렌더링 이미지 대신 **통일감 있는 2.5D 벡터 그래픽 아키텍처**와 **수제 픽셀/스프라이트 자산 시스템**을 채택하여, 화면의 왜곡이나 부자연스러움 없이 깔끔하고 감성적인 스터디 카페 분위기를 제공합니다.

---

## 🔥 핵심 시스템 & 주요 모듈

### 🏢 1. 다중 구역 통합 건축 구조 (Multi-Room Layout)
- **📖 메인 집중 열공 방 (Main Focus Study Room)**: 1인 독서실, 오픈 카페석, 요추지지 메쉬 의자, 방음 커튼, LED 조명 후광 연동
- **☕ 힐링 라운지 & 커피 바 (Lounge & Roasting Bar)**: 직영 로스팅 머신, 프리미엄 케이크 베이커리, 싱글 오리진 핸드드립 바
- **🔑 프런트 & 스마트 사물함 (Front & Locker Zone)**: 키오스크 입출입, 비밀번호 사물함, ANC 노이즈 캔슬링 헤드폰 대여 도크

### 🌧️ 2. 실시간 2.5D 날씨 & 조명 쉐이더 연출 (Atmospheric Weather & Circadian Lighting)
- **4종 날씨 사이클**: ☀️ 맑음, 🌧️ 빗소리 레이니 데이, ❄️ 눈 내리는 날, ☁️ 구름 많은 운치 있는 날
- **감성 말풍선 인터랙션**: 공부 중인 학생 머리 위에 `🌧️ 빗소리 아늑하다 ☕`, `❄️ 눈 오니 라떼 최고!` 등 감성 멘트 실시간 렌더링
- **매출 & 몰입 보너스**: 날씨별 음료 갈증도 및 학업 집중도 수치(+10% ~ +30%) 동적 가산

### 🧲 3. 인터랙티브 2.5D 책상 마그네틱 그리드 배치 (Magnetic Grid Placement)
- **자석 스냅 기술**: 책상 드래그 이동 시 2.5D 시안(Cyan) 타일 가이드라인 자동 활성화
- **정밀 스냅 & 회전**: 110px x 75px 그리드 단위 정밀 마그네틱 흡착 및 90도 회전 배치 지원

### ⚛️ 4. 42개 첨단 기술 서브시스템 (Tech Operations Center)
- **에너지 & 파워**: 퀀텀 반물질 초청정 에너지, SMR 핵융합, 호킹 복사 싱귤래리티 중력우물 발전소 등
- **시공간 & 물리학**: 텔레파시 시냅스 다운로드, 타키온 크로노 시간가속, 자율 초전도 자기장 양자 부유 바닥 매트릭스 등
- **AI & 뇌파 바이오**: 3D 홀로그램 AI 튜터, 바이오-다이내믹 펩타이드 신경자극기, 기억-결정체 변무테이션 리액터 등
- **경영 & 글로벌 네트워크**: 퀀텀 블록체인 정산, 글로벌 위성 메쉬 네트워크, 글로벌 퀀텀 얽힘 프랜차이즈 가맹 원장 리레이 등

---

## 📁 프로젝트 폴더 구조

```text
Log404/
├── game01/                           # Godot 4 게임 메인 프로젝트
│   ├── assets/                       # 게임 스프라이트 및 UI 자산
│   ├── build/ios/                    # iOS 네이티브 임베디드 배포 패키지 (data.pck)
│   ├── docs/                         # 모듈별 기능 사양서 (MEETING_MODULE_1~53.md)
│   ├── scenes/                       # 메인 씬 및 UI 패키지 TSCN 파일
│   │   ├── main_scene.tscn           # 2.5D 메인 타이쿤 통합 씬
│   │   └── ui/                       # 팝업 패키지 (DeskShop, Roasting, Quest 등)
│   ├── scripts/
│   │   ├── autoload/
│   │   │   ├── game_state.gd         # 핵심 게임 상태 및 경영 시뮬레이션 엔진
│   │   │   └── sound_manager.gd      # SFX 및 BGM 사운드 제어기
│   │   ├── ui/
│   │   │   └── cafe_view.gd          # 2.5D 아소메트릭 절차적 뷰 렌더링 엔진
│   │   └── tests/
│   │       └── test_all_70_modules.gd # 82개 모듈 통합 자동 검증 스크립트 (100% PASS)
│   └── project.godot                 # Godot 4 프로젝트 설정 파일
└── README.md                         # 전체 프로젝트 설명 문서
```

---

## 🛠️ 실행 및 테스트 방법

### 1. Godot 4 로컬 실행
```bash
# 메인 2.5D 스터디 카페 타이쿤 실행
godot --path game01
```

### 2. 82개 모듈 자동 검증 스위트 (Headless Mode)
```bash
# 82개 경영, 유틸리티, 2.5D 날씨 및 마그네틱 배치 모듈 100% 통과 여부 자동 검증
godot --headless --path game01 --script scripts/tests/test_all_70_modules.gd
```

### 3. iOS 네이티브 데이터 패키지 빌드
```bash
# iOS 임베디드 패키지 동기화 생성
godot --headless --path game01 --export-pack "iOS" build/ios/data.pck
cp game01/build/ios/data.pck game01/build/ios/StudyCafeTycoon.pck
```

---

## 🎨 자산 관리 지침 (Asset Management Guidelines)

1. **실사/AI 인물 사진 사용 금지**: 실사 배경은 2.5D 아소메트릭 게임 시점과 이질감을 발생시키므로 배제하고, 통일된 **2.5D 벡터 및 픽셀 자산**을 사용합니다.
2. **절차적 렌더링 자산 (Procedural 2.5D Graphics)**: `cafe_view.gd`에서 절차적으로 벽면, 요추 의자, 스탠드 조명 후광, 창문 날씨 효과를 그려 자산 누락 시에도 100% 안정적인 뷰를 보장합니다.
3. **스마트 해상도 스케일링**: 모든 팝업 패널은 `Vector2(660, 460)` 규격으로 중앙 정렬되어 어떠한 디바이스 해상도에서도 화면 잘림 없이 렌더링됩니다.

---

© 2026 **Log404 Studio**. All Rights Reserved.
