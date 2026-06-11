import 'package:servicenin/app/core/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../values/app_colors.dart';
import '../values/app_fond_sized.dart';

class AppTheme {
  /// Light Theme
  ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: AppColors.appColor,
    cardColor: AppColors.white,
    cardTheme: CardThemeData(color: AppColors.white),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.displayLarge,
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.displayMedium,
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.displaySmall,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.headlineMedium,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.headlineSmall,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.titleLarge,
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.titleMedium,
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.titleSmall,
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.bodyLarge,
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.bodyMedium,
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.bodySmall,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.labelLarge,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleLight.labelSmall,
      ),
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
      titleTextStyle: TextStyle(color: AppColors.white, fontSize: 18),
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
      displayLarge:
          GoogleFonts.poppins(textStyle: AppTextStyleDark.displayLarge),
      displayMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.displayMedium,
      ),
      displaySmall:
          GoogleFonts.poppins(textStyle: AppTextStyleDark.displaySmall),
      headlineMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.headlineMedium,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.headlineSmall,
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.titleLarge,
      ),
      titleMedium:
          GoogleFonts.poppins(textStyle: AppTextStyleDark.titleMedium),
      titleSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.titleSmall,
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.bodyLarge,
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.bodyMedium,
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.bodySmall,
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.labelLarge,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: AppTextStyleDark.labelSmall,
      ),
    ),
    iconTheme: IconThemeData(color: AppColors.white, size: 25.0),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.gold,
      disabledColor: AppColors.grey,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      titleTextStyle: TextStyle(color: AppColors.white),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColors.grey,
    ),
  );
}
