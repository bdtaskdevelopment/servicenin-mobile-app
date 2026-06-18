import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/blood_controller.dart';
import '../widgets/blood_widgets.dart';

const _red = Color(0xFFE11D48);
const _label = Color(0xFF14B8A6);

class DonorDetailView extends GetView<BloodController> {
  const DonorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final donor = controller.viewingDonor;
    if (donor == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: Column(
            children: [
              _BackBar(title: 'Donor'.tr, subtitle: ''),
              Expanded(
                child: Center(
                  child: Text('Donor not found'.tr,
                      style: const TextStyle(color: Color(0xFF94A3B8))),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final name = donor.fullName.isNotEmpty ? donor.fullName : 'ServiceNin Donor';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _BackBar(title: 'Donor'.tr, subtitle: donor.bloodGroup),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                children: [
                  // Detail card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BloodGroupBadge(group: donor.bloodGroup, size: 52),
                            const SizedBox(width: 14),
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
                                            style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A))),
                                      ),
                                      if (donor.isVerified) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified_rounded,
                                            size: 18, color: Color(0xFF16A34A)),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (donor.badgeLevel.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFE5E9F0),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(
                                              donor.badgeLevel[0].toUpperCase() +
                                                  donor.badgeLevel.substring(1),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF475569))),
                                        ),
                                      const SizedBox(width: 8),
                                      if (donor.isAvailable)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(
                                              Get.locale?.languageCode == 'bn'
                                                  ? 'অ্যাভেইলেবল'
                                                  : 'Available',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF15803D))),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ),
                        _InfoRow(
                          icon: Icons.water_drop_outlined,
                          label: 'Total donations'.tr,
                          value: '${donor.totalDonations}',
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.event_available_outlined,
                          label: 'Last donated'.tr,
                          value: donor.lastDonatedLabel.isNotEmpty
                              ? donor.lastDonatedLabel
                                  .replaceFirst('Last donated ', '')
                              : 'Not recorded'.tr,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Area'.tr,
                          value: donor.address.isNotEmpty
                              ? donor.address
                              : 'Not shared'.tr,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.call_outlined,
                          label: 'Phone'.tr,
                          value: donor.phone.isNotEmpty
                              ? donor.phone
                              : 'Not available'.tr,
                        ),
                        if (donor.notes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(donor.notes,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF475569),
                                    height: 1.4)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom action row
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      // You can't call yourself — hide the call button on your
                      // own donor profile and show a note instead.
                      child: controller.isMyDonor(donor)
                          ? Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFFECDD3)),
                              ),
                              child: Text('This is your donor profile'.tr,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE11D48))),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => controller.callPhone(donor.phone),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.call_rounded, size: 20),
                              label: Text('Call donor'.tr,
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A))),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFDE4E4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: _red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _label)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }
}
