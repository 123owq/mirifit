import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'generate_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 각 탭에 해당하는 라우트 이름
  final List<String> _routes = [
    '/home',
    '/progress',
    '/generate',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          // 현재 선택된 탭의 라우트로 화면 생성
          return MaterialPageRoute(
            builder: (context) {
              switch (_currentIndex) {
                case 0:
                  return const Center(child: Text('Home 화면', style: TextStyle(fontSize: 24)));
                case 1:
                  return const Center(child: Text('Progress 화면', style: TextStyle(fontSize: 24)));
                case 2:
                  return Navigator(
                    onGenerateRoute: (settings) {
                      return MaterialPageRoute(
                        settings: settings,
                        builder: (context) => const GenerateScreen(),
                      );
                    },
                  );
                case 3:
                  return const Center(child: Text('Profile 화면', style: TextStyle(fontSize: 24)));
                default:
                  return const Center(child: Text('Home 화면'));
              }
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Navigator.pushNamed 사용
          if (index == 2) { // Generate 탭
            Navigator.pushNamed(context, '/generate');
          }
        },
      ),
    );
  }
}
