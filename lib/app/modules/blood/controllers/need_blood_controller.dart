import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/values/storage.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';
import 'blood_controller.dart';

class NeedBloodController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String group = 'O+';
  int units = 2;
  BloodSeverity severity = BloodSeverity.critical;

  bool busy = false;

  // When the blood is needed.
  DateTime? neededAt;
  String neededDate = 'Today · ASAP';

  /// API date, e.g. "2026-06-10" (defaults to today if not picked).
  String get neededAtIso {
    final d = neededAt ?? DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  void setNeeded(DateTime d) {
    neededAt = d;
    neededDate = '${d.day} ${_months[d.month - 1]} ${d.year}';
    update();
  }

  // Hospital — user enters these. lat/lng auto-detected (GPS) in a full build.
  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController hospitalAddress = TextEditingController();
  double lat = 23.8103;
  double lng = 90.4125;

  // Contact details — prefilled from the logged-in user's saved info
  // (name/email/phone). Fields not present in user info stay empty.
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final raw = StorageService.read(StorageConstants.userInfo);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        name.text = m['name']?.toString() ?? '';
        email.text = m['email']?.toString() ?? '';
        phone.text = m['phone']?.toString() ?? '';
      } catch (_) {
        // Leave fields empty if the stored info can't be parsed.
      }
    }
  }

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

  Future<void> broadcast() async {
    // Required fields: blood_group, units_needed, hospital_name.
    if (hospitalName.text.trim().isEmpty) {
      SnackHelper.error('হাসপাতালের নাম দিন');
      return;
    }
    if (busy) return;
    busy = true;
    update();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final payload = <String, dynamic>{
        'blood_group': group,
        'units_needed': units,
        'urgency': severity.name, // critical / urgent / routine
        'needed_at': neededAtIso,
        'hospital_name': hospitalName.text.trim(),
        'hospital_address': hospitalAddress.text.trim(),
        'lat': lat,
        'lng': lng,
        'contact_name': name.text.trim(),
        'contact_email': email.text.trim(),
        'contact_phone': phone.text.trim(),
        'contact_address': address.text.trim(),
        'notes': description.text.trim(),
      };
      final res = await Get.find<BloodRepository>().createRequest(payload);
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        Get.toNamed(Routes.BLOOD_FINDING);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    hospitalName.dispose();
    hospitalAddress.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    description.dispose();
    super.onClose();
  }
}
