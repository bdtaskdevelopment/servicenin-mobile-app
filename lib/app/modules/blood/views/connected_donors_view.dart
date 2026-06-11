import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE11D48);

class ConnectedDonorsView extends GetView<BloodController> {
  const ConnectedDonorsView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
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
                      Text('My donors'.tr,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('Donors you\'ve connected with'.tr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFDE4E4),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 18, color: _red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Saved after a successful donation — reach them directly next time you need blood.'.tr,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: Color(0xFF9F1239))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...con.connectedDonors.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DonorTile(donor: d, con: con),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonorTile extends StatelessWidget {
  const _DonorTile({required this.donor, required this.con});
  final ConnectedDonor donor;
  final BloodController con;

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
                    color: _red.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(donor.initials,
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
                    Text(donor.name,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text(donor.area,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFFDE4E4),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(donor.group,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _red)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 15, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(donor.lastDonation,
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
                    onPressed: () => con.callDonor(donor),
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
                    onPressed: () => con.openDonorChat(donor),
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
