import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../constants/assets_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      toolbarHeight: 80.h,
      leadingWidth: showLogo ? 160.w : 56.w,
      leading: _buildLeading(context),

      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: titleColor ?? AppColors.primary,
              ),
            )
          : null,

      actions: actions != null
          ? [
              Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Row(children: actions!),
              ),
            ]
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showLogo) {
      return Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Row(
          children: [
            Image.asset(AssetsManager.appLogo, width: 40.w, height: 40.h),
            SizedBox(width: 8.w),
            Image.asset(AssetsManager.nameLogo, width: 70.w),
          ],
        ),
      );
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: titleColor ?? AppColors.primary,
        ),
        onPressed: () => context.pop(),
      );
    }

    return leading;
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
