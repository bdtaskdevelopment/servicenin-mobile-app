import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/ambulance_booking_response.dart';
import '../../../data/models/response/ambulance_response.dart';

const _red = Color(0xFFE23744);
const _navy = Color(0xFF1E2A4A);
const _green = Color(0xFF16A34A);

/// Popup shown right after a booking is created — a "Thank you" message
/// with a single Done button the caller awaits before navigating on.
class BookingThankYouDialog extends StatelessWidget {
  const BookingThankYouDialog({super.key, required this.bookingNo});
  final String bookingNo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _green, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Thank you!'.tr,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Text(
              bookingNo.isNotEmpty
                  ? '${'Your ambulance booking has been confirmed.'.tr} ($bookingNo)'
                  : 'Your ambulance booking has been confirmed.'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Done'.tr,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single available-ambulance card (front page + "see all" list).
class AmbulanceCard extends StatelessWidget {
  const AmbulanceCard({super.key, required this.amb, required this.onTap});
  final Ambulance amb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (amb.vehicleModel.isNotEmpty) amb.vehicleModel,
      if (amb.serviceArea.isNotEmpty) amb.serviceArea,
    ].join(' · ');
    return GestureDetector(
      onTap: onTap,
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
                  color: _red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.airport_shuttle_rounded,
                  color: _red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amb.typeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(
                      subtitle.isNotEmpty
                          ? subtitle
                          : '৳${amb.baseFare} base · ৳${amb.perKmFare}/km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (amb.isAvailable)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    // Ambulance availability badge: "অ্যাভেইলেবল" in Bangla
                    // (not the shared "উপলব্ধ" used elsewhere for balances etc.).
                    Text(
                        Get.locale?.languageCode == 'bn'
                            ? 'অ্যাভেইলেবল'
                            : 'Available',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D))),
                  ],
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

/// A booking summary card (front page + "see all" + bookings list).
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.onTap});
  final AmbulanceBookingEntry booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ongoing = booking.ongoing;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.airport_shuttle_rounded,
                      color: Color(0xFF334155), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.bookingNo,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      Text(booking.typeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: ongoing
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel(booking.status),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ongoing
                              ? const Color(0xFFB45309)
                              : const Color(0xFF15803D))),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                const Icon(Icons.alt_route_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(booking.routeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF64748B))),
                ),
                Text(booking.fareLabel,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    if (s.isEmpty) return 'Pending'.tr;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }
}

/// The "Hotline 1 / Hotline 2 / Hotline 3" strip — admin-configured numbers
/// from `/api/v1/ambulance/hotlines`. Tapping a card dials that number.
class HotlineStrip extends StatelessWidget {
  const HotlineStrip(
      {super.key, required this.hotlines, required this.onCall});
  final List<AmbulanceHotline> hotlines;
  final ValueChanged<String> onCall;

  @override
  Widget build(BuildContext context) {
    if (hotlines.isEmpty) return const SizedBox.shrink();
    return Row(
      children: hotlines
          .asMap()
          .entries
          .map((e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: e.key == hotlines.length - 1 ? 0 : 10),
                  child: _HotlineCard(
                      hotline: e.value, onTap: () => onCall(e.value.number)),
                ),
              ))
          .toList(),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline, required this.onTap});
  final AmbulanceHotline hotline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.call_rounded, color: _red, size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    hotline.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A1520)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hotline.number,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }
}
