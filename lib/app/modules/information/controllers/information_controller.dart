import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class Guide {
  const Guide({
    required this.title,
    required this.source,
    required this.meta,
    required this.category,
    required this.icon,
    required this.steps,
    required this.helpText,
  });

  final String title;
  final String source;
  final String meta;
  final String category;
  final IconData icon;
  final List<String> steps;
  final String helpText;
}

class Hotline {
  const Hotline(this.number, this.label, this.icon,
      [this.color = const Color(0xFF6366F1)]);
  final String number;
  final String label;
  final IconData icon;
  final Color color;
}

class GuideCategory {
  const GuideCategory(this.name, this.count, this.icon);
  final String name;
  final int count;
  final IconData icon;
}

class PopularGuide {
  const PopularGuide(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class InformationController extends GetxController {
  final List<Hotline> hotlines = const [
    Hotline('16263', 'Health (Shastho)', Icons.medical_services_outlined),
    Hotline('109', 'Women & Children', Icons.female_rounded),
    Hotline('106', 'Anti-Corruption', Icons.flag_outlined),
    Hotline('16106', 'DNCC Hotline', Icons.account_balance_outlined),
  ];

  /// Full list shown on the "Emergency hotlines" screen.
  final List<Hotline> allHotlines = const [
    Hotline('16263', 'Health (Shastho)', Icons.medical_services_outlined),
    Hotline('109', 'Women & Children', Icons.female_rounded),
    Hotline('106', 'Anti-Corruption', Icons.flag_outlined),
    Hotline('16106', 'DNCC Hotline', Icons.account_balance_outlined),
    Hotline('102', 'Fire Service', Icons.local_fire_department_rounded,
        Color(0xFF1E2A4A)),
    Hotline('16216', 'WASA (Water)', Icons.waves_rounded, Color(0xFF3B82F6)),
    Hotline('16120', 'Titas Gas', Icons.bolt_rounded, Color(0xFF6366F1)),
  ];

  final List<GuideCategory> categories = const [
    GuideCategory('Utility & Bills', 12, Icons.bolt_rounded),
    GuideCategory('Govt. Services', 18, Icons.account_balance_rounded),
    GuideCategory('Health & Safety', 9, Icons.medical_services_rounded),
    GuideCategory('Transport', 7, Icons.location_on_rounded),
  ];

  final List<PopularGuide> popular = const [
    PopularGuide('How to pay holding tax online',
        'DNCC · step-by-step · 4 min', Icons.lightbulb_outline_rounded),
  ];

  // ── Guides ───────────────────────────────────────────────────────
  final List<Guide> guides = const [
    Guide(
      title: 'Report a power outage',
      source: 'DPDC / DESCO',
      meta: '2 min read · updated Mar 2026',
      category: 'Utility & Bills',
      icon: Icons.lightbulb_outline_rounded,
      steps: [
        'Note your consumer/meter number before calling.',
        'Report outages to your local DPDC or DESCO office, or via their hotline.',
        'Planned maintenance schedules are announced a day in advance.',
      ],
      helpText: 'Call DNCC hotline 16106',
    ),
    Guide(
      title: 'How to pay holding tax online',
      source: 'DNCC',
      meta: '4 min read · updated Mar 2026',
      category: 'Govt. Services',
      icon: Icons.lightbulb_outline_rounded,
      steps: [
        'Create or log in to your DNCC e-services account.',
        'Search your holding number to view the assessed amount.',
        'Pay via card or mobile banking and save the receipt.',
      ],
      helpText: 'Call DNCC hotline 16106',
    ),
  ];

  GuideCategory? selectedCategory;
  Guide? selectedGuide;

  List<Guide> get categoryGuides =>
      guides.where((g) => g.category == selectedCategory?.name).toList();

  void openCategory(GuideCategory c) {
    selectedCategory = c;
    update();
    Get.toNamed(Routes.INFORMATION_GUIDES);
  }

  void openGuide(Guide g) {
    selectedGuide = g;
    update();
    Get.toNamed(Routes.INFORMATION_GUIDE_DETAIL);
  }

  void openGuideByTitle(String title) {
    openGuide(guides.firstWhere((g) => g.title == title,
        orElse: () => guides.first));
  }
}
