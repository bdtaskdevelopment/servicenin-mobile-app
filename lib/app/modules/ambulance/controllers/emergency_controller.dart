import 'dart:async';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class TripStep {
  const TripStep(this.label, this.time);
  final String label;
  final String time;
}

class EmergencyController extends GetxController {
  // ── Booking details ──────────────────────────────────────────────
  final String pickup = 'Gulshan-2 · Road 11';
  final String takeTo = 'Nearest ICU hospital';
  final String hospital = 'United Hospital · 3.2 km';
  final String ambulanceType = 'ICU · with ventilator';
  final String contact = 'Tanzil (self) · 01711-***123';
  final String estArrival = '6 min';
  final String distance = '3.2 km';
  final String fare = '৳2,840';

  static const List<String> conditions = [
    'Cardiac', 'Accident', 'Stroke', 'Maternity', 'Breathing', 'Other',
  ];
  String condition = 'Cardiac';
  String get conditionLabel => '$condition · Severe';

  void selectCondition(String value) {
    condition = value;
    update();
  }

  // Header countdown
  Timer? _timer;
  int countdown = 30;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown <= 0) {
        t.cancel();
      } else {
        countdown--;
        update();
      }
    });
  }

  // ── Dispatch ─────────────────────────────────────────────────────
  // 0 received, 1 finding, 2 assigned
  int dispatchStep = 1;

  void confirm() => Get.toNamed(Routes.AMBULANCE_DISPATCHING);

  /// Called by the dispatching screen; resolves to the live tracking screen.
  void runDispatchThenTrack() {
    dispatchStep = 1;
    update();
    Future.delayed(const Duration(milliseconds: 2600), () {
      dispatchStep = 2;
      update();
      Get.offNamed(Routes.AMBULANCE_TRACKING);
    });
  }

  // ── Tracking / driver ────────────────────────────────────────────
  final String driverName = 'Md. Rashedul Haque';
  final String driverInitials = 'RH';
  final String driverRating = '4.92';
  final String driverTrips = '612 trips';
  final String driverYears = '8 yrs';
  final String vehicle = 'ICU · BD-1234';
  final String driverPhone = '+880 1711-456789';
  final String routeVia = 'via Pragati Sarani · light traffic';

  final List<TripStep> tripStatus = const [
    TripStep('Request received', '14:02'),
    TripStep('Driver assigned', '14:03'),
    TripStep('Ambulance on the way', '14:04'),
    TripStep('Ambulance arrived', ''),
  ];
  // Index of the currently active step (others before are done).
  final int activeTripStep = 2;

  void openEmergencyContacts() => Get.toNamed(Routes.EMERGENCY_CONTACTS);

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
