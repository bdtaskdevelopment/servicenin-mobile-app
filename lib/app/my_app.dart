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
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.appColorSecond,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.appColorSecond,
        systemNavigationBarIconBrightness: Brightness.light,
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
      locale: Locale(StorageService.read(StorageConstants.languageCode) ??
          AppConst.langCodeEn),
      fallbackLocale: Locale(
          StorageService.read(StorageConstants.languageCode) ??
              AppConst.langCodeEn),
      popGesture: true,
      routingCallback: (routing) {},
      onInit: () {},
      navigatorKey: Get.key,
    );
  }
}
