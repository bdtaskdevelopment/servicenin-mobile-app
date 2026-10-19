import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/home_service_status.dart';

const _darkTeal = Color(0xFF0E7C6B);
const _teal = Color(0xFF0E9F8E);

/// Small colored status pill for a home-service booking. Replaces three
/// byte-for-byte-identical private `_StatusChip` copies that used to live in
/// hs_tracking_view.dart, hs_booking_details_view.dart and
/// hs_my_bookings_view.dart, each with its own ad hoc label formatting that
/// didn't match the provider app's wording for `arrived`/`in_progress`.
class HomeServiceStatusChip extends StatelessWidget {
  const HomeServiceStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    // `closed` is the post-payment/post-rating archive state reached only
    // after `completed` — it reads as "done", not as an in-progress amber
    // pill the way it fell through before.
    final done = s == 'completed' || s == 'closed';
    final bad = s == 'cancelled' || s == 'canceled' || s == 'declined';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(homeServiceStatusLabel(status),
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

/// The full 6-step job-progress stepper, mirroring the provider app's own
/// "Job progress" card (job_detail_view.dart) — all 6 canonical phases are
/// always shown (done / active / upcoming), instead of only the entries the
/// backend has posted to the timeline so far. `timestamps` optionally maps a
/// lowercase status key to its already-formatted time label (from
/// `ServiceTimelineEntry.timeLabel`), shown under any step that's done.
class HomeServiceStatusStepper extends StatelessWidget {
  const HomeServiceStatusStepper({
    super.key,
    required this.status,
    this.timestamps = const {},
  });
  final String status;
  final Map<String, String> timestamps;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    if (s == 'cancelled' || s == 'canceled' || s == 'declined') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded,
                color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('This booking was cancelled.'.tr,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C))),
            ),
          ],
        ),
      );
    }

    final rank = homeServiceStatusRank(s);
    final steps = kHomeServiceCanonicalSteps;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final stepRank = homeServiceStatusRank(step);
          final done = rank >= stepRank;
          final active = rank == stepRank;
          final last = i == steps.length - 1;
          final time = timestamps[step];
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: done
                          ? _darkTeal
                          : (active ? _teal : const Color(0xFFCBD5E1)),
                    ),
                    if (!last)
                      Expanded(
                        child: Container(
                            width: 2,
                            color: done
                                ? const Color(0xFFB6E0D7)
                                : const Color(0xFFE2E8F0)),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: last ? 8 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(homeServiceStepLabel(step),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: (done || active)
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8))),
                        if (time != null && time.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(time,
                              style: const TextStyle(
                                  fontSize: 11.5, color: Color(0xFFE07A1F))),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
