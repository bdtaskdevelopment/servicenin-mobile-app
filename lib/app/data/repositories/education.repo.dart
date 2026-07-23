import '../../core/values/app_url.dart';
import '../models/response/education_response.dart';
import '../providers/education.provider.dart';

class EducationRepository {
  EducationRepository({required this.provider});

  final EducationProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) {
      // A failed request (e.g. duplicate registration) still decodes as a
      // Map — {success:false, message:...} — with no "data" key. Without
      // this check that error body gets treated as valid response data
      // (every field just reads back empty), so the app would silently
      // "succeed" into the done screen while nothing was actually saved.
      if (body['success'] == false) {
        throw Exception((body['message'] ?? 'অনুরোধ ব্যর্থ হয়েছে').toString());
      }
      return body;
    }
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<List<EduInstituteType>> fetchInstituteTypes() async {
    final res = await provider.getData(ApiURL.educationInstituteTypes);
    return EduInstituteType.listFromResponse(_payload(res));
  }

  /// "Centers near you", optionally filtered to one institute type (slug).
  Future<List<EduCenter>> fetchCentersNear({String? instituteType}) async {
    final res = await provider.getData(
        ApiURL.educationCentersNear(instituteType: instituteType));
    return EduCenter.listFromResponse(_payload(res));
  }

  Future<EduCenter> fetchCenter(String id) async {
    final res = await provider.getData(ApiURL.educationCenter(id));
    return EduCenter.fromResponse(_payload(res));
  }

  Future<List<EduCourse>> fetchCenterCourses(String id) async {
    final res = await provider.getData(ApiURL.educationCenterCourses(id));
    return EduCourse.listFromResponse(_payload(res));
  }

  Future<EduCourse> fetchCourse(String id) async {
    final res = await provider.getData(ApiURL.educationCourse(id));
    return EduCourse.fromResponse(_payload(res));
  }

  Future<EduInterest> registerInterest(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.educationInterests, payload);
    return EduInterest.fromResponse(_payload(res));
  }

  Future<List<EduInterest>> fetchMyInterests() async {
    final res = await provider.getData(ApiURL.educationInterestsMy);
    return EduInterest.listFromResponse(_payload(res));
  }
}
