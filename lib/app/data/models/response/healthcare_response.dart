import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

dynamic hcDecode(dynamic src) => src is String ? jsonDecode(src) : src;

String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);
double _dbl(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(_str(v)) ?? 0;

/// Pull `data` out of `{ success, message, data }`, or return the raw value.
dynamic _data(dynamic src) {
  final d = hcDecode(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

List _dataList(dynamic src) {
  final d = _data(src);
  return d is List ? d : const [];
}

// ── Department ──────────────────────────────────────────────────────
class Department {
  Department({required this.name, required this.doctorCount});
  final String name;
  final int doctorCount;

  factory Department.fromMap(Map<String, dynamic> j) => Department(
        name: _str(j['name']),
        doctorCount: _int(j['doctor_count']),
      );

  static List<Department> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => Department.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Healthcare Center ────────────────────────────────────────────────
class HealthcareCenter {
  const HealthcareCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.contactPhone,
    required this.doctorCount,
  });
  final String id;
  final String name;
  final String address;
  final String contactPhone;
  final int doctorCount;

  factory HealthcareCenter.fromMap(Map<String, dynamic> j) => HealthcareCenter(
        id: _str(j['id']),
        name: _str(j['name']),
        address: _str(j['address']),
        contactPhone: _str(j['contact_phone']),
        doctorCount: _int(j['doctor_count']),
      );

  static List<HealthcareCenter> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => HealthcareCenter.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Doctor ──────────────────────────────────────────────────────────
class Doctor {
  Doctor({
    required this.id,
    required this.userId,
    required this.specialization,
    required this.licenseNo,
    required this.bio,
    required this.consultationFee,
    required this.experienceYears,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    required this.isVerified,
    required this.photoUrl,
    required this.qualifications,
    required this.designation,
    required this.currentHospital,
    required this.isPaid,
    required this.fullName,
    required this.fullNameBn,
    required this.gender,
  });

  final String id;
  final String userId;
  final String specialization;
  final String licenseNo;
  final String bio;
  final int consultationFee;
  final int experienceYears;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final bool isVerified;
  final String photoUrl;
  final String qualifications;
  final String designation;
  final String currentHospital;
  final bool isPaid;
  final String fullName;
  final String fullNameBn;
  final String gender;

  String get displayName => fullName.isNotEmpty ? fullName : 'Doctor';
  String get feeLabel => consultationFee > 0 ? '৳$consultationFee' : 'Free'.tr;
  String get ratingLabel => rating.toStringAsFixed(1);

  String get initials {
    final clean =
        fullName.replaceAll(RegExp(r'^(Dr\.?|ডা\.?)\s*', caseSensitive: false), '');
    final parts =
        clean.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory Doctor.fromMap(Map<String, dynamic> j) {
    final user = j['user'] is Map ? j['user'] as Map : const {};
    final profile = user['profile'] is Map ? user['profile'] as Map : const {};
    // The doctor's profile can sit at user.profile (doctors list) or directly
    // at doctor.profile (e.g. nested inside an appointment), and the name may
    // also come as a flat field. Pick the first non-empty.
    final directProfile = j['profile'] is Map ? j['profile'] as Map : const {};
    String pickName(List<dynamic> candidates) {
      for (final c in candidates) {
        final s = _str(c);
        if (s.isNotEmpty) return s;
      }
      return '';
    }

    return Doctor(
      id: _str(j['id']),
      userId: _str(j['user_id']),
      specialization: _str(j['specialization']),
      licenseNo: _str(j['license_no']),
      bio: _str(j['bio']),
      consultationFee: _int(j['consultation_fee']),
      experienceYears: _int(j['experience_years']),
      rating: _dbl(j['rating']),
      totalReviews: _int(j['total_reviews']),
      isAvailable: j['is_available'] == true,
      isVerified: j['is_verified'] == true,
      photoUrl: _str(j['photo_url']),
      qualifications: _str(j['qualifications']),
      designation: _str(j['designation']),
      currentHospital: _str(j['current_hospital']),
      isPaid: j['is_paid'] == true,
      fullName: pickName([
        profile['full_name'],
        directProfile['full_name'],
        j['full_name'],
        j['name'],
        j['doctor_name'],
      ]),
      fullNameBn: pickName([
        profile['full_name_bn'],
        directProfile['full_name_bn'],
        j['full_name_bn'],
      ]),
      gender: pickName([profile['gender'], directProfile['gender']]),
    );
  }

  static List<Doctor> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => Doctor.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Venue / chamber ─────────────────────────────────────────────────
class Venue {
  Venue({
    required this.id,
    required this.venueName,
    required this.address,
    required this.type,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String venueName;
  final String address;
  final String type;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  String get scheduleLabel {
    final days = dayOfWeek
        .split(',')
        .map((d) => d.trim().length >= 3 ? d.trim().substring(0, 3) : d.trim())
        .where((d) => d.isNotEmpty)
        .join(' · ');
    final time = (startTime.isNotEmpty && endTime.isNotEmpty)
        ? '$startTime–$endTime'
        : '';
    return [days, time].where((s) => s.isNotEmpty).join(' · ');
  }

  factory Venue.fromMap(Map<String, dynamic> j) => Venue(
        id: _str(j['id']),
        venueName: _str(j['venue_name']),
        address: _str(j['address']),
        type: _str(j['type']),
        dayOfWeek: _str(j['day_of_week']),
        startTime: _str(j['start_time']),
        endTime: _str(j['end_time']),
      );

  static List<Venue> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => Venue.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Schedule date ───────────────────────────────────────────────────
class ScheduleDate {
  ScheduleDate({
    required this.date,
    required this.dateLabel,
    required this.dayOfWeek,
    required this.venueId,
    required this.slotDurationMin,
  });

  final String date; // "2026-06-08"
  final String dateLabel; // "Monday, 08 Jun 2026"
  final String dayOfWeek;
  final String venueId;
  final int slotDurationMin;

  /// Short label e.g. "Mon".
  String get dayShort =>
      dayOfWeek.length >= 3 ? dayOfWeek.substring(0, 3) : dayOfWeek;

  /// Day number e.g. "08".
  String get dayNum {
    final dt = DateTime.tryParse(date);
    return dt == null ? '' : DateFormat('dd MMM').format(dt);
  }

  factory ScheduleDate.fromMap(Map<String, dynamic> j) => ScheduleDate(
        date: _str(j['date']),
        dateLabel: _str(j['date_label']),
        dayOfWeek: _str(j['day_of_week']),
        venueId: _str(j['venue_id']),
        slotDurationMin: _int(j['slot_duration_min']),
      );

  static List<ScheduleDate> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => ScheduleDate.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Time slot ───────────────────────────────────────────────────────
class TimeSlot {
  TimeSlot({required this.time, required this.label, required this.isBooked});
  final String time; // "09:00"
  final String label; // "9:00 AM"
  final bool isBooked;

  factory TimeSlot.fromMap(Map<String, dynamic> j) => TimeSlot(
        time: _str(j['time']),
        label: _str(j['label']),
        isBooked: j['is_booked'] == true,
      );

  static List<TimeSlot> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => TimeSlot.fromMap(e.cast<String, dynamic>()))
      .toList();
}

// ── Family member ───────────────────────────────────────────────────
class HcFamilyMember {
  HcFamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.isSelf,
  });

  final String id;
  final String name;
  final String relation;
  final int age;
  final String gender;
  final String bloodGroup;
  final bool isSelf;

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get info => [
        if (age > 0) '${age}y',
        if (gender.isNotEmpty) gender.substring(0, 1).toUpperCase(),
        if (bloodGroup.isNotEmpty) bloodGroup,
      ].join(' · ');

  factory HcFamilyMember.fromMap(Map<String, dynamic> j) => HcFamilyMember(
        id: _str(j['id']),
        name: _str(j['name']),
        relation: _str(j['relation']),
        age: _int(j['age']),
        gender: _str(j['gender']),
        bloodGroup: _str(j['blood_group']),
        isSelf: j['is_self'] == true,
      );

  static List<HcFamilyMember> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => HcFamilyMember.fromMap(e.cast<String, dynamic>()))
      .toList();

  static HcFamilyMember fromResponse(dynamic src) =>
      HcFamilyMember.fromMap((_data(src) as Map).cast<String, dynamic>());
}

// ── Review ──────────────────────────────────────────────────────────
class DoctorReview {
  DoctorReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.patientName,
    this.createdAt,
  });

  final String id;
  final int rating;
  final String comment;
  final String patientName;
  final DateTime? createdAt;

  String get patientInitials {
    final parts = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory DoctorReview.fromMap(Map<String, dynamic> j) {
    final patient = j['patient'] is Map ? j['patient'] as Map : const {};
    final profile =
        patient['profile'] is Map ? patient['profile'] as Map : const {};
    final created = _str(j['created_at']);
    return DoctorReview(
      id: _str(j['id']),
      rating: _int(j['rating']),
      comment: _str(j['comment']),
      patientName: _str(profile['full_name']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  static List<DoctorReview> listFrom(dynamic list) => (list is List ? list : const [])
      .whereType<Map>()
      .map((e) => DoctorReview.fromMap(e.cast<String, dynamic>()))
      .toList();

  static List<DoctorReview> listFromResponse(dynamic src) =>
      listFrom(_dataList(src));
}

// ── Doctor profile (composite) ──────────────────────────────────────
class DoctorProfile {
  DoctorProfile({
    required this.doctor,
    required this.bio,
    required this.experienceYears,
    required this.totalPatients,
    required this.degrees,
    required this.venues,
    required this.reviews,
    required this.rating,
    required this.reviewsTotal,
  });

  final Doctor doctor;
  final String bio;
  final int experienceYears;
  final int totalPatients;
  final List<String> degrees;
  final List<Venue> venues;
  final List<DoctorReview> reviews;
  final double rating;
  final int reviewsTotal;

  factory DoctorProfile.fromResponse(dynamic src) {
    final d = _data(src) as Map;
    final about = d['about'] is Map ? d['about'] as Map : const {};
    final doctorMap = d['doctor'] is Map ? d['doctor'] as Map : const {};
    final reviewsMap = d['reviews'] is Map ? d['reviews'] as Map : const {};
    final reviewItems =
        reviewsMap['items'] is List ? reviewsMap['items'] as List : const [];
    final degreesRaw = d['degrees'] is List ? d['degrees'] as List : const [];
    final venuesRaw =
        doctorMap['venues'] is List ? doctorMap['venues'] as List : const [];
    // `is_paid` / `consultation_fee` may sit at the top level of the profile
    // payload rather than inside `doctor`. Fold them in so the parsed Doctor
    // reports the correct free/paid status.
    final mergedDoctor = <String, dynamic>{
      ...doctorMap.cast<String, dynamic>(),
      if (!doctorMap.containsKey('is_paid') && d.containsKey('is_paid'))
        'is_paid': d['is_paid'],
      if (!doctorMap.containsKey('consultation_fee') &&
          d.containsKey('consultation_fee'))
        'consultation_fee': d['consultation_fee'],
    };
    return DoctorProfile(
      doctor: Doctor.fromMap(mergedDoctor),
      bio: _str(about['bio']),
      experienceYears: _int(about['experience_years']),
      totalPatients: _int(about['total_patients']),
      degrees: degreesRaw.map((e) => e.toString()).toList(),
      venues: venuesRaw
          .whereType<Map>()
          .map((e) => Venue.fromMap(e.cast<String, dynamic>()))
          .toList(),
      reviews: DoctorReview.listFrom(reviewItems),
      rating: _dbl(d['rating']),
      reviewsTotal: _int(reviewsMap['total']),
    );
  }
}

// ── Appointment ─────────────────────────────────────────────────────
class HcAppointment {
  HcAppointment({
    required this.id,
    required this.doctorId,
    required this.venueId,
    required this.scheduledAt,
    required this.type,
    required this.status,
    required this.fee,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.reason,
    required this.attachmentUrl,
    required this.serialNo,
    required this.familyMemberId,
    this.doctor,
    this.venue,
    this.patientName = '',
  });

  final String id;
  final String doctorId;
  final String venueId;
  final DateTime? scheduledAt;
  final String type;
  final String status;
  final int fee;
  final String paymentStatus;
  final String paymentMethod;
  final String reason;
  final String attachmentUrl;
  final int serialNo;
  final String familyMemberId;
  final Doctor? doctor;
  final Venue? venue;
  final String patientName;

  bool get isVideo => type == 'video';
  bool get upcoming {
    final s = status.toLowerCase();
    return s != 'completed' && s != 'cancelled' && s != 'canceled';
  }

  String get doctorName => doctor?.displayName ?? 'Doctor';
  String get doctorInitials => doctor?.initials ?? 'D';
  String get specialty => doctor?.specialization ?? '';
  String get venueName => venue?.venueName ?? '';
  String get feeLabel => fee > 0 ? '৳$fee' : 'Free'.tr;

  /// A free visit (no charge) — `payment_method == "free"` or a zero fee. Such
  /// appointments have no invoice, so the view/download actions are hidden.
  bool get isFree => paymentMethod.toLowerCase() == 'free' || fee <= 0;

  String get statusLabel =>
      status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);

  String get whenLabel {
    final dt = scheduledAt?.toLocal();
    return dt == null ? '' : DateFormat('d MMM · h:mm a').format(dt);
  }

  String get typeLabel => isVideo ? 'Video consult' : 'In-person';

  factory HcAppointment.fromMap(Map<String, dynamic> j) {
    final sched = _str(j['scheduled_at']);
    final patient = j['patient'] is Map ? j['patient'] as Map : const {};
    final patientProfile =
        patient['profile'] is Map ? patient['profile'] as Map : const {};
    return HcAppointment(
      id: _str(j['id']),
      doctorId: _str(j['doctor_id']),
      venueId: _str(j['venue_id']),
      scheduledAt: sched.isEmpty ? null : DateTime.tryParse(sched),
      type: _str(j['type']),
      status: _str(j['status']),
      fee: _int(j['fee']),
      paymentStatus: _str(j['payment_status']),
      paymentMethod: _str(j['payment_method']),
      reason: _str(j['reason']),
      attachmentUrl: _str(j['attachment_url']),
      serialNo: _int(j['serial_no']),
      familyMemberId: _str(j['family_member_id']),
      doctor: j['doctor'] is Map
          ? Doctor.fromMap((j['doctor'] as Map).cast<String, dynamic>())
          : null,
      venue: j['venue'] is Map
          ? Venue.fromMap((j['venue'] as Map).cast<String, dynamic>())
          : null,
      patientName: _str(patientProfile['full_name']),
    );
  }

  static List<HcAppointment> listFromResponse(dynamic src) => _dataList(src)
      .whereType<Map>()
      .map((e) => HcAppointment.fromMap(e.cast<String, dynamic>()))
      .toList();

  static HcAppointment fromResponse(dynamic src) =>
      HcAppointment.fromMap((_data(src) as Map).cast<String, dynamic>());
}

// ── Queue ───────────────────────────────────────────────────────────
class QueueInfo {
  QueueInfo({
    required this.serialNo,
    required this.aheadCount,
    required this.estimatedWaitMin,
    required this.avgConsultMin,
    required this.totalForSession,
  });

  final int serialNo;
  final int aheadCount;
  final int estimatedWaitMin;
  final int avgConsultMin;
  final int totalForSession;

  factory QueueInfo.fromResponse(dynamic src) {
    final d = _data(src) as Map;
    return QueueInfo(
      serialNo: _int(d['serial_no']),
      aheadCount: _int(d['ahead_count']),
      estimatedWaitMin: _int(d['estimated_wait_min']),
      avgConsultMin: _int(d['avg_consult_min']),
      totalForSession: _int(d['total_for_session']),
    );
  }
}

// ── Prescription ────────────────────────────────────────────────────
class PrescriptionItem {
  PrescriptionItem({
    required this.tradeName,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  final String tradeName;
  final String genericName;
  final String strength;
  final String form;
  final String dosage;
  final String frequency;
  final String duration;

  factory PrescriptionItem.fromMap(Map<String, dynamic> j) => PrescriptionItem(
        tradeName: _str(j['trade_name']),
        genericName: _str(j['generic_name']),
        strength: _str(j['strength']),
        form: _str(j['form']),
        dosage: _str(j['dosage']),
        frequency: _str(j['frequency']),
        duration: _str(j['duration']),
      );
}

class Prescription {
  Prescription({
    required this.id,
    required this.appointmentId,
    required this.diagnosis,
    required this.chiefComplaint,
    required this.advice,
    required this.investigations,
    required this.bloodPressure,
    required this.pulse,
    required this.temperature,
    required this.weight,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.items,
    this.createdAt,
    this.followUpDate,
  });

  final String id;
  final String appointmentId;
  final String diagnosis;
  final String chiefComplaint;
  final String advice;
  final String investigations;
  final String bloodPressure;
  final String pulse;
  final String temperature;
  final String weight;
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final List<PrescriptionItem> items;
  final DateTime? createdAt;
  final DateTime? followUpDate;

  String get dateLabel {
    final dt = createdAt?.toLocal();
    return dt == null ? '' : DateFormat('d MMM yyyy').format(dt);
  }

  factory Prescription.fromMap(Map<String, dynamic> j) {
    final doctorMap = j['doctor'] is Map ? j['doctor'] as Map : const {};
    final doctorUser =
        doctorMap['user'] is Map ? doctorMap['user'] as Map : const {};
    final doctorProfile =
        doctorUser['profile'] is Map ? doctorUser['profile'] as Map : const {};
    final patient = j['patient'] is Map ? j['patient'] as Map : const {};
    final patientProfile =
        patient['profile'] is Map ? patient['profile'] as Map : const {};
    final itemsRaw = j['items'] is List ? j['items'] as List : const [];
    final created = _str(j['created_at']);
    final followUp = _str(j['follow_up_date']);
    return Prescription(
      id: _str(j['id']),
      appointmentId: _str(j['appointment_id']),
      diagnosis: _str(j['diagnosis']),
      chiefComplaint: _str(j['chief_complaint']),
      advice: _str(j['advice']),
      investigations: _str(j['investigations']),
      bloodPressure: _str(j['blood_pressure']),
      pulse: _str(j['pulse']),
      temperature: _str(j['temperature']),
      weight: _str(j['weight']),
      doctorName: _str(doctorProfile['full_name']),
      doctorSpecialty: _str(doctorMap['specialization']),
      patientName: _str(patientProfile['full_name']),
      items: itemsRaw
          .whereType<Map>()
          .map((e) => PrescriptionItem.fromMap(e.cast<String, dynamic>()))
          .toList(),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
      followUpDate: followUp.isEmpty ? null : DateTime.tryParse(followUp),
    );
  }

  static Prescription fromResponse(dynamic src) =>
      Prescription.fromMap((_data(src) as Map).cast<String, dynamic>());

  /// Parses `{ data: { prescriptions: [...] } }` (by-doctor endpoint).
  static List<Prescription> listFromByDoctor(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['prescriptions'] is List
        ? d['prescriptions'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => Prescription.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Payment method ──────────────────────────────────────────────────
/// A payment option from `GET /api/v1/healthcare/payment-methods`. The backend
/// advertises only methods whose admin gateway toggle is on, so the booking
/// screen reflects the live settings (e.g. cash + online, bKash hidden).
class HcPaymentMethod {
  HcPaymentMethod({
    required this.key,
    required this.label,
    required this.description,
    required this.enabled,
  });
  final String key;
  final String label;
  final String description;
  final bool enabled;

  factory HcPaymentMethod.fromMap(Map<String, dynamic> j) => HcPaymentMethod(
        key: _str(j['key']),
        label: _str(j['label']),
        description: _str(j['description']),
        enabled: j['enabled'] == true,
      );

  static List<HcPaymentMethod> listFromResponse(dynamic src) {
    final d = _data(src);
    final list =
        d is Map && d['methods'] is List ? d['methods'] as List : const [];
    return list
        .whereType<Map>()
        .map((e) => HcPaymentMethod.fromMap(e.cast<String, dynamic>()))
        .toList();
  }

  static String defaultKey(dynamic src) {
    final d = _data(src);
    return d is Map ? _str(d['default']) : '';
  }
}
