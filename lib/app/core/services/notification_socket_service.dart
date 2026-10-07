import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../values/app_config.dart';
import '../values/storage.dart';
import '../../data/models/response/notification_response.dart';
import '../../data/services/storage.service.dart';
import '../../global_widget/notification_banner.dart';
import '../../modules/home_service/bindings/home_service_binding.dart';
import '../../modules/home_service/controllers/home_service_controller.dart';
import 'notification_router.dart';

/// Realtime companion to the REST notification feed (`HomeRepository`'s
/// `fetchNotifications`/`fetchUnreadCount`). Connects to the backend's
/// WebSocket hub so a notification created while this screen isn't open
/// (e.g. an admin changing a physio appointment's status) shows up
/// immediately as a snackbar instead of only appearing next time the app
/// polls the REST feed.
///
/// This is the foreground-delivery half of the notification pipeline —
/// it's independent of Firebase/FCM (which additionally reaches the device
/// when the app is backgrounded or closed, once configured). Both read
/// from the exact same event: `NotificationService.Push` on the backend.
class NotificationSocketService {
  NotificationSocketService._();
  static final NotificationSocketService instance =
      NotificationSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _closedByUs = false;

  /// Every parsed `notification` event, re-broadcast so detail controllers
  /// can live-refresh when their own entity changes (see LiveRefreshMixin).
  /// Broadcast = multiple listeners, and late subscribers are fine since
  /// notifications are transient.
  final _notifications = StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get notifications => _notifications.stream;

  void connect() {
    final accessToken = StorageService.getString(StorageConstants.accessToken);
    if (accessToken.isEmpty) return;

    final base = AppConfig.baseUrl.trim();
    if (base.isEmpty) return;
    final wsBase = base
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final url = Uri.parse(
      '${wsBase.endsWith('/') ? wsBase.substring(0, wsBase.length - 1) : wsBase}'
      '/api/v1/notifications/ws?token=$accessToken',
    );

    // Tear down any previous connection WITHOUT going through disconnect() —
    // that sets _closedByUs = true, which would then make _scheduleReconnect
    // permanently no-op after the very next drop (e.g. a server restart).
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
    _closedByUs = false;

    try {
      _channel = WebSocketChannel.connect(url);
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _closedByUs = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_closedByUs) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), connect);
  }

  void _onMessage(dynamic raw) {
    try {
      final env = jsonDecode(raw as String);
      if (env is! Map) return;
      final event = env['event'];
      final data = env['data'];

      // Live PAYMENT POPUP: the provider just completed the job with a balance
      // owed → show the Cash/Online chooser straight away.
      if (event == 'payment_prompt') {
        if (data is Map) _handlePaymentPrompt(data.cast<String, dynamic>());
        return;
      }
      // Provider confirmed a cash payment → refresh the open booking and
      // celebrate. (The customer's own online payment also broadcasts this,
      // but that path already shows its own success, so we skip it below.)
      if (event == 'payment_recorded') {
        if (data is Map) _handlePaymentRecorded(data.cast<String, dynamic>());
        return;
      }

      if (event != 'notification') return;
      if (data is! Map) return;

      final n = AppNotification(data.cast<String, dynamic>());

      // 1) Feed detail pages so an open page updates itself in place.
      _notifications.add(n);

      // 2) Show a tappable banner that deep-links to the affected page —
      // EXCEPT for payment prompts/receipts, whose dedicated live events
      // (handled above) already drive a richer popup, so a banner on top would
      // be redundant.
      final rt = n.referenceType.trim().toLowerCase();
      final handledByPopup = rt == 'booking_payment' || rt == 'payment_received';
      if (!handledByPopup && (n.body.isNotEmpty || n.title.isNotEmpty)) {
        showNotificationBanner(
          n,
          onTap: () => NotificationRouter.instance.handleNotification(n),
        );
      }
    } catch (_) {
      // Malformed/unexpected frame — ignore, next message may be fine.
    }
  }

  void _handlePaymentPrompt(Map<String, dynamic> data) {
    final booking = data['booking'];
    final id = booking is Map ? (booking['id']?.toString() ?? '') : '';
    final outstanding = (data['outstanding'] as num?)?.toDouble();
    if (id.isEmpty) return;
    if (!Get.isRegistered<HomeServiceController>()) {
      HomeServiceBinding().dependencies();
    }
    Get.find<HomeServiceController>()
        .promptPaymentChoice(id, outstanding: outstanding);
  }

  void _handlePaymentRecorded(Map<String, dynamic> data) {
    final actor = (data['actor_role'] ?? '').toString();
    // Only the collector's action (provider/admin recorded cash) needs a
    // customer-facing acknowledgement here; a customer's own online payment is
    // already acknowledged in the pay flow.
    if (actor != 'provider' && actor != 'admin') return;
    final booking = data['booking'];
    final id = booking is Map ? (booking['id']?.toString() ?? '') : '';
    final fullyPaid = data['fully_paid'] == true;
    if (!Get.isRegistered<HomeServiceController>()) {
      HomeServiceBinding().dependencies();
    }
    Get.find<HomeServiceController>().onPaymentRecorded(id, fullyPaid: fullyPaid);
  }
}
