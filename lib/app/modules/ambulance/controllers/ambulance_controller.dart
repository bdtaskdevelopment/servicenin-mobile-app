import 'package:get/get.dart';

class AmbulanceType {
  const AmbulanceType({
    required this.name,
    required this.subtitle,
    required this.price,
    this.eta,
    this.available,
  });

  final String name;
  final String subtitle;
  final int price;
  final String? eta;
  final int? available;
}

class AmbulanceBooking {
  const AmbulanceBooking({
    required this.id,
    required this.title,
    required this.dateAmount,
  });

  final String id;
  final String title;
  final String dateAmount;
}

class AmbulanceController extends GetxController {
  final String currentLocation = 'House 32, Road 11, Gulshan-2, Dhaka';
  final int nearbyAvailable = 24;
  final String radius = '1 km radius';
  final String area = 'Gulshan-2 · Dhaka';

  final List<AmbulanceType> types = const [
    AmbulanceType(
        name: 'Basic Life',
        subtitle: 'BLS',
        price: 800,
        eta: '6 min',
        available: 12),
    AmbulanceType(
        name: 'Advanced',
        subtitle: 'ALS',
        price: 1500,
        eta: '8 min',
        available: 6),
    AmbulanceType(
        name: 'ICU', subtitle: 'Ventilator', price: 2500),
  ];

  // ICU selected by default (highlighted in the design).
  int selectedType = 2;
  void selectType(int index) {
    selectedType = index;
    update();
  }

  final List<AmbulanceBooking> bookings = const [
    AmbulanceBooking(
        id: 'AMB-2891',
        title: 'ICU · United Hospital',
        dateAmount: '12 May · ৳2,840'),
    AmbulanceBooking(
        id: 'AMB-2710',
        title: 'Basic · Square Hospital',
        dateAmount: '4 May · ৳1,250'),
  ];
}
