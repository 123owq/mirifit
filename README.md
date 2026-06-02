# Mirifit

사용자의 사진과 신체 데이터를 입력하면 AI가 변환된 체형 이미지를 생성해주는 Flutter 앱입니다.

## 주요 기능

- 카메라 촬영 또는 갤러리에서 사진 선택
- 신체 데이터 입력 (키, 체중, 나이, 성별, 목표 등)
- 백엔드 API 연동을 통한 AI 체형 변환 이미지 생성
- 변환 결과 이미지 확인 및 저장
- 운동 기록 및 진행 상황 트래킹

## 기술 스택

- **Framework**: Flutter (SDK 3.x)
- **Language**: Dart
- **주요 패키지**
  - `http` — 백엔드 API 통신
  - `camera` / `image_picker` — 카메라 및 갤러리 연동
  - `photo_manager` — 사진 관리
  - `permission_handler` — 런타임 권한 처리
  - `path_provider` — 파일 시스템 접근

## 프로젝트 구조

```
lib/
├── main.dart               # 앱 진입점 및 라우팅
├── models/                 # 데이터 모델 (fitness_data 등)
├── views/                  # 화면별 위젯
│   ├── opening_screen.dart
│   ├── generate_screen.dart  # 사진 및 데이터 입력
│   ├── loading_screen.dart
│   ├── result_screen.dart    # AI 변환 결과 표시
│   ├── progress_screen.dart  # 진행 상황
│   ├── profile_screen.dart
│   └── ...
├── services/               # API 통신 등 비즈니스 로직
├── widgets/                # 공통 재사용 위젯
└── themes/                 # 앱 테마 (색상, 폰트 등)
```

## 실행 방법

1. Flutter SDK 설치 (3.x 이상)
2. 저장소 클론
   ```bash
   git clone https://github.com/123owq/mirifit.git
   cd mirifit
   ```
3. 의존성 설치
   ```bash
   flutter pub get
   ```
4. 앱 실행
   ```bash
   flutter run
   ```
