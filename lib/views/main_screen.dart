import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Generate 탭 클릭 시 Navigator.pushNamed 사용
          if (index == 2) {
            Navigator.pushNamed(context, '/generate');
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const Center(
          child: Text('Home 화면', style: TextStyle(fontSize: 24)),
        );
      case 1:
        return const Center(
          child: Text('Progress 화면', style: TextStyle(fontSize: 24)),
        );
      case 2:
        return const Center(
          child: Text('Generate 탭', style: TextStyle(fontSize: 24)),
        );
      case 3:
        return const Center(
          child: Text('Profile 화면', style: TextStyle(fontSize: 24)),
        );
      default:
        return const Center(
          child: Text('Home 화면'),
        );
    }
  }
}
