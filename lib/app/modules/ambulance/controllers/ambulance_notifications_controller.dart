import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AmbNotification {
  AmbNotification({
    required this.title,
    required this.subtitle,
    required this.channel,
    required this.time,
    required this.icon,
    required this.tileColor,
    required this.iconColor,
    required this.section,
    required this.category,
    this.unread = false,
  });

  final String title;
  final String subtitle;
  final String channel; // Push / SMS
  final String time;
  final IconData icon;
  final Color tileColor;
  final Color iconColor;
  final String section; // TODAY / YESTERDAY / THIS WEEK
  final String category; // bookings / drivers / payments / promotions
  bool unread;
}

class AmbulanceNotificationsController extends GetxController {
  final List<String> tabs = const [
    'All', 'Bookings', 'Drivers', 'Payments', 'Promotions',
  ];
  int selectedTab = 0;
  void selectTab(int i) {
    selectedTab = i;
    update();
  }

  final List<AmbNotification> _items = [
    AmbNotification(
      title: 'Ambulance arriving in 6 minutes',
      subtitle: 'ICU · BD-1234 · Md. Rashedul',
      channel: 'Push',
      time: '14:04',
      icon: Icons.airport_shuttle_rounded,
      tileColor: const Color(0xFFFDE4E4),
      iconColor: const Color(0xFFE11D48),
      section: 'TODAY',
      category: 'bookings',
      unread: true,
    ),
    AmbNotification(
      title: 'Driver assigned',
      subtitle: 'Rashedul · 4.92★ · 8 yrs exp.',
      channel: 'SMS',
      time: '14:03',
      icon: Icons.person_outline_rounded,
      tileColor: const Color(0xFFE6E7FB),
      iconColor: const Color(0xFF4F46E5),
      section: 'TODAY',
      category: 'drivers',
      unread: true,
    ),
    AmbNotification(
      title: 'Booking confirmed',
      subtitle: 'AMB-2026-04891 · ICU · ETA 8 min',
      channel: 'Push',
      time: '14:02',
      icon: Icons.check_circle_rounded,
      tileColor: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      section: 'TODAY',
      category: 'bookings',
      unread: true,
    ),
    AmbNotification(
      title: 'Payment confirmed · ৳2,840',
      subtitle: 'bKash · AMB-2026-04812',
      channel: 'Push',
      time: '11:42',
      icon: Icons.bolt_rounded,
      tileColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      section: 'YESTERDAY',
      category: 'payments',
    ),
    AmbNotification(
      title: 'Trip completed',
      subtitle: 'Apollo Hospitals · 28 min · Rate now',
      channel: 'Push',
      time: '11:38',
      icon: Icons.check_circle_rounded,
      tileColor: const Color(0xFFDCFCE7),
      iconColor: const Color(0xFF16A34A),
      section: 'YESTERDAY',
      category: 'bookings',
    ),
    AmbNotification(
      title: 'Scheduled booking reminder',
      subtitle: 'Tomorrow 08:30 · BSMMU follow-up',
      channel: 'SMS',
      time: '13 May',
      icon: Icons.calendar_month_rounded,
      tileColor: const Color(0xFFFFEDD5),
      iconColor: const Color(0xFFEA580C),
      section: 'THIS WEEK',
      category: 'bookings',
    ),
  ];

  static const List<String> _sectionOrder = ['TODAY', 'YESTERDAY', 'THIS WEEK'];

  List<AmbNotification> get _filtered {
    if (selectedTab == 0) return _items;
    final cat = tabs[selectedTab].toLowerCase();
    return _items.where((n) => n.category == cat).toList();
  }

  /// Sections (in order) that have at least one notification after filtering.
  List<String> get sections => _sectionOrder
      .where((s) => _filtered.any((n) => n.section == s))
      .toList();

  List<AmbNotification> itemsFor(String section) =>
      _filtered.where((n) => n.section == section).toList();

  int get newToday =>
      _items.where((n) => n.section == 'TODAY' && n.unread).length;

  void markAllRead() {
    for (final n in _items) {
      n.unread = false;
    }
    update();
  }
}
