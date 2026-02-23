import 'dart:async';
import 'dart:io'; // Added for Platform check

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/widgets/curved_wave_painter.dart';

class AudioPostPlayer extends StatefulWidget {
  final String url;

  const AudioPostPlayer({super.key, required this.url});

  @override
  State<AudioPostPlayer> createState() => _AudioPostPlayerState();
}

class _AudioPostPlayerState extends State<AudioPostPlayer> {
  late AudioPlayer _audioPlayer;

  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _initAudio();

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => isPlaying = s == PlayerState.playing);
    });
  }

  Future<void> _initAudio() async {
    try {
      if (Platform.isIOS) {
        await _audioPlayer.setAudioContext(
          AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {AVAudioSessionOptions.defaultToSpeaker},
            ),
            android: const AudioContextAndroid(),
          ),
        );
      }

      Source source = widget.url.startsWith('http')
          ? UrlSource(widget.url)
          : DeviceFileSource(widget.url);

      await _audioPlayer.setSource(source);
    } catch (e) {
      debugPrint("Audio Init Error: $e");
    }
  }

  void _togglePlay() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If position is at the end or zero, play from source
        if (_position >= _duration) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint("Play/Pause Error: $e");
      // Fallback: Re-init if resume fails
      _initAudio();
    }
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.lightBlueTint,
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.mediumGrey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.mediumGrey,
                size: 28,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                CustomPaint(
                  size: Size(double.infinity, 25.h),
                  painter: CurvedWavePainter(
                    color: AppColors.mediumGrey.withOpacity(0.2),
                    percentPlayed: 1.0,
                    isStraight: true,
                    isBackground: true,
                  ),
                ),
                CustomPaint(
                  size: Size(double.infinity, 25.h),
                  painter: CurvedWavePainter(
                    color: AppColors.primary,
                    percentPlayed: progress,
                    isBackground: false,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            _formatDuration(_position),
            style: const TextStyle(
              color: AppColors.mediumGrey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
