import 'package:flutter/material.dart';
import 'views/gallery_screen.dart';
import 'views/camera_screen.dart';

void main() {
  runApp(const PhotoApp());
}

class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/gallery',
      routes: {
        '/gallery': (context) => const GalleryScreen(),
        '/camera': (context) => const CameraScreen(),
      },
    );
  }
}
