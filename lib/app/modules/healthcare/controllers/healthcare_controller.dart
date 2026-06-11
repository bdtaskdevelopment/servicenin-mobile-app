import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/healthcare_response.dart';
import '../../../data/repositories/healthcare.repo.dart';
import '../../../routes/app_pages.dart';
import 'doctors_controller.dart';

/// Icon + accent colour for a department, chosen from its specialization name.
(IconData, Color) hcDeptStyle(String spec) {
  switch (spec.toLowerCase()) {
    case 'cardiology':
      return (Icons.favorite, const Color(0xFFE11D48));
    case 'gynecology':
    case 'gynaecology':
      return (Icons.female_rounded, const Color(0xFFEC4899));
    case 'pediatrics':
    case 'paediatrics':
      return (Icons.child_care_rounded, const Color(0xFF14B8A6));
    case 'orthopedics':
    case 'orthopaedics':
      return (Icons.accessibility_new_rounded, const Color(0xFF0F766E));
    case 'dermatology':
      return (Icons.spa_rounded, const Color(0xFFF59E0B));
    case 'ent':
    case 'otolaryngology':
      return (Icons.hearing_rounded, const Color(0xFF6366F1));
    case 'neurology':
      return (Icons.psychology_rounded, const Color(0xFF7C3AED));
    case 'medicine':
    case 'general medicine':
      return (Icons.medical_services_rounded, const Color(0xFF0F172A));
    case 'psychiatry':
      return (Icons.self_improvement_rounded, const Color(0xFF0EA5E9));
    case 'dentistry':
    case 'dental':
      return (Icons.health_and_safety_rounded, const Color(0xFF16A34A));
    default:
      return (Icons.medical_services_outlined, const Color(0xFF16A34A));
  }
}

class HcDepartment {
  const HcDepartment(this.name, this.icon, this.color,
      {this.specialization = '', this.doctorCount = 0});
  final String name;
  final IconData icon;
  final Color color;
  final String specialization;
  final int doctorCount;

  factory HcDepartment.fromApi(Department d) {
    final style = hcDeptStyle(d.name);
    return HcDepartment(d.name, style.$1, style.$2,
        specialization: d.name, doctorCount: d.doctorCount);
  }
}

class HcDoctor {
  const HcDoctor({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.degree,
    required this.rating,
    required this.reviews,
    required this.fee,
    required this.slot,
    required this.color,
    this.video = false,
    this.id = '',
    this.isPaid = true,
  });

  final String initials;
  final String name;
  final String specialty;
  final String degree;
  final String rating;
  final int reviews;
  final String fee;
  final String slot;
  final Color color;
  final bool video;
  final String id;
  final bool isPaid;

  factory HcDoctor.fromApi(Doctor d) => HcDoctor(
        id: d.id,
        initials: d.initials,
        name: d.displayName,
        specialty: d.specialization,
        degree: d.qualifications,
        rating: d.ratingLabel,
        reviews: d.totalReviews,
        fee: d.feeLabel,
        slot: d.isAvailable ? 'Available today' : 'By schedule',
        color: const Color(0xFF16A34A),
        isPaid: d.isPaid,
      );
}

class HealthcareController extends GetxController {
  HealthcareRepository get _repo => Get.find<HealthcareRepository>();

  // In-person (0) / Video consult (1) — kept for the (hidden) mode toggle.
  int mode = 0;
  void setMode(int m) {
    mode = m;
    update();
  }

  // ── Departments ─────────────────────────────────────────────────────
  List<HcDepartment> departments = [];
  bool loadingDepartments = false;

  /// How many doctors each home-page preview section shows.
  static const int kPreviewCount = 5;

  /// Page size for the paginated "see all" screens.
  static const int kPageSize = 10;

  // ── Available-today doctors (home preview) ──────────────────────────
  List<HcDoctor> doctors = [];
  bool loadingDoctors = false;

