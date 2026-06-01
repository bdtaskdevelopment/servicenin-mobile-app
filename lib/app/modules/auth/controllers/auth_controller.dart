import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/storage.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  // ── Phone entry ──────────────────────────────────────────────────
  final TextEditingController phoneController = TextEditingController();

  static const String countryCode = '+880';
  static const String countryIso = 'BD';

  /// BD mobile numbers are 10 digits after the +880 code (e.g. 1XXXXXXXXX).
  bool get isPhoneValid => phoneController.text.trim().length == 10;

  void onPhoneChanged(String _) => update();

  String get fullPhone => '$countryCode${phoneController.text.trim()}';

  /// Pretty masked phone used on the OTP screen subtitle, e.g.
  /// "+880 1744 86 5867".
  String get displayPhone {
    final digits = phoneController.text.trim();
    if (digits.length < 10) return fullPhone;
    return '$countryCode ${digits.substring(0, 4)} ${digits.substring(4, 6)} ${digits.substring(6)}';
  }

  // ── OTP ──────────────────────────────────────────────────────────
  static const int otpLength = 6;
  String _otp = '';
  bool get isOtpComplete => _otp.length == otpLength;

  void onOtpChanged(String value) {
    _otp = value;
    update();
  }

  // Resend countdown
  Timer? _timer;
  int resendSeconds = 0;
  bool get canResend => resendSeconds == 0;

  String get resendLabel {
    final m = (resendSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (resendSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTimer() {
    _timer?.cancel();
    resendSeconds = 30;
    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds <= 0) {
        t.cancel();
      } else {
        resendSeconds--;
      }
      update();
    });
  }

  // ── Actions ──────────────────────────────────────────────────────

  /// "লগইন করুন" — send OTP then go to the OTP screen.
  void login() {
    if (!isPhoneValid) return;
    proceedToOtp();
  }

  /// Send an OTP and open the OTP screen. Shared by login and the end of the
  /// registration flow.
  void proceedToOtp() {
    _otp = '';
    _startTimer();
    Get.toNamed(Routes.OTP);
  }

  /// "অ্যাকাউন্ট তৈরি করুন" — start the registration flow.
  void goToRegister() => Get.toNamed(Routes.REGISTRATION);

  void resendOtp() {
    if (!canResend) return;
    _otp = '';
    _startTimer();
    Get.snackbar('OTP', 'নতুন কোড পাঠানো হয়েছে',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// "যাচাই করুন" — verify OTP, persist a session token and go home.
  void verifyOtp() {
    if (!isOtpComplete) return;
    StorageService.save(StorageConstants.accessToken, 'session_$fullPhone');
    StorageService.save(StorageConstants.phoneNumber, phoneController.text.trim());
    _timer?.cancel();
    Get.offAllNamed(Routes.HOME);
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    super.onClose();
  }
}
