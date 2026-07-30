import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
import '../../../core/services/notification_router.dart';
import '../../../data/models/response/notification_response.dart';
import '../../../data/repositories/home.repo.dart';

class NotificationsController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();

  List<AppNotification> items = [];
  bool loading = false;
  String? error;
  int unreadCount = 0;

  bool get hasUnread => unreadCount > 0;

  @override
  void onInit() {
    super.onInit();
    fetchUnreadCount();
  }

  /// Called when the notifications screen opens.
  Future<void> load() async {
    await fetchNotifications();
    await fetchUnreadCount();
  }

  Future<void> fetchNotifications() async {
    loading = true;
    error = null;
    update();
    try {
      items = await _repo.fetchNotifications();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      SnackHelper.error(error!);
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount = await _repo.fetchUnreadCount();
      update();
    } catch (_) {}
  }

  /// Tapping a row marks it read AND deep-links to the entity it refers to.
  void openNotification(AppNotification n) {
    markRead(n); // fire-and-forget; navigation shouldn't wait on the PATCH
    NotificationRouter.instance.handleNotification(n);
  }

  /// The ✕ on a card: mark it read and remove it from the visible list.
  /// There is no delete endpoint, so this is a local, in-session dismiss —
  /// a full refresh can bring already-read notifications back.
  void dismiss(AppNotification n) {
    markRead(n);
    items.remove(n);
    update();
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    n.isRead = true;
    if (unreadCount > 0) unreadCount--;
    update();
    try {
      await _repo.markRead(n.id);
    } catch (_) {
      fetchUnreadCount();
    }
  }

  Future<void> markAllRead() async {
    for (final n in items) {
      n.isRead = true;
    }
    unreadCount = 0;
    update();
    try {
      await _repo.markAllRead();
    } catch (_) {
      fetchUnreadCount();
    }
  }
}
