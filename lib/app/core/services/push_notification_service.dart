import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/repositories/home.repo.dart';
import '../../data/services/storage.service.dart';
import '../values/storage.dart';

/// Handles a message that arrived while the app was backgrounded/terminated.
/// Must be a top-level (or static) function — the plugin runs it in its own
/// isolate. Our messages always carry a "notification" payload, which the
/// OS already renders as a system notification on its own, so there is
/// nothing else to do here; this only exists so the plugin has a handler
/// registered.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Registers this device for push notifications and keeps the backend's
/// copy of the FCM token in sync. Call [init] once at app start (after
/// `Firebase.initializeApp()`) and [syncToken] again right after login —
/// the token may already exist before the user is authenticated, in which
/// case there was nothing to attach it to until now.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _listenersReady = false;

  Future<void> init() async {
    await _requestPermission();
    if (!_listenersReady) {
      _listenersReady = true;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      // No foreground display here on purpose — NotificationSocketService's
      // WebSocket connection already shows a snackbar for this same event
      // while the app is open. FCM's job is the background/closed case,
      // where the OS shows the system notification on its own since our
      // messages carry a "notification" payload; showing it again here
      // would duplicate the WebSocket's snackbar.
      _messaging.onTokenRefresh.listen(_sendToken);
    }
    await syncToken();
  }

  /// Re-sends the current device token to the backend, if a user is
  /// currently signed in. Safe to call as often as needed (e.g. right
  /// after login) — a no-op if there's no token yet or no signed-in user.
  Future<void> syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _sendToken(token);
    } catch (_) {
      // Token retrieval can fail (e.g. Play Services unavailable) — push
      // just stays off for this session, nothing else depends on it.
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+'s runtime POST_NOTIFICATIONS permission; no-op (and no
      // prompt) on older versions where it's granted at install time.
      await Permission.notification.request();
    }
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _sendToken(String token) async {
    if (token.isEmpty) return;
    final accessToken = StorageService.getString(StorageConstants.accessToken);
    if (accessToken.isEmpty) return;
    try {
      await Get.find<HomeRepository>().registerDeviceToken(token);
    } catch (_) {
      // Best-effort — a failed registration just means no push until the
      // next successful sync (app restart, token refresh, or next login).
    }
  }
}
