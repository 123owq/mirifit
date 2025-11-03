import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  const FullScreenImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 이전 화면에서 전달받은 이미지 경로 또는 텍스트
    final dynamic arguments = ModalRoute.of(context)?.settings.arguments;

    String? imagePath;
    String placeholderText = 'Generated Future Image';

    if (arguments is String) {
      if (arguments.startsWith('assets/')) {
        imagePath = arguments; // 'assets/...' 경로가 넘어온 경우
      } else {
        placeholderText = arguments; // 'User Image' 같은 텍스트가 넘어온 경우
      }
    }

    return Scaffold(
      // 2. 앱바 (스크린샷 디자인 적용)
      appBar: AppBar(
        title: const Text(
          '사진 전체화면',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // 배경 검은색
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // 뒤로가기 화살표 흰색
      ),
      backgroundColor: Colors.black, // 전체 배경 검은색
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 3. 메인 이미지 (또는 플레이스홀더 텍스트)
          Center(
            child: imagePath != null
                ? Image.asset( // 실제 이미지가 있는 경우
              imagePath,
              fit: BoxFit.contain, // 화면에 맞게 비율 유지
            )
                : Text( // 이미지가 없고 텍스트만 있는 경우
              placeholderText,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),

        ],
      ),
    );
  }
}