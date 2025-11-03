import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'dart:io'; // File

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // arguments에서 imagePath 또는 File 가져오기
    final args = ModalRoute.of(context)?.settings.arguments;
    File? imageFile;

    if (args is Map<String, dynamic>) {
      final imageArg = args['imagePath'];
      if (imageArg is String) {
        imageFile = File(imageArg);
      } else if (imageArg is File) {
        imageFile = imageArg;
      }
    }

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

              // 이미지 표시 영역
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3D3D3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: _buildImageWidget(imageFile),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 설명 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.favorite,
                      size: 48,
                      color: Color(0xFF5B9FED),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '피트니스 목표를 착실히 달성하고 있네요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '이 이미지는 매일 쌓아가는 당신의 노력과 강인함을 보여줘요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
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

              // 다시 생성 버튼
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

              // 공유 버튼
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

  // Web/Android 공용 이미지 처리
  Widget _buildImageWidget(File? imageFile) {
    if (kIsWeb) {
      return Image.asset(
        'assets/images/after.png',
        fit: BoxFit.cover,
      );
    } else if (imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/after.png',
        fit: BoxFit.cover,
      );
    }
  }
}
