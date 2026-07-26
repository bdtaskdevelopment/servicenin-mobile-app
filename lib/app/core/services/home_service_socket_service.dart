import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../values/app_config.dart';
import '../values/storage.dart';
import '../../data/services/storage.service.dart';

/// Realtime companion to the home-service REST APIs. Connects to the
/// backend's per-module WebSocket hub (`GET /api/v1/services/ws`) and lets
/// callers subscribe to topics — e.g. `booking:<id>:location`,
/// `booking:<id>:status` — to receive live pushes instead of polling.
///
/// Protocol mirrors the backend's `pkg/wsbus` hub: after connecting, send
/// `{"action":"subscribe","topic":"..."}` per topic; incoming frames are
/// `{"topic","event","data","ts"}` envelopes, re-emitted here verbatim via
/// [events] for callers to filter by topic.
class HomeServiceSocketService {
  HomeServiceSocketService._();
  static final HomeServiceSocketService instance =
      HomeServiceSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _closedByUs = false;
  final Set<String> _topics = {};

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Decoded envelopes for every currently-subscribed topic.
  Stream<Map<String, dynamic>> get events => _controller.stream;

  void connect() {
    if (_channel != null) return; // already connected
    final accessToken = StorageService.getString(StorageConstants.accessToken);
    if (accessToken.isEmpty) return;

    final base = AppConfig.baseUrl.trim();
    if (base.isEmpty) return;
    final wsBase = base
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final url = Uri.parse(
      '${wsBase.endsWith('/') ? wsBase.substring(0, wsBase.length - 1) : wsBase}'
      '/api/v1/services/ws?token=$accessToken',
    );

    _reconnectTimer?.cancel();
    _closedByUs = false;

    try {
      _channel = WebSocketChannel.connect(url);
      _sub = _channel!.stream.listen(
        _onMessage,
        onDone: _handleDrop,
        onError: (_) => _handleDrop(),
        cancelOnError: true,
      );
      // Re-establish whatever topics callers already asked for — covers
      // both the first connect and every reconnect after a drop.
      for (final t in _topics) {
        _send({'action': 'subscribe', 'topic': t});
      }
    } catch (_) {
      _channel = null;
      _scheduleReconnect();
    }
  }

  /// Subscribes to [topic], connecting first if needed. Safe to call
  /// repeatedly / before connect() resolves — the topic is remembered and
  /// re-sent on every (re)connect.
  void subscribe(String topic) {
    _topics.add(topic);
    connect();
    _send({'action': 'subscribe', 'topic': topic});
  }

  void unsubscribe(String topic) {
    _topics.remove(topic);
    _send({'action': 'unsubscribe', 'topic': topic});
  }

  /// Closes the connection. Only call this when no more topics are needed —
  /// prefer [unsubscribe] for a single booking's topics, since this socket
  /// is shared across the whole home-service module.
  void disconnect() {
    _closedByUs = true;
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _handleDrop() {
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_closedByUs || _topics.isEmpty) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {
      // Not connected yet / dropped — the topic is already remembered in
      // _topics and will be re-sent once connect() succeeds.
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final env = jsonDecode(raw as String);
      if (env is! Map) return;
      _controller.add(Map<String, dynamic>.from(env));
    } catch (_) {
      // Malformed/unexpected frame — ignore, next message may be fine.
    }
  }
}
