import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/values/app_colors.dart';
import '../modules/notifications/controllers/notifications_controller.dart';
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

  VoidCallback get _onBell =>
      onNotifications ??
      () async {
        await Get.toNamed(Routes.NOTIFICATIONS);
        if (Get.isRegistered<NotificationsController>()) {
          Get.find<NotificationsController>().fetchUnreadCount();
        }
      };

  Widget _logo() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.brandOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        'assets/image/service_logo.png',
        fit: BoxFit.contain,
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
    final button = _circleButton(Icons.notifications_none_rounded, _onBell);
    if (Get.isRegistered<NotificationsController>()) {
      return GetBuilder<NotificationsController>(
        builder: (con) => _bellStack(button, con.hasUnread),
      );
    }
    return _bellStack(button, hasNotification);
  }

  Widget _bellStack(Widget button, bool showDot) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        if (showDot)
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
