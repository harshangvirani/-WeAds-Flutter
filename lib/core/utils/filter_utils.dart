import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_ads/core/widgets/common_confirmation_dialog.dart';
import 'package:we_ads/features/category/presentation/CategoryFilterSheet.dart';

class FilterUtils {
  static void showCategorySheet(BuildContext context,{bool? safeArea = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>  CategoryFilterSheet(safeArea: safeArea),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    try {
      // It is often safer to just use launchUrl directly for phone calls
      // as canLaunchUrl can return false on some restricted systems
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch dialer for $phoneNumber');
      }
    } catch (e) {
      debugPrint('Error launching phone call: $e');
    }
  }

 static Future<void> launchSMS({String phoneNumber = ''}) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: null,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw Exception('Could not launch $launchUri');
    }
  }

  static void showPhoneDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => CommonConfirmationDialog(
        icon: Icons.phone_outlined,
        title: "Open Phone app?",
        description:
            "This will close the current app and launch your default dialer.",
        onContinue: () {
          FilterUtils().makePhoneCall(phoneNumber);
        },
      ),
    );
  }

  static void showMessageDialog(
    BuildContext context,
    IconData? icon,
    String? svgIcon,
    String phoneNumber,
  ) {
    showDialog(
      context: context,
      builder: (context) => CommonConfirmationDialog(
        icon: icon,
        svgIcon: svgIcon,
        title: "Open message app?",
        description:
            "This will close the current app and launch your default Messager.",
        onContinue: () {
          launchSMS(phoneNumber: phoneNumber);
        },
      ),
    );
  }

  static void showLogoutDialog(BuildContext context, Function onTap) {
    showDialog(
      context: context,
      builder: (context) => CommonConfirmationDialog(
        icon: Icons.logout_rounded,
        title: "Logout Confirmation",
        description:
            "Are you sure you want to log out? You will need to sign in again to access your account.",
        continueLabel: "Logout",
        onContinue: () {
          onTap();
        },
      ),
    );
  }

  static void showExitDialog(BuildContext context, Function onExit) {
    showDialog(
      context: context,
      builder: (context) => CommonConfirmationDialog(
        title: "Exit Confirmation",
        description: "Are you sure you want to exit the app?",
        continueLabel: "Exit",
        onContinue: () {
          onExit();
        },
      ),
    );
  }
}
