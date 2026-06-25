import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_responder_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE11D48);
const _green = Color(0xFF15803D);

/// Donors who responded to a chosen request
/// (`GET /api/v1/blood/requests/:id/responders`). Each row can call/chat the
/// donor and confirm blood received.
class BloodRespondersView extends GetView<BloodController> {
  const BloodRespondersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) {
            final req = con.selectedMyRequest;
            return Column(
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
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
                          Text('Responders'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          if (req != null)
                            Text('${req.bloodGroup} · ${req.unitsNeeded} unit${req.unitsNeeded > 1 ? 's' : ''}',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                if (con.requestCompleted)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFDCFCE7),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 18, color: _green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Blood received — request fulfilled'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _green)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: con.loadingResponders && con.responders.isEmpty
                      ? const SnListSkeleton(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 24))
                      : RefreshIndicator(
                          onRefresh: con.fetchResponders,
                          color: _red,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            children: [
                              if (con.responders.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Text('No responders yet'.tr,
                                        style: const TextStyle(
                                            color: Color(0xFF94A3B8))),
                                  ),
                                )
                              else
                                ...con.responders
                                    .asMap()
                                    .entries
                                    .map((e) => FadeInUp(
                                          from: 18,
                                          duration: const Duration(
                                              milliseconds: 350),
                                          delay: Duration(
                                              milliseconds: 70 *
                                                  (e.key < 6 ? e.key : 6)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: _ResponderCard(
                                              r: e.value,
                                              con: con,
                                            ),
                                          ),
                                        )),
                            ],
                          ),
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

class _ResponderCard extends StatelessWidget {
  const _ResponderCard({required this.r, required this.con});
  final BloodResponder r;
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final disabled = con.requestCompleted;
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(r.initials,
                    style: const TextStyle(
                        color: _red,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 3),
                    Text(
                        [
                          if (r.distanceLabel.isNotEmpty) r.distanceLabel,
                          if (r.status.isNotEmpty) r.status,
                        ].join(' · '),
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (r.donorBloodGroup.isNotEmpty)
                BloodGroupBadge(group: r.donorBloodGroup),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: disabled ? null : () => con.callResponder(r),
                  icon: const Icon(Icons.call_outlined, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: Text('Call'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: disabled ? null : () => con.chatResponder(r),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  label: Text('Chat'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (disabled || con.completing)
                  ? null
                  : () => con.confirmReceived(r),
              icon: con.completing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 19),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              label: Text(
                  disabled ? 'Completed'.tr : 'Mark blood received'.tr,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
