import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'views/main_screen.dart';
import 'views/generate_screen.dart';
import 'views/result_screen.dart';  // 추가
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Goal App',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/home': (context) => const Center(child: Text('Home 화면')),
        '/progress': (context) => const Center(child: Text('Progress 화면')),
        '/generate': (context) => const GenerateScreen(),
        '/result': (context) => const ResultScreen(),  // 추가
        '/profile': (context) => const Center(child: Text('Profile 화면')),
      },
    );
  }
}
