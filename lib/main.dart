// main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// 1. 모든 화면 파일들을 import 합니다.
import 'package:mirifit/views/main_screen.dart';
import 'package:mirifit/views/opening_screen.dart';
import 'package:mirifit/views/generate_screen.dart';
import 'package:mirifit/views/result_screen.dart';
import 'package:mirifit/views/gallery_screen.dart';
import 'package:mirifit/views/camera_screen.dart';
import 'package:mirifit/views/splash_screen.dart';
import 'package:mirifit/views/loading_screen.dart';
import 'package:mirifit/views/record_detail_screen.dart';
import 'package:mirifit/views/goal_by_date_screen.dart';
import 'package:mirifit/views/full_screen_image_screen.dart';
import 'package:mirifit/models/app_mode.dart';

void main() async {
  // 1. async 추가
  // 2. Flutter 엔진이 플러그인을 로드할 준비가 되도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 3. 앱이 실행되기 전에 '한국어' 날짜 데이터를 미리 로드
  await initializeDateFormatting('ko_KR', null);

  runApp(const MirifitApp());
}

class MirifitApp extends StatelessWidget {
  const MirifitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirifit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 1. 앱의 기본 배경색을 흰색으로 강제합니다.
        scaffoldBackgroundColor: Colors.white,

        // 2. 핑크빛이 도는 원인을 제거하고, 파란색 기반으로 색상표를 생성
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent, // (디자인의 메인 파란색)
        ),
        // 3. (선택) 모든 AppBar의 기본 스타일을 흰색 배경으로 통일
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 앱바 배경 흰색
          elevation: 0, // 그림자 제거
          iconTheme: const IconThemeData(color: Colors.black), // 뒤로가기 버튼 검은색
          titleTextStyle: const TextStyle(
            // 제목 스타일
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // 4. 최신 Material 3 디자인 사용
        useMaterial3: true,
      ),
      // 2. 시작 화면은 '/' (MainScreen)으로 설정합니다.
      initialRoute: '/',

      // 3. 모든 사람의 경로를 여기에 등록합니다.
      routes: {
        '/': (context) => const SplashScreen(),
        '/opening': (context) => const OpeningScreen(),

        // '/profile': (context) => const ProfileScreen(), // (나중에 추가)
        '/record_detail': (context) => const RecordDetailScreen(),
        '/goal_by_date': (context) => const GoalByDateScreen(),
        '/full_screen_image': (context) => const FullScreenImageScreen(),

        // README에 있던 파트
        '/loading': (context) => const LoadingScreen(),
        '/result': (context) => const ResultScreen(),

        '/gallery': (context) => const GalleryScreen(),
        '/camera': (context) => const CameraScreen(),
      },
    );
  }
}
