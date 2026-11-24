import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/helpers/location_helper.dart';
import '../../../core/helpers/snack_helper.dart';
import '../../../data/repositories/blood.repo.dart';
import '../../../data/services/geo_search.service.dart';
import '../../../routes/app_pages.dart';

/// Drives "Become a volunteer" (স্বেচ্ছাসেবক হোন) — POST /blood/volunteers.
/// Location picking mirrors [DonorRegisterController]'s GPS-default pattern.
class BloodVolunteerController extends GetxController {
  static const List<String> groups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  static const List<String> roleKeys = [
    'blood_camp',
    'donor_management',
    'photography',
    'social_media',
    'event_organizing',
  ];
  static const Map<String, String> roleLabels = {
    'blood_camp': 'Blood camp',
    'donor_management': 'Donor management',
    'photography': 'Photography',
    'social_media': 'Social media',
    'event_organizing': 'Event organizing',
  };

  final TextEditingController fullName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController profession = TextEditingController();
  final TextEditingController donationCount = TextEditingController();

  String group = '';
  String thana = '';
  final TextEditingController ward = TextEditingController();

  double lat = 23.8103;
  double lng = 90.4125;
  String locationLabel = '';
  bool loadingLocation = false;
  int mapVersion = 0;

  final Set<String> selectedRoles = {};
  bool isDonor = false;
  String lastDonatedCategory = 'over_3_months';

  bool busy = false;

  @override
  void onInit() {
    super.onInit();
    _initDefaultLocation();
  }

  Future<void> _initDefaultLocation() async {
    loadingLocation = true;
    update();
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) return;
      lat = pos.latitude;
      lng = pos.longitude;
      mapVersion++;
      final resolved =
          await GeoSearchService.instance.reverse(LatLng(lat, lng));
      if (resolved != null && resolved.isNotEmpty) locationLabel = resolved;
    } finally {
      loadingLocation = false;
      update();
    }
  }

  void setGroup(String value) {
    group = value;
    update();
  }

  void setThana(String value) {
    thana = value;
    update();
  }

  void toggleRole(String key) {
    if (!selectedRoles.remove(key)) selectedRoles.add(key);
    update();
  }

  void setIsDonor(bool value) {
    isDonor = value;
    update();
  }

  void setLastDonatedCategory(String value) {
    lastDonatedCategory = value;
    update();
  }

  bool get isValid =>
      fullName.text.trim().isNotEmpty &&
      phone.text.trim().isNotEmpty &&
      selectedRoles.isNotEmpty;

  Future<void> submit() async {
    if (busy || !isValid) return;
    busy = true;
    update();
    try {
      final payload = <String, dynamic>{
        'full_name': fullName.text.trim(),
        'phone': phone.text.trim(),
        'blood_group': group,
        'profession': profession.text.trim(),
        'thana': thana,
        'ward': ward.text.trim(),
        'lat': lat,
        'lng': lng,
        'roles': selectedRoles.toList(),
        'is_donor': isDonor,
        'last_donated_category': lastDonatedCategory,
        if (int.tryParse(age.text.trim()) != null)
          'age': int.parse(age.text.trim()),
        if (int.tryParse(donationCount.text.trim()) != null)
          'donation_count': int.parse(donationCount.text.trim()),
      };
      final res = await Get.find<BloodRepository>().registerVolunteer(payload);
      busy = false;
      update();
      if (res.success) {
        SnackHelper.success(res.message);
        Get.until((route) => route.settings.name == Routes.BLOOD);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      busy = false;
      update();
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    fullName.dispose();
    phone.dispose();
    age.dispose();
    profession.dispose();
    donationCount.dispose();
    ward.dispose();
    super.onClose();
  }
}
