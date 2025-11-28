import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirifit/models/fitness_data.dart';
import 'package:mirifit/services/api_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/calendar.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'generate_screen.dart';
import 'dart:io';
import '../models/app_mode.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class MainScreen extends StatefulWidget {
  final FitnessData fitnessData;
  const MainScreen({super.key, required this.fitnessData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _imagePathForGenerate;
  late AppMode _currentMode;

  final TextEditingController _targetWeightController = TextEditingController();
  String? _generatedImagePath;
  int? _daysToGoal;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // @override
  // void initState() {
  //   super.initState();
  //   _currentMode = widget.mode;
  // }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_targetWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표 체중을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetWeight = double.parse(_targetWeightController.text);

      final byteData = await rootBundle.load('assets/images/fitness_image.jpeg');
      final buffer = byteData.buffer;
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/temp_fitness_image.jpeg';
      final imageFile = await File(tempPath).writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      final response = await _apiService.getFutureImage(
        targetWeight: targetWeight,
        imageFile: imageFile,
        sex: widget.fitnessData.gender == '남성' ? 'male' : 'female',
        height: widget.fitnessData.height,
        currentWeight: widget.fitnessData.currentWeight,
        age: widget.fitnessData.age,
      );

      final String base64Image = response['image'];
      final int daysToGoal = response['days_to_goal'];
      final Uint8List decodedBytes = base64Decode(base64Image);
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/generated_image.jpeg';
      final file = File(imagePath);
      await file.writeAsBytes(decodedBytes);

      setState(() {
        _generatedImagePath = imagePath;
        _daysToGoal = daysToGoal;
        widget.fitnessData.daysToGoal = daysToGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, '/gallery');
                if (result != null &&
                    result is Map &&
                    result['destination'] == 'generate') {
                  setState(() {
                    _currentIndex = 2;
                    _imagePathForGenerate = result['path'] as String?;
                  });
                }
              },
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 8,
              child: const Icon(Icons.add, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CalendarWidget(
                  fitnessData: widget.fitnessData,
                ),
                const SizedBox(height: 20),
                _buildProgressCard(),
                const SizedBox(height: 20),
                _buildStatsCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      case 1:
        return ProgressScreen(fitnessData: widget.fitnessData);
      case 2:
        return GenerateScreen(
          //mode: _currentMode,
          fitnessData: widget.fitnessData,
          initialImagePath: _imagePathForGenerate,
          onClearImage: () {
            setState(() {
              _imagePathForGenerate = null;
            });
          },
        );
      case 3:
        return ProfileScreen();
      default:
        return const Center(child: Text('Home 화면'));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _targetWeightController,
                    hint: '목표 체중(kg)을 입력하세요',
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _handleConfirm,
                  child: const Text('확인'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_generatedImagePath != null && _daysToGoal != null)
              Column(
                children: [
                  Image.file(
                    File(_generatedImagePath!),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '목표 체중까지 약 $_daysToGoal일 소요됩니다.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Image.asset(
                'assets/images/fitness_image.jpeg',
                height: 460,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: const Color(0xFF252525),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  '소모칼로리',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '285',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'kcal',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            Container(height: 50, width: 1, color: Colors.grey[700]),
            Column(
              children: [
                Text(
                  '총활동량',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '30',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '분',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
