import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class NagarikCategory {
  const NagarikCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum ReportStatus { inProgress, resolved }

class Grievance {
  const Grievance({
    required this.title,
    required this.ref,
    required this.ago,
    required this.icon,
    required this.status,
    this.ward = 'Banani · Ward 19',
  });
  final String title;
  final String ref;
  final String ago;
  final IconData icon;
  final ReportStatus status;
  final String ward;
}

class Ticket {
  const Ticket({
    required this.title,
    required this.code,
    required this.dept,
    required this.ago,
    required this.status,
  });
  final String title;
  final String code;
  final String dept;
  final String ago;
  final ReportStatus status;
}

class NagarikController extends GetxController {
  final List<NagarikCategory> categories = const [
    NagarikCategory('রাস্তা', Icons.add_road_rounded),
    NagarikCategory('আবর্জনা', Icons.delete_outline_rounded),
    NagarikCategory('ড্রেন', Icons.waves_rounded),
    NagarikCategory('বাতি', Icons.lightbulb_outline_rounded),
    NagarikCategory('পানি', Icons.water_drop_outlined),
    NagarikCategory('মশা', Icons.shield_outlined),
  ];

  final List<Grievance> grievances = const [
    Grievance(
      title: 'Large pothole on Road 27',
      ref: 'DNCC-2026-04823',
      ago: '3 days ago',
      icon: Icons.add_road_rounded,
      status: ReportStatus.inProgress,
    ),
    Grievance(
      title: 'Garbage not collected for a week',
      ref: 'DNCC-2026-04760',
      ago: '6 days ago',
      icon: Icons.delete_outline_rounded,
      status: ReportStatus.resolved,
    ),
    Grievance(
      title: 'Street light out near park',
      ref: 'DNCC-2026-04711',
      ago: '1 week ago',
      icon: Icons.lightbulb_outline_rounded,
      status: ReportStatus.resolved,
    ),
  ];

  final List<Ticket> tickets = const [
    Ticket(
      title: 'Holding tax payment failed',
      code: 'TK-8841',
      dept: 'Tax',
      ago: '1 day ago',
      status: ReportStatus.inProgress,
    ),
    Ticket(
      title: 'Trade license renewal query',
      code: 'TK-8790',
      dept: 'License',
      ago: '4 days ago',
      status: ReportStatus.resolved,
    ),
  ];

  // Currently-viewed report / ticket
  Grievance? selectedGrievance;
  Ticket? selectedTicket;

  // ---- Report-an-issue form ----
  int categoryIndex = 0; // Roads default
  final List<String> issueCategories = const [
    'Roads',
    'Garbage',
    'Drainage',
    'Street light',
    'Water',
    'Mosquito',
  ];
  final List<IconData> issueIcons = const [
    Icons.add_road_rounded,
    Icons.delete_outline_rounded,
    Icons.waves_rounded,
    Icons.lightbulb_outline_rounded,
    Icons.water_drop_outlined,
    Icons.shield_outlined,
  ];
  void setCategory(int i) {
    categoryIndex = i;
    update();
  }

  int priorityIndex = 1; // Low / Medium / Urgent — Medium default
  void setPriority(int i) {
    priorityIndex = i;
    update();
  }

  // ---- Navigation ----
  void openReports() => Get.toNamed(Routes.NAGARIK_REPORTS);
  void seeAllReports() => Get.toNamed(Routes.NAGARIK_REPORTS);

  void reportIssue() {
    categoryIndex = 0;
    priorityIndex = 1;
    update();
    Get.toNamed(Routes.NAGARIK_REPORT_ISSUE);
  }

  void openCategory(int i) {
    categoryIndex = i;
    priorityIndex = 1;
    update();
    Get.toNamed(Routes.NAGARIK_REPORT_ISSUE);
  }

  void submitReport() => Get.toNamed(Routes.NAGARIK_STATUS);

  void openGrievance(Grievance g) {
    selectedGrievance = g;
    update();
    Get.toNamed(Routes.NAGARIK_STATUS);
  }

  void supportTicket() {
    selectedTicket = tickets.first;
    update();
    Get.toNamed(Routes.NAGARIK_CHAT);
  }

  void openTicket(Ticket t) {
    selectedTicket = t;
    update();
    Get.toNamed(Routes.NAGARIK_CHAT);
  }
}
