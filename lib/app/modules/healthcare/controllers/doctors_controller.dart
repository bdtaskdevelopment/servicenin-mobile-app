import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../routes/app_pages.dart';
import 'booking_controller.dart';
import 'healthcare_controller.dart';

class DoctorsController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

  /// Filter chips: 'All' + department specializations.
  List<String> filters = const ['All'];
  int selectedFilter = 0;

  List<HcDoctor> doctors = [];
  bool loading = false;

  @override
  void onInit() {
    super.onInit();
    _loadFilters();
    fetchDoctors();
  }

  void _loadFilters() {
    final depts = Get.find<HealthcareController>().departments;
    filters = ['All', ...depts.map((d) => d.specialization)];
  }

  String get _selectedSpecialization =>
      selectedFilter <= 0 ? '' : filters[selectedFilter];

  void selectFilter(int i) {
    selectedFilter = i;
    update();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    loading = true;
    update();
    try {
      final list = await _repo.fetchDoctors(
          specialization: _selectedSpecialization.isEmpty
              ? null
              : _selectedSpecialization);
      doctors = list.map(HcDoctor.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  List<HcDoctor> get filtered => doctors;

  /// Open the doctors screen filtered to a specialization (from a department).
  void openForSpecialization(String spec) {
    _loadFilters();
    final idx = filters.indexWhere((f) => f == spec);
    selectedFilter = idx >= 0 ? idx : 0;
    update();
    fetchDoctors();
    Get.toNamed(Routes.HC_DOCTORS);
  }

  void openDoctor(HcDoctor d) {
    Get.find<BookingController>().setDoctor(d);
    Get.toNamed(Routes.HC_DOCTOR_PROFILE);
  }
}
