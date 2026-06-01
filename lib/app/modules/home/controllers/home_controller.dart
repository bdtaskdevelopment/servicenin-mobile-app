import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/sn_service.dart';

class HomeController extends GetxController {
  // Promo banner carousel
  int promoIndex = 0;
  void setPromo(int i) {
    promoIndex = i;
    update();
  }

  final List<RecentService> recent = const [
    RecentService(
      title: 'Healthcare',
      subtitle: 'Dr. Salma Akter',
      time: '2 days ago',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF14B8A6),
      bg: Color(0xFFD9F7EF),
    ),
    RecentService(
      title: 'Home Service',
      subtitle: 'AC Cleaning',
      time: 'Yesterday',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFF6366F1),
      bg: Color(0xFFE6E7FB),
    ),
    RecentService(
      title: 'Nagarik Sheba',
      subtitle: 'Pothole',
      time: '3 days ago',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFF15A24),
      bg: Color(0xFFFDE7DC),
    ),
  ];
}
