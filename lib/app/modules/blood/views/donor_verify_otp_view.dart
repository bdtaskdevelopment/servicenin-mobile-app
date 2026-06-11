import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../auth/widgets/boxed_code_input.dart';
import '../controllers/donor_register_controller.dart';

const _red = Color(0xFFE11D48);

/// OTP step of donor registration. The user enters the 6-digit code sent by
/// the API; [DonorRegisterController.verifyOtp] POSTs it and, on success,
/// pops back to the main blood page. On failure the exact API message is shown.
class DonorVerifyOtpView extends GetView<DonorRegisterController> {
  const DonorVerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE4E4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.sms_outlined,
                        color: _red, size: 30),
                  ),
                  const SizedBox(height: 18),
                  Text('Verify your account'.tr,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit code we sent to verify your donor registration.'.tr,
                    style: const TextStyle(
                        fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  BoxedCodeInput(
                    length: DonorRegisterController.otpLength,
                    accentColor: _red,
                    autoFocus: true,
                    onChanged: controller.onOtpChanged,
                    onCompleted: (_) => controller.verifyOtp(),
                  ),
                ],
              ),
            ),
            // ── Verify button ───────────────────────────────────
            GetBuilder<DonorRegisterController>(
              builder: (con) {
                final enabled = con.isOtpComplete && !con.busy;
                return Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: enabled ? con.verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        disabledBackgroundColor: _red.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Verify & finish'.tr,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 10),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Color(0xFF1A1A1A)),
          ),
          Text('Verify OTP'.tr,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
