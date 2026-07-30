import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/response/notification_response.dart';

/// A tappable top banner for a foreground notification. Tapping it runs
/// [onTap] (the deep-link) and dismisses the banner.
///
/// De-duplicated by notification id: the same notification can reach the
/// app over both the WebSocket feed and FCM within a moment of each other,
/// and we only want one banner.
void showNotificationBanner(
  AppNotification n, {
  required VoidCallback onTap,
}) {
  if (n.id.isNotEmpty && _recentlyShown(n.id)) return;

  final title = n.title.trim().isEmpty ? 'ServiceNin' : n.title.trim();
  final body = n.body.trim();

  Get.snackbar(
    title,
    body,
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF0F172A),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    duration: const Duration(seconds: 4),
    isDismissible: true,
    icon: const Icon(Icons.notifications_active_rounded,
        color: Colors.white, size: 26),
    shouldIconPulse: true,
    mainButton: TextButton(
      onPressed: () {
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        onTap();
      },
      child: Text(
        'View'.tr,
        style: const TextStyle(
          color: Color(0xFFF59E0B),
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    onTap: (_) {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      onTap();
    },
  );
}

// ── de-dup (WS vs FCM foreground) ──────────────────────────────────────
final Map<String, DateTime> _shown = {};

bool _recentlyShown(String id) {
  final now = DateTime.now();
  // Drop stale entries so the map can't grow forever.
  _shown.removeWhere((_, t) => now.difference(t) > const Duration(minutes: 2));
  final last = _shown[id];
  if (last != null && now.difference(last) < const Duration(seconds: 8)) {
    return true;
  }
  _shown[id] = now;
  return false;
}
