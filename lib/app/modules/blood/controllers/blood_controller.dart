import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BloodSeverity { critical, urgent, routine }

extension BloodSeverityX on BloodSeverity {
  String get label => switch (this) {
        BloodSeverity.critical => 'Critical',
        BloodSeverity.urgent => 'Urgent',
        BloodSeverity.routine => 'Routine',
      };

  Color get color => switch (this) {
        BloodSeverity.critical => const Color(0xFFE11D48),
        BloodSeverity.urgent => const Color(0xFFB45309),
        BloodSeverity.routine => const Color(0xFF2563EB),
      };

  Color get bg => switch (this) {
        BloodSeverity.critical => const Color(0xFFFEE2E2),
        BloodSeverity.urgent => const Color(0xFFFEF3C7),
        BloodSeverity.routine => const Color(0xFFDBEAFE),
      };
}

class BloodRequest {
  const BloodRequest({
    required this.units,
    required this.group,
    required this.severity,
    required this.hospital,
    required this.area,
    required this.distance,
    required this.timeAgo,
    required this.responded,
    this.contact = 'Karim Sheikh · 01711-***123',
    this.note = '',
  });

  final int units;
  final String group;
  final BloodSeverity severity;
  final String hospital;
  final String area;
  final String distance; // km
  final String timeAgo;
  final int responded;
  final String contact;
  final String note;
}

class BloodController extends GetxController {
  // Donor profile
  final String donorGroup = 'B+';
  final int donations = 12;
  final int livesSaved = 36;
  final int rank = 4;
  final bool available = true;
  final String area = 'Gulshan area';

  // "Show compatible groups only" toggle on the Requests view.
  bool compatibleOnly = true;
  void toggleCompatible(bool value) {
    compatibleOnly = value;
    update();
  }

  /// Groups this B+ donor is willing to match against (demo set).
  static const Set<String> _compatibleGroups = {'O+', 'B+', 'A+', 'AB+'};

  List<BloodRequest> get visibleRequests => compatibleOnly
      ? requests.where((r) => _compatibleGroups.contains(r.group)).toList()
      : requests;

  final List<BloodRequest> requests = const [
    BloodRequest(
      units: 2,
      group: 'O+',
      severity: BloodSeverity.critical,
      hospital: 'Square Hospital',
      area: 'West Panthapath',
      distance: '1.2',
      timeAgo: '8 min ago',
      responded: 3,
      contact: 'Karim Sheikh · 01711-***123',
      note: 'Road accident, ICU. Need within 2 hours.',
    ),
    BloodRequest(
      units: 1,
      group: 'B+',
      severity: BloodSeverity.urgent,
      hospital: 'Dhaka Medical College',
      area: 'Bakshibazar',
      distance: '3.4',
      timeAgo: '22 min ago',
      responded: 5,
      contact: 'Rahim Uddin · 01712-***456',
      note: 'Surgery scheduled tomorrow morning.',
    ),
    BloodRequest(
      units: 3,
      group: 'A+',
      severity: BloodSeverity.routine,
      hospital: 'Labaid Specialized',
      area: 'Dhanmondi',
      distance: '5.1',
      timeAgo: '1 hr ago',
      responded: 8,
      contact: 'Nasrin Akter · 01713-***789',
      note: 'Thalassemia patient, regular transfusion.',
    ),
  ];

  /// The request the donor tapped to view in detail.
  BloodRequest? selectedRequest;
  void selectRequest(BloodRequest request) {
    selectedRequest = request;
    update();
  }
}
