import 'package:flutter/material.dart';
import 'package:mirifit/models/fitness_data.dart';
import 'main_screen.dart';
import '../models/app_mode.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // 상태 변수들
  int _currentPage = 0; // 0: 첫번째 페이지, 1: 두번째 페이지
  String _selectedGender = '남성'; // 기본값
  AppMode _selectedMode = AppMode.precise; // 기본값

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // 다음 페이지로 이동
  void _nextPage() {
    // TODO: 입력값 검증 추가
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 앱 시작하기 (홈 화면으로 이동)
  void _startApp() {
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double currentWeight = double.tryParse(_weightController.text) ?? 0;
    final int age = int.tryParse(_ageController.text) ?? 0;

    final fitnessData = FitnessData(
      height: height,
      currentWeight: currentWeight,
      age: age,
      gender: _selectedGender,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          mode: _selectedMode,
          fitnessData: fitnessData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 키보드 올라왔을 때 화면 밀림 방지 및 여백 터치 시 키보드 닫기
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // 1. 상단 공통 헤더 (아이콘 + 타이틀)
              _buildHeader(),

              const SizedBox(height: 30),

              // 2. 메인 컨텐츠 (PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildStep1Form(), // 1페이지: 키/체중/나이
                    _buildStep2Form(), // 2페이지: 성별/모드
                  ],
                ),
              ),

              // 3. 하단 인디케이터 (점 두개)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(isActive: _currentPage == 0),
                  const SizedBox(width: 8),
                  _buildIndicator(isActive: _currentPage == 1),
                ],
              ),

              const SizedBox(height: 20),

              // 4. 하단 버튼 (다음 or 시작하기)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _currentPage == 0 ? _nextPage : _startApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF), // 파란색 (이미지 참조)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 0 ? "다음" : "미리핏 시작하기",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 위젯 조각들 (Components) ---

  // 상단 헤더
  Widget _buildHeader() {
    return Column(
      children: [
        // 로고 아이콘 (원형)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: const Icon(
            Icons.directions_run,
            size: 40,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "미리핏을 시작하기 전에",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "사용자의 정보를 입력해주세요.",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // 페이지 1: 키/체중/나이 입력
  Widget _buildStep1Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel("키"),
          _buildTextField(controller: _heightController, hint: "키(cm)를 입력하세요"),
          const SizedBox(height: 24),
          _buildInputLabel("체중"),
          _buildTextField(controller: _weightController, hint: "체중(kg)을 입력하세요"),
          const SizedBox(height: 24),
          _buildInputLabel("나이"),
          _buildTextField(controller: _ageController, hint: "나이를 입력하세요"),
        ],
      ),
    );
  }

  // 페이지 2: 성별/모드 선택
  Widget _buildStep2Form() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildInputLabel("미리핏을 통하여"),
          Row(
            children: [
              Expanded(
                child: _buildSelectButton(
                  text: "정밀하게 시작할래요",
                  isSelected: _selectedMode == AppMode.precise,
                  onTap: () => setState(() => _selectedMode = AppMode.precise),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectButton(
                  text: "간편하게 시작할래요",
                  isSelected: _selectedMode == AppMode.simple,
                  onTap: () => setState(() => _selectedMode = AppMode.simple),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
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

  Widget _buildSelectButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    double fontSize = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E90FF)
              : const Color(0xFFF5F5F5), // 선택됨: 파랑, 안됨: 연회색
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.grey.shade600 : Colors.grey.shade300,
        border: isActive ? Border.all(color: Colors.grey.shade600) : null,
      ),
    );
  }
}
