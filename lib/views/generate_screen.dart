import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 갤러리용
import 'dart:io'; // File 클래스용
import '../models/fitness_data.dart';

class GenerateScreen extends StatefulWidget {
  // 1. MainScreen에서 이미지를 전달받기 위한 파라미터
  final File? initialImage;

  const GenerateScreen({
    super.key,
    this.initialImage,
  });

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  // 2. GenerateScreen이 자체적으로 관리하는 이미지 변수
  File? _selectedImage;
  late FitnessData _fitnessData;
  final ImagePicker _picker = ImagePicker(); // 갤러리 접근용

  @override
  void initState() {
    super.initState();
    _fitnessData = FitnessData();
    // 3. 위젯이 처음 생성될 때, MainScreen에서 받은 이미지로 초기화
    _selectedImage = widget.initialImage;
  }

  // 4. (중요) MainScreen의 상태가 바뀌어 GenerateScreen이 다시 빌드될 때
  // 새로운 initialImage를 반영하기 위한 함수
  @override
  void didUpdateWidget(covariant GenerateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImage != oldWidget.initialImage) {
      setState(() {
        _selectedImage = widget.initialImage;
      });
    }
  }

  // 5. 카메라 또는 갤러리에서 이미지를 가져오는 내부 함수
  Future<void> _pickImage(ImageSource source) async {
    String? imagePath;

    if (source == ImageSource.camera) {
      final result = await Navigator.pushNamed(context, '/camera');
      if (result != null && result is String) {
        imagePath = result;
      }
    } else {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        imagePath = image.path;
      }
    }

    if (imagePath != null) {
      setState(() {
        _selectedImage = File(imagePath!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight),
            const Center(
              child: Text(
                '이미지 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B9FED),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 이미지 선택기 UI
            _buildImagePicker(),
            const SizedBox(height: 24),

            // 칼로리 카드 (막대 그래프 포함)
            _buildProgressInfoCard(
              title: '칼로리',
              value: '${_fitnessData.calories.toInt()}',
              subtitle: '목표 ${_fitnessData.caloriesGoal.toInt()}칼로리',
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B6B),
              progress: _fitnessData.caloriesProgress,
            ),

            const SizedBox(height: 16),

            // 운동 카드
            _buildInfoCard(
              title: '운동',
              value: _fitnessData.exerciseType,
              subtitle: '${_fitnessData.exerciseDuration}분 소요',
              icon: Icons.fitness_center,
              iconColor: const Color(0xFF9E9E9E),
            ),

            const SizedBox(height: 16),

            // 체중 목표 카드
            _buildProgressInfoCard(
              title: '현재 목표',
              value: '${_fitnessData.weightGoal.toInt()}kg 감량',
              subtitle: '${_fitnessData.weightRemaining.toInt()}kg 남음',
              icon: Icons.help_outline,
              iconColor: const Color(0xFF9E9E9E),
              progress: _fitnessData.weightProgress,
            ),

            const SizedBox(height: 24),

            // 기간 선택
            const Text(
              '기간 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton('6개월', _fitnessData.selectedPeriod == '6개월'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodButton('12개월', _fitnessData.selectedPeriod == '12개월'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton('18개월', _fitnessData.selectedPeriod == '18개월'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodButton('24개월', _fitnessData.selectedPeriod == '24개월'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 이미지 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/loading',
                    arguments: {
                      'calories': _fitnessData.calories,
                      'weightGoal': _fitnessData.weightGoal,
                      'period': _fitnessData.selectedPeriod,
                      'imagePath': _selectedImage?.path, // 선택된 이미지 경로 전달
                    },
                  );
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
                    Icon(Icons.image, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '이미지 생성',
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- 헬퍼 위젯들 ---

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선택 이미지',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),
        _selectedImage != null
            ?
        Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            // 이미지 삭제(x) 버튼
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
            )
          ],
        )
            :
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Color(0xFF5B9FED)),
                label: const Text('카메라', style: TextStyle(color: Color(0xFF5B9FED))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Color(0xFF5B9FED)),
                label: const Text('갤러리', style: TextStyle(color: Color(0xFF5B9FED))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              Icon(icon, color: iconColor, size: 32),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B9FED)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
          Icon(icon, color: iconColor, size: 32),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _fitnessData = _fitnessData.copyWith(selectedPeriod: period);
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B9FED) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            period,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}