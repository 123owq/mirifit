import 'package:flutter/material.dart';

class OverlayFrame extends StatelessWidget {
  const OverlayFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Image.asset(
            'assets/images/frame_overlay.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
