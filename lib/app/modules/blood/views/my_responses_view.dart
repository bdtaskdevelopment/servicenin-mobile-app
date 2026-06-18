import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_response_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE11D48);

class MyResponsesView extends GetView<BloodController> {
  const MyResponsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) => Column(
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
                        Text('My responses'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('Requests you offered to donate'.tr,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const Spacer(),
                    if (con.loadingResponses && con.myResponses.isNotEmpty)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: _red),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: con.fetchMyResponses,
                  color: _red,
                  child: _body(con),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BloodController con) {
    if (con.loadingResponses && con.myResponses.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    if (con.myResponses.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text("You haven't responded to any requests yet".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8))),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ...con.myResponses.toList().asMap().entries.map((e) => FadeInUp(
              from: 18,
              duration: const Duration(milliseconds: 350),
              delay: Duration(milliseconds: 70 * (e.key < 6 ? e.key : 6)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ResponseCard(res: e.value, con: con),
              ),
            )),
      ],
    );
  }
}

// ── Status badge colours ────────────────────────────────────────────
// Status badge hidden for now — helpers kept (commented) for easy restore.
// ({Color bg, Color fg, String label}) _statusStyle(String status) {
//   final s = status.toLowerCase();
//   switch (s) {
//     case 'verified':
//     case 'completed':
//     case 'fulfilled':
//     case 'accepted':
//       return (
//         bg: const Color(0xFFDCFCE7),
//         fg: const Color(0xFF15803D),
//         label: _cap(s)
//       );
//     case 'pending':
//     case 'matched':
//       return (
//         bg: const Color(0xFFFEF3C7),
//         fg: const Color(0xFFB45309),
//         label: _cap(s)
//       );
//     case 'rejected':
//     case 'cancelled':
//     case 'canceled':
//     case 'expired':
//       return (
//         bg: const Color(0xFFFEE2E2),
//         fg: const Color(0xFFDC2626),
//         label: _cap(s)
//       );
//     default:
//       return (
//         bg: const Color(0xFFEEF2F7),
//         fg: const Color(0xFF475569),
//         label: s.isEmpty ? 'Pending' : _cap(s)
//       );
//   }
// }

// String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.res, required this.con});
  final BloodResponseEntry res;
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final name =
        res.requesterName.isNotEmpty ? res.requesterName : 'Requester';
    // final st = _statusStyle(res.status); // status hidden for now
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BloodGroupBadge(group: res.bloodGroup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(res.hospital.isNotEmpty ? res.hospital : '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              // Status badge hidden for now — no need to show response status.
              // const SizedBox(width: 8),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //   decoration: BoxDecoration(
              //       color: st.bg, borderRadius: BorderRadius.circular(20)),
              //   child: Text(st.label,
              //       style: TextStyle(
              //           fontSize: 11,
              //           fontWeight: FontWeight.w800,
              //           color: st.fg)),
              // ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                  res.otpVerified
                      ? Icons.verified_rounded
                      : Icons.schedule_rounded,
                  size: 15,
                  color: res.otpVerified
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    res.otpVerified
                        ? '${'Verified'.tr}${res.respondedLabel.isNotEmpty ? ' · ${res.respondedLabel}' : ''}'
                        : (res.respondedLabel.isNotEmpty
                            ? res.respondedLabel
                            : 'Awaiting verification'.tr),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => con.callPhone(res.phone),
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: Text('Call'.tr,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => con.openResponseChat(res),
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 18),
                    label: Text('Message'.tr,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
