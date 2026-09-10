import 'package:get/get.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/auth_response.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Request location permission / fix in the background. This must NOT
    // block reaching the login page — a denied dialog or a slow GPS fix
    // would otherwise stall first launch. The app can re-ask for it later,
    // wherever a location-dependent feature is actually used.
    LocationService.getCurrentPosition();
    Future.delayed(const Duration(seconds: 3), () {
      final String? token = StorageService.read(StorageConstants.accessToken);
      if (token == null) {
        Get.offAndToNamed(Routes.AUTH);
      } else if (AuthUser.fromStorage()?.isProvider == true) {
        Get.offAndToNamed(Routes.HS_PROVIDER);
      } else {
        Get.offAndToNamed(Routes.HOME);
      }
    });
  }
}
