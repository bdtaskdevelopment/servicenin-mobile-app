import '../../core/values/app_url.dart';
import '../models/response/funeral_response.dart';
import '../providers/funeral.provider.dart';

class FuneralRepository {
  FuneralRepository({required this.provider});

  final FuneralProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<FuneralCoordinator> fetchCoordinator() async {
    final res = await provider.getData(ApiURL.funeralCoordinator);
    return FuneralCoordinator.fromResponse(_payload(res));
  }

  Future<List<FuneralServiceOption>> fetchServices() async {
    final res = await provider.getData(ApiURL.funeralServices);
    return FuneralServiceOption.listFromResponse(_payload(res));
  }

  Future<List<FuneralUnitModel>> fetchAvailableUnits() async {
    final res = await provider.getData(ApiURL.funeralUnitsAvailable);
    return FuneralUnitModel.listFromResponse(_payload(res));
  }

  Future<FuneralRequest> createRequest(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.funeralRequests, payload);
    return FuneralRequest.fromResponse(_payload(res));
  }

  Future<List<FuneralRequest>> fetchMyRequests() async {
    final res = await provider.getData(ApiURL.funeralRequestsMy);
    return FuneralRequest.listFromResponse(_payload(res));
  }
}
