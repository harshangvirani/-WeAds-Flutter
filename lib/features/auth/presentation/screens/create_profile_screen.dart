// NOTE: AppTextStyles import removed

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_ads/core/constants/assets_manager.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/features/auth/data/modals/profile_request.dart';
import 'package:we_ads/features/auth/presentation/providers/auth_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_phone_field.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_background.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String countryText;
  final String fullMobileNumber;

  const CreateProfileScreen({
    super.key,
    required this.phoneNumber,
    required this.countryText,
    required this.fullMobileNumber,
  });

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailIdController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _phoneController.text = widget.phoneNumber;
    super.initState();
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // fontFamily: 'Roboto',
                  color: AppColors.backgroundDark,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text(
                'Camera',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // fontFamily: 'Roboto',
                  color: AppColors.backgroundDark,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    // fontFamily: 'Roboto',
                    color: AppColors.backgroundDark,
                  ),
                ),
                onTap: () {
                  setState(() => _profileImage = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final targetPath = "${pickedFile.path}_tiny.jpg";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      targetPath,
      quality: 70,
      minWidth: 150,
      minHeight: 150,
      format: CompressFormat.jpeg,
    );

    if (compressedFile != null) {
      final file = File(compressedFile.path);
      setState(() => _profileImage = file);
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // if (_profileImage == null) {
    //   AppToast.show(
    //     context: context,
    //     message: "Please select a profile photo",
    //     type: ToastType.error,
    //   );
    //   return;
    // }

    final request = ProfileRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      description: _descController.text.trim(),
      email: _emailIdController.text.trim(),
      mobileNo: widget.fullMobileNumber.trim(),
      pincode: _zipCodeController.text.trim(),
      city:
          "Vadodara", // dummy / hardcoded for noe because need clarification from team
      filePath: _profileImage?.path,
    );

    await ref.read(authProvider.notifier).createProfile(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        appBar: const CustomAppBar(showLogo: true),
        bottomNavigationBar: Container(
          color: AppColors.white,
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: 30.h,
            top: 10.h,
          ),
          child: CustomButton(
            width: 180.w,
            text: "Save and next",
            borderRadius: 50.r,
            onTap: authState.isLoading ? null : _submitProfile,
          ),
        ),
        body: GradientBackground(
          isUpperGradient: true,
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.h),
                    topRight: Radius.circular(16.h),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Profile",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          // fontFamily: 'Roboto',
                          color: AppColors.primary,
                        ),
                      ),

                      SizedBox(height: 25.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 128.w,
                                  height: 128.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: AppColors.borderGrey,
                                    ),
                                    image: _profileImage != null
                                        ? DecorationImage(
                                            image: FileImage(_profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: -10,
                                  right: 46,
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
                                  keyboardType: TextInputType.name,
                                  controller: _firstNameController,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? "Required"
                                      : null,
                                ),
                                SizedBox(height: 20.h),
                                CustomTextField(
                                  labelText: "Last name",
                                  keyboardType: TextInputType.name,
                                  controller: _lastNameController,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? "Required"
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),

                      CustomTextField(
                        labelText: "Description (Optional)",
                        hintText: "Cooking and clothing business",
                        keyboardType: TextInputType.multiline,
                        controller: _descController,
                      ),

                      SizedBox(height: 20.h),

                      CustomTextField(
                        labelText: "Email id",
                        hintText: "Samir Shah",
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailIdController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          final emailValid = RegExp(
                            r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value);

                          return emailValid
                              ? null
                              : "Please enter a valid email";
                        },
                      ),

                      SizedBox(height: 20.h),

                      CustomTextField(
                        labelText: "Zipcode",
                        hintText: "07008",
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        suffixIcon: SvgPicture.asset(
                          AssetsManager.zipcodeIcon,
                          height: 16,
                          width: 16,
                        ),
                        controller: _zipCodeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Required";
                          if (value.length < 5) return "Invalid Zipcode";
                          return null;
                        },
                      ),

                      SizedBox(height: 20.h),

                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          CustomPhoneField(
                            initialCountryCode: widget.countryText,
                            controller: _phoneController,
                            readOnly: true,
                          ),
                        ],
                      ),

                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
