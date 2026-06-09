import 'dart:io';

import '../../core/values/app_url.dart';
import '../models/response/auth_response.dart';
import '../models/response/jobs_response.dart';
import '../providers/jobs.provider.dart';

class JobsRepository {
  JobsRepository({required this.provider});

  final JobsProvider provider;

  dynamic _payload(dynamic res) {
    final body = res.body;
    if (body is Map) return body;
    final raw = res.bodyString;
    if (raw != null && raw.toString().trim().isNotEmpty) return raw;
    throw Exception('সংযোগে সমস্যা — আবার চেষ্টা করুন');
  }

  Future<List<JobCategory>> fetchCategories() async {
    final res = await provider.getData(ApiURL.jobsCategories);
    return JobCategory.listFromResponse(_payload(res));
  }

  Future<List<Job>> fetchJobs({
    String category = '',
    String jobType = '',
    String search = '',
    int page = 1,
    int limit = 20,
  }) async {
    final res = await provider.getData(ApiURL.jobsList(
      category: category,
      jobType: jobType,
      search: search,
      page: page,
      limit: limit,
    ));
    return Job.listFromResponse(_payload(res));
  }

  Future<Job> fetchJob(String id) async {
    final res = await provider.getData(ApiURL.jobById(id));
    return Job.fromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> createSeekerProfile(
      Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.jobsSeekerProfile, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<String> uploadResume(File file) async {
    final res = await provider.uploadResume(ApiURL.jobsResumeUpload, file);
    return jobsResumeUrlFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> apply(
      String jobId, Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.jobApply(jobId), payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<List<JobApplicationModel>> fetchMyApplications() async {
    final res = await provider.getData(ApiURL.jobsApplicationsMy);
    return JobApplicationModel.listFromResponse(_payload(res));
  }

  Future<AuthSimpleResponse> registerEmployer(
      Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.jobsEmployerRegister, payload);
    return AuthSimpleResponse.fromMap(_payload(res));
  }

  Future<Job> postJob(Map<String, dynamic> payload) async {
    final res = await provider.postData(ApiURL.jobs, payload);
    return Job.fromResponse(_payload(res));
  }
}
