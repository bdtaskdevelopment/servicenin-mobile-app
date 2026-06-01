import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:servicenin/app/global_widget/custom_phone_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/storage.service.dart';
import '../../routes/app_pages.dart';
import '../values/app_assets.dart';
import '../values/app_colors.dart';
import '../values/app_dismens.dart';
import '../values/app_space.dart';
import '../values/storage.dart';
class Helpers {
  Helpers._();

  static List<DateTime> getNextNDays(int n) {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 1; i <= n; i++) {
      dates.add(now.add(Duration(days: i)));
    }
    return dates;
  }

  static Color generateRandomPrimaryColor() {
    Random random = Random();
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);
    return Color.fromARGB(255, red, green, blue);
  }


  static Future<void> launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  static Future<bool?> showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(children: [const Expanded(child: Text('Are You Sure ?'))]),
          content: const Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // don't exit
              },
              child: Text('No', style: TextStyle(color: AppColors.appColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appColor, // 🔥 button color
                foregroundColor: AppColors.appColor, // text/icon color
              ),
              onPressed: () {
                // Close dialog first
                Navigator.of(context).pop(true);

                // Then exit app depending on platform
                // Delay a bit to ensure dialog has closed
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (kIsWeb) {
                    // On web we can't close the tab; just do nothing or navigate away
                    // Optionally show a Snackbar
                  } else {
                    try {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop(); // recommended on Android
                      } else if (Platform.isIOS) {
                        // iOS discourages programmatic exit. Best practice: pop until root
                        // You can call exit(0) but it's not recommended by Apple.
                        // We'll attempt to pop the navigator:
                        Navigator.of(context, rootNavigator: true).pop();
                      } else {
                        // For other desktop platforms, exit:
                        exit(0);
                      }
                    } catch (e) {
                      // Fallback
                      exit(0);
                    }
                  }
                });
              },
              child: Text('Yes', style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  static void openDialog(void Function()? onPressed) {
    Get.dialog(
      AlertDialog(
        title: Text("AppTranslations.sebaghar.tr"),
        content: Text("AppTranslations.yourAreNotOldPatient.tr"),
        actions: [
          // TextButton(
          //   onPressed: () => Get.back(),
          //   child: Text(AppTranslations.no.tr),
          // ),
          TextButton(
            onPressed: onPressed,
            child: Text("AppTranslations.ok.tr"),
          ),
        ],
      ),
    );
  }

  static String? formatedStartDate() {
    DateTime now = DateTime.now();

    // Calculate the date one month ago
    // DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    DateTime sevenDaysAgo = now.subtract(Duration(days: 6));

    // Format the dates for display
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    printLog(formattedStartDate);
    printLog("formattedStartDate=======");
    return formattedStartDate;
  }

  static String? formatedEndDate() {
    DateTime now = DateTime.now();

    // Format the dates for display
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(now);
    printLog(formattedEndDate);
    printLog("formattedEndDate=======");
    return formattedEndDate;
    //
  }



  static void openUpdateProfileDialog() {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      width: AppDismens.size30,
                      height: AppDismens.size30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red,
                      ),
                      child: Center(
                        child: Icon(Icons.close, color: AppColors.white, size: AppDismens.size24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Profile update coming soon."),
                SizedBox(height: AppDismens.size20),
              ],
            ),
          ),
        ),
      ),
    );
  }






  static void openDialogDatePickRange() {
    Get.dialog(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          elevation: 0.0,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: AppDismens.size10),
          insetPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Column(mainAxisSize: MainAxisSize.min, children: []),
        ),
      ),
    );
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff'); // Add the alpha value if it's not included
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static AppBar customAppBar({
    String? title,
    bool? search,
    bool? appointmentBack,
    onPressed,
    bool? searchDoctor,
    closeSearch,
    searchSaved,
    hintText,
    enabled,
    editController,
    keyboardType,
    clearSearch,
    prescription,
    downloadPress,
    eyePress,
    onchangeSearch,
  }) {
    return AppBar(
      // systemOverlayStyle:
      //     const SystemUiOverlayStyle(statusBarColor: Colors.orange),
      backgroundColor: Get.theme.primaryColor,
      centerTitle: false,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      title: searchDoctor == true
          ? Row(
              children: [
                IconButton(
                  onPressed: closeSearch,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Get.theme.iconTheme.color,
                  ),
                ),
                //change
                Flexible(
                  child: TextFormField(
                    keyboardType: keyboardType,
                    controller: editController,
                    autofocus: true,
                    onChanged: onchangeSearch,
                    enabled: enabled,
                    cursorColor: AppColors.white,
                    style: TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: AppColors.white),
                      hintText: hintText,
                      border: InputBorder.none,
                    ),
                    onSaved: searchSaved,
                  ),
                ),
                IconButton(
                  onPressed: clearSearch,
                  icon: Icon(Icons.close, color: Get.theme.iconTheme.color),
                ),
              ],
            )
          : Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => appointmentBack == true
                            ? Get.offNamed(Routes.HOME)
                            : Get.back(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Get.theme.iconTheme.color,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          title!.tr,
                          style: Get.theme.appBarTheme.titleTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                search == true
                    ? IconButton(
                        onPressed: onPressed,
                        icon: Icon(
                          Icons.search,
                          color: Get.theme.iconTheme.color,
                        ),
                      )
                    : prescription == true
                    ? Row(
                        children: [
                          IconButton(
                            onPressed: downloadPress,
                            icon: Icon(
                              Icons.cloud_download,
                              color: Get.theme.iconTheme.color,
                            ),
                          ),
                          IconButton(
                            onPressed: eyePress,
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Get.theme.iconTheme.color,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
    );
  }

  static openSuccessDialog() {
    Get.dialog(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
        child: AlertDialog(
          //title: const Text('Are Yor Sure?'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          elevation: 0.0,
          titlePadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: AppDismens.size10),
          actionsPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
            width: Get.width - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpace.spaceH20,
                Image.asset(
                  AppAssets.success_submit,
                  height: AppDismens.size100,
                  width: AppDismens.size100,
                ),
                AppSpace.spaceH10,
                Text(
                  "Submit Successful!",
                  style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: AppColors.normalGreen,
                    fontSize: AppDismens.size16,
                  ),
                ),
                AppSpace.spaceH10,
                Text(
                  textAlign: ui.TextAlign.center,
                  "Thank you for uploading your verification documents.Your account is being verified.you will be notified within 24 hours",
                  style: TextStyle(
                    color: AppColors.hash,
                    fontSize: AppDismens.size14,
                  ),
                ),
                AppSpace.spaceH10,
                CustomPhoneButton(
                  btnBackground: AppColors.appColorSecond,
                  borderColor: AppColors.appColorSecond,
                  title: "Back To Home",
                  onTap: () {
                    Get.offAndToNamed(Routes.HOME);
                  },
                ),
                AppSpace.spaceH20,
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static openSuccessConfirmExchangeDialog() {
    Get.dialog(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
        child: AlertDialog(
          //title: const Text('Are Yor Sure?'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          elevation: 0.0,
          titlePadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: AppDismens.size10),
          actionsPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
            width: Get.width - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpace.spaceH20,
                Image.asset(
                  AppAssets.success_submit,
                  height: AppDismens.size100,
                  width: AppDismens.size100,
                ),
                AppSpace.spaceH10,
                Text(
                  "Submit Successful!",
                  style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: AppColors.normalGreen,
                    fontSize: AppDismens.size16,
                  ),
                ),
                // AppSpace.spaceH10,
                // Text(
                //   textAlign: ui.TextAlign.center,
                //   "Thank you for uploading your verification documents.Your account is being verified.you will be notified within 24 hours",
                //   style: TextStyle(
                //       color: AppColors.hash, fontSize: AppDismens.size14),
                // ),
                AppSpace.spaceH10,
                CustomPhoneButton(
                  btnBackground: AppColors.appColorSecond,
                  borderColor: AppColors.appColorSecond,
                  title: "Back To Home",
                  onTap: () {
                    Get.toNamed(Routes.HOME);
                  },
                ),
                AppSpace.spaceH20,
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static BoxDecoration createButtonDecoration({double? radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? 0.0),
      // border: Border.all(
      //   color: Colors.black26,
      // ),
      color: AppColors.grey.withValues(alpha: 0.13),
      // boxShadow: [
      //   BoxShadow(
      //     color: AppColors.grey.withValues(alpha: 0.2),
      //     spreadRadius: 1,
      //     blurRadius: 2,
      //     offset: const Offset(0, 0), // changes position of shadow
      //   ),
      // ]
    );
  }

  static BoxDecoration customCircularDecoretion(
    BuildContext context,
    Color? color,
    double value,
  ) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(value),
    );
  }

  static BoxDecoration createDropdownButtonDecoration({double? radius}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? 0.0),
      // border: Border.all(
      //   color: Colors.black26,
      // ),
      color: AppColors.white,
      // boxShadow: [
      //   BoxShadow(
      //     color: AppColors.grey.withValues(alpha: 0.2),
      //     spreadRadius: 1,
      //     blurRadius: 2,
      //     offset: const Offset(0, 0), // changes position of shadow
      //   ),
      // ]
    );
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static void snackbarForErorr({
    required String titleText,
    required String bodyText,
    double? topMargin,
  }) {
    Get.snackbar(
      titleText,
      bodyText,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.only(
        top: topMargin ?? Get.height * 0.0,
        left: Get.width * 0.05,
        right: Get.width * 0.05,
      ),
      backgroundColor: AppColors.red.withValues(alpha: 0.9),
      colorText: AppColors.white,
    );
  }

  static void toastError(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: AppColors.red,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  static void toastWarn(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: AppColors.yellow,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  static void toastSuccess(String error) async {
    await Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: AppColors.normalGreen,
      textColor: AppColors.white,
      fontSize: 16.0,
    );
  }

  static void snackBarForSuccess({
    dynamic titleText,
    dynamic bodyText,
    double? topMargin,
  }) {
    Get.snackbar(
      titleText,
      bodyText,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.only(
        top: topMargin ?? Get.height * 0.0,
        left: Get.width * 0.05,
        right: Get.width * 0.05,
      ),
      // backgroundColor: fromHex('#E9A9AF'),
      backgroundColor: AppColors.black,
      colorText: AppColors.white,
    );
  }

  static void showSnackBarBuild({
    required BuildContext context,
    required String message,
  }) {
    final snackBar = SnackBar(
      backgroundColor: Get.theme.primaryColor,
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void snackbarForErorr2({
    String? titleText,
    required String bodyText,
    double? topMargin,
  }) {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Text(
        bodyText,
        style: const TextStyle(color: AppColors.white, fontSize: 15),
      ),
      snackPosition: SnackPosition.TOP,
      maxWidth: Get.width * 0.7,
      padding: const EdgeInsets.only(bottom: 15, left: 12, right: 10, top: 5),
      margin: EdgeInsets.only(
        top: 25,
        left: Get.width * 0.05,
        right: Get.width * 0.05,
      ),
      borderRadius: 4,
      backgroundColor: AppColors.red.withValues(alpha: 0.9),
      colorText: AppColors.white,
    );
  }

  static Future<void> snackBarForSuccess2({
    String? titleText,
    required String bodyText,
    double? topMargin,
  }) async {
    Get.snackbar(
      "",
      "",
      titleText: const SizedBox.shrink(),
      messageText: Text(
        bodyText,
        style: const TextStyle(color: AppColors.white, fontSize: 15),
      ),
      snackPosition: SnackPosition.TOP,
      maxWidth: Get.width * 0.7,
      padding: const EdgeInsets.only(bottom: 15, left: 12, right: 10, top: 5),
      margin: EdgeInsets.only(
        top: 25,
        left: Get.width * 0.05,
        right: Get.width * 0.05,
      ),
      borderRadius: 4,
      backgroundColor: AppColors.secondaryColor.withOpacity(0.9),
      colorText: AppColors.white,
    );
  }

  //Time Of Day
  static Future dayOfTime(BuildContext context) async {
    final TimeOfDay? timePicker = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: Get
                  .theme
                  .primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
              // style: TextButton.styleFrom(
              //   primary: Colors.w, // button text color
              // ),
            ),
          ),
          child: child!,
        );
      },
    );

    return '${int.parse(timePicker!.hourOfPeriod.toString().split('.')[0]) <= 9 ? "0${int.parse(timePicker!.hourOfPeriod.toString().split('.')[0])}" : int.parse(timePicker!.hourOfPeriod.toString().split('.')[0])} :${timePicker.minute <= 9 ? "0${timePicker.minute}" : timePicker.minute} ${timePicker.period.toString().split('.')[1]}';
  }

  //Time Of Day
  static Future dayOfTimeDiagonstic(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: Get
                  .theme
                  .primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
              // style: TextButton.styleFrom(
              //   primary: Colors.w, // button text color
              // ),
            ),
          ),
          child: child!,
        );
      },
    );

    return '$selectedDate';
  }

  // Date picker
  static Future<String?> datePickerShow([String? dateFormat]) async {
    final DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: Get.overlayContext!,
      initialDate: now, // ✅ default selected current date
      firstDate: DateTime(1900), // disallow past dates
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.appColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor, // selected date background
              onPrimary: AppColors.white, // selected date text
              surface: AppColors.white, // calendar background
              onSurface: AppColors.black, // normal date text
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      return DateFormat(dateFormat ?? 'yyyy-MM-dd').format(pickedDate);
    }
    return null;
  }

  // Date picker
  static Future<String?> datePickerShowKyc([String? dateFormate]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.appColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: AppColors
                  .appColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
              // style: TextButton.styleFrom(
              //   primary: Colors.w, // button text color
              // ),
            ),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      // initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(
        dateFormate ?? 'yyyy-MM-dd',
      ).format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  // Date picker filter
  static Future<String?> datePickerFilterShow([String? dateFormate]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.appColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: AppColors
                  .appColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
              // style: TextButton.styleFrom(
              //   primary: Colors.w, // button text color
              // ),
            ),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      // initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(
        dateFormate ?? 'dd-MM-yyyy',
      ).format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  // Date picker filter
  static Future<String?> datePickerFilterPurcahse([String? dateFormate]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: AppColors.appColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: AppColors
                  .appColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: const TextButtonThemeData(
              // style: TextButton.styleFrom(
              //   primary: Colors.w, // button text color
              // ),
            ),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      //DateTime.now() - not to allow to choose before today.
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(
        dateFormate ?? 'yyyy-MM-dd',
      ).format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      barrierDismissible: false,
      helpText: "AppTranslations.selectDate.tr",
      cancelText: "AppTranslations.cancel.tr",
      confirmText: "AppTranslations.ok.tr",
      // locale: Locale( StorageService.read(StorageConstants.languageCode) ?? AppConst.langCodeEn),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: Get.theme.primaryColor,
              headerForegroundColor: AppColors.white,
              backgroundColor: AppColors.white,
            ),
            colorScheme: ColorScheme.light(
              primary: Get.theme.primaryColor,
              // <-- SEE HERE  onPrimary: AppColors.white, // <-- SEE HERE
              onSecondary: Get
                  .theme
                  .primaryColor, // <-- SEE HERE  secondary: Get.theme.primaryColor, // <-- SEE HERE
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.primaryColor,
                ),
                foregroundColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.white,
                ),
                overlayColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.primaryColor,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      barrierDismissible: false,
      cancelText: " AppTranslations.cancel.tr",
      confirmText: "AppTranslations.ok.tr",
      helpText: "AppTranslations.selectDate.tr",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // This uses the _timePickerTheme defined above
            timePickerTheme: timePickerTheme,
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.primaryColor,
                ),
                foregroundColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.white,
                ),
                overlayColor: MaterialStateColor.resolveWith(
                  (states) => AppColors.primaryColor,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    var result = selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
    return result;
  }

  static final timePickerTheme = TimePickerThemeData(
    // backgroundColor: AppColors.secondaryColor,
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: AppColors.primaryColor, width: 2),
    ),
    dayPeriodBorderSide: BorderSide(color: AppColors.primaryColor, width: 4),
    // dayPeriodColor: Colors.blueGrey.shade600,
    // shape:  RoundedRectangleBorder(
    //   borderRadius:const BorderRadius.all(Radius.circular(8)),
    //   side: BorderSide(color:  AppColors.primaryColor, width: 2),
    // ),
    // dayPeriodTextColor: AppColors.white,
    // dayPeriodShape:  RoundedRectangleBorder(
    //   borderRadius:const BorderRadius.all(Radius.circular(8)),
    //   side: BorderSide(color:  AppColors.primaryColor, width: 4),
    // ),
    hourMinuteColor: MaterialStateColor.resolveWith(
      (states) => states.contains(MaterialState.selected)
          ? AppColors.primaryColor
          : Colors.blueGrey.shade200,
    ),
    hourMinuteTextColor: MaterialStateColor.resolveWith(
      (states) => states.contains(MaterialState.selected)
          ? AppColors.white
          : AppColors.primaryColor,
    ),
    dialHandColor: AppColors.primaryColor,
    // dialBackgroundColor: Colors.blueGrey.shade400,
    // hourMinuteTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    // dayPeriodTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    // helpTextStyle:
    // const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.white),
    // inputDecorationTheme: const InputDecorationTheme(
    //   border: InputBorder.none,
    //   contentPadding: EdgeInsets.all(0),
    // ),
    // dialTextColor: MaterialStateColor.resolveWith(
    //         (states) => states.contains(MaterialState.selected) ? Colors.orange : AppColors.white),
    entryModeIconColor: AppColors.primaryColor,
  );

  static Future<String?> datePickerShowForBirthDay([
    String? dateFormate,
  ]) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              onSurface: AppColors.primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
            ),
          ),
          child: child!,
        );
      },
      context: Get.overlayContext!,
      initialDate: DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime(DateTime.now().year - 18),
    );

    if (pickedDate != null) {
      printLog(pickedDate);
      String formattedDate = DateFormat(
        dateFormate ?? 'yyyy-MM-dd',
      ).format(pickedDate);
      printLog(formattedDate);

      return formattedDate;
    } else {}
    return null;
  }

  static monthYear(String dateStart) {
    DateFormat inputFormat = DateFormat('dd/MM/yyyy hh:mm:ss a');
    DateTime input = inputFormat.parse(dateStart);
    String result = DateFormat('MM/yyyy').format(input);
    return result;
  }

  static String formatTime(String time) {
    String dateTime = DateFormat.jm().format(
      DateFormat("hh:mm:ss").parse(time),
    );
    return dateTime;
  }

  static String checkCardNumber(String cardnumber) {
    String number = "";
    final String stripped = cardnumber.replaceAll(RegExp(r'[^\d]'), '');
    if (stripped.length > 8) {
      final String middle = cardnumber.substring(4, 6).trim();
      final String middle1 = cardnumber
          .substring(6, cardnumber.length - 8)
          .trim()
          .replaceAll(RegExp(r'\d'), 'X');
      final String middle2 = cardnumber
          .substring(8, cardnumber.length - 4)
          .trim()
          .replaceAll(RegExp(r'\d'), 'X');
      number =
          stripped.substring(0, 4) +
          " " +
          middle +
          "" +
          middle1 +
          " " +
          middle2 +
          ' ' +
          stripped.substring(stripped.length - 4);
    }

    return number;
  }

  static String cardMaskingStart(String cardnumber) {
    String number = "";

    final String stripped = cardnumber.replaceAll(RegExp(r'[^\d]'), '');
    if (stripped.length > 8) {
      final String middle = cardnumber
          .trim()
          .substring(6, cardnumber.length - 4)
          .replaceAll(RegExp(r'\d'), '*')
          .replaceAll(" ", "");

      number =
          stripped.substring(0, 6) +
          middle +
          stripped.substring(stripped.length - 4);
    }
    return number.trim();
  }

  static void checkLogin({required VoidCallback onPressed}) {
    if (StorageService.read(StorageConstants.userInfo) == null) {
      Helpers.openAuthAlertDialog(() {
        //Get.offAndToNamed(Routes.LOGIN);
      });
    } else {
      onPressed();
    }
  }

  static openAuthAlertDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        //title: const Text('Are Yor Sure?'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 0.0,
        titlePadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpace.spaceH30,
            Text(
              "AppTranslations.youUstLoginDoYouAgree.tr",
              textAlign: TextAlign.center,
            ),
            AppSpace.spaceH10,
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey300,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.no.tr",
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                  AppSpace.spaceW20,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.yes.tr",
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpace.spaceH10,
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static openLogoutAlertDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        //title: const Text('Are Yor Sure?'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 0.0,
        titlePadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpace.spaceH30,
            Text("AppTranslations.areYouSure.tr", textAlign: TextAlign.center),
            AppSpace.spaceH10,
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey300,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.no.tr",
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                  AppSpace.spaceW20,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.yes.tr",
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpace.spaceH10,
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static openDeleteAlertDialog(VoidCallback? onPressed) {
    Get.dialog(
      AlertDialog(
        //title: const Text('Are Yor Sure?'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 0.0,
        titlePadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpace.spaceH30,
            Text("AppTranslations.areYouSure.tr", textAlign: TextAlign.center),
            AppSpace.spaceH10,
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey300,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.no.tr",
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                  ),
                  AppSpace.spaceW20,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                      ),
                      child: Text(
                        "AppTranslations.yes.tr",
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpace.spaceH10,
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static openWelcomeDialog() {
    Get.dialog(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
        child: AlertDialog(
          //title: const Text('Are Yor Sure?'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          elevation: 0.0,
          titlePadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: AppDismens.size10),
          actionsPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
            width: Get.width - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpace.spaceH20,
                // Image.asset(
                //   AppAssets.submitSuccess,
                //   height: AppDismens.size100,
                //   width: AppDismens.size100,
                // ),
                AppSpace.spaceH10,
                Text(
                  "Submit Successful!",
                  style: TextStyle(
                    fontWeight: ui.FontWeight.bold,
                    color: AppColors.normalGreen,
                    fontSize: AppDismens.size16,
                  ),
                ),
                AppSpace.spaceH10,
                Text(
                  textAlign: ui.TextAlign.center,
                  "Thank you for uploading your verification documents.Your account is being verified.you will be notified within 24 hours",
                  style: TextStyle(
                    color: AppColors.hash,
                    fontSize: AppDismens.size12,
                  ),
                ),
                AppSpace.spaceH10,
                CustomPhoneButton(
                  title: "Back To Home",
                  onTap: () {
                    Get.toNamed(Routes.HOME);
                  },
                ),
                AppSpace.spaceH20,
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  //passwordVisivilityMethod
  static IconButton passwordVisivilityMethod(
    void Function()? onPressed,
    bool isVisible,
  ) {
    return IconButton(
      splashColor: Colors.transparent,
      onPressed: onPressed,
      icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
    );
  }

  static String? validateEmail(String? value) {
    const pattern =
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return value!.isNotEmpty && !regex.hasMatch(value)
        ? 'Enter a valid email address'
        : null;
  }

  static Text appDiveder() {
    return Text(
      "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
      style: TextStyle(color: AppColors.grey300),
      maxLines: 1,
      overflow: TextOverflow.visible,
    );
  }

  static String handleErrorApi(Response response) {
    var statusCode = response.statusCode;
    switch (statusCode) {
      case 400:
        printLog('Bad request status code : $statusCode');
        // break;
        return "Bad request status code : $statusCode";
      case 401:
        printLog('Unauthorized status code : $statusCode');
        return "Unauthorized status code : $statusCode";
      case 404:
        printLog('Not found status code : $statusCode');
        return "Not found status code : $statusCode";
      default:
        printLog('Unknown error occurred status code : $statusCode');
        return "Unknown error occurred status code : $statusCode";
    }
  }

  static String handleErrorException(error) {
    if (error is SocketException) {
      printLog('Network error : $error');
      return "Network error : $error";
    } else if (error is TimeoutException) {
      printLog('Request timed out : $error');
      return "Request timed out : $error";
    } else {
      printLog('Unknown error $error');
      return "Unknown error : $error";
    }
  }

  static void openDialogChooseImage({
    VoidCallback? onTapGallery,
    VoidCallback? onTapCamera,
  }) {
    Get.dialog(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDismens.size20),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          elevation: 0.0,
          titlePadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: AppDismens.size10),
          actionsPadding: EdgeInsets.zero,
          content: SizedBox(
            width: Get.width - 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppSpace.spaceH15,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Image From",
                      style: TextStyle(
                        fontWeight: ui.FontWeight.bold,
                        fontSize: AppDismens.size14,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: AppDismens.size50),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: AppDismens.size24,
                          width: AppDismens.size24,
                          decoration: BoxDecoration(
                            color: AppColors.stockOut.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDismens.size30,
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.cross,
                              height: AppDismens.size10,
                              width: AppDismens.size10,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpace.spaceH10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onTapGallery,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDismens.size10,
                            vertical: AppDismens.size5,
                          ),
                          height: AppDismens.size60,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppDismens.size10,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.image, color: AppColors.black),
                              Text("Gallery"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDismens.size10),
                    Container(),
                    Expanded(
                      child: InkWell(
                        onTap: onTapCamera,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDismens.size10,
                            vertical: AppDismens.size5,
                          ),
                          height: AppDismens.size60,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppDismens.size10,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt, color: AppColors.black),
                              Text("Camera"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDismens.size20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String generateRandomBarcode() {
    final random = Random();
    return List.generate(10, (_) => random.nextInt(10)).join();
  }

  static String getExtensionWithoutDot(String imagePath) {
    String extension = path.extension(imagePath);
    return extension.replaceFirst('.', ''); // Removes the leading dot
  }

  static Future<XFile?> picImage(ImageSource type) async {
    try {
      //imgLoader(false);
      final imagePicker = await ImagePicker().pickImage(
        source: type == ImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 500,
        maxWidth: 450,
      );
      if (imagePicker == null) return null;
      File imageTemp = File(imagePicker.path);
      // final bytes = File(imagePicker.path).readAsBytesSync();
      // String base64Image = "data:image/png;base64,${base64Encode(bytes)}";
      // String img64 = base64Image;
      // var imgDecode64 = base64Decode(base64Image);
      // printLog(" encoded image $base64Image");
      // printLog(" decoded image $imgDecode64");
      // printLog(imagePicker.path);
      // printLog(imageTemp);

      File _imageFile = File(imagePicker.path);
      //
      // // Read bytes from the file object
      Uint8List _bytes = await _imageFile.readAsBytes();

      // base64 encode the bytes
      //       String _base64String = base64.encode(_bytes);
      //
      //       var imgDecode64 = base64.decode(_base64String);
      //
      //       printWrapped(" here: ${_base64String}");
      //       printWrapped(" here is decoded image: ${imgDecode64}");

      return imagePicker;
    } on PlatformException catch (e) {
      printLog("Failed to pick image: $e");
    }
    return null;
  }

  static Future<String> convertImageToBase64(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    String base64Image = base64Encode(bytes);
    return base64Image;
  }

  static Future<File?> tokeImageForFile(ImageSource type) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imagePicker = await picker.pickImage(
        source: type == ImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (imagePicker == null) return null;
      final imageTemp = File(imagePicker.path);

      String base64Image = await convertImageToBase64(imageTemp.path);
      // final formattedBase64 =
      //     base64Image.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
      // printWrapped(base64Image);

      printLog("base64Image=======");

      return imageTemp;
    } on PlatformException catch (e) {
      printLog("Failed to pick image: $e");
    }
    return null;
  }

  static Future<File?> selectVideo() async {
    final ImagePicker picker = ImagePicker();
    // final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    final XFile? pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);
      return videoFile;
    }
    return null;
  }

  static Future<String?> saveBitmapToExtFilesDir(
    ui.Image bitmap,
    String fileName,
  ) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      return null; // Handle case where external storage is unavailable
    }
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    try {
      await file.create(recursive: true); // Ensure directory exists
      final sink = file.openWrite(mode: FileMode.write);
      await saveImageToJPEGFile(bitmap, filePath);
      await sink.flush();
      await sink.close();
      return filePath;
    } catch (e) {
      debugPrint('Error saving bitmap: $e'); // Log for debugging
      return null;
    }
  }

  static Future<void> saveImageToJPEGFile(
    ui.Image image,
    String filePath, {
    int quality = 100,
  }) async {
    Uint8List? bytes = await encodeToJpeg(image, quality);
    File(filePath).writeAsBytesSync(bytes!);
  }

  static Future<Uint8List?> encodeToJpeg(ui.Image image, int quality) async {
    try {
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        throw Exception("Failed to convert image to byte data.");
      }

      var byteList = byteData.buffer;

      img.Image imgImage = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: byteList,
      );

      return img.encodeJpg(imgImage, quality: quality);
    } catch (e) {
      print("Error encoding image to JPEG: $e");
      return null;
    }
  }

  static Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    if (await Permission.microphone.status.isDenied) {
      // showPermissionExplanation(Permission.microphone);
    } else if (await Permission.camera.status.isDenied) {
    } else {
      // Permission granted, proceed with video/audio operations
    }

    for (var entry in statuses.entries) {
      Permission permission = entry.key;
      PermissionStatus status = entry.value;

      if (status.isGranted) {
        // Permission granted, proceed with Agora operations
        print('Permission $permission granted.');
      } else if (status.isDenied) {
        // Permission denied, explain and potentially re-request
        print('Permission $permission denied.');
        // showPermissionExplanation(permission);
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, guide to app settings
        print('Permission $permission permanently denied.');
        openAppSettings();
      }
    }
    void openAppSettings2() async {
      if (await canLaunch('package:com.android.settings')) {
        await launch('package:com.android.settings');
      } else if (await canLaunch('https://itunes.apple.com/settings/general')) {
        await launch('https://itunes.apple.com/settings/general');
      } else {
        // Handle inability to launch
      }
    }
  }

  void showPermissionExplanation(Permission permission) {
    showDialog(
      context: Get.overlayContext!,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          '${permission.toString()} permission is needed for ${getPermissionExplanation(permission)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text('Go to Settings'),
          ),
          TextButton(
            onPressed: () => requestPermissions(),
            child: Text('Request Again'),
          ),
        ],
      ),
    );
  }

  String getPermissionExplanation(Permission permission) {
    // Customize explanations for different permissions
    switch (permission) {
      case Permission.microphone:
        return 'audio chat and recording';
      case Permission.camera:
        return 'video chat and sharing';
      default:
        return 'app functionality';
    }
  }

  static double decimals(double value) {
    return double.parse(value.toStringAsFixed(3));
  }

  static String format(double number) {
    // Create a number format with commas and two decimal places
    NumberFormat numberFormat = NumberFormat("#,##0.00");
    // Format the number
    String formattedNumber = numberFormat.format(number);
    return formattedNumber;
  }

  static String extractErrorMessage(dynamic response) {
    try {
      Map<String, dynamic> body;
      if (response is Map<String, dynamic>) {
        body = response;
      } else if (response is String && response.isNotEmpty) {
        final decoded = jsonDecode(response);
        body = decoded is Map<String, dynamic> ? decoded : {};
      } else {
        body = {};
      }
      if (body['errors'] is Map && (body['errors'] as Map).isNotEmpty) {
        final errors = body['errors'] as Map<String, dynamic>;
        final firstList = errors[errors.keys.first];
        if (firstList is List && firstList.isNotEmpty) {
          return firstList.first.toString();
        }
      }
      printWrapped( "Error response body: ${body['message']}");
      return body['message']?.toString() ?? 'Something went wrong';
    } catch (_) {
      return 'Something went wrong';
    }
  }
}

