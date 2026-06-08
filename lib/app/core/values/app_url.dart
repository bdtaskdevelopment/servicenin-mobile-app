class ApiURL {
  ApiURL._();

  //===== authentication part apis
  static final String login = '/login';
  static final String logout = '/logout';
  static final String forgotPassword = '/forgot-password';

  //===== ServiceNin auth (phone + OTP). No leading slash so it appends
  // cleanly to a base URL that ends with "/".
  static final String authLogin = 'api/v1/auth/login';
  static final String authVerifyOtp = 'api/v1/auth/verify-otp';
  static final String authRegister = 'api/v1/auth/register';
  static final String authResendOtp = 'api/v1/auth/resend-otp';

  //===== Blood
  static final String bloodRequests = 'api/v1/blood/requests';
  static String bloodRequestRespond(String id) =>
      'api/v1/blood/requests/$id/respond';
  static final String bloodResponsesMy = 'api/v1/blood/responses/my';
  static String bloodFulfillmentChat(String id) =>
      'api/v1/blood/fulfillments/$id/chat';
  static final String bloodDonors = 'api/v1/blood/donors';
  static final String bloodDonorsNearest = 'api/v1/blood/donors/nearest';
  static final String bloodDonorsLeaderboard = 'api/v1/blood/donors/leaderboard';
  static final String bloodDonorAvailability =
      'api/v1/blood/donors/me/availability';
  static final String bloodDonorRegister = 'api/v1/blood/donors/register';
  static final String bloodDonorVerifyOtp = 'api/v1/blood/donors/verify-otp';

  //===== Ambulance
  static final String ambulanceAvailable = 'api/v1/ambulance/available';
  static final String ambulanceBookings = 'api/v1/ambulance/bookings';
  static final String ambulanceTypes = 'api/v1/ambulance/types';
  static final String ambulanceFareEstimate = 'api/v1/ambulance/fare/estimate';
  static final String ambulancePaymentMethods =
      'api/v1/ambulance/payment-methods';

  //===== Locations
  static final String locationDivisions = 'api/v1/locations/divisions';
  static String locationDistricts(String division) =>
      'api/v1/locations/districts?division=$division';

  //===== Healthcare
  static final String hcDepartments = 'api/v1/healthcare/departments';
  static final String hcDoctors = 'api/v1/healthcare/doctors';
  static String hcDoctorsBySpecialization(String spec) =>
      'api/v1/healthcare/doctors?specialization=$spec';
  static final String hcDoctorsAvailableToday =
      'api/v1/healthcare/doctors/available-today';
  static String hcDoctorProfile(String id) =>
      'api/v1/healthcare/doctors/$id/profile';
  static String hcDoctorReviews(String id) =>
      'api/v1/healthcare/doctors/$id/reviews';
  static String hcDoctorVenues(String id) =>
      'api/v1/healthcare/doctors/$id/venues';
  static String hcScheduleDates(String id, String venueId) =>
      'api/v1/healthcare/doctors/$id/schedule-dates?venue_id=$venueId';
  static String hcTimeSlots(String id, String venueId, String date) =>
      'api/v1/healthcare/doctors/$id/time-slots?venue_id=$venueId&date=$date';
  static final String hcFamily = 'api/v1/healthcare/family';
  static final String hcDocumentsUpload =
      'api/v1/healthcare/documents/upload';
  static final String hcAppointments = 'api/v1/healthcare/appointments';
  static final String hcAppointmentsMy = 'api/v1/healthcare/appointments/my';
  static String hcAppointmentById(String id) =>
      'api/v1/healthcare/appointments/$id';
  static String hcAppointmentQueue(String id) =>
      'api/v1/healthcare/appointments/$id/queue';
  static String hcAppointmentReschedule(String id) =>
      'api/v1/healthcare/appointments/$id/reschedule';
  static final String hcPrescriptionLatest =
      'api/v1/healthcare/prescriptions/latest';
  static String hcPrescriptionsByDoctor(String doctorId) =>
      'api/v1/healthcare/prescriptions/by-doctor/$doctorId';
  static String hcPrescriptionDownload(String id) =>
      'api/v1/healthcare/prescriptions/$id/download';

  //===== Information / hotlines (ServiceNin)
  static final String info = 'api/v1/info';
  static String infoById(String id) => 'api/v1/info/$id';

  //===== profile (ServiceNin — no leading slash, appends to base ending "/")
  static final String usersMe = 'api/v1/users/me';
  static final String usersMeProfile = 'api/v1/users/me/profile';
  static final String usersMePhoto = 'api/v1/users/me/photo';
  static String usersMeActivity({int days = 7}) =>
      'api/v1/users/me/activity?days=$days';

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
