import 'package:flutter/material.dart';
import 'dart:convert'; // for base64Decode
import 'dart:typed_data'; // for Uint8List

class ResultScreen extends StatelessWidget {
  // 1. 생성자를 통해 직접 API 응답을 받도록 수정
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    // 2. ModalRoute 대신 생성자로 받은 resultData 사용
    final Map<String, dynamic>? args = resultData;

    // 3. 응답에서 base64 이미지 문자열 추출
    Uint8List? decodedBytes;
    if (args != null &&
        args.containsKey('images') &&
        args['images'] is Map &&
        (args['images'] as Map).containsKey('transformed')) {
      final String base64String = args['images']['transformed'];
      try {
        decodedBytes = base64Decode(base64String);
      } catch (e) {
        print('Error decoding base64 string: $e');
        // 디코딩 실패 시 decodedBytes는 null로 유지됩니다.
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    // 4. 디코딩된 이미지 바이트를 위젯으로 전달
                    child: _buildImageWidget(decodedBytes),
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
                    //_buildWeightWidget(args),
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
                    // 이전 화면 (GenerateScreen)으로 돌아감
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

  // 5. Uint8List를 받는 위젯 (변경 없음)
  // Widget _buildWeightWidget(Map<String, dynamic>? args) {
  //   if (args == null || !args.containsKey('prediction') || !(args['prediction'] is Map) || !(args['prediction'] as Map).containsKey('predicted_weight_kg')) {
  //     return Container(); // 데이터가 없거나 형식이 일치하지 않으면 빈 위젯 반환
  //   }

  //   final dynamic weightValue = (args['prediction'] as Map)['predicted_weight_kg'];
  //   final double? weight = double.tryParse(weightValue.toString());

  //   if (weight == null) {
  //     return Container(); // 숫자로 변환 실패 시 빈 위젯 반환
  //   }

  //   return Text(
  //     '예상 몸무게: ${weight.toStringAsFixed(1)} kg',
  //     textAlign: TextAlign.center,
  //     style: const TextStyle(
  //       fontSize: 16,
  //       fontWeight: FontWeight.bold,
  //       color: Color(0xFF1A1A1A),
  //     ),
  //   );
  // }

  Widget _buildImageWidget(Uint8List? imageBytes) {
    if (imageBytes != null && imageBytes.isNotEmpty) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      );
    } else {
      // 이미지가 없거나 디코딩 실패 시
      return Image.asset(
        'assets/images/after.png', // 기본 플레이스홀더 이미지
        fit: BoxFit.cover,
      );
    }
  }
}
