import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_colors.dart';

/// App-wide snackbars: success uses the brand theme colour, error uses red.
/// Both always surface the API `message`. When no [title] is passed, the title
/// is derived from the current module (route) — e.g. "Home Service", "Blood" —
/// so messages read in context everywhere instead of a generic "ত্রুটি".
class SnackHelper {
  SnackHelper._();

  static const Color _errorBg = Color(0xFFE11D48);

  /// Module name for the current route, used as the default snackbar title.
  static String moduleTitle() {
    final r = Get.currentRoute.toLowerCase();
    bool has(String s) => r.contains(s);
    if (has('home-service') || has('hs-')) return 'Home Service'.tr;
    if (has('healthcare') || has('hc-')) return 'Healthcare'.tr;
    if (has('blood')) return 'Blood'.tr;
    if (has('ambulance')) return 'Ambulance'.tr;
    if (has('physio')) return 'Physio'.tr;
    if (has('matchmaking')) return 'Marriage'.tr;
    if (has('jobs')) return 'Jobs'.tr;
    if (has('funeral')) return 'Funeral'.tr;
    if (has('education')) return 'Education'.tr;
    if (has('nagarik')) return 'Nagarik Sheba'.tr;
    if (has('information')) return 'Information'.tr;
    if (has('registration')) return 'Login'.tr;
    if (has('otp') || has('auth') || has('phone')) return 'Login'.tr;
    if (has('profile') || has('account') || has('settings')) {
      return 'Profile'.tr;
    }
    return 'ServiceNin';
  }

  static void success(String message, {String? title}) {
    Get.snackbar(
      title ?? moduleTitle(),
      message.trim().isEmpty ? 'সফল হয়েছে' : message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.brandOrange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  static void error(String message, {String? title}) {
    Get.snackbar(
      title ?? moduleTitle(),
      message.trim().isEmpty ? 'কিছু ভুল হয়েছে' : message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: _errorBg,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
