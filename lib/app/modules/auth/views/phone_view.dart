import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../global_widget/primary_button.dart';
import '../controllers/auth_controller.dart';

class PhoneView extends GetView<AuthController> {
  const PhoneView({super.key});

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
                    'আপনার ফোন নম্বর দিন',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'আমরা একটি OTP পাঠাব যাচাইয়ের জন্য।',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'মোবাইল নম্বর',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PhoneInput(con: con),
                  const SizedBox(height: 8),
                  const Text(
                    'শুধুমাত্র বাংলাদেশী নম্বর সমর্থিত।',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'লগইন করুন',
                    enabled: con.isPhoneValid,
                    onPressed: con.login,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'চালিয়ে গেলে আপনি ',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8)),
                        children: const [
                          TextSpan(
                            text: 'শর্তাবলী',
                            style: TextStyle(
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' ও '),
                          TextSpan(
                            text: 'গোপনীয়তা নীতি',
                            style: TextStyle(
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: '-তে সম্মত হচ্ছেন।'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: con.goToRegister,
                      child: Text.rich(
                        TextSpan(
                          text: 'নতুন ব্যবহারকারী? ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                          children: const [
                            TextSpan(
                              text: 'অ্যাকাউন্ট তৈরি করুন',
                              style: TextStyle(
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.con});
  final AuthController con;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: con.isPhoneValid
              ? AppColors.brandOrange
              : const Color(0xFFE2E8F0),
          width: con.isPhoneValid ? 1.6 : 1.2,
        ),
      ),
      child: Row(
        children: [
          // Country code pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: const [
                Text(
                  AuthController.countryIso,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  AuthController.countryCode,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: TextField(
              controller: con.phoneController,
              keyboardType: TextInputType.phone,
              onChanged: con.onPhoneChanged,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                letterSpacing: 1,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '1XXXXXXXXX',
                hintStyle: TextStyle(
                  color: Color(0xFFB6C0CC),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
