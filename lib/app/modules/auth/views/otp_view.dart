import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../global_widget/primary_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/boxed_code_input.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: GetBuilder<AuthController>(
            builder: (con) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OTP লিখুন',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text:
                          '${con.displayPhone} নম্বরে একটি 6-সংখ্যার কোড পাঠানো হয়েছে। ',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: const Text(
                              'নম্বর পরিবর্তন করুন',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  BoxedCodeInput(
                    length: AuthController.otpLength,
                    autoFocus: true,
                    onChanged: con.onOtpChanged,
                    onCompleted: (_) => con.verifyOtp(),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: con.canResend
                        ? GestureDetector(
                            onTap: con.resendOtp,
                            child: const Text(
                              'কোড আবার পাঠান',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Text.rich(
                            TextSpan(
                              text: 'কোড পাননি?   ',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF64748B)),
                              children: [
                                TextSpan(
                                  text: con.resendLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'অন্য পদ্ধতিতে যাচাই করুন',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'যাচাই করুন',
                    enabled: con.isOtpComplete,
                    onPressed: con.verifyOtp,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
