import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/service_nav.dart';
import '../../../core/values/app_colors.dart';
import '../../../data/models/response/home_response.dart';
import '../../../global_widget/service_app_bar.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/orders_controller.dart';

IconData _moduleIcon(String module) {
  switch (module) {
    case 'blood':
      return Icons.water_drop_rounded;
    case 'ambulance':
      return Icons.airport_shuttle_rounded;
    case 'healthcare':
      return Icons.medical_services_rounded;
    case 'services':
    case 'home_service':
      return Icons.home_repair_service_rounded;
    case 'physio':
      return Icons.self_improvement_rounded;
    case 'funeral':
      return Icons.volunteer_activism_rounded;
    case 'matchmaking':
      return Icons.favorite_rounded;
    case 'jobs':
      return Icons.work_outline_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'nagarik':
      return Icons.account_balance_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

Color _moduleColor(String module) {
  switch (module) {
    case 'blood':
      return const Color(0xFFC0392B);
    case 'ambulance':
      return const Color(0xFFE84C1E);
    case 'healthcare':
      return const Color(0xFF1A3A8F);
    case 'services':
    case 'home_service':
      return const Color(0xFF16A085);
    case 'physio':
      return const Color(0xFF8E44AD);
    case 'funeral':
      return const Color(0xFF34495E);
    case 'matchmaking':
      return const Color(0xFFE91E63);
    case 'jobs':
      return const Color(0xFF2980B9);
    case 'education':
      return const Color(0xFFF39C12);
    case 'nagarik':
      return const Color(0xFF27AE60);
    default:
      return const Color(0xFF64748B);
  }
}

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ServiceAppBar(
        title: 'My Orders',
        subtitle: '${controller.total}টি অর্ডার · সব সেবা',
      ),
      body: GetBuilder<OrdersController>(
        builder: (con) {
          if (con.loading && con.orders.isEmpty) {
            return const SnListSkeleton(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 16));
          }
          if (con.orders.isEmpty) {
            return const _Empty();
          }
          return RefreshIndicator(
            color: AppColors.brandOrange,
            onRefresh: con.fetchOrders,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: con.orders
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _OrderCard(order: o),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 140),
        Icon(Icons.receipt_long_outlined,
            size: 56, color: Colors.black.withValues(alpha: 0.18)),
        const SizedBox(height: 14),
        const Center(
          child: Text('No orders yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text('Your activity across all services appears here.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final HomeOrder order;

  @override
  Widget build(BuildContext context) {
    final color = _moduleColor(order.module);
    final subtitle = [order.typeLabel, order.createdLabel]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return GestureDetector(
      onTap: () => ServiceNav.openByKey(order.module),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_moduleIcon(order.module), color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (order.statusLabel.isNotEmpty) _StatusPill(order: order),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.order});
  final HomeOrder order;
  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (order.isDone) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (order.isCancelled) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        order.statusLabel,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
