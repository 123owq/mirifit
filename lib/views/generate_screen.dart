import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // 시간 선택을 위해 추가
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../models/fitness_data.dart';
import '../services/api_service.dart';
import 'result_screen.dart';
import 'dart:math';

// ----------------------------------------------------
// 🔥 MET 운동 활동 모델 정의 (새로 추가)
// ----------------------------------------------------
class METActivity {
  final String name; // 운동 이름
  final double metValue; // MET 값
  final IconData icon; // 표시할 아이콘

  const METActivity({
    required this.name,
    required this.metValue,
    required this.icon,
  });
}

// ----------------------------------------------------
// 🔥 기록된 활동 모델 정의 (새로 추가)
// ----------------------------------------------------
class RecordedActivity {
  final METActivity activity;
  final int minutes; // 운동 시간 (분)
  final double calories; // 소모 칼로리

  RecordedActivity({
    required this.activity,
    required this.minutes,
    required this.calories,
  });
}

// ----------------------------------------------------
// GenerateScreen 클래스 (기존과 동일)
// ----------------------------------------------------
class GenerateScreen extends StatefulWidget {
  final FitnessData fitnessData;
  final String? initialImagePath;
  final VoidCallback onClearImage;

  const GenerateScreen({
    super.key,
    required this.fitnessData,
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

  final TextEditingController _weightController = TextEditingController();

  // 칼로리 조절을 위한 상태 변수
  late double _caloriesIntake; // 섭취 칼로리 (슬라이더 값)
  late double _caloriesBurned; // 소모 칼로리 (슬라이더 값 - API 전송용)
  late int _bmr; // 기초대사량 (Base Metabolic Rate)
  late int _maxCalorie; // 최대 수치 (BMR의 2배)

  bool _isLoading = false;

  // 🔥 MET 기반 운동 기록 상태 변수 (새로 추가)
  List<RecordedActivity> _recordedActivities = [];
  double _totalCaloriesBurned = 0.0; // 총 소비 칼로리

  // 🔥 운동 종류 목록 (MET 값과 아이콘 포함) (새로 추가)
  final List<METActivity> _metActivities = const [
    METActivity(name: '달리기', metValue: 8.0, icon: Icons.directions_run),
    METActivity(name: '걷기', metValue: 3.5, icon: Icons.directions_walk),
    METActivity(name: '자전거 타기', metValue: 7.5, icon: Icons.bike_scooter),
    METActivity(name: '수영', metValue: 6.0, icon: Icons.pool),
    METActivity(name: '요가', metValue: 3.0, icon: Icons.self_improvement),
    METActivity(name: '근력 운동', metValue: 5.0, icon: Icons.fitness_center),
    METActivity(name: '축구', metValue: 7.0, icon: Icons.sports_soccer),
    // 필요한 다른 활동 추가
  ];


  @override
  void initState() {
    super.initState();
    _fitnessData = widget.fitnessData;
    _selectedImagePath = widget.initialImagePath;

    _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);

    _bmr = _calculateBMR(
      _fitnessData.gender,
      _fitnessData.height,
      _fitnessData.currentWeight,
      _fitnessData.age,
    );
    _maxCalorie = _bmr * 2;

    _caloriesIntake = _bmr.toDouble();
    // 초기 소모 칼로리 값도 BMR로 설정
    _caloriesBurned = _bmr.toDouble();
  }

  // (이하 dispose, didUpdateWidget, _updateWeightAndBMR, _calculateBMR, _pickImage, _generateImage, _showSnackBar 생략 - 변경 없음)
  @override
  void dispose() {
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
        _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);

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

  void _updateWeightAndBMR(String weightString) {
    final double? newWeight = double.tryParse(weightString.trim());

    if (newWeight != null && newWeight > 0 && (newWeight - _fitnessData.currentWeight).abs() > 0.1) {
      setState(() {
        _fitnessData = _fitnessData.copyWith(currentWeight: newWeight);

        final newBMR = _calculateBMR(
          _fitnessData.gender,
          _fitnessData.height,
          newWeight,
          _fitnessData.age,
        );

        _bmr = newBMR;
        _maxCalorie = _bmr * 2;

        _caloriesIntake = newBMR.toDouble();
        // 몸무게가 바뀌면 MET 기반 총 칼로리도 재계산
        _recalculateTotalBurnedCalories();
        // API 전송용 _caloriesBurned도 총 칼로리 값으로 업데이트
        _caloriesBurned = _totalCaloriesBurned;
      });

      _weightController.text = newWeight.toStringAsFixed(1);
      _showSnackBar('몸무게가 ${newWeight.toStringAsFixed(1)} kg으로 업데이트되었습니다. BMR이 재계산되었습니다.', Colors.green);
    } else if (newWeight == null || newWeight <= 0) {
      _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);
      _showSnackBar('유효한 몸무게(양수)를 입력해주세요.', Colors.orange);
    } else {
      _weightController.text = _fitnessData.currentWeight.toStringAsFixed(1);
    }
  }