  // ── Available-today doctors (paginated "see all" screen) ────────────
  List<HcDoctor> availableDoctors = [];
  bool loadingAvailable = false;
  bool loadingMoreAvailable = false;
  bool availableHasMore = true;
  int _availablePage = 1;
  final ScrollController availableScrollCtrl = ScrollController();

  // ── All doctors (home preview) ──────────────────────────────────────
  List<HcDoctor> allDoctors = [];
  bool loadingAllDoctors = false;

  // ── Family ──────────────────────────────────────────────────────────
  List<HcFamilyMember> family = [];
  bool loadingFamily = false;
  bool addingFamily = false;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
    fetchAvailableToday();
    fetchAllDoctors();
    fetchFamily();
    availableScrollCtrl.addListener(_onAvailableScroll);
  }

  @override
  void onClose() {
    availableScrollCtrl.removeListener(_onAvailableScroll);
    availableScrollCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchAllDoctors() async {
    loadingAllDoctors = true;
    update();
    try {
      final list = await _repo.fetchDoctors(limit: kPreviewCount);
      allDoctors = list.map(HcDoctor.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingAllDoctors = false;
      update();
    }
  }

  Future<void> fetchDepartments() async {
    loadingDepartments = true;
    update();
    try {
      final list = await _repo.fetchDepartments();
      departments = list.map(HcDepartment.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDepartments = false;
      update();
    }
  }

  Future<void> fetchAvailableToday() async {
    loadingDoctors = true;
    update();
    try {
      final list = await _repo.fetchAvailableToday(limit: kPreviewCount);
      doctors = list.map(HcDoctor.fromApi).toList();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingDoctors = false;
      update();
    }
  }

  // ── Available-today (paginated full list) ───────────────────────────
  void _onAvailableScroll() {
    final pos = availableScrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) loadMoreAvailable();
  }

  /// First page for the "Available today" see-all screen. Safe to call on
  /// every screen open — only refetches when the list is empty.
  Future<void> initAvailableList({bool force = false}) async {
    if (!force && availableDoctors.isNotEmpty) return;
    loadingAvailable = true;
    _availablePage = 1;
    availableHasMore = true;
    update();
    try {
      final list = await _repo.fetchAvailableToday(
          page: _availablePage, limit: kPageSize);
      availableDoctors = list.map(HcDoctor.fromApi).toList();
      availableHasMore = list.length >= kPageSize;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingAvailable = false;
      update();
    }
  }

  Future<void> loadMoreAvailable() async {
    if (loadingMoreAvailable || loadingAvailable || !availableHasMore) return;
    loadingMoreAvailable = true;
    update();
    try {
      final next = _availablePage + 1;
      final list =
          await _repo.fetchAvailableToday(page: next, limit: kPageSize);
      availableDoctors.addAll(list.map(HcDoctor.fromApi));
      _availablePage = next;
      availableHasMore = list.length >= kPageSize;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingMoreAvailable = false;
      update();
    }
  }

  Future<void> fetchFamily() async {
    loadingFamily = true;
    update();
    try {
      family = await _repo.fetchFamily();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingFamily = false;
      update();
    }
  }

  Future<bool> addFamilyMember({
    required String name,
    required String relation,
    required String age,
    required String gender,
    required String bloodGroup,
  }) async {
    if (addingFamily) return false;
    addingFamily = true;
    update();
    try {
      final created = await _repo.addFamilyMember({
        'name': name,
        'relation': relation,
        'gender': gender,
        'age': int.tryParse(age.trim()) ?? 0,
        'blood_group': bloodGroup,
      });
      family.add(created);
      SnackHelper.success('Family member added');
      return true;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      addingFamily = false;
      update();
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openFamily() => Get.toNamed(Routes.HEALTHCARE_FAMILY);

  /// Open the doctors list filtered to a department's specialization.
  void openDepartment(HcDepartment d) {
    Get.find<DoctorsController>().openForSpecialization(d.specialization);
  }
}
