import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  int _selectedPeriodIndex = 0; // "1달 후", "3달 후" 선택용

  @override
  Widget build(BuildContext context) {
    // 1. 캘린더에서 전달받은 날짜
    final tappedDate = ModalRoute.of(context)?.settings.arguments as DateTime?;

    // 2. 날짜 포맷팅 (예: 06.10.TUE)
    final String formattedDate = tappedDate != null
        ? DateFormat('MM.dd.E', 'ko_KR').format(tappedDate)
        : '기록/상세';

    final bool isToday = tappedDate != null && DateUtils.isSameDay(tappedDate, DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        centerTitle: false,
        // 뒤로가기 버튼 색상 수정
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          formattedDate,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (isToday)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. User Image / Generated Image
            _buildImagePlaceholders(),
            const SizedBox(height: 16),

            // 2. "1달 후, 3달 후..." 토글 버튼
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // 3. 몸무게/인바디 점수
            _buildScoreCard(),
            const SizedBox(height: 16),

            // 4. 몸무게 추이 (그래프)
            _buildWeightChart(),
            const SizedBox(height: 16),

            // 5. 오늘의 운동 (상체, 달리기)
            _buildWorkoutCard(
              title: '상체',
              details: '45 분 • 완료',
              icon: Icons.fitness_center,
            ),
            const SizedBox(height: 12),
            _buildWorkoutCard(
              title: '달리기',
              details: '30 분 • 완료',
              icon: Icons.directions_run,
            ),
            const SizedBox(height: 16),

            // 6. 섭취/소모 칼로리
            _buildCalorieStats(),
          ],
        ),
      ),
    );
  }

  // --- ★★★ 이 아래 함수들을 놓치셨습니다 ★★★ ---

  Widget _buildImagePlaceholders() {
    return Row(
      children: [
        _buildImagePlaceholder(context,'User Image'),
        const SizedBox(width: 12),
        _buildImagePlaceholder(context,'Generated Image'),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context, String text) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GestureDetector( // ★ 1. 이 위젯으로 감싸기
          onTap: () {
            Navigator.pushNamed(
              context,
              '/full_screen_image',
              arguments: text, // ★ 2. "User Image" 같은 텍스트 전달
            );
          },
          child: Container( // ★ 3. 기존 컨테이너
            decoration: BoxDecoration(
              // ...
            ),
            child: Center(child: Text(text, style: TextStyle(color: Colors.grey[600]))),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    // ToggleButtons로 간단하게 구현
    return ToggleButtons(
      isSelected: List.generate(4, (index) => index == _selectedPeriodIndex),
      onPressed: (int index) {
        setState(() {
          _selectedPeriodIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: Colors.blueAccent,
      color: Colors.blueAccent,
      borderColor: Colors.blueAccent,
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('1달 후')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('3달 후')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('9달 후')),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('12달 후')),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('몸무게/인바디 점수', style: TextStyle(color: Colors.grey[600])),
                Icon(Icons.settings_outlined, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '56kg',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: ' / 71 points',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text('골격근량 18.6kg • 체지방 17.5kg', style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('몸무게 추이', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            // (임시) 그래프 영역
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[200],
              child: Center(child: Text('Line Chart Placeholder', style: TextStyle(color: Colors.grey[600]))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard({required String title, required String details, required IconData icon}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 운동', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Icon(icon, color: Colors.grey[800]),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            Text(details, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieStats() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCalorieColumn('섭취한 칼로리', '1847', 'kcal'),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _buildCalorieColumn('소모한 칼로리', '468', 'kcal'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieColumn(String title, String value, String unit) {
    return Column(
      children: [
        Icon(Icons.restaurant, color: Colors.grey[400]), // (임시 아이콘)
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
} // <-- ★ _RecordDetailScreenState 클래스가 여기서 끝납니다.