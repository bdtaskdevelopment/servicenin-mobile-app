import 'package:flutter/material.dart';
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

  static const int _pageSize = 10;

  List<HcDoctor> doctors = [];
  bool loading = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 1;
  final ScrollController scrollCtrl = ScrollController();

  // Text search over the loaded doctors (name / specialty / qualifications).
  final TextEditingController searchCtrl = TextEditingController();
  String query = '';
  void onSearchChanged(String v) {
    query = v;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFilters();
    fetchDoctors();
    scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMore();
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
    _page = 1;
    hasMore = true;
    update();
    try {
      final list = await _repo.fetchDoctors(
          page: _page,
          limit: _pageSize,
          specialization: _selectedSpecialization.isEmpty
              ? null
              : _selectedSpecialization);
      doctors = list.map(HcDoctor.fromApi).toList();
      hasMore = list.length >= _pageSize;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore) return;
    loadingMore = true;
    update();
    try {
      final next = _page + 1;
      final list = await _repo.fetchDoctors(
          page: next,
          limit: _pageSize,
          specialization: _selectedSpecialization.isEmpty
              ? null
              : _selectedSpecialization);
      doctors.addAll(list.map(HcDoctor.fromApi));
      _page = next;
      hasMore = list.length >= _pageSize;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingMore = false;
      update();
    }
  }

  List<HcDoctor> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return doctors;
    return doctors
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.specialty.toLowerCase().contains(q) ||
            d.degree.toLowerCase().contains(q))
        .toList();
  }

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

  @override
  void onClose() {
    scrollCtrl.removeListener(_onScroll);
    scrollCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}
