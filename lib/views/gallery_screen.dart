import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Android 실제 갤러리용
  List<AssetEntity> _images = [];
  AssetPathEntity? _album;
  int _currentPage = 0;
  final int _pageSize = 50;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Web/시연용 demo 이미지
  final List<String> demoImages = const [
    'assets/demo_images/1.jpg',
    'assets/demo_images/2.jpg',
    'assets/demo_images/4.jpg',
    'assets/demo_images/5.jpg',
    'assets/demo_images/6.jpg',
    'assets/demo_images/before.png'
  ];

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _requestPermissionAndLoad();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!kIsWeb &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      _loadMoreImages();
    }
  }

  Future<void> _requestPermissionAndLoad() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isNotEmpty) {
        _album = albums[0];
        await _loadMoreImages();
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> _loadMoreImages() async {
    if (_album == null) return;
    setState(() => _isLoading = true);

    final List<AssetEntity> newPhotos =
    await _album!.getAssetListPaged(page: _currentPage, size: _pageSize);

    setState(() {
      _images.addAll(newPhotos);
      _currentPage++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = kIsWeb ? demoImages.length + 1 : _images.length + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
          // ★ 첫 칸 카메라 버튼 수정 ★
          // ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
          if (index == 0) {
            return GestureDetector(
              onTap: () async {
                final imagePath = await Navigator.pushNamed(context, '/camera');
                if (imagePath != null && imagePath is String) {
                  if (mounted) {
                    Navigator.pop(context, {
                      'destination': 'generate',
                      'path': imagePath, // 카메라에서 찍은 'File' 경로
                    });
                  }
                }
              },
              child: Container(
                color: Colors.grey[300],
                child: const Icon(Icons.camera_alt, size: 36),
              ),
            );
          }

          // Web demo 이미지
          if (kIsWeb) {
            final String assetPath = demoImages[index - 1]; // 예: 'assets/demo_images/1.jpg'

            return GestureDetector(
              onTap: () {
                // ★ 갤러리 이미지를 탭하면, MainScreen으로 '명령'을 보냄
                Navigator.pop(context, {
                  'destination': 'generate',
                  'path': assetPath, // 'assets/'로 시작하는 'Asset' 경로
                });
              },
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
              ),
            );
          }
          final assetEntity = _images[index - 1];
          // Android 실제 갤러리 이미지
          return FutureBuilder<File?>(
            future: assetEntity.file,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {

                return GestureDetector(
                  onTap: () {
                    // ★ 실제 갤러리 이미지를 탭해도 '명령'을 보냄
                    Navigator.pop(context, {
                      'destination': 'generate',
                      'path': snapshot.data!.path, // 'File' 경로
                    });
                  },
                  child: Image.file(snapshot.data!, fit: BoxFit.cover),
                );
              }
              return Container(color: Colors.grey[200]);
            },
          );
        },
      ),
    );
  }
}