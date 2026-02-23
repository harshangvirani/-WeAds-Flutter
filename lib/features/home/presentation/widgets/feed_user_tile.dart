import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/features/home/data/modal/feed_model.dart';

class FeedUserTile extends StatelessWidget {
  final FeedUser user;
  final Color avatarColor;
  final String initials;
  final VoidCallback onTap;

  const FeedUserTile({
    super.key,
    required this.user,
    required this.avatarColor,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24.r,
        backgroundColor: avatarColor,
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        "${user.firstName} ${user.lastName}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.backgroundDark,
        ),
      ),
      subtitle: Text(
        user.description ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.mediumGrey,
        ),
      ),
      trailing: user.unReadPostCount != null && user.unReadPostCount! > 0
          ? Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${user.unReadPostCount}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
