import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/service_response.dart';
import '../providers/service.provider.dart';

class ServiceRepository {
  ServiceRepository({required this.provider});

  final ServiceProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) {
      // Reject backend errors (HTTP 4xx/5xx or {success:false}) instead of
      // parsing the error body as a successful result.
      final code = res.statusCode;
      final failed = body['success'] == false || (code is int && code >= 400);
      if (failed) {
        final msg = (body['message'] ?? '').toString().trim();
        throw Exception(msg.isNotEmpty ? msg : 'অনুরোধটি সম্পন্ন করা যায়নি');
      }
      return body;
    }
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  // ── Catalog ─────────────────────────────────────────────────────────
  Future<List<ServiceCategory>> fetchCategories() async {
    final res = await provider.getData(ApiURL.servicesCategories);
    return ServiceCategory.listFromResponse(_payload(res));
  }

  Future<List<ServiceCategory>> fetchPopular(
      {int days = 7, int limit = 10}) async {
    final res =
        await provider.getData(ApiURL.servicesPopular(days: days, limit: limit));
    return ServiceCategory.popularFromResponse(_payload(res));
  }

  Future<ServiceSearchResult> search(String q) async {
    final res = await provider.getData(ApiURL.servicesSearch(q));
    return ServiceSearchResult.fromResponse(_payload(res));
  }

  Future<List<SubService>> fetchSubServices(String categoryId) async {
    final res = await provider.getData(ApiURL.servicesSubServices(categoryId));
    return SubService.listFromResponse(_payload(res));
  }

  // ── Booking inputs ──────────────────────────────────────────────────
  Future<List<ServiceScheduleDate>> fetchScheduleDates() async {
    final res = await provider.getData(ApiURL.servicesScheduleDates);
    return ServiceScheduleDate.listFromResponse(_payload(res));
  }

  Future<List<ServiceTimeSlot>> fetchTimeSlots(String date) async {
    final res = await provider.getData(ApiURL.servicesTimeSlots(date));
    return ServiceTimeSlot.listFromResponse(_payload(res));
  }

  Future<List<ServicePaymentMethod>> fetchPaymentMethods() async {
    final res = await provider.getData(ApiURL.servicesPaymentMethods);
    return ServicePaymentMethod.listFromResponse(_payload(res));
  }

  Future<String> fetchDefaultPaymentMethod() async {
    final res = await provider.getData(ApiURL.servicesPaymentMethods);
    return ServicePaymentMethod.defaultKey(_payload(res));
  }

  // ── Bookings ────────────────────────────────────────────────────────
  Future<ServiceBooking> book(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.servicesBook, payload);
    return ServiceBooking.fromResponse(_payload(res));
  }

  Future<List<ServiceBooking>> fetchMyBookings() async {
    final res = await provider.getData(ApiURL.servicesBookingsMy);
    return ServiceBooking.listFromResponse(_payload(res));
  }

  Future<ServiceBooking> fetchBooking(String id) async {
    final res = await provider.getData(ApiURL.serviceBooking(id));
    return ServiceBooking.fromResponse(_payload(res));
  }

  Future<List<ServiceTimelineEntry>> fetchTimeline(String id) async {
    final res = await provider.getData(ApiURL.serviceBookingTimeline(id));
    return ServiceTimelineEntry.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> rate(
      String id, int stars, String comment) async {
    final res = await provider.postData(
        ApiURL.serviceBookingRating(id), {'stars': stars, 'comment': comment});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<AuthSimpleResponse> dispute(
      String id, String reason, String description) async {
    final res = await provider.postData(ApiURL.serviceBookingDispute(id),
        {'reason': reason, 'description': description});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  // ── Chat ────────────────────────────────────────────────────────────
  Future<List<ServiceChatMessage>> fetchChat(String id) async {
    final res = await provider.getData(ApiURL.serviceBookingChat(id));
    return ServiceChatMessage.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> sendChat(String id, String message) async {
    final res = await provider
        .postData(ApiURL.serviceBookingChat(id), {'message': message});
    return AuthSimpleResponse.fromMap(_payload(res));
  }
}
