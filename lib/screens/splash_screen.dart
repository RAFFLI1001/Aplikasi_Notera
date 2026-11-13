import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _hasNavigated = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Fallback timer: ensure app always navigates even if video fails or freezes
    _fallbackTimer = Timer(const Duration(seconds: 4), _navigateToMain);

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset('assets/videos/splash.mp4');
      _controller = controller;

      await controller.initialize();
      if (!mounted) return;

      setState(() {});
      await controller.play();

      controller.addListener(() {
        if (!mounted || _hasNavigated) return;
        final pos = controller.value.position;
        final dur = controller.value.duration;
        if (dur > Duration.zero && pos >= dur) {
          _navigateToMain();
        }
      });
    } catch (e) {
      debugPrint('Video splash error: $e');
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();
    Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isInitialized = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToMain,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: isInitialized
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                  : const CircularProgressIndicator(
                      color: Color(0xFFF6C90E),
                    ),
            ),
            PositionSafeSkipButton(onSkip: _navigateToMain),
          ],
        ),
      ),
    );
  }
}

class PositionSafeSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const PositionSafeSkipButton({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: SafeArea(
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black45,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: onSkip,
          child: const Text(
            'Lewati',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
