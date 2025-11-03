import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../widgets/overlay_frame.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    // ★ 카메라가 없는 기기(에뮬레이터 등)에서 오류가 날 수 있으므로 예외처리 추가
    if (cameras.isEmpty) {
      print("No camera found");
      return;
    }
    // ★ 후면 카메라를 우선 사용하도록 수정 (first -> last)
    final back = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first, // 후면 없으면 아무거나
    );
    _controller = CameraController(back, ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // 컨트롤러가 준비되었는지 확인
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }
    // 사진 촬영 시도
    try {
      final file = await _controller!.takePicture();
      // 사진 경로를 들고 이전 화면으로 돌아가기
      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 카메라 컨트롤러가 초기화 되었는지 다시 한번 확인
            if (_controller == null || !_controller!.value.isInitialized) {
              return const Center(child: Text("카메라를 사용할 수 없습니다."));
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                const OverlayFrame(),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '프레임에 맞춰 찍어주세요',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // 카메라 로딩 중
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}