import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  int _selectedPeriodIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ★ 데이터 받기 (보따리 풀기)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final DateTime? tappedDate = args?['date'];
    final double weight = args?['weight'] ?? 0.0;
    final double height = args?['height'] ?? 0.0;

    // ★ BMI 계산
    String bmiString = '0.0';
    if (weight > 0 && height > 0) {
      double heightM = height / 100;
      double bmi = weight / (heightM * heightM);
      bmiString = bmi.toStringAsFixed(1);
    }

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
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(formattedDate, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          if (isToday)
            Padding(padding: const EdgeInsets.only(right: 16.0), child: Center(child: Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePlaceholders(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            // ★ 수정된 스코어 카드 (BMI)
            _buildScoreCard(weight, bmiString),
            const SizedBox(height: 16),
            _buildWeightChart(),
            const SizedBox(height: 16),
            _buildCalorieStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholders() {
    return Row(children: [
      _buildImagePlaceholder(context, 'assets/images/before.png'),
      const SizedBox(width: 12),
      _buildImagePlaceholder(context, 'assets/images/after.png'),
    ]);
  }

  Widget _buildImagePlaceholder(BuildContext context, String imagePath) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/full_screen_image', arguments: imagePath),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return ToggleButtons(
      isSelected: List.generate(4, (index) => index == _selectedPeriodIndex),
      onPressed: (int index) => setState(() => _selectedPeriodIndex = index),
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

  // ★ BMI 표시 위젯
  Widget _buildScoreCard(double weight, String bmiString) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('몸무게 / BMI', style: TextStyle(color: Colors.grey[600])),
              Icon(Icons.settings_outlined, color: Colors.grey[600]),
            ]),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              TextSpan(text: '${weight.toStringAsFixed(1)}kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: ' / BMI $bmiString', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            ])),
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
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/graph.jpeg', width: double.infinity, height: 150, fit: BoxFit.cover)),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildCalorieColumn('섭취한 칼로리', '1847', 'kcal'),
          Container(height: 40, width: 1, color: Colors.grey[300]),
          _buildCalorieColumn('소모한 칼로리', '468', 'kcal'),
        ]),
      ),
    );
  }

  Widget _buildCalorieColumn(String title, String value, String unit) {
    return Column(children: [
      Icon(Icons.restaurant, color: Colors.grey[400]),
      const SizedBox(height: 8),
      Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(unit, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    ]);
  }
}