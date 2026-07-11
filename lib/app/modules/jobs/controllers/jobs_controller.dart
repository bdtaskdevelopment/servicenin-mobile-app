import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../data/models/response/jobs_response.dart';
import '../../../data/repositories/jobs.repo.dart';
import '../../../routes/app_pages.dart';

class JobsController extends GetxController {
  JobsRepository get _repo => Get.find<JobsRepository>();

  // ── Categories ──────────────────────────────────────────────────────
  List<String> categories = ['All'];
  int categoryIndex = 0;
  bool loadingCategories = false;

  String get selectedCategory =>
      (categoryIndex > 0 && categoryIndex < categories.length)
          ? categories[categoryIndex]
          : '';

  // ── Jobs list ───────────────────────────────────────────────────────
  List<Job> jobs = [];
  bool loadingJobs = false;
  bool loadingMore = false;
  bool hasMore = true;
  int _page = 1;
  static const _limit = 20;
  final TextEditingController searchCtrl = TextEditingController();
  String get search => searchCtrl.text.trim();
  Timer? _searchDebounce;

  Job? selected;
  bool loadingDetail = false;

  // ── My applications ─────────────────────────────────────────────────
  List<JobApplicationModel> applications = [];
  bool loadingApplications = false;

  // ── Job-seeker profile (POST /jobs/seekers/profile) ─────────────────
  final TextEditingController seekerName = TextEditingController();
  final TextEditingController seekerPhone = TextEditingController();
  final TextEditingController seekerEmail = TextEditingController();
  final TextEditingController seekerAddress = TextEditingController();
  final TextEditingController seekerDistrict = TextEditingController();
  final TextEditingController seekerSkills = TextEditingController();
  final TextEditingController seekerExp = TextEditingController();
  bool savingSeeker = false;

  // ── Apply flow (POST /jobs/:id/apply) ───────────────────────────────
  final TextEditingController coverLetter = TextEditingController();
  final TextEditingController expectedSalary = TextEditingController();
  final TextEditingController availability = TextEditingController();
  String resumeUrl = '';
  String resumeName = '';
  bool uploadingResume = false;
  bool applying = false;

  // ── Employer register ───────────────────────────────────────────────
  final TextEditingController empCompany = TextEditingController();
  final TextEditingController empContact = TextEditingController();
  final TextEditingController empPhone = TextEditingController();
  final TextEditingController empEmail = TextEditingController();
  final TextEditingController empAddress = TextEditingController();
  final TextEditingController empIndustry = TextEditingController();
  bool registeringEmployer = false;

  // ── Post job ────────────────────────────────────────────────────────
  final TextEditingController postTitle = TextEditingController();
  final TextEditingController postLocation = TextEditingController();
  final TextEditingController postDistrict = TextEditingController();
  final TextEditingController postVacancy = TextEditingController(text: '1');
  final TextEditingController postSalaryMin = TextEditingController();
  final TextEditingController postSalaryMax = TextEditingController();
  final TextEditingController postDescription = TextEditingController();
  final TextEditingController postRequirements = TextEditingController();
  final TextEditingController postEducation = TextEditingController();
  final TextEditingController postExperience = TextEditingController();
  final TextEditingController postDeadline = TextEditingController();

  final List<String> jobTypes = const [
    'full_time', 'part_time', 'contract', 'internship'
  ];
  final List<String> workplaceTypes = const ['onsite', 'remote', 'hybrid'];
  String postCategory = '';
  String postJobType = 'full_time';
  String postWorkplace = 'onsite';
  bool postingJob = false;

  void setPostCategory(String v) {
    postCategory = v;
    update();
  }

  void setPostJobType(String v) {
    postJobType = v;
    update();
  }

  void setPostWorkplace(String v) {
    postWorkplace = v;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchJobs(reset: true);
  }

  Future<void> fetchCategories() async {
    loadingCategories = true;
    update();
    try {
      final list = await _repo.fetchCategories();
      categories = ['All', ...list.map((c) => c.name)];
      if (postCategory.isEmpty && list.isNotEmpty) {
        postCategory = list.first.name;
      }
    } catch (_) {
    } finally {
      loadingCategories = false;
      update();
    }
  }

