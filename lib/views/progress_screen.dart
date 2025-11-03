import 'package:flutter/material.dart';
import '../widgets/calendar.dart'; // 1. 캘린더 위젯 가져오기

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '기록/날짜별',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 2. 캘린더를 "처음부터 펼쳐진 상태"로 사용합니다.
              const CalendarWidget(isInitiallyExpanded: true),
              const SizedBox(height: 16),

              // 3. 일일 기록 카드 리스트 (디자인 예시)
              // (나중에는 이 부분을 ListView.builder로 바꾸면 됩니다.)
              _buildRecordCard(
                context,
                date: '06.10.TUE',
                activityTime: '75',
                calories: '468',
                isGoalAchieved: true,
              ),
              _buildRecordCard(
                context,
                date: '06.09.MON',
                activityTime: '30',
                calories: '285',
                isGoalAchieved: true,
              ),
              _buildRecordCard(
                context,
                date: '06.08.SUN',
                activityTime: '40',
                calories: '308',
                isGoalAchieved: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- 위젯 분리: 일일 기록 카드 ----------
  Widget _buildRecordCard(BuildContext context,{
    required String date,
    required String activityTime,
    required String calories,
    required bool isGoalAchieved,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 카드 상단 (날짜, 목표 달성)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  isGoalAchieved ? '목표 달성 완료' : '목표 미달성',
                  style: TextStyle(
                    fontSize: 14,
                    color: isGoalAchieved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // 카드 하단 (이미지, 통계)
            Row(
              children: [
                // 4. 회색 'User Image' 플레이스홀더로 변경
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/full_screen_image',
                      arguments: 'User Image', // 이미지 대신 텍스트 전달
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // 회색 배경
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리
                    ),
                    child: Center(
                      child: Text(
                        'User Image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 통계
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow('활동량', activityTime, 'min'),
                      const SizedBox(height: 8),
                      _buildStatRow('소모칼로리', calories, 'kcal'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 기록 카드 내부의 통계 행 위젯 ---
  Widget _buildStatRow(String title, String value, String unit) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}