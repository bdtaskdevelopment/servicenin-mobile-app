import 'dart:convert';

import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

// ── Category ────────────────────────────────────────────────────────
class JobCategory {
  JobCategory({required this.name, required this.jobCount});
  final String name;
  final int jobCount;

  factory JobCategory.fromMap(Map<String, dynamic> j) => JobCategory(
        name: _str(j['category']),
        jobCount: _int(j['job_count']),
      );

  static List<JobCategory> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => JobCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Employer ────────────────────────────────────────────────────────
class JobEmployer {
  JobEmployer({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.email,
    required this.address,
    required this.isVerified,
  });
  final String id;
  final String companyName;
  final String industry;
  final String email;
  final String address;
  final bool isVerified;

  factory JobEmployer.fromMap(Map<String, dynamic> j) => JobEmployer(
        id: _str(j['id']),
        companyName: _str(j['company_name']),
        industry: _str(j['industry']),
        email: _str(j['email']),
        address: _str(j['address']),
        isVerified: j['is_verified'] == true,
      );

  static JobEmployer fromResponse(dynamic src) =>
      JobEmployer.fromMap((_data(src) as Map).cast<String, dynamic>());
}

// ── Job ─────────────────────────────────────────────────────────────
class Job {
  Job(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get title => _str(raw['title']);
  String get category => _str(raw['category']);
  String get jobType => _str(raw['job_type']);
  String get workplaceType => _str(raw['workplace_type']);
  int get vacancyCount => _int(raw['vacancy_count']);
  String get location => _str(raw['location']);
  int get salaryMin => _int(raw['salary_min']);
  int get salaryMax => _int(raw['salary_max']);
  bool get salaryNegotiable => raw['salary_negotiable'] == true;
  String get description => _str(raw['description']);
  String get requirements => _str(raw['requirements']);
  String get education => _str(raw['education']);
  String get experienceRequired => _str(raw['experience_required']);
  String get deadline => _str(raw['deadline']);
  String get status => _str(raw['status']);
  bool get isRemote => raw['is_remote'] == true;
  int get totalApplications => _int(raw['total_applications']);

  /// True when the logged-in user has already applied (job-details endpoint).
  bool get hasApplied => raw['has_applied'] == true;

  JobEmployer? get employer => raw['employer'] is Map
      ? JobEmployer.fromMap((raw['employer'] as Map).cast<String, dynamic>())
      : null;

  String get companyName => employer?.companyName ?? '';

  String get jobTypeLabel {
    final s = jobType.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  String get badge {
    final c = companyName.isNotEmpty ? companyName : title;
    final parts =
        c.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'JB';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get salaryLabel {
    if (salaryNegotiable && salaryMin == 0 && salaryMax == 0) {
      return 'Negotiable';
    }
    String f(int n) {
      if (n >= 1000) return '৳${(n / 1000).round()}k';
      return '৳$n';
    }

    if (salaryMin > 0 && salaryMax > 0) return '${f(salaryMin)}–${f(salaryMax)}';
    if (salaryMin > 0) return '${f(salaryMin)}+';
    return 'Negotiable';
  }

  String get postedLabel {
    final created = _str(raw['created_at']);
    final dt = created.isEmpty ? null : DateTime.tryParse(created)?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  List<String> get skills => requirements.isEmpty
      ? const []
      : requirements
          .split(RegExp(r'[,;]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

  factory Job.fromMap(Map<String, dynamic> j) => Job(j);

  static Job fromResponse(dynamic src) =>
      Job((_data(src) as Map).cast<String, dynamic>());

  static List<Job> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list.whereType<Map>().map((e) => Job(e.cast<String, dynamic>())).toList();
  }
}

// ── Application ─────────────────────────────────────────────────────
class JobApplicationModel {
  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.coverLetter,
    required this.expectedSalary,
    required this.status,
    required this.job,
    this.appliedAt,
  });

  final String id;
  final String jobId;
  final String coverLetter;
  final String expectedSalary;
  final String status;
  final Job? job;
  final DateTime? appliedAt;

  String get title => job?.title ?? 'Job';
  String get company => job?.companyName ?? '';

  String get appliedLabel {
    final dt = appliedAt?.toLocal();
    return dt == null ? '' : 'Applied ${DateFormat('d MMM').format(dt)}';
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> j) {
    final applied = _str(j['applied_at']);
    return JobApplicationModel(
      id: _str(j['id']),
      jobId: _str(j['job_id']),
      coverLetter: _str(j['cover_letter']),
      expectedSalary: _str(j['expected_salary']),
      status: _str(j['status']),
      job: j['job'] is Map
          ? Job((j['job'] as Map).cast<String, dynamic>())
          : null,
      appliedAt: applied.isEmpty ? null : DateTime.tryParse(applied),
    );
  }

  static List<JobApplicationModel> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => JobApplicationModel.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Resume upload ───────────────────────────────────────────────────
String jobsResumeUrlFromResponse(dynamic src) {
  final d = _data(src);
  if (d is Map) {
    for (final k in ['resume_url', 'url', 'file_url', 'cv_url']) {
      final v = _str(d[k]);
      if (v.isNotEmpty) return v;
    }
  } else if (d is String) {
    return _str(d);
  }
  return '';
}
