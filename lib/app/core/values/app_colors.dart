import 'package:flutter/material.dart';

import '../helpers/app_helper.dart';

class AppColors {
  AppColors._();
  // ── ServiceNin brand theme (orange) ─────────────────────────────
  static const Color brandOrange = Color(0xffF15A24);
  static const Color brandOrangeDark = Color(0xffE14E14);
  static const Color brandOrangeLight = Color(0xffFF7A45);

  // static Color primaryColor = Helpers.fromHex('#F7AA31');
  static const Color pkgColor = Color(0xffeaf5eb);
  // static const Color appColor = Color(0xff188753);#00a653
  // static const Color appColor = Color(0xff09650E);
  static const Color appColorSlow = Color(0xffDDF7E5);
  // Primary app color — points to the ServiceNin brand orange so the
  // whole app picks up the theme from one place.
  static const Color appColor = brandOrange;
  static const Color appColorCo1 = Color(0xff78BE3B);
  static const Color appColorCo2 = Color(0xffA0D084);
  static const Color textColor = Color(0xff6D6D6D);
  static const Color appColorBg = Color(0xffEFFFEF);
  static const Color hardGreen = Color(0xff074608);
  static const Color innerPageBack = Color(0xffF7FAF7);
  static const Color appColorSecond = Color(0xff54B482);
  static const Color headingColor = Color(0xff4F4F4F);
  static const Color headingColor2 = Color(0xff444444);
  static const Color headingColor3 = Color(0xff484C52);

  static const Color accountSetting = Color(0xff6086E8);
  static const Color  invite = Color(0xffB57DE3);
  static const Color notification = Color(0xffA09DFC);
  static const Color kycVerification = Color(0xff7AB8EA);
  static const Color appLanguage = Color(0xffFF981F);
  static const Color goPremium = Color(0xff23C6AA);
  static const Color addsManagement = Color(0xff9277EA);
  static const Color returnToHome = Color(0xffF75555);


  static const Color headingLogin = Color(0xff06054B);
  static const Color blackBack = Color(0xff090919);
  static const Color gradientOne = Color(0xff1F2A5C);
  static const Color gradientTwo = Color(0xff4D4E5F);
  static const Color residencyBack = Color(0xffF7FFF7);
  static const Color appPrimary = Color(0xff2D8155);
  static const Color appPrimary2 = Color(0xff2E934D);
  static const Color appPrimary3 = Color(0xff368C5F);
  static const Color appPrimary4 = Color(0xff6BE094);
  static const Color appPrimary5 = Color(0xffBEEFBE);
  static const Color appPrimary6 = Color(0xffF5FFFA);
  static const Color yellow = Color(0xffFF8C22);
  static const Color gold = Color(0xffFFB000);
  static const Color bronze = Color(0xffFF7900);
  static const Color pink = Color(0xffFFDEDD);
  static const Color multiPay = Color(0xff26B59F);
  static const Color card = Color(0xff0082A5);
  static const Color red = Color(0xffCC3E3E);

  static const Color yellowMain = Color(0xffFFE100);
  static const Color calculator = Color(0xff5889FB);
  static const Color grey = Color(0xff768089);
  static const Color greySlow = Color(0xffEDEDED);
  static const Color greySlow2 = Color(0xffF3F6F1);
  static const Color textColors = Color(0xff504C4B);
  static const Color borderColor = Color(0xffE8E8E8);
  static const Color borderColor2 = Color(0xffA9A9A9);
  static const Color inputBackground = Color(0xffF5F9FE);
  static const Color slowBackground = Color(0xffF2F2F2);
  static const Color btnAppbar = Color(0xff3E3E3E);
  static const Color document = Color(0xff7f146a);
  static const Color makePayment = Color(0xff3d307f);
  static const Color document2 = Color(0xfff5e4f2);
  static const Color yellowPrinter = Color(0xfffcf7e9);

  static const Color greye2 = Color(0xffe8e2e2);
  static const Color greye3 = Color(0xff7B3232);
  static const Color hash = Color(0xff6F6F6F);
  static const Color hashShadow = Color(0xffF5F7FE);
  static const Color hashBack = Color(0xffF4F4F4);
  static const Color hashShadow2 = Color(0xffE5F2E5);

  // static const Color normalGreen = Color(0xff09650E);
  static const Color normalGreen = Color(0xff43AF49);
  static const Color normalHashGreen = Color(0xffE0F1E1);

  static const Color discount = Color(0xffA6AE09);
  static const Color stockOut = Color(0xffFF82AC);
  static const Color tableHeader = Color(0xff002739);
  static const Color statusBarDarkColor = Colors.black;
  static const Color bottomNavBack = Color(0xff002739);
  static Color statusBarLightColor = Helpers.fromHex("40CC48");
  static Color scaffoldBackgroundColor = Helpers.fromHex("F5F6F8");
  static Color primaryColor = Helpers.fromHex('0E5E6F');
  static Color dividerColor = Helpers.fromHex('D6D6D6');
  static Color secondaryColor = Colors.green;
  //static Color bgColor = Helpers.fromHex('#F4FDFF');
  static const Color black = Color(0xFF000000);
  static Color blackButton = Color(0xff444444);
  static Color appBarEarnBack = Color(0xffEEFBF4);
  static Color black54 = Color(0xff515151);
  static Color black7c = Color(0xff7c7c7c);
  static Color blackAppbarTitle = Color(0xff404040);
  static const Color white = Color(0xFFFFFFFF);
  static Color todaySell = Color(0xffFFF5D9);
  static Color totalExpense = Color(0xffDCFAF8);
  static Color expenseSell = Color(0xffFFE0EB);
  static Color pageBackground = Color(0xffF5F7FA);
  static Color dueEdit = Color(0xffdef0ea);
  static Color white60 = Colors.white60;
  static Color grey100 = Colors.grey.shade100;
  static Color grey200 = Colors.grey.shade200;
  static Color grey300 = Colors.grey.shade300;
  static Color green = Colors.green;
  static Color blue = Colors.blue;
  static Color cyan = Colors.cyan;
  //
  static Color editTextFillColor = hexToColor("#F1F1F1");
  static Color hintTextColor = hexToColor("#717171");
  static Color backButtonColor = hexToColor("#DDDDDD").withOpacity(0.9);
  static Color buttonColor = hexToColor("#1A1A1A");
  static Color drift = Color(0xff3CB371);
  static Color redFF = Color(0xffFFEAEB);
  static Color black70 = Color(0xff707070);
  static Color blackF9 = Color(0xffFAF9F9);
  static Color operatorColor = Color(0xff505050);
  static Color whiteF12 = Color(0xffF2F2F2);
  static const Color calulatorBtnColor = Color(0xff505050);
}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
      'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}
