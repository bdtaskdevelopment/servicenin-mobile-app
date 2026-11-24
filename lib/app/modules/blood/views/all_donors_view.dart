import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/donor_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/blood_controller.dart';
import '../controllers/need_blood_controller.dart';

const _red = Color(0xFFE5383B);
const _orange = Color(0xFFEA5A0C);
const _green = Color(0xFF16A34A);

/// "কাছাকাছি ডোনার" — donors near the viewer's current location, filterable
/// by distance (10/20/50/all km). Repurposes the formerly-unbounded "all
/// donors" screen (route BLOOD_DONORS had zero live callers before this
/// redesign) to show `fetchNearestDonors()`'s data instead.
class AllDonorsView extends GetView<BloodController> {
  const AllDonorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          builder: (con) => Column(
            children: [
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
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
                        Text('Nearby donors'.tr,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('Near your current location'.tr,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 6, color: _green),
                          const SizedBox(width: 4),
                          Text('Live'.tr,
                              style: const TextStyle(
                                  fontSize: 10.5, fontWeight: FontWeight.w800, color: _green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.droplet, size: 14, color: _red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${'Blood group'.tr} ${con.myDonor?.bloodGroup ?? '-'} · ${con.area}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final km in NeedBloodController.radiusOptions) ...[
                          Expanded(
                            child: _RadiusChip(
                                km: km,
                                selected: con.donorRadiusKm == km,
                                onTap: () => con.setDonorRadius(km)),
                          ),
                          if (km != NeedBloodController.radiusOptions.last) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(
                    '${con.donorRadiusKm == 0 ? 'All over'.tr : '${con.donorRadiusKm} ${'km'.tr}'} ${'within'.tr} · ${con.visibleNearestDonors.length} ${'donors found'.tr}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ),
              Expanded(child: _Body(con: con)),
              _BottomBar(con: con),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.km, required this.selected, required this.onTap});
  final int km;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _red : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _red : const Color(0xFFE2E8F0)),
        ),
        child: Text(km == 0 ? 'All over'.tr : '$km km',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF334155))),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingNearest && con.nearestDonors.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    final items = con.visibleNearestDonors;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: con.fetchNearestDonors,
        color: _red,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
          children: [
            Icon(LucideIcons.users, size: 56, color: Colors.black.withValues(alpha: 0.12)),
            const SizedBox(height: 12),
            Text('No donors found'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: con.fetchNearestDonors,
      color: _red,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ...items.toList().asMap().entries.map((e) => FadeInUp(
                from: 18,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: 60 * (e.key < 6 ? e.key : 6)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NearbyDonorRow(
                    donor: e.value,
                    highlighted: e.key == 0,
                    onCall: () => con.callPhone(e.value.phone),
                    onTap: () => con.viewDonor(e.value),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _NearbyDonorRow extends StatelessWidget {
  const _NearbyDonorRow({
    required this.donor,
    required this.highlighted,
    required this.onCall,
    required this.onTap,
  });
  final DonorEntry donor;
  final bool highlighted;
  final VoidCallback onCall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = donor.fullName.isNotEmpty ? donor.fullName : 'ServiceNin Donor';
    final dist = donor.distanceKm;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: highlighted ? Border.all(color: _red, width: 1.2) : null,
          boxShadow: highlighted
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.user, size: 20, color: Color(0xFF94A3B8)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: donor.isAvailable ? _green : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: donor.isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text((donor.isAvailable ? 'Online' : 'Unavailable').tr,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: donor.isAvailable ? _green : const Color(0xFF94A3B8))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                      '${'ID'.tr}: ${donor.id.isNotEmpty ? donor.id.substring(0, donor.id.length < 6 ? donor.id.length : 6).toUpperCase() : '-'} · ${donor.totalDonations} ${'donations'.tr}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                  if (dist != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 11, color: _red),
                        const SizedBox(width: 3),
                        Text(
                            dist < 1 ? '${(dist * 1000).round()} m' : '${dist.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _red)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: donor.isAvailable ? onCall : null,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: donor.isAvailable ? _green : AppColors.white,
                  shape: BoxShape.circle,
                  border: donor.isAvailable ? null : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(LucideIcons.phone,
                    size: 17, color: donor.isAvailable ? Colors.white : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.con});
  final BloodController con;

  Future<void> _shareLocation() async {
    final lat = con.userLat;
    final lng = con.userLng;
    if (lat == null || lng == null) {
      Get.snackbar('', 'অবস্থান পাওয়া যায়নি',
          snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(12));
      return;
    }
    try {
      await launchUrl(Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _shareLocation,
                icon: const Icon(LucideIcons.share2, size: 16),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: Text('Share location'.tr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.find<NeedBloodController>().startNew();
                  Get.toNamed(Routes.BLOOD_NEED);
                },
                icon: const Icon(LucideIcons.radio, size: 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: Text('Request everyone'.tr,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
