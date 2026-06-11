import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../auth/widgets/boxed_code_input.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE11D48);

/// Bottom sheet where the donor enters the OTP sent after responding to a
/// blood request. On confirm it POSTs to `/api/v1/blood/donors/verify-otp`
/// and, on success, lands on the donation-confirmed screen.
class RespondOtpSheet extends StatefulWidget {
  const RespondOtpSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const RespondOtpSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  @override
  State<RespondOtpSheet> createState() => _RespondOtpSheetState();
}

class _RespondOtpSheetState extends State<RespondOtpSheet> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    // GetX's bottom sheet already pads for the keyboard (viewInsets), so the
    // sheet only needs the safe-area bottom inset here.
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Verify your response'.tr,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(
                'Enter the 6-digit code we sent to confirm your offer to donate.'.tr,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              BoxedCodeInput(
                length: 6,
                boxSize: 46,
                accentColor: _red,
                autoFocus: true,
                onChanged: (v) => setState(() => _code = v),
              ),
              const SizedBox(height: 22),
              GetBuilder<BloodController>(
                builder: (c) => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_code.length == 6 && !c.verifyingOtp)
                        ? () => c.verifyRespondOtp(_code)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      disabledBackgroundColor: _red.withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: c.verifyingOtp
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text('Confirm & verify'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
