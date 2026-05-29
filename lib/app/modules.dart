// lib/app/modules.dart
// Registry of the 12 service modules — drives the dashboard grid + routes.
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ModuleDef {
  final String id, label, labelBn, route;
  final IconData icon;
  final Color accent;
  const ModuleDef(this.id, this.label, this.labelBn, this.route, this.icon, this.accent);
}

const kModules = <ModuleDef>[
  ModuleDef('blood', 'Blood', 'রক্ত', '/m/blood', Icons.water_drop, AppColors.rose),
  ModuleDef('ambulance', 'Ambulance', 'অ্যাম্বুলেন্স', '/m/ambulance', Icons.local_hospital, AppColors.navy),
  ModuleDef('healthcare', 'Healthcare', 'স্বাস্থ্য', '/m/healthcare', Icons.medical_services, AppColors.mint),
  ModuleDef('services', 'Home Service', 'হোম সার্ভিস', '/m/services', Icons.cleaning_services, AppColors.teal),
  ModuleDef('physio', 'Physio', 'ফিজিও', '/m/physio', Icons.accessibility_new, AppColors.amber),
  ModuleDef('matchmaking', 'Matchmaking', 'ম্যাচমেকিং', '/m/matchmaking', Icons.favorite, AppColors.pink),
  ModuleDef('jobs', 'Jobs', 'চাকরি', '/m/jobs', Icons.work_outline, AppColors.burnt),
  ModuleDef('education', 'Education', 'শিক্ষা', '/m/education', Icons.menu_book, AppColors.violet),
  ModuleDef('nagarik', 'Nagarik Sheba', 'নাগরিক', '/m/nagarik', Icons.account_balance, AppColors.dnccOrange),
  ModuleDef('info', 'Information', 'তথ্য', '/m/info', Icons.phone_in_talk, AppColors.indigo),
  ModuleDef('funeral', 'Funeral', 'জানাজা', '/m/funeral', Icons.local_florist, AppColors.stone),
  ModuleDef('account', 'Account', 'অ্যাকাউন্ট', '/account', Icons.person_outline, AppColors.navy),
];
