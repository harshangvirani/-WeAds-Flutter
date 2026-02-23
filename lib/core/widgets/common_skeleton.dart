import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';

enum SkeletonShape { line, box, circle }

class CommonSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final SkeletonShape shape;
  final double borderRadius;

  const CommonSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = SkeletonShape.line,
    this.borderRadius = 8.0,
  });

  // Helper for quick Line creation
  const CommonSkeleton.line({
    super.key,
    this.width,
    this.height = 12,
    this.borderRadius = 4,
  }) : shape = SkeletonShape.line;

  // Helper for quick Box creation
  const CommonSkeleton.box({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  }) : shape = SkeletonShape.box;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width?.w ?? double.infinity,
        height: height?.h ?? 20.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape == SkeletonShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: shape == SkeletonShape.circle
              ? null
              : BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// examples to use

// Row(
//   children: [
//     const CommonSkeleton(shape: SkeletonShape.circle, width: 50, height: 50),
//     SizedBox(width: 12.w),
//     Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CommonSkeleton.line(width: 150.w),
//         SizedBox(height: 8.h),
//         CommonSkeleton.line(width: 100.w),
//       ],
//     )
//   ],
// )