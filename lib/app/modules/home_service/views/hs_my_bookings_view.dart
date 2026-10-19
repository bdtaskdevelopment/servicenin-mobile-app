import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_config.dart';
import '../../../data/models/response/service_response.dart';
import '../../../global_widget/home_service_status_widgets.dart';
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

/// A per-category accent (icon + color) so the list reads as a colorful mix
/// of trades rather than one flat teal tile repeated on every card.
/// Keyword-matched against whatever category/service text the booking
/// carries — there's no dedicated icon/color field on the API today, and
/// this needs no backend change to light the page up.
class _CategoryStyle {
  const _CategoryStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}

const List<MapEntry<String, _CategoryStyle>> _categoryStyles = [
  MapEntry('ac ', _CategoryStyle(Icons.ac_unit_rounded, Color(0xFF0EA5E9))),
  MapEntry('air con', _CategoryStyle(Icons.ac_unit_rounded, Color(0xFF0EA5E9))),
  MapEntry('plumb', _CategoryStyle(Icons.plumbing_rounded, Color(0xFFF59E0B))),
  MapEntry('electric', _CategoryStyle(Icons.bolt_rounded, Color(0xFF8B5CF6))),
  MapEntry('clean', _CategoryStyle(Icons.cleaning_services_rounded, Color(0xFFEC4899))),
  MapEntry('pest', _CategoryStyle(Icons.pest_control_rounded, Color(0xFF16A34A))),
  MapEntry('appliance', _CategoryStyle(Icons.build_circle_rounded, Color(0xFF6366F1))),
  MapEntry('carpentr', _CategoryStyle(Icons.handyman_rounded, Color(0xFFF97316))),
  MapEntry('salon', _CategoryStyle(Icons.content_cut_rounded, Color(0xFFD946EF))),
  MapEntry('car wash', _CategoryStyle(Icons.local_car_wash_rounded, Color(0xFF06B6D4))),
];

_CategoryStyle _styleFor(ServiceBooking b) {
  final hay =
      '${b.categoriesLabel} ${b.categoryName} ${b.servicesLabel}'.toLowerCase();
  for (final e in _categoryStyles) {
    if (hay.contains(e.key)) return e.value;
  }
  return const _CategoryStyle(Icons.home_repair_service_rounded, _teal);
}

class HsMyBookingsView extends GetView<HomeServiceController> {
  const HsMyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: GetBuilder<HomeServiceController>(
          builder: (con) => Column(
            children: [
              _Header(count: con.myBookings.length),
              Expanded(
                child: RefreshIndicator(
                  color: _darkTeal,
                  onRefresh: controller.fetchMyBookings,
                  child: Builder(
                    builder: (context) {
                      if (con.loadingMyBookings && con.myBookings.isEmpty) {
                        return const SnListSkeleton();
                      }
                      if (con.myBookings.isEmpty) {
                        return ListView(
                          children: const [
                            SizedBox(height: 100),
                            _EmptyState(),
                          ],
                        );
                      }
                      return FadeInUp(
                        from: 18,
                        duration: const Duration(milliseconds: 350),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                          children: con.myBookings
                              .map((b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
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
      ),
    );
  }
}

/// Teal gradient banner (matches the rest of the home-service module's
/// category headers) with a live count pill, instead of a plain white app
/// bar — the first thing that made the page feel flat.
class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _darkTeal],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Row(
        children: [
          IconButton(
            splashRadius: 22,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.white),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My bookings'.tr,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 1),
                Text('Tap a booking to track it'.tr,
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withValues(alpha: 0.82))),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _darkTeal)),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                  color: _tile, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 38, color: _teal),
            ),
            const SizedBox(height: 16),
            Text('No bookings yet.'.tr,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B))),
          ],
        ),
      );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.b});
  final ServiceBooking b;
  @override
  Widget build(BuildContext context) {
    final style = _styleFor(b);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: style.color.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              // A soft tint of the category color washes the card header so
              // every booking reads as its own trade at a glance.
              color: style.color.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(style.icon, color: style.color, size: 23),
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
                const SizedBox(width: 8),
                HomeServiceStatusChip(status: b.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: [
                // Provider identity shows once assigned; the call button is
                // withdrawn once the invoice is fully paid.
                if (b.provider != null) ...[
                  _ProviderRow(
                      provider: b.provider!,
                      canCall: !b.fullyPaid,
                      accent: style.color),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
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
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _darkTeal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Assigned provider strip: photo/initials, name, rating + a call button.
class _ProviderRow extends StatelessWidget {
  const _ProviderRow(
      {required this.provider, this.canCall = true, this.accent = _teal});
  final ServiceBookingProvider provider;
  final bool canCall;
  final Color accent;

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
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 1.6)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 36,
                height: 36,
                child: photo.isNotEmpty
                    ? Image.network(photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _initials())
                    : _initials(),
              ),
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
          if (canCall && provider.phone.isNotEmpty)
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
