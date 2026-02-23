// lib/core/widgets/video_post_player.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';

class VideoPostPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoPostPlayer({super.key, required this.videoUrl});

  @override
  State<VideoPostPlayer> createState() => _VideoPostPlayerState();
}

class _VideoPostPlayerState extends State<VideoPostPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Ensure we don't try to initialize an empty or null URL
    if (widget.videoUrl.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      // Adding a small timeout or error handling to the native channel call
      await _controller.initialize().timeout(const Duration(seconds: 10));

      await _controller.seekTo(const Duration(milliseconds: 1));

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Video Player Error: $e");
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePlayPause() {
    if (!_isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      color: Colors.black, // Dark background while loading
      child: GestureDetector(
        onTap: _handlePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // VIDEO RENDERER
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else if (_hasError)
              const Icon(Icons.error, color: Colors.white)
            else
              const CircularProgressIndicator(color: AppColors.primary),

            // PLAY BUTTON OVERLAY (Visible when paused)
            if (_isInitialized && !_controller.value.isPlaying)
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50.sp,
                ),
              ),

            // LOADING OVERLAY (If user clicks play but it's buffering)
            if (_isInitialized && _controller.value.isBuffering)
              const CircularProgressIndicator(color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
