import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:we_ads/core/utils/app_toast.dart';
import 'package:we_ads/features/auth/presentation/providers/auth_provider.dart';
import 'package:we_ads/features/auth/presentation/screens/login_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_phone_field.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/constants/assets_manager.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _start = 45;
  bool _canResend = false;

  void _startTimer() {
    _canResend = false;
    _start = 45;
    _timer?.cancel(); // Cancel any existing timer
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
    _timer?.cancel(); // cancel timer to avoid memory leaks
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOtpSent = ref.watch(otpVisibilityProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                /// Logo + Title
                Row(
                  children: [
                    Image.asset(AssetsManager.appLogo, width: 40.w),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WeAds",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            // fontFamily: 'Roboto',
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          "United we soar",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            // fontFamily: 'Roboto',
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 40.h),

                /// Title
                Text(
                  "Create new account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    // fontFamily: 'Roboto',
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 24.h),

                /// Phone Field
                CustomPhoneField(
                  controller: _phoneController,
                  initialCountryCode: countryCode,
                  onCountryChanged: (countryCode, dialCode) {
                    setState(() {
                      _currentDialCode = "+$dialCode";
                      _fullPhoneNumber = fullPhoneNumber;
                      ref.read(otpVisibilityProvider.notifier).state = false;
                      _otpController.clear();
                      _phoneController.clear();
                      this.countryCode = countryCode;
                    });
                  },
                  onValueChanged: (fullNumber) {
                    setState(() => _fullPhoneNumber = fullNumber);
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return "Please enter your mobile number";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                /// SEND OTP
                if (!isOtpSent) ...[
                  CustomButton(
                    text: authState.isLoading ? "Sending..." : "Send OTP",
                    isLoading: authState.isLoading,
                    isDisabled: authState.isLoading,
                    backgroundColor: authState.isLoading
                        ? AppColors.lightGrey
                        : AppColors.primary,
                    onTap: () async {
                      if (_phoneController.text.trim().isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          await ref
                              .read(authProvider.notifier)
                              .sendOtp(
                                context,
                                fullPhoneNumber,
                                "register",
                                null,
                              );
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
                ]
                /// OTP UI
                else ...[
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Roboto',
                      color: AppColors.darkGrey,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Pinput(
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
                      textStyle: TextStyle(
                        fontSize: 20,
                        // fontFamily: 'Roboto',
                        color: AppColors.backgroundDark,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _canResend
                            ? () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .sendOtp(
                                      context,
                                      fullPhoneNumber,
                                      "register",
                                      null,
                                    );
                                _startTimer(); // Restart timer after resending
                              }
                            : null,
                        child: RichText(
                          text: TextSpan(
                            text: "Didn't receive OTP ? ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              // fontFamily: 'Roboto',
                              color: AppColors.mediumGrey,
                            ),
                            children: [
                              TextSpan(
                                text: _canResend
                                    ? "Resend Now"
                                    : "Resend in 0:$_start Sec",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  // fontFamily: 'Roboto',
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
                        final success = await ref
                            .read(authProvider.notifier)
                            .verifyOtp(
                              context,
                              fullPhoneNumber,
                              _otpController.text,
                              "register",
                              countryCode,
                              _currentDialCode,
                            );

                        if (success) {
                          context.go(
                            '/create-profile',
                            extra: {
                              'phoneNumber': _phoneController.text.trim(),
                              'countryText': countryCode,
                              'fullMobileNumber': fullPhoneNumber,
                            },
                          );
                        }
                      }
                    },
                  ),
                ],

                SizedBox(height: 30.h),

                Divider(color: AppColors.lightGrey),

                SizedBox(height: 10.h),

                /// Already account
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      // fontFamily: 'Roboto',
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),

                CustomButton(
                  text: "Log In",
                  backgroundColor: Colors.transparent,
                  borderColor: AppColors.borderGrey,
                  textColor: AppColors.secondary,
                  borderRadius: 50.w,
                  onTap: () {
                    ref.read(otpVisibilityProvider.notifier).state = false;
                    context.go('/login');
                  },
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
