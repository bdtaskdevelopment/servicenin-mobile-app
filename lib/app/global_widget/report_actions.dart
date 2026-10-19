import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/helpers/app_helper.dart';
import '../core/helpers/report_helper.dart';
import '../core/values/app_colors.dart';

/// "View report" + "Download" buttons for an already-accessible lab/X-ray
/// report URL — same two-button shape as InvoiceActions, but for a direct
/// file URL (PhysioAppointment.reportUrl) rather than this app's own
/// relative API paths.
class ReportActions extends StatelessWidget {
  const ReportActions({
    super.key,
    required this.reportUrl,
    this.fileName = 'report',
    this.accent = AppColors.brandOrange,
  });

  final String reportUrl;
  final String fileName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(
            icon: Icons.visibility_outlined,
            label: 'View report'.tr,
            filled: false,
            onTap: () => Helpers.launchWebsite(reportUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _btn(
            icon: Icons.download_rounded,
            label: 'Download'.tr,
            filled: true,
            onTap: () => ReportHelper.download(reportUrl, name: fileName),
          ),
        ),
      ],
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final fg = filled ? Colors.white : accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? accent : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? accent : accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
          ],
        ),
      ),
    );
  }
}
