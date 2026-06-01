import 'package:flutter/material.dart';

/// A service shown in the "All Services" grid.
class SnService {
  const SnService({
    required this.name,
    required this.icon,
    required this.color,
    this.badge,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int? badge;
}

/// A quick action shown in the center "Quick" bottom sheet.
class QuickAction {
  const QuickAction(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}

/// A recent service card on the Home tab.
class RecentService {
  const RecentService({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.bg,
    this.status = 'Done',
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final Color bg;
  final String status;
}

/// An order row on the Orders tab.
class OrderEntry {
  const OrderEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final OrderStatus status;
}

enum OrderStatus { completed, inProgress }

extension OrderStatusX on OrderStatus {
  String get label =>
      this == OrderStatus.completed ? 'Completed' : 'In progress';
  Color get fg =>
      this == OrderStatus.completed ? const Color(0xFF15803D) : const Color(0xFFB45309);
  Color get bg =>
      this == OrderStatus.completed ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
}
