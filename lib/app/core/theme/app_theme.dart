import 'package:servicenin/app/core/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../values/app_colors.dart';
import '../values/app_fond_sized.dart';

// Poppins for English/numerals, Hind Siliguri as the fallback so Bangla
// glyphs in the same string render correctly — no locale branching needed,
// Flutter picks the fallback automatically per-glyph.
//
// Both are bundled locally (pubspec `fonts:`) as real multi-weight families
// with weight-tagged assets, NOT fetched at runtime via google_fonts.
// google_fonts registers a DIFFERENT synthetic family name per weight, so
// any ad-hoc TextStyle that only overrides fontWeight while inheriting this
// ambient fontFamily/fontFamilyFallback never finds the matching weight's
// real face and gets a synthetically stretched "faux bold" glyph instead —
// that's what made bold Bangla text look stretched ("lomba") app-wide. A
// single real family name per font lets Flutter's own font matching pick
// the correct weight for ANY TextStyle, anywhere, with no per-call-site fix.
TextStyle _appFont(TextStyle textStyle) => textStyle.copyWith(
      fontFamily: 'Poppins',
      fontFamilyFallback: const ['Hind Siliguri'],
    );

class AppTheme {
  /// Light Theme
  ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: AppColors.appColor,
    cardColor: AppColors.white,
    cardTheme: CardThemeData(color: AppColors.white),
    textTheme: TextTheme(
      displayLarge: _appFont(AppTextStyleLight.displayLarge),
      displayMedium: _appFont(AppTextStyleLight.displayMedium),
      displaySmall: _appFont(AppTextStyleLight.displaySmall),
      headlineMedium: _appFont(AppTextStyleLight.headlineMedium),
      headlineSmall: _appFont(AppTextStyleLight.headlineSmall),
      titleLarge: _appFont(AppTextStyleLight.titleLarge),
      titleMedium: _appFont(AppTextStyleLight.titleMedium),
      titleSmall: _appFont(AppTextStyleLight.titleSmall),
      bodyLarge: _appFont(AppTextStyleLight.bodyLarge),
      bodyMedium: _appFont(AppTextStyleLight.bodyMedium),
      bodySmall: _appFont(AppTextStyleLight.bodySmall),
      labelLarge: _appFont(AppTextStyleLight.labelLarge),
      labelSmall: _appFont(AppTextStyleLight.labelSmall),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.appColor,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.white,
          fontSize: AppFontSize.fontSize14,
        ),
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.white, size: 25.0),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.appColor,
      disabledColor: AppColors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.appColor,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    bottomAppBarTheme: BottomAppBarThemeData(
      color: AppColors.appColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.appColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.appColor,
    ),
  );

  /// Dark Theme
  ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.gold,
    cardColor: AppColors.black,
    cardTheme: CardThemeData(color: AppColors.red),
    textTheme: TextTheme(
      displayLarge: _appFont(AppTextStyleDark.displayLarge),
      displayMedium: _appFont(AppTextStyleDark.displayMedium),
      displaySmall: _appFont(AppTextStyleDark.displaySmall),
      headlineMedium: _appFont(AppTextStyleDark.headlineMedium),
      headlineSmall: _appFont(AppTextStyleDark.headlineSmall),
      titleLarge: _appFont(AppTextStyleDark.titleLarge),
      titleMedium: _appFont(AppTextStyleDark.titleMedium),
      titleSmall: _appFont(AppTextStyleDark.titleSmall),
      bodyLarge: _appFont(AppTextStyleDark.bodyLarge),
      bodyMedium: _appFont(AppTextStyleDark.bodyMedium),
      bodySmall: _appFont(AppTextStyleDark.bodySmall),
      labelLarge: _appFont(AppTextStyleDark.labelLarge),
      labelSmall: _appFont(AppTextStyleDark.labelSmall),
    ),
    iconTheme: IconThemeData(color: AppColors.white, size: 25.0),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.gold,
      disabledColor: AppColors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      titleTextStyle:
          TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.grey,
    ),
  );
}
