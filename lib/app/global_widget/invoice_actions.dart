import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/helpers/invoice_helper.dart';
import '../core/values/app_colors.dart';

/// "View invoice" + "Download" buttons that fetch the module's invoice PDF.
/// Drop into any booking-detail screen with the relative view/download paths.
class InvoiceActions extends StatelessWidget {
  const InvoiceActions({
    super.key,
    required this.viewPath,
    required this.downloadPath,
    this.fileName = 'invoice',
    this.accent = AppColors.brandOrange,
  });

  final String viewPath;
  final String downloadPath;
  final String fileName;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _btn(
            icon: Icons.visibility_outlined,
            label: 'View invoice'.tr,
            filled: false,
            onTap: () => InvoiceHelper.view(viewPath, name: fileName),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _btn(
            icon: Icons.download_rounded,
            label: 'Download'.tr,
            filled: true,
            onTap: () => InvoiceHelper.download(downloadPath, name: fileName),
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
