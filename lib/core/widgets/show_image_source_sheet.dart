import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/utils/utility.dart';

void showImageSourceSheet(
  BuildContext context,
  Function(String path) onImagePicked,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          /// Camera
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title: const Text(
              'Camera',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundDark,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              final path = await pickImage(ImageSource.camera);
              if (path != null) onImagePicked(path);
            },
          ),

          /// Gallery
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.primary),
            title: const Text(
              'Gallery',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.backgroundDark,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              final path = await pickImage(ImageSource.gallery);
              if (path != null) onImagePicked(path);
            },
          ),
        ],
      ),
    ),
  );
}
