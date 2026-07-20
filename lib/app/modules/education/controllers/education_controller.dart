import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/education_response.dart';
import '../../../data/repositories/education.repo.dart';
import '../../../routes/app_pages.dart';

class EducationController extends GetxController {
  EducationRepository get _repo => Get.find<EducationRepository>();

  // ── Institute types (admin-managed) ──────────────────────────────────
  // Index 0 is a synthetic "All" entry; API institute types follow.
  List<EduInstituteType> instituteTypes = [];
  bool loadingInstituteTypes = false;
  int typeIndex = 0;

  String? get _selectedInstituteTypeSlug =>
      (typeIndex > 0 && typeIndex <= instituteTypes.length)
          ? instituteTypes[typeIndex - 1].slug
          : null;

  /// Chip label at [i] — index 0 is always "All".
  String typeLabel(int i) => i == 0 ? 'All'.tr : instituteTypes[i - 1].label;

  void setInstituteType(int i) {
    typeIndex = i;
    update();
    fetchCentersNear();
  }

  // ── Centers (server-filtered by institute type) ──────────────────────
  List<EduCenter> centers = [];
  bool loadingCenters = false;

  // ── Center detail ───────────────────────────────────────────────────
  EduCenter? center;
  List<EduCourse> courses = [];
  bool loadingCourses = false;

  // ── Course / enquiry ────────────────────────────────────────────────
  EduCourse? course;

  final List<Map<String, String>> grades = const [
    {'label': 'Class 6-8', 'value': 'class_6_8'},
    {'label': 'SSC', 'value': 'ssc'},
    {'label': 'HSC', 'value': 'hsc'},
    {'label': 'Admission', 'value': 'admission'},
    {'label': 'University', 'value': 'university'},
  ];
  int gradeIndex = 2; // HSC default
  void setGrade(int i) {
    gradeIndex = i;
    update();
  }

  final TextEditingController studentName = TextEditingController();
  final TextEditingController parentContact = TextEditingController();
  final TextEditingController subjectNeeded = TextEditingController();
  final TextEditingController preferredTime = TextEditingController();
  final TextEditingController notes = TextEditingController();
  bool submitting = false;
  EduInterest? lastInterest;

  // ── My enrollments ──────────────────────────────────────────────────
  List<EduInterest> myInterests = [];
  bool loadingInterests = false;

  @override
  void onInit() {
    super.onInit();
    fetchInstituteTypes();
    fetchCentersNear();
  }

  Future<void> fetchInstituteTypes() async {
    loadingInstituteTypes = true;
    update();
    try {
      instituteTypes = await _repo.fetchInstituteTypes();
    } catch (_) {
    } finally {
      loadingInstituteTypes = false;
      update();
    }
  }

  Future<void> fetchCentersNear() async {
    loadingCenters = true;
    update();
    try {
      centers =
          await _repo.fetchCentersNear(instituteType: _selectedInstituteTypeSlug);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCenters = false;
      update();
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openCenter(EduCenter c) {
    center = c;
    courses = [];
    update();
    Get.toNamed(Routes.EDUCATION_CENTER);
    fetchCenterCourses(c.id);
  }

  Future<void> fetchCenterCourses(String centerId) async {
    loadingCourses = true;
    update();
    try {
      courses = await _repo.fetchCenterCourses(centerId);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingCourses = false;
      update();
    }
  }

  void enquire(EduCourse c) {
    course = c;
    gradeIndex = 2;
    studentName.clear();
    parentContact.clear();
    subjectNeeded.text = c.title;
    preferredTime.clear();
    notes.clear();
    update();
    Get.toNamed(Routes.EDUCATION_ENQUIRY);
  }

  Future<void> submitEnquiry() async {
    if (submitting) return;
    if (studentName.text.trim().isEmpty) {
      SnackHelper.error('শিক্ষার্থীর নাম দিন');
      return;
    }
    if (parentContact.text.trim().isEmpty) {
      SnackHelper.error('অভিভাবকের যোগাযোগ নম্বর দিন');
      return;
    }
    if (center == null || course == null) {
      SnackHelper.error('কোর্স নির্বাচন করুন');
      return;
    }
    submitting = true;
    update();
    try {
      final payload = <String, dynamic>{
        'center_id': center!.id,
        'course_id': course!.id,
        'student_name': studentName.text.trim(),
        'student_grade': grades[gradeIndex]['value'],
        'parent_contact': parentContact.text.trim(),
        if (subjectNeeded.text.trim().isNotEmpty)
          'subject_needed': subjectNeeded.text.trim(),
        if (preferredTime.text.trim().isNotEmpty)
          'preferred_time': preferredTime.text.trim(),
        if (notes.text.trim().isNotEmpty) 'notes': notes.text.trim(),
      };
      lastInterest = await _repo.registerInterest(payload);
      Get.toNamed(Routes.EDUCATION_DONE);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      submitting = false;
      update();
    }
  }

  // ── My enrollments ──────────────────────────────────────────────────
  void openMyInterests() {
    fetchMyInterests();
    Get.toNamed(Routes.EDUCATION_INTERESTS);
  }

  Future<void> fetchMyInterests() async {
    loadingInterests = true;
    update();
    try {
      myInterests = await _repo.fetchMyInterests();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingInterests = false;
      update();
    }
  }

  void backToEducation() =>
      Get.until((r) => r.settings.name == Routes.EDUCATION);

  @override
  void onClose() {
    studentName.dispose();
    parentContact.dispose();
    subjectNeeded.dispose();
    preferredTime.dispose();
    notes.dispose();
    super.onClose();
  }
}
