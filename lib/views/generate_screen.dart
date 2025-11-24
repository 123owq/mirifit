import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 갤러리용
import 'dart:io'; // File 클래스용
import 'package:permission_handler/permission_handler.dart';
import '../models/fitness_data.dart';
import '../models/app_mode.dart';
import '../services/api_service.dart';
import 'result_screen.dart'; // ResultScreen import

class GenerateScreen extends StatefulWidget {
  final AppMode mode;
  final FitnessData fitnessData; // FitnessData 전달 받기
  final String? initialImagePath;
  final VoidCallback onClearImage;

  const GenerateScreen({
    super.key,
    required this.mode,
    required this.fitnessData, // 생성자에 추가
    this.initialImagePath,
    required this.onClearImage,
  });

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  String? _selectedImagePath;
  late FitnessData _fitnessData;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  int _selectedCalorieLevel = 1;
  int _selectedExerciseLevel = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 전달받은 fitnessData로 상태 초기화
    _fitnessData = widget.fitnessData;
    _selectedImagePath = widget.initialImagePath;
  }

  @override
  void didUpdateWidget(covariant GenerateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImagePath != oldWidget.initialImagePath) {
      setState(() {
        _selectedImagePath = widget.initialImagePath;
      });
    }
    // 부모 위젯에서 fitnessData가 변경될 경우를 대비해 업데이트
    if (widget.fitnessData != oldWidget.fitnessData) {
      setState(() {
        _fitnessData = widget.fitnessData;
      });
    }
  }

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
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<void> _generateImage() async {
    if (_selectedImagePath == null) {
      _showSnackBar('이미지를 먼저 선택해주세요.', Colors.red);
      return;
    }

    PermissionStatus status;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }

    // if (!status.isGranted) {
    //   _showSnackBar('이미지 저장을 위해 저장소 권한이 필요합니다.', Colors.red);
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageFile = File(_selectedImagePath!);

      // 전달받은 fitnessData 사용
      final String sex = _fitnessData.gender == '남성' ? 'male' : 'female';
      final double height = _fitnessData.height;
      final int age = _fitnessData.age;
      final double currentWeight = _fitnessData.currentWeight;
      
      // TODO: 아래 값들은 추후 UI를 통해 입력받거나 계산해야 합니다.
      final int dailyCaloriesBurned = 500; // 임시값
      final int dailyCaloriesIntake = _fitnessData.caloriesGoal > 0 ? _fitnessData.caloriesGoal.toInt() : 2000;
      final double bellySize = 0.0; // 임시값

      // 기간 선택 (예: '6개월' -> 180일)
      int days = 90; // 기본값
      if (_fitnessData.selectedPeriod == '6개월') {
        days = 180;
      } else if (_fitnessData.selectedPeriod == '12개월') {
        days = 365;
      } else if (_fitnessData.selectedPeriod == '18개월') {
        days = 547;
      } else if (_fitnessData.selectedPeriod == '24개월') {
        days = 730;
      }

      final response = await _apiService.transformImage(
        imageFile: imageFile,
        sex: sex,
        height: height,
        currentWeight: currentWeight,
        age: age,
        dailyCaloriesBurned: dailyCaloriesBurned,
        dailyCaloriesIntake: dailyCaloriesIntake,
        days: days,
        bellySize: bellySize,
      );

      // 성공 시 result_screen으로 이동
      if (mounted) {
        // ResultScreen으로 직접 이동하고 데이터를 전달합니다.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(resultData: response),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('이미지 생성 실패: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (build 메서드의 나머지 부분은 2:13 PM 코드와 동일합니다)
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

            // 6. [수정됨] 이미지 선택기 UI
            _buildImagePicker(),
            const SizedBox(height: 24),

            if (widget.mode == AppMode.simple)
              _buildSimpleModeContent()
            else
              _buildPreciseModeContent(),
            const SizedBox(height: 16),

            // ... (칼로리, 운동, 체중 카드 등은 2:13 PM 코드와 동일) ...
            _buildProgressInfoCard(
              title: '현재 목표',
              value: '${_fitnessData.weightGoal.toInt()}kg 감량',
              subtitle: '${_fitnessData.weightRemaining.toInt()}kg 남음',
              icon: Icons.help_outline,
              iconColor: const Color(0xFF9E9E9E),
              progress: _fitnessData.weightProgress,
            ),
            const SizedBox(height: 24),
            // ... (기간 선택 버튼들 - 2:13 PM 코드와 동일) ...
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
                  child: _buildPeriodButton(
                    '6개월',
                    _fitnessData.selectedPeriod == '6개월',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodButton(
                    '12개월',
                    _fitnessData.selectedPeriod == '12개월',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton(
                    '18개월',
                    _fitnessData.selectedPeriod == '18개월',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodButton(
                    '24개월',
                    _fitnessData.selectedPeriod == '24개월',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 7. [수정됨] 이미지 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateImage, // 로딩 중에는 버튼 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9FED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // 로딩 인디케이터
                    : const Row(
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

  Widget _buildSimpleModeContent() {
    return Column(
      children: [
        _buildSelectionCard(
          title: "칼로리",
          options: ["적음", "보통", "많음"],
          selectedIndex: _selectedCalorieLevel,
          onChanged: (index) => setState(() => _selectedCalorieLevel = index),
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFFF6B6B),
        ),
        const SizedBox(height: 16),
        _buildSelectionCard(
          title: "운동강도",
          options: ["낮음", "보통", "높음"],
          selectedIndex: _selectedExerciseLevel,
          onChanged: (index) => setState(() => _selectedExerciseLevel = index),
          icon: Icons.fitness_center,
          iconColor: const Color(0xFF9E9E9E),
        ),
      ],
    );
  }

  // --- [B] 정밀 모드 (Precise Mode): 구체적인 수치 확인 ---
  Widget _buildPreciseModeContent() {
    return Column(
      children: [
        _buildProgressInfoCard(
          title: '칼로리',
          value: '${_fitnessData.calories.toInt()}',
          subtitle: '목표 ${_fitnessData.caloriesGoal.toInt()}칼로리',
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFFF6B6B),
          progress: _fitnessData.caloriesProgress,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: '운동',
          value: _fitnessData.exerciseType,
          subtitle: '${_fitnessData.exerciseDuration}분 소요',
          icon: Icons.fitness_center,
          iconColor: const Color(0xFF9E9E9E),
        ),
      ],
    );
  }

  // --- [C] 버튼 선택 카드 위젯 (간단 모드용) ---
  Widget _buildSelectionCard({
    required String title,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onChanged,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "평소를 기준으로 선택해주세요",
                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
              Icon(icon, color: iconColor, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(options.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => onChanged(index),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5B9FED)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5B9FED)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        options[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF666666),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- 헬퍼 위젯들 ---

  // 8. [수정됨] 이미지 피커 UI
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선택된 이미지',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),
        _selectedImagePath != null
            ? Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // ★ 9. [수정됨] 경로를 확인하여 Asset 또는 File 이미지 표시
                    child: _selectedImagePath!.startsWith('assets/')
                        ? Image.asset(
                            // Asset 이미지 (크롬 데모)
                            _selectedImagePath!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            // File 이미지 (카메라/갤러리)
                            File(_selectedImagePath!),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.black54),
                    onPressed: () {
                      setState(() {
                        _selectedImagePath = null;
                        widget.onClearImage(); // ★ MainScreen에도 이미지가 지워졌다고 알림
                      });
                    },
                  ),
                ],
              )
            : Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF5B9FED),
                      ),
                      label: const Text(
                        '카메라',
                        style: TextStyle(color: Color(0xFF5B9FED)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Color(0xFF5B9FED),
                      ),
                      label: const Text(
                        '갤러리',
                        style: TextStyle(color: Color(0xFF5B9FED)),
                      ),
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

  // (이 아래의 _buildProgressInfoCard, _buildInfoCard, _buildPeriodButton 함수는
  // 2:13 PM에 드린 코드와 동일하므로, 기존 코드를 그대로 두시면 됩니다.)

  // 10. 정보 + 막대 그래프 위젯 (칼로리, 현재 목표)
  Widget _buildProgressInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required double progress,
  }) {
    // ... (2:13 PM 코드와 동일) ...
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF5B9FED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 11. 정보만 표시하는 위젯 (운동)
  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    // ... (2:13 PM 코드와 동일) ...
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

  // 12. 기간 선택 버튼 위젯
  Widget _buildPeriodButton(String period, bool isSelected) {
    // ... (2:13 PM 코드와 동일) ...
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