  void setCategory(int i) {
    categoryIndex = i;
    update();
    fetchJobs(reset: true);
  }

  void onSearchSubmitted(String _) {
    _searchDebounce?.cancel();
    fetchJobs(reset: true);
  }

  /// Debounced live search as the user types.
  void onSearchChanged(String _) {
    update(); // refresh the clear (×) affordance
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 400), () => fetchJobs(reset: true));
  }

  void clearSearch() {
    searchCtrl.clear();
    _searchDebounce?.cancel();
    fetchJobs(reset: true);
  }

  Future<void> fetchJobs({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasMore = true;
    }
    loadingJobs = true;
    update();
    try {
      final list = await _repo.fetchJobs(
        category: selectedCategory,
        search: search,
        page: _page,
        limit: _limit,
      );
      jobs = list;
      hasMore = list.length >= _limit;
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingJobs = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || loadingJobs || !hasMore) return;
    loadingMore = true;
    update();
    try {
      _page += 1;
      final list = await _repo.fetchJobs(
        category: selectedCategory,
        search: search,
        page: _page,
        limit: _limit,
      );
      jobs.addAll(list);
      hasMore = list.length >= _limit;
    } catch (_) {
      _page -= 1;
    } finally {
      loadingMore = false;
      update();
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────
  void openJob(Job j) async {
    selected = j;
    update();
    Get.toNamed(Routes.JOBS_DETAIL);
    loadingDetail = true;
    update();
    try {
      selected = await _repo.fetchJob(j.id);
    } catch (_) {
    } finally {
      loadingDetail = false;
      update();
    }
  }

  void openApplications() {
    fetchMyApplications();
    Get.toNamed(Routes.JOBS_APPLICATIONS);
  }

  /// Open the job details for one of my applications.
  void openApplicationJob(JobApplicationModel app) {
    final job = app.job ?? Job({'id': app.jobId});
    if (job.id.isEmpty) return;
    openJob(job);
  }

  /// Whether the currently-open job is one I've already applied to (so the
  /// detail screen shows "Already applied" instead of the Apply button).
  /// Primary source is the job-details `has_applied` flag; falls back to the
  /// applications list so the state is right before the full detail loads.
  bool get selectedAlreadyApplied {
    final j = selected;
    if (j == null) return false;
    if (j.hasApplied) return true;
    return j.id.isNotEmpty && applications.any((a) => a.jobId == j.id);
  }

  Future<void> fetchMyApplications() async {
    loadingApplications = true;
    update();
    try {
      applications = await _repo.fetchMyApplications();
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loadingApplications = false;
      update();
    }
  }

  void applyToJob() {
    resumeUrl = '';
    resumeName = '';
    update();
    Get.toNamed(Routes.JOBS_APPLY);
  }

  void openPostJob() => Get.toNamed(Routes.JOBS_POST);
  void openEmployerRegister() => Get.toNamed(Routes.JOBS_EMPLOYER);
  void openSeekerProfile() => Get.toNamed(Routes.JOBS_SEEKER_PROFILE);

  // ── Job-seeker profile ──────────────────────────────────────────────
  Future<void> submitSeekerProfile() async {
    if (savingSeeker) return;
    if (seekerName.text.trim().isEmpty) {
      SnackHelper.error('Full name is required');
      return;
    }
    savingSeeker = true;
    update();
    try {
      final res = await _repo.createSeekerProfile({
        'full_name': seekerName.text.trim(),
        'phone': seekerPhone.text.trim(),
        'email': seekerEmail.text.trim(),
        'address': seekerAddress.text.trim(),
        'district': seekerDistrict.text.trim(),
        'skills': seekerSkills.text.trim(),
        'experience_years': int.tryParse(seekerExp.text.trim()) ?? 0,
      });
      if (res.success) {
        SnackHelper.success(
            res.message.isNotEmpty ? res.message : 'Profile saved');
        Get.back(closeOverlays: true);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      savingSeeker = false;
      update();
    }
  }

  // ── Resume upload ───────────────────────────────────────────────────
  Future<void> pickAndUploadResume() async {
    try {
      // The API only accepts pdf/doc/docx, so use a document picker (not an
      // image picker) restricted to those types.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
      );
      final path = result?.files.single.path;
      if (path == null) return;
      uploadingResume = true;
      update();
      final url = await _repo.uploadResume(File(path));
      if (url.isEmpty) {
        // Upload didn't return a URL — don't show a CV as attached, so the
        // required-CV check stays accurate.
        SnackHelper.error('Resume upload failed — please try again'.tr);
      } else {
        resumeUrl = url;
        resumeName = result!.files.single.name;
        SnackHelper.success('Resume uploaded'.tr);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      uploadingResume = false;
      update();
    }
  }

  // ── Submit application ──────────────────────────────────────────────
  Future<void> submitApplication() async {
    final j = selected;
    if (j == null || applying) return;
    // CV/resume is mandatory — block submission until one is uploaded.
    if (resumeUrl.isEmpty) {
      SnackHelper.error('Please upload your CV before applying'.tr);
      return;
    }
    applying = true;
    update();
    try {
      final res = await _repo.apply(j.id, {
        'cover_letter': coverLetter.text.trim(),
        'expected_salary': expectedSalary.text.trim(),
        'availability': availability.text.trim().isEmpty
            ? 'Immediate'
            : availability.text.trim(),
        'resume_url': resumeUrl,
      });
      if (res.success) {
        SnackHelper.success(
            res.message.isNotEmpty ? res.message : 'Application submitted');
        // Clear the form so a fresh application doesn't reuse stale input.
        coverLetter.clear();
        expectedSalary.clear();
        availability.clear();
        resumeUrl = '';
        resumeName = '';
        fetchMyApplications();
        Get.offNamed(Routes.JOBS_APPLICATIONS);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      applying = false;
      update();
    }
  }

  // ── Employer register ───────────────────────────────────────────────
  Future<void> registerEmployer() async {
    if (registeringEmployer) return;
    if (empCompany.text.trim().isEmpty) {
      SnackHelper.error('Company name is required');
      return;
    }
    registeringEmployer = true;
    update();
    try {
      final res = await _repo.registerEmployer({
        'company_name': empCompany.text.trim(),
        'contact_person': empContact.text.trim(),
        'phone': empPhone.text.trim(),
        'email': empEmail.text.trim(),
        'address': empAddress.text.trim(),
        'industry': empIndustry.text.trim(),
      });
      if (res.success) {
        SnackHelper.success(
            res.message.isNotEmpty ? res.message : 'Employer registered');
        Get.back(closeOverlays: true);
      } else {
        SnackHelper.error(res.message);
      }
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      registeringEmployer = false;
      update();
    }
  }

  // ── Post a job ──────────────────────────────────────────────────────
  Future<void> publishJob() async {
    if (postingJob) return;
    if (postTitle.text.trim().isEmpty) {
      SnackHelper.error('Job title is required');
      return;
    }
    postingJob = true;
    update();
    try {
      final payload = <String, dynamic>{
        'title': postTitle.text.trim(),
        'category': postCategory,
        'job_type': postJobType,
        'workplace_type': postWorkplace,
        'location': postLocation.text.trim(),
        'district': postDistrict.text.trim(),
        'vacancy_count': int.tryParse(postVacancy.text.trim()) ?? 1,
        'salary_min': int.tryParse(postSalaryMin.text.trim()) ?? 0,
        'salary_max': int.tryParse(postSalaryMax.text.trim()) ?? 0,
        'description': postDescription.text.trim(),
        'requirements': postRequirements.text.trim(),
        'education': postEducation.text.trim(),
        'experience_required': postExperience.text.trim(),
        'deadline': postDeadline.text.trim(),
      };
      await _repo.postJob(payload);
      SnackHelper.success('Job posted');
      fetchJobs(reset: true);
      Get.until((r) => r.settings.name == Routes.JOBS);
    } catch (e) {
      SnackHelper.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      postingJob = false;
      update();
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    for (final c in [
      searchCtrl, seekerName, seekerPhone, seekerEmail, seekerAddress,
      seekerDistrict, seekerSkills, seekerExp, coverLetter, expectedSalary,
      availability,
      empCompany, empContact, empPhone, empEmail, empAddress, empIndustry,
      postTitle, postLocation, postDistrict, postVacancy, postSalaryMin,
      postSalaryMax, postDescription, postRequirements, postEducation,
      postExperience, postDeadline,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
