import 'package:flutter/material.dart';
import 'dart:async'; // Future.delayed를 위해 import

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 이 함수가 여러 번 호출될 수 있으므로, 딱 한 번만 실행되도록
    if (!_isInitialized) {
      _isInitialized = true;

      // 1. GenerateScreen에서 전달한 데이터를 받습니다.
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // 2. 3초간 "생성"을 시뮬레이션합니다. (실제로는 AI 모델 호출)
      Future.delayed(const Duration(seconds: 3), () {
        // 3. 3초 후, ResultScreen으로 이동합니다.
        if (mounted) { // (중요) 화면이 꺼진 경우를 대비
          Navigator.pushReplacementNamed(
            context,
            '/result', // ResultScreen으로 이동
            arguments: args, // 1번에서 받은 데이터를 그대로 전달
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. 로딩 페이지 UI (스크린샷 기반)
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱의 메인 색상을 사용한 스피너
            const CircularProgressIndicator(
              color: Color(0xFF5B9FED),
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              '생성 중...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}