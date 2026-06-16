import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app_binding.dart';
import 'core/languages/app_translation.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/values/app_colors.dart';
import 'core/values/app_const.dart';
import 'core/values/storage.dart';
import 'data/services/storage.service.dart';
import 'routes/app_pages.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Saved language code, or Bangla by default (only honour a valid choice).
  late final String _langCode = _resolveLang();

  static String _resolveLang() {
    final saved = StorageService.read(StorageConstants.languageCode);
    if (saved is String &&
        (saved == AppConst.langCodeBn || saved == AppConst.langCodeEn)) {
      return saved;
    }
    return AppConst.langCodeBn; // default → Bangla
  }

  @override
  void initState() {
    super.initState();
    // Force Get.locale on cold start so static text renders in the selected
    // language (Bangla by default) from the first screen. The GetMaterialApp
    // `locale` param alone doesn't always set Get.locale on launch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.locale?.languageCode != _langCode) {
        Get.updateLocale(Locale(_langCode));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark, // Android status icons
        statusBarBrightness: Brightness.light, // iOS status icons
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: AppColors.white,
      ),
    );
    return GetMaterialApp(
      defaultTransition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 350), // Optional
      title: "ServiceNin",
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme().lightTheme,
      darkTheme: AppTheme().darkTheme,
      themeMode: ThemeService().theme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      translationsKeys: AppTranslation.translationsKeys,
      locale: Locale(_langCode),
      fallbackLocale: const Locale(AppConst.langCodeEn),
      popGesture: true,
      routingCallback: (routing) {},
      onInit: () {},
      navigatorKey: Get.key,
    );
  }
}
