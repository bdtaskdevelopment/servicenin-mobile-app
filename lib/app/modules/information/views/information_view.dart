import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/info_response.dart';
import '../../../global_widget/sn_shimmer.dart';
import '../../../routes/app_pages.dart';
import '../controllers/information_controller.dart';

const _purple = Color(0xFF6366F1);

class InformationView extends GetView<InformationController> {
  const InformationView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Information',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      SizedBox(height: 1),
                      Text('Hotlines & civic directory',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.INFORMATION_HOTLINES),
                    child: const Icon(Icons.call_outlined,
                        color: Color(0xFF1A1A1A), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<InformationController>(
                builder: (con) => RefreshIndicator(
                  color: _purple,
                  onRefresh: () async {
                    await con.fetchInfo();
                    await con.fetchEmergency();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _NationalEmergencyCard(con: con),
                      const SizedBox(height: 18),
                      _EmergencySection(con: con),
                      _DirectorySection(con: con),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── National emergency hero card (driven by /api/v1/info/emergency) ──
class _NationalEmergencyCard extends StatelessWidget {
  const _NationalEmergencyCard({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final entry = con.nationalEmergency;
    final label = (entry?.title.isNotEmpty ?? false)
        ? entry!.title.toUpperCase()
        : 'NATIONAL EMERGENCY';
    final number =
        (entry?.hotline.isNotEmpty ?? false) ? entry!.hotline : '999';
    final subtitle = (entry?.titleBn.isNotEmpty ?? false)
        ? entry!.titleBn
        : 'পুলিশ · ফায়ার · আম্বুলেন্স';

    return GestureDetector(
      onTap: () => con.callHotline(number),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE8333A), Color(0xFFC2182B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6), width: 2),
              ),
              child: const Icon(Icons.call_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFFFDADE),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  Text(number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.call_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Emergency hotlines preview (driven by /api/v1/info/emergency) ────
class _EmergencySection extends StatelessWidget {
  const _EmergencySection({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final cards = con.emergencyCards;
    if (con.loadingEmergency && cards.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.zero, count: 4);
    }
    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Emergency hotlines',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.INFORMATION_HOTLINES),
              child: const Text('All →',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _purple)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...cards.take(4).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HotlineRow(entry: e, con: con),
            )),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ── Directory list (driven by /api/v1/info) ─────────────────────────
class _DirectorySection extends StatelessWidget {
  const _DirectorySection({required this.con});
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final cards = con.infoCards;

    if (con.loadingInfo && cards.isEmpty) {
      return const SnListSkeleton(padding: EdgeInsets.zero, count: 4);
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Directory',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        ...cards.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoCard(entry: e, con: con),
            )),
      ],
    );
  }
}

// ── Compact emergency call row ──────────────────────────────────────
class _HotlineRow extends StatelessWidget {
  const _HotlineRow({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => con.callHotline(entry.callNumber),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.emergency_share_rounded,
                  color: Color(0xFFE8333A), size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  if (entry.callNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(entry.callNumber,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE07A1F))),
                  ],
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Color(0xFFD9F7E6), shape: BoxShape.circle),
              child: const Icon(Icons.call_rounded,
                  color: Color(0xFF16A34A), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Directory entry card (tap → detail sheet) ───────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final subtitle = [entry.typeLabel, entry.address]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    return GestureDetector(
      onTap: () async {
        final detail = await con.fetchInfoById(entry.id);
        if (detail != null) {
          Get.bottomSheet(
            _InfoDetailSheet(entry: detail, con: con),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: entry.isEmergency
                      ? const Color(0xFFFDECEC)
                      : const Color(0xFFEEF0FB),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  entry.isEmergency
                      ? Icons.emergency_share_rounded
                      : Icons.account_balance_outlined,
                  color: entry.isEmergency
                      ? const Color(0xFFE8333A)
                      : _purple,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A))),
                      ),
                      if (entry.verified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 15, color: Color(0xFF16A34A)),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (entry.callNumber.isNotEmpty)
              GestureDetector(
                onTap: () => con.callHotline(entry.callNumber),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFD9F7E6),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.call_rounded,
                      size: 18, color: Color(0xFF16A34A)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet (driven by /api/v1/info/{id}) ───────────────
class _InfoDetailSheet extends StatelessWidget {
  const _InfoDetailSheet({required this.entry, required this.con});
  final InfoEntry entry;
  final InformationController con;

  @override
  Widget build(BuildContext context) {
    final location = [entry.district, entry.division]
        .where((s) => s.isNotEmpty)
        .join(', ');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Row(
            children: [
              if (entry.isEmergency)
                _Tag('Emergency', const Color(0xFFFDECEC),
                    const Color(0xFFE8333A)),
              if (entry.verified) ...[
                const SizedBox(width: 8),
                _Tag('Verified', const Color(0xFFDCFCE7),
                    const Color(0xFF15803D)),
              ],
              if (entry.typeLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                _Tag(entry.typeLabel, const Color(0xFFEEF0FB), _purple),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(entry.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          if (entry.titleBn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(entry.titleBn,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
          ],
          if (entry.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(entry.description,
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: Color(0xFF334155))),
          ],
          const SizedBox(height: 16),
          if (entry.address.isNotEmpty)
            _DetailRow(Icons.location_on_outlined, entry.address),
          if (location.isNotEmpty)
            _DetailRow(Icons.map_outlined, location),
          if (entry.officeHours.isNotEmpty)
            _DetailRow(Icons.schedule_rounded, entry.officeHours),
          if (entry.phone.isNotEmpty && entry.hotline.isEmpty)
            _DetailRow(Icons.call_outlined, entry.phone),
          const SizedBox(height: 12),
          if (entry.callNumber.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => con.callHotline(entry.callNumber),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8333A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.call_rounded, size: 20),
                label: Text('Call ${entry.callNumber}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.bg, this.fg);
  final String text;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
