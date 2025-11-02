import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final bool isInitiallyExpanded;

  const CalendarWidget({
    super.key,
    this.isInitiallyExpanded = false,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late bool _isExpanded;
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  // ★ 1. 날짜 클릭 시 호출될 함수
  void _onDateTapped(DateTime tappedDate) {
    // 날짜만 비교하기 위해 시간, 분, 초를 0으로 맞춥니다.
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime tapped = DateUtils.dateOnly(tappedDate);

    if (tapped.isBefore(today) || tapped.isAtSameMomentAs(today)) {
      // 오늘 또는 과거 -> '기록/상세' 페이지로 이동
      Navigator.pushNamed(
        context,
        '/record_detail',
        arguments: tappedDate, // 탭한 날짜를 전달
      );
    } else {
      // 미래 -> '날짜별 목표' 페이지로 이동
      Navigator.pushNamed(
        context,
        '/goal_by_date',
        arguments: tappedDate, // 탭한 날짜를 전달
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentYearMonth =
        '${_now.year}.${_now.month.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        // 캘린더 카드 자체를 탭하면 확장/축소
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

  // --- 현재 날짜 기준의 주(Week) 뷰 [클릭 가능하게 수정] ---
  Widget _buildWeekView() {
    final DateTime startOfWeek = _now.subtract(Duration(days: _now.weekday % 7));
    final List<String> dayLabels = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final DateTime date = startOfWeek.add(Duration(days: index));
        final bool isToday = DateUtils.isSameDay(date, _now);

        // ★ 2. _buildDayCell을 GestureDetector로 감싸서 클릭 가능하게 만듦
        return GestureDetector(
          onTap: () => _onDateTapped(date), // 탭하면 _onDateTapped 함수 호출
          child: _buildDayCell(dayLabels[index], date.day.toString(), isToday),
        );
      }),
    );
  }

  // --- 현재 날짜 기준의 월(Month) 뷰 [클릭 가능하게 수정] ---
  Widget _buildMonthView() {
    final int daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    final int firstDayWeekday = DateTime(_now.year, _now.month, 1).weekday % 7;
    final List<String> dayLabels = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels
              .map((label) => Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)))
              .toList(),
        ),
        const SizedBox(height: 10),

        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: daysInMonth + firstDayWeekday,
          itemBuilder: (context, index) {
            if (index < firstDayWeekday) {
              return Container(); // 1일 전의 빈 칸
            }

            final int day = index - firstDayWeekday + 1;
            final DateTime date = DateTime(_now.year, _now.month, day);
            final bool isToday = DateUtils.isSameDay(date, _now);

            // ★ 3. 날짜 셀 Container를 GestureDetector로 감싸기
            return GestureDetector(
              onTap: () => _onDateTapped(date), // 탭하면 _onDateTapped 함수 호출
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: isToday
                    ? BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
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
              ? BoxDecoration(
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