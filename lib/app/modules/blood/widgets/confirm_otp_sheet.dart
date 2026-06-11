import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../auth/widgets/boxed_code_input.dart';
import '../controllers/donation_flow_controller.dart';

const _red = Color(0xFFE11D48);

/// Bottom sheet where the donor enters the requester's 6-digit code to
/// confirm the donation.
class ConfirmOtpSheet extends StatefulWidget {
  const ConfirmOtpSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const ConfirmOtpSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  @override
  State<ConfirmOtpSheet> createState() => _ConfirmOtpSheetState();
}

class _ConfirmOtpSheetState extends State<ConfirmOtpSheet> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final con = Get.find<DonationFlowController>();
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
          Text('Confirm donation'.tr,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(
            'Ask the requester for the 6-digit code shown in their app. This confirms the donation and credits your record.'.tr,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
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
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _code.length == 6
                  ? () {
                      Get.back();
                      con.completeDonation();
                    }
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
              child: Text('Confirm & complete'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          ],
          ),
        ),
    );
  }
}
