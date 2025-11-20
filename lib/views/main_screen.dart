import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/calendar.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'generate_screen.dart';
import 'dart:io';
import '../models/app_mode.dart';

class MainScreen extends StatefulWidget {
  final AppMode mode;
  const MainScreen({super.key, required this.mode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _imagePathForGenerate;

  late AppMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      // 1. FAB (플로팅 액션 버튼) 추가: 홈 화면일 때만 표시 (_currentIndex == 0)
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
              // 디자인 설정 (이미지에서 본 것처럼 크게, 파란색으로 만듭니다)
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(), // 원형
              elevation: 8, // 그림자를 더 줘서 튀어나오게 합니다.
              child: const Icon(Icons.add, size: 30),
            )
          : null, // 홈 화면이 아닐 때는 FAB을 표시하지 않습니다.
      // 2. FAB의 위치를 하단 중앙으로 설정
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
          // 스크롤이 가능하도록
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. 캘린더 (widgets 폴더에서 가져옴)
                const CalendarWidget(),
                const SizedBox(height: 20),

                // 2. 이미지 진행상황 카드
                _buildProgressCard(),
                const SizedBox(height: 20),

                // 3. 소모 칼로리 / 총 활동량 카드
                _buildStatsCard(),
                const SizedBox(height: 20), // 하단 여백
              ],
            ),
          ),
        );
      case 1:
        return const ProgressScreen();
      case 2:
        return GenerateScreen(
          mode: _currentMode,
          initialImagePath: _imagePathForGenerate,
          // ★ 4. GenerateScreen에서 이미지를 지우면 MainScreen도 잊도록 함
          onClearImage: () {
            setState(() {
              _imagePathForGenerate = null;
            });
          },
        );
      case 3:
        return ProfileScreen(
          currentMode: _currentMode,
          onModeChanged: (newMode) {
            setState(() {
              _currentMode = newMode;
            });
            print("모드가 변경되었습니다: $_currentMode");
          },
        );
      default:
        return const Center(child: Text('Home 화면'));
    }
  }

  Widget _buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // 이미지가 카드의 둥근 모서리를 따르도록
      elevation: 4,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          // 1. 배경 이미지
          Image.asset(
            'assets/images/fitness_image.jpeg', // ★ 5. [필수] 이 이미지 파일 추가해야 함
            height: 460,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // 2. 파란색 그라데이션
          Container(
            height: 460,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.blue.withOpacity(0.95), // 하단 (95% 불투명, 더 진하게)
                ],
                stops: const [0.4, 1.0], // 그라데이션이 중간(40%)부터 시작
              ),
            ),
          ),
          // 3. 텍스트
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 진행상황',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '현재 목표의 30%를 달성했어요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: const Color(0xFF252525), // 디자인의 어두운 색상
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. 소모 칼로리
            Column(
              children: [
                Text(
                  '소모칼로리',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic, // '285'와 'kcal' 높이 맞춤
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
            // 2. 구분선
            Container(height: 50, width: 1, color: Colors.grey[700]),
            // 3. 총 활동량
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
