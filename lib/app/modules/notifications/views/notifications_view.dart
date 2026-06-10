import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          GetBuilder<NotificationsController>(
            builder: (con) => con.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: con.markAllRead,
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: con.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _NotificationCard(
                item: con.items[i],
                onTap: () => con.markRead(con.items[i]),
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
          child: Text(isError ? 'Could not load notifications' : "You're all caught up",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(isError ? error! : 'New updates will appear here.',
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
              child: const Text('Retry'),
            ),
          ),
        ],
      ],
    );
  }
}

IconData _typeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'booking':
    case 'service_booking':
      return Icons.home_repair_service_rounded;
    case 'appointment':
      return Icons.medical_services_rounded;
    case 'blood':
      return Icons.water_drop_rounded;
    case 'ambulance':
      return Icons.airport_shuttle_rounded;
    case 'grievance':
    case 'nagarik':
      return Icons.account_balance_rounded;
    case 'ticket':
    case 'message':
      return Icons.chat_bubble_outline_rounded;
    case 'job':
    case 'application':
      return Icons.work_outline_rounded;
    case 'match':
    case 'matchmaking':
      return Icons.favorite_rounded;
    default:
      return Icons.notifications_rounded;
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFFFF4EE) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread
                ? const Color(0xFFFDE3D5)
                : const Color(0xFFEDEFF2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brandOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(item.type),
                  color: AppColors.brandOrange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (item.body.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.3),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeLabel,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 8),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.brandOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
