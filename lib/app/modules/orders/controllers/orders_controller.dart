import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/sn_service.dart';

class OrdersController extends GetxController {
  final List<OrderEntry> orders = const [
    OrderEntry(
      title: 'Healthcare',
      subtitle: 'Dr. Salma Akter · 2 days ago',
      icon: Icons.medical_services_rounded,
      color: Color(0xFF14B8A6),
      status: OrderStatus.completed,
    ),
    OrderEntry(
      title: 'Home Service',
      subtitle: 'AC Cleaning · Yesterday',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFF6366F1),
      status: OrderStatus.completed,
    ),
    OrderEntry(
      title: 'Nagarik Sheba',
      subtitle: 'Pothole · Banani · 3 days ago',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFF15A24),
      status: OrderStatus.inProgress,
    ),
    OrderEntry(
      title: 'Ambulance',
      subtitle: 'ICU · BD-1234 · 5 days ago',
      icon: Icons.airport_shuttle_rounded,
      color: Color(0xFF3B82F6),
      status: OrderStatus.completed,
    ),
    OrderEntry(
      title: 'Blood Donation',
      subtitle: 'O+ · Square Hsp. · 12 days ago',
      icon: Icons.water_drop_rounded,
      color: Color(0xFFE53935),
      status: OrderStatus.completed,
    ),
  ];
}
