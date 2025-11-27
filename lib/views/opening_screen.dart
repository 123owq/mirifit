import 'package:flutter/material.dart';
import 'package:mirifit/models/fitness_data.dart';
import 'package:mirifit/views/main_screen.dart';
// import 'package:mirifit/models/app_mode.dart'; 

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  // 입력 컨트롤러
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  // 성별 기본값
  String _selectedGender = '남성';

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // [다음] 버튼 눌렀을 때 실행
  void _startApp() {
    // 1. 입력값 가져오기 (비어있으면 0)
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double currentWeight = double.tryParse(_weightController.text) ?? 0;
    final int age = int.tryParse(_ageController.text) ?? 0;

    // 2. 데이터 모델 생성 (나중에 사용할 수 있음)
    final fitnessData = FitnessData(
      height: height,
      currentWeight: currentWeight,
      age: age,
      gender: _selectedGender,
    );

    // 3. 메인 화면으로 이동 (모드 전달 X)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          fitnessData: fitnessData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 화면 빈 곳 터치 시 키보드 내리기
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // 1. 상단 헤더
                Center(child: _buildHeader()),
                
                const SizedBox(height: 40),

                // 2. 입력 폼들
                _buildInputLabel("키"),
                _buildTextField(controller: _heightController, hint: "키(cm)를 입력하세요"),
                const SizedBox(height: 24),

                _buildInputLabel("체중"),
                _buildTextField(controller: _weightController, hint: "체중(kg)을 입력하세요"),
                const SizedBox(height: 24),

                _buildInputLabel("나이"),
                _buildTextField(controller: _ageController, hint: "나이를 입력하세요"),
                const SizedBox(height: 24),

                // 3. 성별 선택 버튼
                _buildInputLabel("성별"),
                Row(
                  children: [
                    Expanded(
                      child: _buildSelectButton(
                        text: "남성",
                        isSelected: _selectedGender == '남성',
                        onTap: () => setState(() => _selectedGender = '남성'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSelectButton(
                        text: "여성",
                        isSelected: _selectedGender == '여성',
                        onTap: () => setState(() => _selectedGender = '여성'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 4. [다음] 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF), // 파란색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "시작하기",
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI 구성 요소 (위젯) ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: const Icon(Icons.directions_run, size: 40, color: Colors.black),
        ),
        const SizedBox(height: 20),
        const Text("미리핏을 시작하기 전에", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("사용자의 정보를 입력해주세요.", style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSelectButton({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E90FF) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}