import 'package:get/get.dart';

import '../../../core/helpers/snack_helper.dart';
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
