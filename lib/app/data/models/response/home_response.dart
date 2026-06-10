import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

dynamic _dec(dynamic src) => src is String ? jsonDecode(src) : src;
String _str(dynamic v) => v?.toString().trim() ?? '';
int _int(dynamic v) =>
    v is int ? v : int.tryParse(_str(v)) ?? (v is num ? v.toInt() : 0);

dynamic _data(dynamic src) {
  final d = _dec(src);
  return d is Map && d.containsKey('data') ? d['data'] : d;
}

Color _hexColor(String hex, Color fallback) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final v = int.tryParse(h, radix: 16);
  return v == null ? fallback : Color(v);
}

IconData homeServiceIcon(String icon) {
  switch (icon.toLowerCase()) {
    case 'stethoscope':
      return Icons.medical_services_rounded;
    case 'ambulance':
      return Icons.airport_shuttle_rounded;
    case 'blood':
      return Icons.water_drop_rounded;
    case 'tools':
      return Icons.home_repair_service_rounded;
    case 'physio':
      return Icons.self_improvement_rounded;
    case 'funeral':
      return Icons.volunteer_activism_rounded;
    case 'heart':
      return Icons.favorite_rounded;
    case 'briefcase':
      return Icons.work_outline_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'government':
      return Icons.account_balance_rounded;
    case 'info':
      return Icons.info_outline_rounded;
    default:
      return Icons.grid_view_rounded;
  }
}

// ── Service (catalog / trending / popular / recent / search) ────────
class HomeService {
  HomeService({
    required this.key,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.route,
    required this.type,
  });

  final String key;
  final String name;
  final String icon;
  final String colorHex;
  final String route;
  final String type;

  IconData get iconData => homeServiceIcon(icon);
  Color get color => _hexColor(colorHex, const Color(0xFF334155));

  factory HomeService.fromMap(Map<String, dynamic> j) => HomeService(
        key: _str(j['key']),
        name: _str(j['name']),
        icon: _str(j['icon']),
        colorHex: _str(j['color']),
        route: _str(j['route']),
        type: _str(j['type']),
      );

  /// Parses `{ data: { services: [...] } }` (or a bare list).
  static List<HomeService> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['services'] is List
        ? d['services'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => HomeService.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── Banner ──────────────────────────────────────────────────────────
class HomeBanner {
  HomeBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.route,
    required this.action,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String route;
  final String action;
  final String type;

  factory HomeBanner.fromMap(Map<String, dynamic> j) => HomeBanner(
        title: _str(j['title']),
        subtitle: _str(j['subtitle']),
        imageUrl: _str(j['image_url']),
        route: _str(j['route']),
        action: _str(j['action']),
        type: _str(j['type']),
      );

  static List<HomeBanner> listFromResponse(dynamic src) {
    final d = _data(src);
    final list = d is Map && d['banners'] is List
        ? d['banners'] as List
        : (d is List ? d : const []);
    return list
        .whereType<Map>()
        .map((e) => HomeBanner.fromMap(e.cast<String, dynamic>()))
        .toList();
  }
}

// ── My orders ───────────────────────────────────────────────────────
class HomeOrder {
  HomeOrder(this.raw);
  final Map<String, dynamic> raw;

  String get module => _str(raw['module']);
  String get type => _str(raw['type']);
  String get title => _str(raw['title']);
  String get status => _str(raw['status']);
  String get refId => _str(raw['ref_id']);

  String get statusLabel {
    final s = status.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  String get typeLabel {
    final s = type.replaceAll('_', ' ');
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  bool get isDone => status == 'completed' || status == 'accepted' ||
      status == 'resolved' || status == 'closed';
  bool get isCancelled =>
      status == 'cancelled' || status == 'rejected' || status == 'declined';

  String get createdLabel {
    final c = _str(raw['created_at']);
    final dt = c.isEmpty ? null : DateTime.tryParse(c)?.toLocal();
    return dt == null ? '' : DateFormat('d MMM yyyy').format(dt);
  }
}

class HomeOrdersData {
  HomeOrdersData({
    required this.orders,
    required this.byModule,
    required this.total,
  });

  final List<HomeOrder> orders;
  final Map<String, int> byModule;
  final int total;

  factory HomeOrdersData.fromResponse(dynamic src) {
    final d = _data(src);
    final m = d is Map ? d : const {};
    final list = m['orders'] is List ? m['orders'] as List : const [];
    final by = <String, int>{};
    if (m['by_module'] is Map) {
      (m['by_module'] as Map).forEach((k, v) {
        by[_str(k)] = _int(v);
      });
    }
    return HomeOrdersData(
      orders: list
          .whereType<Map>()
          .map((e) => HomeOrder(e.cast<String, dynamic>()))
          .toList(),
      byModule: by,
      total: _int(m['total']),
    );
  }
}
