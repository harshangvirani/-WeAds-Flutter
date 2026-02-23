import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
  }) {
    final FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: _getBgColor(type),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(type), color: Colors.white, size: 20),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP, // Common for modern apps
      toastDuration: const Duration(seconds: 3),
    );
  }

  static Color _getBgColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF2ECC71); // Success Green
      case ToastType.error:
        return const Color(0xFFE74C3C); // Error Red
      case ToastType.info:
        return AppColors.primary;
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}
