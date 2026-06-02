import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/phone_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/registration_view.dart';
import '../modules/ambulance/bindings/ambulance_binding.dart';
import '../modules/ambulance/views/ambulance_view.dart';
import '../modules/healthcare/bindings/healthcare_binding.dart';
import '../modules/healthcare/views/healthcare_view.dart';
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
import '../modules/home_service/views/earnings_view.dart';
import '../modules/physio/bindings/physio_binding.dart';
import '../modules/physio/views/physio_view.dart';
import '../modules/physio/views/physio_sessions_view.dart';
import '../modules/physio/views/physio_center_view.dart';
import '../modules/physio/views/physio_book_view.dart';
import '../modules/physio/views/physio_booked_view.dart';
import '../modules/information/bindings/information_binding.dart';
import '../modules/information/views/information_view.dart';
import '../modules/information/views/emergency_hotlines_view.dart';
import '../modules/information/views/guide_list_view.dart';
import '../modules/information/views/guide_detail_view.dart';
import '../modules/healthcare/views/appointments_view.dart';
import '../modules/healthcare/views/chat_view.dart';
import '../modules/healthcare/views/prescription_view.dart';
import '../modules/healthcare/views/find_doctor_view.dart';
import '../modules/healthcare/views/doctor_profile_view.dart';
import '../modules/healthcare/views/choose_slot_view.dart';
import '../modules/healthcare/views/patient_details_view.dart';
import '../modules/healthcare/views/review_confirm_view.dart';
import '../modules/healthcare/views/appointment_confirmed_view.dart';
import '../modules/healthcare/views/appointment_detail_view.dart';
import '../modules/ambulance/views/ambulance_notifications_view.dart';
import '../modules/ambulance/views/select_ambulance_view.dart';
import '../modules/ambulance/views/schedule_ambulance_view.dart';
import '../modules/ambulance/views/fare_estimate_view.dart';
import '../modules/ambulance/views/emergency_booking_view.dart';
import '../modules/ambulance/views/dispatching_view.dart';
import '../modules/ambulance/views/ambulance_tracking_view.dart';
import '../modules/ambulance/views/emergency_contacts_view.dart';
import '../modules/blood/bindings/blood_binding.dart';
import '../modules/blood/views/blood_view.dart';
import '../modules/blood/views/blood_requests_view.dart';
import '../modules/blood/views/blood_request_detail_view.dart';
import '../modules/blood/views/need_blood_view.dart';
import '../modules/blood/views/finding_donors_view.dart';
import '../modules/blood/views/donor_tracking_view.dart';
import '../modules/blood/views/donation_confirmed_view.dart';
import '../modules/blood/views/leaderboard_view.dart';
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
      name: _Paths.HC_DOCTORS,
      page: () => const FindDoctorView(),
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
      name: _Paths.HC_APPOINTMENT,
      page: () => const AppointmentDetailView(),
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
      name: _Paths.EMERGENCY_CONTACTS,
      page: () => const EmergencyContactsView(),
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
  ];
}
