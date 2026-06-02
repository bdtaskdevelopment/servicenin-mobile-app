import 'package:get/get.dart';

import '../../data/models/sn_service.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../routes/app_pages.dart';

/// Central router for "All Services" taps. Maps a service to its screen;
/// services without a screen yet show a "coming soon" snackbar.
class ServiceNav {
  ServiceNav._();

  static void open(SnService service) {
    switch (service.name) {
      case 'Blood':
        Get.toNamed(Routes.BLOOD);
        break;
      case 'Ambulance':
        Get.toNamed(Routes.AMBULANCE);
        break;
      case 'Healthcare':
        Get.toNamed(Routes.HEALTHCARE);
        break;
      case 'Information':
        Get.toNamed(Routes.INFORMATION);
        break;
      case 'Home Service':
        Get.toNamed(Routes.HOME_SERVICE);
        break;
      case 'Physio':
        Get.toNamed(Routes.PHYSIO);
        break;
      case 'Matchmaking':
        Get.toNamed(Routes.MATCHMAKING);
        break;
      case 'Jobs':
        Get.toNamed(Routes.JOBS);
        break;
      case 'Funeral':
        Get.toNamed(Routes.FUNERAL);
        break;
      case 'Education':
        Get.toNamed(Routes.EDUCATION);
        break;
      case 'Nagarik Sheba':
        Get.toNamed(Routes.NAGARIK);
        break;
      case 'More':
        // Not a page — jump the dashboard to the "Services" tab.
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changeTab(1);
        }
        break;
      default:
        Get.snackbar(
          service.name,
          'শীঘ্রই আসছে',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}
