import 'dart:core';

import 'package:servicenin/app/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:get/get.dart';

import 'core/values/storage.dart';
import 'data/services/storage.service.dart';

class AppController extends GetxController implements GetxService {
  static AppController get to => Get.find();

  @override
  void onInit() async {
    super.onInit();
  }

  Future<bool> checkInternetConnection() async {
    final List<connectivity.ConnectivityResult> connectivityResult =
        await (connectivity.Connectivity().checkConnectivity());

    if (GetPlatform.isAndroid) {
      if (connectivityResult.contains(connectivity.ConnectivityResult.mobile)) {
        return true;
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.wifi)) {
        return true;
      } else {
        return false;
      }
    } else {
      if (connectivityResult.contains(connectivity.ConnectivityResult.mobile)) {
        return true;
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.wifi)) {
        return true;
      } else if (connectivityResult.contains(connectivity.ConnectivityResult.vpn)) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> logoutApp() async {
    await StorageService.remove(StorageConstants.accessToken);
    await StorageService.remove(StorageConstants.userInfo);
    await StorageService.remove(StorageConstants.languageCode);
    await StorageService.remove(StorageConstants.phoneCode);
    await StorageService.remove(StorageConstants.phoneNumber);
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed(Routes.SPLASH);
    });
  }

  Future<void> accountDeleteRequest() async {
    await StorageService.remove(StorageConstants.accessToken);
    await StorageService.remove(StorageConstants.userInfo);
    await StorageService.remove(StorageConstants.languageCode);
    await StorageService.remove(StorageConstants.phoneCode);
    await StorageService.remove(StorageConstants.phoneNumber);
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed(Routes.SPLASH);
    });
  }
}
