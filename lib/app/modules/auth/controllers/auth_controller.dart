import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicenin/app/core/helpers/app_helper.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/repositories/auth.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  AuthRepository get _repo => Get.find<AuthRepository>();

  bool busy = false;

  // ── Phone entry ──────────────────────────────────────────────────
  final TextEditingController phoneController = TextEditingController();

  static const String countryCode = '+880';
  static const String countryIso = 'BD';

  /// BD mobile numbers are 10 digits after the +880 code (e.g. 1XXXXXXXXX).
  bool get isPhoneValid => phoneController.text.trim().length == 10;

  void onPhoneChanged(String _) => update();

  String get fullPhone => '$countryCode${phoneController.text.trim()}';

  /// The exact phone an OTP was requested for — carried to verify/resend so it
  /// always matches what /login used (even if the field later changes).
  String otpPhone = '';

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

  /// Bumped to clear the OTP boxes (e.g. after a wrong code).
  int otpClearToken = 0;

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
    resendSeconds = 60;
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

  /// Run an async task with a blocking loading dialog + error snackbar.
  Future<T?> _run<T>(Future<T> Function() task) async {
    if (busy) return null;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final result = await task();
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      return result;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''),
          title: 'Login'.tr);
      return null;
    }
  }

  /// "লগইন করুন" — request an OTP from the API, then open the OTP screen.
  Future<void> login() async {
    if (!isPhoneValid) return;
    otpPhone = fullPhone; // capture the exact phone used for this OTP request
    final res = await _run(() => _repo.requestOtp(otpPhone));
    if (res == null) return;
    if (res.success) {
      proceedToOtp();
      // Login success snackbar hidden — not needed.
      // SnackHelper.success(res.message);
    } else {
      SnackHelper.error(res.message, title: 'Login'.tr);
    }
  }

  /// Open the OTP screen (OTP already requested).
  void proceedToOtp() {
    _otp = '';
    _startTimer();
    Get.toNamed(Routes.OTP);
  }

  /// "অ্যাকাউন্ট তৈরি করুন" — start the registration flow.
  void goToRegister() => Get.toNamed(Routes.REGISTRATION);

  Future<void> resendOtp() async {
    if (!canResend) return;
    final phone = otpPhone.isNotEmpty ? otpPhone : fullPhone;
    final res = await _run(() => _repo.resendOtp(phone));
    if (res == null) return;
    _otp = '';
    _startTimer();
    SnackHelper.success(res.message.isEmpty ? 'নতুন কোড পাঠানো হয়েছে' : res.message);
  }

  /// "যাচাই করুন" — verify the OTP. On success save token + user and go home;
  /// if the user does not exist, show the API message (e.g. please register).
  Future<void> verifyOtp() async {
    if (!isOtpComplete) return;
    final phone = otpPhone.isNotEmpty ? otpPhone : fullPhone;
    final res = await _run(() => _repo.verifyOtp(phone, _otp));
    if (res == null) return;

    if (res.success && res.userExist && (res.token ?? '').isNotEmpty) {
      printWrapped('OTP verification successful. Saving token and user info. ${res.token}');
      await StorageService.save(StorageConstants.accessToken, res.token);
      if ((res.refreshToken ?? '').isNotEmpty) {
        await StorageService.save(StorageConstants.refreshToken, res.refreshToken);
      }
      if (res.user != null) {
        await StorageService.save(
            StorageConstants.userInfo, jsonEncode(res.user!.toMap()));
      }
      await StorageService.save(
          StorageConstants.phoneNumber, phoneController.text.trim());
      _timer?.cancel();
      // No success message on login — go straight home.
      Get.offAllNamed(Routes.HOME);
    } else {
      // user_exist == false or verification failed: clear the OTP boxes so the
      // user can re-enter, then surface the error.
      _otp = '';
      otpClearToken++;
      update();
      SnackHelper.error(res.message, title: 'Login'.tr);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    // NOTE: phoneController is intentionally NOT disposed here. This controller
    // is a fenix singleton; disposing the TextEditingController can leave a
    // disposed controller bound to the rebuilt login field after
    // offAllNamed(AUTH) (e.g. right after registration).
    super.onClose();
  }
}
