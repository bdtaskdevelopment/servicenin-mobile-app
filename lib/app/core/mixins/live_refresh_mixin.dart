import 'dart:async';

import 'package:get/get.dart';

import '../services/notification_socket_service.dart';

/// Makes a detail controller re-fetch itself the moment its own entity
/// changes, so the user never has to pull-to-refresh to see a new status.
///
/// It listens to the foreground notification feed (the backend writes a
/// notification AND broadcasts it on `user:<id>` for every status change —
/// see NotificationService.Push). When a notification arrives whose
/// `reference_type` is one this page cares about AND whose `reference_id`
/// matches the entity currently open, [onLiveRefresh] runs.
///
/// FCM covers the backgrounded case; this covers "app open, sitting on the
/// page". Home-service additionally has a dedicated per-booking socket
/// topic for richer live tracking — this is the generic catch-all.
mixin LiveRefreshMixin on GetxController {
  StreamSubscription<dynamic>? _liveRefreshSub;

  /// reference_types this page reacts to, e.g. {'grievance'} or
  /// {'service_booking', 'booking'}.
  Set<String> get liveRefreshTypes;

  /// Id of the entity currently open. A DETAIL page returns the open
  /// entity's id so it only reacts to its own changes. A LIST page returns
  /// '' (empty) to refresh on ANY notification of [liveRefreshTypes] —
  /// e.g. "my physio sessions" re-pulls whenever any session status moves.
  String get liveRefreshId;

  /// Re-fetch the open entity. Should be silent (no full-screen spinner) so
  /// the update feels seamless.
  Future<void> onLiveRefresh();

  /// Start listening. Call once from the controller's onInit.
  void startLiveRefresh() {
    _liveRefreshSub?.cancel();
    _liveRefreshSub = NotificationSocketService.instance.notifications.listen(
      (n) {
        if (!liveRefreshTypes.contains(n.referenceType.toLowerCase())) return;
        final id = liveRefreshId;
        // Detail pages pin to their own id; list pages leave it empty and
        // refresh on any notification of their type.
        if (id.isNotEmpty && n.referenceId != id) return;
        onLiveRefresh();
      },
    );
  }

  void stopLiveRefresh() {
    _liveRefreshSub?.cancel();
    _liveRefreshSub = null;
  }

  @override
  void onClose() {
    stopLiveRefresh();
    super.onClose();
  }
}
