import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/blood_donation_response.dart';
import '../../../data/models/response/blood_response_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE5383B);
const _maroon = Color(0xFF8E1B2C);
const _orange = Color(0xFFEA5A0C);

/// "আমার রক্তদান" — a 2-tab screen: ongoing responses (unchanged data) and
/// the new self-logged donation history (with photos).
class MyResponsesView extends GetView<BloodController> {
  const MyResponsesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5FA),
        body: SafeArea(
          child: GetBuilder<BloodController>(
            initState: (_) => controller.fetchMyDonations(),
            builder: (con) => Column(
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(LucideIcons.chevronLeft,
                            size: 22, color: Color(0xFF0F172A)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My donations'.tr,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A))),
                          const SizedBox(height: 1),
                          Text('How many times you\'ve donated'.tr,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SummaryCard(con: con),
                ),
                const SizedBox(height: 14),
                TabBar(
                  labelColor: _red,
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  indicatorColor: _red,
                  labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('${'Ongoing responses'.tr} (${con.myResponses.length})'),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('${'Donation history'.tr} (${con.myDonations.length})'),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RefreshIndicator(
                        onRefresh: con.fetchMyResponses,
                        color: _red,
                        child: _ResponsesBody(con: con),
                      ),
                      RefreshIndicator(
                        onRefresh: con.fetchMyDonations,
                        color: _red,
                        child: _DonationsBody(con: con),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final donor = con.myDonor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _maroon, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(donor?.initials ?? 'D',
                style: const TextStyle(color: _maroon, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor?.fullName.isNotEmpty == true ? donor!.fullName : 'ServiceNin Donor'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                    '${'Donor ID'.tr}: ${donor != null && donor.id.isNotEmpty ? donor.id.substring(0, donor.id.length < 6 ? donor.id.length : 6).toUpperCase() : '-'} · ${donor?.bloodGroup ?? '-'}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${donor?.totalDonations ?? 0}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              Text('${'total donations'.tr} · ${'bags'.tr}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponsesBody extends StatelessWidget {
  const _ResponsesBody({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingResponses && con.myResponses.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    if (con.myResponses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
        children: [
          Icon(LucideIcons.heart, size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text("You haven't responded to any requests yet".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
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

class _DonationsBody extends StatelessWidget {
  const _DonationsBody({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingDonations && con.myDonations.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (con.myDonations.any((d) => !d.hasPhoto))
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFFFFF4E8), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.camera, size: 16, color: _orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Upload your donation photo — it may feature in our magazine!'.tr,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4)),
                ),
              ],
            ),
          ),
        if (con.myDonations.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Text('No donations logged yet'.tr,
                  style: const TextStyle(color: Color(0xFF94A3B8))),
            ),
          )
        else
          ...con.myDonations.toList().asMap().entries.map((e) => FadeInUp(
                from: 18,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 60 * (e.key < 6 ? e.key : 6)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DonationRow(d: e.value),
                ),
              )),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: con.openAddDonation,
            icon: const Icon(LucideIcons.plus, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            label: Text('Add new donation'.tr, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _DonationRow extends StatelessWidget {
  const _DonationRow({required this.d});
  final BloodDonation d;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: d.hasPhoto ? const Color(0xFFFDECEC) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: d.hasPhoto ? null : Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid)),
            child: d.hasPhoto
                ? const Icon(LucideIcons.image, size: 18, color: _red)
                : const Icon(LucideIcons.camera, size: 18, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${d.bags} ${'bags'.tr}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: d.hasPhoto ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text((d.hasPhoto ? 'Photo added' : 'Photo pending').tr,
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: d.hasPhoto ? const Color(0xFF16A34A) : const Color(0xFF92400E))),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(d.hospitalName.isNotEmpty ? d.hospitalName : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 2),
                Text(d.dateLabel, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.res, required this.con});
  final BloodResponseEntry res;
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    final name = res.requesterName.isNotEmpty ? res.requesterName : 'Requester';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3))],
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
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(res.hospital.isNotEmpty ? res.hospital : '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(res.otpVerified ? LucideIcons.badgeCheck : LucideIcons.clock,
                  size: 15, color: res.otpVerified ? const Color(0xFF16A34A) : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    res.otpVerified
                        ? '${'Verified'.tr}${res.respondedLabel.isNotEmpty ? ' · ${res.respondedLabel}' : ''}'
                        : (res.respondedLabel.isNotEmpty ? res.respondedLabel : 'Awaiting verification'.tr),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                    icon: const Icon(LucideIcons.phone, size: 17),
                    label: Text('Call'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF334155),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    icon: const Icon(LucideIcons.messageCircle, size: 17),
                    label: Text('Message'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