  int _calculateBMR(String gender, double height, double weight, int age) {
    double bmr;
    if (gender == '남성') {
      bmr = 66.47 + (13.75 * weight) + (5 * height) - (6.76 * age);
    } else {
      bmr = 655.1 + (9.56 * weight) + (1.85 * height) - (4.68 * age);
    }
    return max(0, bmr.round());
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

    setState(() {
      _isLoading = true;
    });

    try {
      final imageFile = File(_selectedImagePath!);

      final String sex = _fitnessData.gender == '남성' ? 'male' : 'female';
      final double height = _fitnessData.height;
      final int age = _fitnessData.age;
      final double currentWeight = _fitnessData.currentWeight;

      final int dailyCaloriesBurned = _totalCaloriesBurned.round(); // 🔥 MET 기반 총 소모 칼로리 사용
      final int dailyCaloriesIntake = _caloriesIntake.round();
      final double bellySize = 0.0;

      int days = 90;
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

  Widget _buildWeightInput() {
    // ... (기존 _buildWeightInput 내용과 동일)
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
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
            _updateWeightAndBMR(_weightController.text);
          },
          onFieldSubmitted: _updateWeightAndBMR,
        ),
      ],
    );
  }


  // 🔥 MET 칼로리 계산 함수 (새로 추가)
  // 소모 칼로리 (kcal) = METs * 3.5 * 체중(kg) * 시간(분) / 200
  double _calculateMetCalories(double metValue, int minutes) {
    // 현재 몸무게 사용
    final double weight = _fitnessData.currentWeight;
    if (weight <= 0) return 0.0;

    // 계산: METs * 3.5 * 체중(kg) * (시간/60) / 5
    // 또는 METs * 3.5 * 체중(kg) * 시간(분) / 200 (분 단위 공식)
    double calories = metValue * 3.5 * weight * minutes / 200;
    return calories; // 소수점 2자리에서 반올림
  }

  // 🔥 총 소비 칼로리 재계산 (새로 추가)
  void _recalculateTotalBurnedCalories() {
    double total = 0.0;
    for (var activity in _recordedActivities) {
      // 기존 저장된 activity의 metValue와 minutes를 사용하여 현재 weight로 재계산
      total += _calculateMetCalories(activity.activity.metValue, activity.minutes);
    }
    setState(() {
      _totalCaloriesBurned = total;
      // API 전송용 변수도 업데이트
      _caloriesBurned = total;
    });
  }

  // 🔥 운동 선택 다이얼로그 (새로 추가)
  Future<void> _showExerciseSelectionDialog() async {
    final selectedActivity = await showModalBottomSheet<METActivity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '운동 종류 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8, // 아이콘과 텍스트 공간 확보
                    ),
                    itemCount: _metActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _metActivities[index];
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, activity),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                activity.icon,
                                size: 40,
                                color: const Color(0xFF5B9FED),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activity.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${activity.metValue} METs',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedActivity != null) {
      _showTimeInputDialog(selectedActivity);
    }
  }

  // 🔥 시간 입력 다이얼로그 (CupertinoPicker 사용) (새로 추가)
  Future<void> _showTimeInputDialog(METActivity activity) async {
    int selectedHours = 0;
    int selectedMinutes = 0;

    // 최대 시간 설정 (예: 5시간 59분)
    const int maxHours = 5;
    const int maxMinutes = 59;

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${activity.name} 운동 시간 입력 (최대 ${maxHours}시간 ${maxMinutes}분)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // 시간 선택 휠
                    SizedBox(
                      width: 80,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: 0),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          selectedHours = index;
                        },
                        children: List<Widget>.generate(maxHours + 1, (int index) {
                          return Center(child: Text('$index 시간'));
                        }),
                      ),
                    ),
                    // 분 선택 휠
                    SizedBox(
                      width: 80,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: 0),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          selectedMinutes = index;
                        },
                        children: List<Widget>.generate(maxMinutes + 1, (int index) {
                          return Center(child: Text('$index 분'));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: const Color(0xFF5B9FED),
                  child: const Text('확인'),
                  onPressed: () {
                    // 총 운동 시간 (분) 계산
                    final int totalMinutes = (selectedHours * 60) + selectedMinutes;
                    if (totalMinutes > 0) {
                      final double calories = _calculateMetCalories(activity.metValue, totalMinutes);
                      setState(() {
                        // 기록 추가
                        _recordedActivities.add(RecordedActivity(
                          activity: activity,
                          minutes: totalMinutes,
                          calories: calories,
                        ));
                        _totalCaloriesBurned += calories; // 총합 업데이트
                        _caloriesBurned = _totalCaloriesBurned; // API 전송용 변수 업데이트
                      });
                      Navigator.pop(context); // 다이얼로그 닫기
                    } else {
                      _showSnackBar('최소 1분 이상의 시간을 입력해주세요.', Colors.orange);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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

            _buildImagePicker(),
            const SizedBox(height: 24),

            _buildWeightInput(),
            const SizedBox(height: 24),

            // 🔥 섭취 칼로리 슬라이더 (수정된 버전)
            _buildCalorieIntakeSlider(),
            const SizedBox(height: 24),

            // 🔥 소비 칼로리 (MET 기반) (새로 추가)
            _buildCalorieBurnedMet(),
            const SizedBox(height: 24),

            // (이하 기간 선택 및 이미지 생성 버튼 기존과 동일)
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
                Expanded(child: _buildPeriodButton('6개월', _fitnessData.selectedPeriod == '6개월')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButton('12개월', _fitnessData.selectedPeriod == '12개월')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPeriodButton('18개월', _fitnessData.selectedPeriod == '18개월')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButton('24개월', _fitnessData.selectedPeriod == '24개월')),
              ],
            ),
            const SizedBox(height: 32),

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

  // 🔥 섭취 칼로리 슬라이더 위젯 (수정: 툴팁으로 수치 표시)
  Widget _buildCalorieIntakeSlider() {
    return _buildCalorieSliderCard(
      title: '섭취 칼로리',
      subTitle: '평소를 기준으로 선택해주세요.',
      icon: Icons.fastfood,
      currentValue: _caloriesIntake,
      onChanged: (newValue) {
        setState(() {
          _caloriesIntake = newValue;
        });
      },
      minLabel: '공복',
      midLabel: '보통',
      maxLabel: '많이 먹음',
      // 슬라이더에 툴팁 기능 추가
      showTooltip: true,
    );
  }

  // 🔥 소비 칼로리 (MET 기반) 위젯 (새로 추가)
  Widget _buildCalorieBurnedMet() {
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
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '소비 칼로리',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'MET 기반 운동 기록',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
              const Icon(Icons.local_fire_department, color: Color(0xFF1A1A1A), size: 32),
            ],
          ),
          const SizedBox(height: 16),

          // 기록된 운동 목록
          ..._recordedActivities.map((activity) {
            final double calories = activity.calories;
            final int minutes = activity.minutes;
            final String hours = (minutes ~/ 60).toString().padLeft(2, '0');
            final String mins = (minutes % 60).toString().padLeft(2, '0');

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(activity.activity.icon, size: 20, color: const Color(0xFF5B9FED)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.activity.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$hours H $mins M',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${calories.round()} kcal',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  // 삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                    onPressed: () {
                      setState(() {
                        _totalCaloriesBurned -= activity.calories;
                        _caloriesBurned = _totalCaloriesBurned; // API 전송용 변수 업데이트
                        _recordedActivities.remove(activity);
                      });
                    },
                  ),
                ],
              ),
            );
          }).toList(),

          // '+' 버튼 (그림의 요구사항)
          GestureDetector(
            onTap: _showExerciseSelectionDialog,
            child: Container(
              margin: EdgeInsets.only(top: _recordedActivities.isEmpty ? 0 : 8.0), // 첫 항목이 아닐 경우만 상단 마진
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Color(0xFF5B9FED)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Total 칼로리 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${_totalCaloriesBurned.round()} kcal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B9FED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // 🔥 섭취 칼로리 슬라이더 개별 카드 위젯 (수정: 툴팁/수치 표시 옵션 추가)
  Widget _buildCalorieSliderCard({
    required String title,
    required String subTitle,
    required IconData icon,
    required double currentValue,
    required ValueChanged<double> onChanged,
    required String minLabel,
    required String midLabel,
    required String maxLabel,
    bool showTooltip = false, // 툴팁 표시 여부 (섭취 칼로리에만 사용)
  }) {
    // Max Calorine을 기준으로 정규화된 값 계산 (0.0 ~ 1.0)
    final double normalizedValue = (_maxCalorie > 0) ? (currentValue.clamp(0.0, _maxCalorie.toDouble())) / _maxCalorie : 0.0;
    final Color barColor = Color.lerp(
      const Color(0xFFB3E0FF),
      const Color(0xFF1E90FF),
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
              Icon(icon, color: const Color(0xFF1A1A1A), size: 32),
            ],
          ),
          const SizedBox(height: 20),

          // 고정 수치 레이블: 0 kcal, BMR kcal, Max kcal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0 kcal', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                Text(
                  '${_bmr.round()} kcal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${_maxCalorie.round()} kcal',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 슬라이더 및 바 영역
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
              Positioned(
                left: (_maxCalorie > 0) ? (MediaQuery.of(context).size.width - 40) * 0.5 - 20 - 2 : 0,
                child: Container(
                  width: 4,
                  height: 20,
                  color: Colors.black,
                ),
              ),

              // 슬라이더 (툴팁 추가)
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 10,
                  thumbColor: const Color(0xFF5B9FED),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  overlayColor: const Color(0x295B9FED),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                  // 🔥 툴팁 표시 설정
                  showValueIndicator: showTooltip ? ShowValueIndicator.always : ShowValueIndicator.never,
                  valueIndicatorTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                child: Slider(
                  min: 0,
                  max: _maxCalorie.toDouble(),
                  value: currentValue,
                  onChanged: onChanged,
                  // 🔥 툴팁에 표시될 텍스트
                  label: '${currentValue.round()} kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // '공복', '보통', '많이 먹음' 텍스트 레이블
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
    // ... (기존 _buildImagePicker 내용과 동일)
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

  Widget _buildPeriodButton(String period, bool isSelected) {
    // ... (기존 _buildPeriodButton 내용과 동일)
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