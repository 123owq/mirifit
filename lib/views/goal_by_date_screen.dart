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

  Widget _buildFutureImage(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 350, // (디자인에 맞는 적절한 높이값, 예: 350)
        width: double.infinity, // 너비 꽉 채우기
        color: Colors.grey[300], // (디자인의 회색 배경)

        child: GestureDetector( // ★ 1. 이 위젯으로 감싸기
          onTap: () {
            Navigator.pushNamed(
              context,
              '/full_screen_image',
              arguments: 'Generated Future Image', // ★ 2. 텍스트 전달
            );
          },
          child: Center( // ★ 3. 기존 센터 위젯
            child: Text(
              'Generated Future Image',
              style: TextStyle(color: Colors.grey[600]),
            ),
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