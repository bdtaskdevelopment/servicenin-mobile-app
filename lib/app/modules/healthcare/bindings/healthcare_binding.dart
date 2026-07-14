import 'package:get/get.dart';

import '../controllers/appointments_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/centers_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/doctors_controller.dart';
import '../controllers/healthcare_controller.dart';
import '../controllers/prescription_controller.dart';

class HealthcareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthcareController>(() => HealthcareController(), fenix: true);
    Get.lazyPut<HealthcareCentersController>(() => HealthcareCentersController(),
        fenix: true);
    Get.lazyPut<AppointmentsController>(() => AppointmentsController(),
        fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<PrescriptionController>(() => PrescriptionController(),
        fenix: true);
    Get.lazyPut<DoctorsController>(() => DoctorsController(), fenix: true);
    Get.lazyPut<BookingController>(() => BookingController(), fenix: true);
  }
}
