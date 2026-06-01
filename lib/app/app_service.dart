import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'core/helpers/app_helper.dart';

class AppService extends GetxService {
  bool isLogged = true;
  @override
  void onInit() {
    super.onInit();
    printLog("app services on init");
  }
}

class ConnectivityService extends GetxService {
  bool isShowingDialog = false;

  @override
  void onInit() async {
    super.onInit();
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      isShowingDialog = true;
      showDialog();
    }

    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        isShowingDialog = true;
        showDialog();
      } else {
        if (isShowingDialog) {
          Get.back();
          isShowingDialog = false;
        }
      }
    });
  }

  void showDialog() {
    Get.dialog(
      const CupertinoAlertDialog(
        title: Text(
            'Please turn on network connection to continue using this app'),
      ),
      barrierDismissible: false,
    );
  }
}

/*
final appProvider=Get.put<AppProvider>(AppProvider());
final appServices=Get.find<AppService>();
final connectivityService=Get.find<ConnectivityService>();
  @override
  void onInit()async {
    super.onInit();
    //statusBarTheme();
    // printLog(appProvider);
    printLog(appServices.hashCode);
    // printLog(connectivityService.hashCode);
    printLog('appServices.hashCode');
   await appProvider.getSpecialists();
 */
