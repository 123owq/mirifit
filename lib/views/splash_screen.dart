import 'dart:async'; // Timer를 사용하기 위해 import
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1. 화면이 켜지고 1초 후에 _navigateToHome 함수 실행
    Timer(const Duration(seconds: 1), _navigateToHome);
  }

  void _navigateToHome() {
    // 2. '/home' 경로(MainScreen)로 이동
    // pushReplacementNamed: 현재 화면(Splash)을 파괴하고 새 화면으로 이동
    // (뒤로가기 버튼을 눌러도 스플래시 화면으로 돌아오지 않게 함)
    Navigator.pushReplacementNamed(context, '/opening');
  }

  @override
  Widget build(BuildContext context) {
    // 3. 디자인에 맞게 UI 구성
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2), // (디자인의 파란색)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ★ 4. [필수] 'mirifit_logo.png' 이미지 파일이 필요합니다
            Image.asset(
              'assets/images/mirifit_logo.png',
              width: 150, // 로고 크기 조절
            ),
          ],
        ),
      ),
    );
  }
}
