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

  /// The booking's payment ledger + running balance — the outstanding
  /// figure "pay online" needs, since the booking itself only carries a
  /// coarse paid|partial|unpaid status.
  Future<ServicePaymentSummary> fetchPaymentSummary(String id) async {
    final res = await provider.getData(ApiURL.serviceBookingPayments(id));
    return ServicePaymentSummary.fromResponse(_payload(res));
  }

  /// Pays [amount] towards the booking's outstanding balance via an online
  /// gateway. The backend re-verifies [valId] against the gateway itself —
  /// the client can't just claim success — and rejects anything but an
  /// online method for a customer (cash must come from the provider's app).
  /// Returns the fresh ledger so the UI's outstanding figure updates
  /// immediately without a second round-trip.
  Future<ServicePaymentSummary> payBookingOnline(
    String id, {
    required String method,
    required double amount,
    String? valId,
    String? tranId,
    String? notes,
  }) async {
    final res = await provider.postData(ApiURL.serviceBookingPayments(id), {
      'method': method,
      'amount': amount,
      if (valId != null && valId.isNotEmpty) 'val_id': valId,
      if (tranId != null && tranId.isNotEmpty) 'tran_id': tranId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return ServicePaymentSummary.fromResponse(_payload(res));
  }

  /// Redeems a promo code against an EXISTING booking's outstanding balance
  /// — for a citizen who didn't have (or didn't use) a code at checkout.
  /// Owner (or admin) only; the server rejects everyone else, a code already
  /// applied to this booking, or a locked booking. Returns the whole
  /// booking with Subtotal/VATAmount/Amount/PromoDiscount already
  /// recomputed, same "adopt the returned booking wholesale" contract as
  /// the other editing mutations above.
  Future<ServiceBooking> applyPromoCode(String bookingId, String code) async {
    final res = await provider
        .patchData(ApiURL.serviceBookingPromo(bookingId), {'code': code});
    final body = _payload(res);
    final data = body is Map ? body['data'] : null;
    if (data is Map && data['booking'] is Map) {
      return ServiceBooking.fromMap(
          (data['booking'] as Map).cast<String, dynamic>());
    }
    throw Exception('প্রোমো কোড প্রয়োগ করা যায়নি');
  }

  Future<AuthSimpleResponse> rate(
      String id, int stars, String comment) async {
    final res = await provider.postData(
        ApiURL.serviceBookingRating(id), {'stars': stars, 'comment': comment});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  /// The customer's own rating for this booking, if already submitted —
  /// `null` when they haven't reviewed yet. Used to lock the review form
  /// against a second submission (the server rejects it anyway, but the UI
  /// should never let the customer try in the first place).
  Future<Map<String, dynamic>?> fetchMyReview(String bookingId) async {
    final res = await provider.getData(ApiURL.serviceBookingRatings(bookingId));
    final body = _payload(res);
    final data = body is Map ? body['data'] : null;
    if (data is List) {
      for (final item in data) {
        if (item is Map && item['direction'] == 'customer_to_provider') {
          return {
            'stars': item['stars'],
            'comment': (item['comment'] ?? '').toString(),
            // pending | approved | rejected — the provider's contact
            // options stay available until an admin APPROVES the review.
            'moderation_status':
                (item['moderation_status'] ?? '').toString(),
          };
        }
      }
    }
    return null;
  }

  /// Answers the post-review "will you book this service again?" popup.
  Future<AuthSimpleResponse> submitReorderInterest(
      String bookingId, bool wantsReorder) async {
    final res = await provider.postData(
        ApiURL.serviceBookingReorderInterest(bookingId),
        {'wants_reorder': wantsReorder});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<AuthSimpleResponse> dispute(
      String id, String reason, String description) async {
    final res = await provider.postData(ApiURL.serviceBookingDispute(id),
        {'reason': reason, 'description': description});
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  // ── Editing a placed order ──────────────────────────────────────────
  // Every mutation returns the whole booking with totals already
  // recomputed, so callers replace their copy wholesale rather than
  // patching it locally and risking a divergent invoice.

  /// Adds one or more service jobs. Prices come from the catalogue
  /// server-side; sending them would be ignored.
  Future<ServiceBooking> addBookingTasks(
      String bookingId, List<Map<String, dynamic>> items) async {
    final res = await provider
        .postData(ApiURL.serviceBookingTasks(bookingId), {'items': items});
    return ServiceBooking.fromResponse(_payload(res));
  }

  /// Changes the quantity and/or note on one job. Both are optional, but
  /// the server rejects a request that sets neither.
  Future<ServiceBooking> updateBookingTask(
    String bookingId,
    String itemId, {
    int? quantity,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (quantity != null) body['quantity'] = quantity;
    if (notes != null) body['notes'] = notes;
    final res = await provider.patchData(
        ApiURL.serviceBookingTask(bookingId, itemId), body);
    return ServiceBooking.fromResponse(_payload(res));
  }

  Future<ServiceBooking> removeBookingTask(
      String bookingId, String itemId) async {
    final res = await provider
        .deleteData(ApiURL.serviceBookingTask(bookingId, itemId));
    return ServiceBooking.fromResponse(_payload(res));
  }

  /// Parts catalogue for a category — what can be added as materials.
  Future<List<ServiceItem>> fetchCategoryItems(String categoryId) async {
    final res =
        await provider.getData(ApiURL.servicesCategoryItems(categoryId));
    return ServiceItem.listFromResponse(_payload(res));
  }

  /// Adds a part. The server decrements stock in the same transaction and
  /// rejects the request if there isn't enough.
  ///
  /// Responds with `{extra_item, booking}` rather than a bare booking, so
  /// this unwraps the nested booking to match the other mutations.
  Future<ServiceBooking> addExtraItem(
      String bookingId, String itemId, double quantity) async {
    final res = await provider.postData(
      ApiURL.serviceBookingExtraItems(bookingId),
      {'item_id': itemId, 'quantity': quantity},
    );
    final body = _payload(res);
    final data = body is Map ? body['data'] : null;
    if (data is Map && data['booking'] is Map) {
      return ServiceBooking.fromMap(
          (data['booking'] as Map).cast<String, dynamic>());
    }
    return ServiceBooking.fromResponse(body);
  }

  Future<ServiceBooking> removeExtraItem(
      String bookingId, String extraItemId) async {
    final res = await provider
        .deleteData(ApiURL.serviceBookingExtraItem(bookingId, extraItemId));
    return ServiceBooking.fromResponse(_payload(res));
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
