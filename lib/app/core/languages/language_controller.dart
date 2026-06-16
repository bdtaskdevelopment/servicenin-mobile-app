import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../values/app_const.dart';
import '../values/storage.dart';
import '../../data/services/storage.service.dart';

/// Holds the app language and switches it live. Bangla is the default.
class LanguageController extends GetxController {
  /// Current language code: `bn` (default) or `en`.
  String code = AppConst.langCodeBn;

  bool get isBangla => code == AppConst.langCodeBn;

  /// 0 = Bangla, 1 = English (matches the settings selector order).
  int get index => isBangla ? 0 : 1;

  @override
  void onInit() {
    super.onInit();
    final saved = StorageService.read(StorageConstants.languageCode);
    if (saved is String && saved.isNotEmpty) {
      code = saved;
    }
  }

  Future<void> setLanguage(String langCode) async {
    // Always re-apply (don't early-return on an equal code) so the rendered
    // locale and the saved code can't drift out of sync.
    code = langCode;
    Get.updateLocale(Locale(langCode));
    await StorageService.save(StorageConstants.languageCode, langCode);
    update();
  }

  /// Convenience for the settings selector (0 = Bangla, 1 = English).
  Future<void> setByIndex(int i) =>
      setLanguage(i == 0 ? AppConst.langCodeBn : AppConst.langCodeEn);
}
