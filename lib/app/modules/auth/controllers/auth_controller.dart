import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicenin/app/core/helpers/app_helper.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/services/notification_socket_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/auth_response.dart';
import '../../../data/repositories/auth.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  AuthRepository get _repo => Get.find<AuthRepository>();

  bool busy = false;

  // ── Phone entry ──────────────────────────────────────────────────
  final TextEditingController phoneController = TextEditingController();

  // The chip shows the short "+88" prefix; the customer then types the
  // full local number the way they'd dial it domestically, leading 0 and
  // all ("01XXXXXXXXX", 11 digits). "+88" + "01744865867" concatenates to
  // exactly the same E.164 string ("+8801744865867") as the old "+880" +
  // "1744865867" split did — this only changes where the UI divides the
  // digits, not the number that's actually sent to the backend.
  static const String countryCode = '+88';
  static const String countryIso = 'BD';

  /// BD mobile numbers are 11 digits after the +88 code, starting with 0
  /// (e.g. 01XXXXXXXXX).
  bool get isPhoneValid =>
      phoneController.text.trim().length == 11 &&
      phoneController.text.trim().startsWith('0');

  void onPhoneChanged(String _) => update();

  String get fullPhone => '$countryCode${phoneController.text.trim()}';

  /// The exact phone an OTP was requested for — carried to verify/resend so it
  /// always matches what /login used (even if the field later changes).
  String otpPhone = '';

  /// Pretty masked phone used on the OTP screen subtitle, e.g.
  /// "+88 01744 86 5867".
  String get displayPhone {
    final digits = phoneController.text.trim();
    if (digits.length < 11) return fullPhone;
    return '$countryCode ${digits.substring(0, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
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

  // ── OTP SMS autofill ────────────────────────────────────────────
  // Uses Android's SMS User Consent API: no RECEIVE_SMS/READ_SMS permission
  // needed (Play Store restricts those to default SMS/dialer apps), and the
  // system shows a one-tap consent dialog with the incoming message before
  // handing the text to the app. No-op on iOS/other platforms.
  final SmartAuth _smartAuth = SmartAuth.instance;
  String? otpPrefillValue;
  int otpPrefillToken = 0;

  Future<void> _listenForOtpSms() async {
    try {
      final res = await _smartAuth.getSmsWithUserConsentApi();
      if (!res.hasData) return;
      final code = res.requireData.code;
      if (code == null || code.length != otpLength) return;
      otpPrefillValue = code;
      otpPrefillToken++;
      _otp = code;
      update();
      await verifyOtp();
    } catch (_) {
      // No Play Services, user dismissed the consent dialog, listener timed
      // out, etc. — the user can always still type/paste the code manually.
    }
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
    // Arm the SMS listener BEFORE the request goes out, not after it
    // succeeds: some gateways deliver the OTP within ~1s, which can beat
    // Play Services to registering the listener if we wait for the HTTP
    // round-trip first — that race makes the consent broadcast arrive with
    // a TIMEOUT status instead of the actual message.
    unawaited(_listenForOtpSms());
    final res = await _run(() => _repo.requestOtp(otpPhone));
    if (res == null) return;
    if (res.success) {
      proceedToOtp();
      // Login success snackbar hidden — not needed.
      // SnackHelper.success(res.message);
    } else if (res.registered == false) {
      // No account for this phone — the backend tells us so explicitly
      // (data.registered == false) rather than sending an OTP for nothing.
      // Surface why, then take them straight to registration with the
      // number already filled in.
      SnackHelper.error(res.message, title: 'Login'.tr);
      goToRegister();
    } else {
      SnackHelper.error(res.message, title: 'Login'.tr);
    }
  }

  /// Open the OTP screen (OTP already requested; the SMS listener is already
  /// armed from [login]/[resendOtp]).
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
    // See the comment in login() — arm the listener before the request.
    unawaited(_listenForOtpSms());
    final res = await _run(() => _repo.resendOtp(phone));
    if (res == null) return;
    _otp = '';
    _startTimer();
    SnackHelper.success(
        res.message.isEmpty ? 'নতুন কোড পাঠানো হয়েছে' : res.message);
  }

  /// "যাচাই করুন" — verify the OTP. On success save token + user and go home;
  /// if the user does not exist, show the API message (e.g. please register).
  Future<void> verifyOtp() async {
    if (!isOtpComplete) return;
    final phone = otpPhone.isNotEmpty ? otpPhone : fullPhone;
    final res = await _run(() => _repo.verifyOtp(phone, _otp));
    if (res == null) return;

    if (res.success && res.userExist && (res.token ?? '').isNotEmpty) {
      printWrapped(
          'OTP verification successful. Saving token and user info. ${res.token}');
      await StorageService.save(StorageConstants.accessToken, res.token);
      if ((res.refreshToken ?? '').isNotEmpty) {
        await StorageService.save(
            StorageConstants.refreshToken, res.refreshToken);
      }
      if (res.user != null) {
        await StorageService.save(
            StorageConstants.userInfo, jsonEncode(res.user!.toMap()));
      }
      await StorageService.save(
          StorageConstants.phoneNumber, phoneController.text.trim());
      _timer?.cancel();
      // The device token may already exist from before this user signed
      // in — nothing to attach it to until now, so (re-)send it.
      unawaited(PushNotificationService.instance.syncToken());
      // Realtime notification feed for this session (foreground delivery —
      // works immediately, independent of FCM/push setup).
      NotificationSocketService.instance.connect();
      // No success message on login — go straight home (or the provider
      // dashboard, for a home-service provider account).
      Get.offAllNamed(AuthUser.fromStorage()?.isProvider == true
          ? Routes.HS_PROVIDER
          : Routes.HOME);
    } else if (res.success && !res.userExist) {
      // A valid OTP but no account for this phone (needs_register) — in
      // practice login() already blocks this before an OTP is even sent,
      // but this keeps the OTP screen itself correct too (e.g. the account
      // being removed between request and verify). The OTP was already
      // consumed server-side, so just move on to registration.
      _timer?.cancel();
      Get.offNamed(Routes.REGISTRATION);
    } else {
      // Wrong/expired OTP: clear the boxes so the user can re-enter, then
      // surface the error.
      _otp = '';
      otpClearToken++;
      update();
      SnackHelper.error(res.message, title: 'Login'.tr);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    unawaited(_smartAuth.removeUserConsentApiListener());
    // NOTE: phoneController is intentionally NOT disposed here. This controller
    // is a fenix singleton; disposing the TextEditingController can leave a
    // disposed controller bound to the rebuilt login field after
    // offAllNamed(AUTH) (e.g. right after registration).
    super.onClose();
  }
}
