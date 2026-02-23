import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

enum MediaType { image, video, audio }

class CustomNetworkMedia extends StatelessWidget {
  final String url;
  final MediaType type;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CustomNetworkMedia({
    super.key,
    required this.url,
    this.type = MediaType.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: _buildMediaContent(),
    );
  }

  Widget _buildMediaContent() {
    switch (type) {
      case MediaType.image:
        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          // Loading State
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder(Icons.image_outlined, isLoading: true);
          },
          // Error State
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholder(Icons.broken_image_outlined),
        );

      case MediaType.video:
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPlaceholder(Icons.movie_outlined),
            Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
          ],
        );

      case MediaType.audio:
        return Container(
          width: width ?? double.infinity,
          height: 60.h,
          color: AppColors.surfaceBlue,
          child: Row(
            children: [
              SizedBox(width: 10.w),
              const Icon(Icons.audiotrack, color: AppColors.primary),
              Expanded(child: Slider(value: 0.3, onChanged: (v) {})),
              const Icon(Icons.play_arrow, color: AppColors.primary),
              SizedBox(width: 10.w),
            ],
          ),
        );
    }
  }

  Widget _buildPlaceholder(IconData icon, {bool isLoading = false}) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 200.h,
      color: AppColors.lightGrey.withOpacity(0.2),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.mediumGrey, size: 40.sp),
                  SizedBox(height: 8.h),
                  Text(
                    "Media unavailable",
                    style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                  ),
                ],
              ),
      ),
    );
  }
}
