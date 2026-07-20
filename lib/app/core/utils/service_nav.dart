import 'package:get/get.dart';

import '../../data/models/sn_service.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../routes/app_pages.dart';

/// Central router for "All Services" taps. Maps a service to its screen;
/// services without a screen yet show a "coming soon" snackbar.
class ServiceNav {
  ServiceNav._();

  /// Maps an API service `key` (from /api/v1/home/*) to its route.
  /// Used by Home (popular/recent) and Search where services come from the API.
  static void openByKey(String key) {
    switch (key) {
      case 'blood':
        Get.toNamed(Routes.BLOOD);
        break;
      case 'ambulance':
        Get.toNamed(Routes.AMBULANCE_FARE);
        break;
      case 'healthcare':
        Get.toNamed(Routes.HEALTHCARE_CENTERS);
        break;
      case 'info':
        Get.toNamed(Routes.INFORMATION);
        break;
      case 'home_service':
      case 'services':
        Get.toNamed(Routes.HOME_SERVICE);
        break;
      case 'physio':
        Get.toNamed(Routes.PHYSIO);
        break;
      case 'matchmaking':
        Get.toNamed(Routes.MATCHMAKING);
        break;
      case 'jobs':
        Get.toNamed(Routes.JOBS);
        break;
      case 'funeral':
        Get.toNamed(Routes.FUNERAL);
        break;
      case 'education':
        Get.toNamed(Routes.EDUCATION);
        break;
      case 'nagarik':
        Get.toNamed(Routes.NAGARIK);
        break;
      default:
        Get.snackbar('ServiceNin', 'শীঘ্রই আসছে',
            snackPosition: SnackPosition.BOTTOM);
    }
  }

  static void open(SnService service) {
    switch (service.name) {
      case 'Blood':
        Get.toNamed(Routes.BLOOD);
        break;
      case 'Ambulance':
        Get.toNamed(Routes.AMBULANCE_FARE);
        break;
      case 'Healthcare':
        Get.toNamed(Routes.HEALTHCARE_CENTERS);
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
      case 'Marriage':
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
      case 'Our Work':
        Get.toNamed(Routes.OUR_WORK);
        break;
      case 'Our News':
        Get.toNamed(Routes.OUR_NEWS);
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
