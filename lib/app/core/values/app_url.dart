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

  //===== Home services
  static final String servicesCategories = 'api/v1/services/categories';
  static String servicesPopular({int days = 7, int limit = 10}) =>
      'api/v1/services/popular?days=$days&limit=$limit';
  static String servicesSearch(String q) => 'api/v1/services/search?q=$q';
  static String servicesSubServices(String categoryId) =>
      'api/v1/services/categories/$categoryId/sub-services';
  static final String servicesScheduleDates =
      'api/v1/services/schedule-dates';
  static String servicesTimeSlots(String date) =>
      'api/v1/services/time-slots?date=$date';
  static final String servicesPaymentMethods =
      'api/v1/services/payment-methods';
  static final String servicesBook = 'api/v1/services/book';
  static final String servicesBookingsMy = 'api/v1/services/bookings/my';
  static String serviceBooking(String id) => 'api/v1/services/bookings/$id';
  static String serviceBookingTimeline(String id) =>
      'api/v1/services/bookings/$id/timeline';
  static String serviceBookingRating(String id) =>
      'api/v1/services/bookings/$id/rating';
  static String serviceBookingDispute(String id) =>
      'api/v1/services/bookings/$id/dispute';
  static String serviceBookingChat(String id) =>
      'api/v1/services/bookings/$id/chat';

  //===== Physiotherapy
  static final String physioConcerns = 'api/v1/physio/concerns';
  static String physioConcernCenters(String key) =>
      'api/v1/physio/concerns/$key/centers';
  static final String physioCenters = 'api/v1/physio/centers';
  static String physioCenter(String id) => 'api/v1/physio/centers/$id';
  static String physioCenterStaff(String id) =>
      'api/v1/physio/centers/$id/staff';
  static final String physioVisitTypes = 'api/v1/physio/visit-types';
  static final String physioScheduleDates = 'api/v1/physio/schedule-dates';
  static String physioTimeSlots(String staffId, String date) =>
      'api/v1/physio/time-slots?staff_id=$staffId&date=$date';
  static final String physioPaymentMethods =
      'api/v1/physio/payment-methods';
  static final String physioAppointments = 'api/v1/physio/appointments';
  static String physioAppointmentsMy({int page = 1, int limit = 20}) =>
      'api/v1/physio/appointments/my?page=$page&limit=$limit';

  //===== Matchmaking (Marriage)
  static final String mmCategories = 'api/v1/matchmaking/categories';
  static final String mmBiodataFields = 'api/v1/matchmaking/biodata-fields';
  static final String mmProfiles = 'api/v1/matchmaking/profiles';
  static final String mmProfileMe = 'api/v1/matchmaking/profiles/me';
  static String mmProfile(String id) => 'api/v1/matchmaking/profiles/$id';
  static final String mmSuggestions = 'api/v1/matchmaking/suggestions';
  static String mmInterest(String profileId) =>
      'api/v1/matchmaking/profiles/$profileId/interest';
  static final String mmInterestsReceived =
      'api/v1/matchmaking/interests/received';
  static final String mmInterestsSent = 'api/v1/matchmaking/interests/sent';
  static String mmInterestRespond(String id) =>
      'api/v1/matchmaking/interests/$id/respond';
  static final String mmMatches = 'api/v1/matchmaking/matches';
  static String mmInterestChat(String id) =>
      'api/v1/matchmaking/interests/$id/chat';

  //===== Jobs
  static final String jobsCategories = 'api/v1/jobs/categories';
  static final String jobs = 'api/v1/jobs';
  static String jobsList({
    String category = '',
    String jobType = '',
    String search = '',
    int page = 1,
    int limit = 20,
  }) {
    final params = <String>['page=$page', 'limit=$limit'];
    if (category.isNotEmpty && category != 'All') {
      params.add('category=$category');
    }
    if (jobType.isNotEmpty) params.add('job_type=$jobType');
    if (search.isNotEmpty) params.add('search=$search');
    return 'api/v1/jobs?${params.join('&')}';
  }

  static String jobById(String id) => 'api/v1/jobs/$id';
  static final String jobsSeekerProfile = 'api/v1/jobs/seekers/profile';
  static final String jobsResumeUpload = 'api/v1/jobs/resume/upload';
  static String jobApply(String id) => 'api/v1/jobs/$id/apply';
  static final String jobsApplicationsMy = 'api/v1/jobs/applications/my';
  static final String jobsEmployerRegister =
      'api/v1/jobs/employers/register';

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
