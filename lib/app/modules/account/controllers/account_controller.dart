import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/storage.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class ActivityEntry {
  const ActivityEntry({
    required this.module,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.moduleColor,
    required this.statusBg,
    required this.statusFg,
  });
  final String module;
  final String title;
  final String subtitle;
  final String status;
  final IconData icon;
  final Color moduleColor;
  final Color statusBg;
  final Color statusFg;
}

class AccountController extends GetxController {
  String get name => 'Tanzil';
  String get fullName => 'Tanzil Ahmed';
  String get email => 'tanzil@example.com';
  String get address => 'House 32, Road 11, Gulshan-2, Dhaka';

  /// Masked phone, e.g. "+880 1711-••••23".
  String get maskedPhone {
    final raw = StorageService.read(StorageConstants.phoneNumber) as String?;
    if (raw == null || raw.length < 6) return '+880 1711-***123';
    final start = raw.substring(0, 4);
    final end = raw.substring(raw.length - 2);
    return '+880 $start-***$end';
  }

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  // ---- Edit profile selections ----
  final List<String> genders = const ['Male', 'Female', 'Other'];
  String gender = 'Male';
  void setGender(String g) {
    gender = g;
    update();
  }

  final List<String> bloodGroups = const [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];
  String bloodGroup = 'B+';
  void setBloodGroup(String b) {
    bloodGroup = b;
    update();
  }

  // ---- Settings ----
  int languageIndex = 0; // 0 = Bangla, 1 = English
  void setLanguage(int i) {
    languageIndex = i;
    update();
  }

  bool pushNotifications = true;
  bool smsAlerts = true;
  void togglePush(bool v) {
    pushNotifications = v;
    update();
  }

  void toggleSms(bool v) {
    smsAlerts = v;
    update();
  }

  // ---- Delete account confirm ----
  final TextEditingController deleteInput = TextEditingController();
  bool get canDelete => deleteInput.text.trim().toUpperCase() == 'DELETE';
  void onDeleteChanged(String _) => update();

  // ---- Activity ----
  final List<ActivityEntry> activity = const [
    ActivityEntry(
      module: 'AMBULANCE',
      title: 'ICU ambulance · United Hospital',
      subtitle: 'Today · ৳2,840',
      status: 'Completed',
      icon: Icons.airport_shuttle_rounded,
      moduleColor: Color(0xFF3B82F6),
      statusBg: Color(0xFFDCFCE7),
      statusFg: Color(0xFF15803D),
    ),
    ActivityEntry(
      module: 'HEALTHCARE',
      title: 'Dr. Salma Akter · Cardiology',
      subtitle: 'Today 3:40 PM',
      status: 'Upcoming',
      icon: Icons.medical_services_rounded,
      moduleColor: Color(0xFF14B8A6),
      statusBg: Color(0xFFDBEAFE),
      statusFg: Color(0xFF2563EB),
    ),
    ActivityEntry(
      module: 'HOME SERVICE',
      title: 'AC General Service ×2',
      subtitle: 'Today 3:00 PM',
      status: 'In progress',
      icon: Icons.home_repair_service_rounded,
      moduleColor: Color(0xFF0E9F8E),
      statusBg: Color(0xFFFEF3C7),
      statusFg: Color(0xFFB45309),
    ),
    ActivityEntry(
      module: 'BLOOD BANK',
      title: 'Donated B+ · Square Hospital',
      subtitle: '12 May',
      status: 'Completed',
      icon: Icons.water_drop_rounded,
      moduleColor: Color(0xFFE11D48),
      statusBg: Color(0xFFDCFCE7),
      statusFg: Color(0xFF15803D),
    ),
    ActivityEntry(
      module: 'NAGARIK',
      title: 'Pothole report · Road 27',
      subtitle: '3 days ago',
      status: 'In progress',
      icon: Icons.account_balance_rounded,
      moduleColor: Color(0xFFF15A24),
      statusBg: Color(0xFFFEF3C7),
      statusFg: Color(0xFFB45309),
    ),
  ];

  @override
  void onClose() {
    deleteInput.dispose();
    super.onClose();
  }

  // ---- Navigation ----
  void openProfile() => Get.toNamed(Routes.ACCOUNT_PROFILE);
  void openEditProfile() => Get.toNamed(Routes.ACCOUNT_EDIT);
  void openActivity() => Get.toNamed(Routes.ACCOUNT_ACTIVITY);
  void openSettings() => Get.toNamed(Routes.ACCOUNT_SETTINGS);
  void openPrivacy() => Get.toNamed(Routes.ACCOUNT_PRIVACY);
  void openDeleteAccount() => Get.toNamed(Routes.ACCOUNT_DELETE);

  void saveProfile() {
    Get.back();
    Get.snackbar(
      'Profile updated',
      'Your changes have been saved',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
  }

  void deleteAccount() {
    StorageService.remove(StorageConstants.accessToken);
    Get.offAllNamed(Routes.AUTH);
  }

  void logout() {
    StorageService.remove(StorageConstants.accessToken);
    Get.offAllNamed(Routes.AUTH);
  }
}
