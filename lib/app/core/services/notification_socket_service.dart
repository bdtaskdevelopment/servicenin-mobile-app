import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../values/app_config.dart';
import '../values/storage.dart';
import '../../data/models/response/notification_response.dart';
import '../../data/services/storage.service.dart';
import '../../global_widget/notification_banner.dart';
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
      if (env is! Map || env['event'] != 'notification') return;
      final data = env['data'];
      if (data is! Map) return;

      final n = AppNotification(data.cast<String, dynamic>());

      // 1) Feed detail pages so an open page updates itself in place.
      _notifications.add(n);

      // 2) Show a tappable banner that deep-links to the affected page.
      if (n.body.isNotEmpty || n.title.isNotEmpty) {
        showNotificationBanner(
          n,
          onTap: () => NotificationRouter.instance.handleNotification(n),
        );
      }
    } catch (_) {
      // Malformed/unexpected frame — ignore, next message may be fine.
    }
  }
}
