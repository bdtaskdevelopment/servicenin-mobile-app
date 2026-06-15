import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_colors.dart';

/// App-wide snackbars: success uses the brand theme colour, error uses red.
/// Both always surface the API `message`.
class SnackHelper {
  SnackHelper._();

  static const Color _errorBg = Color(0xFFE11D48);

  static void success(String message, {String title = 'সফল'}) {
    Get.snackbar(
      title,
      message.trim().isEmpty ? 'সফল হয়েছে' : message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.brandOrange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  static void error(String message, {String title = 'ত্রুটি'}) {
    Get.snackbar(
      title,
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
