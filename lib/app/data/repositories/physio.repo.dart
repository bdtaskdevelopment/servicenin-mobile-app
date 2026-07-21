import '../../core/values/app_url.dart';
import '../models/response/physio_response.dart';
import '../providers/physio.provider.dart';

class PhysioRepository {
  PhysioRepository({required this.provider});

  final PhysioProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<List<PhysioServiceItem>> fetchServices() async {
    final res = await provider.getData(ApiURL.physioServices);
    return PhysioServiceItem.listFromResponse(_payload(res));
  }

  Future<List<PhysioCenterModel>> fetchCentersForService(
      String serviceId) async {
    final res =
        await provider.getData(ApiURL.physioServiceCenters(serviceId));
    return PhysioCenterModel.listFromResponse(_payload(res));
  }

  Future<List<PhysioCenterModel>> fetchCenters() async {
    final res = await provider.getData(ApiURL.physioCenters);
    return PhysioCenterModel.listFromResponse(_payload(res));
  }

  Future<PhysioCenterModel> fetchCenter(String id) async {
    final res = await provider.getData(ApiURL.physioCenter(id));
    return PhysioCenterModel.fromResponse(_payload(res));
  }

  Future<List<PhysioStaff>> fetchStaff(String centerId) async {
    final res = await provider.getData(ApiURL.physioCenterStaff(centerId));
    return PhysioStaff.listFromResponse(_payload(res));
  }

  Future<List<PhysioOption>> fetchVisitTypes() async {
    final res = await provider.getData(ApiURL.physioVisitTypes);
    return PhysioOption.fromResponse(_payload(res), 'visit_types');
  }

  Future<String> fetchDefaultVisitType() async {
    final res = await provider.getData(ApiURL.physioVisitTypes);
    return PhysioOption.defaultKey(_payload(res));
  }

  Future<List<PhysioScheduleDate>> fetchScheduleDates() async {
    final res = await provider.getData(ApiURL.physioScheduleDates);
    return PhysioScheduleDate.listFromResponse(_payload(res));
  }

  Future<List<PhysioTimeSlot>> fetchTimeSlots(
      String staffId, String date) async {
    final res = await provider.getData(ApiURL.physioTimeSlots(staffId, date));
    return PhysioTimeSlot.listFromResponse(_payload(res));
  }

  Future<List<PhysioOption>> fetchPaymentMethods() async {
    final res = await provider.getData(ApiURL.physioPaymentMethods);
    return PhysioOption.fromResponse(_payload(res), 'methods');
  }

  Future<String> fetchDefaultPaymentMethod() async {
    final res = await provider.getData(ApiURL.physioPaymentMethods);
    return PhysioOption.defaultKey(_payload(res));
  }

  Future<PhysioAppointment> book(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.physioAppointments, payload);
    return PhysioAppointment.fromResponse(_payload(res));
  }

  Future<List<PhysioAppointment>> fetchMyAppointments() async {
    final res = await provider.getData(ApiURL.physioAppointmentsMy());
    return PhysioAppointment.listFromResponse(_payload(res));
  }
}
