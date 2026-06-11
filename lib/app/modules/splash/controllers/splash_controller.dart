import 'package:get/get.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    // Ask for location permission on launch and cache the device lat/long.
    await LocationService.getCurrentPosition();
    await Future.delayed(const Duration(seconds: 3));
    final String? token = StorageService.read(StorageConstants.accessToken);
    if (token == null) {
      Get.offAndToNamed(Routes.AUTH);
    } else {
      Get.offAndToNamed(Routes.HOME);
    }
  }
}
