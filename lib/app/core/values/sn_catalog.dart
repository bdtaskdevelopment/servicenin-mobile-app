import 'package:flutter/material.dart';

import '../../data/models/sn_service.dart';

/// Static catalog data shared across the Home and Services tabs.
/// Icons are the closest Material equivalents to the design; swap for custom
/// assets later if needed.
class SnCatalog {
  SnCatalog._();

  static const List<SnService> services = [
    SnService(name: 'Blood', icon: Icons.water_drop_rounded, color: Color(0xFFE53935)),
    SnService(name: 'Ambulance', icon: Icons.airport_shuttle_rounded, color: Color(0xFF3B82F6)),
    SnService(name: 'Healthcare', icon: Icons.medical_services_rounded, color: Color(0xFF14B8A6)),
    SnService(name: 'Information', icon: Icons.call_rounded, color: Color(0xFF8B5CF6)),
    SnService(name: 'Home Service', icon: Icons.home_repair_service_rounded, color: Color(0xFFF15A24), badge: 2),
    SnService(name: 'Physio', icon: Icons.directions_run_rounded, color: Color(0xFFF97316)),
    SnService(name: 'Matchmaking', icon: Icons.favorite_rounded, color: Color(0xFFEC4899)),
    SnService(name: 'Jobs', icon: Icons.business_center_rounded, color: Color(0xFFF59E0B)),
    SnService(name: 'Funeral', icon: Icons.local_florist_rounded, color: Color(0xFF475569)),
    SnService(name: 'Education', icon: Icons.menu_book_rounded, color: Color(0xFF7C3AED)),
    SnService(name: 'Nagarik Sheba', icon: Icons.account_balance_rounded, color: Color(0xFFF15A24)),
    SnService(name: 'More', icon: Icons.more_horiz_rounded, color: Color(0xFF94A3B8)),
  ];

  static const List<QuickAction> quickActions = [
    QuickAction('Need\nBlood', Icons.water_drop_rounded, Color(0xFFE53935)),
    QuickAction('Ambulance', Icons.airport_shuttle_rounded, Color(0xFF3B82F6)),
    QuickAction('Quick Pay', Icons.bolt_rounded, Color(0xFFF59E0B)),
    QuickAction('Find\nDoctor', Icons.medical_services_rounded, Color(0xFF10B981)),
    QuickAction('Track\nOrder', Icons.location_on_rounded, Color(0xFF6366F1)),
  ];
}
