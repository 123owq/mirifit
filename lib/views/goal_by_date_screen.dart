import 'package:flutter/material.dart';

class GoalByDateScreen extends StatelessWidget {
  const GoalByDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 캘린더에서 전달받은 날짜 (예: 26일)
    final tappedDate = ModalRoute.of(context)?.settings.arguments as DateTime? ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '날짜별 목표',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        // 뒤로가기 버튼 색상 수정
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. 캘린더 (선택한 날짜가 하이라이트됨)
            _buildMonthCalendar(context, tappedDate),
            const SizedBox(height: 16),

            // 2. 미래 이미지
            _buildFutureImage(context),
            const SizedBox(height: 16),

            // 3. 목표 설정
            _buildGoalStats(),
          ],
        ),
      ),
    );
  }

  // --- ★★★ 이 아래 함수들을 놓치셨습니다 ★★★ ---

  Widget _buildMonthCalendar(BuildContext context, DateTime selectedDate) {
    // (calendar.dart의 _buildMonthView와 거의 동일하지만,
    // 'Today' 대신 'selectedDate'를 하이라이트합니다.)

    final DateTime now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int firstDayWeekday = DateTime(now.year, now.month, 1).weekday % 7;
    final List<String> dayLabels = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 2025.06 / Today (디자인에 맞게 추가)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${now.year}.${now.month.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 요일 레이블
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayLabels
                  .map((label) => Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)))
                  .toList(),
            ),
            const SizedBox(height: 10),

            // 날짜 그리드
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: daysInMonth + firstDayWeekday,
              itemBuilder: (context, index) {
                if (index < firstDayWeekday) {
                  return Container();
                }

                final int day = index - firstDayWeekday + 1;
                final DateTime date = DateTime(now.year, now.month, day);
                final bool isSelected = DateUtils.isSameDay(date, selectedDate);

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration( // ★ 선택된 날짜 (빨간색 동그라미)
                    color: Colors.red,
                    shape: BoxShape.circle,
                  )
                      : null,
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // GoalByDateScreen 클래스의 _buildFutureImage 함수

  Widget _buildFutureImage(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      // ★★★ 바로 GestureDetector를 Card의 child로 가져옵니다 ★★★
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/full_screen_image',
            arguments: 'assets/images/after.png',
          );
        },
        // ★★★ AspectRatio로 Image.asset을 감싸고 height 속성을 제거합니다 ★★★
        child: AspectRatio(
          // 이미지의 일반적인 비율을 지정합니다. (예: 4:3, 16:9, 1:1 등)
          // 이 이미지의 비율을 확인하시고, 만약 다른 비율이면 여기에 맞춰 수정하세요.
          // 현재 이미지처럼 세로로 조금 더 길면 3/4나 9/16 같은 비율이 적절할 수 있습니다.
          aspectRatio: 3 / 4, // 예시: 너비 3 대 높이 4 비율
          child: Image.asset(
            'assets/images/after.png',
            // height 속성을 제거하여 AspectRatio가 높이를 결정하게 합니다.
            width: double.infinity,
            fit: BoxFit.cover, // AspectRatio 공간을 꽉 채우면서 비율 유지
          ),
        ),
      ),
    );
  }

  Widget _buildGoalStats() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('몸무게', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  const Text('54 kg', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('체지방률', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  const Text('16 %', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} // <-- ★ GoalByDateScreen 클래스가 여기서 끝납니다.