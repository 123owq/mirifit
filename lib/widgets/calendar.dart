import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _isExpanded = false;
  final DateTime _now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final String currentYearMonth = '${_now.year}.${_now.month.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isExpanded ? currentYearMonth : '미리핏',
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
              if (_isExpanded)
                _buildMonthView() // 확장됐으면 월(Month) 뷰
              else
                _buildWeekView(), // 축소됐으면 주(Week) 뷰
            ],
          ),
        ),
      ),
    );
  }

  // --- 현재 날짜 기준의 주(Week) 뷰 ---
  Widget _buildWeekView() {
    final DateTime startOfWeek = _now.subtract(Duration(days: _now.weekday % 7));
    final List<String> dayLabels = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final DateTime date = startOfWeek.add(Duration(days: index));
        final bool isToday = date.day == _now.day && date.month == _now.month;

        return _buildDayCell(dayLabels[index], date.day.toString(), isToday);
      }),
    );
  }

  // --- 현재 날짜 기준의 월(Month) 뷰 [스타일 수정됨] ---
  Widget _buildMonthView() {
    final int daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    final int firstDayWeekday = DateTime(_now.year, _now.month, 1).weekday % 7;
    final List<String> dayLabels = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];

    return Column(
      children: [
        // 요일 레이블 (SUN, MON...)
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
            crossAxisCount: 7, // 7열
          ),
          itemCount: daysInMonth + firstDayWeekday,
          itemBuilder: (context, index) {
            if (index < firstDayWeekday) {
              return Container(); // 1일 시작 전의 빈 칸들
            }

            final int day = index - firstDayWeekday + 1;
            final bool isToday = day == _now.day; // "오늘"인지 확인

            // ★★★ 스타일 수정된 부분 ★★★
            // '오늘' 날짜(isToday)일 때 주(Week) 뷰와 동일한 스타일 적용
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: isToday
                  ? BoxDecoration( // "오늘" 날짜 배경
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              )
                  : null,
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.black, // "오늘"이면 흰색, 아니면 검은색
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16, // 주(Week) 뷰와 동일한 폰트 크기
                ),
              ),
            );
            // ★★★ 여기까지 수정됨 ★★★
          },
        ),
      ],
    );
  }

  // --- 날짜 셀 하나를 그리는 공통 함수 (주(Week) 뷰 전용) ---
  Widget _buildDayCell(String dayOfWeek, String date, bool isSelected) {
    return Column(
      children: [
        Text(
          dayOfWeek,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: isSelected
              ? BoxDecoration( // "오늘" 날짜 배경
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          )
              : null,
          child: Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}