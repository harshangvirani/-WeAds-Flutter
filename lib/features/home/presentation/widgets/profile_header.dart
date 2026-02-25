import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:we_ads/features/auth/data/modals/user_model.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final UserData? user;

  const ProfileHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 360.h,
            child: _buildProfileImage(),
          ),

          /// Glass Card
          Positioned(
            bottom: 20.h,
            left: 16.w,
            right: 16.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 180.h,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// NAME
                      Text(
                        '${user?.firstName ?? ""} ${user?.lastName ?? ""}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDark,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      /// DESCRIPTION
                      Flexible(
                        child: Text(
                          user!.description ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.backgroundDark,
                            overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      /// PHONE + EMAIL
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: AppColors.backgroundDark,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            user?.mobileNo ?? "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          const Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: AppColors.backgroundDark,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              user?.email ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.backgroundDark,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      /// LOCATION
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.backgroundDark,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            user?.city ?? "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// EDIT BUTTON
          Positioned(
            top: 84.h,
            right: 30.w,
            child: GestureDetector(
              onTap: () => context.push("/edit-profile"),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final url = user?.profilePhoto?.fileUrl;

    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.surfaceBlue,
        child: const Icon(Icons.person, size: 80, color: AppColors.primary),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceBlue,
        child: const Icon(Icons.person, size: 80, color: AppColors.primary),
      ),
    );
  }
}
