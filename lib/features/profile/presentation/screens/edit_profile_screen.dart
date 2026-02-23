import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/network/local_storage_service.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/features/home/presentation/providers/profile_provide.dart';
import 'package:we_ads/features/posts/presentation/providers/my_posts_provider.dart';
import 'package:we_ads/features/profile/presentation/providers/user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_phone_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedDialCode = "+1";
  String _selectedCountryIso = "US";
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(userProvider);
    final countryData = await LocalStorageService.getCountryData();

    if (user != null) {
      setState(() {
        _selectedCountryIso = countryData['iso'] ?? "IN";
        _selectedDialCode = countryData['dialCode'] ?? "+91";

        _firstNameController.text = user.firstName ?? "";
        _lastNameController.text = user.lastName ?? "";
        _descController.text = user.description ?? "";
        _emailIdController.text = user.email ?? "";
        _zipCodeController.text = user.pincode ?? "";

        String fullPhone = user.mobileNo ?? "";
        if (fullPhone.startsWith(_selectedDialCode)) {
          _phoneController.text = fullPhone.substring(_selectedDialCode.length);
        } else {
          _phoneController.text = fullPhone;
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailIdController.dispose();
    _descController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(userProvider);
    if (user == null) return;

    // Combine the selected dial code with the local number
    final String fullMobile =
        "$_selectedDialCode${_phoneController.text.trim()}";

    await ref
        .read(updateProfileProvider.notifier)
        .updateProfile(
          userId: user.userId!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          description: _descController.text.trim(),
          email: _emailIdController.text.trim(),
          mobileNo: fullMobile, // Send the fully qualified number
          pincode: _zipCodeController.text.trim(),
          city: user.city ?? "Vadodara",
          imagePath: _profileImage?.path,
          deleteProfilePhotoOld: _profileImage != null
              ? user.profilePhoto?.mediaId
              : null,
        );
    final updateState = ref.read(updateProfileProvider);

    if (updateState.isSuccess) {
      AppToast.show(
        context: context,
        message: "Profile updated successfully",
        type: ToastType.success,
      );

      ref.invalidate(userProfileDataProvider);
      ref.invalidate(myPostsProvider);
      ref.invalidate(userProfileDataProvider);

      await Future.wait([
        ref.read(myPostsProvider.future),
        ref.read(userProfileDataProvider.future),
      ]);

      if (mounted) context.pop();
    } else if (updateState.error != null) {
      AppToast.show(
        context: context,
        message: updateState.error!,
        type: ToastType.error,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final targetPath = "${pickedFile.path}_edit_compressed.jpg";

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      targetPath,
      quality: 70,
      minWidth: 200,
      minHeight: 200,
    );

    if (compressedFile != null) {
      setState(() => _profileImage = File(compressedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final updateState = ref.watch(updateProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        backgroundColor: Colors.white,
        showBackButton: true,
        title: "Edit Profile",
        titleColor: AppColors.backgroundDark,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE + NAME
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _showPickerOptions,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 128.w,
                              height: 128.h,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color: AppColors.borderGrey),
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : (user?.profilePhoto?.fileUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                user!.profilePhoto!.fileUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                              ),
                              child:
                                  (_profileImage == null &&
                                      user?.profilePhoto == null)
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: -10,
                              right: 46.w,
                              child: CircleAvatar(
                                radius: 18.r,
                                backgroundColor: AppColors.surfaceBlue,
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 15.w),

                      Expanded(
                        child: Column(
                          children: [
                            CustomTextField(
                              labelText: "First name",
                              controller: _firstNameController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Required" : null,
                            ),
                            SizedBox(height: 20.h),
                            CustomTextField(
                              labelText: "Last name",
                              controller: _lastNameController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "Required" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  /// DESCRIPTION
                  CustomTextField(
                    labelText: "Description (Optional)",
                    hintText: "Cooking and clothing business",
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                  ),

                  SizedBox(height: 20.h),

                  /// EMAIL
                  CustomTextField(
                    labelText: "Email id",
                    controller: _emailIdController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Email is required" : null,
                  ),

                  SizedBox(height: 20.h),

                  /// ZIPCODE
                  CustomTextField(
                    labelText: "Zipcode",
                    hintText: "07008",
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SvgPicture.asset(AssetsManager.zipcodeIcon),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Required" : null,
                  ),

                  SizedBox(height: 20.h),

                  /// PHONE
                  Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context).textTheme.copyWith(
                        bodyLarge: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    child: CustomPhoneField(
                      key: ValueKey(_selectedCountryIso),
                      initialCountryCode: _selectedCountryIso,
                      controller: _phoneController,
                      readOnly: true,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  /// SAVE BUTTON
                  CustomButton(
                    text: "Save changes",
                    borderRadius: 50.r,
                    onTap: updateState.isLoading ? null : _handleUpdate,
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          if (updateState.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
