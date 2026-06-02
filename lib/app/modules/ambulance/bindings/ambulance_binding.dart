import 'package:get/get.dart';

import '../controllers/ambulance_controller.dart';
import '../controllers/ambulance_notifications_controller.dart';
import '../controllers/emergency_contacts_controller.dart';
import '../controllers/emergency_controller.dart';
import '../controllers/fare_controller.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/select_ambulance_controller.dart';

class AmbulanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AmbulanceController>(() => AmbulanceController(), fenix: true);
    Get.lazyPut<EmergencyController>(() => EmergencyController(), fenix: true);
    Get.lazyPut<EmergencyContactsController>(
        () => EmergencyContactsController(),
        fenix: true);
    Get.lazyPut<ScheduleController>(() => ScheduleController(), fenix: true);
    Get.lazyPut<FareController>(() => FareController(), fenix: true);
    Get.lazyPut<SelectAmbulanceController>(() => SelectAmbulanceController(),
        fenix: true);
    Get.lazyPut<AmbulanceNotificationsController>(
        () => AmbulanceNotificationsController(),
        fenix: true);
  }
}
