import 'dart:io';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/auth_response.dart';
import '../../../data/services/settings.service.dart';
import '../../../data/services/storage.service.dart';
import '../../../global_widget/update_required_dialog.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Request location permission / fix in the background. This must NOT
    // block reaching the login page — a denied dialog or a slow GPS fix
    // would otherwise stall first launch. The app can re-ask for it later,
    // wherever a location-dependent feature is actually used.
    LocationService.getCurrentPosition();
    _init();
  }

  Future<void> _init() async {
    // Re-fetch settings here rather than trusting AppDependencyInjection's
    // fire-and-forget load() to have finished — app_version/min_app_version
    // must be current before the update check below reads them.
    final minSplash = Future.delayed(const Duration(seconds: 3));
    await SettingsService.to.load();
    await minSplash;

    if (await _blockedByForcedUpdate()) return;

    final String? token = StorageService.read(StorageConstants.accessToken);
    if (token == null) {
      Get.offAndToNamed(Routes.AUTH);
    } else if (AuthUser.fromStorage()?.isProvider == true) {
      Get.offAndToNamed(Routes.HS_PROVIDER);
    } else {
      Get.offAndToNamed(Routes.HOME);
    }
  }

  /// Returns true (and leaves the force-update dialog on screen, blocking
  /// navigation) when the installed build is below `min_app_version`. A
  /// build between `min_app_version` and `app_version` instead shows a
  /// dismissible nudge and lets navigation continue underneath it.
  Future<bool> _blockedByForcedUpdate() async {
    if (!SettingsService.to.loaded) return false;
    final settings = SettingsService.to.settings;
    final storeUrl =
        Platform.isIOS ? settings.appstoreUrl : settings.playstoreUrl;
    if (storeUrl.isEmpty) return false;

    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (settings.minAppVersion.isNotEmpty &&
          _isOlder(current, settings.minAppVersion)) {
        await UpdateRequiredDialog.show(forced: true, storeUrl: storeUrl);
        return true;
      }
      if (settings.appVersion.isNotEmpty &&
          _isOlder(current, settings.appVersion)) {
        await UpdateRequiredDialog.show(forced: false, storeUrl: storeUrl);
      }
    } catch (_) {
      // Can't read the installed version or settings are malformed — don't
      // block app access over it.
    }
    return false;
  }

  /// True when [current] < [target], comparing dot-separated numeric parts
  /// (e.g. "1.0.2" vs "1.1.0"); missing trailing parts count as 0.
  static bool _isOlder(String current, String target) {
    final a = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final b = target.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    for (var i = 0; i < a.length || i < b.length; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av < bv;
    }
    return false;
  }
}