Widget button(
  posCon, {
  text,
  tColor = AppColors.white,
  buttonBgColor = AppColors.calulatorBtnColor,
}) {
  return Expanded(
    child: Container(
      height: 65,
      width: 60,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(AppDismens.size50),
      ),
      margin: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor, // Set the background color here
          foregroundColor: AppColors.white, // Set the text color
        ),
        onPressed: () => {posCon.onButtonClick(text)},
        child: Text(
          text,
          style: TextStyle(
            fontSize: 32,
            color: tColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

extension HexColorApp on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension StringToInt on String {
  int parseInt() {
    return int.parse(this);
  }
}

extension FancyNum on num {
  num plus(num other) => this + other;

  num times(num other) => this * other;
}

extension ExtendedString on String {
  bool get isValidName {
    return !contains(RegExp(r'[0–9]'));
  }
}

extension DateTimeFormat on DateTime {
  String get ddMMyy => DateFormat("dd-MM-yy").format(this);

  String ddMMyyyy(String formate) {
    return DateFormat(formate).format(this);
  }

  String get yyyDDmm => DateFormat("yyyy-MM-dd").format(this);

  String get mmYYYY => DateFormat("MM-yyyy").format(this);

  String get eMMMd => DateFormat('E, MMM d').format(this);

  String get mmDDyyHHmmA => DateFormat('MM/dd/yyyy hh:mm a').format(this);

  String get yyyDDmmNumber => DateFormat("yyyyMMdd").format(this);
}

extension StringExtension on String {
  String toCapitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

Widget titleTextWidget({required String text}) {
  return Text(text.tr, style: Get.textTheme.bodySmall!);
}

Widget insideBodyText({required String text}) {
  return Text(
    text,
    style: Get.textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: HexColor('#505050'),
    ),
  );
}

ButtonStyle elevatedButtonStyleCustom() => ElevatedButton.styleFrom(
  backgroundColor: Get.theme.primaryColor,
  minimumSize: Size(Get.width, 40),
  padding: const EdgeInsets.symmetric(horizontal: 2),
  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
);

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

// WillPopScopeForStopBackspace

class WillPopScopeForStopBackspace extends StatelessWidget {
  const WillPopScopeForStopBackspace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: child,
    );
  }
}

const kLOGTAG = "[print-log]";
// const kLOGENABLE = true;

printLog(dynamic data) {
  if (kDebugMode) {
    print("$kLOGTAG: ${data.toString()}");
  }
}

void printWrapped(String text) {
  final pattern = RegExp('.{5,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
