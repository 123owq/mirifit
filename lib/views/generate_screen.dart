import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/fitness_data.dart';


class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  File? _selectedImage;
  // double _calories = 1847;
  // double _weightGoal = 5.0;
  // String _selectedPeriod = '6개월';


  /////////model/// 하드코딩 대신 모델 사용
  late FitnessData _fitnessData;
  
  @override
  void initState() {
    super.initState();
    _fitnessData = FitnessData(); // 초기 데이터
  }
  ///////////////////////

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Scaffold, AppBar, BottomNavBar를 모두 제거합니다.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. [추가] AppBar 대신 화면 상단 여백과 타이틀을 넣습니다.
            const SizedBox(height: kToolbarHeight), // 시스템 상태 표시줄 만큼 여백
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
            const SizedBox(height: 24), // 타이틀과 카드 사이 여백

            // 3. 기존 body의 Column 내용물은 그대로 둡니다.
            // 칼로리 카드
            _buildGoalCard(
              title: '칼로리',
              value: '${_fitnessData.calories.toInt()}',
              subtitle: '목표 ${_fitnessData.caloriesGoal.toInt()}칼로리',
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B6B),
              progress: _fitnessData.caloriesProgress,
              onChanged: (value) {
                setState(() {
                  _fitnessData = _fitnessData.copyWith(calories: value);
                });
              },
              min: 0,
              max: 3000,
            ),

            // 운동 카드
            _buildInfoCard(
              title: '운동',
              value: _fitnessData.exerciseType,
              subtitle: '${_fitnessData.exerciseDuration}분 소요',
              icon: Icons.fitness_center,
              iconColor: const Color(0xFF9E9E9E),
            ),

            // 체중 목표 카드
            _buildGoalCard(
              title: '현재 목표',
              value: '${_fitnessData.weightGoal.toInt()}kg 감량',
              subtitle: '${_fitnessData.weightRemaining.toInt()}kg 남음',
              icon: Icons.help_outline,
              iconColor: const Color(0xFF9E9E9E),
              progress: _fitnessData.weightProgress,
              onChanged: (value) {
                setState(() {
                  _fitnessData = _fitnessData.copyWith(weightGoal: value);
                });
              },
              min: 1,
              max: 20,
            ),

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

            // Generate Button (경로는 /loading으로 유지)
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
                      'imagePath': _selectedImage?.path,
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

  // 목표 카드 빌더 (슬라이더 포함)
  Widget _buildGoalCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double progress,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: const Color(0xFF5B9FED),
              inactiveTrackColor: const Color(0xFFE5E5E5),
              thumbColor: const Color(0xFF5B9FED),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0) * (max - min) + min,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // 정보 카드 빌더
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

  // 기간 선택 버튼 빌더
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
