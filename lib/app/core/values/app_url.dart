class ApiURL {
  ApiURL._();

  //===== authentication part apis
  static final String login = '/login';
  static final String logout = '/logout';
  static final String forgotPassword = '/forgot-password';

  //===== profile
  static final String profile = '/profile';
  static final String profileAvatar = '/profile/avatar';
  static final String dashboard = '/dashboard';
  static final String attendanceLocations = '/attendance/locations';
  static final String attendanceCheckIn   = '/attendance/check-in';
  static final String attendanceStatus     = '/attendance/status';
  static final String attendanceBreakStart = '/attendance/break-start';
  static final String attendanceHistory    = '/attendance/history';
  static final String notices              = '/notices';
  static final String leave                = '/leave';
  static String leaveById(int id)          => '/leave/$id';
  static final String shortLeave           = '/leave/short-leave';
  static String shortLeaveById(int id)     => '/leave/short-leave/$id';
  static final String leaveTypes           = '/leave/types';
  static final String leaveEmployees       = '/leave/employees';
  static final String notifications        = '/notifications';
  static final String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';
  static final String projects              = '/projects';
  static String projectById(int id)         => '/projects/$id';
  static String projectSprints(int id)      => '/projects/$id/sprints';
  static String projectUseCases(int id)     => '/projects/$id/use-cases';
  static final String tasks                 = '/tasks';
  static String ownTasks({int? projectId}) =>
      projectId != null ? '/tasks/own?project_id=$projectId' : '/tasks/own';
  static String taskById(int id)            => '/tasks/$id';
  static final String policies              = '/policies';
  static final String documents             = '/documents';
  static final String loans                 = '/loans';
  static final String clients               = '/clients';
  static final String team                  = '/team';
  static final String kanbanDashboard      = '/kanban/dashboard';
  static final String kanban               = '/kanban';
  static String kanbanMove(int id, int status) => '/kanban/$id/move?status=$status';
  static final String dailyTasksBase = '/daily-tasks';
  static String dailyTaskById(int id) => '/daily-tasks/$id';
  static String dailyTasks({
    String title = '',
    String dateFrom = '',
    String dateTo = '',
    String isApproved = '',
    String employeeId = '',
    int page = 1,
    int perPage = 15,
  }) {
    final params = <String, String>{};
    if (title.isNotEmpty)      params['title']       = title;
    if (dateFrom.isNotEmpty)   params['date_from']   = dateFrom;
    if (dateTo.isNotEmpty)     params['date_to']     = dateTo;
    if (isApproved.isNotEmpty) params['is_approved'] = isApproved;
    if (employeeId.isNotEmpty) params['employee_id'] = employeeId;
    params['page']     = page.toString();
    params['per_page'] = perPage.toString();
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '/daily-tasks?$query';
  }
}
