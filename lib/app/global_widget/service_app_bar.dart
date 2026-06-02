import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../routes/app_pages.dart';

/// The ServiceNin brand app bar: SN logo, name + tagline, and search /
/// notification actions. Reused on Home, Services and Account tabs.
class ServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ServiceAppBar({
    super.key,
    this.title = 'ServiceNin',
    this.subtitle = 'আপনার শহর, আপনার সেবা',
    this.onSearch,
    this.onNotifications,
    this.hasNotification = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
  final bool hasNotification;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _logo(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const Spacer(),
            _circleButton(
              Icons.search_rounded,
              onSearch ?? () => Get.toNamed(Routes.SEARCH),
            ),
            const SizedBox(width: 10),
            _bell(),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.brandOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'SN',
        style: TextStyle(
          color: AppColors.brandOrange,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF334155), size: 22),
      ),
    );
  }

  Widget _bell() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _circleButton(
          Icons.notifications_none_rounded,
          onNotifications ?? () => Get.toNamed(Routes.NOTIFICATIONS),
        ),
        if (hasNotification)
          Positioned(
            right: 9,
            top: 9,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.brandOrange,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
