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
class EduCategory {
  EduCategory({required this.key, required this.label, required this.icon});
  final String key;
  final String label;
  final String icon;

  factory EduCategory.fromMap(Map<String, dynamic> j) => EduCategory(
        key: _str(j['key']),
        label: _str(j['label']),
        icon: _str(j['icon']),
      );

  /// Parses `{ data: { categories: [...] } }`.
  static List<EduCategory> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['categories'] is List
        ? d['categories'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => EduCategory.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Center ──────────────────────────────────────────────────────────
class EduCenter {
  EduCenter(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get name => _str(raw['name']);
  String get instituteType => _str(raw['institute_type']);
  String get contactPhone => _str(raw['contact_phone']);
  String get email => _str(raw['email']);
  String get address => _str(raw['address']);
  String get wardNo => _str(raw['ward_no']);
  String get description => _str(raw['description']);
  String get subjects => _str(raw['subjects']);
  String get targetGrades => _str(raw['target_grades']);
  bool get featured => raw['featured'] == true;

  String get typeLabel {
    final s = instituteType.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  List<String> get subjectTags => subjects
      .split(RegExp(r'[,/]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  factory EduCenter.fromMap(Map<String, dynamic> j) => EduCenter(j);

  static EduCenter fromResponse(dynamic src) =>
      EduCenter((_data(src) as Map).cast<String, dynamic>());

  static List<EduCenter> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => EduCenter(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Course ──────────────────────────────────────────────────────────
class EduCourse {
  EduCourse(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get centerId => _str(raw['center_id']);
  String get title => _str(raw['title']);
  String get description => _str(raw['description']);
  String get targetClass => _str(raw['target_class']);
  String get durationText => _str(raw['duration_text']);
  String get instructor => _str(raw['instructor']);
  int get feeAmount => _int(raw['fee_amount']);
  String get schedule => _str(raw['schedule']);
  String get status => _str(raw['status']);

  String get feeLabel => feeAmount > 0 ? '৳$feeAmount' : 'Free';

  factory EduCourse.fromMap(Map<String, dynamic> j) => EduCourse(j);

  static EduCourse fromResponse(dynamic src) =>
      EduCourse((_data(src) as Map).cast<String, dynamic>());

  static List<EduCourse> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => EduCourse(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Interest / enrollment ───────────────────────────────────────────
class EduInterest {
  EduInterest(this.raw);
  final Map<String, dynamic> raw;

  String get id => _str(raw['id']);
  String get centerId => _str(raw['center_id']);
  String get courseId => _str(raw['course_id']);
  String get studentName => _str(raw['student_name']);
  String get studentGrade => _str(raw['student_grade']);
  String get parentContact => _str(raw['parent_contact']);
  String get subjectNeeded => _str(raw['subject_needed']);
  String get preferredTime => _str(raw['preferred_time']);
  String get notes => _str(raw['notes']);
  String get status => _str(raw['status']);

  EduCenter? get center =>
      raw['center'] is Map ? EduCenter((raw['center'] as Map).cast()) : null;
  EduCourse? get course =>
      raw['course'] is Map ? EduCourse((raw['course'] as Map).cast()) : null;

  String get statusLabel {
    final s = status.replaceAll('_', ' ');
    return s.isEmpty ? 'Pending' : s[0].toUpperCase() + s.substring(1);
  }

  String get createdLabel {
    final created = _str(raw['created_at']);
    final dt = created.isEmpty ? null : DateTime.tryParse(created)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM, h:mm a').format(dt);
  }

  factory EduInterest.fromMap(Map<String, dynamic> j) => EduInterest(j);

  static EduInterest fromResponse(dynamic src) =>
      EduInterest((_data(src) as Map).cast<String, dynamic>());

  static List<EduInterest> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is List ? d : const [];
    return list
        .whereType<Map>()
        .map((e) => EduInterest(e.cast<String, dynamic>()))
        .toList();
  }
}
