import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'blood_controller.dart';

class NeedBloodController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  String group = 'O+';
  int units = 2;
  BloodSeverity severity = BloodSeverity.critical;

  // Pre-filled details (from GPS / profile in a real build).
  final String hospital = 'Square Hospital, Panthapath';
  final String patientLocation = 'GPS · West Panthapath, Dhaka';
  final String contactPerson = 'Tanzil Ahmed · 01711-***123';

  void setGroup(String value) {
    group = value;
    update();
  }

  void setSeverity(BloodSeverity value) {
    severity = value;
    update();
  }

  void incUnits() {
    if (units < 10) {
      units++;
      update();
    }
  }

  void decUnits() {
    if (units > 1) {
      units--;
      update();
    }
  }

  void broadcast() {
    Get.toNamed(Routes.BLOOD_FINDING);
  }
}
