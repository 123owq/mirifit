import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 갤러리용
import 'dart:io'; // File 클래스용
import 'package:permission_handler/permission_handler.dart';
import '../models/fitness_data.dart';
import '../services/api_service.dart';
import 'result_screen.dart'; // ResultScreen import
import 'dart:math'; // min/max 함수 사용을 위해 추가

class GenerateScreen extends StatefulWidget {
  final FitnessData fitnessData; // FitnessData 전달 받기
  final String? initialImagePath;
  final VoidCallback onClearImage;

  const GenerateScreen({
    super.key,
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

  // ★ 1. 몸무게 입력을 위한 컨트롤러 추가
  final TextEditingController _weightController = TextEditingController();

  // 칼로리 조절을 위한 상태 변수
  late double _caloriesIntake; // 섭취 칼로리 (슬라이더 값)
  late double _caloriesBurned; // 소모 칼로리 (슬라이더 값)
  late int _bmr; // 기초대사량 (Base Metabolic Rate)
  late int _maxCalorie; // 최대 수치 (BMR의 2배)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fitnessData = widget.fitnessData;
    _selectedImagePath = widget.initialImagePath;

    // ★ 2. 컨트롤러 초기값 설정
    _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);

    // 1. 기초대사량 (BMR) 계산 및 초기값 설정
    _bmr = _calculateBMR(
      _fitnessData.gender,
      _fitnessData.height,
      _fitnessData.currentWeight,
      _fitnessData.age,
    );
    _maxCalorie = _bmr * 2; // 최대 수치는 BMR의 2배

    // 초기 슬라이더 값: BMR을 기준으로 설정
    _caloriesIntake = _bmr.toDouble();
    _caloriesBurned = _bmr.toDouble();
  }

