import 'dart:io';
import 'package:dio/dio.dart' as dio;
import '../../core/helpers/app_helper.dart';
import '../../core/values/app_config.dart';
import '../../core/values/app_url.dart';
import '../../core/values/storage.dart';
import '../services/storage.service.dart';
import '../data.dart';

class HomeRepository {
  HomeRepository({required this.homeProvider});

  final HomeProvider homeProvider;

  Future<ProfileResponse> getProfile() async {
    final res = await homeProvider.getProfile(ApiURL.profile);
    if (BaseResponse.handleApiResponse(res)) {
      return profileResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<AttendanceLocationsResponse> getAttendanceLocations() async {
    final res = await homeProvider.getData(ApiURL.attendanceLocations);
    if (BaseResponse.handleApiResponse(res)) {
      return attendanceLocationsResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<DashboardResponse> getDashboard() async {
    final res = await homeProvider.getData(ApiURL.dashboard);
    if (BaseResponse.handleApiResponse(res)) {
      return dashboardResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<AttendanceStatusResponse> getAttendanceStatus() async {
    final res = await homeProvider.getData(ApiURL.attendanceStatus);
    if (BaseResponse.handleApiResponse(res)) {
      return attendanceStatusResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<AttendanceHistoryResponse> getAttendanceHistory() async {
    final res = await homeProvider.getData(ApiURL.attendanceHistory);
    if (BaseResponse.handleApiResponse(res)) {
      return attendanceHistoryResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<ShortLeaveResponse> getShortLeaves() async {
    final res = await homeProvider.getData(ApiURL.shortLeave);
    if (BaseResponse.handleApiResponse(res)) {
      return shortLeaveResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<CommonResponse> createShortLeave(Map<String, dynamic> payload) async {
    final res = await homeProvider.postData(ApiURL.shortLeave, payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<CommonResponse> updateShortLeave(int id, Map<String, dynamic> payload) async {
    final res = await homeProvider.putData(ApiURL.shortLeaveById(id), payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<CommonResponse> deleteShortLeave(int id) async {
    final res = await homeProvider.deleteData(ApiURL.shortLeaveById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<LeaveTypesResponse> getLeaveTypes() async {
    final res = await homeProvider.getData(ApiURL.leaveTypes);
    if (BaseResponse.handleApiResponse(res)) {
      return leaveTypesResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<LeaveEmployeesResponse> getLeaveEmployees() async {
    final res = await homeProvider.getData(ApiURL.leaveEmployees);
    if (BaseResponse.handleApiResponse(res)) {
      return leaveEmployeesResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<LeaveResponse> getLeaves() async {
    final res = await homeProvider.getData(ApiURL.leave);
    if (BaseResponse.handleApiResponse(res)) {
      return leaveResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<LeaveDetailItem> getLeaveDetail(int id) async {
    final res = await homeProvider.getData(ApiURL.leaveById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return leaveDetailFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<CommonResponse> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String reason,
    required String address,
    required String contact,
    int? responsiblePerson,
  }) async {
    final res = await homeProvider.postData(ApiURL.leave, {
      'leave_type_id': leaveTypeId,
      'from_date': fromDate,
      'to_date': toDate,
      'reason': reason,
      'address': address,
      'contact': contact,
      'responsible_person': responsiblePerson,
    });
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<NotificationResponse> getNotifications() async {
    final res = await homeProvider.getData(ApiURL.notifications);
    if (BaseResponse.handleApiResponse(res)) {
      return notificationResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> markAllNotificationsRead() async {
    final res = await homeProvider.postData(ApiURL.notificationsReadAll, {});
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> markNotificationRead(String id) async {
    final res = await homeProvider.postData(ApiURL.notificationRead(id), {});
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<ProjectsResponse> getProjects({String? status}) async {
    final url = (status != null && status.isNotEmpty)
        ? '${ApiURL.projects}?status=$status'
        : ApiURL.projects;
    final res = await homeProvider.getData(url);
    if (BaseResponse.handleApiResponse(res)) {
      return projectsResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<OwnTasksResponse> getOwnTasks({int? projectId}) async {
    final res = await homeProvider.getData(ApiURL.ownTasks(projectId: projectId));
    if (BaseResponse.handleApiResponse(res)) {
      return ownTasksResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<UseCasesResponse> getUseCases(int projectId) async {
    final res = await homeProvider.getData(ApiURL.projectUseCases(projectId));
    if (BaseResponse.handleApiResponse(res)) {
      return useCasesResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<SprintsResponse> getSprints(int projectId) async {
    final res = await homeProvider.getData(ApiURL.projectSprints(projectId));
    if (BaseResponse.handleApiResponse(res)) {
      return sprintsResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> updateTask(int id, Map<String, dynamic> payload) async {
    final res = await homeProvider.putData(ApiURL.taskById(id), payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> deleteTask(int id) async {
    final res = await homeProvider.deleteData(ApiURL.taskById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<OwnTasksResponse> getAllTasks() async {
    final res = await homeProvider.getData(ApiURL.tasks);
    if (BaseResponse.handleApiResponse(res)) {
      return ownTasksResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> createTask({
    required int projectId,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
  }) async {
    final res = await homeProvider.postData(ApiURL.tasks, {
      'project_id': projectId,
      'title': title,
      'description': description,
      'priority': priority,
      'due_date': dueDate,
      'assignee_id': null,
      'sprint_id': null,
      'use_case_id': null,
    });
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<ClientsResponse> getClients() async {
    final res = await homeProvider.getData(ApiURL.clients);
    if (BaseResponse.handleApiResponse(res)) {
      return clientsResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<TeamResponse> getTeam() async {
    final res = await homeProvider.getData(ApiURL.team);
    if (BaseResponse.handleApiResponse(res)) {
      return teamResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> createProject(Map<String, dynamic> payload) async {
    final res = await homeProvider.postData(ApiURL.projects, payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> updateProject(
      int id, Map<String, dynamic> payload) async {
    final res = await homeProvider.putData(ApiURL.projectById(id), payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> uploadProfileAvatar(File image) async {
    final token = StorageService.read(StorageConstants.accessToken);
    final client = dio.Dio(dio.BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ));
    final formData = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(image.path, filename: image.path.split(Platform.pathSeparator).last),
    });
    final res = await client.post(ApiURL.profileAvatar, data: formData);
    final body = res.data is Map ? res.data as Map<String, dynamic> : {};
    if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
      return commonResponseFromMap(body);
    } else {
      throw Exception(Helpers.extractErrorMessage(body.toString()));
    }
  }

  Future<CommonResponse> deleteProject(int id) async {
    final res = await homeProvider.deleteData(ApiURL.projectById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<LoanResponse> getLoans() async {
    final res = await homeProvider.getData(ApiURL.loans);
    if (BaseResponse.handleApiResponse(res)) {
      return loanResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> createLoan(Map<String, dynamic> payload) async {
    final res = await homeProvider.postData(ApiURL.loans, payload);
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<DocumentsResponse> getDocuments() async {
    final res = await homeProvider.getData(ApiURL.documents);
    if (BaseResponse.handleApiResponse(res)) {
      return documentsResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<PoliciesResponse> getPolicies() async {
    final res = await homeProvider.getData(ApiURL.policies);
    if (BaseResponse.handleApiResponse(res)) {
      return policiesResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> postBreakStart() async {
    final res = await homeProvider.postData(ApiURL.attendanceBreakStart, {});
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CheckInResponse> postCheckIn({
    required double latitude,
    required double longitude,
    required String address,
    bool override = false,
    String? reasonType,
    String? reason,
  }) async {
    final res = await homeProvider.postData(ApiURL.attendanceCheckIn, {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'override': override,
      'reason_type': reasonType,
      'reason': reason,
    });
    if (BaseResponse.handleApiResponse(res)) {
      return checkInResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> moveKanbanTask(int id, int status) async {
    final res = await homeProvider.patchData(ApiURL.kanbanMove(id, status), {});
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<KanbanBoardResponse> getKanbanBoard(String status) async {
    final res = await homeProvider.getData('${ApiURL.kanban}?status=$status');
    if (BaseResponse.handleApiResponse(res)) {
      return kanbanBoardResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<KanbanDashboardResponse> getKanbanDashboard() async {
    final res = await homeProvider.getData(ApiURL.kanbanDashboard);
    if (BaseResponse.handleApiResponse(res)) {
      return kanbanDashboardResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<NoticeResponse> getNotices() async {
    final res = await homeProvider.getData(ApiURL.notices);
    if (BaseResponse.handleApiResponse(res)) {
      return noticeResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }

  Future<CommonResponse> deleteDailyTask(int id) async {
    final res = await homeProvider.deleteData(ApiURL.dailyTaskById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return commonResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<DailyTaskItem> getDailyTaskDetail(int id) async {
    final res = await homeProvider.getData(ApiURL.dailyTaskById(id));
    if (BaseResponse.handleApiResponse(res)) {
      return dailyTaskDetailFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<DailyTaskResponse> getDailyTasks({
    String title = '',
    String dateFrom = '',
    String dateTo = '',
    String isApproved = '',
    String employeeId = '',
    int page = 1,
    int perPage = 15,
  }) async {
    final res = await homeProvider.getData(ApiURL.dailyTasks(
      title: title,
      dateFrom: dateFrom,
      dateTo: dateTo,
      isApproved: isApproved,
      employeeId: employeeId,
      page: page,
      perPage: perPage,
    ));
    if (BaseResponse.handleApiResponse(res)) {
      return dailyTaskResponseFromMap(res.body);
    } else {
      throw Exception(Helpers.extractErrorMessage(res.bodyString ?? res.body));
    }
  }

  Future<CheckInResponse> postCheckOut({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final res = await homeProvider.postData(ApiURL.attendanceCheckIn, {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'override': false,
      'reason_type': null,
      'reason': null,
    });
    if (BaseResponse.handleApiResponse(res)) {
      return checkInResponseFromMap(res.body);
    } else {
      final message = Helpers.extractErrorMessage(res.bodyString ?? res.body);
      throw Exception(message);
    }
  }
}
