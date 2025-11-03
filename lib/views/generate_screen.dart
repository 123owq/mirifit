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
  late FitnessData _fitnessData;

  @override
  void initState() {
    super.initState();
    _fitnessData = FitnessData(); // 초기 데이터
  }

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

            // ★ 1. 칼로리 카드: 새 위젯인 _buildProgressInfoCard 사용
            _buildProgressInfoCard(
              title: '칼로리',
              value: '${_fitnessData.calories.toInt()}',
              subtitle: '목표 ${_fitnessData.caloriesGoal.toInt()}칼로리',
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B6B),
              progress: _fitnessData.caloriesProgress, // ★ 진행률 데이터 전달
            ),

            const SizedBox(height: 16),

            // ★ 2. 운동 카드: 기존 _buildInfoCard 사용 (막대 그래프 없음)
            _buildInfoCard(
              title: '운동',
              value: _fitnessData.exerciseType,
              subtitle: '${_fitnessData.exerciseDuration}분 소요',
              icon: Icons.fitness_center,
              iconColor: const Color(0xFF9E9E9E),
            ),

            const SizedBox(height: 16),

            // ★ 3. 체중 목표 카드: 새 위젯인 _buildProgressInfoCard 사용
            _buildProgressInfoCard(
              title: '현재 목표',
              value: '${_fitnessData.weightGoal.toInt()}kg 감량',
              subtitle: '${_fitnessData.weightRemaining.toInt()}kg 남음',
              icon: Icons.help_outline,
              iconColor: const Color(0xFF9E9E9E),
              progress: _fitnessData.weightProgress, // ★ 진행률 데이터 전달
            ),

            const SizedBox(height: 24),

            // 기간 선택 (기존과 동일)
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

            // Generate Button (기존과 동일)
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

  // ★ 4. [새로 추가된 위젯] (막대 그래프 포함)
  Widget _buildProgressInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double progress, // (0.0 ~ 1.0 사이의 값)
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
      child: Column( // 정보 + 막대그래프를 위해 Column 사용
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보 부분
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
          const SizedBox(height: 16), // 정보와 막대 그래프 사이 여백

          // 하단 막대 그래프
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // 막대 모서리를 둥글게
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0), // 0.0 ~ 1.0 사이 값
              minHeight: 8, // 막대 두께
              backgroundColor: const Color(0xFFE5E5E5), // 배경색
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B9FED)), // 진행색
            ),
          ),
        ],
      ),
    );
  }

  // ★ 5. [기존 위젯] (정보만 표시)
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

  // 기간 선택 버튼 빌더 (기존과 동일)
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