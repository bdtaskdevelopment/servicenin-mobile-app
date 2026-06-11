import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/ambulance_notifications_controller.dart';

const _navy = Color(0xFF1E2A4A);

class AmbulanceNotificationsView
    extends GetView<AmbulanceNotificationsController> {
  const AmbulanceNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: GetBuilder<AmbulanceNotificationsController>(
          builder: (con) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('${con.newToday} new today',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        splashRadius: 22,
                        onPressed: con.markAllRead,
                        icon: const Icon(Icons.done_rounded,
                            color: Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                ),
                // v2 banner
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFF7E6),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('● v2',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notification feed is v2 — no notifications endpoint in the current API.'.tr,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB45309),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter tabs
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    itemCount: con.tabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final sel = con.selectedTab == i;
                      return GestureDetector(
                        onTap: () => con.selectTab(i),
                        child: Container(
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: sel ? _navy : AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: sel
                                    ? _navy
                                    : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(con.tabs[i],
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: sel
                                      ? Colors.white
                                      : const Color(0xFF334155))),
                        ),
                      );
                    },
                  ),
                ),
                // Feed
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      for (final section in con.sections) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(section,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                  letterSpacing: 0.6)),
                        ),
                        ...con.itemsFor(section).map((n) => _NotifTile(item: n)),
                      ],
                      if (con.sections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Center(
                            child: Text('No notifications'.tr,
                                style: const TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final AmbNotification item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.unread ? const Color(0xFFFFF6EF) : AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // unread dot
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: item.unread
                    ? const Color(0xFFF15A24)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: item.tileColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(item.icon, color: item.iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8))),
                const SizedBox(height: 8),
                _ChannelTag(channel: item.channel),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.time,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _ChannelTag extends StatelessWidget {
  const _ChannelTag({required this.channel});
  final String channel;

  @override
  Widget build(BuildContext context) {
    final isSms = channel.toLowerCase() == 'sms';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSms ? const Color(0xFFDBEAFE) : const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(channel,
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isSms ? const Color(0xFF2563EB) : const Color(0xFF475569))),
    );
  }
}
