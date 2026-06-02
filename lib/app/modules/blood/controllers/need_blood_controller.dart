import 'package:flutter/material.dart';
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

  // When the blood is needed.
  String neededDate = 'Today · ASAP';
  void setNeededDate(String value) {
    neededDate = value;
    update();
  }

  // Contact details.
  final TextEditingController name =
      TextEditingController(text: 'Tanzil Ahmed');
  final TextEditingController email =
      TextEditingController(text: 'tanzil@example.com');
  final TextEditingController phone =
      TextEditingController(text: '01711-XXXXXX');
  final TextEditingController address =
      TextEditingController(text: 'House 32, Road 11, Gulshan-2, Dhaka');
  final TextEditingController description = TextEditingController();

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

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    description.dispose();
    super.onClose();
  }
}
