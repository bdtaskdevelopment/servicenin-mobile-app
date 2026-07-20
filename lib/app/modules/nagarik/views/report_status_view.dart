import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_colors.dart';
import '../../../data/models/response/nagarik_response.dart';
import '../controllers/nagarik_controller.dart';

const _orange = Color(0xFFF15A24);
const _tile = Color(0xFFFCE6CB);

class ReportStatusView extends GetView<NagarikController> {
  const ReportStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: GetBuilder<NagarikController>(
          builder: (con) {
            final g = con.selectedGrievance;
            if (g == null) {
              return Center(child: Text('No report selected'.tr));
            }
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        splashRadius: 22,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: Color(0xFF1A1A1A)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Report status'.tr,
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A))),
                            Text(g.trackingCode,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      if (con.loadingGrievanceDetail)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: _orange),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    children: [
                      // Title row
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                color: _tile,
                                borderRadius: BorderRadius.circular(12)),
                            child: Icon(nagarikCategoryIcon(g.category),
                                color: _orange, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g.title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                Text(
                                    [g.address, g.wardNo.isNotEmpty ? 'Ward ${g.wardNo}' : '']
                                        .where((s) => s.isNotEmpty)
                                        .join(' · '),
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(g: g),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Photos
                      if (g.mediaUrls.where((u) => u.startsWith('http')).isNotEmpty)
                        _PhotoGallery(
                            urls: g.mediaUrls
                                .where((u) => u.startsWith('http'))
                                .toList()),
                      if (g.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(g.description,
                            style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF334155))),
                      ],
                      const SizedBox(height: 16),
                      // Meta chips
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (g.categoryLabel.isNotEmpty)
                            _MetaChip(Icons.category_outlined,
                                g.categoryLabel),
                          if (g.priority.isNotEmpty)
                            _MetaChip(Icons.flag_outlined,
                                '${g.priority[0].toUpperCase()}${g.priority.substring(1)} priority'),
                          if (g.upvoteCount > 0)
                            _MetaChip(Icons.thumb_up_outlined,
                                '${g.upvoteCount} upvotes'),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text('Progress'.tr,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: const Color(0xFFEDEFF2))),
                        child: _Timeline(g: g),
                      ),
                      const SizedBox(height: 18),
                      _VerificationSection(con: con, g: g),
                      if (g.createdLabel.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text('Filed ${g.createdLabel}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8))),
                      ],
                    ],
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

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          urls.first,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
        ),
      );
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            urls[i],
            height: 130,
            width: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: 150,
              child: _PhotoPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAED),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.photo_camera_outlined,
            color: Color(0xFFB0B6C0), size: 34),
      );
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEDEFF2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569))),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.g});
  final NagarikGrievance g;

  int get _index {
    switch (g.status) {
      case 'open':
      case 'submitted':
        return 0;
      case 'acknowledged':
      case 'assigned':
      case 'in_progress':
        return 1;
      case 'resolved':
      case 'closed':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Submitted to Nagarik Sheba'.tr,
      'Acknowledged & in progress'.tr,
      'Resolved & verified'.tr,
    ];
    final idx = _index;
    return Column(
      children: List.generate(titles.length, (i) {
        final state = i < idx
            ? 0
            : i == idx
                ? 1
                : 2;
        return _TimelineRow(
          title: titles[i],
          state: state,
          isLast: i == titles.length - 1,
        );
      }),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(
      {required this.title, required this.state, required this.isLast});
  final String title;
  final int state; // 0 done, 1 current, 2 pending
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    final done = state == 0;
    final current = state == 1;
    final active = done || current;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? _orange : Colors.transparent,
                  border: Border.all(
                      color: active ? _orange : const Color(0xFFCBD5E1),
                      width: 2.4),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? _orange : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 1, bottom: isLast ? 10 : 22),
              child: Text(title,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFB0B6C0))),
            ),
          ),
        ],
      ),
    );
  }
}

/// Citizen-verification section: confirm form when allowed, a confirmation
/// badge once verified, or an info note while awaiting.
class _VerificationSection extends StatelessWidget {
  const _VerificationSection({required this.con, required this.g});
  final NagarikController con;
  final NagarikGrievance g;

  @override
  Widget build(BuildContext context) {
    // Already verified by the reporter.
    if (g.verified) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF16A34A), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You verified this resolution'.tr,
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D))),
                      if (g.ratingAverage > 0)
                        Text(
                            '${g.ratingAverage.toStringAsFixed(1)} ★ '
                            '(${g.ratingCount} ${'ratings'.tr})',
                            style: const TextStyle(
                                fontSize: 12.5, color: Color(0xFF15803D))),
                    ],
                  ),
                ),
              ],
            ),
            if (g.verificationPhotoUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Your proof photo'.tr,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D))),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  g.verificationPhotoUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Reporter can verify now.
    if (g.canVerify) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDEFF2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify resolution'.tr,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text('The authority marked this resolved. Is it really fixed?'.tr,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF94A3B8))),
            const SizedBox(height: 14),
            // Stars
            Text('RATING'.tr,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.6)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (i) {
                final filled = i < con.verifyStars;
                return GestureDetector(
                  onTap: () => con.setVerifyStars(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 34,
                        color: const Color(0xFFF59E0B)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            // Comment
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEDEFF2))),
              child: TextField(
                controller: con.verifyComment,
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a comment (optional)'.tr,
                  hintStyle: const TextStyle(
                      fontSize: 13.5, color: Color(0xFF94A3B8)),
                ),
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 12),
            // Proof photo
            Row(
              children: [
                GestureDetector(
                  onTap: con.pickVerifyPhoto,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: _tile,
                        borderRadius: BorderRadius.circular(12),
                        image: con.verifyPhoto != null
                            ? DecorationImage(
                                image: FileImage(con.verifyPhoto!),
                                fit: BoxFit.cover)
                            : null),
                    child: con.verifyPhoto == null
                        ? const Icon(Icons.add_a_photo_outlined,
                            color: _orange, size: 22)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      con.verifyPhoto != null
                          ? 'Proof photo added · tap to change'.tr
                          : 'Add a proof photo (optional)'.tr,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF64748B))),
                ),
                if (con.verifyPhoto != null)
                  GestureDetector(
                    onTap: con.removeVerifyPhoto,
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: con.verifying
                          ? null
                          : () => con.submitVerification(confirmed: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: con.verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2, color: Colors.white))
                          : Text('Confirm fixed'.tr,
                              style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: con.verifying
                          ? null
                          : () => con.submitVerification(confirmed: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Not fixed'.tr,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Resolved but verification not open to this user.
    if (g.awaitingCitizenVerification) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.hourglass_bottom_rounded,
                color: Color(0xFFB45309), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Awaiting reporter verification.'.tr,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309))),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.g});
  final NagarikGrievance g;
  @override
  Widget build(BuildContext context) {
    final resolved = g.isResolved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: resolved
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle,
              size: 7,
              color: resolved
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFD97706)),
          const SizedBox(width: 5),
          Text(g.statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: resolved
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309))),
        ],
      ),
    );
  }
}
