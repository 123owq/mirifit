import 'package:flutter/material.dart';
import 'dart:io'; // ★ 1. Image.file을 사용하기 위해 import

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. 전달받은 데이터 (GenerateScreen -> LoadingScreen -> ResultScreen)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // 3. imagePath를 추출합니다.
    final String? imagePath = args?['imagePath'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '생성 이미지',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B9FED),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ★ 4. [수정됨] 생성된 이미지 영역
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(20),
                ),
                // 5. 이미지가 있으면 Image.file, 없으면 after.png
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imagePath != null
                      ?
                  // 5-A: 이미지가 있는 경우 (Image.file 사용)
                  Image.file(
                    File(imagePath), // 전달받은 경로의 파일 표시
                    fit: BoxFit.cover,
                  )
                      :
                  // 5-B: 이미지가 없는 경우 (after.png 표시)
                  Image.asset(
                    'assets/images/after.png', // ★★★ imagePath가 null일 때 after.png를 보여줌
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // (이 아래의 설명 카드, 버튼 등은 모두 기존과 동일합니다)

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 48,
                      color: Color(0xFF5B9FED),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '피트니스 목표를 착실히 달성하고 있네요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '이 이미지는 매일 쌓아가는 당신의 노력과 강인함을 보여줘요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '계속 힘내세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        '다시 생성하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능 준비 중입니다')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF5B9FED),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Color(0xFF5B9FED)),
                      SizedBox(width: 8),
                      Text(
                        '이미지 공유',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5B9FED),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}