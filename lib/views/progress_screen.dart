import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar.dart';
import 'package:mirifit/models/fitness_data.dart'; // ★ 1. 여기 Import 추가!

class ProgressScreen extends StatelessWidget {
  // ★ 2. 데이터를 받을 변수 추가
  final FitnessData fitnessData;

  // ★ 2. 생성자에서 데이터를 받도록 수정 (required this.fitnessData 추가)
  const ProgressScreen({super.key, required this.fitnessData});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    final List<Map<String, dynamic>> dummyData = [
      {'activity': '75', 'calories': '468', 'achieved': true},
      {'activity': '30', 'calories': '285', 'achieved': true},
      {'activity': '40', 'calories': '308', 'achieved': false},
    ];

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
              // ★ 3. 캘린더에 데이터 전달! (const 지우고 fitnessData 넣기)
              CalendarWidget(
                isInitiallyExpanded: true,
                fitnessData: fitnessData, // 👈 여기서 데이터를 넘겨줌!
              ),
              const SizedBox(height: 16),

              ...List.generate(3, (index) {
                final DateTime date = today.subtract(Duration(days: index));
                final String formattedDate = DateFormat('MM.dd.E', 'ko_KR').format(date);

                return _buildRecordCard(
                  context,
                  date: formattedDate,
                  activityTime: dummyData[index]['activity']!,
                  calories: dummyData[index]['calories']!,
                  isGoalAchieved: dummyData[index]['achieved']!,
                );
              }),
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
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/full_screen_image',
                      arguments: 'assets/images/before.png',
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/before.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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