  @override
  void dispose() {
    // ★ 3. 컨트롤러 해제
    _weightController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GenerateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImagePath != oldWidget.initialImagePath) {
      setState(() {
        _selectedImagePath = widget.initialImagePath;
      });
    }
    if (widget.fitnessData != oldWidget.fitnessData) {
      setState(() {
        _fitnessData = widget.fitnessData;
        _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1); // 컨트롤러도 업데이트

        final newBMR = _calculateBMR(
          _fitnessData.gender,
          _fitnessData.height,
          _fitnessData.currentWeight,
          _fitnessData.age,
        );
        _bmr = newBMR;
        _maxCalorie = _bmr * 2;

        _caloriesIntake = newBMR.toDouble();
        _caloriesBurned = newBMR.toDouble();
      });
    }
  }

  // ★ 4. 몸무게 업데이트 및 BMR 재계산 함수
  void _updateWeightAndBMR(String weightString) {
    // 입력된 텍스트에서 숫자만 추출하거나 파싱 시도
    final double? newWeight = double.tryParse(weightString.trim());

    // 파싱에 성공했고, 양수이며, 현재 값과 다를 때만 업데이트
    if (newWeight != null && newWeight > 0 && (newWeight - _fitnessData.currentWeight).abs() > 0.1) {
      setState(() {
        // FitnessData 업데이트
        _fitnessData = _fitnessData.copyWith(currentWeight: newWeight);

        // BMR 및 최대 칼로리 재계산
        final newBMR = _calculateBMR(
          _fitnessData.gender,
          _fitnessData.height,
          newWeight,
          _fitnessData.age,
        );

        _bmr = newBMR;
        _maxCalorie = _bmr * 2;

        // 슬라이더 초기화 (재설정)
        _caloriesIntake = newBMR.toDouble();
        _caloriesBurned = newBMR.toDouble();
      });

      // UI에 업데이트된 몸무게 반영 (소수점 1자리로 통일)
      _weightController.text = newWeight.toStringAsFixed(1);
      _showSnackBar('몸무게가 ${newWeight.toStringAsFixed(1)} kg으로 업데이트되었습니다. BMR이 재계산되었습니다.', Colors.green);
    } else if (newWeight == null || newWeight <= 0) {
      // 유효하지 않은 입력인 경우, 기존 유효한 값으로 되돌림
      _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);
      _showSnackBar('유효한 몸무게(양수)를 입력해주세요.', Colors.orange);
    } else {
      // 입력은 유효하나 값이 변하지 않은 경우 (Do nothing)
      _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);
    }
  }

  // --- BMR 계산 함수 (Harris-Benedict 공식) ---
  int _calculateBMR(String gender, double height, double weight, int age) {
    double bmr;
    if (gender == '남성') {
      // 남성: 66.47 + (13.75 * 체중) + (5 * 키) - (6.76 * 나이)
      bmr = 66.47 + (13.75 * weight) + (5 * height) - (6.76 * age);
    } else {
      // 여성: 655.1 + (9.56 * 체중) + (1.85 * 키) - (4.68 * 나이)
      bmr = 655.1 + (9.56 * weight) + (1.85 * height) - (4.68 * age);
    }
    // BMR은 0보다 작을 수 없으며, 정수로 반환
    return max(0, bmr.round());
  }
  // ----------------------------------------

  // ... (rest of _pickImage, _generateImage, _showSnackBar functions - no changes)

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

    setState(() {
      _isLoading = true;
    });

    try {
      final imageFile = File(_selectedImagePath!);

      final String sex = _fitnessData.gender == '남성' ? 'male' : 'female';
      final double height = _fitnessData.height;
      final int age = _fitnessData.age;
      // 최신 업데이트된 몸무게 사용
      final double currentWeight = _fitnessData.currentWeight;

      // 슬라이더에서 조절된 값 사용
      final int dailyCaloriesBurned = _caloriesBurned.round();
      final int dailyCaloriesIntake = _caloriesIntake.round();
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

  // ★ 5. 몸무게 입력 위젯
  Widget _buildWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 몸무게 (kg)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _weightController,
          // 숫자와 소수점만 입력 가능하게 설정
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: '예: 70.5',
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B9FED), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
          ),
          // 포커스가 사라질 때 몸무게 업데이트 및 BMR 재계산
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
            _updateWeightAndBMR(_weightController.text);
          },
          // 제출(엔터) 시 몸무게 업데이트 및 BMR 재계산
          onFieldSubmitted: _updateWeightAndBMR,
        ),
      ],
    );
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

            // ★ 몸무게 입력 칸 추가
            _buildWeightInput(),
            const SizedBox(height: 24),

            // 칼로리 슬라이더 위젯 삽입
            _buildCalorieSliders(),
            const SizedBox(height: 24),

            // 기간 선택 버튼들
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

            // 이미지 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9FED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
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

  // ★ 칼로리 슬라이더 메인 위젯
  Widget _buildCalorieSliders() {
    return Column(
      children: [
        // 섭취 칼로리 슬라이더
        _buildCalorieSliderCard(
          title: '섭취 칼로리',
          subTitle: '평소를 기준으로 선택해주세요.',
          icon: Icons.fastfood,
          iconColor: const Color(0xFF1A1A1A), // 흑백(진한 회색)
          currentValue: _caloriesIntake,
          onChanged: (newValue) {
            setState(() {
              _caloriesIntake = newValue; // 스무스하게 움직이도록 double 유지
            });
          },
          minLabel: '공복',
          midLabel: '보통',
          maxLabel: '많이 먹음',
        ),
        const SizedBox(height: 16),
        // 소모 칼로리 슬라이더 (운동강도)
        _buildCalorieSliderCard(
          title: '운동강도',
          subTitle: '평소를 기준으로 선택해주세요.',
          icon: Icons.fitness_center, // 역기 아이콘
          iconColor: const Color(0xFF1A1A1A), // 흑백(진한 회색)
          currentValue: _caloriesBurned,
          onChanged: (newValue) {
            setState(() {
              _caloriesBurned = newValue; // 스무스하게 움직이도록 double 유지
            });
          },
          minLabel: '운동량 없음',
          midLabel: '보통',
          maxLabel: '운동량 많음',
        ),
      ],
    );
  }

  // ★ 칼로리 슬라이더 개별 카드 위젯 (최종 수정)
  Widget _buildCalorieSliderCard({
    required String title,
    required String subTitle,
    required IconData icon,
    required Color iconColor,
    required double currentValue,
    required ValueChanged<double> onChanged,
    required String minLabel,
    required String midLabel,
    required String maxLabel,
  }) {
    // Max Calorine을 기준으로 정규화된 값 계산 (0.0 ~ 1.0)
    final double normalizedValue = (_maxCalorie > 0) ? (currentValue.clamp(0.0, _maxCalorie.toDouble())) / _maxCalorie : 0.0;


    // 파란색 그라데이션
    final Color barColor = Color.lerp(
      const Color(0xFFB3E0FF), // 옅은 파랑
      const Color(0xFF1E90FF), // 진한 파랑
      normalizedValue.clamp(0.0, 1.0),
    )!;

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
          // 1. 헤더 (타이틀, 아이콘)
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
                  Text(
                    subTitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
              Icon(icon, color: iconColor, size: 32),
            ],
          ),
          const SizedBox(height: 20),

          // ★ 2. 고정 수치 레이블: 0 kcal, BMR kcal, Max kcal (바 위에 위치)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0 kcal', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),

                // BMR kcal (중간 수치)
                Text(
                  '${_bmr.round()} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                // Max kcal
                Text(
                  '${_maxCalorie.round()} kcal',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4), // 수치 레이블과 바 사이 간격

          // 3. 슬라이더 및 바 영역
          Stack(
            alignment: Alignment.center,
            children: [
              // 바 (LinearProgressIndicator)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 10,
                  child: LinearProgressIndicator(
                    value: normalizedValue,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE5E5E5),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),

              // 기초대사량 (BMR) 표시 마커 (50% 지점)
              // Stack의 크기 계산을 위해 MediaQuery 대신 고정 너비 사용 (Padding을 고려하여 40을 뺌)
              Positioned(
                left: (_maxCalorie > 0) ? (MediaQuery.of(context).size.width - 40) * 0.5 - 20 - 2 : 0,
                child: Container(
                  width: 4,
                  height: 20,
                  color: Colors.black,
                ),
              ),

              // 슬라이더 (divisions 제거로 스무스하게 움직임)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  thumbColor: const Color(0xFF5B9FED),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayColor: const Color(0x295B9FED),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                ),
                child: Slider(
                  min: 0,
                  max: _maxCalorie.toDouble(), // 최대값은 BMR * 2
                  value: currentValue,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5. '공복', '보통', '많이 먹음' 텍스트 레이블 (바 아래)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minLabel, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                Text(midLabel, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
                Text(maxLabel, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 기존 헬퍼 위젯들 (변경 없음) ---

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
                  Container( // ClipRRect 대신 Container로 감싸서 최대 높이 제한
                    constraints: const BoxConstraints(
                      maxHeight: 300, // 원하는 최대 높이 설정 (예: 300)
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImagePath!.startsWith('assets/')
                          ? Image.asset(
                        _selectedImagePath!,
                        width: double.infinity,
                        // height 속성 제거 또는 null
                        fit: BoxFit.contain, // ★★★ contain으로 변경하여 비율 유지 및 잘림 방지
                      )
                          : Image.file(
                        File(_selectedImagePath!),
                        width: double.infinity,
                        // height 속성 제거 또는 null
                        fit: BoxFit.contain, // ★★★ contain으로 변경하여 비율 유지 및 잘림 방지
                      ),
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

  // 기간 선택 버튼 위젯
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