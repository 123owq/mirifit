# mirifit

feature/api_server <- main 브랜치에 merge됨 
A new Flutter project.

## Getting Started

<<<<<<< HEAD
사용 순서
1.Flutter SDK 설치 (3.35.6)

2.프로젝트 git Clone

3.의존성 설치 (flutter pub get)

4.앱 실행 flutter run

## 프로젝트 구조 예시 

lib/
 
 ├── main.dart               # 앱 진입점
 
 ├── models/                 # 데이터 모델 클래스 폴더
 
 ├── views/                  # 화면 관련 위젯(스크린) 모음 폴더
 
 ├── widgets/                # 재사용 가능한 위젯 폴더
 
 ├── themes/                 # 앱 테마 (색상, 폰트 등) 폴더
 
작성하는 코드는 lib 디렉토리 안에 배치해야합니다.

### models/ 
폴더에는 앱에서 사용하는 데이터나 필드를 따로 관리하는 코드 저장.
예시로 double calories 이런것을 따로 관리. 하드코딩 대신 model/fitness_data.dart에서 가져올 수 있음.

### views/ 
폴더에는 각자 담당한 화면 구현 코드파일 넣으면 됩니다. 
figma에서 각 화면이름 기준으로
데이터입력 <- views/generate_screen.dart
생성 <- views/result_screen.dart

views/main_screen.dart 은 임시 홈화면


### widgets/ 
폴더는 재사용하거나 공유해서 쓸 위젯 넣어서 사용.
예시: custom_bottom_nav_bar.dart 위젯모습 -> <img width="200" height="40" alt="image" src="https://github.com/user-attachments/assets/2b1f5669-5eac-4764-bf42-f7b24f265cc3" />

## 화면이동
### Navigator.pushNamed 방법을 현재 사용중입니다.

main.dart
```
routes: {
        '/': (context) => const MainScreen(),
        '/home': (context) => const Center(child: Text('Home 화면')),
        '/generate': (context) => const GenerateScreen(),
        '/result': (context) => const ResultScreen(),  // 추가
      },
```
이런식으로 각자 생성한 views/~.dart 파일을 라우터에 등록 

### 사용예시
views/main_screen.dart 27줄 (`Navigator.pushNamed(context, '/generate');`)


=======
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> cc5e99a (Initial commit - Flutter project)
