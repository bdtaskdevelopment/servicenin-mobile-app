import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:animate_do/animate_do.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/notification_response.dart';
import '../../../global_widget/custom_app_bar.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final con = Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => con.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: CustomAppBar(
        title: 'Notifications'.tr,
        actions: [
          GetBuilder<NotificationsController>(
            builder: (con) => con.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: con.markAllRead,
                    child: Text(
                      'Mark all read'.tr,
                      style: const TextStyle(
                        color: AppColors.brandOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: GetBuilder<NotificationsController>(
        builder: (con) {
          if (con.loading && con.items.isEmpty) {
            return const SnListSkeleton();
          }
          if (con.items.isEmpty) {
            return _Empty(error: con.error, onRetry: con.fetchNotifications);
          }
          return RefreshIndicator(
            color: AppColors.brandOrange,
            onRefresh: con.fetchNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: con.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => FadeInUp(
                from: 16,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 40 * (i % 10)),
                child: _NotificationCard(
                  item: con.items[i],
                  onTap: () => con.openNotification(con.items[i]),
                  onDismiss: () => con.dismiss(con.items[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.error, this.onRetry});
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isError = error != null && error!.isNotEmpty;
    return ListView(
      children: [
        const SizedBox(height: 140),
        Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.notifications_none_rounded,
            size: 56,
            color: Colors.black.withValues(alpha: 0.18)),
        const SizedBox(height: 14),
        Center(
          child: Text(
              isError
                  ? 'Could not load notifications'.tr
                  : "You're all caught up".tr,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(isError ? error! : 'New updates will appear here.'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF94A3B8))),
          ),
        ),
        if (isError && onRetry != null) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: onRetry,
              child: Text('Retry'.tr),
            ),
          ),
        ],
      ],
    );
  }
}

/// The orange call-to-action label under each notification. Only the TEXT
/// changes with the notification's kind — the colour is always brand orange,
/// so every card reads as one consistent design.
String _actionLabel(AppNotification n) {
  final t = n.type.toLowerCase();
  final r = n.referenceType.toLowerCase();
  if (t == 'payment') return 'Receipt'.tr;
  if (t == 'message') return 'Reply'.tr;
  switch (r) {
    case 'service_booking':
    case 'booking':
      return 'View booking'.tr;
    case 'ambulance_booking':
      return 'Track'.tr;
    case 'appointment':
      return 'View appointment'.tr;
    case 'grievance':
      return 'View status'.tr;
    case 'blood_request':
      return 'View request'.tr;
  }
  return 'View'.tr;
}

/// One card design for every notification — differs only in its data
/// (title, body, time, action label). White card with a soft shadow and a
/// brand-orange accent bar along the bottom; a ✕ dismisses it.
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });
  final AppNotification item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 4),
                          child: Text(
                            item.timeLabel,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        // Bigger, higher-contrast, easy-to-hit dismiss button.
                        GestureDetector(
                          onTap: onDismiss,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDF0F4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          item.body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _actionLabel(item),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandOrange,
                      ),
                    ),
                  ],
                ),
              ),
              // Brand-orange accent bar along the bottom — full colour when
              // unread, faded once read.
              Container(
                margin: const EdgeInsets.fromLTRB(12, 1, 12, 10),
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.brandOrange
                      .withValues(alpha: unread ? 1 : 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
