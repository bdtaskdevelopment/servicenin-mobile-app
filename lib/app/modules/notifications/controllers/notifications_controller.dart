import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnNotification {
  SnNotification({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.unread = false,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  bool unread;
}

class NotificationsController extends GetxController {
  final List<SnNotification> today = [
    SnNotification(
      title: 'Ambulance arriving',
      subtitle: 'Your ICU ambulance is 4 min away.',
      time: '2m',
      icon: Icons.airport_shuttle_rounded,
      color: const Color(0xFF3B82F6),
      unread: true,
    ),
    SnNotification(
      title: 'Technician on the way',
      subtitle: 'Jamal U. will reach you by 3:00 PM.',
      time: '40m',
      icon: Icons.home_repair_service_rounded,
      color: const Color(0xFF14B8A6),
      unread: true,
    ),
    SnNotification(
      title: 'Blood request match',
      subtitle: 'An O+ donor 1.2 km away responded.',
      time: '1h',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFFE53935),
      unread: true,
    ),
  ];

  final List<SnNotification> earlier = [
    SnNotification(
      title: 'Appointment confirmed',
      subtitle: 'Dr. Salma Akter · today 3:40 PM · token 14.',
      time: 'Yesterday',
      icon: Icons.medical_services_rounded,
      color: const Color(0xFF14B8A6),
    ),
    SnNotification(
      title: 'Report update',
      subtitle: 'Pothole report DNCC-04823 is in progress.',
      time: '2d',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFFF15A24),
    ),
  ];

  void markAllRead() {
    for (final n in today) {
      n.unread = false;
    }
    for (final n in earlier) {
      n.unread = false;
    }
    update();
  }
}
