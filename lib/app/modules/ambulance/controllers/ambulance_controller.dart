import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../routes/app_pages.dart';

class Zilla {
  const Zilla(this.name, this.lat, this.lng);
  final String name;
  final double lat;
  final double lng;
  LatLng get point => LatLng(lat, lng);
}

class AmbulanceBooking {
  const AmbulanceBooking({
    required this.id,
    required this.title,
    required this.route,
    required this.dateAmount,
    required this.ongoing,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String title;
  final String route;
  final String dateAmount;
  final bool ongoing; // true = on the way, false = completed
  final double lat;
  final double lng;
  LatLng get point => LatLng(lat, lng);
}

class AmbulanceController extends GetxController {
  // ── Division → Zilla data (with coordinates for the map) ────────────
  final Map<String, List<Zilla>> _data = const {
    'Dhaka': [
      Zilla('Dhaka', 23.8103, 90.4125),
      Zilla('Gazipur', 23.9999, 90.4203),
      Zilla('Narayanganj', 23.6238, 90.4990),
    ],
    'Chattogram': [
      Zilla('Chattogram', 22.3569, 91.7832),
      Zilla("Cox's Bazar", 21.4395, 92.0050),
      Zilla('Cumilla', 23.4607, 91.1809),
    ],
    'Khulna': [
      Zilla('Khulna', 22.8456, 89.5403),
      Zilla('Jashore', 23.1667, 89.2167),
    ],
    'Rajshahi': [
      Zilla('Rajshahi', 24.3636, 88.6241),
      Zilla('Bogura', 24.8466, 89.3776),
    ],
    'Sylhet': [
      Zilla('Sylhet', 24.8949, 91.8687),
      Zilla('Moulvibazar', 24.4829, 91.7774),
    ],
    'Barishal': [
      Zilla('Barishal', 22.7010, 90.3535),
      Zilla('Bhola', 22.6859, 90.6482),
    ],
    'Rangpur': [
      Zilla('Rangpur', 25.7439, 89.2752),
      Zilla('Dinajpur', 25.6217, 88.6354),
    ],
    'Mymensingh': [
      Zilla('Mymensingh', 24.7471, 90.4203),
      Zilla('Jamalpur', 24.9375, 89.9372),
    ],
  };

  List<String> get divisions => _data.keys.toList();
  List<Zilla> zillasOf(int divIndex) => _data[divisions[divIndex]]!;

  // Pickup selection
  int pickupDiv = 0;
  int pickupZilla = 0;
  // Destination selection
  int destDiv = 0;
  int destZilla = 1;

  String get pickupDivision => divisions[pickupDiv];
  String get pickupZillaName => zillasOf(pickupDiv)[pickupZilla].name;
  String get destDivision => divisions[destDiv];
  String get destZillaName => zillasOf(destDiv)[destZilla].name;

  LatLng get pickupPoint => zillasOf(pickupDiv)[pickupZilla].point;
  LatLng get destPoint => zillasOf(destDiv)[destZilla].point;

  void setPickupDiv(int i) {
    pickupDiv = i;
    pickupZilla = 0;
    update();
  }

  void setPickupZilla(int i) {
    pickupZilla = i;
    update();
  }

  void setDestDiv(int i) {
    destDiv = i;
    destZilla = 0;
    update();
  }

  void setDestZilla(int i) {
    destZilla = i;
    update();
  }

  // ── Bookings ────────────────────────────────────────────────────────
  final List<AmbulanceBooking> bookings = const [
    AmbulanceBooking(
      id: 'AMB-2891',
      title: 'ICU · United Hospital',
      route: 'Gulshan-2 → United Hospital',
      dateAmount: 'On the way · ৳2,840',
      ongoing: true,
      lat: 23.7980,
      lng: 90.4150,
    ),
    AmbulanceBooking(
      id: 'AMB-2710',
      title: 'Basic · Square Hospital',
      route: 'Dhanmondi → Square Hospital',
      dateAmount: '4 May · ৳1,250',
      ongoing: false,
      lat: 23.7530,
      lng: 90.3780,
    ),
    AmbulanceBooking(
      id: 'AMB-2588',
      title: 'ALS · Evercare Hospital',
      route: 'Bashundhara → Evercare',
      dateAmount: '26 Apr · ৳1,920',
      ongoing: false,
      lat: 23.8150,
      lng: 90.4260,
    ),
  ];

  AmbulanceBooking? selectedBooking;

  // Live ambulance position (moves toward destination on refresh).
  LatLng? _livePos;
  LatLng get liveAmbulancePoint =>
      _livePos ?? selectedBooking?.point ?? const LatLng(23.78, 90.41);

  /// Simulate a location update — step the ambulance toward the destination.
  void refreshAmbulance() {
    final from = liveAmbulancePoint;
    final to = destPoint;
    _livePos = LatLng(
      from.latitude + (to.latitude - from.latitude) * 0.3,
      from.longitude + (to.longitude - from.longitude) * 0.3,
    );
    update();
  }

  /// Re-render the location preview map (re-centres on current selection).
  void refreshMap() => update();

  // ── Navigation ──────────────────────────────────────────────────────
  void openSeeAll() => Get.toNamed(Routes.AMBULANCE_SELECT);
  void openBookings() => Get.toNamed(Routes.AMBULANCE_BOOKINGS);

  void trackBooking(AmbulanceBooking b) {
    selectedBooking = b;
    _livePos = b.point; // reset live position to the booking's start
    update();
    Get.toNamed(Routes.AMBULANCE_TRACKING);
  }
}
