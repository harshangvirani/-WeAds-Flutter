import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:we_ads/core/providers/user_provider.dart';
import 'package:we_ads/core/theme/app_colors.dart';
import 'package:we_ads/core/theme/app_text_styles.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/core/widgets/custom_app_bar.dart';
import 'package:we_ads/core/widgets/custom_button.dart';
import 'package:we_ads/core/widgets/custom_phone_field.dart';
import 'package:we_ads/core/widgets/gradient_background.dart';
import 'package:we_ads/features/auth/presentation/providers/auth_provider.dart';
import 'package:we_ads/features/home/presentation/providers/nav_provider.dart';

final otpVisibilityProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Timer State Variables
  Timer? _timer;
  int _start = 45;
  bool _canResend = false;

  // Timer Logic
  void _startTimer() {
    setState(() {
      _canResend = false;
      _start = 45;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String _currentDialCode = "+1";
  String _fullPhoneNumber = "";
  String get fullPhoneNumber => _fullPhoneNumber.isEmpty
      ? "$_currentDialCode${_phoneController.text}"
      : _fullPhoneNumber;
  String countryCode = "US";

  @override
  void initState() {
    super.initState();
    ref.read(otpVisibilityProvider.notifier).state = false;
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer on dispose
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOtpSent = ref.watch(otpVisibilityProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        showLogo: true,
        backgroundColor: AppColors.white,
      ),
      body: GradientBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      CustomPhoneField(
                        controller: _phoneController,
                        initialCountryCode: countryCode,
                        onCountryChanged: (countryCode, dialCode) {
                          setState(() {
                            _currentDialCode = "+$dialCode";
                            _fullPhoneNumber = fullPhoneNumber;
                            ref.read(otpVisibilityProvider.notifier).state =
                                false;
                            _otpController.clear();
                            _phoneController.clear();
                            this.countryCode = countryCode;
                          });
                        },
                        onValueChanged: (fullNumber) {
                          setState(() {
                            _fullPhoneNumber = fullNumber;
                          });
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return "Please enter your mobile number";
                          }
                          return null;
                        },
                      ),
                      if (isOtpSent)
                        Positioned(
                          right: 10.w,
                          child: GestureDetector(
                            onTap: () =>
                                ref.read(otpVisibilityProvider.notifier).state =
                                    false,
                            child: CircleAvatar(
                              radius: 15.r,
                              backgroundColor: AppColors.surfaceBlue,
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  if (!isOtpSent) ...[
                    CustomButton(
                      text: authState.isLoading ? "Sending OTP..." : "Send OTP",
                      isLoading: authState.isLoading,
                      isDisabled: authState.isLoading,
                      onTap: authState.isLoading
                          ? null
                          : () async {
                              if (_phoneController.text.trim().isNotEmpty) {
                                if (_formKey.currentState!.validate()) {
                                  final finalPhone = fullPhoneNumber;
                                  await ref
                                      .read(authProvider.notifier)
                                      .sendOtp(
                                        context,
                                        finalPhone,
                                        "login",
                                        null,
                                      );
                                  // Start timer if OTP is successfully sent
                                  if (ref.read(otpVisibilityProvider)) {
                                    _startTimer();
                                  }
                                }
                              } else {
                                AppToast.show(
                                  context: context,
                                  message: "Phone number cannot be empty",
                                  type: ToastType.info,
                                );
                              }
                            },
                      borderRadius: 50.w,
                    ),
                  ] else ...[
                    Text(
                      "Enter OTP",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Center(
                      child: Pinput(
                        controller: _otpController,
                        length: 6,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Enter 6-digit OTP";
                          }
                          return null;
                        },
                        defaultPinTheme: PinTheme(
                          width: 50.w,
                          height: 56.h,
                          textStyle: const TextStyle(fontSize: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderGrey),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          // Disable button if timer is running
                          onPressed: _canResend
                              ? () async {
                                  if (_phoneController.text.trim().isNotEmpty) {
                                      final finalPhone = fullPhoneNumber;
                                      await ref
                                          .read(authProvider.notifier)
                                          .sendOtp(
                                            context,
                                            finalPhone,
                                            "login",
                                            null,
                                          );
                                      _startTimer(); // Restart timer
                                  }
                                }
                              : null,
                          child: RichText(
                            text: TextSpan(
                              text: "Didn't receive OTP? ",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mediumGrey,
                              ),
                              children: [
                                // 7. Update text based on timer state
                                TextSpan(
                                  text: _canResend
                                      ? "Resend Now"
                                      : "Resend in 0:$_start Sec",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomButton(
                      text: authState.isLoading ? "Verifying..." : "Verify OTP",
                      isLoading: authState.isLoading,
                      isDisabled: authState.isLoading,
                      borderRadius: 50.r,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final finalPhone = fullPhoneNumber;
                          final success = await ref
                              .read(authProvider.notifier)
                              .verifyOtp(
                                context,
                                finalPhone,
                                _otpController.text,
                                "login",
                                countryCode,
                                _currentDialCode,
                              );
                          if (success) {
                            context.go(
                              '/home',
                              extra: {
                                'phoneNumber': _phoneController.text.trim(),
                                'countryText': countryCode,
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                  SizedBox(height: 30.h),
                  const Divider(color: AppColors.lightGrey),
                  SizedBox(height: 10.h),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),

                  CustomButton(
                    text: "Create new account",
                    backgroundColor: Colors.transparent,
                    borderColor: AppColors.borderGrey,
                    textColor: AppColors.secondary,
                    borderRadius: 50.w,
                    onTap: () => {
                      ref.read(otpVisibilityProvider.notifier).state = false,
                      context.push('/register'),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
