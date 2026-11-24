import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/values/app_colors.dart';

/// Shown from the splash screen when the installed build is behind the
/// server's `app_version` (soft nudge, dismissible) or `min_app_version`
/// (hard block, no dismiss / no "Later") — both set from the admin panel's
/// Settings → App group, alongside the store URL to open.
class UpdateRequiredDialog extends StatelessWidget {
  const UpdateRequiredDialog({
    super.key,
    required this.forced,
    required this.storeUrl,
  });

  final bool forced;
  final String storeUrl;

  static Future<void> show({
    required bool forced,
    required String storeUrl,
  }) {
    return Get.dialog(
      PopScope(
        canPop: !forced,
        child: UpdateRequiredDialog(forced: forced, storeUrl: storeUrl),
      ),
      barrierDismissible: !forced,
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.tryParse(storeUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    // Soft nudge: let them into the app after sending them to the store —
    // forced stays up (no "Later" either) so coming back still blocks them.
    if (!forced) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brandOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.system_update_rounded,
                  color: AppColors.brandOrange, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              (forced ? 'Update Required' : 'Update Available').tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              (forced
                      ? 'This version of the app is no longer supported. Please update to continue.'
                      : 'A new version of the app is available with the latest features and fixes.')
                  .tr,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandOrange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _openStore,
                child: Text('Update Now'.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.5)),
              ),
            ),
            if (!forced) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Later'.tr,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
