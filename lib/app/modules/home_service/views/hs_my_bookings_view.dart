import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/home_service_controller.dart';

const _teal = Color(0xFF0E9F8E);
const _darkTeal = Color(0xFF0E7C6B);
const _tile = Color(0xFFE0F2EF);

/// Build an absolute URL for a provider photo, which may be absolute or a
/// server-relative path (`/static/uploads/...`).
String _providerPhotoUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}

Future<void> _callProvider(String phone) async {
  final digits = phone.trim();
  if (digits.isEmpty) return;
  try {
    await launchUrl(Uri.parse('tel:$digits'),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
}

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My bookings'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Tap a booking to track it'.tr,
                          style: const TextStyle(
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
                      return const SnListSkeleton();
                    }
                    if (con.myBookings.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 140),
                          Center(
                            child: Text('No bookings yet.'.tr,
                                style: const TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        ],
                      );
                    }
                    return FadeInUp(
                      from: 18,
                      duration: const Duration(milliseconds: 350),
                      child: ListView(
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
                      ),
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
                    Text(b.servicesLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(
                        b.categoriesLabel.isNotEmpty
                            ? '${b.categoriesLabel} · ${b.invoiceNo}'
                            : b.invoiceNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              _StatusChip(status: b.status),
            ],
          ),
          if (b.provider != null) ...[
            const SizedBox(height: 12),
            _ProviderRow(provider: b.provider!),
          ],
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

/// Assigned provider strip: photo/initials, name, rating + a call button.
class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.provider});
  final ServiceBookingProvider provider;

  @override
  Widget build(BuildContext context) {
    final photo = _providerPhotoUrl(provider.photoUrl);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F0EE)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 38,
              height: 38,
              child: photo.isNotEmpty
                  ? Image.network(photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _initials())
                  : _initials(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 1),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(provider.ratingLabel,
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B))),
                    if (provider.totalJobs > 0)
                      Text('  ·  ${provider.totalJobs} ${'jobs'.tr}',
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          if (provider.phone.isNotEmpty)
            GestureDetector(
              onTap: () => _callProvider(provider.phone),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: _darkTeal, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.call_rounded,
                    size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _initials() => Container(
        color: _tile,
        alignment: Alignment.center,
        child: Text(provider.initials,
            style: const TextStyle(
                color: _teal, fontSize: 13, fontWeight: FontWeight.w800)),
      );
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
