import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/service_response.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

class HsMyBookingsView extends GetView<HomeServiceController> {
  const HsMyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My bookings',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Tap a booking to track it',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _darkTeal,
                onRefresh: controller.fetchMyBookings,
                child: GetBuilder<HomeServiceController>(
                  builder: (con) {
                    if (con.loadingMyBookings && con.myBookings.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2.6, color: _darkTeal),
                      );
                    }
                    if (con.myBookings.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 140),
                          Center(
                            child: Text('No bookings yet.',
                                style: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: con.myBookings
                          .map((b) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () => con.openBooking(b),
                                  child: _BookingCard(b: b),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.b});
  final ServiceBooking b;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _tile, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.home_repair_service_outlined,
                    color: _teal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(b.invoiceNo,
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              _StatusChip(status: b.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(b.whenLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF64748B))),
              ),
              Text(b.amountLabel,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final done = s == 'completed';
    final bad = s == 'cancelled' || s == 'canceled';
    final bg = bad
        ? const Color(0xFFFEE2E2)
        : done
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final fg = bad
        ? const Color(0xFFDC2626)
        : done
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    final label = status.isEmpty
        ? 'Pending'
        : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}
