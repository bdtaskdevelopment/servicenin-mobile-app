import 'dart:async';
import 'dart:io';
import 'package:internet_checker_plus/internet_checker_plus.dart';
import 'package:servicenin/app/core/helpers/app_helper.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:internet_checker_plus/internet_level.dart';

import 'app/app_binding.dart';
import 'app/core/values/app_const.dart';
import 'app/core/values/storage.dart';
import 'app/data/services/storage.service.dart';
import 'app/my_app.dart';
// import 'firebase_options.dart';
import 'package:flutter_log_console/flutter_log_console.dart';
void main() async {

  // runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();

    // White system navigation bar (with dark buttons) from the very start —
    // applies on the splash and every page that follows.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );

    // Must load before AppDependencyInjection.init() — AppConfig.baseUrl reads
    // dotenv, and SettingsService fetches /api/v1/settings synchronously
    // during dependency setup (unlike other providers, which are only used
    // later from screen controllers). Loading dotenv after init() meant that
    // first request read an empty/uninitialized BASE_URL and silently failed
    // before ever reaching the network — every later screen's provider calls
    // happened to work because by then dotenv had already loaded.
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Missing or unreadable .env must not crash startup — fall back to
      // an empty env so dotenv.get(...) calls don't throw and the app can
      // still reach the splash screen.
      dotenv.loadFromString(envString: '', isOptional: true);
      FlutterConsole.log("dotenv load failed, using empty env: $e");
    }

    // Must run before AppDependencyInjection.init() — that call puts
    // LanguageController immediately (permanent), and its onInit() reads the
    // saved language from GetStorage synchronously. Reading before the box is
    // ready silently returns null, so the settings screen's language
    // checkmark stuck on the Bangla default even when English was saved.
    await GetStorage.init();

    AppDependencyInjection.init();

    // One-time: make Bangla the default language. This resets any stale value
    // left by earlier builds (e.g. English) so the app opens in Bangla. It runs
    // only once — the user's later language choice persists after this.
    if (StorageService.read('lang_default_bn_v1') != true) {
      await StorageService.save(
          StorageConstants.languageCode, AppConst.langCodeBn);
      await StorageService.save('lang_default_bn_v1', true);
    }

    FlutterConsole.log("Hello Flutter");
    runApp(MyApp());
}
