import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/phone_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/registration_view.dart';
import '../modules/ambulance/bindings/ambulance_binding.dart';
import '../modules/ambulance/views/ambulance_view.dart';
import '../modules/healthcare/bindings/healthcare_binding.dart';
import '../modules/healthcare/views/healthcare_view.dart';
import '../modules/healthcare/views/healthcare_centers_view.dart';
import '../modules/home_service/bindings/home_service_binding.dart';
import '../modules/home_service/views/home_service_view.dart';
import '../modules/home_service/views/hs_service_list_view.dart';
import '../modules/home_service/views/confirm_booking_view.dart';
import '../modules/home_service/views/booking_placed_view.dart';
import '../modules/home_service/views/hs_tracking_view.dart';
import '../modules/home_service/views/hs_booking_details_view.dart';
import '../modules/home_service/views/rate_service_view.dart';
import '../modules/home_service/views/subscriptions_view.dart';
import '../modules/home_service/views/provider_dashboard_view.dart';
import '../modules/home_service/views/hs_chat_view.dart';
import '../modules/home_service/views/hs_my_bookings_view.dart';
import '../modules/home_service/views/earnings_view.dart';
import '../modules/physio/bindings/physio_binding.dart';
import '../modules/physio/views/physio_view.dart';
import '../modules/physio/views/physio_sessions_view.dart';
import '../modules/physio/views/physio_center_view.dart';
import '../modules/physio/views/physio_book_view.dart';
import '../modules/physio/views/physio_booked_view.dart';
import '../modules/matchmaking/bindings/matchmaking_binding.dart';
import '../modules/matchmaking/views/matchmaking_view.dart';
import '../modules/matchmaking/views/my_biodata_view.dart';
import '../modules/matchmaking/views/partner_preference_view.dart';
import '../modules/matchmaking/views/biodata_detail_view.dart';
import '../modules/matchmaking/views/interests_view.dart';
import '../modules/matchmaking/views/mm_chat_view.dart';
import '../modules/jobs/bindings/jobs_binding.dart';
import '../modules/jobs/views/jobs_view.dart';
import '../modules/jobs/views/my_applications_view.dart';
import '../modules/jobs/views/job_detail_view.dart';
import '../modules/jobs/views/job_apply_view.dart';
import '../modules/jobs/views/post_job_view.dart';
import '../modules/jobs/views/employer_register_view.dart';
import '../modules/jobs/views/job_seeker_profile_view.dart';
import '../modules/funeral/bindings/funeral_binding.dart';
import '../modules/funeral/views/funeral_view.dart';
import '../modules/funeral/views/funeral_request_view.dart';
import '../modules/funeral/views/funeral_done_view.dart';
import '../modules/funeral/views/funeral_requests_view.dart';
import '../modules/education/bindings/education_binding.dart';
import '../modules/education/views/education_view.dart';
import '../modules/education/views/education_center_view.dart';
import '../modules/education/views/course_enquiry_view.dart';
import '../modules/education/views/enquiry_done_view.dart';
import '../modules/education/views/education_interests_view.dart';
import '../modules/nagarik/bindings/nagarik_binding.dart';
import '../modules/nagarik/views/nagarik_view.dart';
import '../modules/nagarik/views/nagarik_reports_view.dart';
import '../modules/nagarik/views/nagarik_tickets_view.dart';
import '../modules/nagarik/views/report_issue_view.dart';
import '../modules/nagarik/views/report_status_view.dart';
import '../modules/nagarik/views/nagarik_chat_view.dart';
import '../modules/nagarik/views/nagarik_ticket_create_view.dart';
import '../modules/nagarik/views/nagarik_ticket_detail_view.dart';
import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/profile_view.dart';
import '../modules/account/views/edit_profile_view.dart';
import '../modules/account/views/my_activity_view.dart';
import '../modules/account/views/settings_view.dart';
import '../modules/account/views/privacy_policy_view.dart';
import '../modules/account/views/terms_view.dart';
import '../modules/account/views/delete_account_view.dart';
import '../modules/information/bindings/information_binding.dart';
import '../modules/information/views/information_view.dart';
import '../modules/information/views/emergency_hotlines_view.dart';
import '../modules/information/views/guide_list_view.dart';
import '../modules/information/views/guide_detail_view.dart';
import '../modules/healthcare/views/appointments_view.dart';
import '../modules/healthcare/views/chat_view.dart';
import '../modules/healthcare/views/prescription_view.dart';
import '../modules/healthcare/views/family_view.dart';
import '../modules/healthcare/views/find_doctor_view.dart';
import '../modules/healthcare/views/all_available_doctors_view.dart';
import '../modules/healthcare/views/doctor_profile_view.dart';
import '../modules/healthcare/views/choose_slot_view.dart';
import '../modules/healthcare/views/patient_details_view.dart';
import '../modules/healthcare/views/review_confirm_view.dart';
import '../modules/healthcare/views/appointment_confirmed_view.dart';
import '../modules/healthcare/views/appointment_queue_view.dart';
import '../modules/ambulance/views/ambulance_notifications_view.dart';
import '../modules/ambulance/views/select_ambulance_view.dart';
import '../modules/ambulance/views/schedule_ambulance_view.dart';
import '../modules/ambulance/views/fare_estimate_view.dart';
import '../modules/ambulance/views/emergency_booking_view.dart';
import '../modules/ambulance/views/dispatching_view.dart';
import '../modules/ambulance/views/ambulance_tracking_view.dart';
import '../modules/ambulance/views/ambulance_bookings_view.dart';
import '../modules/ambulance/views/all_ambulances_view.dart';
import '../modules/ambulance/views/booking_confirmed_view.dart';
import '../modules/ambulance/views/rate_ambulance_view.dart';
import '../modules/ambulance/views/emergency_contacts_view.dart';
import '../modules/ambulance/views/ambulance_support_view.dart';
import '../modules/blood/bindings/blood_binding.dart';
import '../modules/blood/views/blood_view.dart';
import '../modules/blood/views/blood_requests_view.dart';
import '../modules/blood/views/blood_request_detail_view.dart';
import '../modules/blood/views/my_requests_view.dart';
import '../modules/blood/views/blood_responders_view.dart';
import '../modules/blood/views/need_blood_view.dart';
import '../modules/blood/views/finding_donors_view.dart';
import '../modules/blood/views/donor_tracking_view.dart';
import '../modules/blood/views/donation_confirmed_view.dart';
import '../modules/blood/views/leaderboard_view.dart';
import '../modules/blood/views/connected_donors_view.dart';
import '../modules/blood/views/all_donors_view.dart';
import '../modules/blood/views/donor_detail_view.dart';
import '../modules/blood/views/my_responses_view.dart';
import '../modules/blood/views/blood_chat_view.dart';
import '../modules/blood/views/donor_chat_view.dart';
import '../modules/blood/views/donor_register_view.dart';
import '../modules/blood/views/donor_verify_otp_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const PhoneView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
    ),
    GetPage(
      name: _Paths.REGISTRATION,
      page: () => const RegistrationView(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD,
      page: () => const BloodView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE,
      page: () => const AmbulanceView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE,
      page: () => const HealthcareView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE_CENTERS,
      page: () => const HealthcareCentersView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION,
      page: () => const InformationView(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: _Paths.HOME_SERVICE,
      page: () => const HomeServiceView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HOME_SERVICE_LIST,
      page: () => const HsServiceListView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_CONFIRM,
      page: () => const ConfirmBookingView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_PLACED,
      page: () => const BookingPlacedView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_TRACKING,
      page: () => const HsTrackingView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_DETAILS,
      page: () => const HsBookingDetailsView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_RATE,
      page: () => const RateServiceView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_SUBSCRIPTIONS,
      page: () => const SubscriptionsView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_PROVIDER,
      page: () => const ProviderDashboardView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_CHAT,
      page: () => const HsChatView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_MY_BOOKINGS,
      page: () => const HsMyBookingsView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.HS_EARNINGS,
      page: () => const EarningsView(),
      binding: HomeServiceBinding(),
    ),
    GetPage(
      name: _Paths.PHYSIO,
      page: () => const PhysioView(),
      binding: PhysioBinding(),
    ),
    GetPage(
      name: _Paths.PHYSIO_SESSIONS,
      page: () => const PhysioSessionsView(),
      binding: PhysioBinding(),
    ),
    GetPage(
      name: _Paths.PHYSIO_CENTER,
      page: () => const PhysioCenterView(),
      binding: PhysioBinding(),
    ),
    GetPage(
      name: _Paths.PHYSIO_BOOK,
      page: () => const PhysioBookView(),
      binding: PhysioBinding(),
    ),
    GetPage(
      name: _Paths.PHYSIO_BOOKED,
      page: () => const PhysioBookedView(),
      binding: PhysioBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING,
      page: () => const MatchmakingView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING_BIODATA,
      page: () => const MyBiodataView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING_PREFERENCE,
      page: () => const PartnerPreferenceView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING_PROFILE,
      page: () => const BiodataDetailView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING_INTERESTS,
      page: () => const InterestsView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.MATCHMAKING_CHAT,
      page: () => const MmChatView(),
      binding: MatchmakingBinding(),
    ),
    GetPage(
      name: _Paths.JOBS,
      page: () => const JobsView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_APPLICATIONS,
      page: () => const MyApplicationsView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_DETAIL,
      page: () => const JobDetailView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_APPLY,
      page: () => const JobApplyView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_POST,
      page: () => const PostJobView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_EMPLOYER,
      page: () => const EmployerRegisterView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.JOBS_SEEKER_PROFILE,
      page: () => const JobSeekerProfileView(),
      binding: JobsBinding(),
    ),
    GetPage(
      name: _Paths.FUNERAL,
      page: () => const FuneralView(),
      binding: FuneralBinding(),
    ),
    GetPage(
      name: _Paths.FUNERAL_REQUEST,
      page: () => const FuneralRequestView(),
      binding: FuneralBinding(),
    ),
    GetPage(
      name: _Paths.FUNERAL_DONE,
      page: () => const FuneralDoneView(),
      binding: FuneralBinding(),
    ),
    GetPage(
      name: _Paths.FUNERAL_REQUESTS,
      page: () => const FuneralRequestsView(),
      binding: FuneralBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION,
      page: () => const EducationView(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_CENTER,
      page: () => const EducationCenterView(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_ENQUIRY,
      page: () => const CourseEnquiryView(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_DONE,
      page: () => const EnquiryDoneView(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.EDUCATION_INTERESTS,
      page: () => const EducationInterestsView(),
      binding: EducationBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK,
      page: () => const NagarikView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_REPORTS,
      page: () => const NagarikReportsView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_TICKETS,
      page: () => const NagarikTicketsView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_REPORT_ISSUE,
      page: () => const ReportIssueView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_STATUS,
      page: () => const ReportStatusView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_CHAT,
      page: () => const NagarikChatView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_TICKET_CREATE,
      page: () => const NagarikTicketCreateView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.NAGARIK_TICKET_DETAIL,
      page: () => const NagarikTicketDetailView(),
      binding: NagarikBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_PROFILE,
      page: () => const ProfileView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_EDIT,
      page: () => const EditProfileView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_ACTIVITY,
      page: () => const MyActivityView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_SETTINGS,
      page: () => const SettingsView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_PRIVACY,
      page: () => const PrivacyPolicyView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_TERMS,
      page: () => const TermsView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT_DELETE,
      page: () => const DeleteAccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION_HOTLINES,
      page: () => const EmergencyHotlinesView(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION_GUIDES,
      page: () => const GuideListView(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION_GUIDE_DETAIL,
      page: () => const GuideDetailView(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE_APPOINTMENTS,
      page: () => const AppointmentsView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE_CHAT,
      page: () => const ChatView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE_PRESCRIPTION,
      page: () => const PrescriptionView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHCARE_FAMILY,
      page: () => const FamilyView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_DOCTORS,
      page: () => const FindDoctorView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_AVAILABLE_TODAY,
      page: () => const AllAvailableDoctorsView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_DOCTOR_PROFILE,
      page: () => const DoctorProfileView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_SLOT,
      page: () => const ChooseSlotView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_PATIENT,
      page: () => const PatientDetailsView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_REVIEW,
      page: () => const ReviewConfirmView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_CONFIRMED,
      page: () => const AppointmentConfirmedView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.HC_QUEUE,
      page: () => const AppointmentQueueView(),
      binding: HealthcareBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_NOTIFICATIONS,
      page: () => const AmbulanceNotificationsView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_SELECT,
      page: () => const SelectAmbulanceView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_SCHEDULE,
      page: () => const ScheduleAmbulanceView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_FARE,
      page: () => const FareEstimateView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_BOOKING,
      page: () => const EmergencyBookingView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_DISPATCHING,
      page: () => const DispatchingView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_TRACKING,
      page: () => const AmbulanceTrackingView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_BOOKINGS,
      page: () => const AmbulanceBookingsView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_ALL,
      page: () => const AllAmbulancesView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_CONFIRMED,
      page: () => const BookingConfirmedView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_RATE,
      page: () => const RateAmbulanceView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.EMERGENCY_CONTACTS,
      page: () => const EmergencyContactsView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.AMBULANCE_SUPPORT,
      page: () => const AmbulanceSupportView(),
      binding: AmbulanceBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_REQUESTS,
      page: () => const BloodRequestsView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_REQUEST_DETAIL,
      page: () => const BloodRequestDetailView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_MY_REQUESTS,
      page: () => const MyRequestsView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_RESPONDERS,
      page: () => const BloodRespondersView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_NEED,
      page: () => const NeedBloodView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_FINDING,
      page: () => const FindingDonorsView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_TRACKING,
      page: () => const DonorTrackingView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_CONFIRMED,
      page: () => const DonationConfirmedView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_MY_DONORS,
      page: () => const ConnectedDonorsView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_MY_RESPONSES,
      page: () => const MyResponsesView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_DONORS,
      page: () => const AllDonorsView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_DONOR_DETAIL,
      page: () => const DonorDetailView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_DONOR_CHAT,
      page: () => const DonorChatView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_CHAT,
      page: () => const BloodChatView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_DONOR_REGISTER,
      page: () => const DonorRegisterView(),
      binding: BloodBinding(),
    ),
    GetPage(
      name: _Paths.BLOOD_DONOR_VERIFY_OTP,
      page: () => const DonorVerifyOtpView(),
      binding: BloodBinding(),
    ),
  ];
}
