import 'package:latlong2/latlong.dart';

/// A searched location — from Nominatim place search or reverse-geocoding
/// the device's GPS position.
class SnPlace {
  const SnPlace({
    required this.label,
    required this.address,
    required this.point,
  });

  /// Short primary name, e.g. "Dhaka New Market".
  final String label;

  /// Full display address, e.g. "New Market Rd, Dhaka 1205, Bangladesh".
  final String address;

  final LatLng point;
}
