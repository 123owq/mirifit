// main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';


// 1. 모든 화면 파일들을 import 합니다.
import 'package:mirifit/views/main_screen.dart';
import 'package:mirifit/views/generate_screen.dart';
import 'package:mirifit/views/result_screen.dart';
import 'package:mirifit/views/gallery_screen.dart';
import 'package:mirifit/views/camera_screen.dart';
import 'package:mirifit/views/splash_screen.dart';
import 'package:mirifit/views/loading_screen.dart';
import 'package:mirifit/views/record_detail_screen.dart';
import 'package:mirifit/views/goal_by_date_screen.dart';

void main() async { // 1. async 추가
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,

      // 2. 시작 화면은 '/' (MainScreen)으로 설정합니다.
      initialRoute: '/',

      // 3. 모든 사람의 경로를 여기에 등록합니다.
      routes: {

        '/': (context) => const SplashScreen(),
        '/home': (context) => const MainScreen(),
        // '/profile': (context) => const ProfileScreen(), // (나중에 추가)

        '/record_detail': (context) => const RecordDetailScreen(),
        '/goal_by_date': (context) => const GoalByDateScreen(),

        // README에 있던 파트
        '/generate': (context) => const GenerateScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/result': (context) => const ResultScreen(),

        '/gallery': (context) => const GalleryScreen(),
        '/camera': (context) => const CameraScreen(),
      },
    );
  }
}