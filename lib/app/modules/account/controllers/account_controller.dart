import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/services/notification_socket_service.dart';
import '../../../core/values/storage.dart';
import '../../../data/models/response/activity_response.dart';
import '../../../data/models/response/profile_response.dart';
import '../../../data/repositories/profile.repo.dart';
import '../../../data/services/storage.service.dart';
import '../../../routes/app_pages.dart';

class AccountController extends GetxController {
  ProfileRepository get _repo => Get.find<ProfileRepository>();
  final ImagePicker _picker = ImagePicker();

  /// The live profile from `/api/v1/users/me`. Null until the first load.
  UserProfile? profile;
  bool loading = false;
  bool saving = false;
  bool uploadingPhoto = false;

  // ---- Edit-form fields ----
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ---- Display getters (read straight off [profile]) ----
  String get fullName =>
      (profile?.fullName.trim().isNotEmpty ?? false)
          ? profile!.fullName.trim()
          : 'ServiceNin User';

  String get name {
    final parts = fullName.split(' ').where((p) => p.isNotEmpty);
    return parts.isEmpty ? 'User' : parts.first;
  }

  String get email => profile?.email ?? '';
  String get address =>
      (profile?.address?.trim().isNotEmpty ?? false) ? profile!.address!.trim() : '—';
  String? get photoUrl => profile?.photoUrl;
  bool get isVerified => profile?.isVerified ?? false;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  /// Masked phone. Prefers the server `masked_phone`, then masks the raw phone,
  /// then falls back to the stored login number.
  String get maskedPhone {
    final server = profile?.maskedPhone?.trim() ?? '';
    if (server.isNotEmpty) return server;
    final raw = (profile?.phone.trim().isNotEmpty ?? false)
        ? profile!.phone.trim()
        : (StorageService.read(StorageConstants.phoneNumber) as String? ?? '');
    if (raw.length < 7) return raw;
    final start = raw.substring(0, raw.length - 6);
    final end = raw.substring(raw.length - 3);
    return '$start•••$end';
  }

  /// Full, unmasked phone number — falls back to the stored login number.
  String get phone => (profile?.phone.trim().isNotEmpty ?? false)
      ? profile!.phone.trim()
      : (StorageService.read(StorageConstants.phoneNumber) as String? ?? '');

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

  // ---- Activity (GET /api/v1/users/me/activity) ----
  List<ActivityItem> activities = [];
  bool loadingActivity = false;
  int activityDays = 7;

  /// Fetch the recent activity feed. Defaults to the last 7 days.
  Future<void> fetchActivity({int days = 7}) async {
    activityDays = days;
    loadingActivity = true;
    update();
    try {
      final res = await _repo.fetchActivity(days: days);
      activities = res.activities;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingActivity = false;
      update();
    }
  }

  // ---- Profile API ----

  /// GET /api/v1/users/me — load the profile and seed the edit form.
  Future<void> loadProfile() async {
    loading = true;
    update();
    try {
      profile = await _repo.fetchProfile();
      _syncForm(profile!);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  /// Copy the live profile into the editable controllers/selections.
  void _syncForm(UserProfile p) {
    nameCtrl.text = p.fullName;
    emailCtrl.text = p.email;
    addressCtrl.text = p.address ?? '';
    gender = _normalizeGender(p.gender);
    if (p.bloodGroup != null && bloodGroups.contains(p.bloodGroup)) {
      bloodGroup = p.bloodGroup!;
    }
  }

  String _normalizeGender(String? g) {
    switch ((g ?? '').toLowerCase()) {
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      case 'male':
        return 'Male';
      default:
        return 'Male';
    }
  }

  /// PUT /api/v1/users/me/profile — save the edited fields, then pop back.
  Future<void> saveProfile() async {
    if (saving) return;
    final fullName = nameCtrl.text.trim();
    final emailValue = emailCtrl.text.trim();
    if (fullName.isEmpty) {
      SnackHelper.error('নাম দিন');
      return;
    }
    saving = true;
    update();
    try {
      final res = await _repo.updateProfile(
        fullName: fullName,
        email: emailValue,
        gender: gender.toLowerCase(),
        bloodGroup: bloodGroup,
        address: addressCtrl.text.trim(),
      );
      // Reflect the change locally so the profile screen is up to date.
      profile = profile?.copyWith(
        fullName: fullName,
        email: emailValue,
        gender: gender.toLowerCase(),
        bloodGroup: bloodGroup,
        address: addressCtrl.text.trim(),
      );
      saving = false;
      update();
      Get.back();
      SnackHelper.success(res.message, title: 'Profile'.tr);
    } catch (e) {
      saving = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// POST /api/v1/users/me/photo — pick from gallery and upload the avatar.
  Future<void> pickAndUploadPhoto() async {
    if (uploadingPhoto) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;
    uploadingPhoto = true;
    update();
    try {
      final res = await _repo.uploadPhoto(File(picked.path));
      if (res.success) {
        profile = profile?.copyWith(photoUrl: res.photoUrl);
        SnackHelper.success(res.message);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      uploadingPhoto = false;
      update();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    deleteInput.dispose();
    super.onClose();
  }

  // ---- Navigation ----
  void openProfile() => Get.toNamed(Routes.ACCOUNT_PROFILE);
  void openEditProfile() => Get.toNamed(Routes.ACCOUNT_EDIT);
  void openActivity() {
    fetchActivity();
    Get.toNamed(Routes.ACCOUNT_ACTIVITY);
  }
  void openSettings() => Get.toNamed(Routes.ACCOUNT_SETTINGS);
  void openPrivacy() => Get.toNamed(Routes.ACCOUNT_PRIVACY);
  void openTerms() => Get.toNamed(Routes.ACCOUNT_TERMS);
  void openDeleteAccount() => Get.toNamed(Routes.ACCOUNT_DELETE);

  void deleteAccount() {
    NotificationSocketService.instance.disconnect();
    StorageService.remove(StorageConstants.accessToken);
    Get.offAllNamed(Routes.AUTH);
  }

  void logout() {
    NotificationSocketService.instance.disconnect();
    StorageService.remove(StorageConstants.accessToken);
    Get.offAllNamed(Routes.AUTH);
  }
}
