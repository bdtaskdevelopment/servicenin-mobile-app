import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../routes/app_pages.dart';

/// Drives the "Register as a blood donor" flow:
///   1. [register]  → POST /blood/donors/register, then opens the OTP page.
///   2. [verifyOtp] → POST /blood/donors/verify-otp, then returns to the
///      main blood page on success. Both surface the exact API `message`.
class DonorRegisterController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  // ── Registration form ──────────────────────────────────────────────
  String group = 'A+';
  // lat/lng auto-detected (GPS) in a full build; default to Dhaka for now.
  double lat = 23.8103;
  double lng = 90.4125;
  final TextEditingController notes = TextEditingController();

  // ── OTP step ────────────────────────────────────────────────────────
  static const int otpLength = 6;
  String otp = '';
  bool get isOtpComplete => otp.length == otpLength;

  bool busy = false;

  void setGroup(String value) {
    group = value;
    update();
  }

  void onOtpChanged(String value) {
    otp = value;
    update();
  }

  /// Submit the donor registration. On success, moves to the OTP screen.
  Future<void> register() async {
    if (busy) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final payload = <String, dynamic>{
        'blood_group': group,
        'lat': lat,
        'lng': lng,
        'notes': notes.text.trim(),
      };
      final res = await Get.find<BloodRepository>().registerDonor(payload);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        otp = ''; // fresh start for the OTP screen
        SnackHelper.success(res.message);
        Get.toNamed(Routes.BLOOD_DONOR_VERIFY_OTP);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Verify the OTP. On success, pops back to the main blood page; on failure
  /// shows the exact API message (e.g. "invalid or expired OTP").
  Future<void> verifyOtp() async {
    if (busy || !isOtpComplete) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final res = await Get.find<BloodRepository>().verifyDonorOtp(otp);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        // Pop the OTP + register pages, landing back on the main blood page.
        Get.until((route) => route.settings.name == Routes.BLOOD);
      } else {
        SnackHelper.error(res.message); // exact API message
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    notes.dispose();
    super.onClose();
  }
}
