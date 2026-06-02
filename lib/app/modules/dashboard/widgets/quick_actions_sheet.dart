import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/sn_catalog.dart';
import '../../../data/models/sn_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

/// "Quick Actions" bottom sheet opened from the center nav button.
class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const QuickActionsSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reachable in two taps from anywhere.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: SnCatalog.quickActions
                .map((a) => Expanded(child: _QuickItem(action: a)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  const _QuickItem({required this.action});
  final QuickAction action;

  void _go() {
    Get.back(); // close the sheet first
    switch (action.name) {
      case 'Need\nBlood':
        Get.toNamed(Routes.BLOOD);
        break;
      case 'Ambulance':
        Get.toNamed(Routes.AMBULANCE);
        break;
      case 'Find\nDoctor':
        Get.toNamed(Routes.HEALTHCARE);
        break;
      case 'Track\nOrder':
        // Not a page — jump the dashboard to the "Orders" tab.
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changeTab(2);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _go,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            action.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
