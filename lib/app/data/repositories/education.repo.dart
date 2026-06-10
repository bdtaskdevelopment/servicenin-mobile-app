import '../../core/values/app_url.dart';
import '../models/response/education_response.dart';
import '../providers/education.provider.dart';

class EducationRepository {
  EducationRepository({required this.provider});

  final EducationProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<List<EduCategory>> fetchCategories() async {
    final res = await provider.getData(ApiURL.educationCategories);
    return EduCategory.listFromResponse(_payload(res));
  }

  Future<List<EduCenter>> fetchCentersNear() async {
    final res = await provider.getData(ApiURL.educationCentersNear);
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
