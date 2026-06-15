import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/repositories/auth.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
import 'auth_controller.dart';

class RegistrationController extends GetxController {
  final PageController pageController = PageController();
  int currentStep = 0;
  static const int totalSteps = 3;

  bool busy = false;

  // ── Sign-up info (single step: name · phone · email) ──────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill the phone captured during OTP/login if available.
    if (Get.isRegistered<AuthController>()) {
      final p = Get.find<AuthController>().phoneController.text.trim();
      if (p.isNotEmpty) phoneController.text = p;
    }
  }

  void onInfoChanged(String _) => update();

  bool _emailOk(String e) {
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return r.hasMatch(e);
  }

  /// Same phone rules as the login screen: 10 local digits after +880.
  bool get isPhoneValid => phoneController.text.trim().length == 10;
  String get fullPhone =>
      '${AuthController.countryCode}${phoneController.text.trim()}';

  bool get isInfoValid =>
      nameController.text.trim().isNotEmpty &&
      isPhoneValid &&
      // Email is optional — only validate the format when something is entered.
      (emailController.text.trim().isEmpty ||
          _emailOk(emailController.text.trim()));

  /// Register the account (name · phone · email) then go to the login page,
  /// where the user signs in with phone + OTP. No OTP step here.
  Future<void> register() async {
    if (!isInfoValid || busy) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final res = await Get.find<AuthRepository>().register(
        name: nameController.text.trim(),
        phone: fullPhone,
        email: emailController.text.trim(),
      );
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        // Remember the phone so the login screen can pre-fill it.
        StorageService.save(
            StorageConstants.phoneNumber, phoneController.text.trim());
        Get.offAllNamed(Routes.AUTH);
        SnackHelper.success(res.message.isEmpty ? 'এখন লগইন করুন' : res.message);
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

  // ── Step 1: About you ────────────────────────────────────────────
  DateTime? dob;
  String? gender; // পুরুষ / মহিলা / অন্যান্য

  static const List<String> genders = ['পুরুষ', 'মহিলা', 'অন্যান্য'];
  static const List<String> _bnMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  String get dobLabel =>
      dob == null ? '' : '${dob!.day} ${_bnMonths[dob!.month - 1]} ${dob!.year}';

  bool get isStep1Valid =>
      nameController.text.trim().isNotEmpty && dob != null && gender != null;

  // ── Step 2: Location ─────────────────────────────────────────────
  String? division;
  String? district;
  String? thana;
  String? area;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();

  bool get isStep2Valid =>
      division != null && district != null && thana != null && area != null;

  // ── Step 3: Security (PIN) ───────────────────────────────────────
  String pin = '';
  String confirmPin = '';
  bool biometricEnabled = false;
  bool notificationEnabled = true;

  // Button activates once both 4-digit PINs are entered. The match is
  // validated when the user presses "অ্যাকাউন্ট তৈরি করুন" (see _submit).
  bool get isStep3Valid => pin.length == 4 && confirmPin.length == 4;

  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      default:
        return isStep3Valid;
    }
  }

  // ── Mutations ────────────────────────────────────────────────────
  void onNameChanged(String _) => update();

  void setDob(DateTime value) {
    dob = value;
    update();
  }

  void setGender(String value) {
    gender = value;
    update();
  }

  void setDivision(String value) {
    division = value;
    update();
  }

  void setDistrict(String value) {
    district = value;
    update();
  }

  void setThana(String value) {
    thana = value;
    update();
  }

  void setArea(String value) {
    area = value;
    update();
  }

  void setPin(String value) {
    pin = value;
    update();
  }

  void setConfirmPin(String value) {
    confirmPin = value;
    update();
  }

  void toggleBiometric(bool value) {
    biometricEnabled = value;
    update();
  }

  void toggleNotification(bool value) {
    notificationEnabled = value;
    update();
  }

  void useCurrentLocation() {
    // Placeholder: real geolocation wiring can populate these later.
    Get.snackbar('অবস্থান', 'বর্তমান অবস্থান শনাক্ত করা হচ্ছে…',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── Navigation ───────────────────────────────────────────────────
  void next() {
    if (!isCurrentStepValid) return;
    if (currentStep < totalSteps - 1) {
      currentStep++;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      update();
    } else {
      _submit();
    }
  }

  void back() {
    if (currentStep == 0) {
      Get.back();
    } else {
      currentStep--;
      pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      update();
    }
  }

  /// After the final step, validate the PIN, persist the session and go home.
  void _submit() {
    if (pin != confirmPin) {
      Get.snackbar(
        'PIN মিলছে না',
        'দুটি PIN একই দিন।',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final phone = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().phoneController.text.trim()
        : '';
    StorageService.save(StorageConstants.accessToken, 'session_register');
    StorageService.save(StorageConstants.pinCode, pin);
    if (phone.isNotEmpty) {
      StorageService.save(StorageConstants.phoneNumber, phone);
    }
    Get.offAllNamed(Routes.HOME);
  }

  // NOTE: text/page controllers are intentionally NOT disposed here. This is a
  // fenix singleton; disposing them can leave disposed controllers bound to
  // rebuilt fields after offAllNamed (e.g. when bouncing between register and
  // login). They are released when the controller instance is garbage-collected.
}
