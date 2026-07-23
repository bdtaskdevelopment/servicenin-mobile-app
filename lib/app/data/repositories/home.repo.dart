import '../../core/values/app_url.dart';
import '../models/response/home_response.dart';
import '../models/response/notification_response.dart';
import '../providers/home.provider.dart';

class HomeRepository {
  HomeRepository({required this.provider});

  final HomeProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map || body is List) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  // ── Home dashboard ────────────────────────────────────────────────
  Future<List<HomeBanner>> fetchBanners() async {
    final res = await provider.getData(ApiURL.homeBanners);
    return HomeBanner.listFromResponse(_payload(res));
  }

  Future<List<HomeService>> fetchServices() async {
    final res = await provider.getData(ApiURL.homeServices);
    return HomeService.listFromResponse(_payload(res));
  }

  Future<List<HomeService>> fetchTrending({int limit = 6}) async {
    final res = await provider.getData(ApiURL.homeTrending(limit: limit));
    return HomeService.listFromResponse(_payload(res));
  }

  Future<List<HomeService>> fetchPopular({int limit = 6}) async {
    final res = await provider.getData(ApiURL.homePopular(limit: limit));
    return HomeService.listFromResponse(_payload(res));
  }

  Future<List<HomeService>> fetchRecent({int limit = 6}) async {
    final res = await provider.getData(ApiURL.homeRecent(limit: limit));
    return HomeService.listFromResponse(_payload(res));
  }

  Future<List<HomeService>> search(String q) async {
    final res = await provider.getData(ApiURL.homeSearch(q));
    return HomeService.listFromResponse(_payload(res));
  }

  Future<HomeOrdersData> fetchMyOrders({int days = 60}) async {
    final res = await provider.getData(ApiURL.homeMyOrders(days: days));
    return HomeOrdersData.fromResponse(_payload(res));
  }

  // ── Notifications ─────────────────────────────────────────────────
  Future<List<AppNotification>> fetchNotifications() async {
    final res = await provider.getData(ApiURL.snNotifications);
    return AppNotification.listFromResponse(_payload(res));
  }

  Future<int> fetchUnreadCount() async {
    final res = await provider.getData(ApiURL.snNotificationsUnreadCount);
    return AppNotification.unreadFromResponse(_payload(res));
  }

  Future<void> markRead(String id) async {
    await provider.patchData(ApiURL.snNotificationRead(id));
  }

  Future<void> markAllRead() async {
    await provider.patchData(ApiURL.snNotificationsReadAll);
  }

  /// Registers (or clears, if [token] is empty) this device's FCM token
  /// against the signed-in user — called right after login and whenever
  /// Firebase rotates the token, so push notifications reach this device.
  Future<void> registerDeviceToken(String token) async {
    await provider.postData(ApiURL.snDeviceToken, {'fcm_token': token});
  }
}
