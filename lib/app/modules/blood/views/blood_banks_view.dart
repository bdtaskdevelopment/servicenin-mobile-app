import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/values/app_colors.dart';
import '../../../core/values/app_url.dart';
import '../../../data/models/response/blood_bank_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../controllers/blood_controller.dart';

const _red = Color(0xFFE5383B);
const _amberTile = Color(0xFFFEF3C7);
const _green = Color(0xFF16A34A);

class BloodBanksView extends GetView<BloodController> {
  const BloodBanksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: GetBuilder<BloodController>(
          initState: (_) => controller.fetchBanks(),
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
                      icon: const Icon(LucideIcons.chevronLeft, size: 22, color: Color(0xFF0F172A)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Other blood banks'.tr,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 1),
                        Text('Registered blood banks in Dhaka'.tr,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: _SearchBar(onChanged: con.searchBanks),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HotlineBanner(),
              ),
              const SizedBox(height: 10),
              Expanded(child: _Body(con: con)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF94A3B8)),
          hintText: 'Search blood bank or area'.tr,
          hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFFB6C0CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _HotlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/support-center',
          arguments: {'title': 'Blood Support'.tr, 'endpoint': ApiURL.bloodHotlines}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            const Icon(LucideIcons.phone, size: 16, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Call our hotline for an urgent need'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.con});
  final BloodController con;

  @override
  Widget build(BuildContext context) {
    if (con.loadingBanks && con.banks.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.fromLTRB(16, 8, 16, 24));
    }
    if (con.banks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        children: [
          Icon(LucideIcons.building2, size: 56, color: Colors.black.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Text('No blood banks found'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        ...con.banks.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BankRow(bank: b),
            )),
        const SizedBox(height: 8),
        Center(
          child: Text('List is updated manually from the admin panel'.tr,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB6C0CC))),
        ),
      ],
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({required this.bank});
  final BloodBank bank;

  Future<void> _call() async {
    if (bank.phone.isEmpty) return;
    try {
      await launchUrl(Uri.parse('tel:${bank.phone}'), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _amberTile, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.building2, size: 19, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(bank.area.isNotEmpty ? bank.area : bank.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(bank.phone.isEmpty ? '[${'Add number'.tr}]' : bank.phone,
                    style: TextStyle(fontSize: 11.5, color: bank.phone.isEmpty ? const Color(0xFFCBD5E1) : const Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: bank.phone.isEmpty ? null : _call,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: bank.phone.isEmpty ? const Color(0xFFCBD5E1) : _green, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.phone, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Call'.tr, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
